import Foundation

enum RequestStatus: String, Codable, CaseIterable {
    case draft
    case calling
    case completed
    case failed
    case confirmed
    case cancelled
    case rescheduled

    var displayName: String {
        switch self {
        case .draft: return "Draft"
        case .calling: return "Calling..."
        case .completed: return "Completed"
        case .failed: return "Failed"
        case .confirmed: return "Confirmed"
        case .cancelled: return "Cancelled"
        case .rescheduled: return "Rescheduled"
        }
    }

    var iconName: String {
        switch self {
        case .draft: return "doc.text"
        case .calling: return "phone.arrow.up.right"
        case .completed: return "checkmark.circle"
        case .failed: return "xmark.circle"
        case .confirmed: return "calendar.badge.checkmark"
        case .cancelled: return "calendar.badge.minus"
        case .rescheduled: return "arrow.triangle.2.circlepath"
        }
    }
}

enum CallPurpose: String, Codable {
    case book
    case reschedule
    case cancel

    var displayName: String {
        switch self {
        case .book: return "Book Appointment"
        case .reschedule: return "Reschedule"
        case .cancel: return "Cancel"
        }
    }
}

enum CancellationReason: String, Codable, CaseIterable, Identifiable {
    case scheduleConflict = "Schedule conflict"
    case noLongerNeeded = "No longer needed"
    case foundAlternative = "Found another provider"
    case financialReasons = "Financial reasons"
    case healthReasons = "Health reasons"
    case personalEmergency = "Personal emergency"
    case other = "Other"

    var id: String { rawValue }
}

struct AppointmentRequest: Identifiable, Codable {
    let id: UUID
    var businessName: String
    var phoneNumber: String
    var serviceDescription: String
    var preferredTimes: [TimeSlot]
    var status: RequestStatus
    var callId: String?
    var transcript: String?
    var confirmedTime: Date?
    var createdAt: Date
    var listenInEnabled: Bool
    var userProfileId: UUID?
    var callPurpose: CallPurpose
    var cancellationReason: CancellationReason?
    var originalRequestId: UUID?
    var endedReason: String?

    var wasUnanswered: Bool {
        guard status == .completed || status == .failed else { return false }
        guard let reason = endedReason?.lowercased() else { return false }
        return reason.contains("no-answer") ||
               reason.contains("did-not-answer") ||
               reason.contains("busy") ||
               reason.contains("no answer")
    }

    init(
        id: UUID = UUID(),
        businessName: String = "",
        phoneNumber: String = "",
        serviceDescription: String = "",
        preferredTimes: [TimeSlot] = [],
        status: RequestStatus = .draft,
        callId: String? = nil,
        transcript: String? = nil,
        confirmedTime: Date? = nil,
        createdAt: Date = Date(),
        listenInEnabled: Bool = false,
        userProfileId: UUID? = nil,
        callPurpose: CallPurpose = .book,
        cancellationReason: CancellationReason? = nil,
        originalRequestId: UUID? = nil,
        endedReason: String? = nil
    ) {
        self.id = id
        self.businessName = businessName
        self.phoneNumber = phoneNumber
        self.serviceDescription = serviceDescription
        self.preferredTimes = preferredTimes
        self.status = status
        self.callId = callId
        self.transcript = transcript
        self.confirmedTime = confirmedTime
        self.createdAt = createdAt
        self.listenInEnabled = listenInEnabled
        self.userProfileId = userProfileId
        self.callPurpose = callPurpose
        self.cancellationReason = cancellationReason
        self.originalRequestId = originalRequestId
        self.endedReason = endedReason
    }

    var availableTimesDescription: String {
        preferredTimes.map { $0.displayString }.joined(separator: ", ")
    }
}

extension AppointmentRequest {
    static let mock = AppointmentRequest(
        businessName: "Downtown Dental",
        phoneNumber: "(555) 123-4567",
        serviceDescription: "Teeth cleaning and checkup",
        preferredTimes: TimeSlot.mockSlots,
        status: .completed,
        transcript: "AI: Hi, I'm calling to schedule a teeth cleaning appointment for my client.\nReceptionist: Sure! We have openings on Tuesday at 2 PM and Thursday at 10 AM.\nAI: Tuesday at 2 PM would be perfect. Can we book that?\nReceptionist: Absolutely. What's the patient's name?\nAI: The patient's name is Andrew.\nReceptionist: Great, Andrew is booked for Tuesday at 2 PM for a teeth cleaning. See you then!",
        confirmedTime: Calendar.current.date(byAdding: .day, value: 3, to: Date())
    )

    static let mockHistory: [AppointmentRequest] = [
        AppointmentRequest(
            businessName: "Downtown Dental",
            phoneNumber: "(555) 123-4567",
            serviceDescription: "Teeth cleaning",
            status: .confirmed,
            confirmedTime: Calendar.current.date(byAdding: .day, value: 3, to: Date()),
            createdAt: Calendar.current.date(byAdding: .hour, value: -2, to: Date())!
        ),
        AppointmentRequest(
            businessName: "City Auto Repair",
            phoneNumber: "(555) 987-6543",
            serviceDescription: "Oil change",
            status: .completed,
            createdAt: Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        ),
        AppointmentRequest(
            businessName: "Dr. Smith Family Medicine",
            phoneNumber: "(555) 456-7890",
            serviceDescription: "Annual physical",
            status: .failed,
            createdAt: Calendar.current.date(byAdding: .day, value: -3, to: Date())!
        ),
    ]
}
