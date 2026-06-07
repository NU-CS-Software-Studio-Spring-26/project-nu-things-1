import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["reason", "otherField", "otherInput"]

  connect() {
    this.toggleOther()
  }

  toggleOther() {
    if (!this.hasOtherFieldTarget) return

    const showOther = this.reasonTargets.some(
      (input) => input.value === "other" && input.checked
    )
    this.otherFieldTarget.classList.toggle("d-none", !showOther)

    if (this.hasOtherInputTarget) {
      this.otherInputTarget.required = showOther
      if (!showOther) this.otherInputTarget.value = ""
    }
  }
}
