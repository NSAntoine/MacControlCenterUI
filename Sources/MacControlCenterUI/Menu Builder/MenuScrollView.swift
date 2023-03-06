//
//  MenuScrollView.swift
//  MacControlCenterUI • https://github.com/orchetect/MacControlCenterUI
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import SwiftUI

@available(macOS 10.15, *)
@available(iOS, unavailable)
@available(tvOS, unavailable)
@available(watchOS, unavailable)
public struct MenuScrollView<Content: View>: View, MacControlCenterMenuItem {
    public var content: Content
    public var maxHeight: CGFloat
    
    @State private var scrollPosition: CGPoint = .zero
    @State private var contentSize: CGSize = .zero
    
    public init(
        maxHeight: CGFloat = 300,
        content: () -> Content
    ) {
        self.maxHeight = maxHeight.clamped(to: 0...)
        self.content = content()
    }
    
    public var body: some View {
        ZStack {
            ObservableScrollView(.vertical, offset: $scrollPosition) {
                MenuBody {
                    content
                }
            } contentSizeBlock: { newSize in
                contentSize = newSize
            }
            
            VStack(spacing: 0) {
                Group {
                    if scrollPosition.y < -1 {
                        Image(systemName: "chevron.compact.up")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                    } else {
                        Spacer()
                    }
                }
                .frame(height: 5)
                
                Spacer()
                
                Group {
                    if scrollPosition.y > maxHeight - contentSize.height {
                        Image(systemName: "chevron.compact.down")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                    } else {
                        Spacer()
                    }
                }
                .frame(height: 5)
            }
        }
        .frame(minHeight: min(maxHeight, contentSize.height))
        .frame(maxHeight: maxHeight)
    }
}