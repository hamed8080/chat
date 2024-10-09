//
// PrimaryTextField.swift
// Copyright (c) 2022 AdditiveUI
//
// Created by Hamed Hosseini on 12/14/22

import SwiftUI

public struct PrimaryTextField: View {
    public enum FocusField: Hashable {
        case field
    }

    var title: String
    @Binding var textBinding: String
    @State var isEditing: Bool
    var keyboardType: UIKeyboardType
    var corenrRadius: CGFloat
    var backgroundColor: Color
    @FocusState var focusedField: FocusField?
    var onCommit: (() -> Void)?

    public init(title: String,
                textBinding: Binding<String>,
                isEditing: Bool = false,
                keyboardType: UIKeyboardType = .phonePad,
                corenrRadius: CGFloat = 8,
                backgroundColor: Color = .white,
                focusedField: FocusField? = nil,
                onCommit: ( () -> Void)? = nil
    ) {
        self.title = title
        self._textBinding = textBinding
        self.isEditing = isEditing
        self.keyboardType = keyboardType
        self.corenrRadius = corenrRadius
        self.backgroundColor = backgroundColor
        self.focusedField = focusedField
        self.onCommit = onCommit
    }

    public var body: some View {
        TextField(String(localized: .init(title)), text: $textBinding) { isEditing in
            self.isEditing = isEditing
        } onCommit: {
            onCommit?()
        }
        .keyboardType(keyboardType)
        .padding(.init(top: 0, leading: 8, bottom: 0, trailing: 0))
        .frame(minHeight: 56)
        .focused($focusedField, equals: .field)
        .background(
            backgroundColor.cornerRadius(corenrRadius)
                .onTapGesture {
                    if focusedField != .field {
                        focusedField = .field
                    }
                }
        )
        .overlay(RoundedRectangle(cornerRadius: 8).stroke(isEditing ? Color.gray : Color.clear))
    }
}

struct PrimaryTextField_Previews: PreviewProvider {
    @State static var text: String = ""

    static var previews: some View {
        VStack {
            PrimaryTextField(title: "Placeholder", textBinding: $text)
            PrimaryTextField(title: "Placeholder", textBinding: $text)
        }
    }
}
