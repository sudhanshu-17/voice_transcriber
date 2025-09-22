# Voice Transcription & Summarization Web App

A Ruby on Rails application that provides real-time voice transcription and AI-powered summarization using modern web technologies.

## Features

-  **Real-time Voice Recording**: Browser-based audio capture with visual feedback
-  **Live Transcription**: Word-by-word transcription display while recording
-  **AI Summarization**: Automatic conversation summaries using OpenAI
-  **Speaker Diarization**: Multiple speaker detection (when supported by API)
-  **Copy & Export**: Easy transcription copying and sharing
-  **Responsive Design**: Works on desktop and mobile devices

## Tech Stack

- **Backend**: Ruby on Rails 7.0+
- **Frontend**: Stimulus.js, Turbo, vanilla JavaScript
- **Database**: PostgreSQL
- **Speech-to-Text**: Deepgram API
- **AI Summary**: OpenAI GPT-3.5-turbo
- **Styling**: Custom CSS with modern design patterns

## Prerequisites

- Ruby 3.0+
- Rails 7.0+
- PostgreSQL
- Redis (for future caching/sessions)
- API Keys:
  - [Deepgram](https://deepgram.com/) for speech-to-text
  - [OpenAI](https://openai.com/) for summarization

## Installation

1. **Clone the repository**
```bash
   git clone https://github.com/sudhanshu-17/voice_transcriber.git
   cd voice_transcriber
```
2. **Install dependencies**
```
   bundle install
```
3. **Setup database**
```
   rails db:create db:migrate
```
4. **Configure API credentials**
```
rails credentials:edit
```
Add your API keys:
```
   deepgram:
     api_key: your_deepgram_api_key_here
   
   openai:
     api_key: your_openai_api_key_here
```
5. **Start the development server**
```
   rails server
```   
6. **Visit the application**

   Open http://localhost:3000 in your browser
   
   Usage
   
   Navigate to transcription page: Click "Start Transcribing" on the homepage
   Grant microphone permissions: Click "Start Listening" and allow browser access
   Record your voice: Speak naturally while seeing live transcription
   Stop recording: Click "Stop Listening" when finished
   View results: See full transcription and generate summary
   Copy or share: Use the copy button to export your transcription
   
   API Endpoints
   
   GET /transcribe - Transcription interface
   
   POST /transcriptions - Submit audio data for transcription
   
   GET /transcriptions/:id/summary - Get or generate summary
   
   PATCH /transcriptions/:id/finalize - Finalize transcription session
   
   Environment Variables
   
   For production deployment, you can also use environment variables:
```
export DEEPGRAM_API_KEY="your_deepgram_key"
export OPENAI_API_KEY="your_openai_key"
```

7. **Testing**

Run the test suite:
```
# Run all tests
rspec

# Run specific test types
rspec spec/models/
rspec spec/controllers/
rspec spec/services/
```
   
**Browser Support**

- Chrome 60+ (recommended)
- Firefox 55+
- Safari 11+
- Edge 79+

Note: Microphone access requires HTTPS in production environments.