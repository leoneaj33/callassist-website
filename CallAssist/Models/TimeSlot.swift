import Foundation

struct TimeSlot: Identifiable, Codable, Hashable {
    let id: UUID
    var start: Date
    var end: Date

    init(id: UUID = UUID(), start: Date, end: Date) {
        self.id = id
        self.start = start
        self.end = end
    }

    var displayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE M/d h:mm a"
        return "\(formatter.string(from: start)) – \(endTimeString)"
    }

    var endTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: end)
    }

    var durationMinutes: Int {
        Int(end.timeIntervalSince(start) / 60)
    }

    /// Conversational format for the Vapi AI agent, e.g.
    /// "Tuesday, February 11th from 9:00 AM to 10:00 AM"
    var spokenDescription: String {
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEEE, MMMM d"
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        let daySuffix = ordinalSuffix(for: Calendar.current.component(.day, from: start))
        return "\(dayFormatter.string(from: start))\(daySuffix) from \(timeFormatter.string(from: start)) to \(timeFormatter.string(from: end))"
    }

    private func ordinalSuffix(for day: Int) -> String {
        switch day {
        case 11, 12, 13: return "th"
        default:
            switch day % 10 {
            case 1: return "st"
            case 2: return "nd"
            case 3: return "rd"
            default: return "th"
            }
        }
    }

    /// Builds a numbered list of available times for the Vapi system prompt, e.g.:
    /// "1. Tuesday, February 11th from 9:00 AM to 10:00 AM (1 hour)\n2. ..."
    static func vapiAvailabilityDescription(for slots: [TimeSlot]) -> String {
        if slots.isEmpty { return "No specific times provided." }
        return slots.enumerated().map { index, slot in
            let duration = slot.durationMinutes >= 60
                ? "\(slot.durationMinutes / 60) hour\(slot.durationMinutes / 60 > 1 ? "s" : "")"
                : "\(slot.durationMinutes) minutes"
            return "\(index + 1). \(slot.spokenDescription) (\(duration))"
        }.joined(separator: "\n")
    }
}

extension TimeSlot {
    static let mockSlots: [TimeSlot] = {
        let calendar = Calendar.current
        let now = Date()
        var slots: [TimeSlot] = []

        for dayOffset in 1...5 {
            guard let dayStart = calendar.date(byAdding: .day, value: dayOffset, to: now) else { continue }
            let components = calendar.dateComponents([.year, .month, .day], from: dayStart)

            // Morning slot
            var morningComponents = components
            morningComponents.hour = 9
            morningComponents.minute = 0
            if let start = calendar.date(from: morningComponents),
               let end = calendar.date(byAdding: .hour, value: 1, to: start) {
                slots.append(TimeSlot(start: start, end: end))
            }

            // Afternoon slot
            var afternoonComponents = components
            afternoonComponents.hour = 14
            afternoonComponents.minute = 0
            if let start = calendar.date(from: afternoonComponents),
               let end = calendar.date(byAdding: .hour, value: 1, to: start) {
                slots.append(TimeSlot(start: start, end: end))
            }
        }

        return slots
    }()
}
