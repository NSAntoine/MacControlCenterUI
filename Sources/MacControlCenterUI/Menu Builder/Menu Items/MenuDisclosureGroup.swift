//
//  MenuDisclosureGroup.swift
//  MacControlCenterUI • https://github.com/orchetect/MacControlCenterUI
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import SwiftUI

/// ``MacControlCenterMenu`` disclosure group menu item.
/// Used to hide or show optional content in a menu.
@available(macOS 10.15, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public struct MenuDisclosureGroup<Label: View>: View, MacControlCenterMenuItem {
    public var labelHeight: MenuItemSize
    public var label: Label
    public var content: [any View]
    @Binding public var isExpandedBinding: Bool
    @State private var isExpanded: Bool
    
    @State private var isPressed: Bool = false
    @State private var isHighlighted = false
    
    // MARK: Init - With Binding
    
    public init(
        isExpanded: Binding<Bool>,
        labelHeight: MenuItemSize,
        @ViewBuilder label: () -> Label,
        @MacControlCenterMenuBuilder content: () -> [any View]
    ) {
        self._isExpandedBinding = isExpanded
        self._isExpanded = State(initialValue: isExpanded.wrappedValue)
        self.labelHeight = labelHeight
        self.label = label()
        self.content = content()
    }
    
    // MARK: Init - Without Binding
    
    public init(
        initiallyExpanded: Bool = true,
        labelHeight: MenuItemSize,
        @ViewBuilder label: () -> Label,
        @MacControlCenterMenuBuilder content: () -> [any View]
    ) {
        self._isExpandedBinding = .constant(initiallyExpanded)
        self._isExpanded = State(initialValue: initiallyExpanded)
        self.labelHeight = labelHeight
        self.label = label()
        self.content = content()
    }
    
    // MARK: Body
    
    public var body: some View {
        HighlightingMenuStateItem(
            style: .controlCenter,
            height: labelHeight,
            isOn: $isExpanded,
            isPressed: $isPressed
        ) {
            HStack {
                label
                Spacer()
                Image(systemName: "chevron.right")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 10, height: 10)
                    .foregroundColor(.primary)
                    .rotationEffect(isExpanded ? .degrees(90) : .zero)
                    //.animation(.default, value: isExpanded)
            }
        } onChange: { _ in
            // below is some jank magic to make the window not freak out too much
            contentHeight = isExpanded ? nil : 0
            minContentHeight = isExpanded ? 0 : nil
            DispatchQueue.main.async {
                minContentHeight = nil
            }
        }
        
        // do not remove the view using if { } otherwise it loses state
        MenuBody(content: content)
            .frame(minHeight: minContentHeight)
            .frame(maxWidth: .infinity)
            .frame(height: contentHeight)
            .opacity(isExpanded ? 1 : 0)
        
            .onAppear {
                if !isExpanded {
                    contentHeight = 0
                }
            }
        
            .onChange(of: isExpandedBinding) { newValue in
                isExpanded = newValue
            }
            .onChange(of: isExpanded) { newValue in
                isExpandedBinding = newValue
            }
    }
    
    @State private var contentHeight: CGFloat?
    @State private var minContentHeight: CGFloat?
}
