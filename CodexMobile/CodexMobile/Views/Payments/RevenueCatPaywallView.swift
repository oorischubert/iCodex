// FILE: RevenueCatPaywallView.swift
// Purpose: Preserves the existing paywall entrypoint as a simple info sheet for the open-source iCodex fork.
// Layer: View
// Exports: RevenueCatPaywallView
// Depends on: SwiftUI

import SwiftUI

struct RevenueCatPaywallView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 18) {
                Text("This iCodex build has no paywall.")
                    .font(AppFont.title3(weight: .semibold))

                Text("You can use the full app locally without in-app purchases. Pair it with your own bridge and relay setup, either self-hosted directly or over Tailscale.")
                    .font(AppFont.body())
                    .foregroundStyle(.secondary)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Suggested setup")
                        .font(AppFont.caption(weight: .semibold))
                        .foregroundStyle(.secondary)

                    Text(AppEnvironment.sourceBridgeInstallCommand)
                        .font(AppFont.mono(.caption))
                        .textSelection(.enabled)

                    Text(AppEnvironment.sourceBridgeStartCommand)
                        .font(AppFont.mono(.caption))
                        .textSelection(.enabled)
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color(.secondarySystemBackground))
                )

                Spacer()
            }
            .padding(24)
            .navigationTitle("iCodex")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
