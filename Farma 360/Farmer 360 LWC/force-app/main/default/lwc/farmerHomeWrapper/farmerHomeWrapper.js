import basePath from '@salesforce/community/basePath';
import logoResource from '@salesforce/resourceUrl/Logo360';
import Icons from '@salesforce/resourceUrl/farmer360';
import getUserDetails from '@salesforce/apex/userController.getUserDetails';
import Id from "@salesforce/user/Id";
import { LightningElement, track, wire } from 'lwc';

export default class FarmerHomeWrapper extends LightningElement {
    @track showHTMLCSSSubMenu = false;
    @track showMoreSubMenu = false;
    @track showJavaScriptSubMenu = false;
  
      homePageUrl = `${basePath}/`;
      @track logoUrl = logoResource;
      @track contactsSelected = false;
      @track landDetailsSelected = false;
      @track inventorySelected = false;
      @track showContactForm = false;
      @track showSearchInventory = false;
      @track showSearch = true;
      @track showLandCounter = false;
      @track isMenuOpen = false;
      _headerElement;
  

      @track userName;
      @track userId = Id; 
  
      @wire(getUserDetails, { userId: '$userId' })
      wiredUser({ error, data }) {
          if (data) {
              this.userName = data.Name; 
          } else if (error) {
              console.error(error);
          }
      }

      handleLogOut() {
        console.log('Logout clicked');
    }

    get logoutLink() {
        const sitePrefix = basePath.replace(/\/s$/i, ""); // site prefix is the site base path without the trailing "/s"
        return sitePrefix + "/secur/logout.jsp";
    }
      
    show = Icons + '/farmer360/KipiIcons/HomePage/show.png';
    hide = Icons + '/farmer360/KipiIcons/HomePage/hide.png';
  
    toggleMobileMenu(event) {
      const evt = event.currentTarget;
      evt.classList.toggle("open");
      const showImage = evt.querySelector('.show');
      const hideImage = evt.querySelector('.hide');
      
      if (evt.classList.contains("open")) {
        showImage.style.display = "none";
        hideImage.style.display = "block";
      } else {
        showImage.style.display = "block";
        hideImage.style.display = "none";
      }
    
      console.log('Clicked >>>>>', evt);
    }

    backToHomePage(){
      location.reload();
    }
    redirectToDealer(){
      window.location.href = '/dealer'; 
      console.log('dealer')
    }

    showSchemePDF() {
      // The URL of the PDF you want to open
      const pdfUrl = 'https://farmer360-dev-ed.develop.my.salesforce.com/sfc/p/QH000002VKqv/a/QH0000003YI5/423YOI3S1cxdSRauZhLrUOjcR2.UthtWu7LYt2App7A';
      // Open the URL in a new tab
      window.open(pdfUrl, '_blank');
  }
    
  
    connectedCallback() {
      window.addEventListener('scroll', this.makeHeaderSticky.bind(this));
    }
    renderedCallback() {
      this._headerElement = this.refs.myHeader;
    }
    makeHeaderSticky() {
      if (window.scrollY > 90) {
        this._headerElement.classList.add('sticky');
      }
      else {
        this._headerElement.classList.remove('sticky');
      }
    }
    disconnectedCallback() {
      window.removeEventListener('scroll', this.makeHeaderSticky.bind(this));
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
  
  
  
      handleNext() {
          this.showContactForm = false;
          this.showLandCounter = true;
          
      }
  
      handleLogoClick(){
          this.showSearch = true;
          this.showSearchInventory = false;
          this.contactsSelected = false;
          this.landDetailsSelected = false;
          this.inventorySelected = false;
          this.showContactForm = false
          this.showLandCounter=false;
      }
  
      handleContactsClick() {
          this.contactsSelected = true;
          this.landDetailsSelected = false;
          this.showContactForm = true;
           this.showSearch = false;
          this.showSearchInventory = false;
      }
  
      handleLandDetailsClick() {
          this.contactsSelected = false;
          this.landDetailsSelected = true;
          this.showContactForm = false;
          this.showSearchInventory = false;
          this.showSearch = false;
      }
  
      handleInventoryClick(){
          this.inventorySelected = true;
          this.showSearchInventory = true;
          this.contactsSelected = false;
          this.landDetailsSelected = false;
          this.showContactForm = false;
          this.showSearch = false;
  
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