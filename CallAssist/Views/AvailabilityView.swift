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
    @State private var showManualEntry = false
    @State private var manualDate = Date()
    @State private var manualStartTime = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!
    @State private var manualEndTime = Calendar.current.date(bySettingHour: 17, minute: 0, second: 0, of: Date())!

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
            } else {
                List {
                    // Selected Times Section (Always visible)
                    if !selectedSlots.isEmpty {
                        Section {
                            ForEach(selectedSlots) { slot in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(slot.displayString)
                                            .font(.subheadline)
                                        Text("\(slot.durationMinutes) min")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    Button(role: .destructive) {
                                        removeSlot(slot)
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundStyle(.red)
                                    }
                                }
                            }

                            Button(role: .destructive) {
                                selectedSlots.removeAll()
                            } label: {
                                Label("Clear All", systemImage: "trash")
                            }
                        } header: {
                            Text("Selected Times (\(selectedSlots.count))")
                        } footer: {
                            Text("Tap the ✕ to remove a time slot")
                        }
                    }

                    // Instructions
                    Section {
                        Text("Select times when you're available. Tap again to deselect.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    // Manual Time Entry
                    Section {
                        Button {
                            showManualEntry = true
                        } label: {
                            Label("Add Custom Time", systemImage: "plus.circle.fill")
                        }
                    } header: {
                        Text("Manual Entry")
                    } footer: {
                        Text("Add specific date and time ranges")
                    }

                    // Calendar-based free slots
                    if !freeSlots.isEmpty {
                        ForEach(groupedByDay.keys.sorted(), id: \.self) { dayKey in
                            Section(dayKey) {
                                ForEach(groupedByDay[dayKey] ?? []) { slot in
                                    SlotRow(slot: slot, isSelected: selectedSlots.contains(slot)) {
                                        toggleSlot(slot)
                                    }
                                }
                            }
                        }
                    } else {
                        Section {
                            Text("No calendar-based free slots found. Use manual entry to add times.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        } header: {
                            Text("From Your Calendar")
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
                Button("Done") {
                    dismiss()
                }
                .disabled(selectedSlots.isEmpty)
            }
        }
        .onAppear { loadSlots() }
        .sheet(isPresented: $showManualEntry) {
            NavigationStack {
                ManualTimePickerView(
                    selectedDate: $manualDate,
                    startTime: $manualStartTime,
                    endTime: $manualEndTime,
                    onAdd: { addManualTimeSlot() }
                )
            }
        }
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

    private func removeSlot(_ slot: TimeSlot) {
        selectedSlots.removeAll { $0.id == slot.id }
    }

    private func addManualTimeSlot() {
        let calendar = Calendar.current

        // Get date components
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: manualDate)
        let startComponents = calendar.dateComponents([.hour, .minute], from: manualStartTime)
        let endComponents = calendar.dateComponents([.hour, .minute], from: manualEndTime)

        // Combine date with times
        var fullStartComponents = dateComponents
        fullStartComponents.hour = startComponents.hour
        fullStartComponents.minute = startComponents.minute

        var fullEndComponents = dateComponents
        fullEndComponents.hour = endComponents.hour
        fullEndComponents.minute = endComponents.minute

        guard let finalStart = calendar.date(from: fullStartComponents),
              let finalEnd = calendar.date(from: fullEndComponents),
              finalEnd > finalStart else {
            return
        }

        let newSlot = TimeSlot(start: finalStart, end: finalEnd)

        // Add if not duplicate
        if !selectedSlots.contains(where: { $0.start == newSlot.start && $0.end == newSlot.end }) {
            selectedSlots.append(newSlot)
        }

        showManualEntry = false
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

// MARK: - Manual Time Picker View

struct ManualTimePickerView: View {
    @Binding var selectedDate: Date
    @Binding var startTime: Date
    @Binding var endTime: Date
    let onAdd: () -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var showPresets = false

    enum TimePreset: String, CaseIterable {
        case morning = "Morning (8 AM - 12 PM)"
        case afternoon = "Afternoon (12 PM - 5 PM)"
        case evening = "Evening (5 PM - 8 PM)"
        case businessHours = "Business Hours (9 AM - 5 PM)"

        var hours: (start: Int, end: Int) {
            switch self {
            case .morning: return (8, 12)
            case .afternoon: return (12, 17)
            case .evening: return (17, 20)
            case .businessHours: return (9, 17)
            }
        }
    }

    var body: some View {
        Form {
            Section {
                Text("Choose a date and time range when you're available")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Section("Date") {
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    in: Date()...,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
            }

            Section("Time Range") {
                DatePicker(
                    "Start Time",
                    selection: $startTime,
                    displayedComponents: .hourAndMinute
                )

                DatePicker(
                    "End Time",
                    selection: $endTime,
                    displayedComponents: .hourAndMinute
                )

                if !isValidTimeRange {
                    Text("End time must be after start time")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }

            Section {
                Button {
                    showPresets.toggle()
                } label: {
                    Label("Use Preset Time", systemImage: "clock.fill")
                }
            } header: {
                Text("Quick Presets")
            } footer: {
                Text("Morning, Afternoon, Evening, or Business Hours")
            }

            Section {
                Button {
                    onAdd()
                } label: {
                    Label("Add This Time", systemImage: "plus.circle.fill")
                        .frame(maxWidth: .infinity)
                        .fontWeight(.semibold)
                }
                .disabled(!isValidTimeRange)
            }
        }
        .navigationTitle("Add Custom Time")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
        }
        .confirmationDialog("Choose Time Preset", isPresented: $showPresets, titleVisibility: .visible) {
            ForEach(TimePreset.allCases, id: \.self) { preset in
                Button(preset.rawValue) {
                    applyPreset(preset)
                }
            }
        }
    }

    private var isValidTimeRange: Bool {
        let calendar = Calendar.current
        let startComponents = calendar.dateComponents([.hour, .minute], from: startTime)
        let endComponents = calendar.dateComponents([.hour, .minute], from: endTime)

        guard let startHour = startComponents.hour,
              let startMin = startComponents.minute,
              let endHour = endComponents.hour,
              let endMin = endComponents.minute else {
            return false
        }

        let startTotalMinutes = startHour * 60 + startMin
        let endTotalMinutes = endHour * 60 + endMin

        return endTotalMinutes > startTotalMinutes
    }

    private func applyPreset(_ preset: TimePreset) {
        let calendar = Calendar.current
        let (startHour, endHour) = preset.hours

        startTime = calendar.date(bySettingHour: startHour, minute: 0, second: 0, of: selectedDate)!
        endTime = calendar.date(bySettingHour: endHour, minute: 0, second: 0, of: selectedDate)!
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
