import Foundation

struct CallMonitor: Codable {
    let listenUrl: String?
    let controlUrl: String?
}

struct CallResult: Codable {
    let id: String
    let status: String
    let transcript: String?
    let summary: String?
    let startedAt: String?
    let endedAt: String?
    let endedReason: String?
    let cost: Double?
    let messages: [CallMessage]?
    let monitor: CallMonitor?

    var isActive: Bool {
        status == "queued" || status == "ringing" || status == "in-progress"
    }

    var isEnded: Bool {
        status == "ended"
    }

    var displayStatus: String {
        switch status {
        case "queued": return "Queued"
        case "ringing": return "Ringing..."
        case "in-progress": return "In Progress"
        case "ended": return "Call Ended"
        default: return status.capitalized
        }
    }

    var durationInMinutes: Double {
        guard let startedAt = startedAt,
              let endedAt = endedAt,
              let start = ISO8601DateFormatter().date(from: startedAt),
              let end = ISO8601DateFormatter().date(from: endedAt) else {
            return 0
        }
        let duration = end.timeIntervalSince(start)
        return duration / 60.0 // Convert seconds to minutes
    }
}

struct CallMessage: Codable, Identifiable {
    var id: String { "\(role)-\(time ?? 0)" }
    let role: String
    let message: String?
    let time: Double?

    var displayRole: String {
        switch role {
        case "assistant": return "AI Assistant"
        case "user": return "Business"
        case "system": return "System"
        default: return role.capitalized
        }
    }
}

struct CreateCallRequest: Codable {
    let assistantId: String
    let phoneNumberId: String
    let customer: CustomerInfo
    let assistantOverrides: AssistantOverrides?

    struct CustomerInfo: Codable {
        let number: String
    }

    struct AssistantOverrides: Codable {
        let variableValues: [String: String]?
        let firstMessage: String?
    }
}

struct CreateCallResponse: Codable {
    let id: String
    let status: String
    let monitor: CallMonitor?
}
