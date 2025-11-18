import SwiftUI

struct AddEntryView: View {
    @ObservedObject var journalViewModel: JournalViewModel
    @StateObject private var moodAnalyzer: MoodAnalyzer
    @Environment(\.dismiss) private var dismiss

    init(journalViewModel: JournalViewModel, moodAnalyzer: MoodAnalyzer = MoodAnalyzer()) {
        self.journalViewModel = journalViewModel
        _moodAnalyzer = StateObject(wrappedValue: moodAnalyzer)
    }

    @State private var text: String = ""
    @State private var showResult: Bool = false

    var body: some View {
        VStack(spacing: 20) {
            Text(Date(), style: .date)
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 12) {
                Text("Write your thoughts")
                    .font(.headline)

                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.gray.opacity(0.25), lineWidth: 1)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                    TextEditor(text: $text)
                        .frame(minHeight: 200)
                        .padding(8)

                    if text.isEmpty {
                        Text("Start typing here...")
                            .foregroundColor(.gray)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 12)
                    }
                }
            }

            Button(action: {
                moodAnalyzer.analyze(text: text)
                withAnimation(.spring()) {
                    showResult = true
                }
            }) {
                HStack {
                    if moodAnalyzer.isAnalyzing {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Image(systemName: "sparkles")
                    }
                    Text("Analyze My Mood")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(hex: "74B9FF"))
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 6)
            }
            .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

            if let result = moodAnalyzer.currentResult, showResult {
                moodResultCard(result: result)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            Spacer()

            Button(action: saveEntry) {
                Text("Save Entry")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(canSave ? Color(hex: "00B894") : Color.gray.opacity(0.3))
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
            .disabled(!canSave)
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
        .navigationTitle("New Entry")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var canSave: Bool {
        !(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || moodAnalyzer.currentResult == nil)
    }

    private func saveEntry() {
        guard let result = moodAnalyzer.currentResult else { return }
        journalViewModel.addEntry(text: text, mood: result)
        dismiss()
    }

    @ViewBuilder
    private func moodResultCard(result: MoodResult) -> some View {
        VStack(spacing: 16) {
            Text(result.emoji)
                .font(.system(size: 60))
                .scaleEffect(1.1)
                .animation(.spring(), value: result.emoji)

            Text(result.label)
                .font(.title2.weight(.semibold))

            VStack(alignment: .leading) {
                Text("Confidence")
                    .font(.caption)
                    .foregroundColor(.secondary)
                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule().fill(Color.gray.opacity(0.2))
                        Capsule()
                            .fill(Color(hex: "A29BFE"))
                            .frame(width: max(8, proxy.size.width * result.score))
                            .animation(.easeOut(duration: 0.6), value: result.score)
                    }
                }
                .frame(height: 10)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 8)
    }
}

struct AddEntryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            AddEntryView(journalViewModel: JournalViewModel())
        }
    }
}
