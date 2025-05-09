const CarouselHook = {
  mounted() {
    this.id = this.el.id;
    this.slides = this.el.querySelectorAll(".pc-carousel__slide");
    this.activeIndex = parseInt(this.el.dataset.activeIndex) || 0;
    this.autoplay = this.el.dataset.autoplay === "true";
    this.autoplayInterval = parseInt(this.el.dataset.autoplayInterval) || 5000;
    this.transitionType = this.el.dataset.transitionType || "fade";
    this.transitionDuration =
      parseInt(this.el.dataset.transitionDuration) || 500;
    this.autoplayTimer = null;
    this.isTransitioning = false;

    // Initialize slides
    for (let i = 0; i < this.slides.length; i++) {
      this.setupSlide(this.slides[i], i);
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

  setupSlide(slide, index) {
    slide.style.position = "absolute";
    slide.style.top = "0";
    slide.style.left = "0";
    slide.style.width = "100%";
    slide.style.height = "100%";

    // Set transition based on transition type
    if (this.transitionType === "fade") {
      slide.style.transition = `opacity ${this.transitionDuration}ms ease-in-out`;
    } else {
      slide.style.transition = `transform ${this.transitionDuration}ms ease-in-out`;
    }

    // Add styles for carousel images
    const imageWrapper = slide.querySelector(".pc-carousel__image-wrapper");
    if (imageWrapper) {
      imageWrapper.style.width = "100%";
      imageWrapper.style.height = "100%";
      imageWrapper.style.position = "absolute";
      imageWrapper.style.top = "0";
      imageWrapper.style.left = "0";
      imageWrapper.style.zIndex = "0";

      const image = imageWrapper.querySelector(".pc-carousel__image");
      if (image) {
        image.style.width = "100%";
        image.style.height = "100%";
        image.style.objectFit = "cover";
      }
    }

    // Style carousel links
    const link = slide.querySelector(".pc-carousel__link");
    if (link) {
      link.style.display = "block";
      link.style.width = "100%";
      link.style.height = "100%";
      link.style.position = "absolute";
      link.style.top = "0";
      link.style.left = "0";
      link.style.zIndex = "20";
      link.style.cursor = "pointer";
    }

    // Handle active/inactive state
    if (index === this.activeIndex) {
      slide.classList.add("pc-carousel__slide--active");
      slide.style.opacity = "1";
      slide.style.zIndex = "10";
      // Only set transform for slide transition
      if (this.transitionType === "slide") {
        slide.style.transform = "translateX(0)";
      }
    } else {
      slide.classList.add("pc-carousel__slide--inactive");
      slide.style.opacity = "0";
      slide.style.zIndex = "1";
      if (this.transitionType === "slide") {
        // Position inactive slides off-screen
        const direction = index < this.activeIndex ? -1 : 1;
        slide.style.transform = `translateX(${direction * 100}%)`;
      }
    }
  },

  setupNavigation() {
    const prevButton = this.el.querySelector(`#${this.id}-carousel-prev`);
    const nextButton = this.el.querySelector(`#${this.id}-carousel-next`);

    if (prevButton) {
      prevButton.addEventListener("click", () => {
        this.prevSlide();
      });
    }

    if (nextButton) {
      nextButton.addEventListener("click", () => {
        this.nextSlide();
      });
    }
  },

  setupIndicators() {
    const indicators = this.el.querySelectorAll(".pc-carousel__indicator");
    indicators.forEach((indicator, index) => {
      indicator.addEventListener("click", () => {
        this.goToSlide(index);
      });
      if (index === this.activeIndex) {
        indicator.classList.add("opacity-100");
      }
    });
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
    if (this.isTransitioning) return;
    const newIndex =
      (this.activeIndex - 1 + this.slides.length) % this.slides.length;
    this.goToSlide(newIndex, -1);
  },

  nextSlide() {
    if (this.isTransitioning) return;
    const newIndex = (this.activeIndex + 1) % this.slides.length;
    this.goToSlide(newIndex, 1);
  },

  goToSlide(newIndex, direction) {
    if (newIndex === this.activeIndex || this.isTransitioning) return;

    this.isTransitioning = true;
    const currentSlide = this.slides[this.activeIndex];
    const nextSlide = this.slides[newIndex];

    // Update classes
    currentSlide.classList.remove("pc-carousel__slide--active");
    currentSlide.classList.add("pc-carousel__slide--inactive");
    nextSlide.classList.remove("pc-carousel__slide--inactive");
    nextSlide.classList.add("pc-carousel__slide--active");

    if (this.transitionType === "fade") {
      // Fade transition
      currentSlide.style.zIndex = "5"; // Lower than next but still visible
      nextSlide.style.zIndex = "10"; // On top of current
      currentSlide.style.opacity = "1";
      nextSlide.style.opacity = "0";
      void nextSlide.offsetWidth;
      nextSlide.style.opacity = "1";
    } else if (this.transitionType === "slide") {
      // Slide transition
      if (!direction) {
        direction = newIndex > this.activeIndex ? 1 : -1;
      }

      // Make sure opacity is set to 1 for both slides during slide transitions
      currentSlide.style.zIndex = "5";
      nextSlide.style.zIndex = "10";
      currentSlide.style.opacity = "1";
      nextSlide.style.opacity = "1";

      // Position next slide off-screen (without transition)
      nextSlide.style.transition = "none";
      nextSlide.style.transform = `translateX(${direction * 100}%)`;

      // Force browser to recognize the position before animation
      void nextSlide.offsetWidth;

      // Re-enable transition on next slide
      nextSlide.style.transition = `transform ${this.transitionDuration}ms ease-in-out`;

      // Move both slides
      currentSlide.style.transform = `translateX(${-direction * 100}%)`;
      nextSlide.style.transform = "translateX(0)";
    }

    // Update classes (but don't change visibility yet - that happens after transition)
    currentSlide.classList.remove("pc-carousel__slide--active");
    currentSlide.classList.add("pc-carousel__slide--inactive");
    nextSlide.classList.remove("pc-carousel__slide--inactive");
    nextSlide.classList.add("pc-carousel__slide--active");

    // Update indicators
    const indicators = this.el.querySelectorAll(".pc-carousel__indicator");
    indicators.forEach((indicator, index) => {
      if (index === newIndex) {
        indicator.classList.add("opacity-100");
      } else {
        indicator.classList.remove("opacity-100");
      }
    });

    // After transition completes
    setTimeout(() => {
      this.activeIndex = newIndex;

      // Reset positions for non-active slides
      this.slides.forEach((slide, index) => {
        if (index !== this.activeIndex) {
          // Hide and reset all inactive slides
          slide.style.opacity = "0";
          slide.style.zIndex = "1";

          if (this.transitionType === "slide") {
            // Reset position without animation
            // const direction = index < this.activeIndex ? -1 : 1;
            slide.style.transition = "none";
            slide.style.transform = `translateX(${direction * 100}%)`;
            // Force reflow to apply immediate change
            void slide.offsetWidth;
            // Restore transition
            slide.style.transition = `transform ${this.transitionDuration}ms ease-in-out`;
          }
        } else {
          // Ensure active slide stays visible
          slide.style.zIndex = "10";
        }
      });

      if (this.autoplay) {
        this.stopAutoplay();
        this.startAutoplay();
      }

      this.isTransitioning = false;
    }, this.transitionDuration);
  },
};

export default CarouselHook;
