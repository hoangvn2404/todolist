import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  submitForm(event) {
    if (event.key === "Enter") {
      event.preventDefault()
      event.target.closest("form").requestSubmit()
    }
  }
}