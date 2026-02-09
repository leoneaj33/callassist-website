import SwiftUI
import GoogleSignIn

@main
struct CallAssistApp: App {
    @StateObject private var calendarService = CalendarService()
    @StateObject private var requestStore = RequestStore()
    @StateObject private var profileManager = UserProfileManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(calendarService)
                .environmentObject(requestStore)
                .environmentObject(profileManager)
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
    }
}

@MainActor
class RequestStore: ObservableObject {
    @Published var requests: [AppointmentRequest] = []

    private var fileURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("requests.json")
    }

    init() {
        load()
    }

    func add(_ request: AppointmentRequest) {
        requests.insert(request, at: 0)
        save()
    }

    func update(_ request: AppointmentRequest) {
        if let index = requests.firstIndex(where: { $0.id == request.id }) {
            requests[index] = request
            save()
        }
    }

    func delete(_ request: AppointmentRequest) {
        requests.removeAll { $0.id == request.id }
        save()
    }

    func delete(at offsets: IndexSet) {
        requests.remove(atOffsets: offsets)
        save()
    }

    func save() {
        do {
            let data = try JSONEncoder().encode(requests)
            try data.write(to: fileURL)
        } catch {
            print("Failed to save requests: \(error)")
        }
    }

    func load() {
        do {
            let data = try Data(contentsOf: fileURL)
            requests = try JSONDecoder().decode([AppointmentRequest].self, from: data)
        } catch {
            requests = []
        }
    }
}
