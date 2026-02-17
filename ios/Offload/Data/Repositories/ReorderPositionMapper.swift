// Purpose: Shared reorder position mapping helper for collection-item links.
// Authority: Code-level
// Governed by: AGENTS.md
// Additional instructions: Keep reorder behavior stable while avoiding repeated linear scans.

import Foundation

enum ReorderPositionMapper {
    static func indexByItemId(_ collectionItems: [CollectionItem]) -> [UUID: CollectionItem] {
        var index: [UUID: CollectionItem] = [:]
        index.reserveCapacity(collectionItems.count)
        for collectionItem in collectionItems where index[collectionItem.itemId] == nil {
            index[collectionItem.itemId] = collectionItem
        }
        return index
    }

    static func applyPositions(
        for orderedItemIds: [UUID],
        using indexedByItemId: [UUID: CollectionItem]
    ) {
        for (position, itemId) in orderedItemIds.enumerated() {
            indexedByItemId[itemId]?.position = position
        }
    }
}
