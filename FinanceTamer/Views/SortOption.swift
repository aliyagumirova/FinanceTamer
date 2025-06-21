//
//  SortOption.swift
//  FinanceTamer
//
//  Created by Aliia Gumirova on 19.06.2025.
//

import Foundation

enum SortOption: String, CaseIterable, Identifiable {
    case byDate = "По дате"
    case byAmount = "По сумме"

    var id: String { rawValue }
}
