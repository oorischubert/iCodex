// FILE: SubscriptionServiceAccessTests.swift
// Purpose: Verifies the iCodex fork keeps app access unlocked without consuming a free-send quota.
// Layer: Unit Test
// Exports: SubscriptionServiceAccessTests
// Depends on: XCTest, CodexMobile

import XCTest
@testable import CodexMobile

@MainActor
final class SubscriptionServiceAccessTests: XCTestCase {
    func testFreshUserStartsUnlocked() {
        let service = makeService()

        XCTAssertEqual(service.freeSendCount, 0)
        XCTAssertEqual(service.remainingFreeSendAttempts, 5)
        XCTAssertTrue(service.hasFreeSendAccess)
        XCTAssertTrue(service.hasAppAccess)
        XCTAssertTrue(service.hasProAccess)
    }

    func testSendAttemptsDoNotConsumeQuotaInICodexFork() {
        let service = makeService()

        for _ in 0..<7 {
            service.consumeFreeSendAttemptIfNeeded()
        }

        XCTAssertEqual(service.freeSendCount, 0)
        XCTAssertEqual(service.remainingFreeSendAttempts, 5)
        XCTAssertTrue(service.hasFreeSendAccess)
        XCTAssertTrue(service.hasAppAccess)
    }

    private func makeService() -> SubscriptionService {
        let suiteName = "SubscriptionServiceAccessTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suiteName) ?? .standard
        defaults.removePersistentDomain(forName: suiteName)
        return SubscriptionService(defaults: defaults)
    }
}
