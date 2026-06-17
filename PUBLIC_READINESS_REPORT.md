# Public Readiness Report

## Summary

- Repository: `gcanedo/T3DBarGraph`
- Branch: `fix/duplicate-bars-public-readiness`
- Date: 2026-06-17
- Reviewer: Codex
- Status: Not recommended to publish as-is until generated/binary artifacts are reviewed and cleaned up.

## Secret scan

### Current tree

- Tools/commands used:
  - `powershell -ExecutionPolicy Bypass -File patch\scripts\security-audit.ps1`
  - `git grep` manual search for secret-related terms, reporting only file paths and line numbers
  - `git ls-files` suspicious filename search
- Findings: No suspicious secret filenames or secret-related string matches were found in tracked files.

### Full Git history

- Tools/commands used:
  - Included PowerShell audit script
  - Manual `git log --all --name-only` suspicious filename search
  - Manual commit-by-commit `git grep` search for secret-related terms, reporting only commit SHA, file path, and line number
- Findings: No suspicious secret filenames or secret-related string matches were found in Git history.

### Decision

- Safe to publish as-is? No.
- Reason: No secrets were found by the available checks, but generated/binary artifacts are tracked in the current tree and history. Review and cleanup are recommended before making the repository public.
- Notes: `gitleaks` was not installed on PATH, so it was not run. `bash` was not available, so the Bash audit script could not be run. The PowerShell audit script generated `security-audit-report.md`, but emitted Markdown formatting errors; manual checks were run to cover the missing sections.

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

- Current tree cleanup: Review the listed generated/binary artifacts and remove only after owner approval.
- History cleanup: If the repository must be public and history size/content matters, consider a fresh public repository or an approved history cleanup.
- Whether `git filter-repo` or a fresh public repo is recommended: A fresh public repository is the safer option if historical binaries should not be exposed. Do not rewrite history without explicit owner approval.

## Code fix

### Files changed

- `U3DBarGraph.pas`

### Behavior fixed

Repeated calls to `TBarGraph.Add(row, col, value, color)` for the same row/column now update the existing bar instead of creating a duplicate component. `TBarContainer.Add` now distinguishes between missing and existing bars, recalculates data bounds after updates, refreshes positions, and refreshes the selected legend data when the selected bar is modified.

### Testing

- `git apply --check patch\patches\T3DBarGraph_fix_duplicate_bars.patch` was attempted, but the patch file was malformed at line 89, so the same logic was implemented manually.
- `git diff --check` completed with no whitespace errors; Git reported only the existing LF-to-CRLF working-copy warning for `U3DBarGraph.pas`.
- Delphi/MSBuild was not available on PATH, so package/demo builds were not run.

Suggested Delphi scenario:

```pascal
BarGraph.Add(0, 0, 10, claRed);
BarGraph.Add(0, 0, 10, claBlue);
BarGraph.Add(0, 0, 15, claGreen);
```

Expected result:

- Only one bar exists at `(0, 0)`.
- The value is `15`.
- The base color is `claGreen`.
- No duplicate component name exception occurs.

## Remaining recommendations

- Install and run `gitleaks detect --source . --no-git=false --redact --report-format json --report-path gitleaks-report.json`.
- Review the generated/binary artifact list before deleting anything.
- Update `.gitignore` after deciding which generated files should stay out of source control.
- Run `msbuild T3DBarGraphPackage.dproj` and `msbuild T3DBarGraphDemo.dproj` in a Delphi/MSBuild environment.
