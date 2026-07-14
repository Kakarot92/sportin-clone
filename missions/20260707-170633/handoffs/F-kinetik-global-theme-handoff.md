# Handoff: F-kinetik-global-theme — Globally theme AlertDialog, date/time pickers, SegmentedButton, DropdownButton popups, Chip to Kinetik

## Status
COMPLETE

## Assertions covered
No specific assertion IDs were assigned to this feature — it is a centralized design/theme fix.

## Files changed
lib/app/theme.dart

## Commands run
`dart analyze lib/app/theme.dart` (0) — No issues found
`dart analyze lib test` (0) — No issues found
`flutter test` (0) — 188 tests passed, 0 failures
`git add lib/app/theme.dart && git commit ...` (0)

## Decisions made
- Used `DialogThemeData` (not `DialogTheme`) — this is the correct type in Flutter 3.44.4 as confirmed by `dart analyze` passing with no issues.
- All *ThemeData class names matched Flutter 3.44.4 expectations; no renames needed.
- `canvasColor: surface` added as a top-level ThemeData property (not nested) to darken DropdownButton popups automatically without touching any call site.
- Did NOT set `dialogBackgroundColor` (deprecated) — relied on `dialogTheme.backgroundColor` only.
- Checked all 15+ call sites for AlertDialog, showDatePicker, showTimePicker, SegmentedButton, DropdownButton, Chip/FilterChip in `lib/features/` — found ZERO conflicting local `shape:`, `backgroundColor:`, `style:`, or `builder:` overrides that would fight with the new global theme. No call-site edits were needed.
- No Chip/FilterChip usage exists in `lib/features/` (only in `lib/design_lab/` which is excluded from changes) — chipTheme is added proactively for any future usage.

## Out-of-scope work needed
None identified.

## Blockers
None.

## Autonomous decisions
AUTONOMOUS_DECISION: Confirmed class name `DialogThemeData` by running `dart analyze` immediately after the edit — no warnings or errors, confirming it is valid for Flutter 3.44.4/Dart 3.12.2.

## Notes for the next worker
- Theme blocks added at the end of the `ThemeData(...)` constructor call in `_kinetik()`, after `switchTheme:`, following the exact same style as existing blocks.
- The 7 new blocks cover: `canvasColor`, `dialogTheme`, `datePickerTheme`, `timePickerTheme`, `segmentedButtonTheme`, `chipTheme`, `popupMenuTheme`.
- Every call site across all features inherits the Kinetik look automatically — sharp 2px corners, volt accent, Archivo Black titles, Inter Tight body text, near-black surfaces with hairline borders.
- Test count went from 171 to 188 due to unrelated features added since the count was taken — all 188 pass.
