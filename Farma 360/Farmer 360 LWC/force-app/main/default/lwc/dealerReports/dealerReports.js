import { LightningElement, api } from 'lwc';
import chartjs from '@salesforce/resourceUrl/ChartJS';
import chartjsPluginDatalabels from '@salesforce/resourceUrl/chartjsPluginDatalabels';
import { loadScript } from 'lightning/platformResourceLoader';
import fetchReportsData from '@salesforce/apex/updateLandDetails.fetchdealerOrderReportsData';

export default class DealerReports extends LightningElement {
    chart;
    chartjsInitialized = false;
    selectedContactId = '001QH00000jnT2BYAU';

    connectedCallback() {
        if (this.chartjsInitialized) {
            return;
        }
        this.chartjsInitialized = true;
        Promise.all([ loadScript(this, chartjsPluginDatalabels), loadScript(this, chartjs)])
            .then(() => {
                const ctx = this.template.querySelector('canvas.donut').getContext('2d');

                // Define the custom plugin for the doughnut label
                const doughnutLabelPlugin = {
                    id: 'doughnutLabel',
                    beforeDatasetsDraw: (chart, args, pluginOption) => {
                        const { ctx, chartArea, config } = chart;
                        var text = '';
            
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
                      },
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
        fetchReportsData({ AccountId: this.selectedContactId })
            .then((data) => {
                this.updateChart(data);
            })
            .catch((error) => {
                console.error(error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error retrieving data',
                        message: error.body.message,
                        variant: 'error',
                    })
                );
            });
    }

    updateChart(data) {
        if (this.chart && this.chart.data) {
            const labelWithCount = data.map((item) => `${item.label} (${item.count})`);
            const countValues = data.map((item) => item.count);
    
            this.chart.data.labels = labelWithCount;
            this.chart.data.datasets.forEach((dataset) => {
                dataset.data = countValues;
            });
            
            // Calculate the sum of all counts
            const totalCount = countValues.reduce((acc, count) => acc + count, 0);
    
            // Use the totalCount variable as needed
            console.log('Total Count:', totalCount);
            // Example of assigning totalCount to a property or using it elsewhere
            this.totalCount = totalCount;
    
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
                        const total = dataset.data.reduce((accumulator, currentValue) => accumulator + currentValue);
                        const currentValue = dataset.data[tooltipItem.index];
                        const percentage = Math.floor((currentValue / total) * 100 + 0.5);
                        return `${data.labels[tooltipItem.index]}: ${currentValue} (${percentage}%)`;
                    },
                },
            },
            plugins: {
                datalabels: {
                    display: true,
                    align: 'center',
                    anchor: 'center',
                    formatter: (value, context) => {
                        const dataset = context.dataset.data;
                        const total = dataset.reduce((accumulator, currentValue) => accumulator + currentValue);
                        const percentage = Math.floor((value / total) * 100 + 0.5);
                        return `${value} (${percentage}%)`;
                    },
                    color: '#727272', // Set the text color
                },
            },
        },
    };
}