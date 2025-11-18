import SwiftUI

struct JournalListView: View {
    @EnvironmentObject var journalViewModel: JournalViewModel

    var body: some View {
        Group {
            if journalViewModel.entries.isEmpty {
                emptyState
            } else {
                List {
                    ForEach(journalViewModel.entries, id: \JournalEntry.id) { entry in
                        NavigationLink {
                            JournalDetailView(entry: entry)
                        } label: {
                            journalCard(for: entry)
                        }
                    }
                    .onDelete(perform: delete)
                }
                .listStyle(.insetGrouped)
            }
        }
        .navigationTitle("My Journals")
        .onAppear {
            journalViewModel.fetchEntries()
        }
    }

    private func delete(at offsets: IndexSet) {
        offsets.map { journalViewModel.entries[$0] }.forEach(journalViewModel.deleteEntry)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "book")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.secondary)
            Text("No journal entries yet")
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func journalCard(for entry: JournalEntry) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(moodEmoji(for: entry.moodLabel))
                .font(.largeTitle)

            VStack(alignment: .leading, spacing: 6) {
                Text(entry.date, style: .date)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.secondary)

                Text(entry.text)
                    .font(.body)
                    .lineLimit(2)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
    }

    private func moodEmoji(for label: String) -> String {
        switch label.lowercased() {
        case "positive": return "😊"
        case "negative": return "😔"
        default: return "😐"
        }
    }
}

struct JournalListView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            JournalListView()
                .environmentObject(JournalViewModel())
        }
    }
}
