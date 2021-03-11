//
//  MainView.swift
//  CouplesDelight
//
//  Created by Darren Zou on 11/23/20.
//

import Foundation
import SwiftUI
struct MainTabView: View {
    @Namespace var animation
    @StateObject var detailObject = DetailViewModel()
    @EnvironmentObject var authManager : AuthManager
    @State private var badgeNumber: Int = 10
      private var badgePosition: CGFloat = 1
      private var tabsCount: CGFloat = 5
    var body: some View {
        
    
        GeometryReader { geometry in
              ZStack(alignment: .bottomLeading) {
        NavigationView{
            TabView{
                
                DashBoard().environmentObject(self.authManager)
                    .tabItem{
                        
                        Image(systemName: "bag")
                            .renderingMode(.template)
                        
                        Text("Home")
                    }
                LazyView(GamesView().environmentObject(self.authManager))
                    .tabItem{
                        
                        Image(systemName: "bag")
                            .renderingMode(.template)
                        
                        Text("Games")
                    }.onAppear{
                        self.authManager.clearNotifications(typeToClear: .cardGame)
                    }
                
//                LazyView(Today(animation: animation, detail: detailObject))
                    Text("oo")
                    .tabItem{
                        
                        Image(systemName: "bag")
                            .renderingMode(.template)
                        
                        Text("Deals")
                    }.onAppear{
                        print("aaa")
                    }
                
                MapVieww().environmentObject(self.authManager)
                    .tabItem{
                        
                        Image(systemName: "bag")
                            .renderingMode(.template)
                        
                        Text("Stalk")
                    }.onAppear{
                        
                    }
                
                Button(action: {
                    self.authManager.signOut()
                }, label: {
                    Text("Log Out")
                }).tabItem{
                        
                        Image(systemName: "bag")
                            .renderingMode(.template)
                        
                        Text("Settings")
                    }
            }
        }
               
//                NotificationBubble(position: 2, badgeNumber: authManager.couplesLinked!.partner2.notifications.newCardGameDocs.count, tabsCount: self.tabsCount, geoWidth: geometry.size.width)
//                NotificationBubble(position: 1, badgeNumber: 2, tabsCount: self.tabsCount, geoWidth: geometry.size.width)
//                NotificationBubble(position: 3, badgeNumber: 3, tabsCount: self.tabsCount, geoWidth: geometry.size.width)
//                NotificationBubble(position: 4, badgeNumber: 4, tabsCount: self.tabsCount, geoWidth: geometry.size.width)
//          
            
              }


        }
//
           
      
    }
    struct NotificationBubble : View {
        @EnvironmentObject var authManager : AuthManager
        var position : CGFloat
        var badgeNumber: Int
        var tabsCount : CGFloat
        var geoWidth : CGFloat
        var body: some View {
            ZStack {
                      Circle()
                        .foregroundColor(.red)

                      Text("\(self.badgeNumber)")
                        .foregroundColor(.white)
                        .font(Font.system(size: 12))
            }.ignoresSafeArea(.keyboard)
            .frame(width: 20, height: 20)
            .offset(x: ( ( 2.0 * CGFloat(position) ) - 1 ) * ( geoWidth / ( 2 * CGFloat(tabsCount) ) ), y: -30)
            .opacity(authManager.showNotificationBubble ? self.badgeNumber == 0 ? 0 : 1 : 0)
        }
    }
    
}


extension View {
    
    /// Hide or show the view based on a boolean value.
    ///
    /// Example for visibility:
    /// ```
    /// Text("Label")
    ///     .isHidden(true)
    /// ```
    ///
    /// Example for complete removal:
    /// ```
    /// Text("Label")
    ///     .isHidden(true, remove: true)
    /// ```
    ///
    /// - Parameters:
    ///   - hidden: Set to `false` to show the view. Set to `true` to hide the view.
    ///   - remove: Boolean value indicating whether or not to remove the view.
    @ViewBuilder func isHidden(_ hidden: Bool, remove: Bool = false) -> some View {
        if hidden {
            if !remove {
                self.hidden()
            }
        } else {
            self
        }
    }
}
