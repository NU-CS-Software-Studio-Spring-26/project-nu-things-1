// Import and register controllers when they appear on the page (avoids loading unused/broken controllers globally).
import { application } from "controllers/application"
import { lazyLoadControllersFrom } from "@hotwired/stimulus-loading"

lazyLoadControllersFrom("controllers", application)
