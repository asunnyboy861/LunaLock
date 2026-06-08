import SwiftUI

struct DayDetailView: View {
    let date: Date
    @Environment(\.dismiss) private var dismiss
    @State private var selectedFlow: FlowLevel?
    @State private var selectedSymptoms: Set<SymptomType> = []
    @State private var selectedMood: MoodType?
    @State private var isPeriodStart = false
    @State private var isPeriodEnd = false

    private let dataStore = DataStore.shared
    private var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateStyle = .long
        return f
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    periodToggleSection
                    flowSection
                    symptomsSection
                    moodSection
                }
                .padding()
            }
            .navigationTitle(dateFormatter.string(from: date))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveLog()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear { loadExistingRecord() }
        }
    }

    private var periodToggleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Period")
                .font(.headline)
            HStack(spacing: 16) {
                Toggle("Period Start", isOn: $isPeriodStart)
                Toggle("Period End", isOn: $isPeriodEnd)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var flowSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Flow Level")
                .font(.headline)
            HStack(spacing: 8) {
                ForEach(FlowLevel.allCases, id: \.self) { flow in
                    Button(action: { selectedFlow = selectedFlow == flow ? nil : flow }) {
                        Text(flow.label)
                            .font(.subheadline)
                            .fontWeight(selectedFlow == flow ? .bold : .regular)
                            .foregroundStyle(selectedFlow == flow ? .white : .primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(selectedFlow == flow ? Color(hex: "E91E63") : Color(.tertiarySystemFill))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
        }
    }

    private var symptomsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Symptoms")
                .font(.headline)
            FlowLayout(spacing: 8) {
                ForEach(SymptomType.allCases, id: \.self) { symptom in
                    Button(action: {
                        if selectedSymptoms.contains(symptom) {
                            selectedSymptoms.remove(symptom)
                        } else {
                            selectedSymptoms.insert(symptom)
                        }
                    }) {
                        Label(symptom.rawValue, systemImage: symptom.icon)
                            .font(.subheadline)
                            .fontWeight(selectedSymptoms.contains(symptom) ? .bold : .regular)
                            .foregroundStyle(selectedSymptoms.contains(symptom) ? .white : .primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(selectedSymptoms.contains(symptom) ? Color(hex: "7C4DFF") : Color(.tertiarySystemFill))
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }

    private var moodSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mood")
                .font(.headline)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(MoodType.allCases, id: \.self) { mood in
                        Button(action: { selectedMood = selectedMood == mood ? nil : mood }) {
                            VStack(spacing: 6) {
                                Image(systemName: mood.icon)
                                    .font(.title2)
                                Text(mood.rawValue)
                                    .font(.caption)
                            }
                            .foregroundStyle(selectedMood == mood ? .white : .primary)
                            .frame(width: 72, height: 72)
                            .background(selectedMood == mood ? Color(hex: "7C4DFF") : Color(.tertiarySystemFill))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
            }
        }
    }

    private func loadExistingRecord() {
        if let record = dataStore.getRecord(for: date) {
            isPeriodStart = record.isPeriodStart
            isPeriodEnd = record.isPeriodEnd
            selectedFlow = record.flowLevel
            selectedSymptoms = record.symptoms
            selectedMood = record.mood
        }
    }

    private func saveLog() {
        if isPeriodStart {
            dataStore.logPeriodStart(date: date, flowLevel: selectedFlow ?? .medium)
        } else if let flow = selectedFlow {
            // Only log flow separately if not already logged via periodStart
            dataStore.logFlow(date: date, flow: flow)
        }
        if isPeriodEnd {
            dataStore.logPeriodEnd(date: date)
        }
        for symptom in selectedSymptoms {
            dataStore.logSymptom(date: date, symptom: symptom)
        }
        if let mood = selectedMood {
            dataStore.logMood(date: date, mood: mood)
        }
    }
}
