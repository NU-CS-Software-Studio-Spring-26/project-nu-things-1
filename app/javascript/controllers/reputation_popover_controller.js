import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["trigger", "content"]

  connect() {
    if (!this.hasTriggerTarget || !this.hasContentTarget || !window.bootstrap) return

    this.popover = new window.bootstrap.Popover(this.triggerTarget, {
      html: true,
      trigger: "hover focus",
      placement: "top",
      sanitize: false,
      title: "Reputation breakdown",
      content: () => this.contentTarget.innerHTML
    })
  }

  disconnect() {
    this.popover?.dispose()
  }
}
