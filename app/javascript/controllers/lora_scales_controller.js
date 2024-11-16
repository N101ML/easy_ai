import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "select",
    "scalesPlaceholder",
    "form",
    "loraTestGuidanceScale",
    "renderType",
    "imageGuidanceScale",
    "loraTestLoraScale",
  ];

  connect() {
    this.updateFields();
    // Trigger to remove empty fields from render form submission
    this.formTarget.addEventListener(
      "submit",
      this.removeEmptyFields.bind(this)
    );
    this.updateRenderType();
  }

  // This will check to see if any Lora's are selected and will show an input field for the Lora Scale if they are
  updateFields() {
    // First check if any Lora's are selected
    const selectedLoraIds = Array.from(this.selectTarget.selectedOptions).map(
      (option) => option.value
    );
    // Iterate through each selected Lora to remove the hidden field from selected ones - and add hidden to everything else
    this.scalesPlaceholderTarget
      .querySelectorAll("[data-lora-id]")
      .forEach((element) => {
        if (selectedLoraIds.includes(element.getAttribute("data-lora-id"))) {
          element.classList.remove("hidden");
        } else {
          element.classList.add("hidden");
        }
      });
  }

  // Removes ("") empty strings from Lora Scale fields if not selected
  removeEmptyFields() {
    this.scalesPlaceholderTarget
      .querySelectorAll("input[name^='render[lora_scales]']")
      .forEach((input) => {
        if (input.value === "") {
          input.remove();
        }
      });
  }

  renderTypeLoraTest() {
    this.loraTestGuidanceScaleTarget.classList.remove("hidden");
    this.imageGuidanceScaleTarget.classList.add("hidden");
    this.loraTestLoraScaleTarget.classList.remove("hidden");
  }

  renderTypeImage() {
    this.imageGuidanceScaleTarget.classList.remove("hidden");
    this.loraTestGuidanceScaleTarget.classList.add("hidden");
    this.loraTestLoraScaleTarget.classList.add("hidden");
  }

  updateRenderType() {
    const selectedType = this.renderTypeTarget.value;
    if (selectedType === "Lora Test") {
      this.renderTypeLoraTest();
    } else if (selectedType === "Image") {
      this.renderTypeImage();
    }
  }
}
