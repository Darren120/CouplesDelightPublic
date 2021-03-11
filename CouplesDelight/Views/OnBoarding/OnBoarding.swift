//
//  ContentView.swift
//  CouplesDelight
//
//  Created by Darren Zou on 10/24/20.
//

import SwiftUI
import Alamofire
struct OnBoarding: View {
    @EnvironmentObject var authManager : AuthManager
    @State var s = false
    @State var onBoardingTab = 1
    var body: some View {
        NavigationView{
        ZStack{
        CustomGradientBackground()
    
        TabView(selection: self.$onBoardingTab){
            OnBoardingFirst(title: "Welcome", animationFile: "couple", description: "'One bad experience invalidates 100 good things that goes unoticed.' But Couples Delight is here to help reinforce positive communication between you and your significant other!", tabIndex: self.$onBoardingTab).tag(1)
            OnBoardingSecond(tabIndex: self.$onBoardingTab).tag(2)
            }.tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        .listItemTint(Color.orange)
        }.navigationBarHidden(true)
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        OnBoarding()
    }
}
