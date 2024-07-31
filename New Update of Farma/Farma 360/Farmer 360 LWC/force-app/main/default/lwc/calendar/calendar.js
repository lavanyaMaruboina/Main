import { LightningElement, api, wire, track} from 'lwc';
import FullCalendarJS  from '@salesforce/resourceUrl/fullcalendarv3';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import getEvents from '@salesforce/apex/CalendarController.getEvents';

export default class Calendar extends LightningElement {
    @api userId;

    jsInitialised = false;
    @track _events;
    
    

    @api
    get events() {
        return this._events;
    }
    set events(value) {
        this._events=[...value];
    }


    @api
    get eventDataString() {
        return this.events;
    }

    @api
    refreshCalender(){
        console.log('refreshing the calendeer');
        this.setupCalenderJS();
    }
    
    renderedCallback() {
        this.setupCalenderJS();
    }

    setupCalenderJS(){
        
        console.log('1.child component this.events- ',JSON.stringify(this.events));
        
        Promise.all([
        loadScript(this, FullCalendarJS + '/FullCalenderV3/jquery.min.js'),
        loadScript(this, FullCalendarJS + '/FullCalenderV3/moment.min.js'),
        ])
        .then(() => {
            return loadScript(this, FullCalendarJS + '/FullCalenderV3/fullcalendar.min.js');
        })
        .then(() => {
            return loadStyle(this, FullCalendarJS + '/FullCalenderV3/fullcalendar.min.css');
        })
        .then(() => {
        // setTimeout(this.initialiseCalendarJs(), 6000); 
            console.log('2. Scripts loaded');
            getEvents({ userId: this.userId })
            .then(result => {
                let records = result.map(event => {
                    return { Id : event.Id, 
                            title : event.Subject, 
                            start : event.StartDateTime,
                            end : event.EndDateTime,
                            allDay : event.IsAllDayEvent};
                });
                this.events = JSON.parse(JSON.stringify(records)),
                console.log('3. CHILD Data- ',JSON.stringify(this.events));
                this.initialiseCalendarJs();
            })
            .catch(error => {
                // TODO Error handling
                this.events = [];
                console.log(error);
            });
        })
        .catch(error => {
            console.log('Error- ', error);
        })
    }

    
    initialiseCalendarJs() {
        console.log('4. Events in child component -', JSON.stringify(this.events));
        var that=this;
        const ele = this.template.querySelector('div .fullcalendarjs');
        //Use jQuery to instantiate fullcalender JS
        $(ele).fullCalendar({
        header: {
            left: 'prev,next today',
            center: 'title',
            right: 'month,basicWeek,basicDay'
        },
        defaultheader:'basicWeek',
        defaultDate: new Date(),
        navLinks: true, 
        editable: true,
        eventLimit: true,
        events: this.events,
        dragScroll:true,
        droppable:true,
        weekNumbers:true,
        selectable:true,
        //eventClick: this.eventClick,
        eventClick: function (info) {
            console.log('5. Event info- ', info.Id);
            const selectedEvent = new CustomEvent('eventclicked', { detail: info.Id });
            // Dispatches the event.
            that.dispatchEvent(selectedEvent);
            }
           
        });
       
    }
 
}