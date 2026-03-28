// FILE: CodexLiveActivityController.swift
// Purpose: Owns the single lock-screen Live Activity that mirrors the current iCodex run.
// Layer: Service
// Exports: CodexLiveActivityController

import Foundation

#if os(iOS) && canImport(ActivityKit)
import ActivityKit

struct CodexRunLiveActivitySnapshot: Equatable {
    let threadId: String
    let threadTitle: String
    let detail: String
    let status: CodexRunLiveActivityStatus
    let connection: CodexRunLiveActivityConnectionState
    let isTerminal: Bool

    var contentState: CodexRunLiveActivityAttributes.ContentState {
        CodexRunLiveActivityAttributes.ContentState(
            status: status,
            threadTitle: threadTitle,
            detail: detail,
            connection: connection
        )
    }

    var staleDate: Date? {
        guard !isTerminal else { return nil }
        return Date().addingTimeInterval(90)
    }
}

@MainActor
final class CodexLiveActivityController {
    private var currentActivity: Activity<CodexRunLiveActivityAttributes>?
    private var currentSnapshot: CodexRunLiveActivitySnapshot?

    func sync(with snapshot: CodexRunLiveActivitySnapshot?) async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            currentSnapshot = nil
            currentActivity = nil
            await endAllActivities(dismissalPolicy: .immediate)
            return
        }

        guard let snapshot else {
            currentSnapshot = nil
            currentActivity = nil
            await endAllActivities(dismissalPolicy: .immediate)
            return
        }

        if currentActivity?.attributes.threadId != snapshot.threadId {
            currentActivity = nil
            currentSnapshot = nil
        }

        if currentActivity == nil {
            let activities = Activity<CodexRunLiveActivityAttributes>.activities
            currentActivity = activities.first { $0.attributes.threadId == snapshot.threadId }
            if currentActivity == nil, !activities.isEmpty {
                await endAllActivities(dismissalPolicy: .immediate)
            }
        }

        if let currentActivity {
            guard currentSnapshot != snapshot else { return }

            let content = ActivityContent(state: snapshot.contentState, staleDate: snapshot.staleDate)
            if snapshot.isTerminal {
                await currentActivity.end(
                    content,
                    dismissalPolicy: .after(Date().addingTimeInterval(15 * 60))
                )
                self.currentActivity = nil
            } else {
                await currentActivity.update(content)
            }

            currentSnapshot = snapshot
            return
        }

        guard !snapshot.isTerminal else { return }

        do {
            currentActivity = try Activity.request(
                attributes: CodexRunLiveActivityAttributes(threadId: snapshot.threadId),
                content: ActivityContent(state: snapshot.contentState, staleDate: snapshot.staleDate),
                pushType: nil
            )
            currentSnapshot = snapshot
        } catch {
            currentActivity = nil
            currentSnapshot = nil
        }
    }

    private func endAllActivities(dismissalPolicy: ActivityUIDismissalPolicy) async {
        for activity in Activity<CodexRunLiveActivityAttributes>.activities {
            let state = currentSnapshot?.contentState
                ?? CodexRunLiveActivityAttributes.ContentState(
                    status: .stopped,
                    threadTitle: "iCodex",
                    detail: "No active run",
                    connection: .offline
                )
            await activity.end(
                ActivityContent(state: state, staleDate: nil),
                dismissalPolicy: dismissalPolicy
            )
        }
    }
}
#else
struct CodexRunLiveActivitySnapshot: Equatable {
    let threadId: String
    let threadTitle: String
    let detail: String
    let status: String
    let connection: String
    let isTerminal: Bool
}

@MainActor
final class CodexLiveActivityController {
    func sync(with snapshot: CodexRunLiveActivitySnapshot?) async {}
}
#endif
