import Foundation

class GoogleCalendarService: CalendarProvider {
    let providerType: CalendarProviderType = .google
    let displayName = "Google Calendar"

    private var accessToken: String?

    var isAuthorized: Bool {
        accessToken != nil
    }

    func requestAccess() async throws -> Bool {
        // Google OAuth 2.0 flow
        // In production, this would use GoogleSignIn SDK:
        //   1. GIDSignIn.sharedInstance.signIn(withPresenting:)
        //   2. Request scope: "https://www.googleapis.com/auth/calendar"
        //   3. Store the access token from GIDGoogleUser.authentication.accessToken
        //
        // For now, check if credentials are configured in Secrets.plist
        let config = AppConfig.shared
        guard !config.googleClientId.isEmpty else {
            throw GoogleCalendarError.notConfigured
        }

        // Placeholder: In a real implementation, the GoogleSignIn SDK
        // presents a web-based OAuth consent screen and returns tokens.
        // The user must be on a real device (not simulator) for this to work.
        print("[GoogleCalendar] OAuth sign-in would launch here")
        print("[GoogleCalendar] Client ID: \(config.googleClientId)")

        // For development/testing, you can set a token manually:
        // self.accessToken = "your-test-token"
        // return true

        throw GoogleCalendarError.requiresRealDevice
    }

    func fetchFreeSlots(from startDate: Date, to endDate: Date, minimumDuration: TimeInterval) async throws -> [TimeSlot] {
        guard let token = accessToken else {
            throw GoogleCalendarError.notAuthenticated
        }

        // Google Calendar API: GET /calendars/primary/events
        let formatter = ISO8601DateFormatter()
        let timeMin = formatter.string(from: startDate)
        let timeMax = formatter.string(from: endDate)

        var urlComponents = URLComponents(string: "https://www.googleapis.com/calendar/v3/calendars/primary/events")!
        urlComponents.queryItems = [
            URLQueryItem(name: "timeMin", value: timeMin),
            URLQueryItem(name: "timeMax", value: timeMax),
            URLQueryItem(name: "singleEvents", value: "true"),
            URLQueryItem(name: "orderBy", value: "startTime"),
        ]

        var request = URLRequest(url: urlComponents.url!)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw GoogleCalendarError.apiFailed
        }

        let result = try JSONDecoder().decode(GoogleEventsResponse.self, from: data)
        return computeFreeSlots(events: result.items ?? [], from: startDate, to: endDate, minimumDuration: minimumDuration)
    }

    func addEvent(title: String, startDate: Date, endDate: Date, notes: String?) async throws {
        guard let token = accessToken else {
            throw GoogleCalendarError.notAuthenticated
        }

        let url = URL(string: "https://www.googleapis.com/calendar/v3/calendars/primary/events")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let formatter = ISO8601DateFormatter()
        let event: [String: Any] = [
            "summary": title,
            "description": notes ?? "",
            "start": ["dateTime": formatter.string(from: startDate)],
            "end": ["dateTime": formatter.string(from: endDate)],
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: event)

        let (_, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw GoogleCalendarError.apiFailed
        }
    }

    private func computeFreeSlots(events: [GoogleEvent], from startDate: Date, to endDate: Date, minimumDuration: TimeInterval) -> [TimeSlot] {
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
                guard let startStr = event.start?.dateTime ?? event.start?.date,
                      let endStr = event.end?.dateTime ?? event.end?.date,
                      let s = formatter.date(from: startStr),
                      let e = formatter.date(from: endStr),
                      s < dayEnd && e > dayStart else { return nil }
                return (s, e)
            }.sorted { $0.0 < $1.0 }

            var slotStart = dayStart
            for (eventStart, eventEnd) in dayEvents {
                let gapStart = max(slotStart, dayStart)
                let gapEnd = min(eventStart, dayEnd)
                if gapEnd.timeIntervalSince(gapStart) >= minimumDuration {
                    freeSlots.append(TimeSlot(start: gapStart, end: gapEnd))
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

// MARK: - Google Calendar API Models

struct GoogleEventsResponse: Codable {
    let items: [GoogleEvent]?
}

struct GoogleEvent: Codable {
    let summary: String?
    let start: GoogleDateTime?
    let end: GoogleDateTime?
}

struct GoogleDateTime: Codable {
    let dateTime: String?
    let date: String?
}

enum GoogleCalendarError: LocalizedError {
    case notConfigured
    case notAuthenticated
    case requiresRealDevice
    case apiFailed

    var errorDescription: String? {
        switch self {
        case .notConfigured: return "Google Calendar is not configured. Add your Google Client ID to Secrets.plist."
        case .notAuthenticated: return "Not signed in to Google. Please sign in first."
        case .requiresRealDevice: return "Google sign-in requires a real device (not Simulator). Use Apple Calendar for testing."
        case .apiFailed: return "Google Calendar API request failed."
        }
    }
}
