import SwiftUI

struct JournalDetailView: View {
    let entry: JournalEntry

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(entry.date, style: .date)
                    .font(.title2.weight(.semibold))

                moodSection

                Divider()

                Text(entry.text)
                    .font(.body)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(20)
        }
        .background(Color(UIColor.systemBackground))
        .navigationTitle("Entry Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var moodSection: some View {
        let color = moodColor(for: entry.moodLabel)
        let emoji = moodEmoji(for: entry.moodLabel)

        return VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Text(emoji)
                    .font(.system(size: 48))
                VStack(alignment: .leading) {
                    Text(entry.moodLabel.capitalized)
                        .font(.headline)
                    Text("Confidence: \(Int(entry.moodScore * 100))%")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(color.opacity(0.15))
                    Capsule()
                        .fill(color)
                        .frame(width: max(8, proxy.size.width * entry.moodScore))
                        .animation(.easeOut(duration: 0.6), value: entry.moodScore)
                }
            }
            .frame(height: 10)
        }
        .padding(16)
        .background(color.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }

    private func moodColor(for label: String) -> Color {
        switch label.lowercased() {
        case "positive": return Color(hex: "00B894")
        case "negative": return Color(hex: "D63031")
        default: return Color(hex: "636E72")
        }
    }

    private func moodEmoji(for label: String) -> String {
        switch label.lowercased() {
        case "positive": return "😊"
        case "negative": return "😔"
        default: return "😐"
        }
    }
}
