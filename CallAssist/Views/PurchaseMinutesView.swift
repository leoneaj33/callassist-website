import SwiftUI
import StoreKit

struct PurchaseMinutesView: View {
    @StateObject private var storeKit = StoreKitManager.shared
    @ObservedObject private var minutesManager = MinutesManager.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Current Balance Card
                balanceCard

                // Available Packages
                VStack(alignment: .leading, spacing: 12) {
                    Text("Buy Minutes")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)

                    if storeKit.products.isEmpty {
                        ProgressView("Loading packages...")
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        ForEach(storeKit.products, id: \.id) { product in
                            if let package = MinutePackage.allPackages.first(where: { $0.id == product.id }) {
                                PackageCard(
                                    package: package,
                                    product: product,
                                    isPurchasing: storeKit.isPurchasing
                                ) {
                                    purchasePackage(product)
                                }
                            }
                        }
                    }
                }

                // Error Message
                if let error = storeKit.purchaseError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.horizontal)
                }

                // Restore Purchases
                Button {
                    Task {
                        await storeKit.restorePurchases()
                    }
                } label: {
                    Text("Restore Purchases")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 8)

                // Terms
                VStack(spacing: 8) {
                    Text("• Minutes expire 12 months after purchase")
                    Text("• Prices range from $0.35-0.60 per minute")
                    Text("• Unused minutes are non-refundable")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding()
            }
            .padding(.vertical)
        }
        .navigationTitle("Buy Minutes")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") { dismiss() }
            }
        }
    }

    private var balanceCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Balance")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text("\(minutesManager.balance.remainingMinutesInt)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.accentColor)

                    Text("minutes remaining")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "clock.fill")
                    .font(.system(size: 60))
                    .foregroundColor(Color.accentColor.opacity(0.2))
            }

            if minutesManager.checkExpiringMinutes() {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                    Text("\(Int(minutesManager.balance.expiringMinutes)) minutes expiring in 30 days")
                }
                .font(.caption)
                .foregroundStyle(.orange)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding(.horizontal)
    }

    private func purchasePackage(_ product: Product) {
        Task {
            do {
                try await storeKit.purchase(product)
                dismiss()
            } catch {
                // Error already set in storeKit.purchaseError
            }
        }
    }
}

struct PackageCard: View {
    let package: MinutePackage
    let product: Product
    let isPurchasing: Bool
    let onPurchase: () -> Void

    var body: some View {
        Button(action: onPurchase) {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(package.name)
                            .font(.headline)

                        if package.bestValue {
                            Text("BEST VALUE")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.accentColor)
                                .foregroundStyle(.white)
                                .clipShape(Capsule())
                        }
                    }

                    Text("\(package.minutes) minutes")
                        .font(.title3)
                        .fontWeight(.semibold)

                    Text(package.valueText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(product.displayPrice)
                        .font(.title3)
                        .fontWeight(.bold)

                    if isPurchasing {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.title2)
                            .foregroundColor(.accentColor)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(package.bestValue ? Color.accentColor : Color.clear, lineWidth: 2)
            )
            .padding(.horizontal)
        }
        .disabled(isPurchasing)
        .buttonStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        PurchaseMinutesView()
    }
}
