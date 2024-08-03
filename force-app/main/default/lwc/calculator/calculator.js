import { LightningElement, track } from 'lwc';

export default class PercentageCalculator extends LightningElement {
    @track number = 0;
    @track percentage = '';
    @track result = 0;
    @track resultVisible = false;

    percentageOptions = [
        { label: '10%', value: '0.10' },
        { label: '20%', value: '0.20' },
        { label: '30%', value: '0.30' },
        { label: '40%', value: '0.40' },
        { label: '50%', value: '0.50' }
    ];

    handleNumberChange(event) {
        this.number = event.target.value;
    }

    handlePercentageChange(event) {
        this.percentage = event.detail.value;
    }

    calculatePercentage() {
        if (this.number && this.percentage) {
            this.result = this.number * this.percentage;
            this.resultVisible = true;
        } else {
            this.resultVisible = false;
        }
    }
}
