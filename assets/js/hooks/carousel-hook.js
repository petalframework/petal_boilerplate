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
    }
  },

  destroyed() {
    if (this.autoplayTimer) {
      clearInterval(this.autoplayTimer);
    }
  },

  initScrollSnapCarousel() {
    // Set up CSS Scroll Snap carousel (like the Medium article)
    this.slideWrapper.style.display = "flex";
    this.slideWrapper.style.overflow = "auto";
    this.slideWrapper.style.scrollSnapType = "x mandatory";
    this.slideWrapper.style.scrollbarWidth = "none"; // Firefox

    // Hide webkit scrollbar
    const style = document.createElement("style");
    style.textContent = `
      #${this.id} .pc-carousel__slides::-webkit-scrollbar {
        display: none;
      }
    `;
    document.head.appendChild(style);

    // Set up each slide for scroll snap
    this.slides.forEach((slide, index) => {
      slide.style.flex = "0 0 auto";
      slide.style.scrollSnapAlign = "center";
      slide.style.width = "100%";
    });

    // Update slide width first
    this.updateSlideWidth();
    console.log(
      `[Carousel ${this.id}] Slide width: ${this.slideWidth}px, Space: ${this.spaceBtwSlides}px`
    );

    // For now, let's disable infinite scrolling and just get basic scrolling working
    // this.setupInfiniteScrolling();

    // Set up scroll event listener (simplified for now)
    // this.setupScrollListener();

    // Set up resize observer
    this.setupResizeObserver();

    // Don't initialize position yet - let it start at 0 naturally
    // this.goto(0);
    this.slideWrapper.classList.add("smooth-scroll");
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

  goto(index) {
    // Simple scrolling without infinite scroll for now
    const scrollPosition = this.slideWidth * index;
    console.log(
      `[Carousel ${this.id}] goto(${index}), slideWidth: ${this.slideWidth}, scrollTo: ${scrollPosition}px`
    );
    console.log(
      `[Carousel ${this.id}] Current scrollLeft before goto:`,
      this.slideWrapper.scrollLeft
    );
    this.slideWrapper.scrollTo(scrollPosition, 0);
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
    firstSlideClone.style.flex = "0 0 auto";
    firstSlideClone.style.scrollSnapAlign = "center";
    firstSlideClone.style.width = "100%";
    this.slideWrapper.append(firstSlideClone);

    // Clone last slide and prepend to beginning
    const lastSlideClone = this.slides[this.n_slides - 1].cloneNode(true);
    lastSlideClone.setAttribute("aria-hidden", "true");
    lastSlideClone.style.flex = "0 0 auto";
    lastSlideClone.style.scrollSnapAlign = "center";
    lastSlideClone.style.width = "100%";
    this.slideWrapper.prepend(lastSlideClone);

    console.log(
      `[Carousel ${this.id}] Cloned slides added. Total slides in DOM:`,
      this.slideWrapper.children.length
    );
  },

  setupScrollListener() {
    let scrollTimer;
    this.slideWrapper.addEventListener("scroll", () => {
      // Reset nav dots
      this.navdots.forEach((navdot) => {
        navdot.classList.remove("opacity-100");
      });

      // Handle infinite scrolling
      if (scrollTimer) clearTimeout(scrollTimer);
      scrollTimer = setTimeout(() => {
        if (
          this.slideWrapper.scrollLeft <
          (this.slideWidth + this.spaceBtwSlides) *
            (this.n_slidesCloned - 1 / 2)
        ) {
          this.forward();
        }
        if (
          this.slideWrapper.scrollLeft >
          (this.slideWidth + this.spaceBtwSlides) *
            (this.n_slides - 1 + this.n_slidesCloned + 1 / 2)
        ) {
          this.rewind();
        }
      }, 100);

      // Update nav dots
      this.updateNavdot();
    });
  },

  rewind() {
    this.slideWrapper.classList.remove("smooth-scroll");
    setTimeout(() => {
      this.slideWrapper.scrollTo(
        (this.slideWidth + this.spaceBtwSlides) * this.n_slidesCloned,
        0
      );
      this.slideWrapper.classList.add("smooth-scroll");
    }, 100);
  },

  forward() {
    this.slideWrapper.classList.remove("smooth-scroll");
    setTimeout(() => {
      this.slideWrapper.scrollTo(
        (this.slideWidth + this.spaceBtwSlides) *
          (this.n_slides - 1 + this.n_slidesCloned),
        0
      );
      this.slideWrapper.classList.add("smooth-scroll");
    }, 100);
  },

  updateSlideWidth() {
    if (this.slideWrapper && this.slides[0]) {
      this.slideWidth = this.slides[0].offsetWidth;
      // For CSS Scroll Snap, we don't need gaps between slides
      this.spaceBtwSlides = 0;
    }
  },

  setupResizeObserver() {
    if (typeof ResizeObserver !== "undefined") {
      this.resizeObserver = new ResizeObserver(() => {
        this.updateSlideWidth();
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
      });
    }

    if (nextButton) {
      nextButton.addEventListener("click", () => {
        console.log(`[Carousel ${this.id}] Next button clicked`);
        this.nextSlide();
      });
    }
  },

  setupIndicators() {
    this.navdots.forEach((indicator, index) => {
      indicator.addEventListener("click", () => {
        if (this.transitionType === "slide") {
          this.goto(index);
        } else {
          this.goToSlide(index);
        }
      });
    });

    // Set initial indicator state
    this.updateIndicators();
  },

  updateNavdot() {
    const c = this.index_slideCurrent();
    if (c < 0 || c >= this.n_slides) return; // Skip for cloned slides

    if (this.navdots[c]) {
      this.navdots[c].classList.add("opacity-100");
    }
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
      // Simple previous slide logic
      this.activeIndex = Math.max(0, this.activeIndex - 1);
      console.log(`[Carousel ${this.id}] Going to slide: ${this.activeIndex}`);
      this.goto(this.activeIndex);
    } else {
      this.goToSlide(this.activeIndex - 1);
    }
  },

  nextSlide() {
    console.log(
      `[Carousel ${this.id}] nextSlide called, transitionType: ${this.transitionType}`
    );
    if (this.transitionType === "slide") {
      // Simple next slide logic
      this.activeIndex = Math.min(this.n_slides - 1, this.activeIndex + 1);
      console.log(`[Carousel ${this.id}] Going to slide: ${this.activeIndex}`);
      this.goto(this.activeIndex);
    } else {
      this.goToSlide(this.activeIndex + 1);
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

        if (this.autoplay) {
          this.stopAutoplay();
          this.startAutoplay();
        }
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
