//
// BorderedTextFieldStyle.swift
// Copyright (c) 2022 AdditiveUI
//
// Created by Hamed Hosseini on 12/14/22

#if canImport(SwiftUI)
import SwiftUI

public struct BorderedTextFieldStyle: TextFieldStyle {
    let minHeight: CGFloat
    let cornerRadius: CGFloat
    let bgColor: Color
    let borderColor: Color
    let padding: CGFloat
    let strokeStyle: StrokeStyle

    public init(minHeight: CGFloat = 36,
                cornerRadius: CGFloat = 5,
                bgColor: Color = .gray.opacity(0.05),
                borderColor: Color = .gray.opacity(0.6),
                padding: CGFloat = 8,
                strokeStyle: StrokeStyle = .init(lineWidth: 1, lineCap: .round, lineJoin: .round)
    ) {
        self.minHeight = minHeight
        self.cornerRadius = cornerRadius
        self.bgColor = bgColor
        self.padding = padding
        self.borderColor = borderColor
        self.strokeStyle = strokeStyle
    }

    public func _body(configuration: TextField<_Label>) -> some View {
        configuration
            .frame(minHeight: minHeight)
            .padding(padding)
            .background(bgColor)
            .cornerRadius(cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(style: strokeStyle)
                    .stroke(borderColor)
            )
    }
}

struct BorderedTextFieldStyle_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            TextField("type contact", text: Binding(get: { "" }, set: { _ in }))
                .textFieldStyle(BorderedTextFieldStyle())
        }
    }
}

extension TextFieldStyle where Self == BorderedTextFieldStyle {
    /// A custom bordered text filed style.
    public static func customBorderedWith(minHeight: CGFloat = 36, cornerRadius: CGFloat = 5) -> BorderedTextFieldStyle { BorderedTextFieldStyle(minHeight: minHeight, cornerRadius: cornerRadius) }
    public static var customBordered: BorderedTextFieldStyle { BorderedTextFieldStyle() }
    public static var clear: BorderedTextFieldStyle { BorderedTextFieldStyle(minHeight: 36,
                                                                             cornerRadius: 0,
                                                                             bgColor: .clear,
                                                                             borderColor: .clear) }
}

#endif
