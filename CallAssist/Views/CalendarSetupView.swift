import SwiftUI

struct CalendarSetupView: View {
    @EnvironmentObject var calendarService: CalendarService
    @State private var isLinking = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 64))
                    .foregroundStyle(Color.accentColor)

                VStack(spacing: 8) {
                    Text("Link Your Calendar")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("Call Assist checks your calendar to find available times before making calls.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                VStack(spacing: 12) {
                    ForEach(CalendarProviderType.allCases) { provider in
                        Button {
                            linkProvider(provider)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: provider.iconName)
                                    .font(.title3)
                                    .frame(width: 32)

                                VStack(alignment: .leading) {
                                    Text(provider.displayName)
                                        .fontWeight(.medium)
                                    Text(provider.description)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                if isLinking {
                                    ProgressView()
                                } else {
                                    Image(systemName: "chevron.right")
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                        .disabled(isLinking)
                    }
                }
                .padding(.horizontal)

                if let error = errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                }

                Spacer()
                Spacer()
            }
            .navigationTitle("Welcome")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func linkProvider(_ provider: CalendarProviderType) {
        isLinking = true
        errorMessage = nil

        Task {
            do {
                try await calendarService.linkCalendar(provider: provider)
            } catch {
                errorMessage = error.localizedDescription
            }
            isLinking = false
        }
    }
}

#Preview {
    CalendarSetupView()
        .environmentObject(CalendarService())
}
