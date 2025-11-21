import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    timeout: Number
  }

  connect() {
    if (this.timeoutValue && this.timeoutValue > 0) {
      this.timer = setTimeout(() => {
        this.close()
      }, this.timeoutValue)
    }
  }

  close() {
    this.element.remove()
  }

  disconnect() {
    clearTimeout(this.timer)
  }
}