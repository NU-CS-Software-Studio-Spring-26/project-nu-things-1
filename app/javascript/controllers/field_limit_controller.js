import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["field", "count"]
  static values = { maxWords: Number, maxChars: Number }

  connect() {
    this.update()
  }

  update() {
    const val = this.fieldTarget.value

    if (this.hasMaxWordsValue && this.maxWordsValue > 0) {
      const n = val.trim() === "" ? 0 : val.trim().split(/\s+/).length
      const max = this.maxWordsValue
      const remaining = max - n
      let msg
      if (remaining > 0) {
        msg = `${n} of ${max} words · ${remaining} word${remaining === 1 ? "" : "s"} left`
      } else if (remaining === 0) {
        msg = `${n} of ${max} words · at limit`
      } else {
        msg = `${n} of ${max} words · ${-remaining} over limit`
      }
      this.countTarget.textContent = msg
      this.countTarget.classList.toggle("text-danger", remaining < 0)
      this.countTarget.classList.toggle("text-muted", remaining >= 0)
      return
    }

    if (this.hasMaxCharsValue && this.maxCharsValue > 0) {
      const n = val.length
      const max = this.maxCharsValue
      const remaining = max - n
      let msg
      if (remaining > 0) {
        msg = `${n} of ${max} characters · ${remaining} left`
      } else if (remaining === 0) {
        msg = `${n} of ${max} characters · at limit`
      } else {
        msg = `${n} of ${max} characters · ${-remaining} over limit`
      }
      this.countTarget.textContent = msg
      this.countTarget.classList.toggle("text-danger", n > max)
      this.countTarget.classList.toggle("text-muted", n <= max)
    }
  }
}
