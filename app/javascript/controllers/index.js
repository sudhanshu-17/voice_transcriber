// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
import VoiceRecorderController from "./voice_recorder_controller"

eagerLoadControllersFrom("controllers", application)
application.register("voice-recorder", VoiceRecorderController)
