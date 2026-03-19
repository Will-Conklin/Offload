// Purpose: Unit tests for QuotaStore (UserDefaults + Keychain mirror).
// Authority: Code-level
// Governed by: CLAUDE.md

@testable import Offload
import XCTest

final class QuotaStoreTests: XCTestCase {
    private var defaults: UserDefaults!

    override func setUp() {
        super.setUp()
        defaults = UserDefaults(suiteName: "QuotaStoreTests-\(UUID().uuidString)")!
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: defaults.description)
        defaults = nil
        super.tearDown()
    }

    // MARK: - Basic increment and count

    func testIncrementIncreasesLocalCount() {
        let store = QuotaStore(defaults: defaults)
        store.increment(feature: "breakdown", by: 3)
        XCTAssertEqual(store.localCount(for: "breakdown"), 3)
    }

    func testMergedCountReturnsMaxOfLocalAndServer() {
        let store = QuotaStore(defaults: defaults)
        store.increment(feature: "breakdown", by: 5)
        store.updateServerCount(feature: "breakdown", serverCount: 8)
        XCTAssertEqual(store.mergedCount(for: "breakdown"), 8)
    }

    func testMergedCountReturnsLocalWhenHigher() {
        let store = QuotaStore(defaults: defaults)
        store.increment(feature: "breakdown", by: 10)
        store.updateServerCount(feature: "breakdown", serverCount: 3)
        XCTAssertEqual(store.mergedCount(for: "breakdown"), 10)
    }

    // MARK: - totalMergedCount

    func testTotalMergedCountSumsAcrossFeatures() {
        let store = QuotaStore(defaults: defaults)
        store.increment(feature: "breakdown", by: 20)
        store.increment(feature: "braindump", by: 15)
        store.increment(feature: "decide", by: 5)
        XCTAssertEqual(store.totalMergedCount(for: ["breakdown", "braindump", "decide"]), 40)
    }

    func testTotalMergedCountEmptyFeatures() {
        let store = QuotaStore(defaults: defaults)
        store.increment(feature: "breakdown", by: 10)
        XCTAssertEqual(store.totalMergedCount(for: []), 0)
    }

    // MARK: - updateServerCount never decreases

    func testUpdateServerCountDoesNotDecrease() {
        let store = QuotaStore(defaults: defaults)
        store.updateServerCount(feature: "breakdown", serverCount: 10)
        store.updateServerCount(feature: "breakdown", serverCount: 3)
        XCTAssertEqual(store.mergedCount(for: "breakdown"), 10)
    }

    // MARK: - Keychain mirror survives UserDefaults reset

    func testKeychainMirrorRestoredAfterUserDefaultsReset() {
        let store = QuotaStore(defaults: defaults)
        store.updateServerCount(feature: "breakdown", serverCount: 42)

        // Simulate UserDefaults cleared (e.g., app reinstall)
        defaults.removePersistentDomain(forName: defaults.description)
        let freshDefaults = UserDefaults(suiteName: "QuotaStoreTests-fresh-\(UUID().uuidString)")!
        let reinstalledStore = QuotaStore(defaults: freshDefaults)

        // Keychain should restore the server count
        XCTAssertGreaterThanOrEqual(reinstalledStore.mergedCount(for: "breakdown"), 42)

        // Clean up Keychain entry used by this test
        KeychainItem(account: "quota.breakdown.server").delete()
        freshDefaults.removePersistentDomain(forName: freshDefaults.description)
    }

    func testKeychainServerCountUsedInMerged() {
        // Write directly to Keychain to simulate value from prior install
        if let data = "77".data(using: .utf8) {
            KeychainItem(account: "quota.braindump.server").write(data)
        }

        // Fresh store (clean UserDefaults) should read Keychain value
        let store = QuotaStore(defaults: defaults)
        XCTAssertGreaterThanOrEqual(store.mergedCount(for: "braindump"), 77)

        // Clean up
        KeychainItem(account: "quota.braindump.server").delete()
    }
}
