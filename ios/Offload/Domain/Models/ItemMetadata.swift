// Purpose: Typed metadata model for Item records.
// Authority: Code-level
// Governed by: AGENTS.md
// Additional instructions: Preserve unknown metadata fields for backward and forward compatibility.

import Foundation

enum ItemMetadataValue: Codable, Equatable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case object([String: ItemMetadataValue])
    case array([ItemMetadataValue])
    case null

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
        } else if let boolValue = try? container.decode(Bool.self) {
            self = .bool(boolValue)
        } else if let intValue = try? container.decode(Int.self) {
            self = .int(intValue)
        } else if let doubleValue = try? container.decode(Double.self) {
            self = .double(doubleValue)
        } else if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else if let objectValue = try? container.decode([String: ItemMetadataValue].self) {
            self = .object(objectValue)
        } else if let arrayValue = try? container.decode([ItemMetadataValue].self) {
            self = .array(arrayValue)
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Unsupported metadata value."
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case let .string(value):
            try container.encode(value)
        case let .int(value):
            try container.encode(value)
        case let .double(value):
            try container.encode(value)
        case let .bool(value):
            try container.encode(value)
        case let .object(value):
            try container.encode(value)
        case let .array(value):
            try container.encode(value)
        case .null:
            try container.encodeNil()
        }
    }

    var foundationValue: Any {
        switch self {
        case let .string(value):
            value
        case let .int(value):
            value
        case let .double(value):
            value
        case let .bool(value):
            value
        case let .object(value):
            value.mapValues(\.foundationValue)
        case let .array(value):
            value.map(\.foundationValue)
        case .null:
            NSNull()
        }
    }

    static func fromFoundation(_ value: Any) -> ItemMetadataValue? {
        if value is NSNull {
            return .null
        }
        if let stringValue = value as? String {
            return .string(stringValue)
        }
        if let boolValue = value as? Bool {
            return .bool(boolValue)
        }
        if let intValue = value as? Int {
            return .int(intValue)
        }
        if let doubleValue = value as? Double {
            return .double(doubleValue)
        }
        if let objectValue = value as? [String: Any] {
            var parsedObject: [String: ItemMetadataValue] = [:]
            parsedObject.reserveCapacity(objectValue.count)
            for (key, objectFieldValue) in objectValue {
                guard let parsedFieldValue = ItemMetadataValue.fromFoundation(objectFieldValue) else {
                    continue
                }
                parsedObject[key] = parsedFieldValue
            }
            return .object(parsedObject)
        }
        if let arrayValue = value as? [Any] {
            var parsedArray: [ItemMetadataValue] = []
            parsedArray.reserveCapacity(arrayValue.count)
            for element in arrayValue {
                guard let parsedElement = ItemMetadataValue.fromFoundation(element) else {
                    continue
                }
                parsedArray.append(parsedElement)
            }
            return .array(parsedArray)
        }
        if let numberValue = value as? NSNumber {
            if CFGetTypeID(numberValue) == CFBooleanGetTypeID() {
                return .bool(numberValue.boolValue)
            }
            let doubleValue = numberValue.doubleValue
            if floor(doubleValue) == doubleValue,
               doubleValue >= Double(Int.min),
               doubleValue <= Double(Int.max)
            {
                return .int(numberValue.intValue)
            }
            return .double(doubleValue)
        }
        return nil
    }
}

struct ItemMetadata: Codable, Equatable {
    static let attachmentFilePathKey = "attachment_file_path"

    var attachmentFilePath: String?
    var extensions: [String: ItemMetadataValue]

    init(
        attachmentFilePath: String? = nil,
        extensions: [String: ItemMetadataValue] = [:]
    ) {
        self.attachmentFilePath = attachmentFilePath
        self.extensions = extensions
    }

    init(dictionary: [String: Any]) {
        var extensionValues: [String: ItemMetadataValue] = [:]
        extensionValues.reserveCapacity(dictionary.count)

        if let attachmentFilePath = dictionary[Self.attachmentFilePathKey] as? String {
            self.attachmentFilePath = attachmentFilePath
        } else {
            attachmentFilePath = nil
        }

        for (key, value) in dictionary where key != Self.attachmentFilePathKey {
            guard let parsedValue = ItemMetadataValue.fromFoundation(value) else {
                continue
            }
            extensionValues[key] = parsedValue
        }
        extensions = extensionValues
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DynamicCodingKey.self)
        var extensionValues: [String: ItemMetadataValue] = [:]
        var decodedAttachmentPath: String?
        extensionValues.reserveCapacity(container.allKeys.count)

        for key in container.allKeys {
            if key.stringValue == Self.attachmentFilePathKey {
                decodedAttachmentPath = try container.decodeIfPresent(String.self, forKey: key)
                continue
            }
            extensionValues[key.stringValue] = try container.decode(ItemMetadataValue.self, forKey: key)
        }

        attachmentFilePath = decodedAttachmentPath
        extensions = extensionValues
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: DynamicCodingKey.self)

        if let attachmentFilePath {
            try container.encode(
                attachmentFilePath,
                forKey: DynamicCodingKey(Self.attachmentFilePathKey)
            )
        }

        for (key, value) in extensions {
            try container.encode(value, forKey: DynamicCodingKey(key))
        }
    }

    var dictionaryRepresentation: [String: Any] {
        var dictionary = extensions.mapValues(\.foundationValue)
        if let attachmentFilePath {
            dictionary[Self.attachmentFilePathKey] = attachmentFilePath
        }
        return dictionary
    }

    static func decode(from jsonString: String) -> ItemMetadata {
        guard let data = jsonString.data(using: .utf8) else { return ItemMetadata() }
        let decoder = JSONDecoder()
        return (try? decoder.decode(ItemMetadata.self, from: data)) ?? ItemMetadata()
    }

    func encodeToJSONString() -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        guard let data = try? encoder.encode(self),
              let jsonString = String(data: data, encoding: .utf8)
        else {
            return "{}"
        }
        return jsonString
    }
}

private struct DynamicCodingKey: CodingKey {
    let stringValue: String
    let intValue: Int?

    init(_ key: String) {
        stringValue = key
        intValue = nil
    }

    init?(stringValue: String) {
        self.stringValue = stringValue
        intValue = nil
    }

    init?(intValue: Int) {
        stringValue = String(intValue)
        self.intValue = intValue
    }
}
