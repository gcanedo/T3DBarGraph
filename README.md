# T3DBarGraph

T3DBarGraph is a Delphi / FireMonkey 3D bar chart component. It provides a reusable `TBarGraph` control built on top of `TViewport3D`, with support for interactive rotation, zooming, positive and negative values, axis labels, grid lines, color customization, lighting, and a selectable 3D legend.

The repository also includes a FireMonkey demo application that shows how to configure the component and populate it with sample data.

## Features

- 3D bar chart component for Delphi FireMonkey applications.
- Positive and negative bar values.
- X, Y, and Z axis labels.
- Custom labels for rows and columns.
- Configurable background, plane, grid, font, bar, selected bar, and legend colors.
- Optional auto-scale mode for the Z axis.
- Configurable Z-axis minimum, maximum, and number of ticks.
- Mouse-driven rotation and mouse wheel zoom.
- Bar selection with a floating 3D information legend.
- Optional scene lighting.
- Demo project with runtime controls for the main visual settings.

## Repository structure

```text
.
├── U3DBarGraph.pas              # Main component source code
├── T3DBarGraphPackage.dpk       # Delphi package containing the component
├── T3DBarGraphPackage.dproj     # Package project file
├── T3DBarGraphDemo.dpr          # Demo application entry point
├── T3DBarGraphDemo.dproj        # Demo application project file
├── UMain.pas / UMain.fmx        # Demo form and UI
├── LICENSE                      # Apache License 2.0
└── README.md
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

## Basic usage

Add `U3DBarGraph` to your form unit and place a `TBarGraph` on the form, either from the IDE palette or by creating it in code.

```pascal
uses
  U3DBarGraph, System.UIConsts;

procedure TForm1.FormCreate(Sender: TObject);
begin
  BarGraph1.XLabel := 'Season';
  BarGraph1.YLabel := 'Period';
  BarGraph1.ZLabel := 'Mean temperature';

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
end;
```

## Public API overview

### Data methods

```pascal
procedure Add(row, col: Integer; Value: Single; cl: TAlphaColor = 0);
procedure AddYLabel(row: Integer; val: String);
procedure AddXLabel(col: Integer; val: String);
procedure Reset;
```

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
property FontColor: TAlphaColor;
property LegendFontColor: TAlphaColor;
property LegendBackgroundColor: TAlphaColor;
```

### View helpers

```pascal
procedure ViewNegativePlane;
procedure ViewPositivePlane;
procedure TurnLights(Val: Boolean);
```

## Interaction

- Drag with the left mouse button to rotate the graph.
- Use the mouse wheel to zoom.
- Click a bar to select it and show its legend.
- Click the background to clear the current selection.
- Right-click to open the component popup menu.

## Notes

- The component is implemented in `U3DBarGraph.pas`.
- The demo data is configured in `UMain.pas`.
- This project currently focuses on the visual component and demo usage. Automated tests and extended documentation are not included yet.
- If you modernize the repository, consider cleaning generated build artifacts from source control and adding screenshots or GIFs to this README.

## License

This project is licensed under the Apache License 2.0. See `LICENSE` for details.
