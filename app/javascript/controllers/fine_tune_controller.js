import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="fine-tune"
export default class extends Controller {
  static targets = ["fineTunes"];
  static values = { fineTunesToggle: Boolean, default: false };

  connect() {
    console.log("fine-tune controller: connected");
  }

  handleClick(event) {
    event.preventDefault();
    this.toggleFineTunes();
  }

  toggleFineTunes() {
    if (this.fineTunesToggle) {
      this.hideFineTunes();
    } else {
      this.showFineTunes();
    }
  }

  newRender(event) {
    this.fineTunesToggleValue =
      this.fineTunesToggleValue === false ? true : false;
    this.toggleFineTunes();
  }

  showFineTunes() {
    const fineTunesElement = this.fineTunesTarget;
    fineTunesElement.classList.remove("hidden");
    fineTunesElement.classList.add("flex");
    this.fineTunesToggle = true;
  }

  hideFineTunes() {
    const fineTunesElement = this.fineTunesTarget;
    fineTunesElement.classList.add("hidden");
    fineTunesElement.classList.remove("flex");
    this.fineTunesToggle = false;
  }
}
