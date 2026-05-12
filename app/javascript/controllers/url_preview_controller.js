import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["field", "wrap", "image"]

  connect() {
    this.update()
  }

  update() {
    const url = this.fieldTarget.value.trim()

    if (!url || !this.looksLikeImageUrl(url)) {
      this.wrapTarget.classList.add("d-none")
      this.imageTarget.removeAttribute("src")
      return
    }

    this.imageTarget.src = url
    this.wrapTarget.classList.remove("d-none")
  }

  handleError() {
    this.wrapTarget.classList.add("d-none")
    this.imageTarget.removeAttribute("src")
  }

  looksLikeImageUrl(url) {
    try {
      const u = new URL(url)
      if (!["http:", "https:"].includes(u.protocol)) return false
    } catch {
      return false
    }
    return true
  }
}
