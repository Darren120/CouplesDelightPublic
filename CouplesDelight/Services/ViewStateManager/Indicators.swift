//
//  Indicators.swift
//  RainbowFlower
//
//  Created by Darren Zou on 7/28/20.
//  Copyright © 2020 RainbowFlower inc. All rights reserved.
//

import Foundation
import SwiftUI

struct AppStateView : View {
    @Binding var indicatorType : AppState
    @Binding var showIndicator : Bool
    var autoDisable : Bool
    var body: some View {
        HStack {
            Spacer()
            VStack{
                Spacer()
                switch indicatorType {
                case .loading(let message):
                    LoadingIndicator(message: message)
                case .error(let message):
                    Indicator(bad: true, message: message).onTapGesture {
                        self.showIndicator = false
                    }.onAppear {
                        if autoDisable{
                            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                                self.showIndicator = false
                            }
                        }
                    }
                case .success(let message):
                    Indicator(bad: false, message: message).onTapGesture {
                        self.showIndicator = false
                        
                    }.onAppear {
                        if autoDisable{
                            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                                self.showIndicator = false
                            }
                        }
                    }
                }
                
                Spacer()
            }
            Spacer()
        }.contentShape(Rectangle()).background(Color.black.opacity(0.33).edgesIgnoringSafeArea(.all)).edgesIgnoringSafeArea(.all).onTapGesture {
            switch indicatorType {
            case .loading(_):
                return
            default :
                self.showIndicator = false
            }
            
        }
    }
}


struct LoadingIndicator : View {
    var message : String
    @State var animate = false
    var body : some View {
        VStack{
            Circle()
                .trim(from: 0, to: 0.8)
                .stroke(AngularGradient(gradient: .init(colors: [.red,.purple]), center: .center), style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .frame(width: 45, height: 45)
                .rotationEffect(.init(degrees: self.animate ? 360 : 0))
                .animation(Animation.linear(duration: 0.7).repeatForever(autoreverses: false))
                
            Text(message).multilineTextAlignment(.center).font(.system(size: 15)).padding(.top)
                
            }.padding(20)
        .background(Color("loadingColor"))
        .cornerRadius(15)
        .onAppear {
            self.animate.toggle()
        }
    }
    
}

struct Indicator : View {
    var bad : Bool
    var message : String
    
    var body : some View {
        VStack{
            Image(systemName: self.bad ? "xmark.octagon" : "checkmark").resizable().frame(width: 35, height: 35, alignment: .center).animation(.easeIn).foregroundColor(self.bad ? Color.black : Color.green)
                
            Text(message).font(.system(size: 17)).fontWeight(.bold).padding(.top).multilineTextAlignment(.center)
                
            }.padding(20)
        .background(Color.pink)
        .cornerRadius(15)
        .shadow(radius: 20)
        
        
    }
    
    
}
struct LottieIndicator : View {
    var bad : Bool
    var message : String
    
    var body : some View {
        VStack{
            LottieView(loopMode: .loop, filename: "check", speed: 1)
                
            Text(message).font(.system(size: 13)).fontWeight(.bold).padding(.top).multilineTextAlignment(.center)
                
            }.padding(20)
        .background(self.bad ? Color.pink : Color.green)
        .cornerRadius(15)
        .shadow(radius: 20)
        
        
    }
    
    
}

