//
//  MenuCommand.swift
//  MacControlCenterUI • https://github.com/orchetect/MacControlCenterUI
//  © 2022 Steffan Andrews • Licensed under MIT License
//

#if os(macOS)

import AppKit
import SwiftUI

/// ``MacControlCenterMenu`` menu item that acts like a traditional `NSMenuItem` that highlights
/// when moused over and is clickable with a custom action closure.
///
/// Menu hover colorization can be set using the ``menuCommandStyle(_:)`` view modifier:
///  `menu` style (highlight color) or `commandCenter` style (translucent gray).
@available(macOS 10.15, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public struct MenuCommand<Label: View>: View, MacControlCenterMenuItem {
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.isMenuBarExtraPresented) private var menuBarExtraIsPresented
    
    private let label: Label
    private let action: () -> Void
    internal var activatesApp: Bool
    internal var dismissesMenu: Bool
    internal var style: MenuCommandStyle = .controlCenter
    @State private var isHighlighted: Bool = false
    @State private var isSettingsLink: Bool = false
    
    // MARK: Init
    
    @_disfavoredOverload
    public init<S>(
        _ title: S,
        activatesApp: Bool = true,
        dismissesMenu: Bool = true,
        action: @escaping () -> Void
    ) where S: StringProtocol, Label == Text {
        self.label = Text(title)
        self.activatesApp = activatesApp
        self.dismissesMenu = dismissesMenu
        self.action = action
    }
    
    public init(
        _ titleKey: LocalizedStringKey,
        activatesApp: Bool = true,
        dismissesMenu: Bool = true,
        action: @escaping () -> Void
    ) where Label == Text {
        self.label = Text(titleKey)
        self.activatesApp = activatesApp
        self.dismissesMenu = dismissesMenu
        self.action = action
    }
    
    public init(
        action: @escaping () -> Void,
        activatesApp: Bool = true,
        dismissesMenu: Bool = true,
        @ViewBuilder label: () -> Label
    ) {
        self.label = label()
        self.activatesApp = activatesApp
        self.dismissesMenu = dismissesMenu
        self.action = action
    }
    
    // MARK: Init - SettingsLink Variant (used by MenuSettingsCommand)
    
    @_disfavoredOverload
    internal init<S>(
        settingsLink title: S,
        activatesApp: Bool = true,
        dismissesMenu: Bool = true
    ) where S: StringProtocol, Label == Text {
        self.label = Text(title)
        self.activatesApp = activatesApp
        self.dismissesMenu = dismissesMenu
        self.action = { Self.showSettingsWindowLegacy() }
        self._isSettingsLink = State(initialValue: true)
    }
    
    internal init(
        settingsLink title: LocalizedStringKey,
        activatesApp: Bool = true,
        dismissesMenu: Bool = true
    ) where Label == Text {
        self.label = Text(title)
        self.activatesApp = activatesApp
        self.dismissesMenu = dismissesMenu
        self.action = { Self.showSettingsWindowLegacy() }
        self._isSettingsLink = State(initialValue: true)
    }
    
    internal init(
        activatesApp: Bool = true,
        dismissesMenu: Bool = true,
        @ViewBuilder settingsLink: () -> Label
    ) {
        self.label = settingsLink()
        self.activatesApp = activatesApp
        self.dismissesMenu = dismissesMenu
        self.action = { Self.showSettingsWindowLegacy() }
        self._isSettingsLink = State(initialValue: true)
    }
    
    // MARK: Body
    
    public var body: some View {
        HighlightingMenuItem(
            style: style,
            height: .standardTextOnly,
            isHighlighted: $isHighlighted
        ) {
            if isSettingsLink, #available(macOS 14, *) {
                // we're forced to use SettingsLink on macOS Sonoma.
                ZStack {
                    SettingsLink {
                        Text(verbatim: " ")
                            .frame(maxWidth: .infinity)
                    }
                    .settingsLinkButtonStyle(preTapAction: {
                        userTapped()
                    })
                    
                    commandBody
                }
            } else {
                commandBody
                    .allowsHitTesting(true)
                    .onTapGesture {
                        userTapped()
                    }
            }
        }
    }
    
    private var commandBody: some View {
        HStack {
            label
                .foregroundColor(style.textColor(hover: isHighlighted))
            Spacer()
        }
        .contentShape(Rectangle())
    }
    
    // MARK: Helpers
    
    private func userTapped() {
        func go() {
            if activatesApp {
                NSApp.activate(ignoringOtherApps: true)
            }
            
            if dismissesMenu {
                menuBarExtraIsPresented.wrappedValue = false
            }
            
            action()
        }
        
        switch style {
        case .menu:
            // classic NSMenu-style menu commands still blink on click, as of Ventura
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                isHighlighted = false
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isHighlighted = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                go()
            }
        case .controlCenter:
            // Control Center menu commands don't blink because Apple is boring and hates charm
            go()
        }
    }
    
    // Use old API to open Settings scene on older macOS versions.
    private static func showSettingsWindowLegacy() {
        if #available(macOS 14, *) {
            // sendAction methods are deprecated; must use SettingsLink View
        } else if #available(macOS 13, *) {
            NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
        } else {
            NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
        }
    }
}

#endif
