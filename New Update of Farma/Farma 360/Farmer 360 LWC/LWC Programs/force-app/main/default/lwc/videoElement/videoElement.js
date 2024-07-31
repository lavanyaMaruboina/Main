import { LightningElement, track } from 'lwc';

export default class VideoElement extends LightningElement {

    @track isRecording = false;
    @track mediaRecorder;
    @track chunks = [];
 
    async startRecording() {
        const videoElement = this.template.querySelector('video');
 
        try {
            const stream = await navigator.mediaDevices.getUserMedia({ video: true });
            videoElement.srcObject = stream;
            this.mediaRecorder = new MediaRecorder(stream);
 
            this.mediaRecorder.ondataavailable = event => {
                this.chunks.push(event.data);
            };
 
            this.mediaRecorder.onstop = () => {
                const blob = new Blob(this.chunks, { type: 'video/webm' });
                const videoUrl = URL.createObjectURL(blob);
                const downloadLink = document.createElement('a');
                downloadLink.href = videoUrl;
                downloadLink.download = 'recording.webm';
                document.body.appendChild(downloadLink);
                downloadLink.click();
            };
 
            this.mediaRecorder.start();
            this.isRecording = true;
        } catch (error) {
            console.error('Error accessing media devices:', error);
        }
    }
 
    stopRecording() {
        this.mediaRecorder.stop();
        this.isRecording = false;
    }
}