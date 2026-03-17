import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  connect() {
    this.clearAfterMorph = this.clearInput.bind(this)
    document.addEventListener("turbo:morph", this.clearAfterMorph)
  }

  disconnect() {
    document.removeEventListener("turbo:morph", this.clearAfterMorph)
  }

  clearInput() {
    if (this.hasInputTarget) {
      this.inputTarget.value = ""
      this.inputTarget.focus()
    }
  }
}
