import SwiftUI

struct PrivacyPromiseView: View {
    @AppStorage("lunalock.onboarding.complete") private var onboardingComplete = false
    @State private var showApp = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "lock.shield.fill")
                .font(.system(size: 72))
                .foregroundStyle(Color(hex: "7C4DFF"))

            Text("Your Data Stays\nOn Your Device")
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            VStack(alignment: .leading, spacing: 16) {
                promiseRow(icon: "icloud.slash", text: "No cloud sync — ever")
                promiseRow(icon: "eye.slash", text: "No data collection or tracking")
                promiseRow(icon: "server.rack", text: "No accounts or sign-ups")
                promiseRow(icon: "trash", text: "Delete everything anytime")
            }
            .padding(.horizontal, 32)

            Spacer()

            Button(action: {
                onboardingComplete = true
                showApp = true
            }) {
                Text("I Trust This App")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "7C4DFF"))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 32)
            .padding(.bottom, 40)
        }
        .background(Color(.systemBackground))
    }

    private func promiseRow(icon: String, text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Color(hex: "7C4DFF"))
                .frame(width: 28)
            Text(text)
                .font(.body)
        }
    }
}
