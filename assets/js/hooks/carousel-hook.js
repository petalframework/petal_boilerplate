const CarouselHook = {
  mounted() {
    this.id = this.el.id;
    this.carouselContainer = this.el;
    // Look for wrapper to support "below" button style
    this.wrapper = this.el.closest('.pc-carousel-wrapper') || this.el;
    this.slideWrapper = this.el.querySelector(".pc-carousel__slides");
    this.slides = Array.from(this.el.querySelectorAll(".pc-carousel__slide"));
    this.navdots = Array.from(
      this.el.querySelectorAll(".pc-carousel__indicator")
    );

    console.log(
      `[Carousel ${this.id}] Mounted with ${this.slides.length} slides`
    );
    console.log(`[Carousel ${this.id}] slideWrapper:`, this.slideWrapper);

    this.activeIndex = parseInt(this.el.dataset.activeIndex) || 0;
    this.transitionType = this.el.dataset.transitionType || "fade";
    this.autoplay = this.el.dataset.autoplay === "true";
    this.autoplayInterval = parseInt(this.el.dataset.autoplayInterval) || 5000;
    this.slidesPerView = parseInt(this.el.dataset.slidesPerView) || 1;
    this.gap = this.el.dataset.gap || "1rem";

    console.log(`[Carousel ${this.id}] transitionType: ${this.transitionType}`);
    console.log(`[Carousel ${this.id}] slidesPerView: ${this.slidesPerView}, gap: ${this.gap}`);

    // Parameters for CSS Scroll Snap approach
    this.n_slides = this.slides.length;
    // For multi-slide view with infinite loop, clone all slides on each side for seamless wrapping
    // This allows scrolling in both directions through the loop
    this.n_slidesCloned = this.transitionType === "slide" ? this.n_slides : 0;
    this.slideWidth = this.slides[0] ? this.slides[0].offsetWidth : 0;
    // For CSS Scroll Snap, we don't need gaps between slides
    this.spaceBtwSlides = 0;

    // For infinite carousels, we cycle through all slides
    // For non-infinite, the last position shows the last N slides
    this.maxScrollIndex = this.n_slides - 1;

    if (this.transitionType === "slide") {
      this.initScrollSnapCarousel();
    } else {
      this.initFadeCarousel();
    }

    this.setupNavigation();
    this.setupIndicators();

    if (this.autoplay) {
      this.startAutoplay();

      // Pause on hover
      this.el.addEventListener("mouseenter", () => {
        this.stopAutoplay();
      });

      this.el.addEventListener("mouseleave", () => {
        this.startAutoplay();
      });
    }
  },

  destroyed() {
    if (this.autoplayTimer) {
      clearInterval(this.autoplayTimer);
    }
    if (this.resizeObserver) {
      this.resizeObserver.disconnect();
    }
  },

  initScrollSnapCarousel() {
    // Set up CSS Scroll Snap carousel (like the Medium article)
    this.slideWrapper.style.display = "flex";
    this.slideWrapper.style.overflow = "auto";
    this.slideWrapper.style.scrollSnapType = "x mandatory";
    this.slideWrapper.style.scrollbarWidth = "none"; // Firefox
    this.slideWrapper.style.width = "100%";
    this.slideWrapper.style.maxWidth = "100%";

    // Hide webkit scrollbar
    const style = document.createElement("style");
    style.textContent = `
      #${this.id} .pc-carousel__slides::-webkit-scrollbar {
        display: none;
      }
    `;
    document.head.appendChild(style);

    // Update slide width before setting up slides
    // This ensures we have the correct container width
    this.updateSlideWidth();
    console.log(
      `[Carousel ${this.id}] Slide width: ${this.slideWidth}px, Space: ${this.spaceBtwSlides}px`
    );

    // Set up each slide for scroll snap with explicit width
    this.slides.forEach((slide, index) => {
      slide.style.flex = `0 0 ${this.slideWidth}px`;
      slide.style.scrollSnapAlign = "center";
      slide.style.width = `${this.slideWidth}px`;
      slide.style.minWidth = `${this.slideWidth}px`;
      slide.style.maxWidth = `${this.slideWidth}px`;
    });

    // Set up infinite scrolling
    this.setupInfiniteScrolling();

    // Set up scroll event listener
    this.setupScrollListener();

    // Set up resize observer
    this.setupResizeObserver();

    // Initialize to first real slide (after cloned last slide)
    setTimeout(() => {
      this.goto(0, false); // Use goto with smooth=false for initialization
      this.updateIndicators();
    }, 50);
  },

  initFadeCarousel() {
    // Keep existing fade logic
    this.transitionDuration =
      parseInt(this.el.dataset.transitionDuration) || 500;

    this.slides.forEach((slide, index) => {
      slide.style.position = "absolute";
      slide.style.top = "0";
      slide.style.left = "0";
      slide.style.width = "100%";
      slide.style.height = "100%";
      slide.style.transition = `opacity ${this.transitionDuration}ms ease-in-out`;

      if (index === this.activeIndex) {
        slide.classList.add("pc-carousel__slide--active");
        slide.style.opacity = "1";
        slide.style.zIndex = "10";
      } else {
        slide.classList.add("pc-carousel__slide--inactive");
        slide.style.opacity = "0";
        slide.style.zIndex = "1";
      }
    });
  },

  // CSS Scroll Snap helper functions (from Medium article)
  index_slideCurrent() {
    return Math.round(
      this.slideWrapper.scrollLeft / (this.slideWidth + this.spaceBtwSlides) -
        this.n_slidesCloned
    );
  },

  goto(index, smooth = true) {
    // Account for cloned slides - add offset for the cloned last slide at the beginning
    const scrollPosition = (this.slideWidth + this.spaceBtwSlides) * (index + this.n_slidesCloned);
    console.log(
      `[Carousel ${this.id}] goto(${index}), slideWidth: ${this.slideWidth}, scrollTo: ${scrollPosition}px, smooth: ${smooth}`
    );
    console.log(
      `[Carousel ${this.id}] Current scrollLeft before goto:`,
      this.slideWrapper.scrollLeft
    );

    if (smooth) {
      this.slideWrapper.scrollTo({
        left: scrollPosition,
        top: 0,
        behavior: 'smooth'
      });
    } else {
      this.slideWrapper.scrollTo(scrollPosition, 0);
    }

    console.log(
      `[Carousel ${this.id}] Current scrollLeft after goto:`,
      this.slideWrapper.scrollLeft
    );
  },

  setupInfiniteScrolling() {
    if (this.n_slides === 0) return;

    // Clone ALL slides and append to end for forward scrolling
    for (let i = 0; i < this.n_slides; i++) {
      const slideToClone = this.slides[i];
      const clone = slideToClone.cloneNode(true);
      clone.setAttribute("aria-hidden", "true");
      clone.style.flex = `0 0 ${this.slideWidth}px`;
      clone.style.scrollSnapAlign = "center";
      clone.style.width = `${this.slideWidth}px`;
      clone.style.minWidth = `${this.slideWidth}px`;
      clone.style.maxWidth = `${this.slideWidth}px`;
      this.slideWrapper.append(clone);
    }

    // Clone ALL slides and prepend to beginning for backward scrolling
    // Prepend in reverse order so they appear in correct sequence
    for (let i = this.n_slides - 1; i >= 0; i--) {
      const slideToClone = this.slides[i];
      const clone = slideToClone.cloneNode(true);
      clone.setAttribute("aria-hidden", "true");
      clone.style.flex = `0 0 ${this.slideWidth}px`;
      clone.style.scrollSnapAlign = "center";
      clone.style.width = `${this.slideWidth}px`;
      clone.style.minWidth = `${this.slideWidth}px`;
      clone.style.maxWidth = `${this.slideWidth}px`;
      this.slideWrapper.prepend(clone);
    }

    console.log(
      `[Carousel ${this.id}] Cloned ${this.n_slides} slides on each side. Total slides in DOM:`,
      this.slideWrapper.children.length
    );
  },

  setupScrollListener() {
    let scrollTimer;
    this.isScrolling = false;

    this.slideWrapper.addEventListener("scroll", () => {
      // Update active index based on current scroll position
      const currentIndex = this.index_slideCurrent();
      if (currentIndex >= 0 && currentIndex < this.n_slides) {
        this.activeIndex = currentIndex;
      }

      // Handle infinite scrolling with debouncing
      if (scrollTimer) clearTimeout(scrollTimer);

      scrollTimer = setTimeout(() => {
        const scrollLeft = this.slideWrapper.scrollLeft;

        // For multi-slide view, use position-based detection instead of threshold
        // Calculate the current position index
        const currentPosition = Math.round(scrollLeft / (this.slideWidth + this.spaceBtwSlides));

        // Check if we're at or before the first real slide position
        // Real slides start at position n_slidesCloned
        if (currentPosition < this.n_slidesCloned) {
          this.forward();
        }
        // Check if we're at or after the last cloned slide position
        // Cloned slides at end start at position (n_slidesCloned + n_slides)
        else if (currentPosition >= this.n_slidesCloned + this.n_slides) {
          this.rewind();
        }
      }, 100);

      // Update indicators
      this.updateIndicators();
    });
  },

  rewind() {
    // Update index immediately for indicators
    this.activeIndex = 0;
    this.updateIndicators();

    setTimeout(() => {
      this.goto(0, false); // Instant jump to first slide
    }, 50); // Reduced delay for smoother transition
  },

  forward() {
    // Update index immediately for indicators
    this.activeIndex = this.n_slides - 1;
    this.updateIndicators();

    setTimeout(() => {
      this.goto(this.n_slides - 1, false); // Instant jump to last slide
    }, 50); // Reduced delay for smoother transition
  },

  updateSlideWidth() {
    if (this.slideWrapper) {
      const containerWidth = this.carouselContainer.offsetWidth;

      // Convert gap to pixels if needed
      const gapInPx = this.parseGapToPixels(this.gap);

      if (this.slidesPerView > 1) {
        // Multi-slide view: calculate width per slide accounting for gaps
        // Total gap space = (number of slides - 1) * gap
        const totalGapSpace = (this.slidesPerView - 1) * gapInPx;
        this.slideWidth = (containerWidth - totalGapSpace) / this.slidesPerView;
        this.spaceBtwSlides = gapInPx;

        // Set CSS custom property for gap
        this.slideWrapper.style.setProperty('--carousel-gap', this.gap);
      } else {
        // Single slide view: full width, no gaps
        this.slideWidth = containerWidth;
        this.spaceBtwSlides = 0;
      }
    }
  },

  parseGapToPixels(gap) {
    // Convert rem, em, or px values to pixels
    if (gap.endsWith('rem')) {
      const remValue = parseFloat(gap);
      const rootFontSize = parseFloat(getComputedStyle(document.documentElement).fontSize);
      return remValue * rootFontSize;
    } else if (gap.endsWith('em')) {
      const emValue = parseFloat(gap);
      const fontSize = parseFloat(getComputedStyle(this.el).fontSize);
      return emValue * fontSize;
    } else if (gap.endsWith('px')) {
      return parseFloat(gap);
    } else {
      // Assume pixels if no unit
      return parseFloat(gap) || 0;
    }
  },

  setupResizeObserver() {
    if (typeof ResizeObserver !== "undefined") {
      this.resizeObserver = new ResizeObserver(() => {
        const currentIndex = this.activeIndex;
        this.updateSlideWidth();
        // Reapply widths to all slides after resize
        if (this.transitionType === "slide") {
          const allSlides = this.slideWrapper.querySelectorAll(".pc-carousel__slide");
          allSlides.forEach((slide) => {
            slide.style.flex = `0 0 ${this.slideWidth}px`;
            slide.style.width = `${this.slideWidth}px`;
            slide.style.minWidth = `${this.slideWidth}px`;
            slide.style.maxWidth = `${this.slideWidth}px`;
          });

          this.goto(currentIndex, false); // Instant reposition after resize
        }
      });
      this.resizeObserver.observe(this.slideWrapper);
    }
  },

  setupNavigation() {
    // Look in wrapper to support "below" button style
    const prevButton = this.wrapper.querySelector(`#${this.id}-carousel-prev`);
    const nextButton = this.wrapper.querySelector(`#${this.id}-carousel-next`);

    console.log(`[Carousel ${this.id}] prevButton:`, prevButton);
    console.log(`[Carousel ${this.id}] nextButton:`, nextButton);

    if (prevButton) {
      prevButton.addEventListener("click", () => {
        console.log(`[Carousel ${this.id}] Previous button clicked`);
        this.prevSlide();
        // Reset autoplay on manual interaction
        if (this.autoplay) {
          this.stopAutoplay();
          this.startAutoplay();
        }
      });
    }

    if (nextButton) {
      nextButton.addEventListener("click", () => {
        console.log(`[Carousel ${this.id}] Next button clicked`);
        this.nextSlide();
        // Reset autoplay on manual interaction
        if (this.autoplay) {
          this.stopAutoplay();
          this.startAutoplay();
        }
      });
    }
  },

  setupIndicators() {
    this.navdots.forEach((indicator, index) => {
      indicator.addEventListener("click", () => {
        if (this.transitionType === "slide") {
          this.activeIndex = index;
          this.goto(index);
          this.updateIndicators();
        } else {
          this.goToSlide(index);
        }
        // Reset autoplay on manual interaction
        if (this.autoplay) {
          this.stopAutoplay();
          this.startAutoplay();
        }
      });
    });

    // Set initial indicator state
    this.updateIndicators();
  },

  startAutoplay() {
    // Clear any existing timer first to prevent duplicates
    this.stopAutoplay();

    this.autoplayTimer = setInterval(() => {
      this.nextSlide();
    }, this.autoplayInterval);
  },

  stopAutoplay() {
    if (this.autoplayTimer) {
      clearInterval(this.autoplayTimer);
      this.autoplayTimer = null;
    }
  },

  prevSlide() {
    console.log(
      `[Carousel ${this.id}] prevSlide called, transitionType: ${this.transitionType}`
    );

    // Prevent rapid consecutive calls
    if (this.isTransitioning) {
      console.log(`[Carousel ${this.id}] Ignoring prevSlide - already transitioning`);
      return;
    }

    if (this.transitionType === "slide") {
      this.isTransitioning = true;

      if (this.activeIndex === 0) {
        // At first slide, scroll LEFT to the cloned slides at the beginning
        // Position (n_slidesCloned - 1) shows the last cloned slide with first real slides
        // This creates the visual of going backwards to the previous loop
        const scrollPosition = (this.slideWidth + this.spaceBtwSlides) * (this.n_slidesCloned - 1);
        console.log(`[Carousel ${this.id}] Scrolling left to position ${this.n_slidesCloned - 1} for prev loop`);
        this.slideWrapper.scrollTo({
          left: scrollPosition,
          top: 0,
          behavior: 'smooth'
        });
      } else {
        // Normal previous slide
        this.activeIndex = this.activeIndex - 1;
        console.log(`[Carousel ${this.id}] Going to slide: ${this.activeIndex}`);
        this.goto(this.activeIndex);
      }

      // Release lock after transition completes
      setTimeout(() => {
        this.isTransitioning = false;
      }, 600); // Slightly longer than CSS transition
    } else {
      const newIndex = (this.activeIndex - 1 + this.n_slides) % this.n_slides;
      this.goToSlide(newIndex);
    }
  },

  nextSlide() {
    console.log(
      `[Carousel ${this.id}] nextSlide called, transitionType: ${this.transitionType}`
    );

    // Prevent rapid consecutive calls
    if (this.isTransitioning) {
      console.log(`[Carousel ${this.id}] Ignoring nextSlide - already transitioning`);
      return;
    }

    if (this.transitionType === "slide") {
      this.isTransitioning = true;

      if (this.activeIndex >= this.n_slides - 1) {
        // At last slide, smoothly scroll to the first slide position
        // The goto function will handle scrolling to the position after all slides,
        // which triggers the rewind() to seamlessly jump back to the real first slide
        this.activeIndex = 0;
        console.log(`[Carousel ${this.id}] Looping to first slide`);
        // Scroll past all slides to trigger rewind
        const scrollPosition = (this.slideWidth + this.spaceBtwSlides) * (this.n_slides + this.n_slidesCloned);
        this.slideWrapper.scrollTo({
          left: scrollPosition,
          top: 0,
          behavior: 'smooth'
        });
      } else {
        // Normal next slide
        this.activeIndex = this.activeIndex + 1;
        console.log(`[Carousel ${this.id}] Going to slide: ${this.activeIndex}`);
        this.goto(this.activeIndex);
      }

      // Release lock after transition completes
      setTimeout(() => {
        this.isTransitioning = false;
      }, 600); // Slightly longer than CSS transition
    } else {
      const newIndex = (this.activeIndex + 1) % this.n_slides;
      this.goToSlide(newIndex);
    }
  },

  goToSlide(newIndex) {
    if (this.isTransitioning) return;

    this.isTransitioning = true;
    const oldIndex = this.activeIndex;
    this.activeIndex = newIndex;

    if (this.transitionType === "slide") {
      // For direct navigation, we'll use a simple approach
      // This could be enhanced to animate to the target slide
      this.isTransitioning = false;
      this.updateIndicators();
    } else {
      // Fade transition - works for both forward and backward
      const currentSlide = this.slides[oldIndex];
      const nextSlide = this.slides[newIndex];

      // Update classes
      currentSlide.classList.remove("pc-carousel__slide--active");
      currentSlide.classList.add("pc-carousel__slide--inactive");
      nextSlide.classList.remove("pc-carousel__slide--inactive");
      nextSlide.classList.add("pc-carousel__slide--active");

      // Set up the incoming slide
      nextSlide.style.zIndex = "10";
      nextSlide.style.opacity = "0";

      // Force reflow to ensure opacity 0 is applied before transition
      void nextSlide.offsetWidth;

      // Start fade in AND fade out simultaneously
      nextSlide.style.opacity = "1";
      currentSlide.style.opacity = "0";

      // Clean up after transition completes
      setTimeout(() => {
        currentSlide.style.zIndex = "1";
        this.isTransitioning = false;
      }, this.transitionDuration);
    }

    // Update indicators
    this.updateIndicators();
  },

  updateIndicators() {
    const indicators = this.el.querySelectorAll(".pc-carousel__indicator");

    indicators.forEach((indicator, index) => {
      if (index === this.activeIndex) {
        indicator.classList.add("opacity-100");
      } else {
        indicator.classList.remove("opacity-100");
      }
    });
  },
};

export default CarouselHook;
