// FILE: CodexService+LiveActivity.swift
// Purpose: Publishes the current run state to the lock-screen Live Activity.
// Layer: Service
// Exports: CodexService live activity helpers

import Foundation

extension CodexService {
    func scheduleLiveActivityRefresh() {
        let snapshot = liveActivitySnapshot()
        Task { @MainActor [weak self] in
            guard let self else { return }
            await liveActivityController.sync(with: snapshot)
        }
    }

    private func liveActivitySnapshot() -> CodexRunLiveActivitySnapshot? {
        guard let threadId = liveActivityThreadId() else {
            return nil
        }

        let threadTitle = compactLiveActivityText(
            thread(for: threadId)?.displayTitle ?? CodexThread.defaultDisplayTitle,
            limit: 48
        )
        let connection = liveActivityConnectionState

        if let approval = activeApprovalForLiveActivity(threadId: threadId) {
            return CodexRunLiveActivitySnapshot(
                threadId: threadId,
                threadTitle: threadTitle,
                detail: approvalDetailLine(for: approval),
                status: .needsApproval,
                connection: connection,
                isTerminal: false
            )
        }

        if connectionRecoveryState != .idle && !isConnected {
            return CodexRunLiveActivitySnapshot(
                threadId: threadId,
                threadTitle: threadTitle,
                detail: compactLiveActivityText(connectionRecoveryDetailLine, limit: 96),
                status: .reconnecting,
                connection: connection,
                isTerminal: false
            )
        }

        if threadHasActiveOrRunningTurn(threadId) || protectedRunningFallbackThreadIDs.contains(threadId) {
            return CodexRunLiveActivitySnapshot(
                threadId: threadId,
                threadTitle: threadTitle,
                detail: runningDetailLine(for: threadId),
                status: .running,
                connection: connection,
                isTerminal: false
            )
        }

        if let terminalState = latestTurnTerminalStateByThread[threadId] {
            return CodexRunLiveActivitySnapshot(
                threadId: threadId,
                threadTitle: threadTitle,
                detail: completionDetailLine(for: threadId, state: terminalState),
                status: liveActivityStatus(for: terminalState),
                connection: connection,
                isTerminal: true
            )
        }

        return nil
    }

    private func liveActivityThreadId() -> String? {
        if let pendingThreadId = pendingApproval?.threadId?.trimmingCharacters(in: .whitespacesAndNewlines),
           !pendingThreadId.isEmpty {
            return pendingThreadId
        }

        if let activeThreadId,
           threadHasActiveOrRunningTurn(activeThreadId) || connectionRecoveryState != .idle {
            return activeThreadId
        }

        if let runningThreadId = activeTurnIdByThread.keys.sorted().first {
            return runningThreadId
        }

        if let runningThreadId = runningThreadIDs.sorted().first {
            return runningThreadId
        }

        if let fallbackThreadId = protectedRunningFallbackThreadIDs.sorted().first {
            return fallbackThreadId
        }

        if connectionRecoveryState != .idle {
            return activeThreadId ?? firstLiveThreadID()
        }

        if let completionThreadId = threadCompletionBanner?.threadId {
            return completionThreadId
        }

        let completedThreadId = latestTurnTerminalStateByThread
            .compactMap { key, value -> String? in
                switch value {
                case .completed, .failed, .stopped:
                    return key
                }
            }
            .sorted()
            .first
        return completedThreadId
    }

    private func activeApprovalForLiveActivity(threadId: String) -> CodexApprovalRequest? {
        guard let pendingApproval else { return nil }
        guard let approvalThreadId = pendingApproval.threadId?.trimmingCharacters(in: .whitespacesAndNewlines),
              !approvalThreadId.isEmpty else {
            return pendingApproval
        }
        return approvalThreadId == threadId ? pendingApproval : nil
    }

    private var liveActivityConnectionState: CodexRunLiveActivityConnectionState {
        switch connectionPhase {
        case .connected:
            return .connected
        case .connecting:
            return .connecting
        case .loadingChats, .syncing:
            return .syncing
        case .offline:
            return .offline
        }
    }

    private var connectionRecoveryDetailLine: String {
        switch connectionRecoveryState {
        case .idle:
            return "Connection unavailable"
        case .retrying(_, let message):
            return message
        }
    }

    private func approvalDetailLine(for request: CodexApprovalRequest) -> String {
        let base = firstNonEmptyLiveActivityText([
            request.reason,
            request.command.map { "Allow \($0)" },
        ]) ?? "Action needs approval"
        return compactLiveActivityText(base, limit: 96)
    }

    private func runningDetailLine(for threadId: String) -> String {
        let line = recentLiveActivityLine(
            threadId: threadId,
            turnId: activeTurnIdByThread[threadId]
        ) ?? "iCodex is thinking..."
        return compactLiveActivityText(line, limit: 96)
    }

    private func completionDetailLine(for threadId: String, state: CodexTurnTerminalState) -> String {
        let fallback: String
        switch state {
        case .completed:
            fallback = "Run completed"
        case .failed:
            fallback = compactLiveActivityText(lastErrorMessage ?? "Run failed", limit: 96)
        case .stopped:
            fallback = "Run stopped"
        }

        let line = recentLiveActivityLine(
            threadId: threadId,
            turnId: activeTurnIdByThread[threadId]
        )
        return compactLiveActivityText(line ?? fallback, limit: 96)
    }

    private func recentLiveActivityLine(threadId: String, turnId: String?) -> String? {
        let matchingEntries = recentActivityLineByThread.compactMap { key, value -> CodexRecentActivityLine? in
            if let turnId, key == "\(threadId)|\(turnId)" {
                return value
            }
            return key.hasPrefix("\(threadId)|") ? value : nil
        }

        return matchingEntries
            .sorted { $0.timestamp > $1.timestamp }
            .first?
            .line
    }

    private func liveActivityStatus(for terminalState: CodexTurnTerminalState) -> CodexRunLiveActivityStatus {
        switch terminalState {
        case .completed:
            return .completed
        case .failed:
            return .failed
        case .stopped:
            return .stopped
        }
    }

    private func compactLiveActivityText(_ value: String, limit: Int) -> String {
        let normalized = value
            .split(whereSeparator: \.isNewline)
            .joined(separator: " ")
            .replacingOccurrences(of: "\\s+", with: " ", options: .regularExpression)
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard normalized.count > limit else {
            return normalized
        }

        let endIndex = normalized.index(normalized.startIndex, offsetBy: limit)
        return normalized[..<endIndex].trimmingCharacters(in: .whitespacesAndNewlines) + "…"
    }

    private func firstNonEmptyLiveActivityText(_ values: [String?]) -> String? {
        for value in values {
            guard let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines),
                  !trimmed.isEmpty else {
                continue
            }
            return trimmed
        }
        return nil
    }
}
