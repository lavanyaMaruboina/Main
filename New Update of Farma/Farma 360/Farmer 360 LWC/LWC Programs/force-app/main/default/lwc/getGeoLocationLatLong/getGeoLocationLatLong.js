import { LightningElement,track } from 'lwc';

export default class GetGeoLocationLatLong extends LightningElement {
    @track latitude;
    @track longitude;
    @track markerVar = [];

    handleGetLocation() {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(
                (position) => {
                    this.latitude = position.coords.latitude;
                    this.longitude = position.coords.longitude;
                    this.markerVar = [
                        {
                            location: {
                                Latitude: this.latitude,
                                Longitude: this.longitude
                            },
                            title: 'Current Location',
                            description: `Lat: ${this.latitude}, Long: ${this.longitude}`
                        }
                    ];
                },
                (error) => {
                    console.error('Error getting location', error);
                    // Handle error accordingly
                }
            );
        } else {
            console.error('Geolocation is not supported by this browser.');
            // Handle error accordingly
        }
    }

}