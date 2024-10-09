//
// View+.swift
// Copyright (c) 2022 AdditiveUI
//
// Created by Hamed Hosseini on 12/14/22

#if canImport(SwiftUI) && canImport(UIKit)
import SwiftUI
import UIKit

@available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
public extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }

    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }

    var canImportWebRTC: Bool {
        var canImoprt = false
#if canImport(WebRTC)
        canImoprt = true
#endif
        return canImoprt
    }

    @ViewBuilder func noSeparators() -> some View {
        if #available(iOS 15.0, macOS 13.0, *) { // iOS 14
            self.listRowSeparator(.hidden)
        } else { // iOS 13
            listStyle(.plain)
                .onAppear {
                    UITableView.appearance().separatorStyle = .none
                }
        }
    }
}
#endif
