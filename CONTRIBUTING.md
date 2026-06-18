# Contributing

Thanks for considering a contribution to T3DBarGraph.

The project is a Delphi / FireMonkey component, so changes should be tested in RAD Studio when possible.

## Development Setup

1. Clone the repository.
2. Open `T3DBarGraphGroup.groupproj`, `T3DBarGraphPackage.dproj`, `T3DBarGraphDemo.dproj`, or `Test.dproj` in RAD Studio.
3. Build the package or run the demo/test project depending on the change.

## Before Opening a Pull Request

- Keep source changes focused.
- Do not commit generated build output folders such as `Win32/`, `Win64/`, or `OSX64/`.
- Do not commit local IDE files such as `*.local`, `*.identcache`, or `__history/`.
- If the change affects rendering, picking, labels, transparency, or navigation, test the demo visually.
- If the change affects performance or bulk loading, run the `Test.dproj` performance app with at least `1k` and `10k` bars.

## Coding Guidelines

- Prefer clear Delphi code over premature abstraction.
- Keep public API changes intentional and documented in `README.md`.
- Keep rendering, picking, and camera behavior deterministic.
- Avoid adding dependencies unless they clearly improve the component.
- Preserve compatibility with FireMonkey where practical.

## Reporting Bugs

When reporting a bug, include:

- Delphi/RAD Studio version.
- Target platform, for example Win32 or Win64.
- Steps to reproduce.
- Expected behavior.
- Actual behavior.
- Screenshot or short video when the issue is visual.

## Suggesting Features

Feature requests are welcome. Useful requests usually include:

- The data visualization use case.
- Expected API shape, if relevant.
- A small sample dataset or screenshot.
- Any performance constraints.

## Release Assets

Prebuilt test executables should be uploaded as GitHub Release assets, not committed to the repository.
