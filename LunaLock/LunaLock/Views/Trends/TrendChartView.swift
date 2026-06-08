import SwiftUI
import Charts

struct TrendChartView: View {
    @StateObject private var viewModel = TrendViewModel()
    @StateObject private var purchaseManager = PurchaseManager.shared

    var body: some View {
        NavigationStack {
            Group {
                if purchaseManager.isPro {
                    proContent
                } else {
                    paywallContent
                }
            }
            .navigationTitle("Trends")
            .onAppear { viewModel.load() }
        }
    }

    private var proContent: some View {
        ScrollView {
            VStack(spacing: 20) {
                cycleLengthCard
                periodLengthCard
                symptomFrequencyCard
                moodDistributionCard
            }
            .padding()
        }
    }

    private var cycleLengthCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Cycle Length")
                .font(.headline)
            if viewModel.cycleLengths.isEmpty {
                Text("Not enough data yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                Text("Average: \(Int(viewModel.averageCycleLength)) days")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Chart {
                    ForEach(Array(viewModel.cycleLengths.indices), id: \.self) { index in
                        BarMark(x: .value("Cycle", index + 1), y: .value("Days", viewModel.cycleLengths[index]))
                            .foregroundStyle(Color(hex: "7C4DFF"))
                    }
                }
                .frame(height: 150)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var periodLengthCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Period Length")
                .font(.headline)
            if viewModel.periodLengths.isEmpty {
                Text("Not enough data yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                Text("Average: \(Int(viewModel.averagePeriodLength)) days")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Chart {
                    ForEach(Array(viewModel.periodLengths.indices), id: \.self) { index in
                        BarMark(x: .value("Period", index + 1), y: .value("Days", viewModel.periodLengths[index]))
                            .foregroundStyle(Color(hex: "E91E63"))
                    }
                }
                .frame(height: 150)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var symptomFrequencyCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Top Symptoms")
                .font(.headline)
            if viewModel.topSymptoms.isEmpty {
                Text("No symptoms logged yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                Chart(viewModel.topSymptoms, id: \.0) { symptom, count in
                    BarMark(x: .value("Symptom", symptom.rawValue), y: .value("Count", count))
                        .foregroundStyle(Color(hex: "7C4DFF"))
                }
                .frame(height: 150)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var moodDistributionCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Mood Patterns")
                .font(.headline)
            if viewModel.topMoods.isEmpty {
                Text("No moods logged yet")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } else {
                Chart(viewModel.topMoods, id: \.0) { mood, count in
                    SectorMark(angle: .value("Count", count), innerRadius: .ratio(0.5))
                        .foregroundStyle(Color(hex: "7C4DFF").opacity(0.7))
                }
                .frame(height: 150)
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var paywallContent: some View {
        VStack(spacing: 32) {
            Spacer()
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 60))
                .foregroundStyle(Color(hex: "7C4DFF"))
            Text("Trend Charts")
                .font(.title2)
                .fontWeight(.bold)
            Text("Unlock cycle length trends, symptom frequency charts, and mood pattern insights.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Button(action: {}) {
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
}
