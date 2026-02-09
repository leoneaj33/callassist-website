import SwiftUI

struct AvailabilityView: View {
    @EnvironmentObject var calendarService: CalendarService
    @Binding var selectedSlots: [TimeSlot]
    @Environment(\.dismiss) private var dismiss

    @State private var freeSlots: [TimeSlot] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var startDate = Date()
    @State private var endDate = Calendar.current.date(byAdding: .day, value: 7, to: Date())!

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Loading free slots...")
                    .padding()
            } else if let error = errorMessage {
                ContentUnavailableView {
                    Label("Error", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(error)
                } actions: {
                    Button("Try Again") { loadSlots() }
                }
            } else if freeSlots.isEmpty {
                ContentUnavailableView(
                    "No Free Slots",
                    systemImage: "calendar.badge.exclamationmark",
                    description: Text("No availability found in the next 7 days.")
                )
            } else {
                List {
                    Section {
                        Text("Select times when you're available. The AI will suggest these to the business.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    ForEach(groupedByDay.keys.sorted(), id: \.self) { dayKey in
                        Section(dayKey) {
                            ForEach(groupedByDay[dayKey] ?? []) { slot in
                                SlotRow(slot: slot, isSelected: selectedSlots.contains(slot)) {
                                    toggleSlot(slot)
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Availability")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Done (\(selectedSlots.count))") {
                    dismiss()
                }
                .disabled(selectedSlots.isEmpty)
            }
        }
        .onAppear { loadSlots() }
    }

    private var groupedByDay: [String: [TimeSlot]] {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return Dictionary(grouping: freeSlots) { formatter.string(from: $0.start) }
    }

    private func toggleSlot(_ slot: TimeSlot) {
        if let index = selectedSlots.firstIndex(of: slot) {
            selectedSlots.remove(at: index)
        } else {
            selectedSlots.append(slot)
        }
    }

    private func loadSlots() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                freeSlots = try await calendarService.fetchFreeSlots(from: startDate, to: endDate)
                isLoading = false
            } catch {
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }
}

struct SlotRow: View {
    let slot: TimeSlot
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading) {
                    Text(slot.displayString)
                        .font(.subheadline)
                    Text("\(slot.durationMinutes) min available")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? Color.accentColor : .secondary)
                    .font(.title3)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        AvailabilityView(selectedSlots: .constant([]))
            .environmentObject(CalendarService())
    }
}
