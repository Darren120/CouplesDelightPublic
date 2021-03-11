//
//  LinkViewModel.swift
//  CouplesDelight
//
//  Created by Darren Zou on 11/7/20.
//

import Foundation
import Combine
class LinkViewModel : AppStateManager , OpenLinkDelegate {
    func updated(doc: DocRelationship) {
        if doc.docID == "" {
            print("Dont exist")
            return}
        print("exist aa")
        self.getLinkInfo(docID: doc.docID)
    }
    
    @Published var authManager: AuthManager
   
    enum LinkStatus {
        case noLink, linkOwner, linkWith, initlizing
    }
    var cancellable: AnyCancellable?
    
    @Published var linkStatus : LinkStatus {
        willSet{
            self.objectWillChange.send()
        }
    }
    @Published var openLink : OpenLink? {
        willSet {
            self.objectWillChange.send()
        }
    }
   
    @Published var partnerLinkID = "" {
        didSet {
            if partnerLinkID.count > 5 && oldValue.count <= 5 {
                partnerLinkID = oldValue
            }
            self.objectWillChange.send()
        }
    }
    @Published var anniversary = Date().tomorrow! {
        willSet {
            self.objectWillChange.send()
        }
    }
    @Published var partnerBirthday = Date().sevenTeenYearsOld! {
        willSet {
            self.objectWillChange.send()
        }
    }
    @Published var linkPassword = "" {
        willSet {
            self.objectWillChange.send()
        }
    }
    @Published var phoneNumber = "" {
        willSet {
            self.objectWillChange.send()
        }
    }
    @Published var disableRefresh : Bool = false {
        willSet{
            self.objectWillChange.send()
        }
    }
    @Published var counter : Double = 45 {
        willSet{
            self.objectWillChange.send()
        }
    }
    var mulipler = 1.0
    deinit {
        print("deiniting")
    }
    init(authManager: AuthManager) {
        print("back!")
        
        self.authManager = authManager
        self.linkStatus = .initlizing
       
   
        super.init()
        self.authManager.openLinkDelegate = self
        
        guard self.authManager.userSession?.openLink.exist == true && self.authManager.userSession?.openLink.docID != "" else {
            self.linkStatus = .noLink
            return
        }
        self.getLinkInfo(docID: self.authManager.userSession!.openLink.docID)
      
 
    }
   
    func generateLinkPin() {
        guard self.authManager.userSession?.pendingRequest.exist == false else {
            self.indicatorType = .loading(message: "Please cancel any existing request you have sent before generating a link.")
            return
        }
        self.indicatorType = .loading(message: "Generating link...")
        if self.anniversary.distance(to: Date()) < 0 {
            self.indicatorType = .error(message: "Anniversary invalid")
            return
        }
        self.authManager.apiService.getAuthToken { (token, error) in
            if let error = error {
                print(error.errMsg)
                self.indicatorType = .error(message: "Authentication error, please try again or re-log")
                return
            }
            guard let token = token else {
                self.indicatorType = .error(message: "Error, please try again.")
                return
            }
            guard let user = self.authManager.userSession else {
                print("user session nil")
                self.indicatorType = .error(message: "Authentication error, please try again or re-log")
                return
            }
            
            let openLink = OpenLink(ownerUID: user.uid, birthday: user.getBirthday(), anniversary: self.anniversary, linkRequest: [])
            self.authManager.apiService.generateLinkPin(authToken: token, link: openLink) { (error) in
                if let err = error {
                    print(err.errMsg)
                    self.indicatorType = .error(message: err.errMsg)
                    return
                }
               
            }
       
        }
    }
    
    
    func continueWithoutLink() {
        print("aakk")
//        self.indicatorType = .loading(message: "One sec...")
        
        self.authManager.skipLinking()
//        self.showIndicator = false
    }
    func linkWithBae() {
    
        self.linkStatus = .linkWith
        self.objectWillChange.send()
    }
    func sendLink() {
        self.indicatorType = .loading(message: "Sending...")
        self.authManager.apiService.getAuthToken { (token, error) in
            if let error = error {
                print(error.errMsg)
                self.indicatorType = .error(message: "Authentication error, please try again or re-log")
                return
            }
            guard let token = token else {
                self.indicatorType = .error(message: "Error, please try again.")
                return
            }
            guard let user = self.authManager.userSession else {
                self.indicatorType = .error(message: "Failed to get user info, please try again or re-log.")
                return
            }
            let linkRequest = LinkRequest(firstName: user.firstName, lastName: user.lastName, requesterUID: user.uid, linkID: self.partnerLinkID, birthday: self.partnerBirthday, anniversary: self.anniversary)
         
            self.authManager.apiService.sendLinkRequest(authToken: token, linkRequest: linkRequest) { (error) in
                if let err = error {
                    self.indicatorType = .error(message: err.errMsg)
                    return
                }
                self.indicatorType = .success(message: "Link request sent!")
            }
        }
     
    }
    
    func acceptLinkRequest(request: LinkRequest) {
        self.indicatorType = .loading(message: "Tying the knot...")
        self.authManager.apiService.getAuthToken { (token, error) in
            if let error = error {
                print(error.errMsg)
                self.indicatorType = .error(message: "Authentication error, please try again or re-log")
                return
            }
            guard let token = token else {
                self.indicatorType = .error(message: "Error, please try again.")
                return
            }
            guard let openLink = self.openLink else {
                self.indicatorType = .error(message: "Error, link expired.")
                return
            }
            self.authManager.apiService.acceptLinkRequest(authToken: token, openLink: openLink, linkRequest: request) { (error) in
                if let err = error {
                    print(err.errMsg)
                    self.indicatorType = .error(message: err.errMsg)
                    return
                    
                } else {
                    self.getLinkInfo(silentMode: true, docID: self.authManager.userSession!.openLink.docID) {
                        self.disableRefresh = false
                        self.indicatorType = .success(message: "Yay!")
                            
                       
                    }
                }
             
            }
        }
    }
    func rejectRequest(linkRequest: LinkRequest) {
        self.indicatorType = .loading(message: "Rejecting request...")
        self.authManager.apiService.getAuthToken { (token, error) in
            if let err = error {
                self.indicatorType = .error(message: err.errMsg)
                return
            }
            guard let token = token else {
                self.indicatorType = .error(message: "Error getting auth-token, please try again or re-log.")
                return
            }
            self.authManager.apiService.rejectRequest(authToken: token, linkRequest: linkRequest) { (error) in
                if let err = error {
                    self.indicatorType = .error(message: err.errMsg)
                    return
                }
                let name = linkRequest.firstName + linkRequest.lastName
                self.getLinkInfo(silentMode: true, docID: self.authManager.userSession!.openLink.docID){
                    self.indicatorType = .success(message: "Rejected, \(name)'s request.")
                    return
                }
            }
        }
    }
    func cancelOutgoingLinkRequest() {
        self.indicatorType = .loading(message: "Canceling...")
        self.authManager.apiService.getAuthToken { (token, error) in
            if let err = error {
                self.indicatorType = .error(message: err.errMsg)
                return
            }
            guard let token = token else {
                self.indicatorType = .error(message: "Error getting auth-token, please try again or re-log.")
                return
            }
            self.authManager.apiService.cancelOutgoingLinkRequest(authToken: token) { (error) in
                if let err = error {
                    self.indicatorType = .error(message: err.errMsg)
                    return
                }
                self.indicatorType = .success(message: "Cancelled request.")
                return
            }
        }
    }
    func refreshLinkOwner() {
        
            self.disableRefresh = true
            self.indicatorType = .loading(message: "Refreshing...")
            self.getLinkInfo(docID: self.authManager.userSession!.openLink.docID, completion: {
        
                self.indicatorType = .success(message: "Done!")
                if self.mulipler >= 3 {
                    self.counter = 45
                    DispatchQueue.main.asyncAfter(deadline: .now() + self.counter) {
                            self.counter = 46
                            self.disableRefresh = false
                            return
                        }
                } else {
                    self.mulipler += 1
                    self.disableRefresh = false
                }
                
                
                
            })
        
       
    }
    
    func deleteLink() {
        self.indicatorType = .loading(message: "Deleting...")
        self.disableRefresh = false
        self.authManager.apiService.getAuthToken { (token, error) in
            if let error = error {
                print(error.errMsg)
                self.indicatorType = .error(message: "Authentication error, please try again or re-log")
                return
            }
            guard let token = token else {
                self.indicatorType = .error(message: "Error, please try again.")
                return
            }
            self.authManager.apiService.deleteLink(authToken: token, docRelationship: self.authManager.userSession!.openLink) { (error) in
                if let err = error {
                    self.indicatorType = .error(message: err.errMsg)
                    return
                }
                self.linkStatus = .noLink
                self.showIndicator = false
            }
        }
      
    }
    
    func getLinkInfo(silentMode: Bool = false, docID: String, completion: @escaping (() -> Void) = {}) {
        print("got doc")
        if silentMode {
            self.authManager.apiService.checkOpenLink(docID: docID) { (error, openLink) in
                if let err = error {
                    print(err.errMsg)
                    self.linkStatus = .noLink
                  
                    return completion()
                }
                if let openLink = openLink {
                    self.openLink = openLink
                    self.linkStatus = .linkOwner
              
                    return completion()
                } else {
                    self.linkStatus = .noLink
                
                    return completion()
                }
            }
        } else {
            self.authManager.apiService.checkOpenLink(docID: docID) { (error, openLink) in
                if let err = error {
                    print(err.errMsg)
                    self.linkStatus = .noLink
                    self.indicatorType = .error(message: "Error getting link info, please try again.")
                    return completion()
                }
                if let openLink = openLink {
                    self.openLink = openLink
                    self.linkStatus = .linkOwner
                    self.showIndicator = false
                    return completion()
                } else {
                    self.linkStatus = .noLink
                    self.showIndicator = false
                    return completion()
                }
            }
        }
        
    }
}
