//
//  DebugManager.swift
//  iOSAssignment
//
//  Created by Darshan Jolapara on 28/06/23.
//

import Foundation

struct DebugManager {
    static func log(_ items: Any...) {
#if DEBUG
        for item in items {
            print("~\(item)")
        }
#endif
    }
}


