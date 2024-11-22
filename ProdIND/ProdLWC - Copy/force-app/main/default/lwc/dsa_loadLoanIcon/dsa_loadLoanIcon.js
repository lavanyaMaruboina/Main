import { LightningElement } from 'lwc';
import { loadStyle,loadScript } from "lightning/platformResourceLoader";
import DSAStyles from "@salesforce/resourceUrl/DSAStyles";

export default class Dsa_loadLoanIcon extends LightningElement {
    connectedCallback(){
        //loadStyle(this, DSALoanIcon);
        loadStyle(this, DSAStyles);
       // loadScript(this,DSAjavascript);

    }
  
  
}