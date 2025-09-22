# app/controllers/transcriptions_controller.rb
class TranscriptionsController < ApplicationController
  before_action :set_session_id

  def show
    @transcription = Transcription.find_or_create_by_session(@session_id)
  end

  def create
    service = TranscriptionService.new

    # Handle both file upload and base64 audio data
    audio_data = if params[:audio_file].present?
                   params[:audio_file].read
    elsif params[:audio_data].present?
                   Base64.decode64(params[:audio_data])
    else
                   return render json: { error: "No audio data provided" }, status: 400
    end

    result = service.transcribe_audio(audio_data, @session_id)

    if result[:success]
      render json: {
          success: true,
          text: result[:text],
          full_content: result[:full_content],
          transcription_id: result[:transcription_id]
      }
    else
      render json: { error: result[:error] }, status: 422
    end
  end

  def summary
    transcription = Transcription.find(params[:id])

    if transcription.summary.blank?
      transcription.generate_summary!
    end

    render json: {
        summary: transcription.summary,
        status: transcription.status
    }
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Transcription not found" }, status: 404
  rescue => e
    render json: { error: "Summary generation failed" }, status: 500
  end

  def finalize
    transcription = Transcription.find(params[:id])
    transcription.generate_summary!

    render json: {
        transcription: {
            id: transcription.id,
            content: transcription.content,
            summary: transcription.summary,
            status: transcription.status
        }
    }
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Transcription not found" }, status: 404
  end

  private

  def set_session_id
    @session_id = session[:transcription_session] ||= SecureRandom.uuid
  end
end
