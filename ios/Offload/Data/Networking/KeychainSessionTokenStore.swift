// Purpose: Keychain-backed session token persistence.
// Authority: Code-level
// Governed by: CLAUDE.md
// Additional instructions: Tokens stored in iOS Keychain for secure persistence across app launches.

import Foundation
import Security

/// Persists session tokens in the iOS Keychain so they survive app restarts.
///
/// Uses `kSecClassGenericPassword` items scoped to the `wc.Offload.session` service.
/// The token string and ISO 8601-encoded expiry date are stored as separate Keychain entries.
final class KeychainSessionTokenStore: SessionTokenStore {
    private let service = "wc.Offload.session"
    private let tokenKey = "session_token"
    private let expiryKey = "session_expiry"

    /// The current session token, or `nil` if no session is stored.
    var token: String? {
        get { read(key: tokenKey) }
        set {
            if let value = newValue { save(key: tokenKey, value: value) }
            else { delete(key: tokenKey) }
        }
    }

    /// The expiry date of the current session token, or `nil` if not set.
    var expiresAt: Date? {
        get {
            guard let string = read(key: expiryKey) else { return nil }
            return ISO8601DateFormatter().date(from: string)
        }
        set {
            if let value = newValue {
                save(key: expiryKey, value: ISO8601DateFormatter().string(from: value))
            } else {
                delete(key: expiryKey)
            }
        }
    }

    /// Removes both the token and expiry from the Keychain.
    func clear() {
        delete(key: tokenKey)
        delete(key: expiryKey)
    }

    // MARK: - Private Keychain helpers

    private func save(key: String, value: String) {
        let data = Data(value.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
        ]
        SecItemDelete(query as CFDictionary)
        var addQuery = query
        addQuery[kSecValueData as String] = data
        SecItemAdd(addQuery as CFDictionary, nil)
    }

    private func read(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }

    private func delete(key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: key,
        ]
        SecItemDelete(query as CFDictionary)
    }
}
