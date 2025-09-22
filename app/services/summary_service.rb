# app/services/summary_service.rb
class SummaryService
  include HTTParty
  base_uri 'https://api.openai.com/v1'

  def initialize(content)
    @content = content
    @api_key = Rails.application.credentials.dig(:openai, :api_key) || ENV['OPENAI_API_KEY']
  end

  def call
    return "Summary unavailable - API key not configured" unless @api_key
    return "Content too short for summary" if @content.length < 50

    response = self.class.post('/chat/completions',
                               headers: {
                                   'Authorization' => "Bearer #{@api_key}",
                                   'Content-Type' => 'application/json'
                               },
                               body: {
                                   model: 'gpt-3.5-turbo',
                                   messages: [
                                       {
                                           role: 'system',
                                           content: 'You are a helpful assistant that creates concise summaries of transcribed conversations. Keep summaries to 2-3 sentences and focus on key points.'
                                       },
                                       {
                                           role: 'user',
                                           content: "Please summarize this transcription: #{@content}"
                                       }
                                   ],
                                   max_tokens: 150,
                                   temperature: 0.3
                               }.to_json
    )

    if response.success?
      response.dig('choices', 0, 'message', 'content')&.strip || 'Summary could not be generated'
    else
      Rails.logger.error "OpenAI API error: #{response.body}"
      'Summary generation failed - please try again'
    end
  rescue => e
    Rails.logger.error "Summary service error: #{e.message}"
    'Summary generation failed due to technical error'
  end
end