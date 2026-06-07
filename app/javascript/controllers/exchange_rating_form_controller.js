import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["reason", "otherField", "otherInput"]

  connect() {
    this.toggleOther()
  }

  toggleOther() {
    if (!this.hasReasonTarget || !this.hasOtherFieldTarget) return

    const showOther = this.reasonTarget.value === "other"
    this.otherFieldTarget.classList.toggle("d-none", !showOther)

    if (this.hasOtherInputTarget) {
      this.otherInputTarget.required = showOther
      if (!showOther) this.otherInputTarget.value = ""
    }
  }
}
