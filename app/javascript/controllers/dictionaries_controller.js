import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "textareaTop" ]

  goTo(event) {
    const dictionaryLink = event.currentTarget;
    const query = this.textareaTopTarget.value;
    const dictionary = dictionaryLink.getAttribute("data-dictionary")
    let url = "";

    switch (dictionary) {
      case "WordReference":
        url = "https://www.wordreference.com/enfr/" + query;
        break;
      case "Linguee":
        url = "https://www.linguee.com/english-french/search?query=" + query;
        break;
      case "Deepl":
        url = "https://www.deepl.com/translator#en/fr/" + query;
        break;
    }

    window.open(url);
  }
}
