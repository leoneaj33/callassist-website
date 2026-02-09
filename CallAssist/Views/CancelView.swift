import SwiftUI

struct CancelView: View {
    let originalRequest: AppointmentRequest
    @EnvironmentObject var requestStore: RequestStore
    @EnvironmentObject var profileManager: UserProfileManager
    @Environment(\.dismiss) private var dismiss

    @State private var selectedReason: CancellationReason = .scheduleConflict
    @State private var showCallStatus = false
    @State private var activeRequest: AppointmentRequest?
    @State private var errorMessage: String?

    var body: some View {
        Form {
            Section {
                HStack {
                    Image(systemName: "building.2")
                        .foregroundStyle(.secondary)
                    Text(originalRequest.businessName)
                }
                HStack {
                    Image(systemName: "text.quote")
                        .foregroundStyle(.secondary)
                    Text(originalRequest.serviceDescription)
                }
                if let time = originalRequest.confirmedTime {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundStyle(.secondary)
                        VStack(alignment: .leading) {
                            Text("Scheduled For")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(time, style: .date)
                            Text(time, style: .time)
                        }
                    }
                }
            } header: {
                Text("Appointment to Cancel")
            }

            Section {
                Picker("Reason", selection: $selectedReason) {
                    ForEach(CancellationReason.allCases) { reason in
                        Text(reason.rawValue).tag(reason)
                    }
                }
                .pickerStyle(.inline)
                .labelsHidden()
            } header: {
                Text("Reason for Cancellation")
            } footer: {
                Text("This will be communicated to the business during the call.")
            }

            if let error = errorMessage {
                Section {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.caption)
                }
            }

            Section {
                Button(role: .destructive) {
                    placeCancelCall()
                } label: {
                    HStack {
                        Spacer()
                        Image(systemName: "phone.fill")
                        Text("Call to Cancel")
                            .fontWeight(.semibold)
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle("Cancel Appointment")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Back") { dismiss() }
            }
        }
        .fullScreenCover(isPresented: $showCallStatus) {
            if let req = activeRequest {
                NavigationStack {
                    CallStatusView(request: req)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) {
                                Button("Done") {
                                    showCallStatus = false
                                    dismiss()
                                }
                            }
                        }
                }
            }
        }
    }

    private func placeCancelCall() {
        let activeProfile = profileManager.activeProfile

        // Mark original as cancelled
        var updated = originalRequest
        updated.status = .cancelled
        updated.cancellationReason = selectedReason
        requestStore.update(updated)

        // Create a new request for the cancellation call
        var cancelRequest = AppointmentRequest(
            businessName: originalRequest.businessName,
            phoneNumber: originalRequest.phoneNumber,
            serviceDescription: originalRequest.serviceDescription,
            status: .calling,
            confirmedTime: originalRequest.confirmedTime,
            listenInEnabled: originalRequest.listenInEnabled,
            userProfileId: activeProfile?.id,
            callPurpose: .cancel,
            cancellationReason: selectedReason,
            originalRequestId: originalRequest.id
        )
        requestStore.add(cancelRequest)
        activeRequest = cancelRequest

        Task {
            do {
                let callResponse = try await VapiService.shared.createCall(for: cancelRequest, userProfile: activeProfile)
                cancelRequest.callId = callResponse.id
                requestStore.update(cancelRequest)
                activeRequest = cancelRequest
                showCallStatus = true
            } catch {
                cancelRequest.status = .failed
                requestStore.update(cancelRequest)
                errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    NavigationStack {
        CancelView(originalRequest: .mock)
            .environmentObject(RequestStore())
            .environmentObject(UserProfileManager())
    }
}
