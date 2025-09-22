import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["startButton", "stopButton", "status", "visualizer",
        "liveTranscription", "finalSection", "finalTranscription",
        "summaryButton", "summarySection", "summaryContent"]

    connect() {
        this.mediaRecorder = null
        this.audioChunks = []
        this.sessionId = this.data.get("session-id")
        this.transcriptionId = null
        this.isRecording = false

        console.log("Voice recorder controller connected")
    }

    async startRecording() {
        try {
            const stream = await navigator.mediaDevices.getUserMedia({
                audio: {
                    sampleRate: 16000,
                    channelCount: 1,
                    echoCancellation: true,
                    noiseSuppression: true
                }
            })

            this.mediaRecorder = new MediaRecorder(stream, {
                mimeType: 'audio/webm;codecs=opus'
            })

            this.audioChunks = []
            this.isRecording = true

            this.mediaRecorder.ondataavailable = (event) => {
                if (event.data.size > 0) {
                    this.audioChunks.push(event.data)
                    this.processAudioChunk(event.data)
                }
            }

            this.mediaRecorder.onstop = () => {
                this.finalizeRecording()
            }

            // Record in chunks for real-time processing
            this.mediaRecorder.start(2000) // 2-second chunks

            this.updateUI('recording')
            this.showVisualizer()

        } catch (error) {
            console.error('Error accessing microphone:', error)
            alert('Could not access microphone. Please check permissions.')
        }
    }

    stopRecording() {
        if (this.mediaRecorder && this.isRecording) {
            this.mediaRecorder.stop()
            this.mediaRecorder.stream.getTracks().forEach(track => track.stop())
            this.isRecording = false
            this.updateUI('processing')
            this.hideVisualizer()
        }
    }

    async processAudioChunk(audioBlob) {
        if (!this.isRecording) return

        const formData = new FormData()
        formData.append('audio_file', audioBlob, 'chunk.webm')
        formData.append('session_id', this.sessionId)

        try {
            const response = await fetch('/transcriptions', {
                method: 'POST',
                headers: {
                    'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
                },
                body: formData
            })

            const data = await response.json()

            if (data.success && data.text) {
                this.updateLiveTranscription(data.text, data.full_content)
                this.transcriptionId = data.transcription_id
            }
        } catch (error) {
            console.error('Error processing audio chunk:', error)
        }
    }

    updateLiveTranscription(newText, fullContent) {
        const liveElement = this.liveTranscriptionTarget

        // Show the new text briefly in blue, then add to full content
        if (newText.trim()) {
            const newSpan = document.createElement('span')
            newSpan.className = 'live-text'
            newSpan.textContent = newText + ' '
            liveElement.appendChild(newSpan)

            // Convert to final text after a short delay
            setTimeout(() => {
                newSpan.className = 'final-text'
            }, 1000)
        }

        // Auto-scroll to bottom
        liveElement.scrollTop = liveElement.scrollHeight
    }

    async finalizeRecording() {
        if (!this.transcriptionId) {
            this.updateUI('completed')
            return
        }

        try {
            const response = await fetch(`/transcriptions/${this.transcriptionId}/finalize`, {
                method: 'PATCH',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
                }
            })

            const data = await response.json()

            if (data.transcription) {
                this.showFinalResults(data.transcription)
            }
        } catch (error) {
            console.error('Error finalizing transcription:', error)
        }

        this.updateUI('completed')
    }

    showFinalResults(transcription) {
        this.finalTranscriptionTarget.textContent = transcription.content || "No transcription available."
        this.finalSectionTarget.style.display = 'block'

        if (transcription.summary) {
            this.summaryContentTarget.textContent = transcription.summary
            this.summarySectionTarget.style.display = 'block'
        }
    }

    async generateSummary() {
        if (!this.transcriptionId) return

        this.summaryButtonTarget.disabled = true
        this.summaryButtonTarget.textContent = 'Generating...'

        try {
            const response = await fetch(`/transcriptions/${this.transcriptionId}/summary`)
            const data = await response.json()

            if (data.summary) {
                this.summaryContentTarget.textContent = data.summary
                this.summarySectionTarget.style.display = 'block'
            } else {
                alert('Could not generate summary. Please try again.')
            }
        } catch (error) {
            console.error('Error generating summary:', error)
            alert('Error generating summary. Please try again.')
        } finally {
            this.summaryButtonTarget.disabled = false
            this.summaryButtonTarget.textContent = 'Generate Summary'
        }
    }

    copyTranscription() {
        const text = this.finalTranscriptionTarget.textContent
        navigator.clipboard.writeText(text).then(() => {
            // Temporary feedback
            const originalText = event.target.textContent
            event.target.textContent = '✓ Copied!'
            setTimeout(() => {
                event.target.textContent = originalText
            }, 2000)
        })
    }

    updateUI(state) {
        const statusElement = this.statusTarget

        switch(state) {
            case 'recording':
                this.startButtonTarget.style.display = 'none'
                this.stopButtonTarget.style.display = 'inline-block'
                statusElement.textContent = 'Recording'
                statusElement.className = 'status recording'
                break
            case 'processing':
                this.stopButtonTarget.style.display = 'none'
                statusElement.textContent = 'Processing'
                statusElement.className = 'status processing'
                break
            case 'completed':
                this.startButtonTarget.style.display = 'inline-block'
                this.startButtonTarget.textContent = '🎤 Record Again'
                statusElement.textContent = 'Completed'
                statusElement.className = 'status completed'
                break
        }
    }

    showVisualizer() {
        this.visualizerTarget.style.display = 'block'
    }

    hideVisualizer() {
        this.visualizerTarget.style.display = 'none'
    }
}