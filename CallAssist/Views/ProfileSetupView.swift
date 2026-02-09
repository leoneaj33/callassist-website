import SwiftUI
import AuthenticationServices

struct ProfileSetupView: View {
    @EnvironmentObject var profileManager: UserProfileManager

    @State private var ssoUserInfo: SSOUserInfo?
    @State private var showProfileForm = false
    @State private var errorMessage: String?
    @State private var isLoading = false

    private let authService = AuthenticationService()

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()

                Image(systemName: "person.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(Color.accentColor)

                VStack(spacing: 8) {
                    Text("Set Up Your Profile")
                        .font(.title)
                        .fontWeight(.bold)

                    Text("Your name, email, and phone number are shared with the AI assistant so it can provide them to businesses during calls.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                VStack(spacing: 12) {
                    SignInWithAppleButton(.signIn) { request in
                        request.requestedScopes = [.fullName, .email]
                    } onCompletion: { result in
                        handleAppleSignIn(result)
                    }
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 50)

                    Button {
                        signInWithGoogle()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "g.circle.fill")
                                .font(.title3)
                            Text("Sign in with Google")
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)
                .disabled(isLoading)

                HStack {
                    Rectangle().frame(height: 1).foregroundStyle(.secondary.opacity(0.3))
                    Text("or").foregroundStyle(.secondary).font(.subheadline)
                    Rectangle().frame(height: 1).foregroundStyle(.secondary.opacity(0.3))
                }
                .padding(.horizontal, 40)

                Button("Set up manually") {
                    ssoUserInfo = nil
                    showProfileForm = true
                }

                if isLoading {
                    ProgressView()
                }

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
            .sheet(isPresented: $showProfileForm) {
                NavigationStack {
                    ProfileCompletionView(ssoUserInfo: ssoUserInfo)
                }
            }
        }
    }

    private func handleAppleSignIn(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let auth):
            guard let credential = auth.credential as? ASAuthorizationAppleIDCredential else { return }

            let firstName = credential.fullName?.givenName ?? ""
            let lastName = credential.fullName?.familyName ?? ""
            let email = credential.email ?? ""
            let isPrivate = email.hasSuffix("@privaterelay.appleid.com")

            ssoUserInfo = SSOUserInfo(
                firstName: firstName,
                lastName: lastName,
                email: email,
                isApplePrivateEmail: isPrivate
            )
            showProfileForm = true

        case .failure(let error):
            if (error as NSError).code != ASAuthorizationError.canceled.rawValue {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func signInWithGoogle() {
        isLoading = true
        errorMessage = nil
        Task {
            do {
                let info = try await authService.signInWithGoogle()
                ssoUserInfo = info
                showProfileForm = true
            } catch let error as SSOError {
                if case .cancelled = error { /* user cancelled, no message */ }
                else { errorMessage = error.localizedDescription }
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}

#Preview {
    ProfileSetupView()
        .environmentObject(UserProfileManager())
}
