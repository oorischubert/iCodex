// FILE: TurnGitBranchSelectorTests.swift
// Purpose: Verifies new branch creation names normalize toward the icodex/ prefix without double-prefixing.
// Layer: Unit Test
// Exports: TurnGitBranchSelectorTests
// Depends on: XCTest, CodexMobile

import XCTest
@testable import CodexMobile

final class TurnGitBranchSelectorTests: XCTestCase {
    func testNormalizesCreatedBranchNamesTowardICodexPrefix() {
        XCTAssertEqual(remodexNormalizedCreatedBranchName("foo"), "icodex/foo")
        XCTAssertEqual(remodexNormalizedCreatedBranchName("icodex/foo"), "icodex/foo")
        XCTAssertEqual(remodexNormalizedCreatedBranchName("  foo  "), "icodex/foo")
    }

    func testNormalizesEmptyBranchNamesToEmptyString() {
        XCTAssertEqual(remodexNormalizedCreatedBranchName("   "), "")
    }

    func testCurrentBranchSelectionDisablesCheckedOutElsewhereRowsWhenWorktreePathIsMissing() {
        XCTAssertTrue(
            remodexCurrentBranchSelectionIsDisabled(
                branch: "icodex/feature-a",
                currentBranch: "main",
                gitBranchesCheckedOutElsewhere: ["icodex/feature-a"],
                gitWorktreePathsByBranch: [:],
                allowsSelectingCurrentBranch: true
            )
        )
    }

    func testCurrentBranchSelectionKeepsCheckedOutElsewhereRowsEnabledWhenWorktreePathExists() {
        XCTAssertFalse(
            remodexCurrentBranchSelectionIsDisabled(
                branch: "icodex/feature-a",
                currentBranch: "main",
                gitBranchesCheckedOutElsewhere: ["icodex/feature-a"],
                gitWorktreePathsByBranch: ["icodex/feature-a": "/tmp/icodex-feature-a"],
                allowsSelectingCurrentBranch: true
            )
        )
    }
}
