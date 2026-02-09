import SwiftUI

struct ProfileCompletionView: View {
    let ssoUserInfo: SSOUserInfo?

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

    var body: some View {
        Form {
            if ssoUserInfo != nil {
                Section {
                    Label("We pre-filled your info from sign-in. Please verify and add your phone number.",
                          systemImage: "checkmark.circle")
                        .font(.subheadline)
                        .foregroundStyle(.green)
                }
            }

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
                Text("The AI assistant will use this name when speaking to the business.")
            }

            Section {
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)

                if ssoUserInfo?.isApplePrivateEmail == true || email.hasSuffix("@privaterelay.appleid.com") {
                    Label("This is an Apple private relay address. Businesses may not be able to reach you at this email. Consider using your real email instead.",
                          systemImage: "exclamationmark.triangle")
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            } header: {
                Text("Email (Required)")
            } footer: {
                Text("Provided to the business for appointment confirmations.")
            }

            Section {
                TextField("Phone Number", text: $phoneNumber)
                    .textContentType(.telephoneNumber)
                    .keyboardType(.phonePad)
            } header: {
                Text("Phone (Required)")
            } footer: {
                Text("Used for callback purposes and to receive appointment confirmation texts.")
            }

            Section {
                Button {
                    saveAndContinue()
                } label: {
                    HStack {
                        Spacer()
                        Text("Continue")
                            .fontWeight(.semibold)
                        Spacer()
                    }
                }
                .disabled(!isValid)
            }
        }
        .navigationTitle("Your Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Back") { dismiss() }
            }
        }
        .onAppear {
            if let info = ssoUserInfo {
                firstName = info.firstName
                lastName = info.lastName
                email = info.email
            }
        }
    }

    private func saveAndContinue() {
        let profile = UserProfile(
            firstName: firstName.trimmingCharacters(in: .whitespaces),
            lastName: lastName.trimmingCharacters(in: .whitespaces),
            email: email.trimmingCharacters(in: .whitespaces),
            phoneNumber: phoneNumber.trimmingCharacters(in: .whitespaces)
        )
        profileManager.addProfile(profile)
        dismiss()
    }
}

#Preview {
    NavigationStack {
        ProfileCompletionView(ssoUserInfo: nil)
            .environmentObject(UserProfileManager())
    }
}
