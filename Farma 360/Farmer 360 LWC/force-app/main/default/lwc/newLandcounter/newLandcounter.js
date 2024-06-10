import { LightningElement ,track} from 'lwc';

export default class NewLandcounter extends LightningElement {

     @track activeFormIndex = 0
    @track showCounter = true;
    @track count = 1; // Default count value
    @track showLandDetailsForm = false;

    // Increment count
    incrementCount() {
        this.count++;
    }

    // Decrement count
    decrementCount() {
        if (this.count > 1) {
            this.count--;
        }
    }

    // Handle count change
    handleCountChange(event) {
        this.count = parseInt(event.target.value);
    }

    // Handle next button click
    handleNext() {
        this.showLandDetailsForm = true;
    }

    // Handle form next button click
   
   handleFormNext() {
    const forms = this.template.querySelectorAll('c-create-land-details-form');
    
    // Hide all forms
    forms.forEach((form, index) => {
        form.showForm = false;
    });

    // Show the next form
    if (this.activeFormIndex < forms.length - 1) {
        this.activeFormIndex++; // Move to next form
        forms[this.activeFormIndex].showForm = true; // Show next form
    } else {
        // Last form reached, handle completion logic here
        // For example, you might want to reset the form or show a confirmation message
    } 
}

get landForms() {
    let forms = [];
    for (let i = 0; i < this.count; i++) {
        forms.push({ key: i, showForm: i === 0 }); // Show only the first form initially
    }
    return forms;
}

    

    // Disable next button if count is not valid
    get disableNext() {
        return this.count < 1;
    }

      


}