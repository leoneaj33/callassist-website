import SwiftUI

struct MinutesBalanceWidget: View {
    @ObservedObject var minutesManager: MinutesManager
    @State private var showPurchaseSheet = false

    var body: some View {
        Button {
            showPurchaseSheet = true
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "clock.fill")
                    .font(.caption)

                VStack(alignment: .leading, spacing: 1) {
                    Text("\(minutesManager.balance.remainingMinutesInt)")
                        .font(.caption)
                        .fontWeight(.semibold)

                    if minutesManager.balance.remainingMinutes < 10 {
                        Text("Low")
                            .font(.caption2)
                            .foregroundStyle(balanceColor)
                    }
                }

                Image(systemName: "plus.circle.fill")
                    .font(.caption2)
            }
            .foregroundStyle(balanceColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(balanceColor.opacity(0.1))
            .clipShape(Capsule())
        }
        .sheet(isPresented: $showPurchaseSheet) {
            NavigationStack {
                PurchaseMinutesView()
            }
        }
    }

    private var balanceColor: Color {
        let remaining = minutesManager.balance.remainingMinutes
        if remaining < 5 { return .red }
        else if remaining < 10 { return .orange }
        else { return .accentColor }
    }
}
