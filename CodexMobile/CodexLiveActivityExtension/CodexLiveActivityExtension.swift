#if os(iOS) && canImport(ActivityKit)
import ActivityKit
import SwiftUI
import WidgetKit

@main
struct CodexLiveActivityExtension: WidgetBundle {
    var body: some Widget {
        CodexRunLiveActivityWidget()
    }
}

struct CodexRunLiveActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: CodexRunLiveActivityAttributes.self) { context in
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .center, spacing: 8) {
                    Label(context.state.status.label, systemImage: context.state.status.symbolName)
                        .font(.headline)
                        .foregroundStyle(statusColor(for: context.state.status))
                        .lineLimit(1)

                    Spacer(minLength: 8)

                    Label(context.state.connection.label, systemImage: context.state.connection.symbolName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                Text(context.state.threadTitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)

                Text(context.state.detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            .padding(16)
            .activityBackgroundTint(Color(.systemBackground).opacity(0.9))
            .activitySystemActionForegroundColor(.primary)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: context.state.status.symbolName)
                        .foregroundStyle(statusColor(for: context.state.status))
                }
                DynamicIslandExpandedRegion(.center) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(context.state.threadTitle)
                            .font(.headline)
                            .lineLimit(1)
                        Text(context.state.detail)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text(context.state.status.shortLabel)
                            .font(.caption.weight(.semibold))
                        Text(context.state.connection.shortLabel)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            } compactLeading: {
                Image(systemName: context.state.status.symbolName)
                    .foregroundStyle(statusColor(for: context.state.status))
            } compactTrailing: {
                Text(context.state.status.shortLabel)
                    .font(.caption2.weight(.semibold))
            } minimal: {
                Image(systemName: context.state.status.symbolName)
                    .foregroundStyle(statusColor(for: context.state.status))
            }
        }
    }

    private func statusColor(for status: CodexRunLiveActivityStatus) -> Color {
        switch status {
        case .running:
            return .blue
        case .needsApproval:
            return .orange
        case .reconnecting:
            return .yellow
        case .completed:
            return .green
        case .failed:
            return .red
        case .stopped:
            return .secondary
        }
    }
}

#Preview("Live Activity", as: .content, using: CodexRunLiveActivityAttributes(threadId: "preview-thread")) {
    CodexRunLiveActivityWidget()
} contentStates: {
    CodexRunLiveActivityAttributes.ContentState(
        status: .running,
        threadTitle: "Refactor the local relay",
        detail: "Read bridge.js",
        connection: .connected
    )
    CodexRunLiveActivityAttributes.ContentState(
        status: .needsApproval,
        threadTitle: "Review filesystem changes",
        detail: "Allow command execution",
        connection: .connected
    )
}
#endif
