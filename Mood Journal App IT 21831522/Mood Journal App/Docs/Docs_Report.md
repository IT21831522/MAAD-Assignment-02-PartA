# MindFlow – AI Mood Journal – Brief Report

## Purpose

MindFlow helps people build emotional awareness by combining daily journaling with automatic mood analysis. Users can easily record how they feel, see their mood classified as Positive/Neutral/Negative, and review patterns over time.

## Target Audience

- Students and young adults managing stress, exams, or life transitions.
- Anyone interested in self-reflection, mental wellness, or tracking emotional trends.

## Key Features

- **AI-powered mood analysis** of free-text journal entries.
- **Mood-aware journaling** flow with a clean, calming interface.
- **Dashboard** with today’s mood summary and quick actions.
- **Journal list & details** with swipe-to-delete and mood indicators.
- **Analytics** view with weekly mood trend line chart and mood breakdown bar chart.

## UI & UX Decisions

- Pastel color palette (purple + blue) and rounded cards to create a calm, friendly atmosphere.
- Large emojis and clear mood labels for instant emotional feedback.
- SwiftUI animations (`.spring`, transitions, shadows) to make mood results feel alive and responsive.
- Support for system dark mode via system background colors.

## Tech Stack

- **SwiftUI** for modern declarative UI.
- **CoreData** (`NSPersistentContainer`) for local persistence of journal entries.
- **CoreML / NaturalLanguage** for sentiment classification via `NLModel`.
- **Swift Charts** for visual analytics.
- MVVM architecture with dedicated view models.

## ML Integration

- Wraps an NL-based sentiment model (e.g., `SentimentPolarity.mlmodel`) inside `MoodAnalyzer`.
- Uses asynchronous analysis on a background queue with a published `MoodResult` for the UI.
- Includes a rule-based fallback classifier for robustness when the model is missing.

## Testing

- **Unit tests** for `MoodAnalyzer` focusing on fallback behavior for positive/negative phrases.
- **UI test** for adding a journal entry, running analysis, saving, and deleting from the list.

## Future Improvements

- More granular mood categories (e.g., anxious, calm, motivated).
- On-device personalization of sentiment thresholds.
- Widgets or notifications for daily check-ins.
