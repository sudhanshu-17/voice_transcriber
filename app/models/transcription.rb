# app/models/transcription.rb
class Transcription < ApplicationRecord
  validates :session_id, presence: true
  validates :status, inclusion: { in: %w[processing completed failed] }

  enum status: {
      processing: 'processing',
      completed: 'completed',
      failed: 'failed'
  }

  def self.find_or_create_by_session(session_id)
    find_or_create_by(session_id: session_id) do |transcription|
      transcription.content = ""
      transcription.status = 'processing'
    end
  end

  def append_content(text)
    self.content = [content, text].compact.join(" ").strip
    save!
  end

  def generate_summary!
    return if content.blank?

    self.summary = SummaryService.new(content).call
    self.status = 'completed'
    save!
  rescue => e
    Rails.logger.error "Summary generation failed: #{e.message}"
    self.status = 'failed'
    save!
    raise
  end
end