# Changelog

All notable changes to T3DBarGraph are documented in this file.

This project follows pragmatic semantic versioning while the public API stabilizes.

## Unreleased

Planned work:

- Improve dataset loading helpers.
- Add more camera/view presets.
- Improve labels and tooltips for dense charts.
- Add export helpers for images.
- Continue reducing coupling inside `U3DBarGraph.pas`.

## v0.1.0 - 2026-06-18

Initial public release.

### Added

- Delphi / FireMonkey 3D bar chart component.
- Demo application and performance test application.
- Dynamic bar data through `Add`, `AddXLabel`, and `AddYLabel`.
- Positive and negative bar values.
- Axis labels, grid lines, configurable colors, and configurable plane opacity.
- Mouse navigation with rotation, panning, reset shortcuts, and cursor-focused wheel zoom.
- Bar selection with a floating 3D information legend.
- Mesh-based rendering path for larger datasets.
- Mesh picking support for selected bars.
- Batched data loading with `BeginDataUpdate` and `EndDataUpdate`.

### Fixed

- Repeated `Add(row, col, value, color)` calls update an existing bar instead of creating duplicate bars.
- Improved transparent plane rendering and selection behavior after large dataset changes.

### Notes

- The included performance test has been used locally with 50,000 bars.
- Validation is currently manual through RAD Studio and the included demo/test applications.
