//
//  ShakeDetectorModifier.swift
//  FinanceTamer
//
//  Created by Алия Гумирова on 25.06.2025.
//

import SwiftUI
import UIKit

struct ShakeDetectorModifier: ViewModifier {
    let onShake: () -> Void
    
    func body(content: Content) -> some View {
        content
            .background(ShakeRepresentable(onShake: onShake))
    }
    
    private struct ShakeRepresentable: UIViewControllerRepresentable {
        let onShake: () -> Void
        
        func makeUIViewController(context: Context) -> ShakeViewController {
            let controller = ShakeViewController()
            controller.onShake = onShake
            return controller
        }
        
        func updateUIViewController(_ uiViewController: ShakeViewController, context: Context) {}
    }
    
    private class ShakeViewController: UIViewController {
        var onShake: (() -> Void)?
        
        override var canBecomeFirstResponder: Bool { true }
        
        override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            becomeFirstResponder()
        }
        
        override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
            if motion == .motionShake {
                onShake?()
            }
        }
    }
}

extension View {
    func onShake(perform action: @escaping () -> Void) -> some View {
        self.modifier(ShakeDetectorModifier(onShake: action))
    }
}

