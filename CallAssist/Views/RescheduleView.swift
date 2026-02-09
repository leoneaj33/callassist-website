import SwiftUI

struct RescheduleView: View {
    let originalRequest: AppointmentRequest
    @EnvironmentObject var calendarService: CalendarService
    @EnvironmentObject var requestStore: RequestStore
    @EnvironmentObject var profileManager: UserProfileManager
    @Environment(\.dismiss) private var dismiss

    @State private var selectedSlots: [TimeSlot] = []
    @State private var showAvailability = false
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
                            Text("Current Appointment")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text(time, style: .date)
                            Text(time, style: .time)
                        }
                    }
                }
            } header: {
                Text("Existing Appointment")
            }

            Section {
                Button {
                    showAvailability = true
                } label: {
                    HStack {
                        Image(systemName: "calendar.badge.plus")
                        Text(selectedSlots.isEmpty ? "Select New Times" : "\(selectedSlots.count) new time(s) selected")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                }

                if !selectedSlots.isEmpty {
                    ForEach(selectedSlots) { slot in
                        HStack {
                            Image(systemName: "clock")
                                .foregroundStyle(.secondary)
                            Text(slot.displayString)
                                .font(.subheadline)
                        }
                    }
                }
            } header: {
                Text("Proposed New Times")
            } footer: {
                Text("Select times you're available. The AI will ask the business to reschedule to one of these windows.")
            }

            if let error = errorMessage {
                Section {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.caption)
                }
            }

            Section {
                Button {
                    placeRescheduleCall()
                } label: {
                    HStack {
                        Spacer()
                        Image(systemName: "phone.fill")
                        Text("Call to Reschedule")
                            .fontWeight(.semibold)
                        Spacer()
                    }
                }
                .disabled(selectedSlots.isEmpty)
            }
        }
        .navigationTitle("Reschedule")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
        }
        .sheet(isPresented: $showAvailability) {
            NavigationStack {
                AvailabilityView(selectedSlots: $selectedSlots)
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

    private func placeRescheduleCall() {
        let activeProfile = profileManager.activeProfile

        // Mark original as rescheduled
        var updated = originalRequest
        updated.status = .rescheduled
        requestStore.update(updated)

        // Create a new request for the reschedule call
        var rescheduleRequest = AppointmentRequest(
            businessName: originalRequest.businessName,
            phoneNumber: originalRequest.phoneNumber,
            serviceDescription: originalRequest.serviceDescription,
            preferredTimes: selectedSlots,
            status: .calling,
            confirmedTime: originalRequest.confirmedTime,
            listenInEnabled: originalRequest.listenInEnabled,
            userProfileId: activeProfile?.id,
            callPurpose: .reschedule,
            originalRequestId: originalRequest.id
        )
        requestStore.add(rescheduleRequest)
        activeRequest = rescheduleRequest

        Task {
            do {
                let callResponse = try await VapiService.shared.createCall(for: rescheduleRequest, userProfile: activeProfile)
                rescheduleRequest.callId = callResponse.id
                requestStore.update(rescheduleRequest)
                activeRequest = rescheduleRequest
                showCallStatus = true
            } catch {
                rescheduleRequest.status = .failed
                requestStore.update(rescheduleRequest)
                errorMessage = error.localizedDescription
            }
        }
    }
}

#Preview {
    NavigationStack {
        RescheduleView(originalRequest: .mock)
            .environmentObject(CalendarService())
            .environmentObject(RequestStore())
            .environmentObject(UserProfileManager())
    }
}
