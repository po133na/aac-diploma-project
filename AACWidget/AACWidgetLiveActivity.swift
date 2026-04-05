//
//  AACWidgetLiveActivity.swift
//  AACWidget
//
//  Created by Symbat Bayanbayeva on 06.04.2026.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct AACWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct AACWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: AACWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension AACWidgetAttributes {
    fileprivate static var preview: AACWidgetAttributes {
        AACWidgetAttributes(name: "World")
    }
}

extension AACWidgetAttributes.ContentState {
    fileprivate static var smiley: AACWidgetAttributes.ContentState {
        AACWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: AACWidgetAttributes.ContentState {
         AACWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: AACWidgetAttributes.preview) {
   AACWidgetLiveActivity()
} contentStates: {
    AACWidgetAttributes.ContentState.smiley
    AACWidgetAttributes.ContentState.starEyes
}
