//
//  MainView.swift
//  SolarSystem-multiplatform
//
//  Created by TOLGA HALILOGLU on 14.02.2023.
//

import SwiftUI

struct MainView: View {
    
    @State private var previousTranslation = CGSize.zero
    @State private var previousScroll: CGFloat = 1
    
    var body: some View {
        VStack {
            MetalView()
                .onGeometryChange(for: CGRect.self) { proxy in
                    proxy.frame(in: .global)
                } action: { newValue in
                    InputController.shared.isResizing = true
                }
                .gesture(DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        InputController.shared.touchLocation = value.location
                        InputController.shared.touchDelta = CGSize(
                            width: value.translation.width - previousTranslation.width,
                            height: value.translation.height - previousTranslation.height)
                        previousTranslation = value.translation
                        // if the user drags, cancel the tap touch
                        if abs(value.translation.width) > 1 ||
                            abs(value.translation.height) > 1 {
                            InputController.shared.touchLocation = nil
                        }
                    }
                    .onEnded {_ in
                        previousTranslation = .zero
                    })
                .gesture(MagnificationGesture()
                    .onChanged { value in
                        let scroll = value - previousScroll
                        InputController.shared.mouseScroll.x = Float(scroll)
                        * Settings.touchZoomSensitivity
                        previousScroll = value
                    }
                    .onEnded {_ in
                        previousScroll = 1
                    })
        }
        .padding()
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
