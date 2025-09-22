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
   git clone <repository-url>
   cd voice_transcriber