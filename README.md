# Flodo Task Manager (Flutter Assessment)

A visually polished Task Management app built with Flutter.

## Chosen Track & Stretch Goal
- **Track**: Track B (Mobile Specialist)
- **Stretch Goal**: 1. Debounced Autocomplete Search (with text highlighting)

## Features
- **CRUD Operations**: Create, Read, Update, and Delete tasks.
- **Persistent Storage**: Uses `sqflite` to save tasks across app restarts.
- **Visual Task Blocking**: Tasks that are "Blocked By" another incomplete task are greyed out, have a strike-through title, and are non-interactive.
- **Draft Persistence**: If you start typing a new task and leave, the text remains when you return.
- **Search & Filter**: 
  - Search tasks by title with a 300ms debounce.
  - Highlight matching text in task titles in the list.
  - Filter tasks by status (To-Do, In Progress, Done).
- **Simulated Latency**: 2-second delay on Create and Update operations with visual loading states and prevention of double-tapping the "Save" button.

## Setup Instructions
1. Ensure you have the Flutter SDK installed and configured.
2. Clone this repository or copy the files into a new Flutter project.
3. Run `flutter pub get` to install dependencies.
4. Connect a mobile device or start an emulator.
5. Run the app using `flutter run`.

## Project Structure
- `lib/models/`: Task data model and enums.
- `lib/data/`: Database helper for SQLite.
- `lib/providers/`: State management using Provider.
- `lib/screens/`: Main Home Screen and Task Form Modal.
- `lib/widgets/`: Reusable components (TaskCard, SearchHighlightText).

## AI Usage Report
I used Antigravity AI to accelerate the development of this project.

### Helpful Prompts
- "Create a Flutter Task model with an enum for status and a nullable int for a self-referencing relationship (Blocked By)."
- "Implement a debounced search logic in a Flutter Provider."
- "Create a SearchHighlightText widget that takes a text and a query, and returns a RichText with matches highlighted."

### Challenges & Fixes
- **Issue**: Initially, the blocked state logic only checked if `blockedBy != null`. 
- **Fix**: Updated the logic to check if the specific task ID in `blockedBy` corresponds to a task that is NOT in the "Done" status.
- **Issue**: Highlighting text with multiple occurrences was tricky using simple regex.
- **Fix**: Implemented a recursive/looping character-index-based approach to ensure all matches are captured correctly in a `RichText` widget.
