// Purpose: Performance benchmarks for repository queries.
// Authority: Code-level
// Governed by: AGENTS.md
// Additional instructions: Keep tests deterministic and avoid relying on network or time.

import XCTest
import SwiftData
@testable import Offload


@MainActor
final class PerformanceBenchmarkTests: XCTestCase {
    private func makeContainer() throws -> ModelContainer {
        let schema = Schema([
            Item.self,
            Collection.self,
            CollectionItem.self,
            Tag.self,
        ])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [configuration])
    }

    private func seedItems(
        count: Int,
        modelContext: ModelContext,
        configure: ((Item, Int) -> Void)? = nil
    ) throws {
        guard count > 0 else { return }
        for index in 0..<count {
            let item = Item(content: "Item \(index)")
            configure?(item, index)
            modelContext.insert(item)
        }
        try modelContext.save()
    }

    private func benchmarkFetchAll(count: Int) throws {
        let container = try makeContainer()
        let context = container.mainContext
        let repository = ItemRepository(modelContext: context)
        try seedItems(count: count, modelContext: context)

        let options = XCTMeasureOptions()
        options.iterationCount = 3
        measure(metrics: [XCTClockMetric()], options: options) {
            XCTAssertNoThrow(try repository.fetchAll())
        }
    }

    private func benchmarkFetchCaptureItems(count: Int) throws {
        let container = try makeContainer()
        let context = container.mainContext
        let repository = ItemRepository(modelContext: context)
        let completedAt = Date(timeIntervalSince1970: 0)
        try seedItems(count: count, modelContext: context) { item, index in
            if index.isMultiple(of: 2) {
                item.type = "task"
            }
            if index.isMultiple(of: 10) {
                item.completedAt = completedAt
            }
        }

        let options = XCTMeasureOptions()
        options.iterationCount = 3
        measure(metrics: [XCTClockMetric()], options: options) {
            XCTAssertNoThrow(try repository.fetchCaptureItems())
        }
    }

    private func benchmarkFetchByTag(count: Int, tag: String) throws {
        let container = try makeContainer()
        let context = container.mainContext
        let repository = ItemRepository(modelContext: context)
        try seedItems(count: count, modelContext: context) { item, index in
            if index.isMultiple(of: 3) {
                item.tags = [tag]
            } else if index.isMultiple(of: 5) {
                item.tags = ["other"]
            }
        }

        let options = XCTMeasureOptions()
        options.iterationCount = 3
        measure(metrics: [XCTClockMetric()], options: options) {
            XCTAssertNoThrow(try repository.fetchByTag(tag))
        }
    }

    func testFetchAllPerformance100Items() throws {
        try benchmarkFetchAll(count: 100)
    }

    func testFetchAllPerformance1000Items() throws {
        try benchmarkFetchAll(count: 1_000)
    }

    func testFetchAllPerformance10000Items() throws {
        try benchmarkFetchAll(count: 10_000)
    }

    func testFetchCaptureItemsPerformance100Items() throws {
        try benchmarkFetchCaptureItems(count: 100)
    }

    func testFetchCaptureItemsPerformance1000Items() throws {
        try benchmarkFetchCaptureItems(count: 1_000)
    }

    func testFetchCaptureItemsPerformance10000Items() throws {
        try benchmarkFetchCaptureItems(count: 10_000)
    }

    func testFetchByTagPerformance100Items() throws {
        try benchmarkFetchByTag(count: 100, tag: "work")
    }

    func testFetchByTagPerformance1000Items() throws {
        try benchmarkFetchByTag(count: 1_000, tag: "work")
    }

    func testFetchByTagPerformance10000Items() throws {
        try benchmarkFetchByTag(count: 10_000, tag: "work")
    }
}
