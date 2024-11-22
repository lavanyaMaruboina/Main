import { LightningElement, api,track } from "lwc";
import { NavigationMixin } from "lightning/navigation";

export default class FilePreviewCol extends NavigationMixin(LightningElement) {
  showPreview = false;
  @api label = "";
  @api versionId = "";
  @api fileId = "";
  @track isPreview = false;
  height = 32;

  navigateToFile(event) {
    event.preventDefault();
    this.isPreview = true;
  }

  hideModalBox(){
    this.isPreview = false;
  }

}