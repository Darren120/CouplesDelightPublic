//
//  CreateProfileView.swift
//  CouplesDelight
//
//  Created by Darren Zou on 11/3/20.
//

import Foundation
import SwiftUI
struct CreateProfileView : View {
    @StateObject var profileVM : CreateProfileViewModel
    let set = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ")
    @State var genderSlider: Double = 0 {
        willSet{
            
        }
    }
    let timer = Timer.publish(every: 1, on: .current, in: .common).autoconnect()
    @State var repeatAnimation = true
    @State var toggle = false
    var body: some View {
        NavigationView {
        ZStack{
            CustomGradientBackground()
            VStack{
        
            VStack(spacing: 10){
              
                Text("Sex").font(.title).fontWeight(.bold)
                HStack {
                    Button {
                        self.toggle.toggle()
                        self.profileVM.gender = "Male"
                    } label: {
                        Text("Male").font(.headline).frame(width: 100, height: 100, alignment: .center).cornerRadius(10).background(Color.red).foregroundColor((self.profileVM.gender == "Male") ? Color("green") : Color.gray)
                    }.frame(width: 100, height: 100, alignment: .center).cornerRadius(10).shadow(radius: 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke((self.profileVM.gender == "Male") ? Color("green") : Color.gray, lineWidth: 2)
                    )
                    Text("OR").font(.footnote).padding(.horizontal)
                    Button {
                        self.toggle.toggle()
                        self.repeatAnimation = false
                        self.profileVM.gender = "Female"
                    } label: {
                        Text("Female").font(.headline).frame(width: 100, height: 100, alignment: .center).cornerRadius(10).background(Color.red).foregroundColor((self.profileVM.gender == "Female") ? Color("green") : Color.gray)
                    }.frame(width: 100, height: 100, alignment: .center).cornerRadius(10).shadow(radius: 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke((self.profileVM.gender == "Female") ? Color("green") : Color.gray, lineWidth: 2)
                    )
                }
//                Text("Chose your gender!").font(.title)
//                LinearGradient(gradient: .init(colors: [Color(UIColor.random()),Color(UIColor.random()),Color(UIColor.random())]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all).mask(Text(profileVM.gender).font(.title)).animation(.none)
////                Text(profileVM.gender).font(.title).foregroundColor(Color(UIColor.random()))
//                HStack {
////                    Slider(value: self.$genderSlider)
//                    Slider(value: self.$profileVM.sliderValue, in: 0...102)
//
//
//                }
                VStack{
                    
                
                    TextField("First Name", text: $profileVM.firstName).padding().background(Color.white.opacity(0.26)).cornerRadius(10).shadow(radius: 10)
                        .autocapitalization(.words).disableAutocorrection(true)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke((self.profileVM.firstName.count < 1) ? Color.red : Color.green, lineWidth: 2)
                        )
                    TextField("First Name", text: $profileVM.lastName).padding().background(Color.white.opacity(0.26)).cornerRadius(10).shadow(radius: 10)
                        .autocapitalization(.words).disableAutocorrection(true)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke((self.profileVM.lastName.count < 1) ? Color.red : Color.green, lineWidth: 2)
                        )
                }.padding().padding(.top, 10)
                VStack{
                    Text("🎂Birthday🥳").font(.headline).frame(alignment: .center)
                    DatePicker("", selection: $profileVM.birthday, displayedComponents: .date).labelsHidden()
                  
                      
                }
               
                
                Button {
                    self.profileVM.createProfile()
                } label: {
                    Text("Next").frame(width: 100, height: 35, alignment: .center).cornerRadius(10)
                }.buttonStyle(PlainButtonStyle()).frame(width: 100, height: 35, alignment: .center).cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke((self.profileVM.gender == "Female") ? Color.green : Color.blue, lineWidth: 2)
                )

             
                Spacer(minLength: 0)
             
            }.animation(.default).padding(.top)
            }
            if self.profileVM.showIndicator {
                AppStateView(indicatorType: Binding(self.$profileVM.indicatorType)!, showIndicator: self.$profileVM.showIndicator, autoDisable: true).animation(.default)
            }
        }.contentShape(Rectangle()).onTapGesture {
            dismissKeyboard()
        }.navigationBarTitle("Let's fill in some info", displayMode: .inline)
        .navigationBarItems(leading:
                        Button("Help") {
                           print("ajfhskdjhf")
                        }.disabled(self.profileVM.showIndicator)
                    )
        }
    }

}
