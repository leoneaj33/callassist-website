import SwiftUI

struct CallStatusView: View {
    let request: AppointmentRequest
    @EnvironmentObject var requestStore: RequestStore
    @EnvironmentObject var profileManager: UserProfileManager
    @Environment(\.dismiss) private var dismiss

    @State private var callResult: CallResult?
    @State private var currentStatus: String = "Initiating..."
    @State private var transcript: String = ""
    @State private var isPolling = true
    @State private var errorMessage: String?
    @State private var showResult = false
    @State private var showListenIn = false
    @State private var didAutoOpenListenIn = false
    @State private var showEndCallConfirm = false
    @State private var isEndingCall = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Animated phone icon
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.15))
                    .frame(width: 120, height: 120)

                Circle()
                    .fill(statusColor.opacity(0.08))
                    .frame(width: 160, height: 160)

                Image(systemName: statusIcon)
                    .font(.system(size: 48))
                    .foregroundStyle(statusColor)
                    .symbolEffect(.pulse, isActive: isPolling)
            }

            VStack(spacing: 8) {
                Text(currentStatus)
                    .font(.title2)
                    .fontWeight(.bold)

                Text(request.businessName)
                    .foregroundStyle(.secondary)

                Text(request.phoneNumber)
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
            }

            if request.listenInEnabled && isPolling && didAutoOpenListenIn && !showListenIn {
                Button {
                    showListenIn = true
                } label: {
                    Label("Listen In", systemImage: "headphones")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .padding(.horizontal, 40)
            }

            if isPolling, request.callId != nil {
                Button(role: .destructive) {
                    showEndCallConfirm = true
                } label: {
                    Label(isEndingCall ? "Ending Call..." : "End Call", systemImage: "phone.down.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.red)
                .disabled(isEndingCall)
                .padding(.horizontal, 40)
            }

            // Live transcript snippet
            if !transcript.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Live Transcript")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)

                    ScrollView {
                        Text(transcript)
                            .font(.system(.caption, design: .monospaced))
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxHeight: 150)
                }
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
            }

            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.horizontal)
            }

            Spacer()

            if !isPolling {
                Button {
                    var updated = request
                    updated.status = callResult?.isEnded == true ? .completed : .failed
                    updated.transcript = transcript.isEmpty ? nil : transcript
                    updated.endedReason = callResult?.endedReason
                    requestStore.update(updated)
                    showResult = true
                } label: {
                    Text("View Results")
                        .frame(maxWidth: .infinity)
                        .fontWeight(.semibold)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal, 40)
            }

            Button(role: .destructive) {
                dismiss()
            } label: {
                Text(isPolling ? "Close" : "Done")
            }
            .padding(.bottom)
        }
        .navigationTitle("Call in Progress")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .sheet(isPresented: $showListenIn) {
            NavigationStack {
                ListenInView(
                    callId: request.callId ?? "",
                    businessName: request.businessName,
                    listenUrl: callResult?.monitor?.listenUrl,
                    controlUrl: callResult?.monitor?.controlUrl,
                    userPhoneNumber: profileManager.profiles.first?.phoneNumber
                )
            }
        }
        .fullScreenCover(isPresented: $showResult) {
            NavigationStack {
                ResultView(request: {
                    var r = request
                    r.status = callResult?.isEnded == true ? .completed : .failed
                    r.transcript = transcript.isEmpty ? nil : transcript
                    r.endedReason = callResult?.endedReason
                    return r
                }())
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Done") { dismiss() }
                    }
                }
            }
        }
        .confirmationDialog("End this call?", isPresented: $showEndCallConfirm, titleVisibility: .visible) {
            Button("End Call", role: .destructive) {
                endCall()
            }
        } message: {
            Text("This will immediately hang up the AI call.")
        }
        .task { await startPolling() }
    }

    private var statusColor: Color {
        switch currentStatus {
        case "Initiating...", "Queued": return .orange
        case "Ringing...": return .blue
        case "In Progress": return .green
        case "Call Ended": return .gray
        default: return .blue
        }
    }

    private var statusIcon: String {
        switch currentStatus {
        case "Initiating...", "Queued": return "phone.arrow.up.right"
        case "Ringing...": return "phone.connection"
        case "In Progress": return "phone.fill"
        case "Call Ended": return "phone.down.fill"
        default: return "phone"
        }
    }

    private func endCall() {
        guard let callId = request.callId else { return }
        isEndingCall = true

        Task {
            do {
                try await VapiService.shared.endCall(callId: callId)
                await MainActor.run {
                    currentStatus = "Call Ended"
                    isPolling = false
                    isEndingCall = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to end call: \(error.localizedDescription)"
                    isEndingCall = false
                }
            }
        }
    }

    private func startPolling() async {
        guard let callId = request.callId else {
            currentStatus = "No call ID"
            errorMessage = "Call could not be initiated. Check your Vapi configuration."
            isPolling = false
            return
        }

        do {
            let result = try await VapiService.shared.pollUntilComplete(callId: callId) { update in
                Task { @MainActor in
                    callResult = update
                    currentStatus = update.displayStatus
                    if let t = update.transcript, !t.isEmpty {
                        transcript = t
                    }
                    if let messages = update.messages {
                        let messageText = messages.compactMap { msg -> String? in
                            guard let text = msg.message else { return nil }
                            return "\(msg.displayRole): \(text)"
                        }.joined(separator: "\n")
                        if !messageText.isEmpty {
                            transcript = messageText
                        }
                    }
                    // Auto-open listen-in when call goes in-progress
                    if request.listenInEnabled && !didAutoOpenListenIn && update.status == "in-progress" {
                        didAutoOpenListenIn = true
                        showListenIn = true
                    }
                }
            }

            callResult = result
            currentStatus = result.displayStatus
            if let t = result.transcript, !t.isEmpty {
                transcript = t
            }

            // Deduct minutes from user balance
            if result.durationInMinutes > 0 {
                MinutesManager.shared.deductMinutes(result.durationInMinutes)
            }
        } catch {
            errorMessage = error.localizedDescription
        }

        isPolling = false
    }
}

#Preview {
    NavigationStack {
        CallStatusView(request: .mock)
            .environmentObject(RequestStore())
            .environmentObject(UserProfileManager())
    }
}
