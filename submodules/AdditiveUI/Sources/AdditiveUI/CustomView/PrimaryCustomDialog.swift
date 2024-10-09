//
// PrimaryCustomDialog.swift
// Copyright (c) 2022 AdditiveUI
//
// Created by Hamed Hosseini on 12/14/22

import SwiftUI

public struct PrimaryCustomDialog: View {
    var title: String
    var message: String?
    var systemImageName: String?
    var textBinding: Binding<String>?
    @Binding var hideDialog: Bool
    var textPlaceholder: String?
    var submitTitle: String
    var cancelTitle: String
    var titleFont: Font = .title2
    var messageFont: Font = .subheadline
    var onSubmit: ((String) -> Void)?
    var onClose: (() -> Void)?
    @Environment(\.colorScheme) var colorScheme

    public init(title: String,
                message: String? = nil,
                systemImageName: String? = nil,
                textBinding: Binding<String>? = nil,
                hideDialog: Binding<Bool>,
                textPlaceholder: String? = nil,
                submitTitle: String = "General.submit",
                cancelTitle: String = "General.cancel",
                onSubmit: ((String) -> Void)? = nil,
                onClose: (() -> Void)? = nil) {
        self.title = title
        self.message = message
        self.systemImageName = systemImageName
        self.textBinding = textBinding
        self._hideDialog = hideDialog
        self.textPlaceholder = textPlaceholder
        self.submitTitle = submitTitle
        self.cancelTitle = cancelTitle
        self.onSubmit = onSubmit
        self.onClose = onClose
    }

    public var body: some View {
        VStack(spacing: 16) {
            if let systemImageName = systemImageName {
                Image(systemName: systemImageName)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 48)
                    .padding()
                    .foregroundColor(Color.gray)
            }

            Text(String(localized: .init(title)))
                .font(titleFont)
                .padding([.top, .bottom])
            if let message = message {
                Text(String(localized: .init(message)))
                    .font(messageFont)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(Color.gray)
                    .padding([.bottom])
            }
            if let textBinding = textBinding {
                PrimaryTextField(title: textPlaceholder ?? "",
                                 textBinding: textBinding,
                                 isEditing: true,
                                 keyboardType: .alphabet,
                                 backgroundColor: .black.opacity(0.05)) {}
                    .padding([.top, .bottom])
                    .padding(.bottom)
            }

            Button(String(localized: .init(submitTitle))) {
                onSubmit?(textBinding?.wrappedValue ?? "")
                hideDialog.toggle()
            }

            Button(String(localized: .init(cancelTitle))) {
                withAnimation {
                    hideDialog.toggle()
                    onClose?()
                }
            }
        }
    }
}

struct PrimaryCustomDialog_Previews: PreviewProvider {
    static var previews: some View {
        PrimaryCustomDialog(title: "Title",
                            message: "Message",
                            systemImageName: "trash.fill",
                            textBinding: .constant("Text"),
                            hideDialog: .constant(false))
            .preferredColorScheme(.dark)
    }
}
