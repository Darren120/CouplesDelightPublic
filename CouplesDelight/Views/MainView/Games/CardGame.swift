//
//  CardGame.swift
//  CouplesDelight
//
//  Created by Darren Zou on 1/5/21.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI
import PhotosUI
import ExyteGrid
let impactMed = UIImpactFeedbackGenerator(style: .medium)

struct PendingCardGameView : View {
    @EnvironmentObject var authManager : AuthManager
    @StateObject var mainGameVM : MainGameViewModel
    @State var selectedGame: CardGameFormat?
    @State var navigate = false
    enum GameType {
        case completedGame, incompleteGame, none
    }
    @State var gameType: GameType = .none
    let columns = [
        GridItem(.adaptive(minimum: 80))
    ]
    enum ShowGameFormat {
        case pending, completed, waiting
    }
    @State var format : ShowGameFormat = .pending
    var body: some View {
        ZStack{
            if gameType == .incompleteGame && self.selectedGame != nil {
                NavigationLink(destination: SwipeView(dismiss: self.$navigate, playCardGameVM: PlayCardGameViewModel(myUID: self.authManager.uid, cardGameBundle: selectedGame!.gameBundle, apiService: self.authManager.apiService, couplesLinked: self.authManager.couplesLinked!, isPartner1: self.authManager.isPartner1, activeGameProgress: self.selectedGame)), isActive: self.$navigate) {
                    Text("")
                }
            } else if gameType == .completedGame && self.selectedGame != nil{
                
            }
            
            ScrollView(.vertical, showsIndicators: false) {
        VStack {
            HStack{
                Button {
                    self.format = .pending
                } label: {
                    Text("Pending")
                }
                Button {
                    self.format = .completed
                } label: {
                    Text("completed")
                }
                Button {
                    self.format = .waiting
                } label: {
                    Text("Waiting")
                }

            }
            if format == .pending {
                VStack {
                    Text("Pending Games")
                    LazyVGrid(columns: columns, spacing: 20) {
                        
                        ForEach(self.mainGameVM.incompleteCardGames, id: \.docID) { cardGameFormat in
                            ZStack{
                                if cardGameFormat.docID == self.mainGameVM.incompleteCardGames.last?.docID {
                                    Text("").onAppear{
                                        self.mainGameVM.getListener()
                                        print("last reached")}
                                    
                                }
                                
                                Button {
                                    withAnimation {
                                        self.gameType = .incompleteGame
                                        self.selectedGame = cardGameFormat
                                        self.navigate = true
                                    }
                                    
                                } label: {
                                    CardGamePreviewCell( cardGameFormat: cardGameFormat)
                                }
                            }
                            
                        }
                    }.padding(.horizontal).padding(.bottom)
                }
            } else if format == .completed {
                VStack {
                    Text("Pending Games")
                    LazyVGrid(columns: columns, spacing: 20) {
                        
                        ForEach(self.mainGameVM.completeCarddGames, id: \.docID) { cardGameFormat in
                            ZStack{
                                if cardGameFormat.docID == self.mainGameVM.completeCarddGames.last?.docID {
                                    Text("").onAppear{
                                        self.mainGameVM.getListener()
                                        print("last reached")}
                                    
                                }
                                
                                Button {
                                    withAnimation {
                                        self.gameType = .incompleteGame
                                        self.selectedGame = cardGameFormat
                                        self.navigate = true
                                    }
                                    
                                } label: {
                                    CardGamePreviewCell( cardGameFormat: cardGameFormat)
                                }
                            }
                            
                        }
                    }.padding(.horizontal).padding(.bottom)
                }
            } else if format == .waiting {
                VStack {
                    Text("Pending Games")
                    LazyVGrid(columns: columns, spacing: 20) {
                        
                        ForEach(self.mainGameVM.gamesPendingResults, id: \.docID) { cardGameFormat in
                            ZStack{
                                if cardGameFormat.docID == self.mainGameVM.gamesPendingResults.last?.docID {
                                    Text("").onAppear{
                                        self.mainGameVM.getListener()
                                        print("last reached")}
                                    
                                }
                                
                                Button {
                                    withAnimation {
                                        self.gameType = .incompleteGame
                                        self.selectedGame = cardGameFormat
                                        self.navigate = true
                                    }
                                    
                                } label: {
                                    CardGamePreviewCell( cardGameFormat: cardGameFormat)
                                }
                            }
                            
                        }
                    }.padding(.horizontal).padding(.bottom)
                }
            }
            
            
        }
            }
        }
    }
    struct CardGamePreviewCell: View {

        let cardGameFormat: CardGameFormat
        var body: some View {

                VStack{
                    
                    //                        ForEach(self.gameBundle.cards.indices, id: \.self) { (index) in
                    if  cardGameFormat.gameBundle.cards.indices.contains(0) {
                        if cardGameFormat.gameBundle.cards[0].imagePaths.indices.contains(0){
                            WebImage(url: URL(string: cardGameFormat.gameBundle.cards[0].imagePaths[0])).resizable().frame(width: 87, height: 120).cornerRadius(13).shadow(radius: 10).overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.green)
                            )
                        }
                    }
                    //                        }
                    
                    
                    Text(cardGameFormat.gameBundle.bundleTitle)
                        .font(.system(size: 14)).fontWeight(.bold).multilineTextAlignment(.center).frame(alignment: .bottom)
                
            }
            
            
            
        }
        
    }
}
struct CardGame : View {
  
    var activityItems = [CardGameBundle(bundleTitle: "Food", cards: [Card(title: "chinese food", description: "nice food", imagePaths: ["https://cdn.pocket-lint.com/r/s/1200x/assets/images/142413-apps-feature-art-and-science-collide-the-best-in-modern-space-art-image1-iha6vzu3wk.jpg"])])]
    @EnvironmentObject var authManager : AuthManager
    @StateObject var cardGameVM : CardGameViewModel
    @Environment(\.colorScheme) var colorScheme
    @State var showDailyRecommendations = true
    @State var selectedGame : CardGameBundle?
    @State var showAlert = false
    @State var playGame = false
    enum AlertType {
        case create, select, none
    }
    @State var alertType : AlertType = .none
    
    
    let columns = [
        GridItem(.adaptive(minimum: 80))
    ]
    var body: some View {
        
        ZStack {
            if self.selectedGame != nil && self.playGame && self.authManager.couplesLinked != nil {
                NavigationLink(destination: SwipeView(dismiss: self.$showAlert, playCardGameVM: PlayCardGameViewModel(myUID: self.authManager.uid, cardGameBundle: self.selectedGame!, apiService: self.authManager.apiService, couplesLinked: self.authManager.couplesLinked!, isPartner1: self.authManager.isPartner1,activeGameProgress: nil)), isActive: self.$playGame) {
                    Text("")
                }
            }
            ScrollView(.vertical, showsIndicators: false) {
                
                ScrollViewReader { proxy in
                    VStack{
                        
                        HStack{
                            
                            //                                NavigationLink(destination: MakeGameBundleView()) {
                            //                                    Text("Create Game").frame(width: 75, height: 75).multilineTextAlignment(.center)
                            //                                }.background(Color("green-1")).frame(width: 75, height: 75).cornerRadius(10).shadow(color: Color.black.opacity(0.1), radius: 10, y: 10)
                            Button {
                                withAnimation {
                                    self.alertType = .create
                                    self.showAlert = true
                                }
                            } label: {
                                Text("Create Game").multilineTextAlignment(.center).frame(width: 75, height: 75)
                            }.background(Color("green-1")).frame(width: 75, height: 75).cornerRadius(10).shadow(color: Color.black.opacity(0.10), radius: 10, y: 10)
                            Button {
                                withAnimation {
                                    proxy.scrollTo(1, anchor: .top)
                                }
                            } label: {
                                Text("Random Game!").multilineTextAlignment(.center).frame(width: 75, height: 75)
                            }.background(Color("green-1")).frame(width: 75, height: 75).cornerRadius(10).shadow(color: Color.black.opacity(0.10), radius: 10, y: 10)
                            Button {
                                withAnimation {
                                    proxy.scrollTo(1, anchor: .top)
                                }
                            } label: {
                                Text("Pick Game: 0").multilineTextAlignment(.center).frame(width: 75, height: 75)
                            }.background(Color("green-1")).frame(width: 75, height: 75).cornerRadius(10).shadow(color: self.colorScheme == .dark ? Color.white.opacity(0.15) : Color.black.opacity(0.04) , radius: 10, y: 10)
                            
                        }
                    }.padding(.top, 20)
                    ZStack{
                        //                        RoundedRectangle(cornerRadius: 20)
                        //                            .fill(Color("WhiteOrBlack"))
                        //                            .frame(height: 300)
                        //                            .padding(.horizontal, 6)
                        //                            .shadow(color: Color.black.opacity(0.08), radius: 10, y: 10)
                        
                        
                        
                        VStack(alignment: .leading, spacing: 30) {
                            HStack {
                                Text("Daily Recommendations").foregroundColor(Color("textColor"))
                                    .font(.system(size: 22, weight: .semibold))
                                
                                
                            }
                            HStack(spacing: 30) {
                                ForEach(0..<3) { _ in
                                    Button {
                                        withAnimation {
                                            self.alertType = .select
                                            self.selectedGame = activityItems[0]
                                            self.showAlert = true
                                        }
                                    } label: {
                                        CardGamePreviewCell(cardGameBundle: activityItems[0])
                                    }
                                }
                                
                                
                            }
                            
                        }
                        Button {
                            withAnimation {
                                self.showDailyRecommendations = false
                            }
                        } label: {
                            Text("X").fontWeight(.bold)
                        }.position(x: UIScreen.main.bounds.maxX - 60, y: 35).padding()
                        
                    }.background(Color("WhiteOrBlack")).cornerRadius(10).opacity(self.showDailyRecommendations ? 1 : 0).frame(height: self.showDailyRecommendations ? 300 : 0).padding(.horizontal, 5)
                    //                    ZStack{
                    
                    VStack(alignment: .center){
                        HStack{
                            Spacer()
                            Text("Collection").foregroundColor(Color("textColor")).font(.system(size: 22, weight: .semibold)).padding([.top, .leading]).id(1)
                            Spacer()
                            Button {
                                cardGameVM.forcedRefresh()
                            } label: {
                                Image(systemName: "arrow.clockwise").resizable().scaledToFit().frame(width:18, height:18)
                            }.padding(.top).padding(.trailing, 8)
                            
                        }
                        LazyVGrid(columns: columns, spacing: 20) {
                            
                            ForEach(self.cardGameVM.cardGameBundles, id: \.id) { cardBundle in
                                ZStack{
                                    if cardBundle.id == self.cardGameVM.cardGameBundles.last?.id{
                                        Text("").onAppear{
                                            self.cardGameVM.getCardCollectionListener()
                                            print("last reached")}
                                        
                                    }
                                    Button {
                                        withAnimation {
                                            self.alertType = .select
                                            self.selectedGame = cardBundle
                                            self.showAlert = true
                                        }
                                    } label: {
                                        CardGamePreviewCell(cardGameBundle: cardBundle)
                                    }

                                    
                                        
                                  
                                    
                                }
                                
                            }
                        }.padding(.horizontal).padding(.bottom)
                    }
                    .background(Color("WhiteOrBlack")).cornerRadius(10).padding()
                    //                    }
                }
            }.disabled(self.showAlert).blur(radius: self.showAlert ? 15 : 0)
            
            if showAlert {
                VStack{
                    if alertType == .select && self.selectedGame != nil {
                        GaamesAlertView(showAlert: self.$showAlert, makeGameVM: MakeGameBundleViewModel(apiService: self.authManager.apiService, parentCardGameVM: self.cardGameVM), playGame: self.$playGame, parentCardGameVM: self.cardGameVM, selectedGame: self.selectedGame!).environmentObject(self.authManager).padding(.bottom,13)
                        //                        GamesAlertView(showAlert: self.$showAlert, parentCardGameVM: self.cardGameVM, selectedGame: self.selectedGame!).environmentObject(self.authManager)
                    } else if alertType == .create {
                        
                        CreateGameAlertView(makeGameVM: MakeGameBundleViewModel(apiService: self.authManager.apiService, parentCardGameVM: self.cardGameVM), showAlert: self.$showAlert).environmentObject(self.authManager).padding(.bottom,13)
                    }
                }
            }
            
            
        }.navigationBarTitle("", displayMode: .inline).onAppear{
            self.authManager.showNotificationBubble = false
        }.onDisappear{
            self.authManager.showNotificationBubble = true
        }
        
    }
    struct CardGamePreviewCell: View {
        
     
        let cardGameBundle: CardGameBundle
        var body: some View {
           
                VStack{
                    
                    //                        ForEach(self.gameBundle.cards.indices, id: \.self) { (index) in
                    if  cardGameBundle.cards.indices.contains(0) {
                        if cardGameBundle.cards[0].imagePaths.indices.contains(0){
                            WebImage(url: URL(string: cardGameBundle.cards[0].imagePaths[0])).resizable().frame(width: 87, height: 120).cornerRadius(13).shadow(radius: 10).overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.green, lineWidth: cardGameBundle.favorite ? 2 : 0)
                            )
                        }
                    }
                    //                        }
                    
                    
                    Text(cardGameBundle.bundleTitle)
                        .font(.system(size: 14)).fontWeight(.bold).multilineTextAlignment(.center).frame(alignment: .bottom)
              
            }
            
            
            
        }
        
    }
    struct GaamesAlertView: View {
        @Environment(\.presentationMode) var presentationMode
        @EnvironmentObject var authManager : AuthManager
        @Binding var showAlert : Bool
        @State var navigate = false
        @StateObject var makeGameVM : MakeGameBundleViewModel
        
        @Binding var playGame: Bool
        @StateObject var parentCardGameVM: CardGameViewModel
        let impactMed = UIImpactFeedbackGenerator(style: .medium)
        var selectedGame : CardGameBundle
        var body: some View {
            VStack(spacing: 12) {
                Text(selectedGame.bundleTitle)
                    .font(.system(size: 14)).fontWeight(.bold).multilineTextAlignment(.center).frame(alignment: .bottom)
                WebImage(url: URL(string: selectedGame.cards[0].imagePaths[0])).resizable().frame(width: 87, height: 120).cornerRadius(13).shadow(radius: 10)
                
                NavigationLink(destination: CreateGameView(makeGameVM: MakeGameBundleViewModel(cardBundle: self.selectedGame, apiService: self.authManager.apiService, parentCardGameVM: self.parentCardGameVM), showAlert: self.$showAlert).onDisappear{
                    withAnimation {
                        self.showAlert = false
                        //                    self.presentationMode.wrappedValue.dismiss()
                    }
                    
                }) {
                    Text("Edit").fontWeight(.bold).frame(width: 85, height: 40)
                }.frame(width: 85, height: 40).cornerRadius(15).overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.orange, lineWidth: 2)
                )
                HStack(spacing: 15) {
                    
                    Button {
                        withAnimation {
                            impactMed.impactOccurred()
                            self.showAlert = false
                            //                        self.presentationMode.wrappedValue.dismiss()
                        }
                        
                    } label: {
                        Text("Cancel").fontWeight(.bold).frame(width: 100, height: 50)
                    }.frame(width: 100, height: 50).cornerRadius(10).overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.pink, lineWidth: 2)
                    )
                    Button {
                        withAnimation {
                            self.playGame.toggle()
                            //                        self.presentationMode.wrappedValue.dismiss()
                        }
                        
                    } label: {
                        Text("Play").fontWeight(.bold).frame(width: 100, height: 50)
                    }.frame(width: 100, height: 50).cornerRadius(10).overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.green, lineWidth: 2)
                    )
                    
                    
                }
                
            }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity).background(Color.gray.opacity(0.01))
            .onTapGesture {
                withAnimation {
                    impactMed.impactOccurred()
                    self.showAlert = false
                }
                
            }.padding(.top, -80)
        }
    }
    struct CreateGameAlertView : View {
        @EnvironmentObject var authManager : AuthManager
        @StateObject var makeGameVM : MakeGameBundleViewModel
        @State var navigate = false
        @Binding var showAlert : Bool
        
        var body: some View {
            VStack(alignment: .center ,spacing: 12) {
                Text("Enter a title for your custom game!").foregroundColor(Color("textColor")).fontWeight(.bold).multilineTextAlignment(.center).padding()
                Text("Limit \(self.makeGameVM.cardBundleTitle.count)/20").foregroundColor(self.makeGameVM.cardBundleTitle.count > 0 ? (self.makeGameVM.cardBundleTitle.count == 20 ? Color.orange : Color.green) : Color.red).fontWeight(.bold).multilineTextAlignment(.center)
                TextField("Enter Title...", text: self.$makeGameVM.cardBundleTitle).font(.headline).padding().disableAutocorrection(true).overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(self.makeGameVM.cardBundleTitle.count <= 0 ? Color.red : Color.green, lineWidth: 2)
                ).padding(.horizontal).padding(.bottom).onChange(of: self.makeGameVM.cardBundleTitle, perform: { value in
                    if value.count > 20 {
                        self.makeGameVM.cardBundleTitle = String(value.prefix(20))
                        impactMed.impactOccurred()
                    }
                })
                
                HStack(spacing: 15){
                    
                    
                    Button {
                        dismissKeyboard()
                        withAnimation {
                            self.showAlert = false
                            
                            impactMed.impactOccurred()
                            //                        self.presentationMode.wrappedValue.dismiss()
                        }
                        
                    } label: {
                        Text("Cancel").foregroundColor(Color("textColor")).fontWeight(.bold).frame(width: 100, height: 50)
                    }.frame(width: 100, height: 50).cornerRadius(10).overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.pink, lineWidth: 2)
                    )
                    NavigationLink(destination:  CreateGameView(makeGameVM: self.makeGameVM, showAlert: self.$showAlert), isActive: self.$navigate) {
                        Text("")
                    }
                    Button {
                        dismissKeyboard()
                        withAnimation {
                            
                            self.makeGameVM.makeCardBundle { success in
                                if success {
                                    self.navigate.toggle()
                                }
                                
                            }
                        }
                        
                    } label: {
                        Text("Continue").foregroundColor(Color("textColor")).fontWeight(.bold).frame(width: 100, height: 50)
                    }.disabled(self.makeGameVM.cardBundleTitle.count <= 0 ? true : false).frame(width: 100, height: 50).cornerRadius(10).overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(self.makeGameVM.cardBundleTitle.count <= 0 ? Color.gray : Color.green, lineWidth: 2)
                    )
                    
                    
                }
            }.animation(.easeIn).frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity).background(Color.gray.opacity(0.01))
            .onTapGesture {
                withAnimation {
                    dismissKeyboard()
                }
                
            }
        }
    }
    
    struct CreateGameView : View {
        @EnvironmentObject var authManager : AuthManager
        @Environment(\.presentationMode) var presentationMode
        @StateObject var makeGameVM : MakeGameBundleViewModel
        @Binding var showAlert : Bool
        @State var cardHeight: CGFloat = 240
        @State var offSet = CGFloat.zero
        @State var confirmAlert = false
        enum PopUpViewtype {
            case changeTitle, none
        }
        @State var popUpViewtype : PopUpViewtype = .none
        var body: some View {
            ZStack{
                VStack{
                    Button {
                        
                        self.popUpViewtype = .changeTitle
                    } label: {
                        Text(makeGameVM.cardBundle.bundleTitle).fontWeight(.bold).padding().frame(height: 75).foregroundColor(Color("textColor")).cornerRadius(10).overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.green, lineWidth: 2)
                        )
                    }
                    
                    Text("Card count: \(makeGameVM.cardBundle.cards.count)").fontWeight(.bold).padding().frame(height: 45).foregroundColor(Color("textColor")).cornerRadius(10).overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(makeGameVM.cardBundle.cards.count <= 0 ? Color.red : Color.green, lineWidth: 2)
                    ).padding(.top)
                    if !(makeGameVM.cardBundle.cards.count <= 0) {
                        HStack{
                            NavigationLink(destination: AddCardView(addCardVM: AddCardViewModel(makeGameVM: self.makeGameVM, apiService: self.authManager.apiService, card: nil, couplesLinkedID: self.authManager.couplesLinked!.docID))){
                                Image(systemName: "plus.circle").frame(width: 50, height: 50)
                            }.overlay(
                                Circle()
                                    .stroke(Color.green, lineWidth: 2)
                            ).padding()
                            ScrollView(.horizontal, showsIndicators: true){
                                LazyHStack(spacing: -30)
                                {
                                    
                                    
                                    ForEach(makeGameVM.cardBundle.cards, id: \.id) { (card) in
                                        
                                        NavigationLink(destination: AddCardView(addCardVM: AddCardViewModel(makeGameVM: self.makeGameVM, apiService: self.authManager.apiService, card: card, couplesLinkedID: self.authManager.couplesLinked!.docID))) {
                                            CardCell(height: cardHeight, card: card)
                                            
                                        }.animation(Animation.easeInOut(duration: 1.0))
                                        
                                    }
                                }.padding()
                            }.padding(.top).clipped().frame(height: cardHeight)
                        }
                    } else {
                        NavigationLink(destination: AddCardView(addCardVM: AddCardViewModel(makeGameVM: self.makeGameVM, apiService: self.authManager.apiService, card: nil, couplesLinkedID: self.authManager.couplesLinked!.docID))){
                            Image(systemName: "plus.circle").cornerRadius(10).frame(width: 100, height: 100)
                        }.cornerRadius(20).padding(.vertical).padding().overlay(
                            Circle()
                                .stroke(Color.green, lineWidth: 2)
                        )
                    }
                    VStack{
                        Text("Favorited?").foregroundColor(Color("BlackOrWhite")).font(.system(size: 15, weight: .bold, design: Font.Design.rounded))
                        Toggle("Favorited", isOn: $makeGameVM.cardBundle.favorite).labelsHidden()
                    }.padding(.bottom)
                    HStack(spacing: 10){
                        
                        Button {
                            self.confirmAlert.toggle()
                        } label: {
                            Text("Delete").fontWeight(.bold).frame(width: 100, height: 50)
                        }.frame(width: 100, height: 50).cornerRadius(10).overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.red, lineWidth: 2)
                        ).alert(isPresented: self.$confirmAlert) { () -> Alert in
                            Alert(title: Text("Delete entire bundle"), message: Text("Are you sure?"), primaryButton: .default(Text("Cancel"), action: {
                                self.confirmAlert.toggle()
                            }), secondaryButton: .default(Text("Confirm"), action: {
                                self.makeGameVM.deleteBundle { success in
                                    if success {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                            self.showAlert.toggle()
                                        }
                                    }
                                }
                            }))
                        }
                        Button {
                            makeGameVM.saveGameBundle { success in
//                                if success {
//                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                                        self.showAlert.toggle()
//                                    }
//
//                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    self.showAlert.toggle()
                                }
                            }
                        } label: {
                            Text("Save").fontWeight(.bold).frame(width: 100, height: 50)
                        }.frame(width: 100, height: 50).cornerRadius(10).overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.green, lineWidth: 2)
                        )
                        
                    }
                    
                    Spacer(minLength: 0)
                }.frame(alignment: .topLeading).padding(.top).blur(radius: popUpViewtype == .changeTitle ? 9 : 0)
                if self.makeGameVM.showIndicator {
                    AppStateView(indicatorType: Binding(self.$makeGameVM.indicatorType)!, showIndicator: self.$makeGameVM.showIndicator, autoDisable: true)
                }
                if popUpViewtype == .changeTitle {
                    CustomTextField(textBinding: self.$makeGameVM.cardBundle.bundleTitle, popUpViewtype: self.$popUpViewtype, originalTitle: makeGameVM.originalTitle)
                }
                
            }.animation(.default)
            
            
        }
        struct CardCell: View {
            func getCardHeight(index: Int, height: CGFloat)->CGFloat{
                
                let height : CGFloat = height
                
                // Again First Three Cards...
                let cardHeight = index <= 2 ? CGFloat(index) * 30 : 70
                //    let cardHeight = index - model.swipedCard <= 2 ? CGFloat(index - model.swipedCard) * 35 : 70
                return height - cardHeight
                //    return 450
            }

            func getCardWidth(index: Int)->CGFloat{
                
                let boxWidth = UIScreen.main.bounds.width - 60 - 60
                
                // For First Three Cards....
                //    let cardWidth = index <= 2 ? CGFloat(index) * 30 : 60
                
                return boxWidth
            }
            func getCardOffset(index: Int)->CGFloat{
                
                //    let boxWidth = UIScreen.main.bounds.width - 60 - 60
                
                // For First Three Cards....
                //let cardWidth = index <= 2 ? CGFloat(index) * 30 : 60
                let cardWidth = index <= 2 ? CGFloat(index) * 30 : 60
                return cardWidth
            }
            var height: CGFloat
            var card : Card
            var body: some View {
                
                VStack {
                    
                    ZStack{
                        ForEach(card.imagePaths.indices.reversed(), id: \.self) { (index)  in
                            
                            HStack{
                                WebImage(url: URL(string: card.imagePaths[index])).resizable().cornerRadius(12).frame(width: 100, height: getCardHeight(index: index, height: height - 70)).offset(x: getCardOffset(index: index)).aspectRatio(contentMode: .fit)
                            }.frame(height: height - 70)
                            
                            
                        }
                    }.padding(.trailing, height/2)
                    
                    
                    
                    
                    
                }
            }
            
        }
        struct CustomTextField : View {
            @Binding var textBinding : String
            @Binding var popUpViewtype : PopUpViewtype
            var originalTitle : String
            
            var body: some View {
                VStack(alignment: .center ,spacing: 12) {
                    Text("Change your title here").foregroundColor(Color("textColor")).fontWeight(.bold).multilineTextAlignment(.center).padding()
                    Text("Limit \(textBinding.count)/20").foregroundColor(textBinding.count > 0 ? (textBinding.count == 20 ? Color.orange : Color.green) : Color.red).fontWeight(.bold).multilineTextAlignment(.center)
                    TextField("Enter Title...", text: $textBinding).font(.headline).padding().disableAutocorrection(true).overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(textBinding.count <= 0 ? Color.red : Color.green, lineWidth: 2)
                    ).padding(.horizontal).padding(.bottom).onChange(of: textBinding, perform: { value in
                        if value.count > 20 {
                            textBinding = String(value.prefix(20))
                            impactMed.impactOccurred()
                        }
                    })
                    HStack{
                        
                        Button {
                            self.textBinding = originalTitle
                            withAnimation {
                                
                                self.popUpViewtype = .none
                                
                            }
                            
                        } label: {
                            Text("Cancel").foregroundColor(Color("textColor")).fontWeight(.bold).frame(width: 100, height: 50)
                        }.frame(width: 100, height: 50).cornerRadius(10).overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.red, lineWidth: 2)
                        )
                        
                        Button {
                            withAnimation {
                                
                                self.popUpViewtype = .none
                                
                            }
                            
                        } label: {
                            Text("Continue").foregroundColor(Color("textColor")).fontWeight(.bold).frame(width: 100, height: 50)
                        }.disabled(textBinding.count <= 0 ? true : false).frame(width: 100, height: 50).cornerRadius(10).overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(textBinding.count <= 0 ? Color.gray : Color.green, lineWidth: 2)
                        )
                    }
                }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity).background(Color.gray.opacity(0.01))
                .onTapGesture {
                    withAnimation {
                        dismissKeyboard()
                    }
                    
                }
            }
        }
        
        
        struct AddCardView : View {
            @EnvironmentObject var authManager: AuthManager
            @Environment(\.presentationMode) var presentationMode
            @StateObject var addCardVM : AddCardViewModel
            @State var images = [UIImage]()
            @State var showPhotoPicker = false
            @State var allowPhotosAlert = false
            @State var confirmDeleteAlert = false
            let columns = [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ]
            var body: some View {
                ZStack{
                    
                    VStack{
                        ScrollView(showsIndicators: false) {
                            HStack {
                                Text("Select 1-3 images")
                                Text("\(addCardVM.totalImagesSelected) / 3 selected").foregroundColor(self.addCardVM.totalImagesSelected < 1 ? Color.red : Color.green)
                                
                            }.padding(.vertical)
                            ScrollView(.horizontal, showsIndicators: false){
                                HStack{
                                    
                                    HStack{
                                        ForEach(addCardVM.cameraRollImages.indices, id: \.self) { i in
                                            Button(action: {
                                                self.addCardVM.removeImageFromCameraRoll(index: i)
                                            }, label: {
                                                
                                                Image(uiImage: self.addCardVM.cameraRollImages[i]).resizable().frame(width: 90, height: 125).cornerRadius(10)
                                                
                                            }).frame(width: 90, height: 125).cornerRadius(10).overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke( Color.green, lineWidth: 2)
                                            )
                                            
                                        }
                                    }
                                    HStack{
                                        if addCardVM.card != nil {
                                            ForEach(addCardVM.card!.imagePaths.indices, id: \.self) { i in
                                                Button(action: {
                                                    self.addCardVM.removeExistingImage(index: i)
                                                    //                                            self.confirmDeleteAlert.toggle()
                                                }, label: {
                                                    
                                                    WebImage(url: URL(string: addCardVM.card!.imagePaths[i])).resizable().frame(width: 90, height: 125).cornerRadius(10)
                                                    
                                                }).frame(width: 90, height: 125).cornerRadius(10).overlay(
                                                    RoundedRectangle(cornerRadius: 10)
                                                        .stroke( Color.green, lineWidth: 2)
                                                )
                                            }
                                            
                                        }
                                    }
                                    HStack{
                                        ForEach(addCardVM.selectedAPIImages, id: \.self) { url in
                                            Button(action: {
                                                self.addCardVM.selectImage(url: url)
                                            }, label: {
                                                
                                                WebImage(url: URL(string: url)).resizable().frame(width: 90, height: 125).cornerRadius(10)
                                                
                                            }).frame(width: 90, height: 125).cornerRadius(10).overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(self.addCardVM.selectedAPIImages.contains(url) ? Color.green : Color.red, lineWidth: 2)
                                            )
                                            
                                        }
                                    }
                                }
                                
                            }.padding(.horizontal, 20).padding(.leading, 5).padding(.bottom)
                            Line().stroke(Color.orange,style: StrokeStyle(lineWidth: 1, lineCap: .butt, lineJoin: .miter, dash: [10])) .frame(height: 1).padding(.horizontal).padding(.top,10)
                            VStack{
                                Text("Web Images (not very good =[)").opacity(self.addCardVM.apiImages.count <= 0 ? 0 : 1)
                                ScrollView{
                                    
                                    LazyVGrid(columns: columns){
                                        
                                        ForEach(addCardVM.apiImages, id: \.self) { url in
                                            Button(action: {
                                                self.addCardVM.selectImage(url: url)
                                            }, label: {
                                                WebImage(url: URL(string: url)).resizable().frame(width: 90, height: 125).cornerRadius(10)
                                                
                                            }).frame(width: 90, height: 125).cornerRadius(10).cornerRadius(10).overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(self.addCardVM.selectedAPIImages.contains(url) ? Color.green : Color.red, lineWidth: 2)
                                            )
                                        }
                                    }.padding()
                                }
                            }.clipped().frame(height:self.addCardVM.apiImages.count <= 0 ? 0 : UIScreen.main.bounds.height / 3)
                            VStack(spacing: 15){
                                VStack{
                                    
                                    Text("Card Information").frame(height: 5).foregroundColor(.white).font(.system(size: 10, weight: .bold, design: Font.Design.default)).padding().background(Color.orange).cornerRadius(8).overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.green, lineWidth: 0.7)
                                    )
                                    Line().stroke(Color.purple,style: StrokeStyle(lineWidth: 1, lineCap: .butt, lineJoin: .miter, dash: [10])) .frame(height: 1).padding(.horizontal).padding(.top,10).padding(.bottom)
                                    VStack(spacing: 2){
                                        Text("Title").font(.system(size: 15, weight: .bold, design: Font.Design.default))
                                        TextField("Enter image title", text: $addCardVM.imageTitle).foregroundColor(Color("WhiteOrBlack")).padding().cornerRadius(8).overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.green, lineWidth: 0.7)
                                        )
                                    }
                                    VStack(spacing: 2){
                                        Text("Description").font(.system(size: 15, weight: .bold, design: Font.Design.default))
                                        TextField("Enter brief image description", text: $addCardVM.imageDescription).foregroundColor(Color("WhiteOrBlack")).padding().cornerRadius(8).overlay(
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(Color.green, lineWidth: 0.7)
                                        )
                                    }
                                }.padding().background(Color.orange).cornerRadius(15)
                                HStack(spacing: 15){
                                    Button {
                                        addCardVM.getImagesFromAPI()
                                        dismissKeyboard()
                                    } label: {
                                        Text("Search Web").fontWeight(.bold).frame(width: 100, height: 50)
                                    }.frame(width: 135, height: 50).cornerRadius(10).overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.green, lineWidth: 2)
                                    )
                                    Button {
                                        PHPhotoLibrary.requestAuthorization { (status) in
                                            if status == PHAuthorizationStatus.authorized {
                                                self.addCardVM.imageFromCameraRoll()
                                            } else {
                                                self.allowPhotosAlert.toggle()
                                            }
                                        }
                                        
                                    } label: {
                                        Text("Camera Roll").fontWeight(.bold).frame(width: 100, height: 50)
                                    }.alert(isPresented: self.$allowPhotosAlert, content: {
                                        Alert(title: Text("Error"), message: Text("Please Enable Photo access or this feature will not work as properly."), primaryButton: .default(Text("Cancel")) , secondaryButton: .default(Text("Go"), action: {
                                            if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                                                
                                                UIApplication.shared.open(settingsUrl)
                                                
                                            }
                                        }))
                                    }).sheet(isPresented: self.$addCardVM.showPhotoPicker, content: {
                                        PhotoPicker(addCardVM: self.addCardVM)
                                    }).frame(width: 135, height: 50).cornerRadius(10).overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.green, lineWidth: 2)
                                    )
                                }
                                Button {
                                    dismissKeyboard()
                                    addCardVM.saveCard() { success in
                                        if success{
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                                self.presentationMode.wrappedValue.dismiss()
                                            }
                                        }
                                    }
                                } label: {
                                    Text("Done").fontWeight(.bold).frame(width: 100, height: 50)
                                }.frame(width: 100, height: 50).cornerRadius(10).overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.green, lineWidth: 2)
                                )
                            }
                            
                        }
                    }.clipped().padding()
                    if self.addCardVM.showIndicator {
                        AppStateView(indicatorType: Binding(self.$addCardVM.indicatorType)!, showIndicator: self.$addCardVM.showIndicator, autoDisable: true)
                    }
                }.animation(.default).frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity).background(Color.gray.opacity(0.01)).onTapGesture {
                    dismissKeyboard()
                }
            }
            //                import PhotosUI
            struct PhotoPicker: UIViewControllerRepresentable {
                @StateObject var addCardVM: AddCardViewModel
                
                
                func makeCoordinator() -> Coordinator {
                    return Coordinator(parent: self)
                }
                
                func makeUIViewController(context: Context) -> PHPickerViewController {
                    var config = PHPickerConfiguration()
                    config.filter = .images
                    config.selectionLimit = (3 - self.addCardVM.totalImagesSelected)
                    let picker = PHPickerViewController(configuration: config)
                    picker.delegate = context.coordinator
                    return picker
                }
                
                func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
                    
                }
                class Coordinator: NSObject, PHPickerViewControllerDelegate {
                    var temp = [UIImage]()
                    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
                        self.parent.addCardVM.indicatorType = .loading(message: "Adding images...")
                        let myGroup = DispatchGroup()
                        for img in results {
                            myGroup.enter()
                            if img.itemProvider.canLoadObject(ofClass: UIImage.self) {
                                img.itemProvider.loadObject(ofClass: UIImage.self) { (reading, err) in
                                    guard let img = reading else {
                                        print("error loading image")
                                        myGroup.leave()
                                        return
                                    }
                                    if let img = img as? UIImage {
                                        self.temp.append(img)
                                    }
                                    
                                    myGroup.leave()
                                    
                                    
                                }
                            } else {
                                myGroup.leave()
                                print("error")
                            }
                        }
                        parent.addCardVM.showPhotoPicker.toggle()
                        myGroup.notify(queue: .main) {
                            if !self.temp.isEmpty{
                                self.temp.reversed().forEach { (img) in
                                    self.parent.addCardVM.cameraRollImages.insert(img, at: 0)
                                }
                                self.temp.removeAll()
                                self.parent.addCardVM.showIndicator = false
                            } else {
                                self.parent.addCardVM.indicatorType = .error(message: "Some or all images failed to add. Please try again.")
                            }
                            
                        }
                    }
                    
                    var parent : PhotoPicker
                    init(parent: PhotoPicker) {
                        self.parent = parent
                    }
                }
                
                typealias UIViewControllerType = PHPickerViewController
                
                
            }
        }
    }

}



//struct GamesAlertView: View {
//    @Environment(\.presentationMode) var presentationMode
//    @EnvironmentObject var authManager : AuthManager
//    @Binding var showAlert : Bool
//    @State var navigate = false
//    @StateObject var parentCardGameVM: CardGameViewModel
//    let impactMed = UIImpactFeedbackGenerator(style: .medium)
//    var selectedGame : CardGameBundle
//    var body: some View {
//        VStack(spacing: 12) {
//            Text(selectedGame.bundleTitle)
//                .font(.system(size: 14)).fontWeight(.bold).multilineTextAlignment(.center).frame(alignment: .bottom)
//            WebImage(url: URL(string: selectedGame.cards[0].imagePaths[0])).resizable().frame(width: 87, height: 120).cornerRadius(13).shadow(radius: 10)
//
//            NavigationLink(destination: CreateGameView(makeGameVM: MakeGameBundleViewModel(cardBundle: self.selectedGame, apiService: self.authManager.apiService, parentCardGameVM: self.parentCardGameVM), showAlert: self.$showAlert).onDisappear{
//                withAnimation {
//                    self.showAlert = false
//                    //                    self.presentationMode.wrappedValue.dismiss()
//                }
//
//            }) {
//                Text("Edit").fontWeight(.bold).frame(width: 85, height: 40)
//            }.frame(width: 85, height: 40).cornerRadius(15).overlay(
//                RoundedRectangle(cornerRadius: 15)
//                    .stroke(Color.orange, lineWidth: 2)
//            )
//            HStack(spacing: 15) {
//
//                Button {
//                    withAnimation {
//                        impactMed.impactOccurred()
//                        self.showAlert = false
//                        //                        self.presentationMode.wrappedValue.dismiss()
//                    }
//
//                } label: {
//                    Text("Cancel").fontWeight(.bold).frame(width: 100, height: 50)
//                }.frame(width: 100, height: 50).cornerRadius(10).overlay(
//                    RoundedRectangle(cornerRadius: 10)
//                        .stroke(Color.pink, lineWidth: 2)
//                )
//                NavigationLink(destination: EmptyView().onDisappear{
//                    withAnimation {
//
//                        self.showAlert = false
//                    }
//
//                }) {
//                    Text("Play").fontWeight(.bold).frame(width: 100, height: 50)
//                }.frame(width: 100, height: 50).cornerRadius(15).overlay(
//                    RoundedRectangle(cornerRadius: 15)
//                        .stroke(Color.green, lineWidth: 2)
//                )
//
//            }
//
//        }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity).background(Color.gray.opacity(0.01))
//        .onTapGesture {
//            withAnimation {
//                impactMed.impactOccurred()
//                self.showAlert = false
//            }
//
//        }.padding(.top, -80)
//    }
//}

//SWIPE VIEW
//swipe 1
struct SwipeView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var dismiss : Bool
    
    @State var currentCardIndex = 0
    @State var showKola = true
    @StateObject var playCardGameVM : PlayCardGameViewModel
    @State var showSuperChoice = false
    
    enum Result {
        case showResults, sendGame, none
    }
    @State var resultType: Result = .none
    enum SuperType {
        case superLike, superDislike, none
    }
    @State var typeOfChoice : SuperType = .none
    var body: some View {
        ZStack{
            VStack {
                /// Top  Stack
                HStack {
                    
                    Button(action: {}) {
                        Image("l1")
                            .resizable().aspectRatio(contentMode: .fit).frame(height:45)
                    }
                    
                    
                }.padding([.horizontal, .bottom])
                
                ZStack{
                    //                RoundedRectangle(cornerRadius: 15)
                    LottieView(loopMode: .loop, filename: "sleepingKola").padding(.bottom, 300).opacity(((self.currentCardIndex <= playCardGameVM.cards.count - 1) && showKola) ? 1 : 0).animation(.none)
                   
                    ForEach(playCardGameVM.cards.indices, id: \.self) { index in
                        
                        SwipeViewCell(showKola: $showKola, currentCardIndex: $currentCardIndex, playGameVM: self.playCardGameVM, card: CardWithAxis(card: playCardGameVM.cards[index]), showSuperChoice: $showSuperChoice, typeOfChoice: $typeOfChoice).opacity(self.currentCardIndex == index ? 1 : 0)
                        
                        
                    }
                    
                    
                }
                
                
                // MARK: - BUG 1
                
                /// Top  Stack
                // Do not add spacing
                
            }.blur(radius: showSuperChoice ? 15 : 0)
            Button {
                
                playCardGameVM.createGame { (success) in
                    
                    if success {
                        self.resultType = .sendGame
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            self.dismiss.toggle()
                            self.presentationMode.wrappedValue.dismiss()
                        }
                    } 
                }
                
            } label: {
                Text(self.playCardGameVM.isNewGame ? "Send Game" : "Show Results!")
            }.disabled(self.playCardGameVM.showIndicator || resultType != .none).opacity((self.currentCardIndex > playCardGameVM.cards.count - 1) && resultType == .none ? 1 : 0)
            if resultType == .sendGame {
                LottieView(loopMode: .loop, filename: "sendSuccess", speed: 1.4).frame(width: 150, height: 150).padding(.all).animation(.default)
            } else if resultType == .showResults {
                
            }
            if showSuperChoice {
                CustomTextField(showSuperChoice: $showSuperChoice, textBinding: $playCardGameVM.reasonForChoice, typeOfChoice: $typeOfChoice, currentCardIndex: $currentCardIndex, playGameVM: self.playCardGameVM)
            }
            if self.playCardGameVM.showIndicator {
                AppStateView(indicatorType: Binding(self.$playCardGameVM.indicatorType)!, showIndicator: self.$playCardGameVM.showIndicator, autoDisable: true)
            }
        }.navigationBarTitle(self.playCardGameVM.activeGameProgress.gameBundle.bundleTitle, displayMode: .inline)
    }
    struct CustomTextField : View {
        @Binding var showSuperChoice : Bool
        @Binding var textBinding : String
        @Binding var typeOfChoice : SuperType
        @Binding var currentCardIndex : Int
        @StateObject var playGameVM : PlayCardGameViewModel
        @State var showDone = false
        var body: some View {
            VStack(alignment: .center ,spacing: 12) {
                
                if !showDone {
                    Text(typeOfChoice == .superLike ? "Attempt to articulate to your parter why you loved this below. Include the little things you noticed!" : typeOfChoice == .superDislike ? "Attempt to articulate to your parter why you disliked this below. How can they improve? Can you compromise?" : "Error.").foregroundColor(Color.orange).fontWeight(.bold).multilineTextAlignment(.center).padding().multilineTextAlignment(.center)
                    
                    TextEditor(text: $textBinding).font(.system(size: 17, weight: .bold, design: Font.Design.rounded)).frame(height:UIScreen.main.bounds.height / 3.5)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.yellow, lineWidth: 2)
                        )
                        .padding(.horizontal, 50)
                    
                    HStack{
                        
                        Button {
                            
                            withAnimation {
                                self.typeOfChoice = .none
                                playGameVM.reasonForChoice = ""
                                self.showSuperChoice.toggle()
                                
                            }
                            
                        } label: {
                            Text("Cancel").foregroundColor(Color("textColor")).fontWeight(.bold).frame(width: 100, height: 50)
                        }.frame(width: 100, height: 50).cornerRadius(10).overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.red, lineWidth: 2)
                        )
                        
                        Button {
                            
                            if self.typeOfChoice == .superLike {
                                playGameVM.appendCard(appendType: .superLike(reason: textBinding), cardIndex: currentCardIndex)
                                withAnimation {
                                    self.showDone.toggle()
                                    self.playGameVM.reasonForChoice = ""
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.20) {
                                        self.currentCardIndex += 1
                                        self.showSuperChoice.toggle()
                                    }
                                    
                                    
                                    
                                }
                            } else if self.typeOfChoice == .superDislike {
                                playGameVM.appendCard(appendType: .superDislike(reason: textBinding), cardIndex: currentCardIndex)
                                withAnimation {
                                    self.showDone.toggle()
                                    self.playGameVM.reasonForChoice = ""
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.20) {
                                        self.currentCardIndex += 1
                                        self.showSuperChoice.toggle()
                                    }
                                    
                                    
                                    
                                }
                            } else {
                                print("none")
                                return
                            }
                            
                            
                        } label: {
                            Text(typeOfChoice == .superLike ? "Super 💖" : typeOfChoice == .superDislike ? "Super 👎" : "Error.").foregroundColor(Color("textColor")).fontWeight(.bold).frame(width: 100, height: 50).multilineTextAlignment(.center)
                        }.disabled(textBinding.count <= 0 ? true : false).frame(width: 100, height: 50).cornerRadius(10).overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(textBinding.count <= 0 ? Color.gray : Color.green, lineWidth: 2)
                        )
                    }
                } else {
                    LottieView(loopMode: .playOnce, filename: "done", speed: 0.8)
                }
            }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity).background(Color.gray.opacity(0.01))
            .onTapGesture {
                withAnimation {
                    dismissKeyboard()
                }
                
            }
        }
    }
    struct SwipeViewCell: View {
        @Binding var showKola: Bool
        @Binding var currentCardIndex : Int
        @StateObject var playGameVM: PlayCardGameViewModel
        @State var card: CardWithAxis
        @Binding var showSuperChoice : Bool
        @Binding var typeOfChoice : SuperType
        //    @StateObject var playCardGameVM
        // MARK: - Drawing Constant
        let cardGradient = Gradient(colors: [Color.black.opacity(0.0), Color.black.opacity(0.5)])
        @State var imageIndex = 0
        @State var disabled = false
        @State var attempts = 0
        //    @State var likeText = "Yep!"
        //    @State var dislikeText = "Nope!"
        var body: some View {
            VStack{
                ZStack {
                    // Image - Explain
                    Color.gray.cornerRadius(10).padding(.horizontal,20)
                    ForEach(card.card.imagePaths.indices, id: \.self) { index in
                        WebImage(url: URL(string: card.card.imagePaths[index])).resizable().placeholder(Image(systemName: "photo")).indicator(.activity).transition(.fade).scaledToFit().cornerRadius(10).padding(.horizontal,27).opacity(self.imageIndex == index ? 1 : 0)
                            .frame(width: 400, height: UIScreen.main.bounds.height / 1.5)
                    }
                    
                    // Linear Gradient
                    LinearGradient(gradient: cardGradient, startPoint: .top, endPoint: .bottom).cornerRadius(10).padding(.horizontal,20)
                    VStack {
                        Spacer()
                        VStack{
                            
                            
                            Text(card.card.title).font(.largeTitle).fontWeight(.bold).frame(maxWidth: .infinity, alignment: .leading)
                            Text(card.card.description).font(.body).frame(maxWidth: .infinity, alignment: .leading)
                            
                            
                        }.padding()
                        
                    }
                    .padding()
                    .foregroundColor(.white)
                    VStack(alignment: .center) {
                        HStack {
                            Spacer()
                            ForEach(card.card.imagePaths.indices, id: \.self) { (index) in
                                Image(systemName: self.imageIndex == index ? "circle.fill" : "circle").foregroundColor(Color("BlackOrWhite"))
                            }
                            Spacer()
                        }.frame(width: 95, height: 28).background(Color("WhiteOrBlack")).cornerRadius(10).padding(.top, 4).opacity(0.75)
                        
                        Spacer()
                    }
                    
                    
                    // MARK: - LATER
                    VStack{
                        HStack {
                            Text("Yep!").rotationEffect(Angle.init(degrees: 20)).font(.system(size: 50, weight: .bold, design: Font.Design.rounded)).foregroundColor(Color.green).padding()
                                .frame(width:150)
                                // MARK: - BUG 2
                                .opacity(Double(card.x/13 - 1))
                            Spacer()
                            Text("Nope!").rotationEffect(Angle.init(degrees: -20)).font(.system(size: 50, weight: .bold, design: Font.Design.rounded)).foregroundColor(Color.red).padding().frame(width:175)
                                // MARK: - BUG 3
                                .opacity(Double(card.x/13 * -1 - 1))
                        }
                        Spacer(minLength: 0)
                    }
                    HStack{
                        Button {
                            
                            if card.card.imagePaths.indices.contains(imageIndex - 1) {
                                imageIndex -= 1
                            } else {
                                withAnimation{
                                    self.attempts += 1
                                }
                                impactMed.impactOccurred(intensity: .greatestFiniteMagnitude)
                            }
                        } label: {
                            Text("").frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        }.disabled(disabled).frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        Button {
                            if card.card.imagePaths.indices.contains(imageIndex + 1) {
                                imageIndex += 1
                            } else {
                                withAnimation{
                                    self.attempts += 1
                                }
                                impactMed.impactOccurred(intensity: .greatestFiniteMagnitude)
                            }
                            
                        } label: {
                            Text("").frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                        }.disabled(disabled).frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                    }
                    
                }.frame(width: 400, height: UIScreen.main.bounds.height / 1.5).modifier(Shake(animatableData: CGFloat(attempts)))
                HStack(spacing:20) {
                    Button(action: {
                        print("super yes")
                        withAnimation{
                            self.typeOfChoice = .superLike
                            self.showSuperChoice.toggle()
                        }
                        
                    }) {
                        Text("Super 💖").font(.system(size: 13, weight: .bold, design: Font.Design.rounded)).frame(width: 95, height: 35).overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.pink, lineWidth: 2)
                        )
                    }.disabled(self.card.degree == 0 ? false : true)    .buttonStyle(PlainButtonStyle())
                    Button(action: {
                        withAnimation{
                            self.typeOfChoice = .superDislike
                            self.showSuperChoice.toggle()
                        }
                    }) {
                        Text("Super 👎").font(.system(size: 13, weight: .bold, design: Font.Design.rounded)).frame(width: 100, height: 35).frame(width: 95, height: 35).overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.red, lineWidth: 2)
                        )
                    }.disabled(self.card.degree == 0 ? false : true).buttonStyle(PlainButtonStyle())
                    
                }.opacity(self.card.degree == 0 ? 1 : 0).animation(.none)
                Spacer()
            }
            
            // MARK: - BUG 4
            // LEAVE OUT
            .offset(x: card.x, y: card.y)
            .rotationEffect(.init(degrees: card.degree))
            .simultaneousGesture (
                DragGesture()
                    .onChanged { value in
                        
                        self.disabled = true
                        withAnimation(.default) {
                            //                        print("x:", value.translation.width)
                            //                        print("y:", value.translation.height)
                            card.x = value.translation.width
                            // MARK: - BUG 5
                            card.y = value.translation.height
                            card.degree = 7 * (value.translation.width > 0 ? 1 : -1)
                        }
                    }
                    .onEnded { (value) in
                        self.disabled = false
                        withAnimation(.interpolatingSpring(mass: 1.0, stiffness: 50, damping: 8, initialVelocity: 0)) {
                            switch value.translation.width {
                            case 0...130:
                                print("a")
                                card.x = 0; card.degree = 0; card.y = 0
                            case let x where x > 130:
                                // yep
                                print("yep")
                                playGameVM.appendCard(appendType: .like, cardIndex: currentCardIndex)
                                print(playGameVM.activeGameProgress.partner1Choices.likedCards.count)
                                print(playGameVM.activeGameProgress.partner1Choices.dislikedCards.count)
                                currentCardIndex+=1
                                card.x = 500; card.degree = 12
                            case (-130)...(-1):
                                print("c")
                                card.x = 0; card.degree = 0; card.y = 0
                            case let x where x < 130:
                                //nope
                                print("nope")
                                playGameVM.appendCard(appendType: .dislike, cardIndex: currentCardIndex)
                                currentCardIndex+=1
                                card.x  = -500; card.degree = -12
                            default:
                                print("e")
                                card.x = 0; card.y = 0
                            }
                        }
                    }
            )
        }
        
        
    }
}



//swipe 2

