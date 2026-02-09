import Foundation

enum CalendarProviderType: String, Codable, CaseIterable, Identifiable {
    case apple
    case google
    case microsoft

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .apple: return "Apple Calendar"
        case .google: return "Google Calendar"
        case .microsoft: return "Microsoft Outlook"
        }
    }

    var iconName: String {
        switch self {
        case .apple: return "apple.logo"
        case .google: return "envelope"
        case .microsoft: return "m.circle"
        }
    }

    var description: String {
        switch self {
        case .apple: return "Works in Simulator. Uses the built-in iOS calendar."
        case .google: return "Requires Google account sign-in. Needs real device."
        case .microsoft: return "Requires Microsoft account sign-in. Needs real device."
        }
    }
}

protocol CalendarProvider {
    var providerType: CalendarProviderType { get }
    var displayName: String { get }
    var isAuthorized: Bool { get }

    func requestAccess() async throws -> Bool
    func fetchFreeSlots(from startDate: Date, to endDate: Date, minimumDuration: TimeInterval) async throws -> [TimeSlot]
    func addEvent(title: String, startDate: Date, endDate: Date, notes: String?) async throws
}

extension CalendarProvider {
    func addEvent(title: String, startDate: Date, endDate: Date) async throws {
        try await addEvent(title: title, startDate: startDate, endDate: endDate, notes: nil)
    }
}
