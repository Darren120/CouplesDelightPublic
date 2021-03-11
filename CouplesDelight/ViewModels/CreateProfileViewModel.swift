//
//  CreateProfileViewModel.swift
//  CouplesDelight
//
//  Created by Darren Zou on 11/3/20.
//

import Foundation

class CreateProfileViewModel : AppStateManager {
    @Published var authManager : AuthManager
    let set = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ")
    @Published var firstName = "" {
        didSet {
            if firstName.rangeOfCharacter(from: set.inverted) != nil {
                firstName = oldValue
                return
            }
            self.objectWillChange.send()
        }
    }
    @Published var lastName = "" {
        didSet {
            if lastName.rangeOfCharacter(from: set.inverted) != nil {
                firstName = oldValue
                return
            }
            self.objectWillChange.send()
        }
    }
    @Published var linkPassword = ""
    @Published var birthday = Date().sevenTeenYearsOld!
 
    @Published var gender = "" {
        willSet {
            self.objectWillChange.send()
        }
    }

    init(authManager : AuthManager) {
        self.authManager = authManager
    }
    


    func createProfile() {
    
        let set = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ")
        if firstName.rangeOfCharacter(from: set.inverted) != nil || firstName.contains(" "){
            self.indicatorType = .error(message: "First name cannot include special characters or spaces")
            print("ERROR: There are numbers included!")
            return
        }
        if lastName.rangeOfCharacter(from: set.inverted) != nil || lastName.contains(" ") {
            self.indicatorType = .error(message: "Last name cannot include special characters or spaces")
            print("ERROR: There are numbers included!")
            return
        }

        if self.birthday.distance(to: Date()) < 568070000 {
       
            self.indicatorType = .error(message: "You must be over 18 to use our service.")
            return
        }
        if self.authManager.uid == "" {
            self.indicatorType = .error(message: "UID undefined")
            return
        }
        if self.gender == "" || self.firstName == "" || self.lastName == "" || (self.gender != "Male" && self.gender != "Female") {
            self.indicatorType = .error(message: "Please fill out all fields!")
            return
        }
       
        self.indicatorType = .loading(message: "One sec...")
       
        let user = User(firstName: self.firstName, lastName: self.lastName, gender: self.gender, uid: self.authManager.uid, birthday: birthday.removeHours ?? birthday, phoneNumber: self.authManager.phoneNumber ?? "")
        self.authManager.apiService.getAuthToken { (token, error) in
            if let err = error {
                self.indicatorType = .error(message: "Error verifying auth token. \(err.errMsg)")
                return
            }
            guard let token = token else {
                self.indicatorType = .error(message: "Error: Auth token was nil")
                return
            }
            self.authManager.apiService.createUserProfile(user: user, token: token) { (error) in
            
                if let err = error {
                    self.indicatorType = .error(message: err.errMsg)
                    return
                }
                // Firebase rules will not allow listener to continue if user isn't in DB, so we need to reset the listener when the user is in the DB.
         
               
                self.authManager.setUp { 
                    self.indicatorType = .success(message: "Nice")
                }
                
            }
            
        }
       
    }
    func test() {
//        guard let phoneNumber = self.authManager.phoneNumber else {
//            self.indicatorType = .error(message: "An error has occured.")
//            return
//        }
//        let user = User(firstName: self.firstName, lastName: self.lastName, gender: self.gender, uid: self.authManager.uid, birthday: birthday.removeHours ?? birthday, phoneNumber: phoneNumber)
//        self.authManager.firestore.TESTDATE(user: user, token: "") { (err) in
//            if let err = err {
//                print(err)
//            }
//        }
    }
}
