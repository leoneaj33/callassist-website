import Foundation
import StoreKit

class StoreKitManager: ObservableObject {
    static let shared = StoreKitManager()

    @Published var products: [Product] = []
    @Published var isPurchasing = false
    @Published var purchaseError: String?

    private var transactionListener: Task<Void, Never>?

    private init() {
        transactionListener = observeTransactionUpdates()
        Task {
            await loadProducts()
        }
    }

    deinit {
        transactionListener?.cancel()
    }

    // MARK: - Product Loading

    @MainActor
    func loadProducts() async {
        do {
            let productIDs = MinutePackage.allPackages.map { $0.id }
            products = try await Product.products(for: productIDs)
                .sorted { $0.price < $1.price }
        } catch {
            print("[StoreKit] Failed to load products: \(error)")
            purchaseError = "Failed to load products. Please try again."
        }
    }

    // MARK: - Purchasing

    @MainActor
    func purchase(_ product: Product) async throws {
        isPurchasing = true
        purchaseError = nil

        defer {
            isPurchasing = false
        }

        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try Self.checkVerified(verification)

            // Find the package and add minutes
            if let package = MinutePackage.allPackages.first(where: { $0.id == transaction.productID }) {
                MinutesManager.shared.addMinutes(package.minutes)
            }

            await transaction.finish()
            return

        case .userCancelled:
            purchaseError = "Purchase cancelled"
            throw StoreKitError.userCancelled

        case .pending:
            purchaseError = "Purchase is pending approval"
            throw StoreKitError.pending

        @unknown default:
            purchaseError = "Unknown error occurred"
            throw StoreKitError.unknown
        }
    }

    // MARK: - Restore Purchases

    @MainActor
    func restorePurchases() async {
        do {
            try await AppStore.sync()
        } catch {
            purchaseError = "Failed to restore purchases: \(error.localizedDescription)"
        }
    }

    // MARK: - Transaction Verification

    private static func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreKitError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    // MARK: - Transaction Listener

    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task.detached {
            for await verificationResult in Transaction.updates {
                do {
                    let transaction = try Self.checkVerified(verificationResult)

                    // Find package and add minutes
                    if let package = MinutePackage.allPackages.first(where: { $0.id == transaction.productID }) {
                        await MainActor.run {
                            MinutesManager.shared.addMinutes(package.minutes)
                        }
                    }

                    await transaction.finish()
                } catch {
                    print("[StoreKit] Transaction verification failed: \(error)")
                }
            }
        }
    }
}

// MARK: - Errors

enum StoreKitError: Error, LocalizedError {
    case failedVerification
    case userCancelled
    case pending
    case unknown

    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "Purchase verification failed"
        case .userCancelled:
            return "Purchase cancelled"
        case .pending:
            return "Purchase is pending approval"
        case .unknown:
            return "An unknown error occurred"
        }
    }
}
