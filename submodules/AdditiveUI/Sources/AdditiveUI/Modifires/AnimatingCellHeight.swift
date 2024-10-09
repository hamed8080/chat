//
// AnimatingCellHeight.swift
// Copyright (c) 2022 AdditiveUI
//
// Created by Hamed Hosseini on 12/14/22


#if canImport(SwiftUI)
import SwiftUI

public struct AnimatingCellHeight: AnimatableModifier {
    public var height: CGFloat = 0

    public init(height: CGFloat) {
        self.height = height
    }

    public var animatableData: CGFloat {
        get { height }
        set { height = newValue }
    }

    public func body(content: Content) -> some View {
        content.frame(height: height)
    }
}
#endif
