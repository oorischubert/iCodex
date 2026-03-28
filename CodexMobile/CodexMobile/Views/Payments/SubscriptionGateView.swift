// FILE: SubscriptionGateView.swift
// Purpose: Backward-compatible placeholder for the removed paywall in the iCodex fork.
// Layer: View
// Exports: SubscriptionGateView, SubscriptionBootstrapFailureView
// Depends on: SwiftUI

import SwiftUI

struct SubscriptionGateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image("AppLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

            Text("iCodex is unlocked")
                .font(AppFont.system(size: 24, weight: .bold))
                .multilineTextAlignment(.center)

            Text("This fork removes in-app purchases. Use your own relay path: self-hosted directly or through Tailscale.")
                .font(AppFont.body())
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            VStack(alignment: .leading, spacing: 10) {
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
        }
        .padding(24)
    }
}

struct SubscriptionBootstrapFailureView: View {
    var body: some View {
        SubscriptionGateView()
    }
}
