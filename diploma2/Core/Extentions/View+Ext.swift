//
//  View+Ext.swift
//  diploma2
//
//  Created by Symbat Bayanbayeva on 17.03.2026.
//

import SwiftUI

extension View {
    @ViewBuilder
    func `if`<T: View>(_ condition: Bool, transform: (Self) -> T) -> some View {
        if condition { transform(self) } else { self }
    }
}

