//
//  LinkView.swift
//  CouplesDelight
//
//  Created by Darren Zou on 11/8/20.
//

import Foundation
import SwiftUI


struct LinkView: View {
    @StateObject var linkVM : LinkViewModel
    var body: some View {
        ZStack{
            
            switch self.linkVM.linkStatus {
                case .noLink:
                    NavigationView{
                        
                        NoLinkView(linkVM: self.linkVM).animation(.none)
                           
                    }
                case .linkOwner:
                    NavigationView{
                        LinkOwnerView(linkVM: self.linkVM).animation(.none)
                         
                    }
                case .linkWith:
                    NavigationView{
                        LinkWithBaeView(linkVM: self.linkVM).animation(.none)
                    }
                case .initlizing:
                    VStack{
                        Text("One sec...")
                        ProgressView()
                    }
            }
            if self.linkVM.showIndicator {
                AppStateView(indicatorType: Binding(self.$linkVM.indicatorType)!, showIndicator: self.$linkVM.showIndicator, autoDisable: false)
            }
           
        }.contentShape(Rectangle()).onTapGesture {
            dismissKeyboard()
        }
    }
    
    
}
struct NoLinkView : View {
    @State var animation = false
    @StateObject var linkVM : LinkViewModel
    @State var kpp = "aa"
    var timer = Timer.publish(every: 1.25, tolerance: 0.5, on: .main, in: .common).autoconnect()
    var body: some View {
        ZStack{
            CustomGradientBackground()
        VStack{
            
            VStack(spacing: 10){
                
                Text("First one on here?").padding(.horizontal).multilineTextAlignment(.center).font(.headline)
                Text("Generate a Link Pin for bae!").padding(.horizontal).padding(.top, -10).multilineTextAlignment(.center).font(.footnote)
                VStack {
                    Text("🎂Anniversary🥳").font(.headline).frame(alignment: .center)
                    DatePicker("", selection: $linkVM.anniversary, displayedComponents: .date).labelsHidden()
                  
                    
                }.padding(.top)
                Button {
                   
                    self.linkVM.generateLinkPin()
                } label: {
                    Text("Generate Link Pin").padding()
                }.overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(!self.animation ? Color("green") : Color.purple, lineWidth: 2)
                )
            }
            HStack{
                Rectangle()
                    .fill(Color.black)
                    .frame(height: 2)
                    .edgesIgnoringSafeArea(.horizontal)
                    .padding(.leading)
                    .opacity(0.5)
                
                Text("OR").font(.footnote).opacity(0.4).padding(.vertical)
                Rectangle()
                    .fill(Color.black)
                    .frame(height: 2)
                    .edgesIgnoringSafeArea(.horizontal)
                    .padding(.trailing)
                    .opacity(0.5)
            }
            VStack(spacing: 10) {
                Text("Link using bae's code").padding(.horizontal).multilineTextAlignment(.center).font(.headline)
                Button {
              
                    self.linkVM.linkWithBae()
                } label: {
                    Text("Link with bae").padding()
                }.overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(self.animation ? Color("green") : Color.purple, lineWidth: 2)
                )
            }
         
            Spacer(minLength: 0)
            
        }.animation(.default)
            
            
        }.onDisappear{self.timer.upstream.connect().cancel()
            print("goodbye")
        }.onReceive(timer) { (time) in
          
            self.animation.toggle()
        }.navigationBarTitle("Link with bae!", displayMode: .automatic)
        .navigationBarItems(trailing:Button("Skip") { self.linkVM.continueWithoutLink()}.disabled(self.linkVM.showIndicator))
    }
}
struct LinkOwnerView : View {
    @StateObject var linkVM : LinkViewModel
    @State var showAlert = false
    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var body: some View {
        ZStack{
            CustomGradientBackground()
        VStack{
            VStack{
                Text("Instructions:").fontWeight(.bold).font(.title)
                Text("Upon signing up, tell your partner to click 'Link with Bae' button, then enter the link code below and answer a few questions. It is recommended that he/she should not ask you for the answers unless they really don't know =)").foregroundColor(.white).font(.system(size: 18, weight: Font.Weight.medium, design: .serif)).font(.footnote).multilineTextAlignment(.center).padding(.horizontal)
            }.padding(.vertical)
            Text("Link Code").padding(.bottom , 2).font(.headline)
            
            if self.linkVM.openLink != nil {
      
                    VStack{
                        Text(self.linkVM.openLink!.linkID.uppercased()).font(.headline)
               
                    }.frame(width: 95, height: 45, alignment: .center).background(Color.white.opacity(0.25)).cornerRadius(14)
                VStack {
                    Text(self.linkVM.openLink!.linkRequests.isEmpty ? "Waiting for link request... \n Hit refresh to reload" : "Pending Requests").font(.headline).multilineTextAlignment(.center)
                ScrollView{
                    ForEach(self.linkVM.openLink!.linkRequests, id: \.requesterUID) { request in
                        HStack{
                            Text(request.firstName + " " + request.lastName).font(.system(size: 20, weight: .bold))
                            
                            Button(action: {
                                self.showAlert.toggle()
                            }, label: {
                                Image(systemName: "chevron.right.circle").resizable().frame(width: 30, height: 30).padding(.leading, 3)
                            }).alert(isPresented: $showAlert, content: {
                                Alert(title: Text("Accept Link?"), message: Text("Are you sure you want to accept \(request.firstName + " " + request.lastName) as your partner?"), primaryButton: .default(Text("Reject")) {
                                    self.linkVM.rejectRequest(linkRequest: request)
                                       
                                }, secondaryButton: .default(Text("Accept"), action: {
                                    self.linkVM.acceptLinkRequest(request: request)
                                }))
                                
                            })
                        }.padding(.bottom, 3)
                        
                    }
                    
                }
                }.padding(.top)
             
            }
       
        }.animation(.easeIn).onReceive(timer) { (time) in
            
            if linkVM.counter >= 30 && !self.linkVM.disableRefresh {return}
            print("Aa")
            if linkVM.counter <= 0 && self.linkVM.disableRefresh {
                self.linkVM.counter = 30
                self.linkVM.disableRefresh = false
            } else {
                self.linkVM.counter -= 1
            }
        
        }
            
        }.onDisappear{self.timer.upstream.connect().cancel()}.navigationBarTitle("Show this to bae", displayMode: .automatic)
        .navigationBarItems(leading:
                                Button("Delete Link") {
                                    self.linkVM.deleteLink()
                                }.disabled(self.linkVM.showIndicator), trailing: Button(self.linkVM.disableRefresh ? "\(self.linkVM.counter, specifier: "%.0f")" : "Refresh") {
                               
                                    self.linkVM.refreshLinkOwner()
                                }.disabled(self.linkVM.showIndicator || self.linkVM.disableRefresh)
        )
    }
//     func instantiateTimer() {
//        self.timer = Timer.publish(every: 1.25, tolerance: 0.5, on: .main, in: .common)
//            return
//        }
//
//        func cancelTimer() {
//            self.timer.connect().cancel()
//            return
//        }
}
struct LinkWithBaeView : View {
    @StateObject var linkVM : LinkViewModel
    let set = CharacterSet(charactersIn: "1234567890ABCDEFGHIJKLKMNOPQRSTUVWXYZ")
    
    
    var body: some View {
        ZStack{
            CustomGradientBackground()
            if self.linkVM.authManager.userSession!.pendingRequest.exist {
                VStack(spacing: 10) {
                    Text("Waiting for bae to accept your link request...").font(.headline).multilineTextAlignment(.center)
                    Button {
                        self.linkVM.cancelOutgoingLinkRequest()
                    } label: {
                        Text("Cancel request")
                    }.buttonStyle(PlainButtonStyle()).frame(width: 150, height: 40, alignment: .center).cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.red, lineWidth: 2)
                    )
                    
                }
            } else {
                VStack{
                    VStack {
                    Text("Enter Link Code").font(.headline)
                    
                    TextField("CODE", text: self.$linkVM.partnerLinkID).autocapitalization(.allCharacters).frame(width: 60, height: 25, alignment: .center).padding().background(Color.white.opacity(0.26)).cornerRadius(10).shadow(radius: 10)
                       .disableAutocorrection(true)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(((self.linkVM.partnerLinkID.count != 5) || (self.linkVM.partnerLinkID.rangeOfCharacter(from: set.inverted) != nil)) ? Color.red : Color.green, lineWidth: 2)
                        )
                    }
                    VStack {
                        Text("🎂Anniversary🥳").font(.headline).frame(alignment: .center)
                        Text("You should know this...").font(.footnote).frame(alignment: .center)
                        DatePicker("", selection: $linkVM.anniversary, displayedComponents: .date).labelsHidden()
                        
                    }.padding(.top)
                    VStack {
                        Text("🎂Partner Birthday🥳").font(.headline).frame(alignment: .center)
                        Text("You should DEFINATELY know this...").font(.footnote).frame(alignment: .center)
                        DatePicker("", selection: $linkVM.partnerBirthday, displayedComponents: .date).labelsHidden()
                        
                    }.padding(.vertical)
                    Button {
                        self.linkVM.sendLink()
                    } label: {
                        Text("Send Link").frame(width: 100, height: 40, alignment: .center).cornerRadius(10)
                    }.buttonStyle(PlainButtonStyle()).frame(width: 100, height: 35, alignment: .center).cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.blue, lineWidth: 2)
                    )
                    Spacer(minLength: 0)

                }.animation(.easeIn).padding(.top)
            }
            
        }.navigationBarTitle("Let's get u two linked", displayMode: .inline)
        .navigationBarItems(leading:
                                Button("Back") {
                                    self.linkVM.linkStatus = .noLink
                                }.disabled(self.linkVM.showIndicator)
        )
    }
}


