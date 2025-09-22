require 'rails_helper'

RSpec.describe TranscriptionsController, type: :controller do
  describe 'POST #create' do
    let(:audio_data) { "fake-audio-data" }

    before do
      allow_any_instance_of(TranscriptionService).to receive(:transcribe_audio)
                                                         .and_return({ success: true, text: "Hello world", full_content: "Hello world", transcription_id: 1 })
    end

    it 'creates transcription with audio file' do
      post :create, params: {
          audio_file: fixture_file_upload('spec/fixtures/test_audio.wav', 'audio/wav')
      }, format: :json

      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['success']).to be true
      expect(json_response['text']).to eq('Hello world')
    end

    it 'handles base64 audio data' do
      encoded_data = Base64.encode64(audio_data)

      post :create, params: { audio_data: encoded_data }, format: :json

      expect(response).to have_http_status(:success)
    end

    it 'returns error when no audio data provided' do
      post :create, params: {}, format: :json

      expect(response).to have_http_status(:bad_request)
      json_response = JSON.parse(response.body)
      expect(json_response['error']).to eq('No audio data provided')
    end
  end

  describe 'GET #summary' do
    let(:transcription) { create(:transcription, content: 'Test content') }

    it 'returns existing summary' do
      transcription.update!(summary: 'Test summary')

      get :summary, params: { id: transcription.id }, format: :json

      expect(response).to have_http_status(:success)
      json_response = JSON.parse(response.body)
      expect(json_response['summary']).to eq('Test summary')
    end

    it 'generates new summary when none exists' do
      allow_any_instance_of(Transcription).to receive(:generate_summary!)
                                                  .and_return(true)
      allow(transcription).to receive(:summary).and_return('Generated summary')

      get :summary, params: { id: transcription.id }, format: :json

      expect(response).to have_http_status(:success)
    end
  end
end