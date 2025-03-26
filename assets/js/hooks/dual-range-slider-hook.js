const DualRangeSliderHook = {
  mounted() {
    // Get the unique identifier for this slider group
    this.sliderId = this.el.dataset.sliderId;
    this.rangeMin = this.el.dataset.rangeMin;
    this.rangeMax = this.el.dataset.rangeMax;
    this.setupSlider();
  },

  setupSlider() {
    // Get reference to this slider element and its paired slider
    const sliderType = this.el.dataset.sliderType; // "min" or "max"
    const rangeMin = parseInt(this.rangeMin);
    const rangeMax = parseInt(this.rangeMax);
    const isMinSlider = sliderType === "min";

    // Find the paired slider and range element using the same sliderId
    const minSlider = document.querySelector(
      `[data-slider-id="${this.sliderId}"][data-slider-type="min"]`
    );
    const maxSlider = document.querySelector(
      `[data-slider-id="${this.sliderId}"][data-slider-type="max"]`
    );
    const rangeElement = document.querySelector(
      `[data-slider-id="${this.sliderId}"].slider-range`
    );

    if (!minSlider || !maxSlider || !rangeElement) {
      console.error("Could not find all slider elements");
      return;
    }

    // Handle slider updates
    const updateRange = () => {
      const minVal = parseInt(minSlider.value);
      const maxVal = parseInt(maxSlider.value);

      // Ensure min doesn't exceed max
      if (minVal > maxVal) {
        if (isMinSlider) {
          minSlider.value = maxVal;
        } else {
          maxSlider.value = minVal;
        }
      }

      // Update the colored range track
      const leftPosition = Math.round(
        ((minSlider.value - rangeMin) / (rangeMax - rangeMin)) * 100
      );
      const rightPosition = Math.round(
        100 - ((maxSlider.value - rangeMin) / (rangeMax - rangeMin)) * 100
      );

      rangeElement.style.left = leftPosition + "%";
      rangeElement.style.right = rightPosition + "%";

      // Push values to LiveView with the sliderId to identify which slider was updated
      this.pushEvent("range_updated", {
        id: this.sliderId,
        min: parseInt(minSlider.value),
        max: parseInt(maxSlider.value),
      });
    };

    // Add event listener to this specific slider only
    this.el.addEventListener("input", updateRange);

    // Initial setup when mounted
    if (isMinSlider) {
      updateRange();
    }
  },
};

export default DualRangeSliderHook;
