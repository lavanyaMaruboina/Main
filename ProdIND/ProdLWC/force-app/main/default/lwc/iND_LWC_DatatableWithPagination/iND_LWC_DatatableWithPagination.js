import { LightningElement, wire, api } from 'lwc';

export default class IND_LWC_DatatableWithPagination extends LightningElement {
    @api columns = [];//holds column info.
    @api tableData = []; //contains all the records.
    @api pageSize = 10; //default value we are assigning
    page = 1; //initialize 1st page
    pageData = []; //data  displayed in the table
    startingRecord = 1; //start record position per page
    endingRecord = 0; //end record position per page
    totalRecountCount = 0; //total record count received from all retrieved records
    totalPages = 0; //total number of page is needed to display all records
    selectedRows = [];

    get isPreviousDisable() {
        return this.page == 1;
    }

    get isNextDisable() {
        return this.page == this.totalPages;
    }

    connectedCallback() {
        //this.tableData = data;
        this.totalRecountCount = this.tableData.length;
        this.totalPages = Math.ceil(this.totalRecountCount / this.pageSize);
        //here we slice the data according page size
        this.pageData = this.tableData.slice(0, this.pageSize);
        this.endingRecord = (this.pageSize > this.totalRecountCount) ? this.totalRecountCount : this.pageSize;
    }

    //press on previous button this method will be called
    previousHandler() {
        if (this.page > 1) {
            this.page = this.page - 1;
            this.displayRecordPerPage(this.page);
        }
    }

    //press on next button this method will be called
    nextHandler() {
        if ((this.page < this.totalPages) && this.page !== this.totalPages) {
            this.page = this.page + 1;
            this.displayRecordPerPage(this.page);
        }
    }

    //this method displays records page by page
    displayRecordPerPage(page) {

        this.startingRecord = ((page - 1) * this.pageSize);
        this.endingRecord = (this.pageSize * page);

        this.endingRecord = (this.endingRecord > this.totalRecountCount)
            ? this.totalRecountCount : this.endingRecord;

        this.pageData = this.tableData.slice(this.startingRecord, this.endingRecord);

        //increment by 1 to display the startingRecord count, 
        //so for 2nd page, it will show "Displaying 6 to 10 of 23 records. Page 2 of 5"
        this.startingRecord = this.startingRecord + 1;
        this.template.querySelector('[data-id="datatable"]').selectedRows = this.selectedRows;
    }

    handleRowSelection(event) {
        let updatedItemsSet = new Set();
        // List of selected tableData we maintain.
        let selectedItemsSet = new Set(this.selectedRows);
        // List of tableData currently loaded for the current view.
        let loadedItemsSet = new Set();

        this.pageData.map((ele) => {
            loadedItemsSet.add(ele.Id);
        });

        if (event.detail.selectedRows) {
            event.detail.selectedRows.map((ele) => {
                updatedItemsSet.add(ele.Id);
            });

            // Add any new tableData to the selectedRows list
            updatedItemsSet.forEach((id) => {
                if (!selectedItemsSet.has(id)) {
                    selectedItemsSet.add(id);
                }
            });
        }

        loadedItemsSet.forEach((id) => {
            if (selectedItemsSet.has(id) && !updatedItemsSet.has(id)) {
                // Remove any tableData that were unselected.
                selectedItemsSet.delete(id);
            }
        });

        this.selectedRows = [...selectedItemsSet];
        console.log('selectedRows==> ' + JSON.stringify(this.selectedRows));
        this.dispatchEvent(new CustomEvent('updateselectedrowvalues', {
            detail: this.selectedRows
        }));
    }
}