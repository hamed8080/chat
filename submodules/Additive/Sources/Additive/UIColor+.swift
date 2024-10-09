//
// UIColor+.swift
// Copyright (c) 2022 Additive
//
// Created by Hamed Hosseini on 9/27/22.

import Foundation
#if canImport(UIKit)
    import UIKit

    public extension UIColor {
        static func random() -> UIColor {
            UIColor(
                red: .random(in: 0 ... 1),
                green: .random(in: 0 ... 1),
                blue: .random(in: 0 ... 1),
                alpha: 1.0
            )
        }
    }
#endif
