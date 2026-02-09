import SwiftUI

struct ResultView: View {
    let request: AppointmentRequest
    @EnvironmentObject var calendarService: CalendarService
    @EnvironmentObject var requestStore: RequestStore
    @EnvironmentObject var profileManager: UserProfileManager
    @State private var showConfirmSheet = false
    @State private var selectedConfirmDate = Date()
    @State private var calendarSaved = false
    @State private var errorMessage: String?
    @State private var detectedDateContext: String?
    @State private var showReschedule = false
    @State private var showCancel = false
    @State private var showCallStatus = false
    @State private var activeFollowUp: AppointmentRequest?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                statusCard
                detailsCard

                if request.status == .completed {
                    confirmSection
                }

                if request.status == .confirmed, let time = request.confirmedTime {
                    confirmedCard(time)
                    manageAppointmentSection
                }

                if request.status == .cancelled {
                    cancelledCard
                }

                if request.status == .rescheduled {
                    rescheduledCard
                }

                if let transcript = request.transcript, !transcript.isEmpty {
                    transcriptCard(transcript)
                }
            }
            .padding()
        }
        .navigationTitle("Call Result")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showConfirmSheet) {
            confirmTimeSheet
        }
        .sheet(isPresented: $showReschedule) {
            NavigationStack {
                RescheduleView(originalRequest: request)
            }
        }
        .sheet(isPresented: $showCancel) {
            NavigationStack {
                CancelView(originalRequest: request)
            }
        }
    }

    private var statusCard: some View {
        HStack {
            Image(systemName: request.status.iconName)
                .font(.largeTitle)
                .foregroundStyle(statusColor)

            VStack(alignment: .leading) {
                HStack(spacing: 6) {
                    Text(request.status.displayName)
                        .font(.title2)
                        .fontWeight(.bold)
                    if request.callPurpose != .book {
                        Text("(\(request.callPurpose.displayName))")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                Text(request.businessName)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var detailsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(request.phoneNumber, systemImage: "phone")
            Label(request.serviceDescription, systemImage: "text.quote")

            if !request.preferredTimes.isEmpty {
                Label("\(request.preferredTimes.count) time slot(s) provided", systemImage: "clock")
            }

            if let reason = request.cancellationReason {
                Label("Reason: \(reason.rawValue)", systemImage: "info.circle")
            }
        }
        .font(.subheadline)
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func transcriptCard(_ transcript: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Transcript")
                .font(.headline)

            Text(transcript)
                .font(.system(.body, design: .monospaced))
                .textSelection(.enabled)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var confirmSection: some View {
        VStack(spacing: 16) {
            Text("Was the appointment booked?")
                .font(.headline)

            if let (date, context) = extractDateFromTranscript() {
                VStack(alignment: .leading, spacing: 6) {
                    Label("Detected from transcript:", systemImage: "text.magnifyingglass")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text(date, style: .date)
                        .fontWeight(.semibold)
                    Text(date, style: .time)
                        .fontWeight(.semibold)

                    Text("\"...\(context)...\"")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .italic()
                        .lineLimit(3)
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.accentColor.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            }

            Button {
                if let (date, context) = extractDateFromTranscript() {
                    selectedConfirmDate = date
                    detectedDateContext = context
                }
                showConfirmSheet = true
            } label: {
                Label("Yes, Confirm Appointment", systemImage: "checkmark.circle.fill")
                    .frame(maxWidth: .infinity)
                    .fontWeight(.semibold)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)

            Button {
                markNotScheduled()
            } label: {
                Label("No, Appointment Not Scheduled", systemImage: "xmark.circle")
                    .frame(maxWidth: .infinity)
                    .fontWeight(.semibold)
            }
            .buttonStyle(.bordered)
            .tint(.red)

            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func confirmedCard(_ time: Date) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Appointment Confirmed", systemImage: "checkmark.seal.fill")
                .font(.headline)
                .foregroundStyle(.green)

            Text(time, style: .date)
            Text(time, style: .time)

            if calendarSaved {
                Label("Added to Calendar", systemImage: "calendar.badge.checkmark")
                    .foregroundStyle(.purple)
                    .font(.subheadline)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.green.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var manageAppointmentSection: some View {
        VStack(spacing: 12) {
            Text("Manage Appointment")
                .font(.headline)

            Button {
                showReschedule = true
            } label: {
                Label("Reschedule", systemImage: "arrow.triangle.2.circlepath")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            Button(role: .destructive) {
                showCancel = true
            } label: {
                Label("Cancel Appointment", systemImage: "xmark.circle")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var cancelledCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Appointment Cancelled", systemImage: "calendar.badge.minus")
                .font(.headline)
                .foregroundStyle(.red)

            if let reason = request.cancellationReason {
                Text("Reason: \(reason.rawValue)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.red.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var rescheduledCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Appointment Rescheduled", systemImage: "arrow.triangle.2.circlepath")
                .font(.headline)
                .foregroundStyle(.orange)

            Text("A new call was placed to reschedule this appointment.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.orange.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var confirmTimeSheet: some View {
        NavigationStack {
            Form {
                if let context = detectedDateContext {
                    Section {
                        HStack(spacing: 8) {
                            Image(systemName: "text.magnifyingglass")
                                .foregroundStyle(Color.accentColor)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("From transcript:")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("\"...\(context)...\"")
                                    .font(.caption)
                                    .italic()
                            }
                        }
                    } header: {
                        Text("Detected Appointment Time")
                    } footer: {
                        Text("The date below was pre-filled from the call transcript. Please verify it's correct.")
                    }
                }

                DatePicker("Appointment Time", selection: $selectedConfirmDate)

                Section {
                    Button("Confirm & Save to Calendar") {
                        confirmAppointment()
                    }
                    .fontWeight(.semibold)
                }
            }
            .navigationTitle("Confirm Time")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { showConfirmSheet = false }
                }
            }
        }
    }

    private func confirmAppointment() {
        var updated = request
        updated.status = .confirmed
        updated.confirmedTime = selectedConfirmDate
        requestStore.update(updated)

        Task {
            do {
                try await calendarService.addEvent(
                    title: "\(request.serviceDescription) at \(request.businessName)",
                    startDate: selectedConfirmDate,
                    endDate: Calendar.current.date(byAdding: .hour, value: 1, to: selectedConfirmDate)!
                )
                calendarSaved = true
            } catch {
                errorMessage = "Failed to add to calendar: \(error.localizedDescription)"
            }
        }

        showConfirmSheet = false
    }

    private func markNotScheduled() {
        var updated = request
        updated.status = .failed
        requestStore.update(updated)
    }

    private func extractDateFromTranscript() -> (Date, String)? {
        guard let transcript = request.transcript, !transcript.isEmpty else { return nil }

        guard let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.date.rawValue) else {
            return nil
        }

        let range = NSRange(transcript.startIndex..., in: transcript)
        let matches = detector.matches(in: transcript, range: range)

        // Find the last date match that's in the future (most likely the confirmed time)
        let now = Date()
        var bestMatch: (Date, String)?

        for match in matches.reversed() {
            guard let date = match.date,
                  date > now,
                  let matchRange = Range(match.range, in: transcript) else { continue }

            // Extract surrounding context (up to 60 chars on each side)
            let contextStart = transcript.index(matchRange.lowerBound, offsetBy: -60, limitedBy: transcript.startIndex) ?? transcript.startIndex
            let contextEnd = transcript.index(matchRange.upperBound, offsetBy: 60, limitedBy: transcript.endIndex) ?? transcript.endIndex
            let context = String(transcript[contextStart..<contextEnd])
                .replacingOccurrences(of: "\n", with: " ")

            bestMatch = (date, context)
            break
        }

        // Fall back to the last date match if no future dates found
        if bestMatch == nil, let lastMatch = matches.last,
           let date = lastMatch.date,
           let matchRange = Range(lastMatch.range, in: transcript) {
            let contextStart = transcript.index(matchRange.lowerBound, offsetBy: -60, limitedBy: transcript.startIndex) ?? transcript.startIndex
            let contextEnd = transcript.index(matchRange.upperBound, offsetBy: 60, limitedBy: transcript.endIndex) ?? transcript.endIndex
            let context = String(transcript[contextStart..<contextEnd])
                .replacingOccurrences(of: "\n", with: " ")
            bestMatch = (date, context)
        }

        return bestMatch
    }

    private var statusColor: Color {
        switch request.status {
        case .draft: return .gray
        case .calling: return .blue
        case .completed: return .green
        case .failed: return .red
        case .confirmed: return .purple
        case .cancelled: return .red
        case .rescheduled: return .orange
        }
    }
}

#Preview {
    NavigationStack {
        ResultView(request: .mock)
            .environmentObject(CalendarService())
            .environmentObject(RequestStore())
            .environmentObject(UserProfileManager())
    }
}
