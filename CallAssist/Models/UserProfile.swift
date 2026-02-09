import Foundation

struct UserProfile: Identifiable, Codable, Hashable {
    let id: UUID
    var firstName: String
    var lastName: String
    var email: String
    var phoneNumber: String
    var createdAt: Date

    init(
        id: UUID = UUID(),
        firstName: String = "",
        lastName: String = "",
        email: String = "",
        phoneNumber: String = "",
        createdAt: Date = Date()
    ) {
        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.phoneNumber = phoneNumber
        self.createdAt = createdAt
    }

    var fullName: String {
        "\(firstName) \(lastName)".trimmingCharacters(in: .whitespaces)
    }

    var isComplete: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !lastName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        !phoneNumber.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var hasPrivateRelayEmail: Bool {
        email.hasSuffix("@privaterelay.appleid.com")
    }

    var vapiVariables: [String: String] {
        [
            "customerFirstName": firstName,
            "customerLastName": lastName,
            "customerFullName": fullName,
            "customerEmail": email,
            "customerPhone": phoneNumber,
        ]
    }
}

@MainActor
class UserProfileManager: ObservableObject {
    @Published var profiles: [UserProfile] = []
    @Published var activeProfileId: UUID?

    var hasCompleteProfile: Bool {
        profiles.contains { $0.isComplete }
    }

    var activeProfile: UserProfile? {
        guard let id = activeProfileId else { return profiles.first }
        return profiles.first { $0.id == id }
    }

    private var fileURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("user_profiles.json")
    }

    init() {
        load()
    }

    func addProfile(_ profile: UserProfile) {
        profiles.append(profile)
        if profiles.count == 1 {
            activeProfileId = profile.id
        }
        save()
    }

    func updateProfile(_ profile: UserProfile) {
        if let index = profiles.firstIndex(where: { $0.id == profile.id }) {
            profiles[index] = profile
            save()
        }
    }

    func deleteProfile(_ profile: UserProfile) {
        profiles.removeAll { $0.id == profile.id }
        if activeProfileId == profile.id {
            activeProfileId = profiles.first?.id
        }
        save()
    }

    func setActive(_ profile: UserProfile) {
        activeProfileId = profile.id
        save()
    }

    func save() {
        do {
            let payload = ProfileStorage(profiles: profiles, activeProfileId: activeProfileId)
            let data = try JSONEncoder().encode(payload)
            try data.write(to: fileURL)
        } catch {
            print("Failed to save profiles: \(error)")
        }
    }

    private func load() {
        do {
            let data = try Data(contentsOf: fileURL)
            let payload = try JSONDecoder().decode(ProfileStorage.self, from: data)
            profiles = payload.profiles
            activeProfileId = payload.activeProfileId
        } catch {
            profiles = []
            activeProfileId = nil
        }
    }
}

private struct ProfileStorage: Codable {
    let profiles: [UserProfile]
    let activeProfileId: UUID?
}
