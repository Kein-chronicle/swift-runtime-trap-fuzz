// Skeleton, not a drop-in: adapt `engine` to your app's public API. Deterministic so failures reproduce.
struct LCG { var s: UInt64; mutating func next() -> UInt64 { s = s &* 6364136223846793005 &+ 1442695040888963407; return s } }

func extremeDouble(_ g: inout LCG) -> Double {
    let pool: [Double] = [0, 1, -1, .nan, .infinity, -.infinity, 1e300, -1e300, 9.2e18, 9.3e18, 0.0000001, Double(Int32.max)]
    return g.next() % 3 == 0 ? pool[Int(g.next() % UInt64(pool.count))] : Double(bitPattern: g.next())
}

func fuzz(iterations: Int = 20_000, seed: UInt64 = 42, engine: (Double, Int) -> Void) {
    var g = LCG(s: seed)
    for _ in 0..<iterations {
        let d = extremeDouble(&g)
        let n = Int(truncatingIfNeeded: g.next())   // truncating: never trap in the fuzzer itself
        engine(d, n)                                 // a trap kills the process => the test run fails loudly
    }
}
