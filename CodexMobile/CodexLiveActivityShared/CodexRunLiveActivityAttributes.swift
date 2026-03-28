#if os(iOS) && canImport(ActivityKit)
import ActivityKit
import Foundation

struct CodexRunLiveActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var status: CodexRunLiveActivityStatus
        var threadTitle: String
        var detail: String
        var connection: CodexRunLiveActivityConnectionState
    }

    var threadId: String
}

enum CodexRunLiveActivityStatus: String, Codable, Hashable, Sendable {
    case running
    case needsApproval
    case reconnecting
    case completed
    case failed
    case stopped

    var label: String {
        switch self {
        case .running:
            return "Running"
        case .needsApproval:
            return "Needs Approval"
        case .reconnecting:
            return "Reconnecting"
        case .completed:
            return "Completed"
        case .failed:
            return "Failed"
        case .stopped:
            return "Stopped"
        }
    }

    var shortLabel: String {
        switch self {
        case .running:
            return "Run"
        case .needsApproval:
            return "Allow"
        case .reconnecting:
            return "Retry"
        case .completed:
            return "Done"
        case .failed:
            return "Fail"
        case .stopped:
            return "Stop"
        }
    }

    var symbolName: String {
        switch self {
        case .running:
            return "terminal"
        case .needsApproval:
            return "checkmark.shield"
        case .reconnecting:
            return "arrow.triangle.2.circlepath"
        case .completed:
            return "checkmark.circle.fill"
        case .failed:
            return "exclamationmark.triangle.fill"
        case .stopped:
            return "stop.circle.fill"
        }
    }
}

enum CodexRunLiveActivityConnectionState: String, Codable, Hashable, Sendable {
    case connected
    case connecting
    case syncing
    case offline

    var label: String {
        switch self {
        case .connected:
            return "Connected"
        case .connecting:
            return "Connecting"
        case .syncing:
            return "Syncing"
        case .offline:
            return "Offline"
        }
    }

    var shortLabel: String {
        switch self {
        case .connected:
            return "On"
        case .connecting:
            return "Link"
        case .syncing:
            return "Sync"
        case .offline:
            return "Off"
        }
    }

    var symbolName: String {
        switch self {
        case .connected:
            return "wifi"
        case .connecting:
            return "antenna.radiowaves.left.and.right"
        case .syncing:
            return "arrow.clockwise"
        case .offline:
            return "wifi.slash"
        }
    }
}
#endif
