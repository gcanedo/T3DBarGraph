# T3DBarGraph

T3DBarGraph is a Delphi / FireMonkey 3D bar chart component. It provides a reusable `TBarGraph` control built on top of `TViewport3D`, with support for interactive rotation, zooming, positive and negative values, axis labels, grid lines, color customization, lighting, plane transparency, and a selectable 3D legend.

The repository also includes a FireMonkey demo application and a performance test application for comparing large datasets.

## Features

- 3D bar chart component for Delphi FireMonkey applications.
- Positive and negative bar values.
- X, Y, and Z axis labels.
- Custom labels for rows and columns.
- Configurable background, plane, grid, font, bar, selected bar, and legend colors.
- Configurable plane transparency through `PlaneOpacity`.
- Optional auto-scale mode for the Z axis.
- Configurable Z-axis minimum, maximum, and number of ticks.
- Mouse and keyboard navigation with rotation, panning, cursor-focused wheel zoom, and reset shortcuts.
- Bar selection with a floating 3D information legend.
- Mesh-based rendering for larger datasets to reduce FireMonkey 3D object count.
- Bar picking support in both cube mode and mesh mode.
- Batched data loading with `BeginDataUpdate` and `EndDataUpdate`.
- Optional scene lighting.
- Demo project with runtime controls for the main visual settings.
- Performance test app with `1k`, `5k`, `10k`, and `50k` load buttons.

## Repository structure

```text
.
|-- U3DBarGraph.pas              # Main component source code
|-- T3DBarGraphPackage.dpk       # Delphi package containing the component
|-- T3DBarGraphPackage.dproj     # Package project file
|-- T3DBarGraphDemo.dpr          # Demo application entry point
|-- T3DBarGraphDemo.dproj        # Demo application project file
|-- UMain.pas / UMain.fmx        # Demo form and UI
|-- Test.dpr / UTest.pas         # Performance test application
|-- PUBLIC_READINESS_REPORT.md   # Public-readiness notes and audit summary
|-- LICENSE                      # Apache License 2.0
`-- README.md
```

## Getting started

### Requirements

- Delphi with FireMonkey support.
- A target platform supported by FireMonkey 3D.

This project was created as a Delphi FireMonkey component. Depending on your Delphi version, you may need to let the IDE update project metadata before building.

### Install the component

1. Open `T3DBarGraphPackage.dproj` or `T3DBarGraphPackage.dpk` in Delphi.
2. Build the package.
3. Install the package into the IDE.
4. After installation, the component should appear in the `UofW` component palette as `TBarGraph`.

### Run the demo

1. Open `T3DBarGraphDemo.dproj` in Delphi.
2. Build and run the project.
3. Use the demo controls to change colors, toggle auto-scale, modify Z-axis limits, change tick count, reset the camera, and toggle lights.

### Run the performance test

1. Open `Test.dproj` in Delphi.
2. Build and run the project.
3. Use the `1k`, `5k`, `10k`, and `50k` buttons to compare loading and interaction at different dataset sizes.

The performance test is useful when changing rendering, picking, camera movement, transparency, or bulk data loading behavior.

Prebuilt performance-test zips, when available, are published as GitHub Release assets so users can try the test application without compiling the project. These distribution zips are intentionally not committed to the source tree.

## Basic usage

Add `U3DBarGraph` to your form unit and place a `TBarGraph` on the form, either from the IDE palette or by creating it in code.

```pascal
uses
  U3DBarGraph, System.UIConsts;

procedure TForm1.FormCreate(Sender: TObject);
begin
  BarGraph1.BeginDataUpdate;
  try
    BarGraph1.XLabel := 'Season';
    BarGraph1.YLabel := 'Period';
    BarGraph1.ZLabel := 'Mean temperature';
    BarGraph1.PlaneOpacity := 0.5;

    BarGraph1.AddYLabel(0, '1987-1996');
    BarGraph1.AddYLabel(1, '1937-1946');
    BarGraph1.AddYLabel(2, '1887-1896');

    BarGraph1.AddXLabel(0, 'Spring');
    BarGraph1.AddXLabel(1, 'Summer');
    BarGraph1.AddXLabel(2, 'Autumn');
    BarGraph1.AddXLabel(3, 'Winter');

    BarGraph1.Add(0, 0, -15, claGreen);
    BarGraph1.Add(1, 0, 14, claPurple);
    BarGraph1.Add(2, 0, 14, claRed);

    BarGraph1.Add(0, 1, 25, claGreen);
    BarGraph1.Add(1, 1, 25, claPurple);
    BarGraph1.Add(2, 1, 25, claRed);
  finally
    BarGraph1.EndDataUpdate;
  end;
end;
```

Calling `Add` again for the same `row` and `col` updates the existing bar instead of creating a duplicate.

## Performance notes

For bulk loading, wrap repeated `Add`, `AddXLabel`, and `AddYLabel` calls with `BeginDataUpdate` and `EndDataUpdate`. This avoids recalculating layout and repainting after every single bar.

```pascal
BarGraph1.BeginDataUpdate;
try
  for I := 0 to Count - 1 do
    BarGraph1.Add(Row, Col, Value, Color);
finally
  BarGraph1.EndDataUpdate;
end;
```

For larger datasets, the component can render bars through a mesh-based path instead of creating one FireMonkey 3D object per bar. This keeps interaction usable with much larger bar counts; the included performance test has been used with 50,000 bars.

## Public API overview

### Data methods

```pascal
procedure Add(row, col: Integer; Value: Single; cl: TAlphaColor = 0);
procedure AddYLabel(row: Integer; val: String);
procedure AddXLabel(col: Integer; val: String);
procedure BeginDataUpdate;
procedure EndDataUpdate;
procedure Reset;
```

`Add(row, col, value, color)` is an upsert-style operation: if a bar already exists at the same row and column, its value and color are updated.

### Axis and scale properties

```pascal
property ZLabel: String;
property YLabel: String;
property XLabel: String;
property AutoScale: Boolean;
property NumTicks: Integer;
property ZMin: Single;
property ZMax: Single;
```

### Visual properties

```pascal
property BackgroundColor: TAlphaColor;
property BarColor: TAlphaColor;
property BarSelectedColor: TAlphaColor;
property GridColor: TAlphaColor;
property XYPlaneColor: TAlphaColor;
property XZandYZPlaneColor: TAlphaColor;
property PlaneOpacity: Single;
property FontColor: TAlphaColor;
property LegendFontColor: TAlphaColor;
property LegendBackgroundColor: TAlphaColor;
```

`PlaneOpacity` is clamped from `0` to `1`; the default is `0.5`.

### View helpers

```pascal
procedure ViewNegativePlane;
procedure ViewPositivePlane;
procedure TurnLights(Val: Boolean);
```

## Interaction

- Left-drag with the mouse to rotate the graph.
- Hold `Ctrl` and left-drag to pan the view.
- Use the mouse wheel to zoom toward the current cursor position.
- Use the arrow keys to pan the view.
- Press `R` or `Home` to reset the view.
- Click a bar to select it and show its floating 3D legend.
- Bar selection works in both normal cube rendering and the mesh render path.
- Click empty space to clear the current selection.
- Right-click to open the component popup menu.

## Public readiness

This repository is being prepared for public release. Before making it public, review `PUBLIC_READINESS_REPORT.md`, especially the generated/binary artifact section. Some build outputs and resource files are currently tracked in the repository history and should be reviewed before publishing.

## Notes

- The component is implemented in `U3DBarGraph.pas`.
- The demo data is configured in `UMain.pas`.
- The performance test is configured in `UTest.pas`.
- This project currently focuses on the visual component and demo usage. Automated tests and extended documentation are not included yet.
- Consider adding screenshots or GIFs to this README before the public release.

## License

This project is licensed under the Apache License 2.0. See `LICENSE` for details.
