import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "showAnswerButton", "text1", "text2", "answerButtons" ]

  showAnswer(event) {
    this.text2Target.classList.remove('text-white');
    this.showAnswerButtonTarget.classList.add('d-none');
    this.answerButtonsTarget.classList.remove('d-none');
  }
}
