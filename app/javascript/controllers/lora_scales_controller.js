// import { Controller } from "@hotwired/stimulus";

// export default class extends Controller {
//   static targets = ["select", "scalesPlaceholder"];

//   connect() {
//     this.updateFields();
//   }

//   onRenderTypeChange(event) {
//     const renderType = event.target.value;
//     this.toggleFields(renderType);
//   }

//   toggleFields() {
//     if (renderType === "Lora Test") {
//       this.showLoraTestOptions();
//     } else {
//       this.hideLoraTestOptions();
//     }
//   }

//   showLoraTestOptions() {}

//   hideLoraTestOptions() {}

//   updateFields() {
//     // Clear existing fields
//     this.scalesPlaceholderTarget.innerHTML = "";

//     // Get selected LoRAs
//     const selectedLoras = Array.from(this.selectTarget.selectedOptions);

//     // Add input fields for each selected LoRA
//     selectedLoras.forEach((lora, index) => {
//       // Create label for the scale field
//       const label = document.createElement("label");
//       label.textContent = `Scale for ${lora.textContent}`;
//       label.classList.add("block", "font-medium", "mt-2", "text-white");

//       // Create number input field for scale
//       const input = document.createElement("input");
//       input.type = "number";
//       input.name = `lora_scale[${lora.id}]`;
//       input.step = "0.01";
//       input.classList.add(
//         "block",
//         "shadow",
//         "rounded-md",
//         "border",
//         "border-gray-400",
//         "outline-none",
//         "px-3",
//         "py-2",
//         "mt-2",
//         "w-full"
//       );

//       // Append the label and input to the placeholder div
//       this.scalesPlaceholderTarget.appendChild(label);
//       this.scalesPlaceholderTarget.appendChild(input);
//     });
//   }
// }

import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["select", "scalesPlaceholder"];

  connect() {
    this.updateFields();
  }

  updateFields() {
    const selectedLoraIds = Array.from(this.selectTarget.selectedOptions).map(
      (option) => option.value
    );

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
}
