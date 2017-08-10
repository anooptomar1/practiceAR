//
//  Utilities.swift
//  practiceAR
//
//  Created by cl-dev on 2017-08-09.
//  Copyright © 2017 Connected Lab. All rights reserved.
//

import Foundation
import UIKit

// https://developer.apple.com/videos/play/wwdc2017/506/
extension CGImagePropertyOrientation {
    init(_ orientation: UIImageOrientation) {
        switch orientation {
        case .up:
            self = .up
        case .upMirrored:
            self = .upMirrored
        case .down:
            self = .down
        case .downMirrored:
            self = .downMirrored
        case .left:
            self = .left
        case .leftMirrored:
            self = .leftMirrored
        case .right:
            self = .right
        case .rightMirrored:
            self = .rightMirrored
        }
    }
}
