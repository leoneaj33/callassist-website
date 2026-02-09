import Foundation

struct AppConfig {
    static let shared = AppConfig()

    let vapiApiKey: String
    let vapiAssistantId: String
    let vapiPhoneNumberId: String
    let googleClientId: String
    let microsoftClientId: String

    private init() {
        // Load from Secrets.plist (gitignored)
        var secrets: [String: Any] = [:]
        if let url = Bundle.main.url(forResource: "Secrets", withExtension: "plist"),
           let data = try? Data(contentsOf: url),
           let plist = try? PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any] {
            secrets = plist
        }

        vapiApiKey = secrets["VAPI_API_KEY"] as? String ?? ""
        vapiAssistantId = secrets["VAPI_ASSISTANT_ID"] as? String ?? ""
        vapiPhoneNumberId = secrets["VAPI_PHONE_NUMBER_ID"] as? String ?? ""
        googleClientId = secrets["GOOGLE_CLIENT_ID"] as? String ?? ""
        microsoftClientId = secrets["MICROSOFT_CLIENT_ID"] as? String ?? ""

        if vapiApiKey.isEmpty {
            print("⚠️ VAPI_API_KEY not found in Secrets.plist. Create CallAssist/Secrets.plist with your keys.")
        } else {
            print("✅ Vapi config loaded — API key: \(vapiApiKey.prefix(8))..., Assistant: \(vapiAssistantId.prefix(8))..., Phone: \(vapiPhoneNumberId.prefix(8))...")
        }
    }
}
