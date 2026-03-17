# NeuroAnalyzer UI style guide

Use this with **UITheme.m** and the Cursor rule (`.cursor/rules/neuroanalyzer-ui.mdc`) so all windows stay consistent.

## Theme (UITheme.m)

- **bgGray** – main/content background
- **headerBg** – header bar (dark blue)
- **projectBarBg** – secondary bar (e.g. project dirs)
- **cardBg** / **cardBorder** – panels and cards
- **accent** – primary buttons (teal); **accentDark** – secondary emphasis
- **headerTitleColor** / **headerSubtitleColor** – header text
- **sectionTitleColor** / **bodyColor** / **mutedColor** – labels and hints
- **fontTitle** (22), **fontSubtitle** (11), **fontSection** (14), **fontButton** (12), **fontBody** (11), **fontSmall** (10), **fontTiny** (9)
- **headerHeight** (52), **headerPaddingH** (20), **headerPaddingV** (14)

## Pattern for every window

1. **Figure**
   - `uifigure` when possible (not legacy `figure`).
   - `Color = UITheme.bgGray`, `Resize = 'on'`.

2. **Header (sub-windows)**
   - Top panel: `BackgroundColor = UITheme.headerBg`, height **52**.
   - Title: `FontSize = UITheme.fontTitle` (or 18 for sub-windows), `FontColor = UITheme.headerTitleColor`, bold.
   - Optional subtitle: `FontSize = UITheme.fontSubtitle`, `FontColor = UITheme.headerSubtitleColor`.
   - Primary action (e.g. Help, OK): white button, `FontColor = UITheme.headerBg`.

3. **Content area**
   - Background: **UITheme.bgGray**.
   - Cards/panels: **UITheme.cardBg**, `HighlightColor = UITheme.cardBorder`, `BorderType = 'line'`.

4. **Buttons**
   - Primary (e.g. Load, Extract): `BackgroundColor = UITheme.accent`, `FontColor = [1 1 1]`, **fontButton**.
   - Secondary: default background, same font size.
   - Tooltip on every button.

5. **Labels**
   - Section titles: **fontSection**, **sectionTitleColor**, bold.
   - Body/status: **fontBody** or **fontSmall**, **bodyColor** or **mutedColor**.

6. **Legacy figure apps**
   - `figure(..., 'Color', UITheme.bgGray)`.
   - Use same numeric colors for panels (`BackgroundColor`, `ForegroundColor`) and buttons where applicable.

## Files to keep consistent

- Main.m (reference)
- ExtractLDFApp.m, HelpApp.m, SignalCharacterizationApp.m (uifigure + header)
- ProcessingLDFApp, LDFGrandAverageApp, ExtractEphysApp, LFPAnalysisApp, MUAAnalysisApp (figure)
- LDFProcessingParamsApp, LFPProcessingParamsApp, MUAProcessingParamsApp, ERPConfigApp (dialogs)

Always use **UITheme.*** constants instead of hardcoded RGB or font sizes.
