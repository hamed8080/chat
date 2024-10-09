//
// RoundedCorner+.swift
// Copyright (c) 2022 AdditiveUI
//
// Created by Hamed Hosseini on 12/14/22

#if canImport(UIKit) && canImport(SwiftUI)
import SwiftUI
import UIKit

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    public func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
#endif
