import { LightningElement, track } from 'lwc';

export default class EkaPayment extends LightningElement {
    @track plandrapdowns = [
        { label: 'Eka Plus', value: 'Eka Plus' },
        { label: 'Eka Pro', value: 'Eka Pro' },
        { label: 'Eka Premium', value: 'Eka Premium' },
        { label: 'Eka Premium Plus', value: 'Eka Premium Plus' },
    ];
    @track drapdowns =[
        { label: 'Digital Presence', value: 'Presence' },
        { label: 'EMR', value: 'EMR' },
        { label: 'Appointment', value: 'Appointment' },
        { label: 'HXNG ', value: 'HXNG' },
        { label: 'HMIS ', value: 'HMIS' },
    ]
}