//
//  UIViewControllerRepresentable.swift
//  FinanceTamer
//
//  Created by Алия Гумирова on 12.07.2025.
//

import SwiftUI

struct AnalysisViewWrapper: UIViewControllerRepresentable {
    let direction: Direction
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let vc = AnalysisViewController()
        vc.direction = direction
        let nav = UINavigationController(rootViewController: vc)
        return nav
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
    }
}

