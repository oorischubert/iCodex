// FILE: AppEnvironment.swift
// Purpose: Centralizes local runtime endpoint and public app config lookups.
// Layer: Service
// Exports: AppEnvironment
// Depends on: Foundation

import Foundation

enum AppEnvironment {
    static let appName = "iCodex"
    static let remotePushNotificationsEnabled = false
    static let sourceBridgeInstallCommand = "cd phodex-bridge && npm install"
    static let sourceBridgeStartCommand = "cd phodex-bridge && node ./bin/icodex.js up"
    static let sourceBridgeUpdateCommand = sourceBridgeInstallCommand

    // Legal links shown in the paywall footer and Settings.
    // Keep these pointed at a public source-of-truth until the website serves dedicated legal routes.
    static let privacyPolicyURL = URL(
        string: "https://github.com/Emanuele-web04/remodex/blob/main/Legal/PRIVACY_POLICY.md"
    )!
    static let termsOfUseURL = URL(
        string: "https://github.com/Emanuele-web04/remodex/blob/main/Legal/TERMS_OF_USE.md"
    )!
}

private extension AppEnvironment {
    static func resolvedString(forInfoPlistKey key: String) -> String? {
        guard let rawValue = Bundle.main.object(forInfoDictionaryKey: key) as? String else {
            return nil
        }

        let trimmedValue = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedValue.isEmpty else {
            return nil
        }

        if trimmedValue.hasPrefix("$("), trimmedValue.hasSuffix(")") {
            return nil
        }

        return trimmedValue
    }
}
