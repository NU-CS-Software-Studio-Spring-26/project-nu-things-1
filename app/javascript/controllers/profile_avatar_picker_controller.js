import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["style", "colorFieldset"]

  connect() {
    this.syncColorFieldset()
  }

  submit() {
    this.element.requestSubmit()
  }

  styleChanged() {
    this.syncColorFieldset()
    this.submit()
  }

  syncColorFieldset() {
    if (!this.hasColorFieldsetTarget) return

    const styleDefault = this.styleTargets.some(
      (input) => input.value === "default" && input.checked
    )
    this.colorFieldsetTarget.classList.toggle("opacity-50", styleDefault)
    this.colorFieldsetTarget.querySelectorAll("input[type=radio]").forEach((input) => {
      input.disabled = styleDefault
    })
  }
}
