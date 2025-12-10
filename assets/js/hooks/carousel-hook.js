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

    this.activeIndex = parseInt(this.el.dataset.activeIndex) || 0;
    this.transitionType = this.el.dataset.transitionType || "fade";
    this.autoplay = this.el.dataset.autoplay === "true";
    this.autoplayInterval = parseInt(this.el.dataset.autoplayInterval) || 5000;
    this.slidesPerViewDesktop = parseInt(this.el.dataset.slidesPerView) || 1;
    this.slidesPerView = this.getResponsiveSlidesPerView();
    this.gap = this.el.dataset.gap || "1rem";
    this.swipe = this.el.dataset.swipe !== "false"; // Default to true
    this.loop = this.el.dataset.loop !== "false"; // Default to true

    // Detect vertical orientation
    this.isVertical = this.el.classList.contains('pc-carousel--vertical');

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
    this.setupKeyboardNavigation();

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
    if (this.keyboardHandler) {
      this.el.removeEventListener('keydown', this.keyboardHandler);
    }
  },

  // Helper function to apply slide dimensions based on orientation
  applySlideDimensions(slide) {
    slide.style.flex = `0 0 ${this.slideWidth}px`;
    slide.style.scrollSnapAlign = "center";

    if (this.isVertical) {
      slide.style.height = `${this.slideWidth}px`;
      slide.style.minHeight = `${this.slideWidth}px`;
      slide.style.maxHeight = `${this.slideWidth}px`;
      slide.style.width = "100%";
    } else {
      slide.style.width = `${this.slideWidth}px`;
      slide.style.minWidth = `${this.slideWidth}px`;
      slide.style.maxWidth = `${this.slideWidth}px`;
    }
  },

  // Helper function to clone a slide for infinite scrolling
  cloneSlide(slideToClone) {
    const clone = slideToClone.cloneNode(true);
    clone.setAttribute("aria-hidden", "true");
    this.applySlideDimensions(clone);
    return clone;
  },

  // Helper function to reset autoplay after manual interaction
  resetAutoplay() {
    if (this.autoplay) {
      this.stopAutoplay();
      this.startAutoplay();
    }
  },

  getResponsiveSlidesPerView() {
    // If only 1 slide per view on desktop, no need for responsive logic
    if (this.slidesPerViewDesktop <= 1) {
      return 1;
    }

    const width = window.innerWidth;

    // Mobile portrait: 1 slide
    if (width < 768) {
      return 1;
    }
    // Tablet and mobile landscape: 2 slides
    else if (width < 1024) {
      return Math.min(2, this.slidesPerViewDesktop);
    }
    // Desktop: use the configured value
    else {
      return this.slidesPerViewDesktop;
    }
  },

  initScrollSnapCarousel() {
    // Set up CSS Scroll Snap carousel (like the Medium article)
    this.slideWrapper.style.display = "flex";
    this.slideWrapper.style.overflow = "auto";

    // Set scroll snap direction based on orientation
    if (this.isVertical) {
      this.slideWrapper.style.scrollSnapType = "y mandatory";
      this.slideWrapper.style.height = "100%";
    } else {
      this.slideWrapper.style.scrollSnapType = "x mandatory";
      this.slideWrapper.style.width = "100%";
      this.slideWrapper.style.maxWidth = "100%";
    }

    this.slideWrapper.style.scrollbarWidth = "none"; // Firefox

    // Hide webkit scrollbar
    const style = document.createElement("style");
    style.textContent = `
      #${this.id} .pc-carousel__slides::-webkit-scrollbar {
        display: none;
      }
    `;
    document.head.appendChild(style);

    // Update slide dimensions before setting up slides
    this.updateSlideWidth();

    // Set up each slide for scroll snap with explicit dimensions
    this.slides.forEach((slide) => {
      this.applySlideDimensions(slide);
    });

    // Set up infinite scrolling
    this.setupInfiniteScrolling();

    // Set up scroll event listener
    this.setupScrollListener();

    // Set up resize observer
    this.setupResizeObserver();

    // Set up mouse drag support (only if swipe is enabled)
    if (this.swipe) {
      this.setupMouseDrag();
    }

    // Initialize to first real slide (after cloned last slide)
    setTimeout(() => {
      this.goto(0, false); // Use goto with smooth=false for initialization
      this.updateIndicators();
      this.updateButtonStates();
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
    const scrollPos = this.isVertical ? this.slideWrapper.scrollTop : this.slideWrapper.scrollLeft;
    return Math.round(
      scrollPos / (this.slideWidth + this.spaceBtwSlides) -
        this.n_slidesCloned
    );
  },

  goto(index, smooth = true) {
    // Account for cloned slides - add offset for the cloned last slide at the beginning
    const scrollPosition = (this.slideWidth + this.spaceBtwSlides) * (index + this.n_slidesCloned);

    if (smooth) {
      this.slideWrapper.scrollTo({
        left: this.isVertical ? 0 : scrollPosition,
        top: this.isVertical ? scrollPosition : 0,
        behavior: 'smooth'
      });
    } else {
      if (this.isVertical) {
        this.slideWrapper.scrollTo(0, scrollPosition);
      } else {
        this.slideWrapper.scrollTo(scrollPosition, 0);
      }
    }
  },

  setupInfiniteScrolling() {
    if (this.n_slides === 0) return;

    // Skip cloning if loop is disabled
    if (!this.loop) {
      this.n_slidesCloned = 0;
      return;
    }

    // Clone ALL slides and append to end for forward scrolling
    for (let i = 0; i < this.n_slides; i++) {
      this.slideWrapper.append(this.cloneSlide(this.slides[i]));
    }

    // Clone ALL slides and prepend to beginning for backward scrolling
    // Prepend in reverse order so they appear in correct sequence
    for (let i = this.n_slides - 1; i >= 0; i--) {
      this.slideWrapper.prepend(this.cloneSlide(this.slides[i]));
    }
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

      // Handle infinite scrolling with debouncing (skip if loop is disabled)
      if (this.loop) {
        if (scrollTimer) clearTimeout(scrollTimer);

        scrollTimer = setTimeout(() => {
          const scrollPos = this.isVertical ? this.slideWrapper.scrollTop : this.slideWrapper.scrollLeft;

          // For multi-slide view, use position-based detection instead of threshold
          // Calculate the current position index
          const currentPosition = Math.round(scrollPos / (this.slideWidth + this.spaceBtwSlides));

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
      }

      // Update indicators and button states
      this.updateIndicators();
      this.updateButtonStates();
    });
  },

  rewind() {
    // Update index immediately for indicators
    this.activeIndex = 0;
    this.updateIndicators();
    this.updateButtonStates();

    setTimeout(() => {
      this.goto(0, false); // Instant jump to first slide
    }, 50); // Reduced delay for smoother transition
  },

  forward() {
    // Update index immediately for indicators
    this.activeIndex = this.n_slides - 1;
    this.updateIndicators();
    this.updateButtonStates();

    setTimeout(() => {
      this.goto(this.n_slides - 1, false); // Instant jump to last slide
    }, 50); // Reduced delay for smoother transition
  },

  updateSlideWidth() {
    if (this.slideWrapper) {
      // For vertical, we measure height; for horizontal, width
      const containerSize = this.isVertical
        ? this.carouselContainer.offsetHeight
        : this.carouselContainer.offsetWidth;

      // Convert gap to pixels if needed
      const gapInPx = this.parseGapToPixels(this.gap);

      if (this.slidesPerView > 1 && !this.isVertical) {
        // Multi-slide view: calculate width per slide accounting for gaps
        // Total gap space = (number of slides - 1) * gap
        const totalGapSpace = (this.slidesPerView - 1) * gapInPx;
        this.slideWidth = (containerSize - totalGapSpace) / this.slidesPerView;
        this.spaceBtwSlides = gapInPx;

        // Set CSS custom property for gap
        this.slideWrapper.style.setProperty('--carousel-gap', this.gap);
      } else {
        // Single slide view or vertical: full size, no gaps
        this.slideWidth = containerSize;
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

        // Recalculate responsive slides per view
        const newSlidesPerView = this.getResponsiveSlidesPerView();
        const slidesPerViewChanged = newSlidesPerView !== this.slidesPerView;

        if (slidesPerViewChanged) {
          this.slidesPerView = newSlidesPerView;

          // Need to rebuild clones for new slides per view
          if (this.transitionType === "slide") {
            // Remove all cloned slides
            const allSlides = this.slideWrapper.querySelectorAll(".pc-carousel__slide");
            allSlides.forEach((slide) => {
              if (slide.getAttribute("aria-hidden") === "true") {
                slide.remove();
              }
            });

            // Recalculate and setup
            this.updateSlideWidth();
            this.setupInfiniteScrolling();
          }
        } else {
          this.updateSlideWidth();
        }

        // Reapply dimensions to all slides after resize
        if (this.transitionType === "slide") {
          const allSlides = this.slideWrapper.querySelectorAll(".pc-carousel__slide");
          allSlides.forEach((slide) => {
            this.applySlideDimensions(slide);
          });

          this.goto(currentIndex, false); // Instant reposition after resize
        }
      });
      this.resizeObserver.observe(this.slideWrapper);
    }
  },

  setupMouseDrag() {
    let isDragging = false;
    let startPos = 0;
    let scrollPos = 0;
    let currentPos = 0;
    let animationFrame = null;

    // Add cursor style
    this.slideWrapper.style.cursor = 'grab';

    // Smooth scrolling with requestAnimationFrame
    const smoothScroll = () => {
      if (!isDragging) return;

      const walk = (currentPos - startPos) * 1.5; // Adjusted multiplier for smooth feel

      if (this.isVertical) {
        this.slideWrapper.scrollTop = scrollPos - walk;
      } else {
        this.slideWrapper.scrollLeft = scrollPos - walk;
      }

      animationFrame = requestAnimationFrame(smoothScroll);
    };

    const handleMouseDown = (e) => {
      // Don't start drag on buttons or links
      if (e.target.closest('button') || e.target.closest('a')) {
        return;
      }

      isDragging = true;
      this.slideWrapper.style.cursor = 'grabbing';
      this.slideWrapper.style.userSelect = 'none'; // Prevent text selection during drag
      this.slideWrapper.style.scrollSnapType = 'none'; // Disable snap during drag

      if (this.isVertical) {
        startPos = e.pageY - this.slideWrapper.offsetTop;
        scrollPos = this.slideWrapper.scrollTop;
      } else {
        startPos = e.pageX - this.slideWrapper.offsetLeft;
        scrollPos = this.slideWrapper.scrollLeft;
      }

      currentPos = startPos;

      // Start smooth scrolling loop
      animationFrame = requestAnimationFrame(smoothScroll);

      // Pause autoplay during drag
      if (this.autoplay) {
        this.stopAutoplay();
      }
    };

    const handleMouseMove = (e) => {
      if (!isDragging) return;

      e.preventDefault();

      if (this.isVertical) {
        currentPos = e.pageY - this.slideWrapper.offsetTop;
      } else {
        currentPos = e.pageX - this.slideWrapper.offsetLeft;
      }
    };

    const handleMouseUp = () => {
      if (!isDragging) return;

      isDragging = false;
      this.slideWrapper.style.cursor = 'grab';
      this.slideWrapper.style.userSelect = '';
      // Re-enable snap with proper direction
      this.slideWrapper.style.scrollSnapType = this.isVertical ? 'y mandatory' : 'x mandatory';

      // Cancel animation frame
      if (animationFrame) {
        cancelAnimationFrame(animationFrame);
        animationFrame = null;
      }

      // Resume autoplay after drag
      if (this.autoplay) {
        this.startAutoplay();
      }
    };

    const handleMouseLeave = () => {
      if (!isDragging) return;

      isDragging = false;
      this.slideWrapper.style.cursor = 'grab';
      this.slideWrapper.style.userSelect = '';
      // Re-enable snap with proper direction
      this.slideWrapper.style.scrollSnapType = this.isVertical ? 'y mandatory' : 'x mandatory';

      // Cancel animation frame
      if (animationFrame) {
        cancelAnimationFrame(animationFrame);
        animationFrame = null;
      }

      // Resume autoplay if we were dragging
      if (this.autoplay) {
        this.startAutoplay();
      }
    };

    // Add event listeners
    this.slideWrapper.addEventListener('mousedown', handleMouseDown);
    this.slideWrapper.addEventListener('mousemove', handleMouseMove);
    this.slideWrapper.addEventListener('mouseup', handleMouseUp);
    this.slideWrapper.addEventListener('mouseleave', handleMouseLeave);

    // Prevent drag on links and images
    this.slideWrapper.addEventListener('dragstart', (e) => {
      e.preventDefault();
    });

    // Prevent click events if there was significant dragging
    let clickStartX = 0;
    this.slideWrapper.addEventListener('mousedown', (e) => {
      clickStartX = e.pageX;
    });
    this.slideWrapper.addEventListener('click', (e) => {
      const clickEndX = e.pageX;
      if (Math.abs(clickEndX - clickStartX) > 5) {
        e.preventDefault();
        e.stopPropagation();
      }
    }, true);
  },

  setupNavigation() {
    // Look in wrapper to support "below" button style
    const prevButton = this.wrapper.querySelector(`#${this.id}-carousel-prev`);
    const nextButton = this.wrapper.querySelector(`#${this.id}-carousel-next`);

    if (prevButton) {
      prevButton.addEventListener("click", () => {
        this.prevSlide();
        this.resetAutoplay();
      });
    }

    if (nextButton) {
      nextButton.addEventListener("click", () => {
        this.nextSlide();
        this.resetAutoplay();
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
        this.resetAutoplay();
      });
    });

    // Set initial indicator state
    this.updateIndicators();
  },

  setupKeyboardNavigation() {
    // Add keyboard navigation for accessibility
    this.keyboardHandler = (e) => {
      // Only respond to arrow keys
      const isArrowKey = ['ArrowLeft', 'ArrowRight', 'ArrowUp', 'ArrowDown'].includes(e.key);
      if (!isArrowKey) return;

      // Prevent default scrolling behavior
      e.preventDefault();

      // Determine direction based on orientation and key
      const isNext = this.isVertical
        ? e.key === 'ArrowDown'
        : e.key === 'ArrowRight';
      const isPrev = this.isVertical
        ? e.key === 'ArrowUp'
        : e.key === 'ArrowLeft';

      if (isNext) {
        this.nextSlide();
      } else if (isPrev) {
        this.prevSlide();
      }

      this.resetAutoplay();
    };

    // Make carousel focusable
    if (!this.el.hasAttribute('tabindex')) {
      this.el.setAttribute('tabindex', '0');
    }

    // Add event listener
    this.el.addEventListener('keydown', this.keyboardHandler);
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
    // Prevent rapid consecutive calls
    if (this.isTransitioning) {
      return;
    }

    if (this.transitionType === "slide") {
      this.isTransitioning = true;

      if (this.activeIndex === 0) {
        // If loop is disabled, prevent going past the first slide
        if (!this.loop) {
          this.isTransitioning = false;
          return;
        }

        // At first slide with loop enabled, scroll to the cloned slides at the beginning
        const scrollPosition = (this.slideWidth + this.spaceBtwSlides) * (this.n_slidesCloned - 1);
        this.slideWrapper.scrollTo({
          left: this.isVertical ? 0 : scrollPosition,
          top: this.isVertical ? scrollPosition : 0,
          behavior: 'smooth'
        });
      } else {
        // Normal previous slide
        this.activeIndex = this.activeIndex - 1;
        this.goto(this.activeIndex);
      }

      // Release lock after transition completes
      setTimeout(() => {
        this.isTransitioning = false;
      }, 600); // Slightly longer than CSS transition
    } else {
      // Fade transition
      if (!this.loop && this.activeIndex === 0) {
        // At first slide with loop disabled, prevent going previous
        return;
      }
      const newIndex = (this.activeIndex - 1 + this.n_slides) % this.n_slides;
      this.goToSlide(newIndex);
    }
  },

  nextSlide() {
    // Prevent rapid consecutive calls
    if (this.isTransitioning) {
      return;
    }

    if (this.transitionType === "slide") {
      this.isTransitioning = true;

      if (this.activeIndex >= this.n_slides - 1) {
        // If loop is disabled, prevent going past the last slide
        if (!this.loop) {
          this.isTransitioning = false;
          return;
        }

        // At last slide with loop enabled, smoothly scroll to the first slide position
        this.activeIndex = 0;
        // Scroll past all slides to trigger rewind
        const scrollPosition = (this.slideWidth + this.spaceBtwSlides) * (this.n_slides + this.n_slidesCloned);
        this.slideWrapper.scrollTo({
          left: this.isVertical ? 0 : scrollPosition,
          top: this.isVertical ? scrollPosition : 0,
          behavior: 'smooth'
        });
      } else {
        // Normal next slide
        this.activeIndex = this.activeIndex + 1;
        this.goto(this.activeIndex);
      }

      // Release lock after transition completes
      setTimeout(() => {
        this.isTransitioning = false;
      }, 600); // Slightly longer than CSS transition
    } else {
      // Fade transition
      if (!this.loop && this.activeIndex >= this.n_slides - 1) {
        // At last slide with loop disabled, prevent going next
        return;
      }
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

    // Update indicators and button states
    this.updateIndicators();
    this.updateButtonStates();
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

    // Update aria-current on slides
    this.slides.forEach((slide, index) => {
      if (index === this.activeIndex) {
        slide.setAttribute('aria-current', 'true');
      } else {
        slide.setAttribute('aria-current', 'false');
      }
    });

    // Announce slide change to screen readers
    this.announceSlideChange();
  },

  announceSlideChange() {
    const liveRegion = this.el.querySelector(`#${this.id}-live-region`);
    if (liveRegion) {
      liveRegion.textContent = `Slide ${this.activeIndex + 1} of ${this.n_slides}`;
    }
  },

  updateButtonStates() {
    // Only update button states when loop is disabled
    if (this.loop) {
      // When loop is enabled, ensure buttons are always enabled
      const prevButton = this.wrapper.querySelector(`#${this.id}-carousel-prev`);
      const nextButton = this.wrapper.querySelector(`#${this.id}-carousel-next`);

      if (prevButton) prevButton.disabled = false;
      if (nextButton) nextButton.disabled = false;
      return;
    }

    // When loop is disabled, disable buttons at boundaries
    const prevButton = this.wrapper.querySelector(`#${this.id}-carousel-prev`);
    const nextButton = this.wrapper.querySelector(`#${this.id}-carousel-next`);

    if (prevButton) {
      prevButton.disabled = this.activeIndex === 0;
    }

    if (nextButton) {
      nextButton.disabled = this.activeIndex >= this.n_slides - 1;
    }
  },
};

export default CarouselHook;
