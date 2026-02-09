import Foundation

class VapiService {
    static let shared = VapiService()

    private let baseURL = "https://api.vapi.ai"
    private var apiKey: String { AppConfig.shared.vapiApiKey }
    private var assistantId: String { AppConfig.shared.vapiAssistantId }
    private var phoneNumberId: String { AppConfig.shared.vapiPhoneNumberId }

    func createCall(for request: AppointmentRequest, userProfile: UserProfile?) async throws -> CreateCallResponse {
        let url = URL(string: "\(baseURL)/call")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let availabilityList = TimeSlot.vapiAvailabilityDescription(for: request.preferredTimes)

        var variables: [String: String] = [
            "businessName": request.businessName,
            "serviceDescription": request.serviceDescription,
            "callPurpose": request.callPurpose.rawValue,
        ]

        if !request.preferredTimes.isEmpty {
            variables["availableTimes"] = availabilityList
        }

        if let reason = request.cancellationReason {
            variables["cancellationReason"] = reason.rawValue
        }

        if let confirmedTime = request.confirmedTime {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMMM d 'at' h:mm a"
            variables["existingAppointmentTime"] = formatter.string(from: confirmedTime)
        }

        if let profile = userProfile {
            for (key, value) in profile.vapiVariables {
                variables[key] = value
            }
        }

        let firstMessage = buildFirstMessage(for: request, profile: userProfile)

        let e164Number = Self.toE164(request.phoneNumber)

        let body = CreateCallRequest(
            assistantId: assistantId,
            phoneNumberId: phoneNumberId,
            customer: .init(number: e164Number),
            assistantOverrides: .init(
                variableValues: variables,
                firstMessage: firstMessage
            )
        )

        urlRequest.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw VapiError.invalidResponse
        }

        guard httpResponse.statusCode == 201 || httpResponse.statusCode == 200 else {
            let errorBody = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("[Vapi] Error \(httpResponse.statusCode): \(errorBody)")
            throw VapiError.apiError(statusCode: httpResponse.statusCode, message: errorBody)
        }

        return try JSONDecoder().decode(CreateCallResponse.self, from: data)
    }

    private func buildFirstMessage(for request: AppointmentRequest, profile: UserProfile?) -> String? {
        guard let profile = profile, profile.isComplete else { return nil }

        switch request.callPurpose {
        case .book:
            return "Hello, I'm Robin calling on behalf of \(profile.fullName) to schedule an appointment for \(request.serviceDescription). Do you have any availability?"

        case .reschedule:
            let existingTime: String
            if let time = request.confirmedTime {
                let formatter = DateFormatter()
                formatter.dateFormat = "EEEE, MMMM d 'at' h:mm a"
                existingTime = formatter.string(from: time)
            } else {
                existingTime = "an upcoming appointment"
            }
            return "Hello, I'm Robin calling on behalf of \(profile.fullName). They need to reschedule their \(request.serviceDescription) appointment that was set for \(existingTime). Could we find a new time?"

        case .cancel:
            let existingTime: String
            if let time = request.confirmedTime {
                let formatter = DateFormatter()
                formatter.dateFormat = "EEEE, MMMM d 'at' h:mm a"
                existingTime = formatter.string(from: time)
            } else {
                existingTime = "an upcoming appointment"
            }
            let reasonClause: String
            if let reason = request.cancellationReason {
                reasonClause = " due to \(reason.rawValue.lowercased())"
            } else {
                reasonClause = ""
            }
            return "Hello, I'm Robin calling on behalf of \(profile.fullName). They need to cancel their \(request.serviceDescription) appointment that was set for \(existingTime)\(reasonClause). Could you please cancel that for them?"
        }
    }

    func getCallStatus(callId: String) async throws -> CallResult {
        let url = URL(string: "\(baseURL)/call/\(callId)")!
        var urlRequest = URLRequest(url: url)
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw VapiError.invalidResponse
        }

        return try JSONDecoder().decode(CallResult.self, from: data)
    }

    func endCall(callId: String) async throws {
        let url = URL(string: "\(baseURL)/call/\(callId)")!
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "PATCH"
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.httpBody = try JSONSerialization.data(withJSONObject: ["status": "ended"])

        let (_, response) = try await URLSession.shared.data(for: urlRequest)
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw VapiError.invalidResponse
        }
    }

    func pollUntilComplete(callId: String, interval: TimeInterval = 10, onUpdate: @escaping (CallResult) -> Void) async throws -> CallResult {
        while true {
            let result = try await getCallStatus(callId: callId)
            onUpdate(result)

            if result.isEnded {
                return result
            }

            try await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
        }
    }

    /// Converts a user-entered phone number to E.164 format.
    /// Strips non-digit characters and prepends +1 (US) if no country code present.
    /// Examples: "(555) 123-4567" -> "+15551234567", "+44 20 1234 5678" -> "+442012345678"
    static func toE164(_ input: String) -> String {
        let digits = input.filter { $0.isNumber }

        if input.hasPrefix("+") {
            return "+\(digits)"
        }

        // US/Canada: 10 digits without country code
        if digits.count == 10 {
            return "+1\(digits)"
        }

        // 11 digits starting with 1 = already has US country code
        if digits.count == 11 && digits.hasPrefix("1") {
            return "+\(digits)"
        }

        // Fallback: prepend + and hope for the best
        return "+\(digits)"
    }
}

enum VapiError: LocalizedError {
    case invalidResponse
    case apiError(statusCode: Int, message: String)
    case notConfigured

    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from Vapi API."
        case .apiError(let code, let message):
            return "Vapi API error (\(code)): \(message)"
        case .notConfigured:
            return "Vapi is not configured. Add your API key to Secrets.plist."
        }
    }
}
