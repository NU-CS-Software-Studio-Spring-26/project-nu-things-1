import { Controller } from "@hotwired/stimulus"

const STORAGE_KEY = "nu-theme"

export default class extends Controller {
  static targets = ["moonIcon", "sunIcon"]

  connect() {
    this.syncIcons()
  }

  toggle() {
    const root = document.documentElement
    const next = root.getAttribute("data-bs-theme") === "dark" ? "light" : "dark"
    root.setAttribute("data-bs-theme", next)
    try {
      localStorage.setItem(STORAGE_KEY, next)
    } catch (_) {
      /* private mode or quota */
    }
    this.syncIcons()
  }

  syncIcons() {
    const dark = document.documentElement.getAttribute("data-bs-theme") === "dark"
    this.moonIconTarget.classList.toggle("d-none", dark)
    this.sunIconTarget.classList.toggle("d-none", !dark)
    this.element.setAttribute("aria-pressed", dark ? "true" : "false")
    this.element.setAttribute("aria-label", dark ? "Switch to light mode" : "Switch to dark mode")
  }
}
