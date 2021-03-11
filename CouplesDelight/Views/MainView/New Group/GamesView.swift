//
//  GamesView.swift
//  CouplesDelight
//
//  Created by Darren Zou on 12/1/20.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI
import PhotosUI
extension Color {
    static let appBlue = Color.init(red: 94/255, green: 112/255, blue: 216/255)
    static let appPurple = Color.init(red: 202/255, green: 87/255, blue: 227/255)
    static let appWhite = Color.init(red: 246/255, green: 247/255, blue: 248/255)
    static let appSkyBlue = Color.init(red: 81/255, green: 220/255, blue: 242/255)
    
    static let appGrediant = LinearGradient(
        gradient: Gradient(colors: [appPurple, appBlue, appPurple]),
        startPoint: .top,
        endPoint: .bottom)
    
    static let appGrediantTopLeadingToBottomTrailling = LinearGradient(
        gradient: Gradient(colors: [appBlue, appPurple]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing)
    
    static let appGrediantWhite = LinearGradient(
        gradient: Gradient(colors: [Color.white, Color.white]),
        startPoint: .top,
        endPoint: .bottom)
}
struct GamesView: View {
    @EnvironmentObject var authManager : AuthManager
    @State var selected = 1
    var body: some View {
        
        //        WebImage(url:URL(string:"http://cdn01.cdn.justjared.com/wp-content/uploads/2013/05/swift-bmaperf/taylor-swift-billboard-music-awards-2013-performance-video-04.jpg")).resizable().frame(width: 100, height: 100).aspectRatio(contentMode: ContentMode.fit)
        
        
        
        VStack(spacing: 4){
            
            
            (Topbar(selected: self.$selected))
            TabView(selection: self.$selected) {
                
                ((MainGameView(mainGameVM: MainGameViewModel(apiService: self.authManager.apiService, couplesLinked: self.authManager.couplesLinked!, isPartner1: self.authManager.isPartner1)).tag(1)).environmentObject(self.authManager))
                (ExploreGameView().tag(2).environmentObject(self.authManager))
                
            }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            
        }.animation(.default).navigationBarHidden(true).frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity).onAppear{

        }
        
        
    }
    
    
}

struct Topbar : View {
    let impactMed = UIImpactFeedbackGenerator(style: .medium)
    @Binding var selected : Int
    var body : some View{
        
        HStack{
            
            Button(action: {
                if selected == 1 {
                    impactMed.impactOccurred()
                    return
                }
                self.selected = 1
                
                
                
            }) {
                
                Image("b1")
                    .resizable()
                    .frame(width: 17, height: 20)
                    .padding(.vertical,12)
                    .padding(.horizontal,30)
                    .cornerRadius(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke((self.selected == 1 ? Color.pink : Color.clear), lineWidth: 2)
                    )
                
            }
            .foregroundColor(self.selected == 1 ? .green : .gray)
            
            Button(action: {
                if selected == 2 {
                    impactMed.impactOccurred()
                    return
                }
                self.selected = 2
                
            }) {
                
                Image("b1")
                    .resizable()
                    .frame(width: 17, height: 20)
                    .padding(.vertical,12)
                    .padding(.horizontal,30)
                    .cornerRadius(15)
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke((self.selected == 2 ? Color.pink : Color.clear), lineWidth: 2)
                    )
            }
            .foregroundColor(self.selected == 2 ? .green : .gray)
            
        }.padding(8)
        .animation(.default)
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(Color.purple, lineWidth: 2)
        )
        
        
        
    }
}

struct GameOptions {
    var id = UUID()
    var title : String
    var image : String
    var gameType: String = ""
}
struct MainGameView : View {
    @EnvironmentObject var authManager : AuthManager
    @StateObject var mainGameVM : MainGameViewModel
    var options = [
        GameOptions(title: "Card Game Menu", image: "colorful1"),
        GameOptions(title: "Create Game", image: "colorful1"),
        GameOptions(title: "Create Game", image: "colorful1"),
        GameOptions(title: "Game History", image: "colorful1")
    ]
    @State var animation = false
    var timer = Timer.publish(every: 0.75, tolerance: 0.5, on: .main, in: .common).autoconnect()
    var body : some View{
        
        ScrollView(showsIndicators: false) {
            VStack(spacing: 15){
                
                NavigationLink(destination: LazyView(PendingCardGameView(mainGameVM: MainGameViewModel(apiService: self.authManager.apiService, couplesLinked: self.authManager.couplesLinked!, isPartner1: self.authManager.isPartner1)).environmentObject(self.authManager))) {
                    ZStack{
                        Image("colorful1").resizable().aspectRatio(contentMode: .fill)
                        Text("Pending Games").font(.system(size: 20)).fontWeight(.bold).frame(alignment: .bottom).foregroundColor(.white)
                    }.frame(width: 325, height: 125, alignment: .center).background(Color.pink).cornerRadius(25).overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(self.animation ? Color.green : Color.red, lineWidth: 2)
                    )
                }.buttonStyle(PlainButtonStyle())
                .onReceive(timer) { (time) in
                    if mainGameVM.incompleteCardGames.count != 0 {
                        withAnimation {
                            self.animation.toggle()
                        }
                    }
                }
                NavigationLink(destination: LazyView(CardGame(cardGameVM: CardGameViewModel(apiService: self.authManager.apiService, couplesLinked: self.authManager.couplesLinked!, myUID: self.authManager.uid, isPartner1: self.authManager.isPartner1)).environmentObject(self.authManager))) {
                    ZStack{
                        Image("colorful1").resizable().aspectRatio(contentMode: .fill)
                        Text("Card Game Menu").font(.system(size: 20)).fontWeight(.bold).frame(alignment: .bottom).foregroundColor(.white)
                    }.frame(width: 325, height: 125, alignment: .center).background(Color.pink).cornerRadius(25).overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.green, lineWidth: 2)
                    )
                }.buttonStyle(PlainButtonStyle())
                NavigationLink(destination: LazyView(CardGame(cardGameVM: CardGameViewModel(apiService: self.authManager.apiService, couplesLinked: self.authManager.couplesLinked!, myUID: self.authManager.uid, isPartner1: self.authManager.isPartner1)).environmentObject(self.authManager))) {
                    ZStack{
                        Image("colorful1").resizable().aspectRatio(contentMode: .fill)
                        Text("Chores Game Menu").font(.system(size: 20)).fontWeight(.bold).frame(alignment: .bottom).foregroundColor(.white)
                    }.frame(width: 325, height: 125, alignment: .center).background(Color.pink).cornerRadius(25).overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.green, lineWidth: 2)
                    )
                }.buttonStyle(PlainButtonStyle())
               
                
                
                Spacer(minLength: 0)
                
            }.padding()
        }
    }
  
}

struct ExploreGameView : View {
    @EnvironmentObject var authManager : AuthManager
    @Environment(\.colorScheme) var colorScheme
    @State var options = [
        GameOptions(title: "Browse Community Games", image: "colorful1"),
        GameOptions(title: "Create Game", image: "colorful1"),
        GameOptions(title: "Game History", image: "colorful1")
    ]
    var body : some View{
        ScrollView(showsIndicators: false) {
            VStack(spacing: 15){
                Text("Community Games").foregroundColor(self.colorScheme == .dark ? Color.white : Color.black)
                    .font(.system(size: 22, weight: .semibold))
                ForEach(options, id: \.id) { (option) in
                    NavigationLink(destination: LazyView(EmptyView())) {
                        ZStack{
                            Image(option.image).resizable().aspectRatio(contentMode: .fill)
                            Text(option.title).font(.system(size: 20)).fontWeight(.bold).frame(alignment: .bottom).foregroundColor(.white)
                        }.frame(width: 325, height: 125, alignment: .center).background(Color.pink).cornerRadius(25).overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.green, lineWidth: 2)
                        )
                    }.buttonStyle(PlainButtonStyle())
                }
                Spacer(minLength: 0)
            }.padding().clipped()
        }
    }
}

