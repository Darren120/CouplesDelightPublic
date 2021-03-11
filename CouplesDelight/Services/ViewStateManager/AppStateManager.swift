//
//  AppStateManager.swift
//  CouplesDelight
//
//  Created by Darren Zou on 10/27/20.
//

import Foundation
import Combine
import FirebaseAuth
public enum AnimationState {
    case congrats,
         sweet,
         sad,
         excited
}
public enum AppState {
    case loading(message: String),
         error(message: String),
         success(message: String)
}
class AppStateManager: ObservableObject {
    @Published var viewIndex = 1
    @Published var indicatorType: AppState? {
        willSet {
            DispatchQueue.main.async {
                self.showIndicator = true
                self.objectWillChange.send()
            }
            
        }
    }
    @Published var showIndicator = false
  
}
