import { LightningElement, track } from 'lwc';
import logoResource from '@salesforce/resourceUrl/Logo360';

export default class FarmerHeader extends LightningElement {

     @track logoUrl = logoResource;

        handleLogoClick(){
        this.showSearch = true;
        this.showSearchInventory = false;
        this.contactsSelected = false;
        this.landDetailsSelected = false;
        this.inventorySelected = false;
        this.showContactForm = false
        this.showLandCounter=false;
    }

        handleInventoryClick(){
        this.inventorySelected = true;
        this.showSearchInventory = true;
        this.contactsSelected = false;
        this.landDetailsSelected = false;
        this.showContactForm = false;
        this.showSearch = false;

    }

      toggleMenu() {
    this.isMenuOpen = !this.isMenuOpen;
    const navList = this.template.querySelector('.nav-list');
    const contactItem = this.template.querySelector('.nav-item.contacts');
    const inventoryItem = this.template.querySelector('.nav-item.inventory');
    
    if (this.isMenuOpen) {
        navList.classList.add('show');
        contactItem.classList.add('show');
        inventoryItem.classList.add('show');
    } else {
        navList.classList.remove('show');
        contactItem.classList.remove('show');
        inventoryItem.classList.remove('show');
    }
}

        get contactsClass() {
        return this.contactsSelected ? 'active' : '';
    }

        get landDetailsClass() {
            return this.landDetailsSelected ? 'active' : '';
        }

        get inventoryClass() {
            return this.inventorySelected ? 'active' : '';
        }

}