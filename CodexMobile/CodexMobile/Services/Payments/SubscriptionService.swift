// FILE: SubscriptionService.swift
// Purpose: Keeps the open-source iCodex build permanently unlocked without store purchases.
// Layer: Service
// Exports: SubscriptionService, SubscriptionPackageOption
// Depends on: Foundation, Observation

import Foundation
import Observation

enum SubscriptionBootstrapState: Equatable {
    case idle
    case loading
    case ready
    case failed
}

struct SubscriptionPackageOption: Identifiable {
    let id: String
    let title: String
    let price: String
    let periodLabel: String
    let termsDescription: String
}

@MainActor
@Observable
final class SubscriptionService {
    private(set) var bootstrapState: SubscriptionBootstrapState = .ready
    private(set) var packageOptions: [SubscriptionPackageOption] = []
    private(set) var hasProAccess = true
    private(set) var latestPurchaseDate: Date?
    private(set) var willRenew = false
    private(set) var managementURL: URL?
    private(set) var isLoading = false
    private(set) var isPurchasing = false
    private(set) var isRestoring = false
    private(set) var lastErrorMessage: String?

    func bootstrap() async {
        bootstrapState = .ready
        hasProAccess = true
        lastErrorMessage = nil
    }

    func refreshCustomerInfoSilently() async {
        bootstrapState = .ready
        hasProAccess = true
        lastErrorMessage = nil
    }

    func loadOfferings() async {
        lastErrorMessage = nil
    }

    func purchase(_ option: SubscriptionPackageOption) async {
        _ = option
        bootstrapState = .ready
        hasProAccess = true
        lastErrorMessage = nil
    }

    func restorePurchases() async {
        bootstrapState = .ready
        hasProAccess = true
        lastErrorMessage = nil
    }
}
