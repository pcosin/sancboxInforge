// contactForm.js
import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createContact from '@salesforce/apex/ContactController.createContact';

export default class ContactForm extends LightningElement {
    @track contact = {
        AccountName: '',
        FirstName: '',
        LastName: '',
        Phone: '',
        Email: ''
    };

    handleInputChange(event) {
        const field = event.target.name;
        this.contact[field] = event.target.value;
    }

    handleSubmit() {
        createContact({ contactData: this.contact })
            .then(() => {
                this.showToast('Success', 'Contact created successfully', 'success');
                this.resetForm();
            })
            .catch(error => {
                this.showToast('Error', error.body.message, 'error');
            });
    }

    resetForm() {
        this.contact = {
            AccountName: '',
            FirstName: '',
            LastName: '',
            Phone: '',
            Email: ''
        };
    }

    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        });
        this.dispatchEvent(event);
    }
}