import Foundation

// MARK: - Minute Packages

struct MinutePackage: Identifiable, Codable {
    let id: String // Product ID from App Store Connect
    let name: String
    let minutes: Int
    let displayPrice: String
    let valueText: String
    let bestValue: Bool

    static let allPackages: [MinutePackage] = [
        MinutePackage(
            id: "com.callassist.minutes.25",
            name: "Starter Pack",
            minutes: 25,
            displayPrice: "$14.99",
            valueText: "$0.60/min",
            bestValue: false
        ),
        MinutePackage(
            id: "com.callassist.minutes.100",
            name: "Growth Pack",
            minutes: 100,
            displayPrice: "$49.99",
            valueText: "$0.50/min • Save 17%",
            bestValue: false
        ),
        MinutePackage(
            id: "com.callassist.minutes.250",
            name: "Pro Pack",
            minutes: 250,
            displayPrice: "$99.99",
            valueText: "$0.40/min • Save 33%",
            bestValue: true
        ),
        MinutePackage(
            id: "com.callassist.minutes.500",
            name: "Business Pack",
            minutes: 500,
            displayPrice: "$174.99",
            valueText: "$0.35/min • Save 42%",
            bestValue: false
        )
    ]
}

// MARK: - Minute Balance

struct MinuteBalance: Codable {
    var purchases: [MinutePurchase] = []

    var totalMinutes: Double {
        purchases.reduce(0) { $0 + Double($1.minutes) }
    }

    var usedMinutes: Double {
        purchases.reduce(0) { $0 + $1.used }
    }

    var remainingMinutes: Double {
        totalMinutes - usedMinutes
    }

    var remainingMinutesInt: Int {
        Int(max(0, remainingMinutes))
    }

    var hasMinutes: Bool {
        remainingMinutes > 0
    }

    var expiringMinutes: Double {
        let thirtyDaysFromNow = Calendar.current.date(byAdding: .day, value: 30, to: Date())!
        return purchases
            .filter { $0.expiresAt < thirtyDaysFromNow && $0.remainingMinutes > 0 }
            .reduce(0) { $0 + $1.remainingMinutes }
    }

    mutating func addPurchase(minutes: Int, purchaseDate: Date = Date()) {
        let expiresAt = Calendar.current.date(byAdding: .month, value: 12, to: purchaseDate)!
        let purchase = MinutePurchase(
            id: UUID(),
            minutes: minutes,
            purchasedAt: purchaseDate,
            expiresAt: expiresAt,
            used: 0
        )
        purchases.append(purchase)
        purchases.sort { $0.purchasedAt < $1.purchasedAt } // Oldest first (FIFO)
    }

    mutating func deductMinutes(_ minutes: Double) {
        var remaining = minutes

        // FIFO deduction - oldest purchases first, skip expired
        for i in 0..<purchases.count {
            guard remaining > 0 else { break }

            // Skip expired purchases
            guard !purchases[i].isExpired else { continue }

            let available = purchases[i].remainingMinutes
            if available > 0 {
                let deduct = min(available, remaining)
                purchases[i].used += deduct
                remaining -= deduct
            }
        }
    }

    mutating func removeExpiredPurchases() {
        purchases.removeAll { $0.isExpired && $0.remainingMinutes == 0 }
    }
}

// MARK: - Minute Purchase

struct MinutePurchase: Codable, Identifiable {
    let id: UUID
    let minutes: Int
    let purchasedAt: Date
    let expiresAt: Date
    var used: Double

    var remainingMinutes: Double {
        // Return 0 if expired, otherwise return unused minutes
        guard !isExpired else { return 0 }
        return max(0, Double(minutes) - used)
    }

    var isExpired: Bool {
        Date() > expiresAt
    }
}
