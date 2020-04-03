//
//  NavController.swift
//  Habito
//
//  Created by Gurjit Singh on 02/04/20.
//  Copyright © 2020 Gurjit Singh. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

class ViewNav: ObservableObject {
    @Published var currentVisibleView = "home"
}
