import Foundation
import EventKit
import SwiftUI

@MainActor
class CalendarService: ObservableObject {
    @Published var isCalendarLinked = false
    @Published var activeProviderType: CalendarProviderType?
    @Published var authorizationError: String?

    private var providers: [CalendarProviderType: CalendarProvider] = [:]
    private let eventStore = EKEventStore()

    var activeProvider: CalendarProvider? {
        guard let type = activeProviderType else { return nil }
        return providers[type]
    }

    init() {
        loadSavedProvider()
    }

    func linkCalendar(provider: CalendarProviderType) async throws {
        let calProvider: CalendarProvider
        switch provider {
        case .apple:
            calProvider = AppleCalendarProvider(eventStore: eventStore)
        case .google:
            calProvider = GoogleCalendarService()
        case .microsoft:
            calProvider = MicrosoftCalendarService()
        }

        let granted = try await calProvider.requestAccess()
        guard granted else {
            throw CalendarError.accessDenied
        }

        providers[provider] = calProvider
        activeProviderType = provider
        isCalendarLinked = true
        saveProvider(provider)
    }

    func unlinkCalendar() {
        activeProviderType = nil
        isCalendarLinked = false
        providers.removeAll()
        UserDefaults.standard.removeObject(forKey: "calendarProvider")
    }

    func fetchFreeSlots(from start: Date, to end: Date, minimumDuration: TimeInterval = 3600) async throws -> [TimeSlot] {
        guard let provider = activeProvider else {
            throw CalendarError.noProviderLinked
        }
        return try await provider.fetchFreeSlots(from: start, to: end, minimumDuration: minimumDuration)
    }

    func addEvent(title: String, startDate: Date, endDate: Date, notes: String? = nil) async throws {
        guard let provider = activeProvider else {
            throw CalendarError.noProviderLinked
        }
        try await provider.addEvent(title: title, startDate: startDate, endDate: endDate, notes: notes)
    }

    private func saveProvider(_ provider: CalendarProviderType) {
        UserDefaults.standard.set(provider.rawValue, forKey: "calendarProvider")
    }

    private func loadSavedProvider() {
        guard let raw = UserDefaults.standard.string(forKey: "calendarProvider"),
              let provider = CalendarProviderType(rawValue: raw) else { return }

        Task {
            do {
                try await linkCalendar(provider: provider)
            } catch {
                authorizationError = error.localizedDescription
            }
        }
    }
}

enum CalendarError: LocalizedError {
    case accessDenied
    case noProviderLinked
    case eventCreationFailed

    var errorDescription: String? {
        switch self {
        case .accessDenied: return "Calendar access was denied. Please enable it in Settings."
        case .noProviderLinked: return "No calendar provider is linked."
        case .eventCreationFailed: return "Failed to create calendar event."
        }
    }
}

// MARK: - Apple Calendar Provider

class AppleCalendarProvider: CalendarProvider {
    let providerType: CalendarProviderType = .apple
    let displayName = "Apple Calendar"
    let eventStore: EKEventStore

    init(eventStore: EKEventStore) {
        self.eventStore = eventStore
    }

    var isAuthorized: Bool {
        EKEventStore.authorizationStatus(for: .event) == .fullAccess
    }

    func requestAccess() async throws -> Bool {
        if #available(iOS 17.0, *) {
            return try await eventStore.requestFullAccessToEvents()
        } else {
            return try await eventStore.requestAccess(to: .event)
        }
    }

    func fetchFreeSlots(from startDate: Date, to endDate: Date, minimumDuration: TimeInterval) async throws -> [TimeSlot] {
        let predicate = eventStore.predicateForEvents(withStart: startDate, end: endDate, calendars: nil)
        let events = eventStore.events(matching: predicate).sorted { $0.startDate < $1.startDate }

        var freeSlots: [TimeSlot] = []
        let calendar = Calendar.current

        // Only consider business hours: 8 AM - 6 PM
        var currentDate = startDate
        while currentDate < endDate {
            let dayComponents = calendar.dateComponents([.year, .month, .day], from: currentDate)

            var businessStart = dayComponents
            businessStart.hour = 8
            businessStart.minute = 0
            guard let dayStart = calendar.date(from: businessStart) else {
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
                continue
            }

            var businessEnd = dayComponents
            businessEnd.hour = 18
            businessEnd.minute = 0
            guard let dayEnd = calendar.date(from: businessEnd) else {
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
                continue
            }

            // Skip weekends
            let weekday = calendar.component(.weekday, from: currentDate)
            if weekday == 1 || weekday == 7 {
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
                continue
            }

            // Find gaps in this day's events
            let dayEvents = events.filter { event in
                event.startDate < dayEnd && event.endDate > dayStart
            }

            var slotStart = dayStart
            for event in dayEvents {
                let eventStart = max(event.startDate, dayStart)
                if eventStart.timeIntervalSince(slotStart) >= minimumDuration {
                    freeSlots.append(TimeSlot(start: slotStart, end: eventStart))
                }
                slotStart = max(slotStart, event.endDate)
            }

            if dayEnd.timeIntervalSince(slotStart) >= minimumDuration {
                freeSlots.append(TimeSlot(start: slotStart, end: dayEnd))
            }

            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }

        return freeSlots
    }

    func addEvent(title: String, startDate: Date, endDate: Date, notes: String?) async throws {
        let event = EKEvent(eventStore: eventStore)
        event.title = title
        event.startDate = startDate
        event.endDate = endDate
        event.notes = notes
        event.calendar = eventStore.defaultCalendarForNewEvents

        do {
            try eventStore.save(event, span: .thisEvent)
        } catch {
            throw CalendarError.eventCreationFailed
        }
    }
}
