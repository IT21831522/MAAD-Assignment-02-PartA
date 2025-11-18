import Foundation
import CoreData
import Combine

final class JournalViewModel: ObservableObject {
    @Published var entries: [JournalEntry] = []
    @Published var latestEntry: JournalEntry?

    private let viewContext: NSManagedObjectContext

    init(context: NSManagedObjectContext = PersistenceController.shared.container.viewContext) {
        self.viewContext = context
        fetchEntries()
    }

    func fetchEntries() {
        let request: NSFetchRequest<JournalEntry> = JournalEntry.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \JournalEntry.date, ascending: false)]

        do {
            entries = try viewContext.fetch(request)
            latestEntry = entries.first
        } catch {
            print("Failed to fetch entries: \(error)")
        }
    }

    func addEntry(text: String, mood: MoodResult) {
        guard let entry = NSEntityDescription.insertNewObject(forEntityName: "JournalEntry", into: viewContext) as? JournalEntry else {
            assertionFailure("Failed to create JournalEntry. Check entity name and model configuration.")
            return
        }
        entry.id = UUID()
        entry.date = Date()
        entry.text = text
        entry.moodLabel = mood.label
        entry.moodScore = mood.score

        saveContext()
        fetchEntries()
    }

    func deleteEntry(_ entry: JournalEntry) {
        viewContext.delete(entry)
        saveContext()
        fetchEntries()
    }

    private func saveContext() {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                print("Error saving context: \(error)")
            }
        }
    }

    func moodCountsLast7Days() -> (positive: Int, neutral: Int, negative: Int) {
        let calendar = Calendar.current
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -6, to: calendar.startOfDay(for: Date())) ?? Date()
        let recent = entries.filter { $0.date >= sevenDaysAgo }
        var pos = 0, neu = 0, neg = 0
        for e in recent {
            switch e.moodLabel.lowercased() {
            case "positive": pos += 1
            case "negative": neg += 1
            default: neu += 1
            }
        }
        return (pos, neu, neg)
    }

    struct DailyMoodPoint: Identifiable {
        let id = UUID()
        let date: Date
        let score: Double
    }

    func moodTrendLast7Days() -> [DailyMoodPoint] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var points: [DailyMoodPoint] = []
        for offset in (0...6).reversed() {
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
            let dayEntries = entries.filter { calendar.isDate($0.date, inSameDayAs: day) }
            let avg = dayEntries.isEmpty ? 0.5 : dayEntries.map { $0.moodScore }.reduce(0, +) / Double(dayEntries.count)
            points.append(DailyMoodPoint(date: day, score: avg))
        }
        return points
    }
}

