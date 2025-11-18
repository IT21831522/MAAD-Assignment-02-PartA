import SwiftUI
import CoreData

@main
struct MindFlowApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(\.managedObjectContext,
                             persistenceController.container.viewContext)
        }
    }
}

struct RootView: View {
    @StateObject private var journalViewModel = JournalViewModel()
    @StateObject private var moodAnalyzer = MoodAnalyzer()

    var body: some View {
        NavigationStack {
            DashboardView()
                .environmentObject(journalViewModel)
                .environmentObject(moodAnalyzer)
        }
    }
}
