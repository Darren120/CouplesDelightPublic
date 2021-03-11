//
//  FirestoreService.swift
//  CouplesDelight
//
//  Created by Darren Zou on 11/3/20.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import Alamofire
import FirebaseAuth
import FirebaseMessaging
import FirebaseStorage
public typealias isUserInDatabase = Bool
// ALL READS FETCHES USES FIREBASE SDK
// MOST WRITES GO THROUGH SERVER

struct MasterAPIService : LinkAPIService, UserAPIService, NotificationAPIService, CouplesAPIService, GamesAPIService {
    enum TypeOfNotification {
        case cardGame, b ,c
    }
    static let instance = MasterAPIService()
    var productionMode = true
    let apiEndPoints = APIEndpoints(productionMode : true)
     func convertImageToBase64String (img: UIImage) -> String? {
        return img.jpegData(compressionQuality: 0.9)?.base64EncodedString()
    }
     var crypto = CryptoService()
     var firestore = Firestore.firestore()
     var gamesImageStorage = Storage.storage(url: "gs://couples-delight.appspot.com")
    //    init() {
    //        let settings = FirestoreSettings()
    //        settings.isPersistenceEnabled = false
    //        MasterAPIService.firestore.settings = settings
    //    }
    func authTokenForcedRefresh(completion: @escaping (_ token : String?, _ error: CustomError?) -> Void) {
        Auth.auth().currentUser?.getIDTokenForcingRefresh(true, completion: { (token,err) in
            if let err = err {
                return completion(nil,CustomError(errMsg: err.localizedDescription))
            }
            return completion(token,nil)
        })
    }
    func getAuthToken(completion: @escaping (_ authToken: authToken?, _ error: CustomError?) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            return completion(nil, CustomError(errMsg: "getAuthToken no user logged in"))
        }
        
        currentUser.getIDToken(completion: { (token, err) in
            
            if let err = err {
                return completion(nil, CustomError(errMsg: err.localizedDescription))
            }
            if let token = token {
                return completion(token, nil)
            }
            return completion(nil, CustomError(errMsg: "somethings went wrong getting auth token, may be nil"))
        })
    }
     func generateHeaders(authToken: String, extraHeaders: [HTTPHeader] = [HTTPHeader]()) -> HTTPHeaders {
        let authHeader = HTTPHeader(name: "x-auth-token", value: authToken)
        var headerArray = extraHeaders
        headerArray.append(authHeader)
        let headers = HTTPHeaders(headerArray)
        return headers
    }
     func codableToJSON<T: Codable>(object: T) -> String? {
        do {
            let jsonEncoder = JSONEncoder()
            let jsonData = try jsonEncoder.encode(object)
            guard let json = String(data: jsonData, encoding: String.Encoding.utf8) else {return nil}
            return json
        } catch let error {
            print("FirestoreService: codableToJSON error: \(error)")
            return nil
        }
    }
     func dictToJSON(dict: [String : Any]) -> String? {
        do {
            let data = try JSONSerialization.data(withJSONObject: dict, options: [])
            
            guard let json = String(data: data, encoding: String.Encoding.utf8) else {return nil}
            return json
        } catch let error {
            print("FirestoreService: dictToJson error: \(error)")
            return nil
        }
    }
}

protocol CouplesAPIService {
    func fetchCouplesLinkedListener(docID: String, completion: @escaping (_ error: CustomError?, _ user: CouplesLinked?) -> Void) -> ListenerRegistration
}
extension CouplesAPIService {
    func fetchCouplesLinkedListener(docID: String, completion: @escaping (_ error: CustomError?, _ user: CouplesLinked?) -> Void) -> ListenerRegistration {
        return MasterAPIService.instance.firestore.collection("CouplesLinked").document(docID).addSnapshotListener { (snap, err) in
            if let err = err {
                return completion(CustomError(errMsg: err.localizedDescription), nil)
                
            }
            guard let snap = snap else {
                return completion(CustomError(errMsg: "Cannot get couples information"), nil)
            }
            do {
                let couplesLinked = try snap.data(as: CouplesLinked.self)
                return completion(nil, couplesLinked)
            } catch (let error) {
                return completion(CustomError(errMsg: error.localizedDescription), nil)
            }
        }
    }
}

protocol LinkAPIService {
    func checkOpenLink(docID: String, completion: @escaping (_ error: CustomError?, _ openLink: OpenLink?) -> Void)
    func generateLinkPin(authToken: String, link: OpenLink, completion: @escaping (_ error: CustomError?) -> Void)
    func sendLinkRequest(authToken: String, linkRequest: LinkRequest, completion: @escaping (_ error: CustomError?) -> Void)
    func acceptLinkRequest(authToken: String, openLink: OpenLink, linkRequest: LinkRequest, completion: @escaping (_ error: CustomError?) -> Void)
    func cancelOutgoingLinkRequest(authToken: String, completion: @escaping (_ error: CustomError?) -> Void)
    func rejectRequest(authToken: String, linkRequest: LinkRequest, completion: @escaping (_ error: CustomError?) -> Void)
    func deleteLink(authToken: String, docRelationship: DocRelationship, completion: @escaping (_ error: CustomError?) -> Void)
}
extension LinkAPIService {
    
    func checkOpenLink(docID: String, completion: @escaping (_ error: CustomError?, _ openLink: OpenLink?) -> Void) {
        MasterAPIService.instance.firestore.collection("OpenLinks").document(docID).getDocument { (snap, err) in
            
            if let err = err {
                return completion(CustomError(errMsg: err.localizedDescription), nil)
            }
            
            guard let snap = snap else {
                return completion(CustomError(errMsg: "Fetching snapshot error"), nil)
            }
            do {
                let openLink = try snap.data(as: OpenLink.self)
                return completion(nil, openLink)
            } catch let error {
                return completion(CustomError(errMsg: error.localizedDescription), nil)
            }
        }
    }
    
    func generateLinkPin(authToken: String, link: OpenLink, completion: @escaping (_ error: CustomError?) -> Void) {
        var url = MasterAPIService.instance.apiEndPoints.createLinkURL
        
        
        guard let openLinkJSON = MasterAPIService.instance.codableToJSON(object: link) else {
            return completion(CustomError(errMsg: "Cannot convert to JSON"))
        }
        let encryptedJSON = MasterAPIService.instance.crypto.encrypt(text: openLinkJSON)
        let headers = MasterAPIService.instance.generateHeaders(authToken: authToken)
        AF.request(url, method: .post, parameters: ["z" : encryptedJSON], headers: headers).responseJSON { (result) in
            if let err = result.error {
                print(err)
                return completion(CustomError(errMsg: "Error: potential network error."))
            }
            guard let value = result.value else {
                return completion(CustomError(errMsg: "Response error"))
            }
            guard let JSON = value as? NSDictionary else {
                return completion(CustomError(errMsg: "JSON to dict error"))
            }
            guard let status = JSON["status"] as? Bool else {
                return completion(CustomError(errMsg: "Cannot get status."))
            }
            guard let err = JSON["error"] as? String else {
                return completion(CustomError(errMsg: "Cannot get error response in status."))
            }
            if let statusCode = result.response?.statusCode {
                if statusCode != 200 {
                    return completion(CustomError(errMsg: "Error: \(statusCode), \(err)"))
                }
            }
            
            if !status {
                return completion(CustomError(errMsg: "Error: \(err)"))
            }
            
            return completion(nil)
        }
        
    }
    
    func sendLinkRequest(authToken: String, linkRequest: LinkRequest, completion: @escaping (_ error: CustomError?) -> Void) {
        let url = MasterAPIService.instance.apiEndPoints.createLinkURL
        guard let linkRequestJSON = MasterAPIService.instance.codableToJSON(object: linkRequest) else {
            return completion(CustomError(errMsg: "Cannot convert to JSON"))
        }
        let encryptedJSON = MasterAPIService.instance.crypto.encrypt(text: linkRequestJSON)
        let headers = MasterAPIService.instance.generateHeaders(authToken: authToken)
        AF.request(url, method: .post, parameters: ["z" : encryptedJSON], headers: headers).responseJSON { (result) in
            if let err = result.error {
                print(err)
                return completion(CustomError(errMsg: "Error: potential network error."))
            }
            guard let value = result.value else {
                return completion(CustomError(errMsg: "Response error"))
            }
            guard let JSON = value as? NSDictionary else {
                return completion(CustomError(errMsg: "JSON to dict error"))
            }
            guard let status = JSON["status"] as? Bool else {
                return completion(CustomError(errMsg: "Cannot get status."))
            }
            guard let err = JSON["error"] as? String else {
                return completion(CustomError(errMsg: "Cannot get error response in status."))
            }
            if let statusCode = result.response?.statusCode {
                if statusCode == 403 && !status {
                    //Birthday or anniversary error
                    
                    return completion(CustomError(errMsg: "\(err) 🤭"))
                }
                if statusCode != 200 {
                    return completion(CustomError(errMsg: "Whoops, \(err)"))
                }
            }
            
            if !status {
                
                return completion(CustomError(errMsg: "Whoops: \(err)"))
            }
            
            return completion(nil)
        }
        
    }
    
    func acceptLinkRequest(authToken: String, openLink: OpenLink, linkRequest: LinkRequest, completion: @escaping (_ error: CustomError?) -> Void) {
        
        let url = MasterAPIService.instance.apiEndPoints.AcceptLinkRequestURL
       
        guard let linkRequestJSON = MasterAPIService.instance.codableToJSON(object: linkRequest) else {
            return completion(CustomError(errMsg: "Cannot convert to JSON"))
        }
        let encryptedLinkRequestJSON = MasterAPIService.instance.crypto.encrypt(text: linkRequestJSON)
        let headers = MasterAPIService.instance.generateHeaders(authToken: authToken)
        guard let openLinkJSON = MasterAPIService.instance.codableToJSON(object: openLink) else {
            return completion(CustomError(errMsg: "Cannot convert to JSON"))
        }
        let encryptedOpenLinkJSON = MasterAPIService.instance.crypto.encrypt(text: openLinkJSON)
        
        AF.request(url, method: .post, parameters: ["z" : encryptedLinkRequestJSON, "y": encryptedOpenLinkJSON], headers: headers).responseJSON { (result) in
            if let err = result.error {
                print(err)
                return completion(CustomError(errMsg: "Error: potential network error."))
            }
            guard let value = result.value else {
                return completion(CustomError(errMsg: "Response error"))
            }
            guard let JSON = value as? NSDictionary else {
                return completion(CustomError(errMsg: "JSON to dict error"))
            }
            guard let status = JSON["status"] as? Bool else {
                return completion(CustomError(errMsg: "Cannot get status."))
            }
            guard let err = JSON["error"] as? String else {
                return completion(CustomError(errMsg: "Cannot get error response in status."))
            }
            if let statusCode = result.response?.statusCode {
                if statusCode == 403 && !status {
                    //Birthday or anniversary error
                    
                    return completion(CustomError(errMsg: "\(err) 🤭"))
                }
                if statusCode != 200 {
                    return completion(CustomError(errMsg: "Error: \(err)"))
                }
            }
            
            if !status {
                
                return completion(CustomError(errMsg: "Error: \(err)"))
            }
            
            return completion(nil)
        }
    }
    func cancelOutgoingLinkRequest(authToken: String, completion: @escaping (_ error: CustomError?) -> Void) {
        
        let url = MasterAPIService.instance.apiEndPoints.CancelOutgoingLinkRequestURL
        
        let headers = MasterAPIService.instance.generateHeaders(authToken: authToken)
        AF.request(url, method: .post, parameters: ["z" : "=]"], headers: headers).responseJSON { (result) in
            if let err = result.error {
                print(err)
                return completion(CustomError(errMsg: "Error: potential network error."))
            }
            guard let value = result.value else {
                return completion(CustomError(errMsg: "Response error"))
            }
            guard let JSON = value as? NSDictionary else {
                return completion(CustomError(errMsg: "JSON to dict error"))
            }
            guard let status = JSON["status"] as? Bool else {
                return completion(CustomError(errMsg: "Cannot get status."))
            }
            guard let err = JSON["error"] as? String else {
                return completion(CustomError(errMsg: "Cannot get error response in status."))
            }
            if let statusCode = result.response?.statusCode {
                if statusCode != 200 {
                    return completion(CustomError(errMsg: "Error, \(err)"))
                }
            }
            
            if !status {
                return completion(CustomError(errMsg: "Error: \(err)"))
            }
            
            return completion(nil)
        }
    }
    
    func rejectRequest(authToken: String, linkRequest: LinkRequest, completion: @escaping (_ error: CustomError?) -> Void) {
   
        let url = MasterAPIService.instance.apiEndPoints.RejectRequestURL
        guard let linkRequestJSON = MasterAPIService.instance.codableToJSON(object: linkRequest) else {
            return completion(CustomError(errMsg: "Cannot convert to JSON"))
        }
        let encryptedLinkRequestJSON = MasterAPIService.instance.crypto.encrypt(text: linkRequestJSON)
        let headers = MasterAPIService.instance.generateHeaders(authToken: authToken)
        AF.request(url, method: .post, parameters: ["z" : encryptedLinkRequestJSON], headers: headers).responseJSON { (result) in
            if let err = result.error {
                print(err)
                return completion(CustomError(errMsg: "Error: potential network error."))
            }
            guard let value = result.value else {
                return completion(CustomError(errMsg: "Response error"))
            }
            guard let JSON = value as? NSDictionary else {
                return completion(CustomError(errMsg: "JSON to dict error"))
            }
            guard let status = JSON["status"] as? Bool else {
                return completion(CustomError(errMsg: "Cannot get status."))
            }
            guard let err = JSON["error"] as? String else {
                return completion(CustomError(errMsg: "Cannot get error response in status."))
            }
            if let statusCode = result.response?.statusCode {
                if statusCode != 200 {
                    return completion(CustomError(errMsg: "Error: \(statusCode), \(err)"))
                }
            }
            
            if !status {
                return completion(CustomError(errMsg: "Error: \(err)"))
            }
            
            return completion(nil)
        }
    }
    
    func deleteLink(authToken: String, docRelationship: DocRelationship, completion: @escaping (_ error: CustomError?) -> Void){
        let url = MasterAPIService.instance.apiEndPoints.DeleteLink
        let openLinkInfo = MasterAPIService.instance.codableToJSON(object: docRelationship)
        let encrypted = MasterAPIService.instance.crypto.encrypt(text: openLinkInfo)!
        let headers = MasterAPIService.instance.generateHeaders(authToken: authToken)
        AF.request(url, method: .post, parameters: ["z" : encrypted], headers: headers).responseJSON { (result) in
            if let err = result.error {
                print(err)
                return completion(CustomError(errMsg: "Error: potential network error."))
            }
            guard let value = result.value else {
                return completion(CustomError(errMsg: "Response error"))
            }
            guard let JSON = value as? NSDictionary else {
                return completion(CustomError(errMsg: "JSON to dict error"))
            }
            guard let status = JSON["status"] as? Bool else {
                return completion(CustomError(errMsg: "Cannot get status."))
            }
            guard let err = JSON["error"] as? String else {
                return completion(CustomError(errMsg: "Cannot get error response in status."))
            }
            if let statusCode = result.response?.statusCode {
                if statusCode != 200 {
                    return completion(CustomError(errMsg: "Error: \(statusCode), \(err)"))
                }
            }
            
            if !status {
                return completion(CustomError(errMsg: "Error: \(err)"))
            }
            
            return completion(nil)
        }
    }
}
protocol UserAPIService {
    func isUserInDatabase(authToken: String, completion: @escaping (_ error: CustomError?, _ isUserInDatabase: isUserInDatabase?) -> Void )
    func createUserProfile(user: User, token: String, completion: @escaping (_ error: CustomError?) -> Void)
    func fetchUserWithoutListener(uid: String, completion: @escaping (_ error: CustomError?, _ user: User?) -> Void)
    func fetchUserListener(uid: String, completion: @escaping (_ error: CustomError?, _ user: User?) -> Void) -> ListenerRegistration
    func isUserInDB2(uid: String, completion: @escaping (_ isUserInDatabase: isUserInDatabase?, _ error: CustomError?) -> Void )
}
extension UserAPIService {
    func isUserInDB2(uid: String, completion: @escaping (_ isUserInDatabase: isUserInDatabase?, _ error: CustomError?) -> Void ) {
        MasterAPIService.instance.firestore.collection("Users").document(uid).getDocument { (snap, error) in
            if let err = error {
                return completion(nil, CustomError(errMsg: err.localizedDescription))
            }
            guard let snap = snap else {
                
                return completion(nil, CustomError(errMsg: "Snapshot info cannot be fetched"))
            }
            if snap.exists {
                return completion(true, nil)
            } else {
                return completion(false, nil)
            }
        }
    }
    func isUserInDatabase(authToken: String, completion: @escaping (_ error: CustomError?, _ isUserInDatabase: isUserInDatabase?) -> Void ) {
        let url = MasterAPIService.instance.apiEndPoints.IsUserInDatabase
        let header = HTTPHeader(name: "x-auth-token", value: authToken)
        let headers = HTTPHeaders([header])
        
        AF.request(url, method: .get, parameters: ["z" : "hehehexd"], headers: headers).responseJSON { (result) in
            
            if let err = result.error {
                print("line 453 masterapiservice!! LOOPING!!! \(err)")
                self.isUserInDatabase(authToken: authToken) { (_, isUserInDataBase) in
                    
                    
                    return completion(nil, isUserInDataBase)
                }
            }
            guard let value = result.value else {
                return completion(CustomError(errMsg: "Response error"), nil)
            }
            guard let JSON = value as? NSDictionary else {
                return completion(CustomError(errMsg: "JSON to dict error"), nil)
            }
            guard let status = JSON["status"] as? Bool else {
                return completion(CustomError(errMsg: "Cannot get status."), nil)
            }
            guard let err = JSON["error"] as? String else {
                return completion(CustomError(errMsg: "Cannot get error response in status."), nil)
            }
            if let statusCode = result.response?.statusCode {
                if statusCode != 200 {
                    return completion(CustomError(errMsg: "Error: \(statusCode), \(err)"), nil)
                }
            }
            
            if !status {
                return completion(nil, status)
            }
            
            return completion(nil, status)
            
            
        }
        //        MasterAPIService.firestore.collection("Users").whereField("uid", isEqualTo: uid).getDocuments { (snap, err) in
        //
        //            if let err = err {
        //                return completion(CustomError(errMsg: err.localizedDescription), false)
        //            }
        //
        //            if snap!.documents.isEmpty{
        //                // register the user
        //                return completion(nil, true)
        //            } else {
        //                return completion(CustomError(errMsg: "User exist"), false)
        //            }
        //
        //        }
    }
    func createUserProfile(user: User, token: String, completion: @escaping (_ error: CustomError?) -> Void) {
        let url = MasterAPIService.instance.apiEndPoints.CreateProfile
        
        user.updateFCM(fcmToken: Messaging.messaging().fcmToken ?? "")
        
        guard let userJSON = MasterAPIService.instance.codableToJSON(object: user) else {
            return completion(CustomError(errMsg: "Cannot conver to JSON"))
        }
        
        let encrypted = MasterAPIService.instance.crypto.encrypt(text: userJSON)
        let header = HTTPHeader(name: "x-auth-token", value: token)
        let headers = HTTPHeaders([header])
        
        
        AF.request(url, method: .post, parameters: ["z" : encrypted], headers: headers).responseJSON { (result) in
            
            if let err = result.error {
                print(err)
                return completion(CustomError(errMsg: "Error: potential network error."))
            }
            guard let value = result.value else {
                return completion(CustomError(errMsg: "Response error"))
            }
            guard let JSON = value as? NSDictionary else {
                return completion(CustomError(errMsg: "JSON to dict error"))
            }
            guard let status = JSON["status"] as? Bool else {
                return completion(CustomError(errMsg: "Cannot get status."))
            }
            guard let err = JSON["error"] as? String else {
                return completion(CustomError(errMsg: "Cannot get error response in status."))
            }
            if let statusCode = result.response?.statusCode {
                if statusCode != 200 {
                    return completion(CustomError(errMsg: "Error: \(statusCode), \(err)"))
                }
            }
            
            if !status {
                return completion(CustomError(errMsg: "Error: \(err)"))
            }
            
            return completion(nil)
            
            
        }
    }
    func fetchUserWithoutListener(uid: String, completion: @escaping (_ error: CustomError?, _ user: User?) -> Void) {
        MasterAPIService.instance.firestore.collection("Users").document(uid).getDocument { (snap, error) in
            
            print("fetchuserWithouListener line156")
            if let err = error {
                return completion(CustomError(errMsg: err.localizedDescription), nil)
            }
            guard let snap = snap else {
                return completion(CustomError(errMsg: "Error getting user snapshot"), nil)
            }
            if !snap.exists {
                return completion(CustomError(errMsg: "No user in databse!"), nil)
            }
            do {
                let user = try snap.data(as: User.self)
                return completion(nil, user)
            } catch let error {
                return completion(CustomError(errMsg: error.localizedDescription), nil)
            }
        }
    }
    func fetchUserListener(uid: String, completion: @escaping (_ error: CustomError?, _ user: User?) -> Void) -> ListenerRegistration {
        let k = MasterAPIService.instance.firestore.collection("Users").document(uid).addSnapshotListener { (snap, error) in
            
            print("fetchuserListener line156")
            if let err = error {
                return completion(CustomError(errMsg: err.localizedDescription), nil)
            }
            guard let snap = snap else {
                return completion(CustomError(errMsg: "Error getting user snapshot"), nil)
            }
            if !snap.exists {
                return completion(CustomError(errMsg: "No user in databse!"), nil)
            }
            do {
                let user = try snap.data(as: User.self)
                return completion(nil, user)
            } catch let error {
                return completion(CustomError(errMsg: error.localizedDescription), nil)
            }
        }
        return k
    }
}
protocol GamesAPIService {
    func fetchImages(searchTerm: String, token: String, completion: @escaping (_ imageArray : [String]?, _ error: CustomError?) -> Void)
    func saveCardGameBundle(cardGameBundle: CardGameBundle, token: String, completion: @escaping ( _ error: CustomError?) -> Void)
    func uploadGameBundleImage(couplesLinkedID: String, gameBundleID: String, cardID: String, urlImages: [String], uiImages: [UIImage], completion: @escaping (_ imageArray : [String]?, _ error: CustomError?) -> Void)
    func deleteImages(imagesToDelete: [String], completion: @escaping (_ error: CustomError?) -> Void)
    func deleteEntireBundleImage(cardGameBundle: CardGameBundle, completion: @escaping (_ error: CustomError?) -> Void)
    func getImageURL(imagePath: String, completion: @escaping (_ downloadURL: String?, _ error: CustomError?) -> Void)
    func fetchCardGameCollectionsListener(couplesDocID: String, myUID: String, isPartner1: Bool, last: QueryDocumentSnapshot?, completion: @escaping (_ error: CustomError?, _ cardGameCollection: [CardGameBundle], _ lastDoc: QueryDocumentSnapshot?) -> Void)
    
    func deleteCardGameBundle(cardGameBundle: CardGameBundle, token: String, completion: @escaping ( _ error: CustomError?) -> Void)
    func beginCardGame(cardGameFormat: CardGameFormat, token: String, completion: @escaping ( _ error: CustomError?) -> Void)
    func completeCardGame(cardGameFormat: CardGameFormat, token: String, completion: @escaping ( _ error: CustomError?) -> Void)
    func fetchCardGameListener (couplesDocID: String, myUID: String, isPartner1: Bool, last: QueryDocumentSnapshot?, completion: @escaping (_ error: CustomError?, _ completedGames: [CardGameFormat], _ gamesPendingResults: [CardGameFormat], _ incompleteGames: [CardGameFormat], _ lastDoc: QueryDocumentSnapshot?) -> Void)
    func fetchGameCard<T : Codable>(couplesDocID: String, myUID: String, isPartner1: Bool, gameProgressToGet: CardGameFormat.GameProgress, last: QueryDocumentSnapshot?, completion: @escaping (_ error: CustomError?, _ game: [T], _ lastDoc: QueryDocumentSnapshot?) -> Void)
}
extension GamesAPIService {

    
    func fetchImages(searchTerm: String, token: String, completion: @escaping (_ imageArray : [String]?, _ error: CustomError?) -> Void) {
        let url = MasterAPIService.instance.apiEndPoints.ImageSearch
        
        let encrypted = MasterAPIService.instance.crypto.encrypt(text: searchTerm)
        
        let header = HTTPHeader(name: "x-auth-token", value: token)
        let headers = HTTPHeaders([header])
        
        AF.request(url, method: .post, parameters: ["z" : encrypted], headers: headers).responseJSON { (result) in
            
            if let err = result.error {
                print(err)
                return completion(nil,CustomError(errMsg: "Error: potential network error."))
            }
            guard let value = result.value else {
                return completion(nil,CustomError(errMsg: "Response error"))
            }
            guard let JSON = value as? NSDictionary else {
                return completion(nil,CustomError(errMsg: "JSON to dict error"))
            }
            guard let status = JSON["status"] as? Bool else {
                return completion(nil,CustomError(errMsg: "Cannot get status."))
            }
            guard let err = JSON["error"] as? String else {
                return completion(nil,CustomError(errMsg: "Unknown error, please try again"))
            }
            if let statusCode = result.response?.statusCode {
                if statusCode != 200 {
                    return completion(nil,CustomError(errMsg: "Error: \(statusCode), \(err)"))
                }
            }
            
            if !status {
                return completion(nil,CustomError(errMsg: "Error: \(err)"))
            }
            guard let imageArray = JSON["images"] as? [String] else {
                return completion(nil,CustomError(errMsg: "Error: Cannot get images, please try an alternative"))
            }
            return completion(imageArray, nil)
            
            
        }
    }
    func fetchGameCard<T : Codable>(couplesDocID: String, myUID: String, isPartner1: Bool, gameProgressToGet: CardGameFormat.GameProgress, last: QueryDocumentSnapshot?, completion: @escaping (_ error: CustomError?, _ game: [T], _ lastDoc: QueryDocumentSnapshot?) -> Void) {
        var gameFormatCollection = [T]()
        var call = MasterAPIService.instance.firestore.collection("CouplesLinked").document(couplesDocID).collection("CardGamesCollection")
        
        switch gameProgressToGet {
            case .completed:
                print("a")
            case .incomplete:
                print("a")
            case .pendingResults:
                print("a")
        }
        
        
        
    }
    func fetchCardGameCollectionsListener(couplesDocID: String, myUID: String, isPartner1: Bool, last: QueryDocumentSnapshot?, completion: @escaping (_ error: CustomError?, _ cardGameCollection: [CardGameBundle], _ lastDoc: QueryDocumentSnapshot?) -> Void)  {
        var cardGameCollection = [CardGameBundle]()
       
       
        if let last = last {
            MasterAPIService.instance.firestore.collection("CouplesLinked").document(couplesDocID).collection("CardGamesCollection").order(by: "favorite", descending: true).order(by: "dateCreated.seconds", descending: true).whereField(isPartner1 ?  "partner1UID" : "partner2UID", isEqualTo: myUID).start(afterDocument: last).limit(to: 6).getDocuments { (snap, error) in
                if let err = error {
                    print(err.localizedDescription)
                    return completion(CustomError(errMsg: "Error: \(err.localizedDescription)"), cardGameCollection, nil)
                }

                guard let snap = snap else {return}
               
                guard let lastSnapshot = snap.documents.last else {
                        print("max: ")
                        return completion(nil, [], last)
                }
                for cardBundle in snap.documents {
                
                    guard let cardBundle = try? cardBundle.data(as: CardGameBundle.self) else {
                        print("Err parsing data data")
                        continue
                    }
                    
                    cardGameCollection.append(cardBundle)
                 
                   
                }
                return completion(nil, cardGameCollection, lastSnapshot)
                
            }
        } else {
            MasterAPIService.instance.firestore.collection("CouplesLinked").document(couplesDocID).collection("CardGamesCollection").order(by: "favorite", descending: true).order(by: "dateCreated.seconds", descending: true).whereField(isPartner1 ?  "partner1UID" : "partner2UID", isEqualTo: myUID).limit(to: 6).getDocuments { (snap, error) in
                if let err = error {
                    print(err.localizedDescription)
                    return completion(CustomError(errMsg: "Error: \(err.localizedDescription)"), cardGameCollection, nil)
                }
//                guard let snap = snap else {
//                    return completion(CustomError(errMsg: "Error getting games collection."), cardGameCollection)
//                }
                guard let snap = snap else {return}
             
               
                for cardBundle in snap.documents {
                
                    guard let cardBundle = try? cardBundle.data(as: CardGameBundle.self) else {
                        print("Err get order data ")
                        continue
                    }
                    
                    
                    cardGameCollection.append(cardBundle)
                 
                   
                }
               
                return completion(nil, cardGameCollection, snap.documents.last)
                
            }
        }
    }
    func fetchCardGameListener (couplesDocID: String, myUID: String, isPartner1: Bool, last: QueryDocumentSnapshot?, completion: @escaping (_ error: CustomError?, _ completedGames: [CardGameFormat], _ gamesPendingResults: [CardGameFormat], _ incompleteGames: [CardGameFormat], _ lastDoc: QueryDocumentSnapshot?) -> Void) {
        var completedGames = [CardGameFormat]()
        var gamesPendingResults = [CardGameFormat]()
        var incompleteGames = [CardGameFormat]()
       
        if let last = last {
            MasterAPIService.instance.firestore.collection("CouplesLinked").document(couplesDocID).collection("CardGames").order(by: "dateCreated.seconds", descending: true).whereField(isPartner1 ?  "partner1Choices.uid" : "partner2Choices.uid", isEqualTo: myUID).whereField(isPartner1 ? "partner2Choices.completed" : "partner1Choices.completed", isEqualTo: true).start(afterDocument: last).limit(to: 6).getDocuments { (snap, error) in
                if let err = error {
                    print(err.localizedDescription)
                    return completion(CustomError(errMsg: "Error: \(err.localizedDescription)"), completedGames, gamesPendingResults, incompleteGames, nil)
                }

                guard let snap = snap else {return}
               
                guard let lastSnapshot = snap.documents.last else {
                        print("max: ")
                        return completion(nil, [], [], [], last)
                }
                for cardGameFormat in snap.documents {
                
                    guard let cardGameFormat = try? cardGameFormat.data(as: CardGameFormat.self) else {
                        print("Err parsing data data")
                        continue
                    }
                    
                    if cardGameFormat.isComplete {
                        completedGames.append(cardGameFormat)
                    } else {
                        if cardGameFormat.partner1Choices.completed {
                            if isPartner1 {
                                gamesPendingResults.append(cardGameFormat)
                            } else {
                                incompleteGames.append(cardGameFormat)
                            }
                        } else {
                            if !isPartner1 {
                                gamesPendingResults.append(cardGameFormat)
                            } else {
                                incompleteGames.append(cardGameFormat)
                            }
                        }
                    }
                 
                   
                }
                return completion(nil, completedGames, gamesPendingResults, incompleteGames, lastSnapshot)
                
            }
        } else {
            MasterAPIService.instance.firestore.collection("CouplesLinked").document(couplesDocID).collection("CardGames").order(by: "dateCreated.seconds", descending: true).whereField(isPartner1 ?  "partner1Choices.uid" : "partner2Choices.uid", isEqualTo: myUID).whereField(isPartner1 ? "partner2Choices.completed" : "partner1Choices.completed", isEqualTo: true).limit(to: 6).getDocuments { (snap, error) in
                if let err = error {
                    print(err.localizedDescription)
                    return completion(CustomError(errMsg: "Error: \(err.localizedDescription)"), completedGames, gamesPendingResults, incompleteGames, nil)
                }
//                guard let snap = snap else {
//                    return completion(CustomError(errMsg: "Error getting games collection."), cardGameCollection)
//                }
                guard let snap = snap else {return}
             
               
                for cardGameFormat in snap.documents {
                
                    guard let cardGameFormat = try? cardGameFormat.data(as: CardGameFormat.self) else {
                        print("Err get order data")
                        continue
                    }
                    if cardGameFormat.isComplete {
                        completedGames.append(cardGameFormat)
                    } else {
                        if cardGameFormat.partner1Choices.completed {
                            if isPartner1 {
                                gamesPendingResults.append(cardGameFormat)
                            } else {
                                incompleteGames.append(cardGameFormat)
                            }
                        } else {
                            if !isPartner1 {
                                gamesPendingResults.append(cardGameFormat)
                            } else {
                                incompleteGames.append(cardGameFormat)
                            }
                        }
                    }
                 
                   
                }
               
                return completion(nil, completedGames, gamesPendingResults, incompleteGames, snap.documents.last)
                
            }
        }
    }
    func uploadGameBundleImage(couplesLinkedID: String, gameBundleID: String, cardID: String, urlImages: [String], uiImages: [UIImage], completion: @escaping (_ imageArray : [String]?, _ error: CustomError?) -> Void) {
        var imageArray = [String]()
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        let myGroup = DispatchGroup()
        
        for image in urlImages {
            myGroup.enter()
            let path = couplesLinkedID + "/" + gameBundleID + "/" + cardID + "/" + UUID().uuidString + ".jpg"
            let storageRef = MasterAPIService.instance.gamesImageStorage.reference(withPath: path)
            let url = URL(string: image)
            let data = try! Data(contentsOf: url!)
            storageRef.putData(data, metadata: metaData) { (metaData, error) in
                if error == nil, metaData != nil {
                    storageRef.downloadURL { (url, err) in
       
                        imageArray.append(url!.absoluteString)
                        myGroup.leave()
                    }
             

                    
                } else {
                    
                    print(error!.localizedDescription)
                    myGroup.leave()
                }
             
            }
        }
        for image in uiImages {
            myGroup.enter()
            if let imgData = image.jpegData(compressionQuality: 0.3) {
                let path = couplesLinkedID + "/" + gameBundleID + "/" + cardID + "/" + UUID().uuidString + ".jpg"
                let storageRef = MasterAPIService.instance.gamesImageStorage.reference(withPath: path)
                storageRef.putData(imgData, metadata: metaData) { (metaData, error) in
                    if error == nil, metaData != nil {
                       
                        storageRef.downloadURL { (url, err) in
                     
                            imageArray.append(url!.absoluteString)
                            myGroup.leave()
                        }
                      
                        
                        
                    } else {
                        myGroup.leave()
                        
                        print(error!.localizedDescription)
                    }
                    
                }
                
            }
            
        }
        
        myGroup.notify(queue: .main) {
            
            print("Finished all requests.")
            return completion(imageArray,nil)
        }
        
    }
    func deleteImages(imagesToDelete: [String], completion: @escaping (_ error: CustomError?) -> Void) {
        let myGroup = DispatchGroup()
        for imageURL in imagesToDelete {
            myGroup.enter()
            let reference = MasterAPIService.instance.gamesImageStorage.reference(forURL: imageURL)
            reference.delete { (error) in
                if let error = error {
                    print(error.localizedDescription)
                    return completion(CustomError(errMsg: "Error: \(error.localizedDescription)"))
                    
                    
                }
                myGroup.leave()
                
            }
        }
        myGroup.notify(queue: .main) {
            
            print("Finished all requests. delete img")
            return completion(nil)
        }
    }
    func deleteEntireBundleImage(cardGameBundle: CardGameBundle, completion: @escaping (_ error: CustomError?) -> Void) {
        let myGroup = DispatchGroup()
        let storage = MasterAPIService.instance.gamesImageStorage
        for card in cardGameBundle.cards {
            
            for urls in card.imagePaths {
                myGroup.enter()
                storage.reference(forURL: urls).delete { (error) in
                    if let err = error {
                        print(err.localizedDescription)
                    }
                    myGroup.leave()
                }
            }
            
        }
        myGroup.notify(queue: .main) {
            
            print("Finished all requests. delete entre img")
            return completion(nil)
        }

    }
    func getImageURL(imagePath: String, completion: @escaping (_ downloadURL: String?, _ error: CustomError?) -> Void) {
        MasterAPIService.instance.gamesImageStorage.reference(withPath: imagePath).downloadURL { (url, error) in
            if let err = error {
                completion(nil, CustomError(errMsg: "Error: \(err)"))
            }
            guard let url = url else {
                return completion(nil,CustomError(errMsg: "Unable to get url, try again."))
            }
            return completion(url.absoluteString, nil)
        }
    }
    func saveCardGameBundle(cardGameBundle: CardGameBundle, token: String, completion: @escaping (_ error: CustomError?) -> Void) {
        
        let url = MasterAPIService.instance.apiEndPoints.SaveCardGameBundle
       
        guard let gamebundleJSON = MasterAPIService.instance.codableToJSON(object: cardGameBundle) else {
            return completion(CustomError(errMsg: "Cannot conver to JSON"))
        }
        let encrypted = MasterAPIService.instance.crypto.encrypt(text: gamebundleJSON)
        
        let header = HTTPHeader(name: "x-auth-token", value: token)
        let headers = HTTPHeaders([header])
        
        AF.request(url, method: .post, parameters: ["z" : encrypted], headers: headers).responseJSON { (result) in
            
            if let err = result.error {
                print(err)
                return completion(CustomError(errMsg: "Error: potential network error."))
            }
            guard let value = result.value else {
                return completion(CustomError(errMsg: "Response error"))
            }
            guard let JSON = value as? NSDictionary else {
                return completion(CustomError(errMsg: "JSON to dict error"))
            }
            guard let status = JSON["status"] as? Bool else {
                return completion(CustomError(errMsg: "Cannot get status."))
            }
            guard let err = JSON["error"] as? String else {
                return completion(CustomError(errMsg: "Unknown error, please try again"))
            }
            if let statusCode = result.response?.statusCode {
                if statusCode != 200 {
                    return completion(CustomError(errMsg: "Error: \(statusCode), \(err)"))
                }
            }
            
            if !status {
                return completion(CustomError(errMsg: "Error: \(err)"))
            }

            return completion(nil)
            
            
        }
    }
    func deleteCardGameBundle(cardGameBundle: CardGameBundle, token: String, completion: @escaping ( _ error: CustomError?) -> Void) {
        let url = MasterAPIService.instance.apiEndPoints.DeleteCardGameBundle
        
        guard let gamebundleJSON = MasterAPIService.instance.codableToJSON(object: cardGameBundle) else {
            return completion(CustomError(errMsg: "Cannot conver to JSON"))
        }
        let encrypted = MasterAPIService.instance.crypto.encrypt(text: gamebundleJSON)
        
        let header = HTTPHeader(name: "x-auth-token", value: token)
        let headers = HTTPHeaders([header])
        
        AF.request(url, method: .post, parameters: ["z" : encrypted], headers: headers).responseJSON { (result) in
            
            if let err = result.error {
                print(err)
                return completion(CustomError(errMsg: "Error: potential network error."))
            }
            guard let value = result.value else {
                return completion(CustomError(errMsg: "Response error"))
            }
            guard let JSON = value as? NSDictionary else {
                return completion(CustomError(errMsg: "JSON to dict error"))
            }
            guard let status = JSON["status"] as? Bool else {
                return completion(CustomError(errMsg: "Cannot get status."))
            }
            guard let err = JSON["error"] as? String else {
                return completion(CustomError(errMsg: "Unknown error, please try again"))
            }
            if let statusCode = result.response?.statusCode {
                if statusCode != 200 {
                    return completion(CustomError(errMsg: "Error: \(statusCode), \(err)"))
                }
            }
            
            if !status {
                return completion(CustomError(errMsg: "Error: \(err)"))
            }

            return completion(nil)
            
            
        }
    }
    func beginCardGame(cardGameFormat: CardGameFormat, token: String, completion: @escaping ( _ error: CustomError?) -> Void) {
            
        let url = MasterAPIService.instance.apiEndPoints.CompleteCardGame
        
        guard let gamebundleJSON = MasterAPIService.instance.codableToJSON(object: cardGameFormat) else {
            return completion(CustomError(errMsg: "Cannot conver to JSON"))
        }
        let encrypted = MasterAPIService.instance.crypto.encrypt(text: gamebundleJSON)
        
        let header = HTTPHeader(name: "x-auth-token", value: token)
        let headers = HTTPHeaders([header])
        
        AF.request(url, method: .post, parameters: ["z" : encrypted], headers: headers).responseJSON { (result) in
            
            if let err = result.error {
                print(err)
                return completion(CustomError(errMsg: "Error: potential network error."))
            }
            guard let value = result.value else {
                return completion(CustomError(errMsg: "Response error"))
            }
            guard let JSON = value as? NSDictionary else {
                return completion(CustomError(errMsg: "JSON to dict error"))
            }
            guard let status = JSON["status"] as? Bool else {
                return completion(CustomError(errMsg: "Cannot get status."))
            }
            guard let err = JSON["error"] as? String else {
                return completion(CustomError(errMsg: "Unknown error, please try again"))
            }
            if let statusCode = result.response?.statusCode {
                if statusCode != 200 {
                    return completion(CustomError(errMsg: "Error: \(statusCode), \(err)"))
                }
            }
            
            if !status {
                return completion(CustomError(errMsg: "Error: \(err)"))
            }

            return completion(nil)
            
            
        }
    }
    func completeCardGame(cardGameFormat: CardGameFormat, token: String, completion: @escaping ( _ error: CustomError?) -> Void) {
            return completion(nil)
    }
}
protocol NotificationAPIService {
    func updateFCM(fcmToken: String, authToken: String)
    
    func clearNotification(typeToClear : MasterAPIService.TypeOfNotification, authToken: String)
}
extension NotificationAPIService {
    func updateFCM(fcmToken: String, authToken: String) {
        let url = MasterAPIService.instance.apiEndPoints.UpdateFCM
        let header = HTTPHeader(name: "x-auth-token", value: authToken)
        let headers = HTTPHeaders([header])
        let encryptedToken = MasterAPIService.instance.crypto.encrypt(text: fcmToken)!
        
        AF.request(url, method: .post, parameters: ["fcmToken" : encryptedToken], headers: headers).responseJSON { (result) in
            if let err = result.error {
                print(err)
                return
            }
            guard let value = result.value else {
                print("fcmUpdate err")
                return
            }
            guard let JSON = value as? NSDictionary else {
                print("fcmUpdate err2")
                return
            }
            guard let status = JSON["status"] as? Bool else {
                print("fcmUpdate err3")
                return
            }
            guard let err = JSON["error"] as? String else {
                print("fcmUpdate err4 ")
                return
            }
            if let statusCode = result.response?.statusCode {
                if statusCode != 200 {
                    print("fcmUpdate err5 \(statusCode), \(err)")
                    return
                }
            }
            if !status {
                print("failed to update fcm \(err)" )
                return
            }
            
        }
    }
    
    func clearNotification(typeToClear : MasterAPIService.TypeOfNotification, authToken: String) {
        let url = MasterAPIService.instance.apiEndPoints.ClearNotification
        let header = HTTPHeader(name: "x-auth-token", value: authToken)
        let headers = HTTPHeaders([header])
        let encryptedToken = MasterAPIService.instance.crypto.encrypt(text: "fcmToken")!
        
        AF.request(url, method: .post, parameters: ["z" : encryptedToken], headers: headers).responseJSON { (result) in
            if let err = result.error {
                print(err)
                return
            }
            guard let value = result.value else {
                print("fcmUpdate err")
                return
            }
            guard let JSON = value as? NSDictionary else {
                print("fcmUpdate err2")
                return
            }
            guard let status = JSON["status"] as? Bool else {
                print("fcmUpdate err3")
                return
            }
            guard let err = JSON["error"] as? String else {
                print("fcmUpdate err4 ")
                return
            }
            if let statusCode = result.response?.statusCode {
                if statusCode != 200 {
                    print("fcmUpdate err5 \(statusCode), \(err)")
                    return
                }
            }
            if !status {
                print("failed to update fcm \(err)" )
                return
            }
            
        }
    }
    
    
}






