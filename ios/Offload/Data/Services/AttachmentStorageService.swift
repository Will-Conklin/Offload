// Purpose: File-backed storage for item attachments.
// Authority: Code-level
// Governed by: AGENTS.md
// Additional instructions: Keep attachment writes atomic and scoped to app-owned storage.

import Foundation

protocol AttachmentStorage {
    func storeAttachment(_ data: Data, for itemId: UUID) throws -> String
    func loadAttachment(at path: String) throws -> Data
    func removeAttachment(at path: String) throws
    func attachmentExists(at path: String) -> Bool
}

struct AttachmentStorageService: AttachmentStorage {
    private let fileManager: FileManager
    private let attachmentsDirectoryURL: URL

    init(
        fileManager: FileManager = .default,
        baseDirectoryURL: URL? = nil
    ) {
        self.fileManager = fileManager
        if let baseDirectoryURL {
            attachmentsDirectoryURL = baseDirectoryURL
        } else {
            let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
                ?? fileManager.temporaryDirectory
            attachmentsDirectoryURL = appSupport
                .appendingPathComponent("Offload", isDirectory: true)
                .appendingPathComponent("Attachments", isDirectory: true)
        }
    }

    func storeAttachment(_ data: Data, for itemId: UUID) throws -> String {
        try ensureAttachmentsDirectory()
        let filename = "\(itemId.uuidString)-\(UUID().uuidString).attachment"
        let fileURL = attachmentsDirectoryURL.appendingPathComponent(filename, isDirectory: false)
        try data.write(to: fileURL, options: .atomic)
        return fileURL.standardizedFileURL.path
    }

    func loadAttachment(at path: String) throws -> Data {
        let fileURL = try validatedAttachmentURL(for: path)
        return try Data(contentsOf: fileURL, options: .mappedIfSafe)
    }

    func removeAttachment(at path: String) throws {
        let fileURL = try validatedAttachmentURL(for: path)
        guard fileManager.fileExists(atPath: fileURL.path) else { return }
        try fileManager.removeItem(at: fileURL)
    }

    func attachmentExists(at path: String) -> Bool {
        guard let fileURL = try? validatedAttachmentURL(for: path) else {
            return false
        }
        return fileManager.fileExists(atPath: fileURL.path)
    }

    private func ensureAttachmentsDirectory() throws {
        var isDirectory: ObjCBool = false
        if fileManager.fileExists(atPath: attachmentsDirectoryURL.path, isDirectory: &isDirectory), isDirectory.boolValue {
            return
        }
        try fileManager.createDirectory(
            at: attachmentsDirectoryURL,
            withIntermediateDirectories: true
        )
    }

    private func validatedAttachmentURL(for path: String) throws -> URL {
        let candidateURL = URL(fileURLWithPath: path)
            .standardizedFileURL
            .resolvingSymlinksInPath()
        let rootURL = attachmentsDirectoryURL
            .standardizedFileURL
            .resolvingSymlinksInPath()

        let rootPath = rootURL.path.hasSuffix("/") ? rootURL.path : rootURL.path + "/"
        guard candidateURL.path.hasPrefix(rootPath) else {
            throw ValidationError("Attachment path is outside app-managed storage.")
        }
        return candidateURL
    }
}
