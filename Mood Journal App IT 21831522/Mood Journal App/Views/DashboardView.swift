import SwiftUI
import Charts

struct DashboardView: View {
    @EnvironmentObject var journalViewModel: JournalViewModel
    @EnvironmentObject var moodAnalyzer: MoodAnalyzer

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ZStack {
            Color(UIColor.systemBackground)
                .ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    headerSection
                    moodCard
                    actionButtons
                    analyticsPreview
                }
                .padding(20)
            }
        }
        .navigationTitle("MindFlow")
        .onAppear {
            journalViewModel.fetchEntries()
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(Date(), style: .date)
                .font(.title2.weight(.bold))
            Text("How are you feeling today?")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var moodCard: some View {
        let latest = journalViewModel.latestEntry
        let label = latest?.moodLabel ?? "Neutral"
        let score = latest?.moodScore ?? 0.5
        let emoji: String
        switch label.lowercased() {
        case "positive": emoji = "😊"
        case "negative": emoji = "😔"
        default: emoji = "😐"
        }

        return ZStack {
            LinearGradient(
                colors: [Color(hex: "A29BFE"), Color(hex: "74B9FF")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .opacity(colorScheme == .dark ? 0.9 : 1.0)

            VStack(spacing: 16) {
                Text("Today's Mood")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))

                Text(emoji)
                    .font(.system(size: 56))
                    .scaleEffect(1.05)
                    .animation(.spring(), value: emoji)

                Text(label)
                    .font(.title2.weight(.semibold))
                    .foregroundColor(.white)

                Text("Confidence: \(Int(score * 100))%")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))

                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.2))
                        Capsule()
                            .fill(Color.white)
                            .frame(width: max(8, proxy.size.width * score))
                            .animation(.easeOut(duration: 0.6), value: score)
                    }
                }
                .frame(height: 10)
            }
            .padding(24)
        }
        .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
        .shadow(color: Color.black.opacity(0.12), radius: 18, x: 0, y: 10)
        .frame(maxWidth: .infinity)
        .frame(minHeight: 180)
    }

    private var actionButtons: some View {
        HStack(spacing: 16) {
            NavigationLink {
                AddEntryView(journalViewModel: journalViewModel)
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Journal Entry")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(hex: "74B9FF"))
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)
            }

            NavigationLink {
                JournalListView()
            } label: {
                HStack {
                    Image(systemName: "list.bullet")
                    Text("View All Entries")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(hex: "A29BFE"))
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)
            }
        }
    }

    private var analyticsPreview: some View {
        NavigationLink {
            AnalyticsView()
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Last 7 days mood trend")
                        .font(.headline)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }

                Chart(journalViewModel.moodTrendLast7Days()) { point in
                    LineMark(
                        x: .value("Date", point.date),
                        y: .value("Mood", point.score)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(Color(hex: "A29BFE"))
                }
                .chartYScale(domain: 0...1)
                .frame(height: 140)
            }
            .padding(16)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 25, style: .continuous))
            .shadow(color: Color.black.opacity(0.06), radius: 10, x: 0, y: 6)
        }
    }
}

struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DashboardView()
                .environmentObject(JournalViewModel())
                .environmentObject(MoodAnalyzer())
        }
    }
}

extension Color {
    init(hex: String) {
        let hexSanitized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hexSanitized.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
