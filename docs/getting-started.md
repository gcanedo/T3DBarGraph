# Getting Started

## Requirements

- Delphi with FireMonkey support.
- A platform supported by FireMonkey 3D.

The project was created as a Delphi FireMonkey component. Depending on your Delphi version, RAD Studio may update project metadata when opening the project files.

## Repository Contents

The repository includes:

- `U3DBarGraph.pas`: main component source code.
- `T3DBarGraphPackage.dproj`: installable package project.
- `T3DBarGraphDemo.dproj`: demo application.
- `Test.dproj`: performance test application.

## Install The Component

1. Open `T3DBarGraphPackage.dproj` or `T3DBarGraphPackage.dpk` in Delphi.
2. Build the package.
3. Install the package into the IDE.
4. The component should appear in the `UofW` component palette as `TBarGraph`.

## Run The Demo

1. Open `T3DBarGraphDemo.dproj`.
2. Build and run the project.
3. Use the demo controls to change visual settings, scale behavior, camera state, and lighting.

## Run The Performance Test

1. Open `Test.dproj`.
2. Build and run the project.
3. Use the `1k`, `5k`, `10k`, and `50k` buttons to compare loading and interaction at different dataset sizes.

The performance test is useful when changing rendering, picking, transparency, camera movement, or bulk data loading.
