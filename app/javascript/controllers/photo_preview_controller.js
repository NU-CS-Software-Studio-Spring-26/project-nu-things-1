import { Controller } from "@hotwired/stimulus"

// Shows a local preview when the user picks an image file (before form submit).
export default class extends Controller {
  static targets = ["input", "wrap", "image"]

  connect() {
    this.objectUrl = null
  }

  preview() {
    this.revoke()

    const file = this.inputTarget.files && this.inputTarget.files[0]
    if (!file || !file.type.startsWith("image/")) {
      this.wrapTarget.classList.add("d-none")
      this.imageTarget.removeAttribute("src")
      return
    }

    this.objectUrl = URL.createObjectURL(file)
    this.imageTarget.src = this.objectUrl
    this.wrapTarget.classList.remove("d-none")
  }

  disconnect() {
    this.revoke()
  }

  revoke() {
    if (this.objectUrl) {
      URL.revokeObjectURL(this.objectUrl)
      this.objectUrl = null
    }
  }
}
