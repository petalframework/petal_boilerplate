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
    this.navigationMethod = null;

    // Initialize slides
    this.slides.forEach((slide, index) => {
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
      const imageWrapper = slide.querySelector('.pc-carousel__image-wrapper');
      if (imageWrapper) {
        imageWrapper.style.width = "100%";
        imageWrapper.style.height = "100%";
        imageWrapper.style.position = "absolute";
        imageWrapper.style.top = "0";
        imageWrapper.style.left = "0";
        imageWrapper.style.zIndex = "0";
        
        const image = imageWrapper.querySelector('.pc-carousel__image');
        if (image) {
          image.style.width = "100%";
          image.style.height = "100%";
          image.style.objectFit = "cover";
        }
      }
      
      // Style carousel links
      const link = slide.querySelector('.pc-carousel__link');
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
        slide.style.zIndex = "1";
        // Only set transform for slide transition
        if (this.transitionType === "slide") {
          slide.style.transform = "translateX(0)";
        }
      } else {
        slide.classList.add("pc-carousel__slide--inactive");
        slide.style.opacity = "0";
        slide.style.zIndex = "0";
        if (this.transitionType === "slide") {
          slide.style.transform = "translateX(100%)";
        }
      }
    });

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

  setupNavigation() {
    const prevButton = this.el.querySelector(`#${this.id}-carousel-prev`);
    const nextButton = this.el.querySelector(`#${this.id}-carousel-next`);

    if (prevButton) {
      prevButton.addEventListener("click", () => {
        this.navigationMethod = "prev";
        this.prevSlide();
      });
    }

    if (nextButton) {
      nextButton.addEventListener("click", () => {
        this.navigationMethod = "next";
        this.nextSlide();
      });
    }
  },

  setupIndicators() {
    const indicators = this.el.querySelectorAll(".pc-carousel__indicator");
    indicators.forEach((indicator, index) => {
      indicator.addEventListener("click", () => {
        this.navigationMethod = "indicator";
        this.goToSlide(index);
      });
      if (index === this.activeIndex) {
        indicator.classList.add("opacity-100");
      }
    });
  },

  startAutoplay() {
    this.autoplayTimer = setInterval(() => {
      this.navigationMethod = "next";
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
    this.goToSlide(newIndex);
  },

  nextSlide() {
    if (this.isTransitioning) return;
    const newIndex = (this.activeIndex + 1) % this.slides.length;
    this.goToSlide(newIndex);
  },

  goToSlide(newIndex) {
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
      currentSlide.style.opacity = "0";
      currentSlide.style.zIndex = "0";
      nextSlide.style.opacity = "1";
      nextSlide.style.zIndex = "1";
    } else {
      // Slide transition
      const direction = newIndex > this.activeIndex ? 1 : -1;

      // Make sure opacity is set to 1 for both slides during slide transitions
      currentSlide.style.opacity = "1";
      nextSlide.style.opacity = "1";

      // Layering: current below next
      currentSlide.style.zIndex = "1";
      nextSlide.style.zIndex = "2";

      // Position the next slide off-screen
      nextSlide.style.transform = `translateX(${direction * 100}%)`;

      // Force reflow to apply starting position
      nextSlide.offsetHeight;

      // Animate: current slides out, next slides in
      currentSlide.style.transform = `translateX(${-direction * 100}%)`;
      nextSlide.style.transform = "translateX(0)";
    }

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
          slide.style.opacity = "0";
          slide.style.zIndex = "0";
          if (this.transitionType === "slide") {
            slide.style.transform = "translateX(100%)";
          }
        }
      });

      if (this.autoplay) {
        this.stopAutoplay();
        this.startAutoplay();
      }

      this.isTransitioning = false;
      this.navigationMethod = null;
    }, this.transitionDuration);
  },
};

export default CarouselHook;
