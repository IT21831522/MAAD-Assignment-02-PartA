# MindFlow – AI Mood Journal

## Architecture (MVVM)

- **Models**
  - `JournalEntry` (CoreData entity): `id`, `date`, `text`, `moodLabel`, `moodScore`.
  - `MoodResult`: lightweight struct used by the UI.
- **ViewModels**
  - `JournalViewModel`: CRUD for entries, analytics helper methods for mood trend and breakdown.
  - `MoodAnalyzer`: wraps CoreML/NLModel sentiment analysis with a rule-based fallback.
- **Views**
  - `DashboardView`: home screen; today summary, quick actions, analytics preview.
  - `AddEntryView`: journaling + mood analysis + save.
  - `JournalListView`: list of all entries with swipe-to-delete.
  - `JournalDetailView`: full entry + mood visualization.
  - `AnalyticsView`: weekly trend and breakdown charts.

## CoreData model configuration

Create a Core Data model file `MindFlowModel.xcdatamodeld` and add an entity `JournalEntry`:

- **JournalEntry**
  - `id`: UUID (required)
  - `date`: Date (required)
  - `text`: String (required)
  - `moodLabel`: String (required)
  - `moodScore`: Double (required)

Set the module of the entity to `Current Product Module` and codegen to **Manual/None**, then use the `JournalEntry` class from `Models.swift`.

## ML model integration

- Add `SentimentPolarity.mlmodel` to the Xcode project (from Apple sample or your own trained model).
- Xcode will compile it into `SentimentPolarity.mlmodelc` in the bundle.
- `MoodAnalyzer` loads it via `NLModel(contentsOf: URL)` and predicts a sentiment label for the entered text.
- If the model is not found, a simple keyword-based fallback sentiment classifier is used.

## Navigation

- `MindFlowApp` -> `RootView` uses `NavigationStack`.
- `DashboardView` contains `NavigationLink`s to `AddEntryView`, `JournalListView`, and `AnalyticsView`.

## Styling & Branding

- Pastel theme using hex colors:
  - Primary purple: `#A29BFE`.
  - Secondary blue: `#74B9FF`.
  - Positive: `#00B894`.
  - Neutral: `#636E72`.
  - Negative: `#D63031`.
- Rounded cards with corner radius ~20–25, soft shadows, and system background colors for dark-mode friendliness.
