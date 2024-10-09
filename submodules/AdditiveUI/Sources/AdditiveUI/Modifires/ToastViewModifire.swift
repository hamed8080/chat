//
// TopNotifyViewModifire.swift
// Copyright (c) 2022 AdditiveUI
//
// Created by Hamed Hosseini on 12/14/22

#if canImport(SwiftUI)
import SwiftUI
import Combine

public struct TopNotifyViewModifire<ContentView: View>: ViewModifier {
    @Binding private var isShowing: Bool
    let title: String?
    let message: String
    let duration: TimeInterval
    let backgroundColor: Color
    let titleFont: Font
    let messageFont: Font
    let leadingView: () -> ContentView

    public init(isShowing: Binding<Bool>,
                title: String? = nil,
                message: String,
                duration: TimeInterval,
                backgroundColor: Color,
                titleFont: Font = .title,
                messageFont: Font = .subheadline,
                @ViewBuilder leadingView: @escaping () -> ContentView)
    {
        _isShowing = isShowing
        self.title = title
        self.message = message
        self.duration = duration
        self.leadingView = leadingView
        self.backgroundColor = backgroundColor
        self.titleFont = titleFont
        self.messageFont = messageFont
    }

    public func body(content: Content) -> some View {
        ZStack {
            content
                .animation(.easeInOut, value: isShowing)
                .blur(radius: isShowing ? 5 : 0)
        }
        .overlay {
            if isShowing {
                VStack {
                    toast
                        .ignoresSafeArea()
                        .background(.ultraThickMaterial)
                        .cornerRadius(24, corners: [.bottomRight, .bottomLeft])
                    Spacer()
                }
                .background(.clear)
                .transition(.move(edge: .top))
            }
        }
        .onChange(of: isShowing) { newValue in
            if newValue == true {
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    withAnimation {
                        isShowing = false
                    }
                }
            }
        }
        .animation(.spring(response: isShowing ? 0.5 : 2, dampingFraction: isShowing ? 0.85 : 1, blendDuration: 1), value: isShowing)
    }

    private var toast: some View {
        VStack(spacing: 0) {
            if let title = title {
                Text(title)
                    .font(titleFont)
            }
            HStack(spacing: 0) {
                leadingView()
                Text(message)
                    .font(messageFont)
                    .padding()
                Spacer()
            }
        }
        .padding()
    }
}

extension View {
    public func toast<ContentView: View>(isShowing: Binding<Bool>,
                                         title: String? = nil,
                                         message: String,
                                         duration: TimeInterval = 3,
                                         backgroundColor: Color = .black,
                                         titleFont: Font = .title,
                                         messageFont: Font = .subheadline,
                                         @ViewBuilder leadingView: @escaping () -> ContentView) -> some View
    {
        modifier(
            TopNotifyViewModifire(
                isShowing: isShowing,
                title: title,
                message: message,
                duration: duration,
                backgroundColor: backgroundColor,
                titleFont: titleFont,
                messageFont: messageFont,
                leadingView: leadingView
            )
        )
    }
}

struct TestView: View {
    @State var isShowing = false

    var body: some View {
        Text("hello")
            .toast(isShowing: $isShowing, title: "Test Title", message: "Test message") {
                Image(uiImage: UIImage(named: "avatar.png")!)
            }
            .onTapGesture {
                isShowing = true
            }
    }
}

struct TopNotifyViewModifire_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
            .previewDevice("iPhone 13 Pro Max")
    }
}
#endif
