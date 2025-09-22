FactoryBot.define do
  factory :transcription do
    session_id { SecureRandom.uuid }
    content { "This is a test transcription content." }
    status { 'processing' }
  end
end