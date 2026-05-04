import Testing
@testable import Easymode
import SwiftData

struct BlockSelectionTests {
    @Test @MainActor
    func saveMockSelectedApps_replacesPriorSelection() throws {
        let container = try ModelContainer(for: BlockedApp.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = container.mainContext
        let viewModel = BlockViewModel()

        context.insert(BlockedApp(bundleID: "com.apple.mail", appName: "Mail"))
        try context.save()

        let selection: Set<String> = ["com.apple.safari"]
        try viewModel.saveMockSelectedApps(selection, from: try context.fetch(FetchDescriptor<BlockedApp>()), using: context)

        let updated = try context.fetch(FetchDescriptor<BlockedApp>())
        #expect(updated.count == 1)
        #expect(updated.first?.bundleID == "com.apple.safari")
    }
}
