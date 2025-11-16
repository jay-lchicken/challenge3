//
//  LockscreenWidgetBundle.swift
//  LockscreenWidget
//
//  Created by Gautham Dinakaran on 14/11/25.
//

//
//  LockscreenWidgetBundle.swift
//  LockscreenWidget
//
//  Created by Gautham Dinakaran on 14/11/25.
//
import WidgetKit
import SwiftUI

@main
struct LockscreenWidgetBundle: WidgetBundle {
    var body: some Widget {
        LockscreenWidget()
        if #available(iOS 26.0, *) {
            LockscreenWidgetControl()
        }
    }
}
