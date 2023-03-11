import { Controller } from "@hotwired/stimulus"
import debounce from 'debounce'

// Connects to data-controller="repositories"
export default class extends Controller {
  initialize() {
    this.submit = debounce(this.submit.bind(this), 500);
  }

  submit(_event) {
    this.element.requestSubmit();
  }
}
