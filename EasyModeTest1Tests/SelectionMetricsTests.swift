import Testing
@testable import EasyModeTest1

struct SelectionMetricsTests {
    @Test @MainActor
    func selectionCount_includesWebDomains() {
        let count = ScreenTimeManager.selectionCount(
            applicationCount: 1,
            categoryCount: 2,
            webDomainCount: 3
        )

        #expect(count == 6)
    }

    @Test @MainActor
    func hasAnySelection_trueForWebDomainOnlySelection() {
        let hasSelection = ScreenTimeManager.hasAnySelection(
            applicationCount: 0,
            categoryCount: 0,
            webDomainCount: 1
        )

        #expect(hasSelection == true)
    }
}
