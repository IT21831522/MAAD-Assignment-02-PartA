import Foundation
import CoreData

@objc(JournalEntry)
public class JournalEntry: NSManagedObject {
    @NSManaged public var id: UUID
    @NSManaged public var date: Date
    @NSManaged public var text: String
    @NSManaged public var moodLabel: String
    @NSManaged public var moodScore: Double
}

extension JournalEntry {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<JournalEntry> {
        NSFetchRequest<JournalEntry>(entityName: "JournalEntry")
    }
}

struct MoodResult {
    let label: String
    let score: Double

    var emoji: String {
        switch label.lowercased() {
        case "positive": return "😊"
        case "negative": return "😔"
        default: return "😐"
        }
    }
}
