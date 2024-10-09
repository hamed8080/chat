//
// KeyboardResponsiveModifier.swift
// Copyright (c) 2022 AdditiveUI
//
// Created by Hamed Hosseini on 12/14/22

#if canImport(SwiftUI)
import SwiftUI

public struct KeyboardResponsiveModifier: ViewModifier {
    @State private var offset: CGFloat = 0

    public func body(content: Content) -> some View {
        content
            .padding(.bottom, offset)
            .onAppear {
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { _ in
                    self.offset = 148
                }

                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                    self.offset = 0
                }
            }
    }
}

public struct KeyboardSizeReader: ViewModifier {
    var onSizeChanged: ((CGSize) -> ())?

    public func body(content: Content) -> some View {
        content
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { notification in
                if let rect = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    onSizeChanged?(rect.size)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)) { notification in
                onSizeChanged?(.zero)
            }
    }
}

public extension View {
    func keyboardResponsive() -> ModifiedContent<Self, KeyboardResponsiveModifier> {
        modifier(KeyboardResponsiveModifier())
    }

    func onKeyboardSize(onSizeChanged: @escaping (CGSize) -> ()) -> ModifiedContent<Self, KeyboardSizeReader> {
        modifier(KeyboardSizeReader(onSizeChanged: onSizeChanged))
    }
}
#endif
