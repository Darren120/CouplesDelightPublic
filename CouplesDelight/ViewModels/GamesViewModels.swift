//
//  GamesViewModels.swift
//  CouplesDelight
//
//  Created by Darren Zou on 12/15/20.
//

import Foundation
import SwiftUI
import Combine
import Firebase

class MainGameViewModel: ObservableObject {
    var cardGameListener : ListenerRegistration?
    var lastSnapshot : QueryDocumentSnapshot?
    internal init(apiService: MasterAPIService, couplesLinked: CouplesLinked, isPartner1: Bool) {
        self.couplesLinked = couplesLinked
        self.isPartner1 = isPartner1
        self.apiService = apiService
    
        getListener()
    }
    
    var isPartner1: Bool
    var couplesLinked : CouplesLinked
    var apiService: MasterAPIService
    @Published var completeCarddGames : [CardGameFormat] = [] {
        willSet {
            self.objectWillChange.send()
        }
    }
    @Published var incompleteCardGames : [CardGameFormat] = [] {
        willSet {
            self.objectWillChange.send()
        }
    }
    @Published var gamesPendingResults : [CardGameFormat] = [] {
        willSet {
            self.objectWillChange.send()
        }
    }
    func getListener() {
        
        apiService.fetchCardGameListener(couplesDocID: couplesLinked.docID, myUID: isPartner1 ? couplesLinked.partner1.uid : couplesLinked.partner2.uid, isPartner1: isPartner1, last: lastSnapshot) { (error, completedGames, gamesPendingResults, incomepleteGames, newLastSnapshot) in
            if let err = error {
                print(err.localizedDescription)
                return
            }
//            self.notReversedCardBundle.append(contentsOf: cardGameBundles)
            print("completed count: \(completedGames.count)")
            print("incomepleteGames count: \(incomepleteGames.count)")
            print("gamesPendingResults count: \(gamesPendingResults.count)")
            self.completeCarddGames.append(contentsOf: completedGames)
            self.incompleteCardGames.append(contentsOf: incomepleteGames)
            self.gamesPendingResults.append(contentsOf: gamesPendingResults)
            self.lastSnapshot = newLastSnapshot
            self.objectWillChange.send()
            print("get")
//            print("completed")
//            (completedGames.forEach({ (card) in
//                print(card.gameBundle.bundleTitle)
//            }))
//            print("incom")
//            (incomepleteGames.forEach({ (card) in
//                print(card.gameBundle.bundleTitle)
//            }))
//            print("pending")
//            (gamesPendingResults.forEach({ (card) in
//                print(card.gameBundle.bundleTitle)
//            }))
        }
    }
    
}
class CardGameViewModel: AppStateManager {
    var apiService: MasterAPIService
    @Published var showRefreshButton = false {
        willSet {
            self.objectWillChange.send()
        }
    }
    @Published var cardGameBundles = [CardGameBundle]() {
        willSet {
            self.objectWillChange.send()
        }
    }
    @Published var notReversedCardBundle = [CardGameBundle]() {
        willSet {
            self.objectWillChange.send()
        }
    }
    var listener : ListenerRegistration?
    var lastSnapshot: QueryDocumentSnapshot?
    var couplesLinked : CouplesLinked
    var myUID : String
    var isPartner1: Bool
    init(apiService: MasterAPIService, couplesLinked: CouplesLinked, myUID: String, isPartner1: Bool) {
        self.apiService = apiService
        self.couplesLinked = couplesLinked
        self.myUID = myUID
        self.isPartner1 = isPartner1
        super.init()
        getCardCollectionListener()
    }
    
    func forcedRefresh() {
        self.cardGameBundles.removeAll()
        self.lastSnapshot = nil
        self.getCardCollectionListener()
        self.showRefreshButton = false
    }
    
    func getCardCollectionListener() {

        self.apiService.fetchCardGameCollectionsListener(couplesDocID: couplesLinked.docID, myUID: myUID, isPartner1: isPartner1, last: lastSnapshot) {  [unowned self] (error, cardGameBundleArray, lastSnapshot)  in
            print(cardGameBundles.debugDescription)
            if let err = error {
                print(err.localizedDescription)
                return
            }
//            self.notReversedCardBundle.append(contentsOf: cardGameBundles)
            self.cardGameBundles.append(contentsOf: cardGameBundleArray)
            self.lastSnapshot = lastSnapshot
            self.objectWillChange.send()
        }
        
    }
    
}
class MakeGameBundleViewModel : AppStateManager {
    var apiService: MasterAPIService
    @Published var parentCardGameVM: CardGameViewModel
    @Published var cardBundleTitle : String = "" {
        willSet {
            
            self.objectWillChange.send()
        }
    }

    @Published var cardBundle : CardGameBundle {
        willSet {
            
            self.objectWillChange.send()
        }
    }
    var originalTitle : String
    var originalCard : CardGameBundle
    init(cardBundle: CardGameBundle = CardGameBundle(bundleTitle: "", cards: []), apiService: MasterAPIService, parentCardGameVM: CardGameViewModel) {
        self.cardBundle = cardBundle
        self.cardBundleTitle = cardBundle.bundleTitle
        self.parentCardGameVM = parentCardGameVM
        self.originalCard = cardBundle
        self.apiService = apiService
        self.originalTitle = cardBundle.bundleTitle
        
    }
    
    
    func getImages(searchTerm: String) -> [String] {
        return [""]
    }
    
    func makeCardBundle(completion: @escaping (_ success : Bool) -> Void) {
        if self.cardBundleTitle.count > 20 {
            return completion(false)
        }
        let cardBundle = CardGameBundle(bundleTitle: self.cardBundleTitle, cards: [])
    
        self.cardBundle = cardBundle
        self.originalTitle = self.cardBundleTitle
        self.originalCard = cardBundle
        return completion(true)
    }
    func saveGameBundle(completion: @escaping (_ success: Bool) -> Void) {
        self.indicatorType = .loading(message: "Saving...")
        if cardBundle.cards.isEmpty {
            self.indicatorType = .error(message: "Add at least one card!")
            return completion(false)
        }
        if originalCard == cardBundle {
            self.indicatorType = .success(message: "Saved successfully.")
            return completion(false)
        }
        
        self.apiService.getAuthToken { (token, error) in
            if let err = error {
                self.indicatorType = .error(message: err.errMsg)
                return completion(false)
            }
            guard let token = token else {
                self.indicatorType = .error(message: "Error getting authentican token. Please try again.")
                return completion(false)
            }
            self.apiService.saveCardGameBundle(cardGameBundle: self.cardBundle, token: token) { (error) in
                if let err = error {
                    self.indicatorType = .error(message: err.errMsg)
                    return completion(false)
                }
                self.syncLocally()
                self.indicatorType = .success(message: "Saved sucessfully")
                return completion(true)
                
            }
        }
    }
    func deleteBundle(completion: @escaping (_ success: Bool) -> Void) {
        if self.cardBundle.cards.count == 0 {
            print("empty card")
            return completion(false)
        }
        self.indicatorType = .loading(message: "One sec...")
        self.apiService.deleteEntireBundleImage(cardGameBundle: self.cardBundle) { (error) in
            if let err = error {
                self.indicatorType = .error(message: err.errMsg)
                return completion(false)
            }
            self.apiService.getAuthToken { (token, error) in
                if let err = error {
                    print("token")
                    self.indicatorType = .error(message: err.errMsg)
                    return completion(false)
                }
                guard let token = token else {
                    self.indicatorType = .error(message: "Error getting authentication token.")
                    return
                }
                self.apiService.deleteCardGameBundle(cardGameBundle: self.cardBundle, token: token) { (error) in
                    if let err = error {
                        self.indicatorType = .error(message: "Error deleting: \(err.localizedDescription)")
                        return completion(false)
                    }
         
                    self.indicatorType = .success(message: "Delete successfully.")
                    self.syncLocally()
                    return completion(true)
//                    for index in 0..<self.parentCardGameVM.cardGameBundles.count {
//                        if self.parentCardGameVM.cardGameBundles[index].id == self.cardBundle.id {
//                            self.parentCardGameVM.cardGameBundles.remove(at: index)
//                            self.cardBundle.bundleTitle = "Deleted"
//                            self.cardBundle.cards.removeAll()
//
//                        }
//
//                    }
                }
            }
        }
        
    }
  
    func syncLocally(){
        
//        self.originalCard = cardBundle
        self.parentCardGameVM.forcedRefresh()
        self.parentCardGameVM.showRefreshButton = true
//        self.parentCardGameVM.cardGameBundles.append(self.cardBundle)
        self.objectWillChange.send()
    }
}
class AddCardViewModel: AppStateManager {
    var apiService: MasterAPIService
    var couplesLinkedID: String
    @Published var parentMakeGameVM: MakeGameBundleViewModel
    @Published var showPhotoPicker = false {
        willSet {
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }
    @Published var imageTitle : String = "" {
        willSet {
            self.objectWillChange.send()
        }
    }
    @Published var imageDescription : String = "" {
        willSet {
            self.objectWillChange.send()
        }
    }
    
    @Published var totalImagesSelected = 0 {
        willSet {
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
            
        }
    }
    @Published var cameraRollImages : [UIImage] = [] {
        willSet {
            DispatchQueue.main.async {
                
                self.totalImagesSelected = newValue.count + self.selectedAPIImages.count + (self.card?.imagePaths.count ?? 0)
                
                self.objectWillChange.send()
            }
            
        }
    }
    @Published var apiImages : [String] = [] {
        willSet {
            self.objectWillChange.send()
        }
    }
    @Published var selectedAPIImages : [String] = [] {
        willSet {
            DispatchQueue.main.async {
                self.totalImagesSelected = newValue.count + self.cameraRollImages.count + (self.card?.imagePaths.count ?? 0)
                
                self.objectWillChange.send()
            }
            
        }
    }
    @Published var existingImageURLs = [String]() {
        willSet {
            self.totalImagesSelected = newValue.count + self.cameraRollImages.count + self.selectedAPIImages.count
            self.objectWillChange.send()
        }
    }
    @Published var card: Card? {
        willSet {
            self.objectWillChange.send()
        }
    }
    var originalCard : Card?
    init(makeGameVM: MakeGameBundleViewModel, apiService: MasterAPIService, card: Card?, couplesLinkedID: String) {
        self.parentMakeGameVM = makeGameVM
        self.apiService = apiService
        self.couplesLinkedID = couplesLinkedID
        guard let card = card else {
            return
        }
        self.card = card
        self.originalCard = card
        self.imageTitle = card.title
        self.imageDescription = card.description
        self.totalImagesSelected = card.imagePaths.count
        
        
    }
    func removeExistingImage(index : Int) {
        print("index \(index)")
        
        guard let _ = card else {
            self.indicatorType = .error(message: "Error, please try again")
            return
        }
        
        self.card!.imagePaths.remove(at: index)
        self.totalImagesSelected = self.card!.imagePaths.count + self.selectedAPIImages.count + self.cameraRollImages.count
    }
    func removeImageFromCameraRoll(index: Int) {
        self.cameraRollImages.remove(at: index)
    }
    func imageFromCameraRoll() {
        DispatchQueue.main.async {
            if self.totalImagesSelected >= 3 {
                self.indicatorType = .error(message: "You can only have a maximum images of 3")
                return
            }
            self.showPhotoPicker = true
        }
        
        
    }
    var currentTitle = ""
    func getImagesFromAPI() {
        if currentTitle == self.imageTitle || imageTitle == "" {
            return
        }
        self.currentTitle = self.imageTitle
        if self.imageTitle.count == 0 {
            self.indicatorType = .error(message: "Enter a image title to get images")
            return
        }
        self.indicatorType = .loading(message: "Getting images!!!")
        apiService.getAuthToken { (token, error) in
            if let err = error {
                self.indicatorType = .error(message: err.errMsg)
                return
            }
            guard let token = token else {
                self.indicatorType = .error(message: "Error authenciating, please try again!")
                return
            }
            self.apiService.fetchImages(searchTerm: self.imageTitle, token: token) { (images, error) in
                if let err = error {
                    self.indicatorType = .error(message: err.errMsg)
                    return
                }
                guard let images = images else {
                    self.indicatorType = .error(message: "Error getting images. Please try again or use your own")
                    return
                }
                self.apiImages = images
                self.showIndicator = false
            }
        }
    }
    func selectImage(url: String) {
        print(totalImagesSelected)
        if totalImagesSelected < 3 || selectedAPIImages.contains(url){
            for i in 0..<selectedAPIImages.count {
                if selectedAPIImages[i] == url {
                    selectedAPIImages.remove(at: i)
                    return
                }
            }
            
            selectedAPIImages.append(url)
        }
    }
    func deleteEntireCard() {
        
    }
    func saveCard(completion: @escaping (_ success: Bool) -> Void) {
        if totalImagesSelected <= 0 {
            self.indicatorType = .error(message: "Please select at least one image!")
            return completion(false)
        }
        self.card?.title = imageTitle
        self.card?.description = imageDescription
        guard self.card != originalCard || (!self.cameraRollImages.isEmpty || !self.selectedAPIImages.isEmpty) else {
            self.indicatorType = .success(message: "Saved!")
            print(self.cameraRollImages.count)
            print(self.selectedAPIImages.count)
            return completion(false)
        }
        self.indicatorType = .loading(message: "saving...")
        self.apiService.getAuthToken { (token, err) in
            guard let token = token else {
                self.indicatorType = .error(message: "Error getting auth token.")
                return completion(false)
            }
            if let err = err {
                self.indicatorType = .error(message: "Error: \(err)")
                return completion(false)
            }
            
            if self.card == nil {
                var newCard = Card(title: self.imageTitle, description: self.imageDescription, imagePaths: [])
                self.apiService.uploadGameBundleImage(couplesLinkedID: self.couplesLinkedID, gameBundleID: self.parentMakeGameVM.cardBundle.id, cardID: newCard.id, urlImages: self.selectedAPIImages, uiImages: self.cameraRollImages) { (imagePaths, err) in
                    if let err = err {
                        self.indicatorType = .error(message: "Error while saving images. \(err)")
                        return completion(false)
                    }
                    guard let imagePaths = imagePaths else {
                        self.indicatorType = .error(message: "Error while getting image paths.")
                        return completion(false)
                    }
                    
                    newCard.imagePaths.append(contentsOf: imagePaths)
                    self.parentMakeGameVM.cardBundle.cards.append(newCard)
                    
                    self.apiService.saveCardGameBundle(cardGameBundle: self.parentMakeGameVM.cardBundle, token: token) { (err) in
                        if let err = err {
                            print("err: \(err)")
                            self.parentMakeGameVM.cardBundle.cards.removeLast()
                            self.indicatorType = .error(message: "Error while saving game bundle. \(err)")
                            return completion(false)
                        }
                        
                        self.parentMakeGameVM.syncLocally()
                        self.indicatorType = .success(message: "done + \(imagePaths.count)")
                        return completion(true)
                    }
                    
                }
            } else {
                guard let _ = self.card else {
                    self.indicatorType = .error(message: "Error getting card info.")
                    return
                }
                
                for index in 0...self.parentMakeGameVM.cardBundle.cards.count - 1 {
                    
                    if self.parentMakeGameVM.cardBundle.cards[index].id == self.card!.id {
                        let originalCard = self.parentMakeGameVM.cardBundle.cards[index]
//                        guard originalCard.imagePaths.count != card.imagePaths.count else {
//                            print("no changes")
//                            return completion()
//                        }
                        let difference = originalCard.imagePaths.difference(from: self.card!.imagePaths)
//                        var replacementCard = Card(title: self.imageTitle, description: self.imageDescription, imagePaths: [])
//                        replacementCard.imagePaths.append(contentsOf: self.card?.imagePaths ?? [])
                      
                        self.apiService.deleteImages(imagesToDelete: difference) { (error) in
                            if let err = error {
                                print(err.localizedDescription)
                                self.indicatorType = .error(message: err.errMsg)
                                return completion(false)
                            }
                            
                        
                            if (self.selectedAPIImages.count != 0 || self.cameraRollImages.count != 0) {
                                self.apiService.uploadGameBundleImage(couplesLinkedID: self.couplesLinkedID, gameBundleID: self.parentMakeGameVM.cardBundle.id, cardID: self.card!.id, urlImages: self.selectedAPIImages, uiImages: self.cameraRollImages) { (imageURLs, error) in
                                    if let err = error {
                                        print(err.localizedDescription)
                                        self.indicatorType = .error(message: err.errMsg)
                                        return completion(false)
                                    }
                                    guard var imageURLs = imageURLs else {
                                        self.indicatorType = .error(message: "err imageurl xd")
                                        return completion(false)
                                    }
                                    imageURLs.append(contentsOf: self.card!.imagePaths)
                                    let replacementCard = Card(title: self.imageTitle, description: self.imageDescription, imagePaths: imageURLs)
                                   
                                    
                                    self.parentMakeGameVM.cardBundle.cards.remove(at: index)
                                    self.parentMakeGameVM.cardBundle.cards.insert(replacementCard, at: index)
                                    self.apiService.saveCardGameBundle(cardGameBundle: self.parentMakeGameVM.cardBundle, token: token) { (error) in
                                        if let err = error {
                                            print(err.localizedDescription)
                                            self.parentMakeGameVM.cardBundle.cards.remove(at: index)
                                            self.parentMakeGameVM.cardBundle.cards.insert(originalCard, at: index)
                                            self.indicatorType = .error(message: err.errMsg)
                                            return completion(false)
                                        }
                                        print("image deleted and saved")
                                        self.selectedAPIImages.removeAll()
                                        self.cameraRollImages.removeAll()
                                        self.card = replacementCard
                                        self.totalImagesSelected = replacementCard.imagePaths.count
                                        self.parentMakeGameVM.syncLocally()
                                        self.showIndicator = false
                                        return completion(true)
                                    }
                                }
                            } else {
                                
                                self.parentMakeGameVM.cardBundle.cards.remove(at: index)
                                self.parentMakeGameVM.cardBundle.cards.insert(self.card!, at: index)
                                
                                self.apiService.saveCardGameBundle(cardGameBundle: self.parentMakeGameVM.cardBundle, token: token) { (error) in
                                    if let err = error {
                                        print(err.localizedDescription)
                                        self.parentMakeGameVM.cardBundle.cards.remove(at: index)
                                        self.parentMakeGameVM.cardBundle.cards.insert(originalCard, at: index)
                                        self.indicatorType = .error(message: err.errMsg)
                                        return completion(false)
                                    }
                                    print("saved")
                                    self.totalImagesSelected = self.card!.imagePaths.count
                                    self.parentMakeGameVM.syncLocally()
                                    self.indicatorType = .success(message: "Saved!")
                                    return completion(true)
                                }
                            }
                           
                        }
                                
                        
                    }
                }
            }
        }
    }
    
}

class PlayCardGameViewModel : AppStateManager {
    var couplesLinked : CouplesLinked
    var myUID: String
    var isNewGame = false
    var isPartner1 : Bool
    var apiService: MasterAPIService
   
    @Published var cards: [Card]
    @Published var acceptedCards = [String]()
    @Published var deniedCards = [String]()
    @Published var activeGameProgress : CardGameFormat
    @Published var reasonForChoice : String = ""
    init(myUID: String, cardGameBundle : CardGameBundle, apiService: MasterAPIService, couplesLinked: CouplesLinked, isPartner1: Bool, activeGameProgress: CardGameFormat?) {
       print("play game vm")
        self.myUID = myUID
        self.couplesLinked = couplesLinked
        self.apiService = apiService
        self.isPartner1 = isPartner1
        self.cards = cardGameBundle.cards
        if let activeGameProgress = activeGameProgress {
            self.activeGameProgress = activeGameProgress
       
            isNewGame = false
            
        } else {
 
            isNewGame = true
            
            let newPartner1 = CardGameFormat.PartnerDetails(uid: couplesLinked.partner1.uid, completed: false, likedCards: [], dislikedCards: [], superDislikes: [], superLikes: [])
            let newPartner2 = CardGameFormat.PartnerDetails(uid: couplesLinked.partner2.uid, completed: false, likedCards: [], dislikedCards: [], superDislikes: [], superLikes: [])
            self.activeGameProgress = CardGameFormat(gameBundle: cardGameBundle, isComplete: false, partner1Choices: newPartner1, partner2Choices: newPartner2, dateCreated: nil, dateCompleted: nil)
        }
        
    }
    enum TypeOfChoice {
        case like, dislike, superLike(reason: String = ""), superDislike(reason: String = "")
    }
    func appendCard(appendType: TypeOfChoice, cardIndex : Int) {
        let cards = activeGameProgress.gameBundle.cards
        switch appendType {
        case .like:
            
            if isPartner1 {
                print("aaaa")
                self.activeGameProgress.partner1Choices.likedCards.append(cards[cardIndex])
            } else {
                print("bbb")
                self.activeGameProgress.partner2Choices.likedCards.append(cards[cardIndex])
            }
//            print(activeGameProgress.partner2Choices.likedCards.count)
        case .superLike(let reason):
            let card = cards[cardIndex]
            let choiceWithReason = CardGameFormat.CardChoiceWithReason(card: card, reason: [reason])
            if isPartner1 {
                self.activeGameProgress.partner1Choices.superLikes.append(choiceWithReason)
            } else {
                self.activeGameProgress.partner2Choices.superLikes.append(choiceWithReason)
            }
        case .dislike:
            if isPartner1 {
                self.activeGameProgress.partner1Choices.dislikedCards.append(cards[cardIndex])
            } else {
                self.activeGameProgress.partner2Choices.dislikedCards.append(cards[cardIndex])
            }
        case .superDislike(let reason):
            let card = cards[cardIndex]
            let choiceWithReason = CardGameFormat.CardChoiceWithReason(card: card, reason: [reason])
            if isPartner1 {
                self.activeGameProgress.partner1Choices.superDislikes.append(choiceWithReason)
            } else {
                self.activeGameProgress.partner2Choices.superDislikes.append(choiceWithReason)
            }
        
        }
    }
    func gameResult() {
        if isPartner1 {
            self.activeGameProgress.partner1Choices.likedCards.forEach { (card) in
                print("liked title: \(card.title)")
            }
            self.activeGameProgress.partner1Choices.dislikedCards.forEach { (card) in
                print("disliked title: \(card.title)")
            }
            self.activeGameProgress.partner1Choices.superLikes.forEach { (card) in
                print("superliked title: \(card.card.title), reason: \(card.reason[0])")
            }
            self.activeGameProgress.partner1Choices.superDislikes.forEach { (card) in
                print("superdisliked title: \(card.card.title), reason: \(card.reason[0])")
            }
        } else {
            self.activeGameProgress.partner2Choices.likedCards.forEach { (card) in
                print("liked title: \(card.title)")
            }
            self.activeGameProgress.partner2Choices.dislikedCards.forEach { (card) in
                print("disliked title: \(card.title)")
            }
            self.activeGameProgress.partner2Choices.superLikes.forEach { (card) in
                print("superliked title: \(card.card.title), reason: \(card.reason[0])")
            }
            self.activeGameProgress.partner2Choices.superDislikes.forEach { (card) in
                print("superdisliked title: \(card.card.title), reason: \(card.reason[0])")
            }
        }
    }
    func createGame(completion: @escaping (_ success: Bool) -> Void) {
        self.indicatorType = .loading(message: "Sending to bae..")
        if isPartner1 {
           if self.activeGameProgress.partner1Choices.totalCardSwiped() == self.activeGameProgress.gameBundle.cards.count {
                self.activeGameProgress.partner1Choices.completed = true
           } else {
            self.indicatorType = .error(message: "An error has occured, please restart the game.")
            return completion(false)
           }
        } else {
            if self.activeGameProgress.partner2Choices.totalCardSwiped() == self.activeGameProgress.gameBundle.cards.count {
                 self.activeGameProgress.partner2Choices.completed = true
            } else {
                self.indicatorType = .error(message: "An error has occured, please restart the game.")
                return completion(false)
            }
        }
        self.apiService.getAuthToken { (token, error) in
            if let err = error {
                print(err.errMsg)
                self.indicatorType = .error(message: "Error, please try again.")
                return completion(false)
            }
            guard let token = token else {
                self.indicatorType = .error(message: "Token error.")
                return completion(false)
            }
            self.apiService.beginCardGame(cardGameFormat: self.activeGameProgress, token: token) { (error) in
                if let err = error {
                    print(err.errMsg)
                    self.indicatorType = .error(message: "Error sending game.")
                    return
                }
                print("Done.")
                self.showIndicator = false
                return completion(true)
            }
        }
        
    }
    func sendGameRematch() {
        
    }
    func updateGame() {
        
    }
}
