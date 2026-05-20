import Testing
@testable import Easymode

/// Guards `Shared/BrandRGB.swift` and `BrandTokens` against silent drift from documented hex values.
struct BrandTokensParityTests {

    private static func rgb(fromHex24 hex: String) -> (red: Double, green: Double, blue: Double) {
        precondition(hex.count == 6, "Expected a 6-digit hex string, got \(hex)")
        guard let value = UInt64(hex, radix: 16) else {
            preconditionFailure("Invalid hex digits: \(hex)")
        }
        let red = Double((value >> 16) & 0xFF) / 255
        let green = Double((value >> 8) & 0xFF) / 255
        let blue = Double(value & 0xFF) / 255
        return (red, green, blue)
    }

    private func expectTupleClose(
        _ actual: (red: Double, green: Double, blue: Double),
        _ expected: (red: Double, green: Double, blue: Double)
    ) {
        #expect(abs(actual.red - expected.red) < 0.001)
        #expect(abs(actual.green - expected.green) < 0.001)
        #expect(abs(actual.blue - expected.blue) < 0.001)
    }

    @Test
    func brandTokens_forwardBrandRGB() {
        expectTupleClose(BrandTokens.parchmentRGB, BrandRGB.parchment)
        expectTupleClose(BrandTokens.softBlackRGB, BrandRGB.softBlack)
        expectTupleClose(BrandTokens.chartreuseRGB, BrandRGB.chartreuse)
        expectTupleClose(BrandTokens.pinkRGB, BrandRGB.pink)
    }

    @Test
    func parchment_matchesHexFBF9F5() {
        expectTupleClose(BrandRGB.parchment, Self.rgb(fromHex24: "FBF9F5"))
    }

    @Test
    func softBlack_matchesHex262626() {
        expectTupleClose(BrandRGB.softBlack, Self.rgb(fromHex24: "262626"))
    }

    @Test
    func chartreuse_matchesHex8AC926() {
        expectTupleClose(BrandRGB.chartreuse, Self.rgb(fromHex24: "8AC926"))
    }

    @Test
    func pink_matchesHexEB8698() {
        expectTupleClose(BrandRGB.pink, Self.rgb(fromHex24: "EB8698"))
    }

    @Test
    func mutedForeground_matchesHex6B6B6B() {
        expectTupleClose(BrandRGB.mutedForeground, Self.rgb(fromHex24: "6B6B6B"))
    }
}
