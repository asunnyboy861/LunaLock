import SwiftUI

struct ContactSupportView: View {
    @State private var name = ""
    @State private var email = ""
    @State private var message = ""
    @State private var selectedSubject: SubjectOption = .general
    @State private var customSubject = ""
    @State private var isSubmitting = false
    @State private var showSuccess = false
    @State private var showError = false
    @State private var errorMessage = ""

    private let backendURL = "https://feedback-board.iocompile67692.workers.dev"

    enum SubjectOption: String, CaseIterable {
        case general = "General"
        case feature = "Feature Suggestion"
        case bug = "Bug Report"
        case question = "Usage Question"
        case performance = "Performance Issue"
        case ui = "UI Improvement"
        case other = "Other"

        var icon: String {
            switch self {
            case .general: return "message.fill"
            case .feature: return "lightbulb.fill"
            case .bug: return "ladybug"
            case .question: return "questionmark.circle.fill"
            case .performance: return "gauge.with.dots.needle.67percent"
            case .ui: return "paintbrush.fill"
            case .other: return "ellipsis.circle.fill"
            }
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                subjectSection
                if selectedSubject == .other {
                    customSubjectField
                }
                nameField
                emailField
                messageField
                submitButton
            }
            .padding()
        }
        .navigationTitle("Contact Support")
        .alert("Thank You!", isPresented: $showSuccess) {
            Button("OK") {
                name = ""
                email = ""
                message = ""
                customSubject = ""
                selectedSubject = .general
            }
        } message: {
            Text("Your feedback has been submitted successfully.")
        }
        .alert("Error", isPresented: $showError) {
            Button("OK") {}
        } message: {
            Text(errorMessage)
        }
    }

    private var subjectSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Subject")
                .font(.headline)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(SubjectOption.allCases, id: \.self) { subject in
                    Button(action: { selectedSubject = subject }) {
                        HStack(spacing: 6) {
                            Image(systemName: subject.icon)
                                .font(.caption)
                            Text(subject.rawValue)
                                .font(.caption)
                                .lineLimit(1)
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 8)
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(selectedSubject == subject ? .white : .primary)
                        .background(selectedSubject == subject ? Color(hex: "7C4DFF") : Color(.tertiarySystemFill))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
        }
    }

    private var customSubjectField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Custom Subject")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            TextField("Enter your subject", text: $customSubject)
                .textFieldStyle(.roundedBorder)
        }
    }

    private var nameField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Name")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            TextField("Your name", text: $name)
                .textFieldStyle(.roundedBorder)
        }
    }

    private var emailField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Email")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            TextField("your@email.com", text: $email)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
        }
    }

    private var messageField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Message")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            TextEditor(text: $message)
                .frame(minHeight: 120)
                .padding(4)
                .background(Color(.tertiarySystemFill))
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }

    private var submitButton: some View {
        Button(action: submitFeedback) {
            if isSubmitting {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
            } else {
                Text("Submit")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
        }
        .background(Color(hex: "7C4DFF"))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .disabled(isSubmitting)
    }

    private func submitFeedback() {
        guard !name.isEmpty, !email.isEmpty, !message.isEmpty else {
            errorMessage = "Please fill in all fields."
            showError = true
            return
        }

        let subjectValue = selectedSubject == .other ? customSubject : selectedSubject.rawValue

        guard !subjectValue.isEmpty else {
            errorMessage = "Please enter a custom subject."
            showError = true
            return
        }

        isSubmitting = true

        let body: [String: String] = [
            "name": name,
            "email": email,
            "subject": subjectValue,
            "message": message,
            "app_name": "LunaLock"
        ]

        guard let url = URL(string: "\(backendURL)/api/feedback") else {
            isSubmitting = false
            errorMessage = "Invalid server URL."
            showError = true
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isSubmitting = false
                if let error = error {
                    errorMessage = error.localizedDescription
                    showError = true
                    return
                }
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    showSuccess = true
                } else {
                    errorMessage = "Failed to submit. Please try again."
                    showError = true
                }
            }
        }.resume()
    }
}
