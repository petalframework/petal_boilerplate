const CarouselHook = {
  mounted() {
    this.id = this.el.id;
    this.carouselContainer = this.el;
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

    console.log(`[Carousel ${this.id}] transitionType: ${this.transitionType}`);

    // Parameters for CSS Scroll Snap approach
    this.n_slides = this.slides.length;
    this.n_slidesCloned = this.transitionType === "slide" ? 1 : 0;
    this.slideWidth = this.slides[0] ? this.slides[0].offsetWidth : 0;
    // For CSS Scroll Snap, we don't need gaps between slides
    this.spaceBtwSlides = 0;

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

    // Clone first slide and append to end
    const firstSlideClone = this.slides[0].cloneNode(true);
    firstSlideClone.setAttribute("aria-hidden", "true");
    firstSlideClone.style.flex = `0 0 ${this.slideWidth}px`;
    firstSlideClone.style.scrollSnapAlign = "center";
    firstSlideClone.style.width = `${this.slideWidth}px`;
    firstSlideClone.style.minWidth = `${this.slideWidth}px`;
    firstSlideClone.style.maxWidth = `${this.slideWidth}px`;
    this.slideWrapper.append(firstSlideClone);

    // Clone last slide and prepend to beginning
    const lastSlideClone = this.slides[this.n_slides - 1].cloneNode(true);
    lastSlideClone.setAttribute("aria-hidden", "true");
    lastSlideClone.style.flex = `0 0 ${this.slideWidth}px`;
    lastSlideClone.style.scrollSnapAlign = "center";
    lastSlideClone.style.width = `${this.slideWidth}px`;
    lastSlideClone.style.minWidth = `${this.slideWidth}px`;
    lastSlideClone.style.maxWidth = `${this.slideWidth}px`;
    this.slideWrapper.prepend(lastSlideClone);

    console.log(
      `[Carousel ${this.id}] Cloned slides added. Total slides in DOM:`,
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
        const threshold = (this.slideWidth + this.spaceBtwSlides) * 0.5;

        // Check if we're at the cloned last slide (beginning)
        if (scrollLeft < threshold) {
          this.forward();
        }
        // Check if we're at the cloned first slide (end)
        else if (scrollLeft > (this.slideWidth + this.spaceBtwSlides) * (this.n_slides + this.n_slidesCloned) - threshold) {
          this.rewind();
        }
      }, 150); // Increased delay to let smooth scroll finish

      // Update indicators
      this.updateIndicators();
    });
  },

  rewind() {
    setTimeout(() => {
      this.goto(0, false); // Instant jump to first slide
    }, 100);
  },

  forward() {
    setTimeout(() => {
      this.goto(this.n_slides - 1, false); // Instant jump to last slide
    }, 100);
  },

  updateSlideWidth() {
    if (this.slideWrapper) {
      // Use the carousel container width, not the slide width
      // This ensures we get the constrained width, not the expanded slide width
      this.slideWidth = this.carouselContainer.offsetWidth;
      // For CSS Scroll Snap, we don't need gaps between slides
      this.spaceBtwSlides = 0;
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
    const prevButton = this.el.querySelector(`#${this.id}-carousel-prev`);
    const nextButton = this.el.querySelector(`#${this.id}-carousel-next`);

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
    if (this.transitionType === "slide") {
      if (this.activeIndex === 0) {
        // At first slide, scroll to cloned last slide (position -1 in our offset system)
        // This will trigger the forward() function to instantly reposition
        const scrollPosition = 0; // Scroll to the very beginning (cloned last slide)
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
    } else {
      const newIndex = (this.activeIndex - 1 + this.n_slides) % this.n_slides;
      this.goToSlide(newIndex);
    }
  },

  nextSlide() {
    console.log(
      `[Carousel ${this.id}] nextSlide called, transitionType: ${this.transitionType}`
    );
    if (this.transitionType === "slide") {
      if (this.activeIndex === this.n_slides - 1) {
        // At last slide, scroll to cloned first slide (after all real slides)
        // This will trigger the rewind() function to instantly reposition
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
      // Fade transition
      const currentSlide = this.slides[oldIndex];
      const nextSlide = this.slides[newIndex];

      currentSlide.classList.remove("pc-carousel__slide--active");
      currentSlide.classList.add("pc-carousel__slide--inactive");
      nextSlide.classList.remove("pc-carousel__slide--inactive");
      nextSlide.classList.add("pc-carousel__slide--active");

      nextSlide.style.zIndex = "10";
      nextSlide.style.opacity = "0";
      void nextSlide.offsetWidth;
      nextSlide.style.opacity = "1";

      setTimeout(() => {
        currentSlide.style.opacity = "0";
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
