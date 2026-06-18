# Public Readiness Report

## Summary

- Repository: `gcanedo/T3DBarGraph`
- Branch: `fix/duplicate-bars-public-readiness`
- Last updated: 2026-06-18
- Reviewer: Codex
- Status: Not recommended to publish as-is until generated/binary artifacts are reviewed and either intentionally kept or cleaned up.

## Secret scan

### Current tree

- Tools/commands used:
  - `powershell -ExecutionPolicy Bypass -File patch\scripts\security-audit.ps1`
  - Manual suspicious filename search with `git log --all --name-only`
  - Manual current-tree secret-term search with `git grep -l`, reporting only file names
  - Manual generated/binary artifact search with `git ls-files`
- Findings: No suspicious secret filenames were found.
- Notes: The only current-tree secret-term match was `PUBLIC_READINESS_REPORT.md` itself, because it documents the secret scan. No credential value was printed.

### Full Git history

- Tools/commands used:
  - Included PowerShell audit script
  - Manual full-history suspicious filename search
  - Manual commit-by-commit secret-term search, reporting only commit SHA and file name
- Findings: No suspicious secret filenames were found. The only secret-term history match was `PUBLIC_READINESS_REPORT.md` in commit `f865aac`, because it documents the scan.

### Tool limitations

- `gitleaks` was not installed on PATH, so it was not run.
- The included PowerShell script generated `security-audit-report.md`, but emitted Markdown formatting errors around fenced code blocks. Manual checks were run to cover the relevant sections.

## Generated/binary artifacts

### Current tree

Tracked generated or binary-looking files currently present:

- `OSX64/Debug/T3DBarGraphDemo`
- `OSX64/Debug/T3DBarGraphDemo.dSYM`
- `OSX64/Debug/Test`
- `OSX64/Debug/Test.dSYM`
- `OSX64/Debug/Test.entitlements`
- `OSX64/Debug/Test.info.plist`
- `OSX64/Release/Test`
- `T3DBarGraphDemo.res`
- `T3DBarGraphPackage.res`
- `Test.res`

### Historical

Generated or binary-looking paths found in history:

- `OSX64/Debug/T3DBarGraphDemo`
- `OSX64/Debug/T3DBarGraphDemo.dSYM`
- `OSX64/Debug/Test`
- `OSX64/Debug/Test.dSYM`
- `OSX64/Debug/Test.entitlements`
- `OSX64/Debug/Test.info.plist`
- `OSX64/Release/Test`
- `Project1.res`
- `T3DBarGraphDemo.res`
- `T3DBarGraphPackage.res`
- `Test.res`
- `Win64/Debug/T3DBarGraphDemo.zip`

### Recommended cleanup

- Review the listed generated/binary artifacts before making the repository public.
- Do not delete files or rewrite history without owner approval.
- If historical binaries should not be exposed, a fresh public repository may be safer than rewriting this history.

## Code changes

### Files changed intentionally

- `U3DBarGraph.pas`
- `UMain.pas`
- `UTest.pas`
- `PUBLIC_READINESS_REPORT.md`

### Behavior fixed or improved

- Repeated calls to `TBarGraph.Add(row, col, value, color)` for the same row/column update the existing bar instead of creating duplicates.
- Large datasets switch to a `TMesh`-based render path, reducing object count and allowing tests such as 50,000 bars.
- Mesh picking was added so clicking bars still selects the corresponding data item in mesh mode.
- A screen-space picking fallback was added for more reliable bar selection.
- `PlaneOpacity` was added for the three planes, with default opacity set to `0.5`.
- Transparent plane/tick text layers now keep depth testing enabled so translucent panels do not render on top of bars incorrectly.
- Axis mirror text was disabled where it produced unreadable mirrored labels.
- Demo/test loading now supports batched performance runs.

### Local files not recommended for this commit

- `Test.dproj` has large RAD Studio auto-generated platform/deployment churn.
- `Test.res` is a generated/binary resource update.
- `security-audit-report.md` is a raw generated audit log with formatting issues.
- `patch/` is the local task package, not library source.

These files should be reviewed separately before deciding whether they belong in the public repository.

## Testing

- User verified in RAD Studio that 50,000 bars load.
- User verified that mesh bar clicks select bars after the picking fixes.
- Transparency was iterated visually in RAD Studio screenshots.
- `powershell -ExecutionPolicy Bypass -File patch\scripts\security-audit.ps1` was run.
- Manual secret and generated-artifact searches were run.
- `git diff --check` completed with no whitespace errors; Git reported only LF-to-CRLF working-copy warnings.
- Command-line MSBuild was not available in this environment/license, so final Delphi builds must be run from RAD Studio.

## Remaining recommendations

- Install and run `gitleaks detect --source . --no-git=false --redact --report-format json --report-path gitleaks-report.json`.
- Review and clean generated/binary artifacts before making the repository public.
- Decide whether the public repo should include only the package/demo source or also the local performance test app.
- Add or refine `.gitignore` after deciding which build outputs should stay out of source control.
- Run a clean RAD Studio build for Win32/Win64 and the package project before publishing.
