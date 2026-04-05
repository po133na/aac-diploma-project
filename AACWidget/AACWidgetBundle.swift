//
//  AACWidgetBundle.swift
//  AACWidget
//
//  Created by Symbat Bayanbayeva on 06.04.2026.
//

import WidgetKit
import SwiftUI

@main
struct AACWidgetBundle: WidgetBundle {
    var body: some Widget {
        AACWidget()
        AACWidgetControl()
        AACWidgetLiveActivity()
    }
}
