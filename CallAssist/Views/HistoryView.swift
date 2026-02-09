import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var requestStore: RequestStore
    @ObservedObject var minutesManager = MinutesManager.shared

    @State private var selectedRequest: AppointmentRequest?
    @State private var showReschedule = false
    @State private var showCancel = false
    @State private var requestToDelete: AppointmentRequest?

    var body: some View {
        List {
            if requestStore.requests.isEmpty {
                ContentUnavailableView(
                    "No Calls Yet",
                    systemImage: "phone.badge.plus",
                    description: Text("Your appointment call history will appear here.")
                )
            } else {
                ForEach(requestStore.requests) { request in
                    NavigationLink {
                        ResultView(request: request)
                    } label: {
                        HistoryRow(request: request)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            requestToDelete = request
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }

                        if request.status == .confirmed {
                            Button {
                                selectedRequest = request
                                showCancel = true
                            } label: {
                                Label("Cancel", systemImage: "xmark.circle")
                            }
                            .tint(.red)
                        }
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                        if request.status == .confirmed {
                            Button {
                                selectedRequest = request
                                showReschedule = true
                            } label: {
                                Label("Reschedule", systemImage: "arrow.triangle.2.circlepath")
                            }
                            .tint(.orange)
                        }
                    }
                }
            }
        }
        .navigationTitle("History")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                MinutesBalanceWidget(minutesManager: minutesManager)
            }
        }
        .confirmationDialog(
            "Delete this call record?",
            isPresented: Binding(
                get: { requestToDelete != nil },
                set: { if !$0 { requestToDelete = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                if let request = requestToDelete {
                    requestStore.delete(request)
                    requestToDelete = nil
                }
            }
        } message: {
            Text("This action cannot be undone.")
        }
        .sheet(isPresented: $showReschedule) {
            if let request = selectedRequest {
                NavigationStack {
                    RescheduleView(originalRequest: request)
                }
            }
        }
        .sheet(isPresented: $showCancel) {
            if let request = selectedRequest {
                NavigationStack {
                    CancelView(originalRequest: request)
                }
            }
        }
    }
}

struct HistoryRow: View {
    let request: AppointmentRequest

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: request.wasUnanswered ? "phone.arrow.down.left" : request.status.iconName)
                .font(.title3)
                .foregroundStyle(request.wasUnanswered ? .orange : statusColor)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(request.businessName)
                        .font(.headline)

                    if request.wasUnanswered {
                        Text("Unanswered")
                            .font(.caption2)
                            .fontWeight(.medium)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.15))
                            .foregroundStyle(.orange)
                            .clipShape(Capsule())
                    }

                    if request.callPurpose != .book {
                        Text(request.callPurpose.displayName)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(purposeColor.opacity(0.15))
                            .foregroundStyle(purposeColor)
                            .clipShape(Capsule())
                    }
                }

                Text(request.serviceDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)

                HStack {
                    Text(request.status.displayName)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(statusColor)

                    Spacer()

                    Text(request.createdAt, style: .relative)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }
            }
        }
        .padding(.vertical, 4)
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

    private var purposeColor: Color {
        switch request.callPurpose {
        case .book: return .blue
        case .reschedule: return .orange
        case .cancel: return .red
        }
    }
}

#Preview {
    NavigationStack {
        HistoryView()
            .environmentObject({
                let store = RequestStore()
                store.requests = AppointmentRequest.mockHistory
                return store
            }())
    }
}
