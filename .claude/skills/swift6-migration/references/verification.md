# Verification — Build Loop and Done Criteria

The requirement: the MAIN APP must compile with zero errors for the simulator. Test-target code must also compile (`build-for-testing`), but may rely on opt-outs.

## Fix loop

1. Build (command below) and collect all errors:
   ```bash
   xcodebuild -workspace Carson.xcworkspace -scheme Carson \
     -destination 'generic/platform=iOS Simulator' build 2>&1 | grep -E "error:" | sort -u
   ```
2. Group errors into clusters (same message pattern / same protocol). Look each up in decision-tree.md.
3. Apply the matching recipe. Mechanical protocol-wide changes (e.g. R5) must cover the protocol AND all conformances in one batch — grep first, edit all, then build.
4. Rebuild. Fixing one cluster often reveals the next layer — that is expected; repeat.

**Expect waves, not one big list.** The compiler type-checks the dependency graph in batches: each clean-looking build unlocks deeper modules with fresh errors. The Carson main app took ~40 build iterations after the "first zero-error" checkpoint; the test target took ~9 more. A build with 0 errors in the log is only final when it ends in `** BUILD SUCCEEDED **`. Budget for this: run builds in the background (`run_in_background`) and fix the next cluster while waiting — full clean builds took 8–15 min each.

**Scale the fixing strategy to cluster size.** 1–5 errors → fix directly. Same-shaped errors across 10+ files (e.g. 47 spec files, 55 conformance files) → save the deduped error list to a file (`sort -u > /tmp/errors.txt`) and dispatch parallel subagents, each owning ~10 files, with the exact fix pattern + BEFORE/AFTER code + explicit "do NOT do X" constraints in the prompt. Subagents can't build, so require them to re-read edited regions and balance braces; verify with one build after all batches land.
5. When the main build is clean, compile the tests:
   ```bash
   xcodebuild -workspace Carson.xcworkspace -scheme Carson \
     -destination 'platform=iOS Simulator,name=iPhone 16' build-for-testing 2>&1 | grep -E "error:" | sort -u
   ```
   Fix test-target errors with the cheapest compiling option (opt-outs allowed, see opt-outs.md §4).

If the simulator name is unavailable, list simulators with `xcrun simctl list devices available` and substitute any iPhone — or pass the device id directly (`-destination 'id=<UUID>'`); the error message for a bad destination lists all valid ids. A destination error exits with code 70 (not a compile failure); compile failures exit 65.

## Environment notes

- Workspace: `Carson.xcworkspace`, scheme: `Carson` (shared). CocoaPods project — never build `Carson.xcodeproj` directly.
- If pods are missing/stale: `bundle install && bundle exec pod install --repo-update`.
- Full unit-test run (optional, slower): `bundle exec fastlane unit_tests`.
- Before finishing a large batch, run `Scripts/checks.command` (assets + lint + format) — and read hard-cases.md §Tooling FIRST: the repo's SwiftLint (0.51) and SwiftFormat mis-handle `nonisolated(unsafe)` modifier order and strip `Sendable` conformances unless guarded. Run the script TWICE and confirm file checksums are stable (`md5 <file>`) — a fix that the formatter reverts on the next run isn't a fix.
- After any full SwiftFormat run, check the diff for stripped migration annotations: `git diff | grep '^-.*Sendable'`.

## Done criteria

- `build` (simulator) — zero errors. Warnings are acceptable.
- `build-for-testing` — zero errors.
- `git diff` shows only annotation-level changes (isolation attributes, Sendable conformances, type spellings) unless a recipe explicitly requires more (e.g. R6 default-value replacement).
- Every `@unchecked Sendable` / `nonisolated(unsafe)` added in main app code has a one-line justification comment.
- No iOS 16+/17+ API introduced (`@Observable`, `Observation` import, etc.) — deployment target is iOS 15.
