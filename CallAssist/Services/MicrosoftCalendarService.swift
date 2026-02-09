import Foundation

class MicrosoftCalendarService: CalendarProvider {
    let providerType: CalendarProviderType = .microsoft
    let displayName = "Microsoft Outlook"

    private var accessToken: String?

    var isAuthorized: Bool {
        accessToken != nil
    }

    func requestAccess() async throws -> Bool {
        // Microsoft MSAL flow
        // In production, this would use MSAL SDK:
        //   1. Create MSALPublicClientApplication with your Azure AD client ID
        //   2. Call acquireToken with scopes: ["Calendars.ReadWrite"]
        //   3. Store the access token from MSALResult.accessToken
        //
        // Prerequisites:
        //   - Register app in Azure AD portal
        //   - Add redirect URI for iOS
        //   - Enable Microsoft Graph Calendar permissions
        let config = AppConfig.shared
        guard !config.microsoftClientId.isEmpty else {
            throw MicrosoftCalendarError.notConfigured
        }

        print("[MicrosoftCalendar] MSAL sign-in would launch here")
        print("[MicrosoftCalendar] Client ID: \(config.microsoftClientId)")

        throw MicrosoftCalendarError.requiresRealDevice
    }

    func fetchFreeSlots(from startDate: Date, to endDate: Date, minimumDuration: TimeInterval) async throws -> [TimeSlot] {
        guard let token = accessToken else {
            throw MicrosoftCalendarError.notAuthenticated
        }

        // Microsoft Graph API: GET /me/calendarview
        let formatter = ISO8601DateFormatter()
        let startStr = formatter.string(from: startDate)
        let endStr = formatter.string(from: endDate)

        var urlComponents = URLComponents(string: "https://graph.microsoft.com/v1.0/me/calendarview")!
        urlComponents.queryItems = [
            URLQueryItem(name: "startdatetime", value: startStr),
            URLQueryItem(name: "enddatetime", value: endStr),
            URLQueryItem(name: "$orderby", value: "start/dateTime"),
        ]

        var request = URLRequest(url: urlComponents.url!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw MicrosoftCalendarError.apiFailed
        }

        let result = try JSONDecoder().decode(MSGraphEventsResponse.self, from: data)
        return computeFreeSlots(events: result.value ?? [], from: startDate, to: endDate, minimumDuration: minimumDuration)
    }

    func addEvent(title: String, startDate: Date, endDate: Date, notes: String?) async throws {
        guard let token = accessToken else {
            throw MicrosoftCalendarError.notAuthenticated
        }

        let url = URL(string: "https://graph.microsoft.com/v1.0/me/events")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let formatter = ISO8601DateFormatter()
        let event: [String: Any] = [
            "subject": title,
            "body": ["contentType": "text", "content": notes ?? ""],
            "start": ["dateTime": formatter.string(from: startDate), "timeZone": TimeZone.current.identifier],
            "end": ["dateTime": formatter.string(from: endDate), "timeZone": TimeZone.current.identifier],
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: event)

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, (200...201).contains(httpResponse.statusCode) else {
            throw MicrosoftCalendarError.apiFailed
        }
    }

    private func computeFreeSlots(events: [MSGraphEvent], from startDate: Date, to endDate: Date, minimumDuration: TimeInterval) -> [TimeSlot] {
        let calendar = Calendar.current
        var freeSlots: [TimeSlot] = []
        let formatter = ISO8601DateFormatter()

        var currentDate = startDate
        while currentDate < endDate {
            let weekday = calendar.component(.weekday, from: currentDate)
            if weekday == 1 || weekday == 7 {
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
                continue
            }

            let dayComponents = calendar.dateComponents([.year, .month, .day], from: currentDate)
            var startComp = dayComponents; startComp.hour = 8; startComp.minute = 0
            var endComp = dayComponents; endComp.hour = 18; endComp.minute = 0
            guard let dayStart = calendar.date(from: startComp),
                  let dayEnd = calendar.date(from: endComp) else {
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
                continue
            }

            let dayEvents = events.compactMap { event -> (Date, Date)? in
                guard let startStr = event.start?.dateTime,
                      let endStr = event.end?.dateTime,
                      let s = formatter.date(from: startStr),
                      let e = formatter.date(from: endStr),
                      s < dayEnd && e > dayStart else { return nil }
                return (s, e)
            }.sorted { $0.0 < $1.0 }

            var slotStart = dayStart
            for (eventStart, eventEnd) in dayEvents {
                let gapEnd = min(eventStart, dayEnd)
                if gapEnd.timeIntervalSince(slotStart) >= minimumDuration {
                    freeSlots.append(TimeSlot(start: slotStart, end: gapEnd))
                }
                slotStart = max(slotStart, eventEnd)
            }

            if dayEnd.timeIntervalSince(slotStart) >= minimumDuration {
                freeSlots.append(TimeSlot(start: slotStart, end: dayEnd))
            }

            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }

        return freeSlots
    }
}

// MARK: - Microsoft Graph API Models

struct MSGraphEventsResponse: Codable {
    let value: [MSGraphEvent]?
}

struct MSGraphEvent: Codable {
    let subject: String?
    let start: MSGraphDateTime?
    let end: MSGraphDateTime?
}

struct MSGraphDateTime: Codable {
    let dateTime: String?
    let timeZone: String?
}

enum MicrosoftCalendarError: LocalizedError {
    case notConfigured
    case notAuthenticated
    case requiresRealDevice
    case apiFailed

    var errorDescription: String? {
        switch self {
        case .notConfigured: return "Microsoft Calendar is not configured. Add your Microsoft Client ID to Secrets.plist."
        case .notAuthenticated: return "Not signed in to Microsoft. Please sign in first."
        case .requiresRealDevice: return "Microsoft sign-in requires a real device (not Simulator). Use Apple Calendar for testing."
        case .apiFailed: return "Microsoft Graph API request failed."
        }
    }
}
