import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "image", "placeholder" ]

  showPlaceholder() {
    if (this.hasImageTarget) {
      this.imageTarget.classList.add("d-none")
      this.imageTarget.removeAttribute("src")
    }

    if (this.hasPlaceholderTarget) {
      this.placeholderTarget.classList.remove("d-none")
    }
  }
}
