import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "query", "form" ]
  static values = { delay: { type: Number, default: 300 } }

  connect() {
    this.timeout = null
  }

  disconnect() {
    if (this.timeout) clearTimeout(this.timeout)
  }

  search(event) {
    const length = event.target.value.trim().length

    if (length === 1) return

    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.formTarget.requestSubmit()
    }, this.delayValue)
  }

  clearFilters() {
    if (this.hasQueryTarget) this.queryTarget.value = ""
  }
}
