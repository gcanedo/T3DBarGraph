# API Reference

This page lists the main public API exposed by `TBarGraph`.

## Data Methods

```pascal
procedure Add(row, col: Integer; Value: Single; cl: TAlphaColor = 0);
procedure AddYLabel(row: Integer; val: String);
procedure AddXLabel(col: Integer; val: String);
procedure BeginDataUpdate;
procedure EndDataUpdate;
procedure Reset;
```

### Add

Adds or updates a bar at a row/column position.

```pascal
BarGraph1.Add(0, 0, 42, claBlue);
```

Calling `Add` again with the same row and column updates the existing bar.

### AddYLabel / AddXLabel

Adds or updates row and column labels.

```pascal
BarGraph1.AddYLabel(0, 'Row A');
BarGraph1.AddXLabel(0, 'Column A');
```

### BeginDataUpdate / EndDataUpdate

Use these methods around bulk data changes.

```pascal
BarGraph1.BeginDataUpdate;
try
  // Add labels and bars here.
finally
  BarGraph1.EndDataUpdate;
end;
```

### Reset

Restores the view state.

## Axis And Scale Properties

```pascal
property ZLabel: String;
property YLabel: String;
property XLabel: String;
property AutoScale: Boolean;
property NumTicks: Integer;
property ZMin: Single;
property ZMax: Single;
```

## Visual Properties

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

## View Helpers

```pascal
procedure ViewNegativePlane;
procedure ViewPositivePlane;
procedure TurnLights(Val: Boolean);
```

Use `TurnLights(False)` if you need flatter colors or want to inspect the geometry without scene lighting.
