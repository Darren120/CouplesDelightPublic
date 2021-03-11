//
//  Models.swift
//  CouplesDelight
//
//  Created by Darren Zou on 10/30/20.
//


import FirebaseFirestore
import Firebase
struct DocRelationship: Codable {
    var exist = false
    var docID = ""
    
}

class User : Codable {
    var firstName: String
    var lastName: String
    var gender: String
    var uid : String
    var phoneNumber : String
    var fcmToken : String
    var birthday : FirebaseFirestore.Timestamp
    var anniversary : FirebaseFirestore.Timestamp?
    var openLink : DocRelationship = DocRelationship(exist: false, docID: "")
    var pendingRequest: DocRelationship = DocRelationship(exist: false, docID: "")
    var couplesLinked: DocRelationship = DocRelationship(exist: false, docID: "")
    var image: String?
   

    func updateFCM(fcmToken: String) {
        self.fcmToken = fcmToken
    }
//    func generateLinkID() {
//        self.linkID = String(self.uid.prefix(5)).uppercased()
//    }
    func getBirthday() -> Date {
        let birthday = FirebaseFirestore.Timestamp.dateValue(self.birthday)()
 
        return birthday
    }
    func getAnniversary() -> String? {
        guard let anni = self.anniversary else {
            return nil
        }
        let anniversary = FirebaseFirestore.Timestamp.dateValue(anni)()
        let formattedDate = anniversary.getCurrentDate()
        return formattedDate
    }
  
    init(firstName: String, lastName: String, gender: String ,uid: String, birthday: Date, phoneNumber: String, fcmToken : String = "") {
        self.firstName = firstName.firstUppercased
        self.lastName = lastName.firstUppercased
        self.gender = gender
        self.uid = uid
        self.birthday = FirebaseFirestore.Timestamp.init(date: birthday.removeHours!)
        self.phoneNumber = phoneNumber
        self.fcmToken = fcmToken
       
       
  
    }
  
}
struct vv : Codable{
    var seconds = 5
    var nanoseconds = 2
    var nanosessconds = 2
}
struct OpenLink : Codable {
    private(set) var selfDocID : String
    private(set) var ownerUID : String
    private(set) var createdOn : FirebaseFirestore.Timestamp
    private(set) var linkID : String
    private(set) var birthday : FirebaseFirestore.Timestamp
    private(set) var anniversary : FirebaseFirestore.Timestamp
    private(set) var linkRequests : [LinkRequest]
    
    init(ownerUID: String, birthday: Date, anniversary : Date, linkRequest : [LinkRequest] = [LinkRequest]()) {
        self.ownerUID = ownerUID
        self.linkID = String.randomString(length: 5)
        self.birthday = FirebaseFirestore.Timestamp.init(date: birthday.removeHours!)
        self.linkRequests = linkRequest
        self.anniversary = FirebaseFirestore.Timestamp.init(date: anniversary.removeHours!)
        self.createdOn = FirebaseFirestore.Timestamp.init(date: Date().removeHours!)
        self.selfDocID = ""
    }
    
    
}

struct LinkRequest : Codable, Hashable {
    private(set) var firstName : String
    private(set) var lastName : String
    private(set) var linkID : String
    private(set) var requesterUID : String
    private(set) var birthday : FirebaseFirestore.Timestamp
    private(set) var anniversary : FirebaseFirestore.Timestamp
    init(firstName: String, lastName: String, requesterUID: String, linkID: String, birthday: Date, anniversary : Date) {
        self.firstName = firstName.firstUppercased
        self.lastName = lastName.firstUppercased
        self.requesterUID = requesterUID
        self.linkID = linkID
        self.birthday = FirebaseFirestore.Timestamp.init(date: birthday.removeHours!)
        self.anniversary = FirebaseFirestore.Timestamp.init(date: anniversary.removeHours!)
    }
}

struct CouplesLinked : Codable {
    private(set) var docID : String
    private(set) var anniversary : FirebaseFirestore.Timestamp
     var partner1 : PartnerDetails
     var partner2 : PartnerDetails
    func getMe(uid: String) -> PartnerDetails {
        if partner1.uid == uid {
            return partner1
        } else {
            return partner2
        }
        
    }
    func getBae(uid: String) -> PartnerDetails {
        if partner1.uid == uid {
            return partner2
        } else {
            return partner1
        }
    }
    func partner1Or2(uid: String) -> Int {
        if partner1.uid == uid {
            return 1
        } else {
            return 2
        }
    }
    struct PartnerDetails : Codable {
         var firstName: String
         var lastName: String
         var uid: String
         var fcmToken: String
         var birthday: FirebaseFirestore.Timestamp
         var notifications: Notifications
        
    }
    struct Notifications: Codable {
        
        var newCardGameDocs: [String]
        var completedCardGame : [String]
        
        func getTotalGameNotification() -> Int {
            return newCardGameDocs.count
        }
        func getToalNotification() -> Int {
            return newCardGameDocs.count
        }
         func resetNotification(type: MasterAPIService.TypeOfNotification) {
            switch type {
            case .cardGame:
                return
//                newCardGameDocs.removeAll()
            default:
                return
            }
        }
    }
}


struct GameDetails : Codable {
    
}

struct CardGameBundle : Codable, Equatable {
    static func == (lhs: CardGameBundle, rhs: CardGameBundle) -> Bool {
        return rhs.bundleTitle == lhs.bundleTitle && rhs.favorite == lhs.favorite
    }
    
    
    var id = UUID().uuidString
    var favorite : Bool = false
    var dateCreated : FirebaseFirestore.Timestamp = FirebaseFirestore.Timestamp.init(date: Date())
    var couplesLinkedDocID : String = ""
    var partner1UID : String = ""
    var partner2UID : String = ""
    var bundleTitle : String
    var cards : [Card]
}

struct Card: Codable, Equatable {
    
    var id = UUID().uuidString 
    var title : String
    var description : String
    var imagePaths : [String]
  
   
}
struct CardWithAxis {
    var card: Card
    var x: CGFloat = 0.0
    var y: CGFloat = 0.0
    var degree: Double = 0.0
}
struct CardGameFormat : Codable {
    enum GameProgress {
        case completed, incomplete, pendingResults
    }
    var docID: String = UUID().uuidString
    var gameBundle: CardGameBundle
    var isComplete : Bool
    var partner1Choices : PartnerDetails
    var partner2Choices : PartnerDetails
    var dateCreated : FirebaseFirestore.Timestamp
    var dateCompleted : FirebaseFirestore.Timestamp
    struct PartnerDetails : Codable {
        var uid : String
        var completed : Bool
        var likedCards : [Card]
        var dislikedCards : [Card]
        var superDislikes : [CardChoiceWithReason]
        var superLikes : [CardChoiceWithReason]
        func totalCardSwiped() -> Int {
            return dislikedCards.count + superDislikes.count + likedCards.count + superLikes.count
        }
    }
    struct CardChoiceWithReason : Codable {
        var card : Card
        var reason : [String]
      
    }
    init(gameBundle: CardGameBundle, isComplete: Bool, partner1Choices: CardGameFormat.PartnerDetails, partner2Choices: CardGameFormat.PartnerDetails, dateCreated: Date?, dateCompleted : Date?) {
        self.gameBundle = gameBundle
        self.isComplete = isComplete
        self.partner1Choices = partner1Choices
        self.partner2Choices = partner2Choices
        self.dateCreated = FirebaseFirestore.Timestamp.init(date: dateCreated ?? Date())
        self.dateCompleted = FirebaseFirestore.Timestamp.init(date: dateCompleted ?? Date())
    }
    
}
class PartnerOneTwo : Codable {
    
}
class SharedInfo : Codable {
    
}
