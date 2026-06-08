import SwiftUI

struct DashboardView: View {
    @StateObject private var viewModel = DashboardViewModel()
    @StateObject private var dataStore = DataStore.shared
    @StateObject private var security = SecurityManager.shared
    @State private var showQuickLog = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    phaseCard
                    quickActionsSection
                    todayLogSection
                }
                .padding()
            }
            .navigationTitle("LunaLock")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { security.emergencyLock() }) {
                        Image(systemName: "lock.fill")
                    }
                }
            }
            .sheet(isPresented: $showQuickLog) {
                QuickLogView()
            }
            .onAppear { viewModel.load() }
            .onChange(of: dataStore.periodStartDates) { _, _ in
                viewModel.load()
            }
            .refreshable { viewModel.load() }
        }
    }

    private var phaseCard: some View {
        VStack(spacing: 16) {
            if let prediction = viewModel.prediction {
                HStack {
                    Image(systemName: viewModel.phaseIcon)
                        .font(.title2)
                        .foregroundStyle(viewModel.phaseColor)
                    Text(prediction.currentPhase.rawValue)
                        .font(.headline)
                        .foregroundStyle(viewModel.phaseColor)
                    Spacer()
                    Text("Day \(prediction.currentCycleDay)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Divider()

                HStack(spacing: 24) {
                    VStack {
                        Text("\(prediction.daysUntilNext)")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(Color(hex: "7C4DFF"))
                        Text("days until next")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Avg cycle: \(Int(prediction.averageCycleLength)) days")
                            .font(.caption)
                        Text("Confidence: ±\(prediction.confidenceRange) days")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "moon.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(Color(hex: "7C4DFF"))
                    Text("Log your first period to get started")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 20)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var quickActionsSection: some View {
        HStack(spacing: 12) {
            Button(action: { viewModel.logPeriodStart() }) {
                Label("Start Period", systemImage: "drop.fill")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(hex: "E91E63"))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Button(action: { viewModel.logPeriodEnd() }) {
                Label("End Period", systemImage: "drop")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(Color(hex: "E91E63"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(hex: "E91E63").opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Button(action: { showQuickLog = true }) {
                Label("Quick Log", systemImage: "plus.circle.fill")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(hex: "7C4DFF"))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private var todayLogSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today's Log")
                .font(.headline)

            VStack(alignment: .leading, spacing: 12) {
                Text("Flow")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                HStack(spacing: 8) {
                    ForEach(FlowLevel.allCases, id: \.self) { flow in
                        Button(action: { viewModel.selectFlow(flow) }) {
                            Text(flow.label)
                                .font(.caption)
                                .fontWeight(viewModel.selectedFlow == flow ? .bold : .regular)
                                .foregroundStyle(viewModel.selectedFlow == flow ? .white : .primary)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(viewModel.selectedFlow == flow ? Color(hex: "E91E63") : Color(.tertiarySystemFill))
                                .clipShape(Capsule())
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Symptoms")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                FlowLayout(spacing: 8) {
                    ForEach(SymptomType.allCases, id: \.self) { symptom in
                        Button(action: { viewModel.toggleSymptom(symptom) }) {
                            Label(symptom.rawValue, systemImage: symptom.icon)
                                .font(.caption)
                                .fontWeight(viewModel.selectedSymptoms.contains(symptom) ? .bold : .regular)
                                .foregroundStyle(viewModel.selectedSymptoms.contains(symptom) ? .white : .primary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(viewModel.selectedSymptoms.contains(symptom) ? Color(hex: "7C4DFF") : Color(.tertiarySystemFill))
                                .clipShape(Capsule())
                        }
                    }
                }
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Mood")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(MoodType.allCases, id: \.self) { mood in
                            Button(action: { viewModel.selectMood(mood) }) {
                                VStack(spacing: 4) {
                                    Image(systemName: mood.icon)
                                        .font(.title3)
                                    Text(mood.rawValue)
                                        .font(.caption2)
                                }
                                .foregroundStyle(viewModel.selectedMood == mood ? .white : .primary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(viewModel.selectedMood == mood ? Color(hex: "7C4DFF") : Color(.tertiarySystemFill))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        return (CGSize(width: maxWidth, height: y + rowHeight), positions)
    }
}
