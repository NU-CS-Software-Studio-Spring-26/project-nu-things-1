import { Controller } from "@hotwired/stimulus"

// Shows a local preview when the user picks an image file (before form submit).
// Also validates file size and type with helpful error messages.
export default class extends Controller {
  static targets = ["input", "wrap", "image"]
  static values = { maxSizeMb: { type: Number, default: 5 } }

  connect() {
    this.objectUrl = null
  }

  preview() {
    this.revoke()
    this.removeErrorAlert()

    const file = this.inputTarget.files && this.inputTarget.files[0]
    if (!file) {
      this.wrapTarget.classList.add("d-none")
      this.imageTarget.removeAttribute("src")
      return
    }

    // Validate file type
    const allowedTypes = ["image/jpeg", "image/png", "image/gif", "image/webp"]
    if (!allowedTypes.includes(file.type)) {
      this.showError("File type not supported. Please use JPEG, PNG, GIF, or WebP.")
      this.inputTarget.value = ""
      this.wrapTarget.classList.add("d-none")
      return
    }

    // Validate file size (5 MB default)
    const maxBytes = this.maxSizeMbValue * 1024 * 1024
    if (file.size > maxBytes) {
      this.showError(`File is too large. Maximum size is ${this.maxSizeMbValue} MB. Your file is ${(file.size / 1024 / 1024).toFixed(2)} MB.`)
      this.inputTarget.value = ""
      this.wrapTarget.classList.add("d-none")
      return
    }

    // Show preview if validation passes
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

  showError(message) {
    // Create and show error alert
    const alert = document.createElement("div")
    alert.className = "alert alert-danger mt-2 photo-upload-error"
    alert.setAttribute("role", "alert")
    alert.innerHTML = `<strong>Error:</strong> ${message}`

    this.element.appendChild(alert)

    // Auto-remove error after 5 seconds
    setTimeout(() => {
      if (alert.parentNode) alert.remove()
    }, 5000)
  }

  removeErrorAlert() {
    const existingAlert = this.element.querySelector(".photo-upload-error")
    if (existingAlert) existingAlert.remove()
  }
}

