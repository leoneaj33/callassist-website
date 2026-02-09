import Foundation
import GoogleSignIn
import UIKit

struct SSOUserInfo {
    let firstName: String
    let lastName: String
    let email: String
    let isApplePrivateEmail: Bool
}

enum SSOError: LocalizedError {
    case cancelled
    case failed(String)
    case googleNotConfigured

    var errorDescription: String? {
        switch self {
        case .cancelled: return "Sign in was cancelled."
        case .failed(let msg): return msg
        case .googleNotConfigured: return "Google Sign-In is not configured. Add GOOGLE_CLIENT_ID to Secrets.plist."
        }
    }
}

@MainActor
class AuthenticationService {

    func signInWithGoogle() async throws -> SSOUserInfo {
        let clientID = AppConfig.shared.googleClientId
        guard !clientID.isEmpty else {
            throw SSOError.googleNotConfigured
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else {
            throw SSOError.failed("Could not find root view controller.")
        }

        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootVC)
        let profile = result.user.profile

        return SSOUserInfo(
            firstName: profile?.givenName ?? "",
            lastName: profile?.familyName ?? "",
            email: profile?.email ?? "",
            isApplePrivateEmail: false
        )
    }
}
