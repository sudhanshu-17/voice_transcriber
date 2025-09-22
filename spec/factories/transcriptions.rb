FactoryBot.define do
  factory :transcription do
    content { "MyText" }
    summary { "MyText" }
    status { "MyString" }
    session_id { "MyString" }
  end
end
