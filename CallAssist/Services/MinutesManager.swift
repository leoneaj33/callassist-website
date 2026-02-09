import Foundation
import SwiftUI

@MainActor
class MinutesManager: ObservableObject {
    static let shared = MinutesManager()

    @Published private(set) var balance: MinuteBalance

    private let balanceKey = "minuteBalance"

    private init() {
        if let data = UserDefaults.standard.data(forKey: balanceKey),
           let decoded = try? JSONDecoder().decode(MinuteBalance.self, from: data) {
            self.balance = decoded
        } else {
            // New users get 5 free trial minutes
            var newBalance = MinuteBalance()
            newBalance.addPurchase(minutes: 5, purchaseDate: Date())
            self.balance = newBalance
            save()
        }
    }

    func addMinutes(_ minutes: Int) {
        balance.addPurchase(minutes: minutes)
        save()
    }

    func deductMinutes(_ minutes: Double) {
        guard balance.hasMinutes else { return }
        balance.deductMinutes(minutes)
        balance.removeExpiredPurchases() // Clean up expired purchases
        save()
    }

    func hasEnoughMinutes(_ minutes: Double) -> Bool {
        balance.remainingMinutes >= minutes
    }

    func checkExpiringMinutes() -> Bool {
        balance.expiringMinutes > 0
    }

    private func save() {
        if let encoded = try? JSONEncoder().encode(balance) {
            UserDefaults.standard.set(encoded, forKey: balanceKey)
        }
    }
}
