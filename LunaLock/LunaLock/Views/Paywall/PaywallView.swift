import SwiftUI

struct PaywallView: View {
    @StateObject private var purchaseManager = PurchaseManager.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    Image(systemName: "lock.open.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(Color(hex: "7C4DFF"))

                    Text("LunaLock Pro")
                        .font(.largeTitle)
                        .fontWeight(.bold)

                    Text("One purchase. Forever yours.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    VStack(alignment: .leading, spacing: 14) {
                        featureRow(icon: "chart.bar.fill", text: "Trend charts & insights")
                        featureRow(icon: "square.and.arrow.up", text: "PDF & JSON data export")
                        featureRow(icon: "widget.small", text: "Home screen widget")
                        featureRow(icon: "paintpalette.fill", text: "5 color themes")
                        featureRow(icon: "heart.text.square.fill", text: "HealthKit integration")
                        featureRow(icon: "doc.text.fill", text: "Monthly cycle reports")
                        featureRow(icon: "infinity", text: "All future updates included")
                    }
                    .padding()
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding(.horizontal)

                    VStack(spacing: 12) {
                        Button(action: purchase) {
                            if purchaseManager.isLoading {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .tint(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            } else {
                                Text("$3.99 — Buy Once, Own Forever")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }
                        }
                        .background(Color(hex: "7C4DFF"))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .padding(.horizontal)

                        Button("Restore Purchases") {
                            Task { await purchaseManager.restorePurchases() }
                        }
                        .font(.subheadline)
                        .foregroundStyle(Color(hex: "7C4DFF"))
                    }

                    HStack(spacing: 16) {
                        Link("Privacy Policy", destination: URL(string: "https://asunnyboy861.github.io/LunaLock/privacy.html")!)
                        Link("Terms of Use", destination: URL(string: "https://asunnyboy861.github.io/LunaLock/terms.html")!)
                    }
                    .font(.caption2)
                    .foregroundStyle(Color.accentColor)
                    .padding(.bottom, 20)
                }
                .padding(.top, 20)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private func featureRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color(hex: "7C4DFF"))
                .frame(width: 28)
            Text(text)
                .font(.subheadline)
            Spacer()
        }
    }

    private func purchase() {
        Task {
            let success = await purchaseManager.purchase()
            if success {
                dismiss()
            }
        }
    }
}
