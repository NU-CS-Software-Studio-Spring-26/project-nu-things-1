import { Controller } from "@hotwired/stimulus"
import { Calendar } from "@fullcalendar/core"
import dayGridPlugin from "@fullcalendar/daygrid"
import timeGridPlugin from "@fullcalendar/timegrid"

export default class extends Controller {
  static values = { 
    eventUrl: String,
    minDate: String,
    maxDate: String
  }

  connect() {
    const calendarEl = this.element
    const calendar = new Calendar(calendarEl, {
      plugins: [dayGridPlugin, timeGridPlugin],
      initialView: "dayGridMonth",
      headerToolbar: {
        left: "prev,next today",
        center: "title",
        right: "dayGridMonth,timeGridWeek"
      },
      eventSources: [
        {
          url: this.eventUrlValue,
          method: "GET",
          failure: () => {
            alert("Error loading bookings")
          }
        }
      ],
      validRange: {
        start: this.minDateValue,
        end: this.maxDateValue
      },
      editable: false,
      selectable: true,
      selectConstraint: "businessHours",
      eventConstraint: "businessHours",
      businessHours: {
        daysOfWeek: [0, 1, 2, 3, 4, 5, 6],
        startTime: "00:00",
        endTime: "24:00"
      }
    })

    calendar.render()
  }
}
