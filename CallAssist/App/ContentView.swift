import SwiftUI

struct ContentView: View {
    @EnvironmentObject var calendarService: CalendarService
    @EnvironmentObject var profileManager: UserProfileManager

    var body: some View {
        Group {
            if !profileManager.hasCompleteProfile {
                ProfileSetupView()
            } else if !calendarService.isCalendarLinked {
                CalendarSetupView()
            } else {
                MainTabView()
            }
        }
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                NewRequestView()
            }
            .tabItem {
                Label("New Call", systemImage: "phone.badge.plus")
            }

            NavigationStack {
                HistoryView()
            }
            .tabItem {
                Label("History", systemImage: "clock.arrow.circlepath")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
        }
    }
}

struct SettingsView: View {
    @EnvironmentObject var calendarService: CalendarService
    @EnvironmentObject var profileManager: UserProfileManager
    @State private var showAddProfile = false
    @State private var editingProfile: UserProfile?

    var body: some View {
        List {
            Section {
                if let active = profileManager.activeProfile {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.title)
                            .foregroundStyle(Color.accentColor)
                        VStack(alignment: .leading) {
                            Text(active.fullName.isEmpty ? "No Name Set" : active.fullName)
                                .font(.headline)
                            if !active.email.isEmpty {
                                Text(active.email)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    Button("Edit Profile") {
                        editingProfile = active
                    }
                } else {
                    Text("No profile set up")
                        .foregroundStyle(.secondary)
                    Button("Create Profile") {
                        showAddProfile = true
                    }
                }
            } header: {
                Text("Active Profile")
            } footer: {
                Text("Your name and contact info are sent to the AI assistant so it can provide them to the business during the call.")
            }

            if profileManager.profiles.count > 1 {
                Section("All Profiles") {
                    ForEach(profileManager.profiles) { profile in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(profile.fullName)
                                    .font(.subheadline)
                                if !profile.phoneNumber.isEmpty {
                                    Text(profile.phoneNumber)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }

                            Spacer()

                            if profile.id == profileManager.activeProfileId {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color.accentColor)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            profileManager.setActive(profile)
                        }
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                profileManager.deleteProfile(profile)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }

                            Button {
                                editingProfile = profile
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.orange)
                        }
                    }
                }
            }

            Section {
                Button {
                    showAddProfile = true
                } label: {
                    Label("Add Another Profile", systemImage: "person.badge.plus")
                }
            }

            Section("Calendar") {
                HStack {
                    Text("Provider")
                    Spacer()
                    Text(calendarService.activeProvider?.displayName ?? "None")
                        .foregroundStyle(.secondary)
                }

                Button("Change Calendar Provider") {
                    calendarService.unlinkCalendar()
                }
                .foregroundStyle(.red)
            }

            Section("About") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $showAddProfile) {
            NavigationStack {
                ProfileEditView(mode: .create)
            }
        }
        .sheet(item: $editingProfile) { profile in
            NavigationStack {
                ProfileEditView(mode: .edit(profile))
            }
        }
    }
}

struct ProfileEditView: View {
    enum Mode: Identifiable {
        case create
        case edit(UserProfile)

        var id: String {
            switch self {
            case .create: return "create"
            case .edit(let p): return p.id.uuidString
            }
        }
    }

    let mode: Mode
    @EnvironmentObject var profileManager: UserProfileManager
    @Environment(\.dismiss) private var dismiss

    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var phoneNumber = ""

    private var isValid: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        !phoneNumber.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private var title: String {
        switch mode {
        case .create: return "New Profile"
        case .edit: return "Edit Profile"
        }
    }

    var body: some View {
        Form {
            Section {
                TextField("First Name", text: $firstName)
                    .textContentType(.givenName)
                    .autocorrectionDisabled()

                TextField("Last Name", text: $lastName)
                    .textContentType(.familyName)
                    .autocorrectionDisabled()
            } header: {
                Text("Name")
            } footer: {
                Text("Enter the exact spelling of your name. The AI will use this when speaking to the business.")
            }

            Section {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)

                TextField("Phone Number", text: $phoneNumber)
                    .textContentType(.telephoneNumber)
                    .keyboardType(.phonePad)
            } header: {
                Text("Contact Info (Required)")
            } footer: {
                Text("Used for callback purposes and to receive appointment confirmation texts.")
            }

            Section {
                Button {
                    saveProfile()
                } label: {
                    HStack {
                        Spacer()
                        Text("Save")
                            .fontWeight(.semibold)
                        Spacer()
                    }
                }
                .disabled(!isValid)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") { dismiss() }
            }
        }
        .onAppear {
            if case .edit(let profile) = mode {
                firstName = profile.firstName
                lastName = profile.lastName
                email = profile.email
                phoneNumber = profile.phoneNumber
            }
        }
    }

    private func saveProfile() {
        switch mode {
        case .create:
            let profile = UserProfile(
                firstName: firstName.trimmingCharacters(in: .whitespaces),
                lastName: lastName.trimmingCharacters(in: .whitespaces),
                email: email.trimmingCharacters(in: .whitespaces),
                phoneNumber: phoneNumber.trimmingCharacters(in: .whitespaces)
            )
            profileManager.addProfile(profile)
        case .edit(let existing):
            var updated = existing
            updated.firstName = firstName.trimmingCharacters(in: .whitespaces)
            updated.lastName = lastName.trimmingCharacters(in: .whitespaces)
            updated.email = email.trimmingCharacters(in: .whitespaces)
            updated.phoneNumber = phoneNumber.trimmingCharacters(in: .whitespaces)
            profileManager.updateProfile(updated)
        }
        dismiss()
    }
}

#Preview {
    ContentView()
        .environmentObject(CalendarService())
        .environmentObject(RequestStore())
        .environmentObject(UserProfileManager())
}
