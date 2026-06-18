# Performance

T3DBarGraph includes a performance test application in `Test.dproj`.

The test app includes buttons for:

- `1k`
- `5k`
- `10k`
- `50k`

## Bulk Loading

Use `BeginDataUpdate` and `EndDataUpdate` when adding many bars.

```pascal
BarGraph1.BeginDataUpdate;
try
  for I := 0 to Count - 1 do
    BarGraph1.Add(Row, Col, Value, Color);
finally
  BarGraph1.EndDataUpdate;
end;
```

## Mesh Rendering

For larger datasets, the component can render bars through a mesh-based path instead of creating one FireMonkey 3D object per bar.

This reduces object count and keeps interaction usable with much larger bar counts. The included performance test has been used locally with 50,000 bars.

## Readability

Rendering 50,000 bars does not automatically mean the result is visually useful.

For very dense datasets, consider:

- filtering visible rows or columns;
- grouping categories;
- showing a top-N view;
- using multiple charts;
- allowing users to drill into a smaller subset.

The goal is not only to draw many bars; it is to keep the data interpretable.
