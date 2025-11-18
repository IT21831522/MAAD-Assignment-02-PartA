import SwiftUI
import Charts

struct AnalyticsView: View {
    @EnvironmentObject var journalViewModel: JournalViewModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Weekly Mood Trend")
                    .font(.title2.weight(.semibold))

                lineChart

                Text("Mood Breakdown")
                    .font(.title3.weight(.semibold))

                breakdownChart

                insightsSection

                Spacer(minLength: 20)
            }
            .padding(20)
        }
        .navigationTitle("Mood Analytics")
    }

    private var lineChart: some View {
        Chart(journalViewModel.moodTrendLast7Days()) { point in
            LineMark(
                x: .value("Date", point.date),
                y: .value("Mood", point.score)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(Color(hex: "74B9FF"))
            AreaMark(
                x: .value("Date", point.date),
                y: .value("Mood", point.score)
            )
            .foregroundStyle(LinearGradient(colors: [Color(hex: "74B9FF").opacity(0.4), .clear], startPoint: .top, endPoint: .bottom))
        }
        .chartYScale(domain: 0...1)
        .frame(height: 220)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var breakdownChart: some View {
        let counts = journalViewModel.moodCountsLast7Days()
        _ = max(1, counts.positive + counts.neutral + counts.negative)

        let data: [(label: String, value: Int, color: Color)] = [
            ("Positive", counts.positive, Color(hex: "00B894")),
            ("Neutral", counts.neutral, Color(hex: "636E72")),
            ("Negative", counts.negative, Color(hex: "D63031"))
        ]

        return Chart(data, id: \.label) { item in
            BarMark(
                x: .value("Count", item.value),
                y: .value("Mood", item.label)
            )
            .foregroundStyle(item.color)
        }
        .frame(height: 180)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private var insightsSection: some View {
        let counts = journalViewModel.moodCountsLast7Days()
        let total = max(1, counts.positive + counts.neutral + counts.negative)

        let dominantMood: String
        if counts.positive >= counts.neutral && counts.positive >= counts.negative {
            dominantMood = "Positive"
        } else if counts.negative >= counts.positive && counts.negative >= counts.neutral {
            dominantMood = "Negative"
        } else {
            dominantMood = "Neutral"
        }

        let dominantPercentage = Int(Double(
            dominantMood == "Positive" ? counts.positive : dominantMood == "Negative" ? counts.negative : counts.neutral
        ) / Double(total) * 100)

        let message: String
        switch dominantMood {
        case "Positive":
            message = "You were mostly Positive this week. Keep it up!"
        case "Negative":
            message = "You've had a tougher week emotionally. Be kind to yourself and consider what small actions might help."
        default:
            message = "Your mood has been quite balanced. Notice what helps you stay grounded."
        }

        return VStack(alignment: .leading, spacing: 8) {
            Text("Insights")
                .font(.headline)
            Text("\(dominantMood) • \(dominantPercentage)% of the last 7 days")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(message)
                .font(.body)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

struct AnalyticsView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AnalyticsView()
                .environmentObject(JournalViewModel())
        }
    }
}
