import { ShowToastEvent } from 'lightning/platformShowToastEvent';

function showToast(title, msg, variant, mode, messageDataArr) {
	const toastEvnt = new ShowToastEvent({
		title: title,
		message: msg,
		variant: variant,
		mode: mode ? mode : variant == 'error' ? 'sticky' : '',
		messageData: messageDataArr
	});
	dispatchEvent(toastEvnt);
}

export default { showToast };