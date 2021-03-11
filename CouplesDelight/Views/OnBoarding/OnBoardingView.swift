//
//  OnBoardingView.swift
//  CouplesDelight
//
//  Created by Darren Zou on 10/27/20.
//

import Foundation
import SwiftUI


struct OnBoardingFirst : View {
    var title : String = ""
    var animationFile : String = ""
    var description : String = ""
    @Binding var tabIndex : Int
    var body: some View {
        VStack{
            VStack{
                Text(title).font(.title).fontWeight(.bold).foregroundColor(.primary)
                LottieView(loopMode: .loop, filename: animationFile, speed: 1).frame(width: 300, height: 250).cornerRadius(10).shadow(radius: 20).edgesIgnoringSafeArea(.all)
                Text(description).multilineTextAlignment(.center).font(.body).foregroundColor(.black)
            }.padding()
            Button(action: {
                tabIndex += 1
            }) {
                    Text("Next")
                    .font(.headline)
                        .frame(width: 230, height: 40)
                    .foregroundColor(.white)
                        .background(Color("green"))
                    .cornerRadius(20)
            }

        }
    }
}
struct OnBoardingSecond: View {
    
    @EnvironmentObject var authManager : AuthManager
    @Binding var tabIndex : Int
    @State var hideSkip = true
    @State var showAlert = false
    @State var manualEnable = false
    var body: some View {
        VStack{
            VStack{
                Text("Allow Alerts?").font(.title).fontWeight(.bold).foregroundColor(.primary)
                LottieView(loopMode: .loop, filename: "ghost", speed: 1.5).frame(width: 320, height: 250).cornerRadius(10).shadow(radius: 20).edgesIgnoringSafeArea(.all)
                Text("Research shows that accidently leaving people hanging hurt as much as being ghosted 😔").multilineTextAlignment(.center).font(.body).foregroundColor(.black)
            }.padding()
           
            ZStack {
                VStack(spacing: 10){
                    ZStack{
                Button(action: {
                    let center = UNUserNotificationCenter.current()
                    center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                        
                        if let _ = error {
                            manualEnable = true
                        }
                    }
                 
                    self.hideSkip = false
                }) {
                        Text("🥺Allow Notifications🥺")
                        .font(.headline)
                            .frame(width: !self.hideSkip ? 0 : 230, height: !self.hideSkip ? 0 : 40)
                        .foregroundColor(.white)
                            .background(Color("green"))
                        .cornerRadius(20)
                }.animation(.easeOut).frame(width: !self.hideSkip ? 0 : 200, height: !self.hideSkip ? 0 : 40)
                    Button(action: {
                        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                            return
                        }

                        if UIApplication.shared.canOpenURL(settingsUrl) {
                            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                               
                            })
                        }
                    }) {
                            Text("🥺Manually Enable🥺")
                            .font(.headline)
                                .frame(width: !manualEnable ? 0 : 230, height: !manualEnable ? 0 : 40)
                            .foregroundColor(.white)
                                .background(Color("green"))
                            .cornerRadius(20)
                    }.frame(width: !manualEnable ? 0 : 200, height: !self.hideSkip ? 0 : 40)
                    }
                    Button(action: {
                        self.authManager.onBoardingFinish()
                    }) {
                            Text("Skip Intro!")
                            .font(.headline)
                                .frame(width: self.hideSkip ? 0 : 200, height: self.hideSkip ? 0 : 40)
                            .foregroundColor(.white)
                                .background(Color.gray)
                            .cornerRadius(20)
                    }.animation(.easeIn).frame(width: self.hideSkip ? 0 : 200, height: self.hideSkip ? 0 : 40).padding(.top)
                }
        }
        }
      
    }
}

