import basePath from '@salesforce/community/basePath';
import logoResource from '@salesforce/resourceUrl/Logo360';
import Icons from '@salesforce/resourceUrl/farmer360';
import getUserDetails from '@salesforce/apex/userController.getUserDetails';
import createEvent from '@salesforce/apex/userController.createEvent';
import getVisitCounts from '@salesforce/apex/CountOfVisits.getVisitCounts';
import Id from "@salesforce/user/Id";
import { LightningElement, track, wire } from 'lwc';
import LightningAlert from 'lightning/alert';

export default class HomePage360 extends LightningElement {

  todayDate;

  @track farmerPlannedVisits;
  @track farmerExecutedVisits;
  @track dealerPlannedVisits;
  @track dealerExecutedVisits;

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
      @track showCalender = false;
      @track VisitUpdate = false;
      @track visitButton = true;
      @track showDealerVisitForm = false;
      @track showFarmerVisitForm = false;
      @track homePageData = true;
      @track showsite = false;
  
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
    showCalenderButton(){
      this.showCalender = true;
      this.homePageData = false;
    }
    handleBackToHome(){
      this.showCalender = false;
      this.homePageData = true;
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
    openvist(){
      this.showsite = true;
      this.showCalender = false;
    }
    redirectToFarmer(){
      window.location.href = '/farmer'; 
      console.log('farmer')
    }  
    redirectToDealer(){
      window.location.href = '/dealer'; 
      console.log('dealer')
    }   
  
    connectedCallback() {
      window.addEventListener('scroll', this.makeHeaderSticky.bind(this));
      this.setTodayDate();
    }

    setTodayDate() {
      const today = new Date();
      const day = String(today.getDate()).padStart(2, '0');
      const month = String(today.getMonth() + 1).padStart(2, '0'); // Months are 0-based
      const year = today.getFullYear();

      this.todayDate = `${day}-${month}-${year}`;
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
      @track showModal = false;
      pdfUrl = '';
  
      handleInventoryClick2() {
           this.pdfUrl = 'https://farmer360-dev-ed.develop.my.salesforce.com/sfc/p/QH000002VKqv/a/QH0000003eCD/OpUFjMjoH4nMUsd9w3W5JoCtOyWvifozPylM2zRYW88';
          this.showModal = true;
          console.log('I am pdf clicked>>>>>>>>>>'+pdfUrl);
      }
  
      handleCloseModal() {
          this.showModal = false;
          this.pdfUrl = '';
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



    //changed by sudarshan

    @track subject = '';
    @track location = '';
    @track startDateTime;
    @track endDateTime;
    @track farmerName='';

    handleToCalender(){

      this.subject = '';
      this.location = '';
      this.startDateTime = '';
      this.endDateTime = '';
      this.farmerName='';

      console.log('back to calender>>');
      this.showCalender = true;
      this.showsite = false;
    }

    handleInputChange(event) {
        const field = event.target.dataset.id;
        this[field] = event.target.value;
        console.log('this[field]>>',this[field]);
    }

    createEvent() {
      const eventWrapper = {
        whoId: this.userId,
        subject: this.subject,
        location: this.location,
        startDateTime: this.startDateTime,
        endDateTime: this.endDateTime
      };

      console.log('calling the create event');

      createEvent({ eventWrapper: eventWrapper })
          .then(() => {

            console.log('event created successfully>>');
            this.showSuccessAlert('Event created successfully!', 'Success', 'Success');
            this.refreshCalender();
            
          })
          .catch(error => {

            console.log('error in event creating>>',error.message);

            this.showSuccessAlert('Error while creating event!', 'Error', 'Error');
              
          });
  }

  refreshCalender(){
    this.handleToCalender();
    // setTimeout(() => {
    //   this.handleToCalender();
    // }, 2000);    
  }

  showSuccessAlert(message, theme, label) {
    LightningAlert.open({
        message: message,
        theme: theme,
        label: label,
    });
  }
  @wire(getVisitCounts, { userId: '$userId' })
  wiredVisitCounts({ error, data }) {
      if (data) {
        console.log('Data received: ', data);
          this.farmerPlannedVisits = data.farmerPlannedVisits;
          this.farmerExecutedVisits = data.farmerExecutedVisits;
          this.dealerPlannedVisits = data.dealerPlannedVisits;
          this.dealerExecutedVisits = data.dealerExecutedVisits;
      } else if (error) {
        console.log('Data received: ', data);
          this.error = error;
      }
  }
}