require 'rails_helper'

RSpec.describe Transcription, type: :model do
  describe 'validations' do
    it 'requires session_id' do
      transcription = Transcription.new
      expect(transcription).not_to be_valid
      expect(transcription.errors[:session_id]).to include("can't be blank")
    end

    it 'validates status inclusion' do
      transcription = Transcription.new(session_id: 'test', status: 'invalid')
      expect(transcription).not_to be_valid
    end
  end

  describe '#find_or_create_by_session' do
    it 'creates new transcription for new session' do
      expect {
        Transcription.find_or_create_by_session('new-session')
      }.to change(Transcription, :count).by(1)
    end

    it 'finds existing transcription for existing session' do
      existing = Transcription.create!(session_id: 'existing')
      found = Transcription.find_or_create_by_session('existing')
      expect(found.id).to eq(existing.id)
    end
  end

  describe '#append_content' do
    it 'appends text to existing content' do
      transcription = Transcription.create!(session_id: 'test', content: 'Hello')
      transcription.append_content('World')
      expect(transcription.content).to eq('Hello World')
    end
  end
end