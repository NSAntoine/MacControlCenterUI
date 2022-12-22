//
//  ContentView.swift
//  MacControlCenterUI • https://github.com/orchetect/MacControlCenterUI
//  © 2022 Steffan Andrews • Licensed under MIT License
//

import SwiftUI
import MacControlCenterUI

struct ContentView: View {
    @State var volumeLevel: CGFloat = 0.75
    @State var brightnessLevel: CGFloat = 0.5
    @State var button1State: Bool = true
    @State var button2State: Bool = true
    @State var button3State: Bool = true
    @State var button4State: Bool = true
    
    /// Based on macOS Control Center slider width
    let sliderWidth: CGFloat = 270
    
    var body: some View {
        MacControlCenterPanel {
            MacControlCenterPanel {
                MacControlCenterSlider(
                    value: $brightnessLevel,
                    label: "Display",
                    image: .macControlCenterDisplayBrightness
                )
                .frame(minWidth: sliderWidth)
            }
            .frame(height: 64)
            
            Slider(value: $brightnessLevel) {
                Text("\(brightnessLevel)")
                    .font(.system(size: 12, design: .monospaced))
            }
            
            Spacer().frame(height: 20)
            
            MacControlCenterPanel {
                MacControlCenterVolumeSlider(value: $volumeLevel, label: "Sound")
                    .frame(minWidth: sliderWidth)
            }
            .frame(height: 64)
            
            Slider(value: $volumeLevel) {
                Text("\(volumeLevel)")
                    .font(.system(size: 12, design: .monospaced))
            }
            
            Spacer().frame(height: 20)
            
            MacControlCenterPanel {
                HStack {
                    MacControlCenterCircleButton(
                        isOn: $button1State,
                        image: .macControlCenterSpeaker
                    ) {
                        Text("Toggle Button")
                    }
                    Spacer()
                    Toggle("On", isOn: $button1State)
                }
                
                HStack {
                    MacControlCenterCircleButton(
                        isOn: $button2State,
                        color: .white,
                        invertForeground: true,
                        image: .macControlCenterSpeaker
                    ) {
                        Text("Toggle Button (White)")
                    }
                    Spacer()
                    Toggle("On", isOn: $button2State)
                }
                
                HStack {
                    MacControlCenterCircleButton(
                        isOn: $button3State,
                        color: .orange,
                        image: .macControlCenterDisplayBrightness
                    ) {
                        Text("Toggle Button (Orange)")
                    }
                    Spacer()
                    Toggle("On", isOn: $button3State)
                }
                
                HStack {
                    HStack {
                        MacControlCenterCircleButton(
                            isOn: $button4State,
                            image: .macControlCenterSpeaker
                        )
                        Text("Text Not Clickable")
                        Spacer()
                        Toggle("On", isOn: $button4State)
                    }
                }
                
                HStack {
                    HStack {
                        MacControlCenterCircleButton(
                            isOn: .constant(true),
                            image: .macControlCenterSpeaker
                        ) {
                            Text("Button")
                        } onChange: { _ in
                            print("Clicked.")
                            NSSound.beep()
                        }
                        Spacer()
                        Text("(Static On)")
                    }
                }
                
                HStack {
                    HStack {
                        MacControlCenterCircleButton(
                            isOn: .constant(false),
                            image: .macControlCenterSpeaker
                        ) {
                            Text("Button")
                        } onChange: { _ in
                            print("Clicked.")
                            NSSound.beep()
                        }
                        Spacer()
                        Text("(Static Off)")
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
