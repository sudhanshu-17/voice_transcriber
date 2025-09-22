# spec/services/summary_service_spec.rb
require 'rails_helper'

RSpec.describe SummaryService do
  describe '#call' do
    let(:content) { "This is a test transcription with enough content to summarize properly." }
    let(:service) { SummaryService.new(content) }

    context 'when API key is not configured' do
      before { allow(service).to receive(:instance_variable_get).with(:@api_key).and_return(nil) }

      it 'returns unavailable message' do
        expect(service.call).to eq("Summary unavailable - API key not configured")
      end
    end

    context 'when content is too short' do
      let(:short_content) { "Short" }
      let(:service) { SummaryService.new(short_content) }

      it 'returns too short message' do
        expect(service.call).to eq("Content too short for summary")
      end
    end

    context 'when API call is successful' do
      before do
        allow(service).to receive(:instance_variable_get).with(:@api_key).and_return('test-key')

        stub_request(:post, "https://api.openai.com/v1/chat/completions")
            .to_return(
                status: 200,
                body: {
                    choices: [ {
                                  message: { content: "This is a test summary." }
                              } ]
                }.to_json
            )
      end

      it 'returns the summary from OpenAI' do
        expect(service.call).to eq("This is a test summary.")
      end
    end
  end
end
