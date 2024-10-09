//
// Image+.swift
// Copyright (c) 2022 AdditiveUI
//
// Created by Hamed Hosseini on 12/14/22

#if canImport(SwiftUI) && canImport(UIKit)
import UIKit
import SwiftUI

@available(iOS 13.0, tvOS 13.0, watchOS 6.0, *)
public extension Image {
    init(cgImage: CGImage) {
        self = Image(uiImage: UIImage(cgImage: cgImage))
    }
}
#endif
