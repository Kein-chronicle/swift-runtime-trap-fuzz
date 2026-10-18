# swift-runtime-trap-fuzz

**Catch Swift runtime traps that unit tests cannot see: Int overflow, Int(Double.nan), bad casts and index errors, with a fuzz recipe and safe-arithmetic fixes.**

[![test](https://github.com/Kein-chronicle/swift-runtime-trap-fuzz/actions/workflows/test.yml/badge.svg)](https://github.com/Kein-chronicle/swift-runtime-trap-fuzz/actions/workflows/test.yml) ![license](https://img.shields.io/badge/license-MIT-blue.svg)

## Why

Table-driven tests only visit the cases you thought of. Swift traps (arithmetic overflow, converting NaN to Int, out-of-range casts) kill the process, so one odd input from a user is a crash. A small fuzz harness finds them before the App Store reviewers do.

> **Status: doc-only.** A recipe and a skeleton, not a packaged library; adapt the harness to your app's entry points.

## Install

**As a Claude Code skill** (Claude uses it when the task matches the skill description):

```sh
git clone https://github.com/Kein-chronicle/swift-runtime-trap-fuzz.git ~/.claude/skills/swift-trap-fuzz
```

For a single project, clone into `<project>/.claude/skills/swift-trap-fuzz` instead, then start a new Claude Code session.

**Just read it:** the whole skill is [SKILL.md](SKILL.md). It is plain Markdown; copy any part into your own `CLAUDE.md` or prompts.

**Requires:** nothing to read it; Python 3.10+ only to run `validate.py`.

## What it covers

- Fuzz recipe: generate inputs outside your tables and run the code path.
- Fix patterns that keep accuracy instead of clamping blindly.
- `references/fuzz-skeleton.swift` is a starting harness.

## Limits

- A recipe and a skeleton, not a packaged library; adapt the harness to your app's entry points.

## Related projects

These solve neighbouring problems; use them when they fit better.

- **swift-testing / XCTest**: the test frameworks the harness runs under
- **libFuzzer / SwiftPM fuzzing**: coverage-guided fuzzers; this recipe is the lightweight randomized version

## More from the same collection

Small, tested tools that grew out of running AI agents and game/app pipelines for months:

- [**safe-delete-sole-copy-check**](https://github.com/Kein-chronicle/safe-delete-sole-copy-check): Before you delete a project folder: is any of it the only copy? Checks the live remote, unpushed commits and tags, untracked and ignored files, and verifies copies by hash.
- [**exif-orientation-guard**](https://github.com/Kein-chronicle/exif-orientation-guard): Find and fix images whose stored size differs from their displayed size because of an EXIF orientation tag.
- [**macos-tcc-automation-permissions**](https://github.com/Kein-chronicle/macos-tcc-automation-permissions): Make unattended macOS automation survive permission resets: AppleScript -1743/-1728, launchd jobs, screen recording, and real vs synthetic clicks.

## Development

```sh
python3 validate.py
```

This only validates the skill file (frontmatter and referenced paths). See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT. See [LICENSE](LICENSE).

If this saved you a debugging session, a star helps other people find it. Bug reports and failing test cases are even better.

<sub>Keywords: swift, swiftui, ios, fuzzing, crash, integer-overflow, testing, claude-skills</sub>
