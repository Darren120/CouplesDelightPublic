//
//  PhoneViewModel.swift
//  CouplesDelight
//
//  Created by Darren Zou on 10/30/20.
//

import Foundation

class AuthViewModel : AppStateManager {
    @Published var authManager : AuthManager
    
    @Published var showPhoneView : Bool = true {
        willSet {
            self.objectWillChange.send()
        }
    }
    @Published var phoneNumber = "" {
        willSet {
            self.objectWillChange.send()
        }
    }
    @Published var verificationCode = "" {
        willSet {
            self.objectWillChange.send()
        }
    }
    
    @Published var phoneSessionID = ""
    init(authManager: AuthManager) {
        self.authManager = authManager
        print("init auth vm")
    }
    
    func sendVerificationCode() {
            self.verificationCode = ""
            self.phoneSessionID = ""
        if phoneNumber == "" || phoneNumber.count != 10 {
            self.indicatorType = .error(message: "Please enter a valid phone number")
            return
        }
        self.indicatorType = .loading(message: "Please wait...")
        let number = "+1" + phoneNumber
        authManager.sendVerificationCode(phoneNumber: number) { (error, ID) in
            if let err = error {
                self.indicatorType = .error(message: err.localizedDescription)
                return
            }
            guard let ID = ID else {
                self.indicatorType = .error(message: "An error has occured")
                return
            }
            self.showIndicator = false
            self.phoneSessionID = ID
            self.showPhoneView = false
            
        }
        
    }
    func verifyPhone() {
      
        if (verificationCode == "" || verificationCode.count != 6) {
            self.indicatorType = .error(message: "Invalid code, please check your entry and try again.")
            return
        }
        
        self.indicatorType = .loading(message: "One sec...")
        self.authManager.verifyPhone(ID: self.phoneSessionID, code: self.verificationCode) { (err, uid) in
            if let err = err {
                self.indicatorType = .error(message: err.localizedDescription)
                return
            }
            
            //CHECK IF USER EXIST IN DATABASE
        }
        
    }
}


