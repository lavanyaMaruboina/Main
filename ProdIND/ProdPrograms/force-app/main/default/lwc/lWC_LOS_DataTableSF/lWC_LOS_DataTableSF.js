import { LightningElement, api, track } from 'lwc';
import fetchDataMap from '@salesforce/apex/IND_DatatableCntrl.fetchDataMap';
import fetchDataMapCached from '@salesforce/apex/IND_DatatableCntrl.fetchDataMapCached';
export default class LWC_LOS_Datatable extends LightningElement {

    @api config = {};
    @api keycolumn = "Id";
    @track objectName;
    @track tableConfig = {};
    @track sortBy;
    @track sortAsc;
    @track limit;
    @track queryType = "SOQL";
    @track hidePagination = false;
    @track hideTableSpinner = false;
    @track cacheable = false;
    @track height = '10rem'; //height of table

    @track tableProps = {};
    @track recordsListInPage = [];
    @track selectedRowsMap = {};
    @track selectedRowsPagesMap = {};
    @track hideSpinner = false;
    @track userMessage = "Please wait...";
    @track error;
    @api
    get userMessages() {
        if (this.isNotBlank(this._userMessages)) return this._userMessages;
        return {
        };
    }
    set userMessages(value) {
        this._userMessages = value;
    }

    @api
    get pageSize() {
        if (!this.isNotBlank(this._pageSize)) this._pageSize = 10;
        return parseInt(this._pageSize, 10);
    }
    set pageSize(value) {
        this._pageSize = value;
    }

    @api oppId = '006710000018TST';
    @api
    get queryFilters() {
        if (this._queryFilters) return this._queryFilters;
        return "";
    }
    set queryFilters(value) {
        this._queryFilters = value;
        if (this._initDone) {
            this.fetchRecords();
        }
    }
    //  set queryFilters(oppId) {
    //     this._queryFilters = oppId;
    //     if (this._initDone) {
    //         this.fetchRecords();
    //     }
    // }

    @api
    getSelectedRows() {
        return this.selectedRowsMap;
    }

    _recordsListInAllPages = [];
    _startFromIndex = 0;
    _paginationInfo = {
        currentPage: 0,
        totalPages: 0
    };
    
    connectedCallback() {
        this.processConfig();
        this.userMessage = this.userMessages.init; // set initial user message
        this.fetchRecords();
        this._originTagRowSelectionLocal = "LIGHTNING-DATATABLE"; // initialising to the expected source tag
        this._initDone = true;
    }

    renderedCallback(){
        this.fetchRecords();
    }
    
    handleRowAction = event => {
        this.dispatchEvent(new CustomEvent('rowaction', {
            detail: {
                action: event.detail.action,
                row: event.detail.row
            }
        }));
    }
    handleResize = event => this.dispatchEvent(new CustomEvent('resize', { detail: event.detail }))
    handleRowSelection = event => {
        if (this._originTagRowSelectionLocal === "LIGHTNING-DATATABLE") {
            this.selectedRowsMap = {};
            this.selectedRowsPagesMap[this._paginationInfo.currentPage] = event.detail.selectedRows;
            Object.values(this.selectedRowsPagesMap).forEach(rowsList => {
                rowsList.forEach(row => {
                    this.selectedRowsMap[row.Id] = row;
                });
            });

            let detail = {
                selectedRows: Object.values(this.selectedRowsMap),
                selectedRowsMap: this.selectedRowsMap
            };

            this.dispatchEvent(new CustomEvent('rowselection', {
                detail: detail
            }));
        } else {
            this._originTagRowSelectionLocal = event.target.tagName;
        }
    }
    handleSort = event => {
        this.selectedRowsMap = {};
        this.selectedRowsPagesMap = {};

        this.tableProps.sortedBy = event.detail.fieldName;
        this.tableProps.sortedDirection = event.detail.sortDirection;

        this._recordsListInAllPages.sort((a, b) => {
            if (!a[this.tableProps.sortedBy]) return 1;
            if (!b[this.tableProps.sortedBy]) return -1;
            if (this.tableProps.sortedDirection === "asc") {
                if (a[this.tableProps.sortedBy] < b[this.tableProps.sortedBy]) return -1;
                else if (a[this.tableProps.sortedBy] > b[this.tableProps.sortedBy]) return 1;
                if (a.Id < b.Id) return -1;
                return 1;
            }
            if (a[this.tableProps.sortedBy] < b[this.tableProps.sortedBy]) return 1;
            else if (a[this.tableProps.sortedBy] > b[this.tableProps.sortedBy]) return -1;
            if (a.Id > b.Id) return -1;
            return 1;
        });

        this._startFromIndex = 0;
        this.processRecordsListPagination();
    }

    processConfig() {
        if (this.config.hasOwnProperty("object-name") || this.config.hasOwnProperty("objectName"))
            this.objectName = this.config["object-name"] || this.config.objectName;
        if (this.config.hasOwnProperty("sort-by") || this.config.hasOwnProperty("sortBy"))
            this.sortBy = this.config["sort-by"] || this.config.sortBy;
        if (this.config.hasOwnProperty("sort-asc") || this.config.hasOwnProperty("sortAsc"))
            this.sortAsc = this.config["sort-asc"] || this.config.sortAsc;
        if (this.config.hasOwnProperty("limit"))
            this.limit = this.config.limit;
        if (this.config.hasOwnProperty("cacheable"))
            this.cacheable = this.config.cacheable;
        if (this.config.hasOwnProperty("height"))
            this.height = this.config.height;

        if (this.config.hasOwnProperty("query-type") || this.config.hasOwnProperty("queryType"))
            this.queryType = this.config["query-type"] || this.config.queryType;

        if (this.config.hasOwnProperty("hide-pagination") || this.config.hasOwnProperty("hidePagination"))
            this.hidePagination = this.config["hide-pagination"] || this.config.hidePagination;

        if (this.config.hasOwnProperty("hide-table-spinner") || this.config.hasOwnProperty("hideTableSpinner"))
            this.hideTableSpinner = this.config["hide-table-spinner"] || this.config.hideTableSpinner;

        if (this.config.hasOwnProperty("user-messages") || this.config.hasOwnProperty("userMessages"))
            this.userMessages = this.config["user-messages"] || this.config.userMessages;

        if (this.config.hasOwnProperty("page-size") || this.config.hasOwnProperty("pageSize"))
            this.pageSize = this.config["page-size"] || this.config.pageSize;

        if (this.config.hasOwnProperty("query-filters") || this.config.hasOwnProperty("queryFilters")) {
            this.queryFilters = this.config["query-filters"] || this.config.queryFilters;
            console.log('queryFilters..'+this.queryFilters);
        }

        if (this.config.hasOwnProperty("sosl-search-term") || this.config.hasOwnProperty("soslSearchTerm"))
            this.soslSearchTerm = this.config["sosl-search-term"] || this.config.soslSearchTerm;

        if (this.config.hasOwnProperty("table-config") || this.config.hasOwnProperty("tableConfig")) {
            this.tableConfig = this.config["table-config"] || this.config.tableConfig;
            this.processTableConfig();
            this.fields = this.tableProps.columns.filter(col => col.hasOwnProperty("api")).map(col => col.api).join();
        }
    }

    processTableConfig() {
        this.tableProps.columns = this.tableConfig.columns;
        this.tableProps.sortedBy = "";
        this.tableProps.sortedDirection = "";
        if (this.tableConfig.hasOwnProperty("hideCheckboxColumn") || this.tableConfig.hasOwnProperty("hide-checkbox-column"))
            this.tableProps.hideCheckboxColumn = this.tableConfig.hideCheckboxColumn || this.tableConfig["hide-checkbox-column"];
        else this.tableProps.hideCheckboxColumn = false;
        if (this.tableConfig.hasOwnProperty("showRowNumberColumn") || this.tableConfig.hasOwnProperty("show-row-number-column"))
            this.tableProps.showRowNumberColumn = this.tableConfig.showRowNumberColumn || this.tableConfig["show-row-number-column"];
        else this.tableProps.showRowNumberColumn = false;
        if (this.tableConfig.hasOwnProperty("rowNumberOffset") || this.tableConfig.hasOwnProperty("row-number-offset"))
            this.tableProps.rowNumberOffset = this.tableConfig.rowNumberOffset || this.tableConfig["row-number-offset"];
        else this.tableProps.rowNumberOffset = 0;
        if (this.tableConfig.hasOwnProperty("resizeColumnDisabled") || this.tableConfig.hasOwnProperty("resize-column-disabled"))
            this.tableProps.resizeColumnDisabled = this.tableConfig.resizeColumnDisabled || this.tableConfig["resize-column-disabled"];
        else this.tableProps.resizeColumnDisabled = false;
        if (this.tableConfig.hasOwnProperty("minColumnWidth") || this.tableConfig.hasOwnProperty("min-column-width"))
            this.tableProps.minColumnWidth = this.tableConfig.minColumnWidth || this.tableConfig["min-column-width"];
        else this.tableProps.minColumnWidth = "50px";
        if (this.tableConfig.hasOwnProperty("maxColumnWidth") || this.tableConfig.hasOwnProperty("max-column-width"))
            this.tableProps.maxColumnWidth = this.tableConfig.maxColumnWidth || this.tableConfig["max-column-width"];
        else this.tableProps.maxColumnWidth = "1000px";
        if (this.tableConfig.hasOwnProperty("resizeStep") || this.tableConfig.hasOwnProperty("resize-step"))
            this.tableProps.resizeStep = this.tableConfig.resizeStep || this.tableConfig["resize-step"];
        else this.tableProps.resizeStep = "10px";
        if (this.tableConfig.hasOwnProperty("defaultSortDirection") || this.tableConfig.hasOwnProperty("default-sort-direction"))
            this.tableProps.defaultSortDirection = this.tableConfig.defaultSortDirection || this.tableConfig["default-sort-direction"];
        else this.tableProps.defaultSortDirection = "asc";
        if (this.tableConfig.hasOwnProperty("enableInfiniteLoading") || this.tableConfig.hasOwnProperty("enable-infinite-loading"))
            this.tableProps.enableInfiniteLoading = this.tableConfig.enableInfiniteLoading || this.tableConfig["enable-infinite-loading"];
        else this.tableProps.enableInfiniteLoading = false;
        if (this.tableConfig.hasOwnProperty("loadMoreOffset") || this.tableConfig.hasOwnProperty("load-more-offset"))
            this.tableProps.loadMoreOffset = this.tableConfig.loadMoreOffset || this.tableConfig["load-more-offset"];
        else this.tableProps.loadMoreOffset = false;
        if (this.tableConfig.hasOwnProperty("isLoading") || this.tableConfig.hasOwnProperty("is-loading"))
            this.tableProps.isLoading = this.tableConfig.isLoading || this.tableConfig["is-loading"];
        else this.tableProps.isLoading = false;
        if (this.tableConfig.hasOwnProperty("maxRowSelection") || this.tableConfig.hasOwnProperty("max-row-selection"))
            this.tableProps.maxRowSelection = this.tableConfig.maxRowSelection || this.tableConfig["max-row-selection"];
        else this.tableProps.maxRowSelection = 1000;
        if (this.tableConfig.hasOwnProperty("selectedRows") || this.tableConfig.hasOwnProperty("selected-rows"))
            this.tableProps.selectedRows = this.tableConfig.selectedRows || this.tableConfig["selected-rows"];
        else this.tableProps.selectedRows = [];
        if (this.tableConfig.hasOwnProperty("errors"))
            this.tableProps.errors = this.tableConfig.errors;
        else this.tableProps.errors = null;
        if (this.tableConfig.hasOwnProperty("draftValues") || this.tableConfig.hasOwnProperty("draft-values"))
            this.tableProps.draftValues = this.tableConfig.draftValues || this.tableConfig["draft-values"];
        else this.tableProps.draftValues = null;
        if (this.tableConfig.hasOwnProperty("hideTableHeader") || this.tableConfig.hasOwnProperty("hide-table-header"))
            this.tableProps.hideTableHeader = this.tableConfig.hideTableHeader || this.tableConfig["hide-table-header"];
        else this.tableProps.hideTableHeader = false;
        if (this.tableConfig.hasOwnProperty("suppressBottomBar") || this.tableConfig.hasOwnProperty("suppress-bottom-bar"))
            this.tableProps.suppressBottomBar = this.tableConfig.suppressBottomBar || this.tableConfig["suppress-bottom-bar"];
        else this.tableProps.suppressBottomBar = false;
    }

    // retrieve the records form database
    @api
    fetchRecords() {
        return new Promise((resolve, reject) => {
            // this.handleSpinner(true, this.userMessages.search);

            const params = {
                objectName: this.objectName,
                fields: this.fields,
                sortBy: this.sortBy,
                sortAsc: this.sortAsc,
                queryFilters: this.queryFilters,
                limitRecords: this.limit,
                queryType: this.queryType,
                soslSearchTerm: this.soslSearchTerm
            };

            if (this.cacheable) {
                fetchDataMapCached({ params })
                    .then(DataMap => resolve(this.getResolve(DataMap.records)))
                    .catch(error => reject(this.getReject(error)));
            } else {                
                fetchDataMap({ params })
                    .then(DataMap => resolve(this.getResolve(DataMap.records)))
                    .catch(error => reject(this.getReject(error)));
            }
        });
    }

    // invoked on success
    getResolve(records) {
        this.error = undefined;
        this.processRecordsResult(records);
        return "SUCCESS";
    }

    // invoked on error
    getReject(error) {
        this.handleSpinner(false, "");
        if (error.body && error.body.message) this.handleError(error.body.message);
        else this.handleError(error);
        // this._recordsListInAllPages = undefined;
        return "ERROR";
    }

    // process the records returned from database
    processRecordsResult(recordsListResult) {
        this.handleSpinner(false, "");

        if (recordsListResult && recordsListResult.length > 0) {
            this._recordsListInAllPages = recordsListResult;
            this._paginationInfo.totalPages = (((this._recordsListInAllPages.length / this.pageSize) - ((this._recordsListInAllPages.length % this.pageSize) / this.pageSize)) + (((this._recordsListInAllPages.length % this.pageSize) === 0) ? 0 : 1));
            this.processRecordsListPagination();
        } else {
            this.handleSpinner(false, this.userMessages.noRecords);
            this.recordsListInPage = [];
            this._recordsListInAllPages = [];
            this._startFromIndex = 0;
            this._paginationInfo = {
                currentPage: 0,
                totalPages: 0
            };

        }
    }

    // paginate the records
    processRecordsListPagination(lastSetOfRecords = null, lastNumberOfRecords = null) {
        if (lastSetOfRecords) {
            this.recordsListInPage = this._recordsListInAllPages.slice(lastNumberOfRecords);
        } else {
            this.recordsListInPage = this._recordsListInAllPages.slice(this._startFromIndex, this.pageSize + this._startFromIndex);
        }

        this.processTableRows();
    }

    // process each row to get direct and relationship fields
    processTableRows() {
        this.tableProps.selectedRows = [];
        this.recordsListInPage = this.recordsListInPage.map(thisRow => {
            let currentRow = Object.assign({}, thisRow);
            if (this.selectedRowsMap.hasOwnProperty(currentRow.Id))
                this.tableProps.selectedRows.push(currentRow.Id);
            this.tableProps.columns.forEach(col => {
                if (col.hasOwnProperty("api"))
                    currentRow[col.fieldName] = this.getFieldValueFromObject(currentRow, col.api);
            });
            return currentRow;
        });
    }

    isNotBlank(checkString) {
        return (checkString !== '' && checkString !== null && checkString !== undefined);
    }

    //GET THE FIELD VALUE IN GIVEN OBJECT
    getFieldValueFromObject(thisObject, fieldRelation) {
        let fieldRelationArray = fieldRelation.split(".");
        let objectFieldValue = thisObject;
        for (let f in fieldRelationArray) {
            if (objectFieldValue) {
                objectFieldValue = objectFieldValue[fieldRelationArray[f].trim()];
            }
        }
        return objectFieldValue;
    }

    handleSpinner(showSpinner, userMessage) {
        if (!this.hideTableSpinner) {
            this.showSpinner = showSpinner;
            this.tableProps.isLoading = showSpinner;
        }

        this.userMessage = userMessage;

        this.dispatchEvent(new CustomEvent('tableloading', {
            detail: {
                showSpinner: showSpinner,
                userMessage: userMessage
            },
            bubbles: true,
            composed: true
        }));
    }

    //PAGINATION - SHOW PREVIOUS PAGE
    showPreviousPage(event) {
        if (this._startFromIndex > 0) {
            if (this.selectedRowsPagesMap.hasOwnProperty(this._paginationInfo.currentPage) && this.selectedRowsPagesMap[this._paginationInfo.currentPage].length > 0)
                this._originTagRowSelectionLocal = event.target.tagName;
            this._startFromIndex = this._startFromIndex - this.pageSize;
            this.processRecordsListPagination();
        }
    }

    //PAGINATION - SHOW NEXT PAGE
    showNextPage(event) {
        if (this._startFromIndex + this.pageSize < this._recordsListInAllPages.length) {
            if (this.selectedRowsPagesMap.hasOwnProperty(this._paginationInfo.currentPage) && this.selectedRowsPagesMap[this._paginationInfo.currentPage].length > 0)
                this._originTagRowSelectionLocal = event.target.tagName;
            this._startFromIndex = this._startFromIndex + this.pageSize;
            this.processRecordsListPagination();
        }
    }

    showLastPage = () => {
        let result = this._recordsListInAllPages.length % this.pageSize;
        if (this._startFromIndex >= 0) {
            if (result === 0) {
                this._startFromIndex = this._recordsListInAllPages.length - this.pageSize;
                this.processRecordsListPagination();
            } else {
                this._startFromIndex = this._recordsListInAllPages.length - result;
                this.processRecordsListPagination(true, -result);
            }
        }
    }

    //PAGINATION - INVOKED WHEN PAGE SIZE IS CHANGED
    pageSizeChanged = () => {
        this.doTableRefresh();
        this.processRecordsListPagination();
    }

    doTableRefresh = () => {
        this._startFromIndex = 0;
    }

    get showMessage() {
        return this.isNotBlank(this.userMessage) || this.showSpinner;
    }

    get pagesInfo() {
        if (this._recordsListInAllPages.length > 0) {
            this._paginationInfo.currentPage = (((this._startFromIndex + 1) / this.pageSize) - (((this._startFromIndex + 1) % this.pageSize) / this.pageSize) + ((((this._startFromIndex + 1) % this.pageSize) === 0) ? 0 : 1));
            return 'Page ' + this._paginationInfo.currentPage + ' of ' + this._paginationInfo.totalPages;
        }
        return 'Page 0 of 0';
    }

    get recordsInfo() {
        if (this._recordsListInAllPages.length > 0) {
            this._endIndex = this._startFromIndex + this.pageSize;
            return 'Showing ' + (this._startFromIndex + 1) + " to " + ((this._endIndex > this._recordsListInAllPages.length) ? this._recordsListInAllPages.length : this._endIndex) + " of " + this._recordsListInAllPages.length + " records";
        }
        return 'Showing 0 of 0';
    }

    get tableStyle() {
        return `height:${this.height};`;
    }

}