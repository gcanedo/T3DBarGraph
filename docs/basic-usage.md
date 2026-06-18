# Basic Usage

Add `U3DBarGraph` to your form unit and place a `TBarGraph` on the form, either through the IDE palette or by creating it in code.

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

## Updating Existing Bars

`Add(row, col, value, color)` behaves as an upsert operation.

If a bar already exists at the same row and column, the existing bar is updated instead of creating a duplicate.

```pascal
BarGraph1.Add(0, 0, 10, claBlue);
BarGraph1.Add(0, 0, 20, claRed); // updates the same bar
```

## Bulk Loading

Wrap bulk updates in `BeginDataUpdate` and `EndDataUpdate`.

```pascal
BarGraph1.BeginDataUpdate;
try
  for I := 0 to Count - 1 do
    BarGraph1.Add(Row, Col, Value, Color);
finally
  BarGraph1.EndDataUpdate;
end;
```

This avoids recalculating layout and repainting after every single bar.
