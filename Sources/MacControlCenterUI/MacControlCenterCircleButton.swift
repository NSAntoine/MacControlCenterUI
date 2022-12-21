//
//  MacControlCenterCircleButton.swift
//  MacControlCenterUI • https://github.com/orchetect/MacControlCenterUI
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import SwiftUI

@available(macOS 10.15, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public struct MacControlCenterCircleButton<Content: View>: View {
    // MARK: Public Properties
    
    @Binding public var isOn: Bool
    public var image: Image
    public var color: Color
    public var invertForeground: Bool
    public var label: (() -> Content)?
    public var onChangeBlock: (Bool) -> Void
    
    // MARK: Environment
    
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: Private State
    
    @State private var isMouseDown: Bool = false
    private var circleSize: CGFloat = 26
    
    // MARK: Init
    
    public init(
        isOn: Binding<Bool>,
        color: Color = Color(NSColor.controlAccentColor),
        invertForeground: Bool = false,
        image: Image,
        onChange onChangeBlock: @escaping (Bool) -> Void = { _ in }
    ) where Content == EmptyView {
        self._isOn = isOn
        self.color = color
        self.invertForeground = invertForeground
        self.image = image
        self.label = nil
        self.onChangeBlock = onChangeBlock
    }
    
    public init(
        isOn: Binding<Bool>,
        color: Color = Color(NSColor.controlAccentColor),
        invertForeground: Bool = false,
        image: Image,
        @ViewBuilder _ label: @escaping () -> Content,
        onChange onChangeBlock: @escaping (Bool) -> Void = { _ in }
    ) {
        self._isOn = isOn
        self.color = color
        self.invertForeground = invertForeground
        self.image = image
        self.label = label
        self.onChangeBlock = onChangeBlock
    }
    
    public var body: some View {
        if label != nil {
            hitTestBody
                .frame(height: circleSize)
        } else {
            hitTestBody
                .frame(width: circleSize, height: circleSize)
        }
    }
    
    @ViewBuilder
    public var hitTestBody: some View {
        GeometryReader { geometry in
            buttonBody
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let hit = geometry.frame(in: .local).contains(value.location)
                            isMouseDown = hit
                        }
                        .onEnded { value in
                            defer { isMouseDown = false }
                            if isMouseDown {
                                isOn.toggle()
                                onChangeBlock(isOn)
                            }
                        }
                )
                
        }
    }
    
    @ViewBuilder
    public var buttonBody: some View {
        if let label = label {
            HStack {
                circleBody
                label()
            }
        } else {
            circleBody
        }
    }
    
    @ViewBuilder
    public var circleBody: some View {
        let buttonBackColor: Color = {
            switch isOn {
            case true:
                return color
            case false:
                switch colorScheme {
                case .dark:
                    return Color(NSColor.controlColor)
                case .light:
                    return Color(white: 0.75)
                @unknown default:
                    return Color(NSColor.controlColor)
                }
            }
        }()
        
        let buttonForeColor: Color = {
            switch isOn {
            case true:
                switch colorScheme {
                case .dark:
                    return invertForeground
                        ? Color(NSColor.textBackgroundColor)
                        : Color(NSColor.textColor)
                case .light:
                    return invertForeground
                        ? Color(NSColor.textColor)
                        : Color(NSColor.textBackgroundColor)
                @unknown default:
                    return Color(NSColor.textColor)
                }
            case false:
                switch colorScheme {
                case .dark:
                    return Color(white: 0.85)
                case .light:
                    return .black
                @unknown default:
                    return Color(NSColor.selectedMenuItemTextColor)
                }
            }
        }()
        
        ZStack {
            Circle()
                .foregroundColor(buttonBackColor)
            image
                .resizable()
                .scaledToFit()
                .padding(5)
                .foregroundColor(buttonForeColor)
            
            if isMouseDown {
                if colorScheme == .dark {
                    Circle()
                        .foregroundColor(.white)
                        .opacity(0.1)
                } else {
                    Circle()
                        .foregroundColor(.black)
                        .opacity(0.1)
                }
            }
        }
        .frame(width: circleSize, height: circleSize)
    }
}
