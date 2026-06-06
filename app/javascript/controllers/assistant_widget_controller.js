import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "log"]
  static classes = ["open"]

  connect() {
    this.boundOnKeydown = this.onKeydown.bind(this)
  }

  disconnect() {
    document.removeEventListener("keydown", this.boundOnKeydown)
  }

  toggle() {
    if (this.panelTarget.classList.contains("d-none")) {
      this.open()
    } else {
      this.close()
    }
  }

  open() {
    this.panelTarget.classList.remove("d-none")
    this.element.classList.add(this.openClass)
    this.element.querySelector(".nu-assistant-fab")?.setAttribute("aria-expanded", "true")
    document.addEventListener("keydown", this.boundOnKeydown)
    this.scrollToBottom()
    this.panelTarget.querySelector("textarea")?.focus()
  }

  close() {
    this.panelTarget.classList.add("d-none")
    this.element.classList.remove(this.openClass)
    this.element.querySelector(".nu-assistant-fab")?.setAttribute("aria-expanded", "false")
    document.removeEventListener("keydown", this.boundOnKeydown)
  }

  scrollToBottom() {
    if (!this.hasLogTarget) return
    this.logTarget.scrollTop = this.logTarget.scrollHeight
  }

  afterSubmit(event) {
    if (event.detail?.success !== false) {
      const field = this.element.querySelector("textarea[name='message']")
      if (field) field.value = ""
    }
    this.scrollToBottom()
  }

  onKeydown(event) {
    if (event.key === "Escape") this.close()
  }
}
