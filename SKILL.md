---
name: swift-trap-fuzz
description: Catch Swift runtime traps (Int overflow, Int(Double.nan), out-of-range casts, array index, precondition) that table-driven unit tests structurally cannot see. Use when a Swift/SwiftUI app does arithmetic on user input, converts Double to Int, uses rational/fixed-point math, or when all tests are green but users can crash the app with two taps. Gives the fuzz recipe and the safe-arithmetic fixes.
---

# swift-trap-fuzz

In Swift these are **traps** - the process dies, `XCTAssert` never gets to fail:
`Int` overflow in `+ - *`, `Int(Double.nan)`, `Int(.infinity)`, `Int(outOfRange)`, array subscript out of range,
failed `precondition`.

A table of expected values only checks the answers you wrote down. Code review, static analysis and property tests help too, but the most reliable way to find traps is to
**run thousands of random extreme inputs and see whether the process survives.**

## Fuzz recipe

- Fixed-seed LCG so a failure reproduces. Draw often from boundaries: 0, 1, -1, the cap, cap+1, huge, NaN, inf.
- Drive the *public* engine entry points the UI uses, not internals.
- Pass criterion: process exits normally. Capture the `.ips` crash log for the failing site
  (see [`ios-simulator-ui-test-hygiene`](https://github.com/Kein-chronicle/ios-simulator-ui-test-hygiene) for keeping logs while silencing the dialog).

Typical catch (from the author's own apps): a calculator crashed after two taps because a rational approximation of pi multiplied by a unit-conversion rational overflowed `Int64` inside the denominator, and
every table-driven test passed. The same fuzz, added once, also found `Int(Double)` traps in other apps (a parser accepting `1e300`, a unit conversion, a degrees-minutes-seconds converter).

## Fix patterns (keep accuracy)

- Use `multipliedReportingOverflow` / `addingReportingOverflow`. If it doesn't fit, **retry at lower precision**.
- Degrade in **one direction only**. "Must not under-order" domains (concrete) always round up.
- Reduce precision correctly: shifting numerator and denominator by the *same* bits crushes a small denominator
  (0.3 % drift). Fit the numerator to the limit and scale the denominator by the same ratio -> relative error
  stays ~1/limit. Use 128-bit `multipliedFullWidth` / `dividingFullWidth` for intermediates.
- `(n + d - 1) / d` ceil overflows at the `+`. Divide first, then adjust.
- A declared max constant (`Length.max`) that `init` never clamps against is decoration.
- Bounds checks: `Double(Int.max)` rounds up to exactly 2^63, which is one more than `Int.max`. So `x < Double(Int.max)` is a correct upper bound, while `x <= Double(Int.max)` lets 2^63 through and
  `Int(x)` traps. Check `x.isFinite` first, prefer `Int(exactly: x)` (returns `nil` instead of trapping) or clamp against a clearly smaller constant such as `9.2e18`.
- User input that becomes a view count (`ForEach(1..<n)`) is the same family: cap it.

Status: doc-only (no runnable Swift harness in this repo yet; see `references/fuzz-skeleton.swift` for a starting point).
