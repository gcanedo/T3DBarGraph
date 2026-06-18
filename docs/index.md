# T3DBarGraph

T3DBarGraph is a Delphi / FireMonkey 3D bar chart component built on top of `TViewport3D`.

It supports dynamic data, positive and negative values, labels, transparent planes, mouse interaction, bar selection, and a mesh-based rendering mode for larger datasets.

[Download PDF manual](assets/T3DBarGraph-Manual.pdf){ .md-button .md-button--primary }
[View on GitHub](https://github.com/gcanedo/T3DBarGraph){ .md-button }

![T3DBarGraph demo](https://raw.githubusercontent.com/gcanedo/T3DBarGraph/main/assets/demo.gif)

## Main Features

- Delphi / FireMonkey 3D bar chart component.
- Dynamic bar data with row and column labels.
- Positive and negative values.
- Configurable colors for bars, selected bars, grids, planes, labels, and legend.
- Configurable plane transparency through `PlaneOpacity`.
- Mouse and keyboard navigation.
- Bar selection with a floating 3D legend.
- Mesh-based rendering path for larger datasets.
- Batched loading with `BeginDataUpdate` and `EndDataUpdate`.

## Current Release

The current public release is `v0.1.0`.

Prebuilt test executables, when available, are published as GitHub Release assets.

## When To Use It

T3DBarGraph is useful when you want a Delphi-native 3D visualization for dataset-style information, especially when rows, columns, and values have a natural visual relationship.

For very dense datasets, the performance test application is the best place to evaluate whether the 3D representation remains readable for your use case.
