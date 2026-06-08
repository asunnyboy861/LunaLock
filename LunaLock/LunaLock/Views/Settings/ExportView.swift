import SwiftUI

struct ExportView: View {
    @StateObject private var purchaseManager = PurchaseManager.shared
    @State private var showShareSheet = false
    @State private var exportFileURL: URL?
    @State private var exportFormat: ExportFormat = .pdf
    @State private var showPaywall = false

    enum ExportFormat {
        case pdf, json
    }

    private let dataStore = DataStore.shared

    var body: some View {
        NavigationStack {
            Group {
                if purchaseManager.isPro {
                    proContent
                } else {
                    lockedContent
                }
            }
            .navigationTitle("Export")
            .sheet(isPresented: $showShareSheet) {
                if let url = exportFileURL {
                    ShareSheet(activityItems: [url])
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }

    private var proContent: some View {
        VStack(spacing: 24) {
            Picker("Format", selection: $exportFormat) {
                Text("PDF (for doctors)").tag(ExportFormat.pdf)
                Text("JSON (for other apps)").tag(ExportFormat.json)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            Button(action: exportData) {
                Label("Export Data", systemImage: "square.and.arrow.up")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "7C4DFF"))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding(.top, 32)
    }

    private var lockedContent: some View {
        VStack(spacing: 32) {
            Spacer()
            Image(systemName: "square.and.arrow.up")
                .font(.system(size: 56))
                .foregroundStyle(Color(hex: "7C4DFF"))
            Text("Data Export")
                .font(.title2)
                .fontWeight(.bold)
            Text("Export your period data as PDF for doctor visits or JSON for other apps.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Button(action: { showPaywall = true }) {
                Text("Upgrade to Pro")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "7C4DFF"))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 32)
            Spacer()
        }
    }

    private func exportData() {
        switch exportFormat {
        case .pdf:
            exportFileURL = ExportManager.shared.exportAsPDF(records: Array(dataStore.records.values))
        case .json:
            exportFileURL = ExportManager.shared.exportAsJSON(records: Array(dataStore.records.values))
        }
        if exportFileURL != nil {
            showShareSheet = true
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
