import { LightningElement, api } from 'lwc';
import chartjs from '@salesforce/resourceUrl/ChartJS';
import { loadScript } from 'lightning/platformResourceLoader';
import fetchReportsData from '@salesforce/apex/updateLandDetails.fetchOrderReportsData';
//import fetchContactAmountReportsData from '@salesforce/apex/updateLandDetails.fetchContactAmountReportsData';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'; // Import ShowToastEvent

export default class FarmerOrderReports extends LightningElement {
    chart;
    @api contactId; // Correct usage of @api decorator
    chartjsInitialized = false;

    connectedCallback() {
        if (this.chartjsInitialized) {
            return;
        }
        this.chartjsInitialized = true;
        Promise.all([loadScript(this, chartjs)])
            .then(() => {
                const ctx = this.template.querySelector('canvas.donut').getContext('2d');

                // Define the custom plugin for the doughnut label
                const doughnutLabelPlugin = {
                    id: 'doughnutLabel',
                    beforeDatasetsDraw: (chart, args, pluginOption) => {
                        const { ctx, chartArea } = chart;
                        const text = '';

                        // Calculate the coordinates for the text
                        const textX = chartArea.left + (chartArea.right - chartArea.left) / 2;
                        const textY = chartArea.top + (chartArea.bottom - chartArea.top) / 2;

                        // Configure the text appearance
                        ctx.font = '20px Poppins';
                        ctx.fillStyle = '#727272';
                        ctx.textAlign = 'center';
                        ctx.textBaseline = 'middle';

                        // Draw the text
                        ctx.fillText(text, textX, textY);
                    }
                };

                // Register the custom plugin
                Chart.plugins.register(doughnutLabelPlugin);

                this.chart = new window.Chart(ctx, this.config);
                this.loadChartData();
            })
            .catch((error) => {
                this.handleChartError(error);
            });
    }

    loadChartData() {
        // Fetch order reports data
        fetchReportsData({ contactId: this.contactId }) // Correctly pass the contactId
            .then((orderData) => {
                // Fetch contact amount reports data
                this.updateChart(orderData);
                // fetchContactAmountReportsData({ contactId: this.contactId }) // Correctly pass the contactId
                //     .then((amountData) => {
                //         // Combine both data sets and update the chart
                //         this.updateChart(orderData);
                //     })
                //     .catch((error) => {
                //         console.error(error);
                //         this.dispatchEvent(
                //             new ShowToastEvent({
                //                 title: 'Error retrieving amount data',
                //                 message: error.body.message,
                //                 variant: 'error',
                //             })
                //         );
                //     });
            })
            .catch((error) => {
                console.error(error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error retrieving order data',
                        message: error.body.message,
                        variant: 'error',
                    })
                );
            });
    }

    updateChart(orderData) {
        if (this.chart && this.chart.data) {
            // Process order data
            const orderLabels = orderData.map((item) => `${item.label} (${item.count})`);
            const orderValues = orderData.map((item) => item.count);

            // Process amount data
            // const amountLabel = amountData.map((item) => item.label)[0];
            // const amountValue = amountData.map((item) => item.amount)[0];

            // Update chart labels and data
            this.chart.data.labels = orderLabels;
            this.chart.data.datasets.forEach((dataset) => {
                dataset.data = orderValues;
            });

            // Update chart with the amount data
            // if (amountLabel && amountValue !== undefined) {
            //     this.chart.data.labels.push(amountLabel);
            //     this.chart.data.datasets[0].data.push(amountValue);
            // }

            this.chart.update();

            const legendItems = this.template.querySelectorAll('.legend-item');
            if (legendItems) {
                legendItems.forEach((item) => {
                    const legendIcon = item.querySelector('.legend-icon');
                    if (legendIcon) {
                        legendIcon.classList.add('circular-legend');
                    }
                });
            }
        } else {
            console.log('Chart or chart.data is undefined.');
        }
    }

    config = {
        // Chart configuration options
        type: 'doughnut',
        data: {
            datasets: [
                {
                    data: [],
                    backgroundColor: [
                        'rgb(120,193,243)',
                        'rgb(74,232,201)',
                        'rgb(255,105,105)',
                        'rgb(75, 192, 192)',
                    ],
                    label: 'Dataset 1',
                },
            ],
            labels: [],
        },
        options: {
            responsive: true,
            cutoutPercentage: 60,
            legend: {
                position: 'right',
                labels: {
                    usePointStyle: true,
                },
            },
            animation: {
                animateScale: true,
                animateRotate: true,
            },
            tooltips: {
                enabled: true,
                mode: 'label',
                callbacks: {
                    label: (tooltipItem, data) => {
                        const dataset = data.datasets[tooltipItem.datasetIndex];
                        const total = dataset.data.reduce((accumulator, currentValue) => accumulator + currentValue, 0);
                        const currentValue = dataset.data[tooltipItem.index];
                        const percentage = Math.floor((currentValue / total) * 100 + 0.5);
                        return `${data.labels[tooltipItem.index]}: ${currentValue} (${percentage}%)`;
                    },
                },
            },
        },
    };

    handleChartError(error) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error loading Chart.js',
                message: error.message,
                variant: 'error',
            })
        );
    }
}