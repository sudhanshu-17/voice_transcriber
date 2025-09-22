# app/services/transcription_service.rb
class TranscriptionService
  include HTTParty

  def initialize
    @api_key = Rails.application.credentials.dig(:deepgram, :api_key) || ENV['DEEPGRAM_API_KEY']
    @base_uri = 'https://api.deepgram.com/v1/listen'
  end

  def transcribe_audio(audio_data, session_id)
    return { error: 'API key not configured' } unless @api_key

    response = HTTParty.post(@base_uri,
                             headers: {
                                 'Authorization' => "Token #{@api_key}",
                                 'Content-Type' => 'audio/wav'
                             },
                             body: audio_data,
                             query: {
                                 'punctuate' => true,
                                 'diarize' => true,
                                 'smart_format' => true
                             }
    )

    if response.success?
      parse_deepgram_response(response.parsed_response, session_id)
    else
      { error: "Transcription failed: #{response.message}" }
    end
  rescue => e
    Rails.logger.error "Transcription error: #{e.message}"
    { error: e.message }
  end

  private

  def parse_deepgram_response(response, session_id)
    transcription = Transcription.find_or_create_by_session(session_id)

    if response.dig('results', 'channels')
      text = response.dig('results', 'channels', 0, 'alternatives', 0, 'transcript')
      transcription.append_content(text) if text.present?

      {
          success: true,
          text: text,
          full_content: transcription.content,
          transcription_id: transcription.id
      }
    else
      { error: 'Invalid response format' }
    end
  end
end