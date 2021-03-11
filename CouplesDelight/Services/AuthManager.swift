//
//  AuthService.swift
//  CouplesDelight
//
//  Created by Darren Zou on 10/30/20.
//

import Foundation
import FirebaseAuth
import CryptoKit
import AuthenticationServices
import FirebaseMessaging
import FirebaseFirestore
public typealias phoneSessionID = String
public typealias uid = String
public typealias authToken = String
public enum AuthState {
    case none, authView, createProfileView, linkView, mainView
}
protocol OpenLinkDelegate : class {
    func updated (doc: DocRelationship)
}
class AuthManager: ObservableObject {
   //TO-DO, do a check, enum of view types, and show view after init is complete.
    weak var openLinkDelegate: OpenLinkDelegate? = .none
    @Published var isPartner1 : Bool = false
    @Published var showNotificationBubble = true
    @Published var authState : AuthState = .none
    //Dependencies
    @Published var isAuthReady = false
    var apiService : MasterAPIService
    private var handle: AuthStateDidChangeListenerHandle?
    @Published var disabeParent = false {
        willSet {
            self.objectWillChange.send()
        }
    }
    @Published var continueWithoutLink = false {
        willSet {
            self.objectWillChange.send()
        }
    }
  
    @Published var uid = "" {
        willSet {
            self.objectWillChange.send()
        }
    }
    @Published var dontShowBoarding : Bool {
        willSet {
            self.objectWillChange.send()
        }
    }
    @Published var isUserInDatabase = false {
        willSet {
            self.objectWillChange.send()
        }
    }
    @Published var userSession: User? {
        willSet {
            if newValue == nil {
                self.couplesLinked = nil
            }
            self.objectWillChange.send()
        }
    }
    @Published var phoneNumber : String? {
        willSet {
            self.objectWillChange.send()
        }
    }
    @Published var couplesLinked : CouplesLinked? {
        willSet {
            self.objectWillChange.send()
        }
    }
    var UserListenr : ListenerRegistration? {
        willSet {
            print("JKDSHFJSHDFKSHDKJ")
        }
    }
    var couplesLinkedListener : ListenerRegistration? {
        willSet {
            print("JKDSHFJSHDFKSHDKJ")
        }
    }
    var didCheckFCM = false
//    enum Deeplink: Equatable {
//            case home
//            case details(reference: String)
//        }
//    func manage(url: URL) -> Deeplink? {
//        guard url.scheme == URL.appScheme else { return nil }
//        guard url.pathComponents.contains(URL.appDetailsPath) else { return .home }
//        guard let query = url.query else { return nil }
//        let components = query.split(separator: ",").flatMap { $0.split(separator: "=") }
//        guard let idIndex = components.firstIndex(of: Substring(URL.appReferenceQueryName)) else { return nil }
//        guard idIndex + 1 < components.count else { return nil }
//        
//        return .details(reference: String(components[idIndex.advanced(by: 1)]))
//    }
    init(firestoreService: MasterAPIService) {
      
       
        print("Auth Manager pinged")
        let onB = UserDefaults.standard.bool(forKey: "dontShowBoarding")
        self.dontShowBoarding = onB
        self.apiService = firestoreService
        self.apiService.authTokenForcedRefresh { (a, b) in}
     
        setUp {
           
        }
        
        
        
    }
    
    func setUp(completion: @escaping (() -> Void) = {}) {
        
        handle = Auth.auth().addStateDidChangeListener { [unowned self] (auth, user) in
            
            print("user session Handler changed")
            if let user = user {
                print("user Signed: \(user.uid)")
                self.phoneNumber = user.phoneNumber
                self.uid = user.uid
             
                self.UserListenr?.remove()
                self.couplesLinkedListener?.remove()
                self.apiService.getAuthToken { (token, err) in
                    if let err = err {
                        print(err)
                        
                        return
                    }
                    guard let token = token else {
                        print("err getting token")
                        return
                    }
                    self.apiService.isUserInDatabase(authToken: token) { [unowned self] (err, exist) in
                            if let err = err {
                                print("auth cc \(err.errMsg)")
                                self.signOut()
                                return
                            }
                            guard let isUserInDB = exist else {
                                print("auth cc, potentiel almofire or server error.")
                                return
                            }
                            if isUserInDB {
                                print("user is in DB")
                                self.setUpUserListener(uid: self.uid)
                                return


                            } else {
                                print("user is  NOT in DB")
                                self.UserListenr?.remove()
                                self.authState = .createProfileView
                                return
                            }
                        }
                }
                
                  
               
            } else {
                print("No user signed in")
                self.authState = .authView
                return
            }
        }


    }
    
    func setUpUserListener(uid: String) {
        //careful, the code below will run everytime user is updated
      
        self.UserListenr = self.apiService.fetchUserListener(uid: uid) { [unowned self] (error, user) in
            print("User snap shot changed")
            if let error = error {
                print("init fetch err: \(error.errMsg)")
                self.userSession = nil
                self.authState = .createProfileView
                return
            }
            guard let user = user else {
                self.userSession = nil
                self.authState = .createProfileView
                print("user is nil in auth, something's wrong...")
                return
            }
            self.userSession = user
            if !self.didCheckFCM {
                self.didCheckFCM = true
                self.updateFCMToken(user: user)

            }
         
            if (user.couplesLinked.exist) {
                Auth.auth().currentUser?.getIDTokenForcingRefresh(true, completion: { (a, b) in
                    print("token refreshed!")
                })
                self.couplesLinkedListener = self.apiService.fetchCouplesLinkedListener(docID: user.couplesLinked.docID, completion: { [unowned self] (error, couplesLinked) in
                    
                    if let error = error {
                        print("error couples linked \(error)")
//                        self.authState = .linkView
                    }
                  
                    guard let couplesLinked = couplesLinked else {
                        print("Couples linked: potential network error.")
                        return
                    }
                    print("couples chsnged: \(couplesLinked.docID)")
                    self.couplesLinked = couplesLinked
                    self.isPartner1 = couplesLinked.partner1Or2(uid: self.uid) == 1 ? true : false
                    self.authState = .mainView
                    
                })
                
            } else if user.openLink.exist {
                // otherwise go to linking page
                self.authState = .linkView
                self.openLinkDelegate?.updated(doc: user.openLink)
          
                return
            } else {
                self.authState = .linkView
                return
            }
           
        
        }
    }
    func clearNotifications(typeToClear : MasterAPIService.TypeOfNotification) {
        if self.couplesLinked?.partner1Or2(uid: self.uid) == 1 {
            self.couplesLinked?.partner1.notifications.newCardGameDocs.removeAll()
            if self.couplesLinked?.partner1.notifications.getTotalGameNotification() == 0 {
                return
            }
        } else if self.couplesLinked?.partner1Or2(uid: self.uid) == 2 {
            self.couplesLinked?.partner2.notifications.newCardGameDocs.removeAll()
            if self.couplesLinked?.partner2.notifications.getTotalGameNotification() == 0 {
                return
            }
        } else {
            return
        }
        apiService.getAuthToken { (token, err) in
            guard let token = token else {
                return
            }
            self.apiService.clearNotification(typeToClear: typeToClear, authToken: token)
        }
    }
    func getCouplesInfo() {
        MasterAPIService.instance.firestore.collection("CouplesLinked").document(userSession!.couplesLinked.docID).getDocument { (snap, err) in
            if let err = err {
                print("err \(err.localizedDescription)")
                return
            }
            print("succes2")
        }

    }
    func delegateTest() {
        self.openLinkDelegate?.updated(doc: self.userSession!.openLink)
    }
    func updateFCMToken(user: User) {
        let ftoken = Messaging.messaging().fcmToken
        if let fcmToken = ftoken {
            if user.fcmToken == "" || user.fcmToken != fcmToken {
                self.apiService.getAuthToken { (token, err) in
                    print("updating fcm")
                    if let err = err {
                        print("error updating fcmToken in auth init(): \(err)")
                    }
                    if let authToken = token {
                        self.apiService.updateFCM(fcmToken: fcmToken, authToken: authToken)
                    } else {
                        print("error updating fcmToken in auth init() here")
                    }
                }
                
                }
        }
    }
    func sendVerificationCode(phoneNumber: String, completion: @escaping (_ error: Error?, _ ID: phoneSessionID?) -> Void) {
        
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (ID, err) in
                   
                   if let err = err{
                    print(err.localizedDescription)
                    return completion(err,nil)
                   }
                return completion(nil, ID)
                
        }
    }
    
 
    func verifyPhone(ID: String, code: String, completion: @escaping (_ error: Error?, _ uid: uid?) -> Void){
        
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: ID, verificationCode: code)
        Auth.auth().signIn(with: credential) { (res, err) in
            if let err  = err {
             print(err.localizedDescription)
             return completion(err, nil)
            }
         
            guard let uid = res?.user.uid else {
                print(res?.additionalUserInfo?.description ?? "no info")
                return completion(CustomError(errMsg: "Cannot find uid"), nil)
            }
            self.isAuthReady = false
            self.uid = uid
            return completion(nil, uid)
        }
    }
    
    
    func onBoardingFinish() {
        UserDefaults.standard.setValue(true, forKey: "dontShowBoarding")
        self.dontShowBoarding = true
    }
  
    
 
    
    
    func skipLinking() {
        if self.userSession!.couplesLinked.exist {
            return
        }
        if !self.userSession!.openLink.exist{
            self.continueWithoutLink.toggle()
            if self.continueWithoutLink {
                self.authState = .mainView
            } else {
                self.authState = .linkView
            }
        }
       
       
    }
    func signOut() {
      do {
        self.UserListenr?.remove()
        self.couplesLinkedListener?.remove()
        
        try Auth.auth().signOut()
        self.authState = .authView
        self.couplesLinked = nil
        self.userSession = nil
        
        self.isUserInDatabase = false
        self.uid = ""
        self.continueWithoutLink = false
       
       
        self.objectWillChange.send()
        print("signed out")
      }
      catch let signOutError as NSError {
        print("Error signing out: \(signOutError)")
      }
    }
}

extension AuthManager {
    
    func signInWithApple(idTokenString: String, nonce: String) {
        
        self.isAuthReady = false
        let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
        Auth.auth().signIn(with: credential) { (res, err) in
            if let err = err {
                print(err)
            }
            
//            print(res?.description)
        }
    }
    func linkAppleAccount(idTokenString: String, nonce: String) {
        let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
        Auth.auth().currentUser?.link(with: credential, completion: { (res, err) in
            if let err = err {
                print(err)
            }
            
//            print(res?.description)
        })
        
    }
    func unlinkAppleAccount() {
        Auth.auth().currentUser?.unlink(fromProvider: "apple.com", completion: { (res, err) in
            if let err = err {
                print(err)
            }
//            print(res?.email)
        })
        
    }
    func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
        return String(format: "%02x", $0)
        }.joined()

        return hashString
    }
    
    //Creates a random string of characters
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if length == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }
}
