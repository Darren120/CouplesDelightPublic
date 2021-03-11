//
//  AuthView.swift
//  CouplesDelight
//
//  Created by Darren Zou on 10/30/20.
//

import Foundation
import SwiftUI
import AuthenticationServices
struct AuthView: View {
  
    @EnvironmentObject var authManager : AuthManager
    @StateObject var authVM : AuthViewModel
    @State var showPhoneAuth = false
    @State var createAccount = false
    @State var loading = false
    var body: some View {
        NavigationView{
        ZStack{
            CustomGradientBackground()
        GeometryReader { geo in
            VStack(spacing: 20) {
                
                Text("Couples Delight").font(.title).fontWeight(.bold).foregroundColor(.white).padding(.top, geo.size.height/3).padding(.bottom, geo.size.height/8)
                
                Text("By Signing In or Creating an Account, you agree to our terms of service and privacy policy.").padding(.leading, 25).padding(.trailing, 25).multilineTextAlignment(.center).font(.footnote).foregroundColor(.white)
                if !createAccount {
                    Button { 
                        self.createAccount.toggle()
                    } label: {
                        Text("SIGN IN").frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity).font(.subheadline).foregroundColor(.white)
                    }.background(Color.clear).frame(width: 300, height: 45).overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white, lineWidth: 2)
                    )
                    NavigationLink(destination:NavigationLazyView(PhoneAuthView(authVM: authVM))) {
                        Text("CREATE ACCOUNT").frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity).font(.subheadline).foregroundColor(.black)
                    }.frame(width: 300, height: 45).background(Color.white).cornerRadius(20)
                    
                    
                }else {
                    AppleAuthView(authVM: authVM, currentNonce: "").frame(width: geo.size.width/2, height: 45)
                    NavigationLink(destination: NavigationLazyView(PhoneAuthView(authVM: AuthViewModel(authManager: self.authManager)))) {
                        Text("SIGN IN WITH PHONE NUMBER").frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity).font(.subheadline).foregroundColor(.white)
                    }.background(Color.clear).frame(width: 325, height: 45).overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white, lineWidth: 2)
                    )
                    Button {
                        self.createAccount = false
                        
                    } label: {
                        Text("< BACK").frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity).font(.subheadline).foregroundColor(.white)
                    }.background(Color.clear).frame(width: geo.size.width/2, height: 45).overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white, lineWidth: 2)
                    )
                }
                
                Button {
                    self.authManager.signOut()
                } label: {
                    Text("Trouble Signing In?").font(.footnote).foregroundColor(.white)
                }
                
            }.animation(.default).padding(.leading, 6)
            
        }
            if self.authVM.showIndicator {
                AppStateView(indicatorType: Binding(self.$authVM.indicatorType)!, showIndicator: self.$authVM.showIndicator, autoDisable: true)
            }
        }.navigationBarHidden(true)
        }
    }
}

struct PhoneAuthView : View {
    @StateObject var authVM  : AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        ZStack{
            CustomGradientBackground()
            VStack{
                ZStack{
                    if self.authVM.showPhoneView {
                        VStack{
                            HStack(spacing: 15){
                                
                                Text("US +1")
                                    .fontWeight(.bold)
                                    .multilineTextAlignment(.leading)
                                    .padding()
                                    .frame(width: 90)
                                    .background(Color.white.opacity(0.06))
                                    .cornerRadius(15)
                                
                                TextField("1234567890", text: $authVM.phoneNumber)
                                    .keyboardType(.numberPad)
                                    .padding()
                                    .background(Color.white.opacity(0.06))
                                    .cornerRadius(15)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke((self.authVM.phoneNumber.count != 10) ? Color.red : Color.green, lineWidth: 2)
                                    )
                            }
                            .padding()
                            .padding(.top,10)
                            Button {
                                dismissKeyboard()
                                self.authVM.sendVerificationCode()
                           
                            } label: {
                                Text("Send Code")
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                                    .padding(.vertical)
                                    .frame(width: UIScreen.main.bounds.width - 100)
                                    .background(Color.blue)
                                    .clipShape(Capsule())
                            }
                        }
                    } else {
                        VStack{
                            HStack(spacing: 1){
                                
                                Text("Code:")
                                    .fontWeight(.bold)
                                    .multilineTextAlignment(.leading)
                                    .padding()
                                    
                                    .frame(width: 125)
                                
                                
                                TextField("000000", text: $authVM.verificationCode)
                                    .keyboardType(.numberPad)
                                    .padding()
                                    .background(Color.white.opacity(0.06))
                                    .cornerRadius(15)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke((self.authVM.verificationCode.count != 6) ? Color.red : Color.green, lineWidth: 2)
                                    )
                            }.padding()
                            .padding(.top,10)
                            Text("We have sent you a verification code at: \(self.authVM.phoneNumber), it may take 1-2 minutes.").padding(.horizontal)
                                .font(.footnote)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            Button {
                                dismissKeyboard()
                                self.authVM.verifyPhone()
                            } label: {
                                Text("Verify")
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                                    .padding(.vertical)
                                    .frame(width: UIScreen.main.bounds.width - 100)
                                    .background(Color.blue)
                                    .clipShape(Capsule())
                            }
                            Button {
                               print("puta")
                                self.authVM.showPhoneView = true
                            } label: {
                                Text("< Back")
                                    .foregroundColor(.white)
                                    .fontWeight(.bold)
                                    .padding(.vertical)
                                    .frame(width: 90, height: 45)
                                    .background(Color.orange)
                                    .cornerRadius(15)
                            }
                        }
                       
                    }
                    
                }
                
                Spacer(minLength: 0)
            }
            
            if self.authVM.showIndicator {
                AppStateView(indicatorType: Binding(self.$authVM.indicatorType)!, showIndicator: self.$authVM.showIndicator, autoDisable: true)
            }
            
        }.navigationBarTitle("Phone Authentication", displayMode: .automatic).navigationBarBackButtonHidden(self.authVM.showIndicator)
        .onTapGesture {
           dismissKeyboard()
        }
        
    }
}

struct AppleAuthView : View {
    @StateObject var authVM  : AuthViewModel
    @State var currentNonce : String?
    
    var body: some View {
        ZStack{

        SignInWithAppleButton(.signIn) { (request) in
            
            let nonce = self.authVM.authManager.randomNonceString()
            currentNonce = nonce
            request.requestedScopes = [.fullName, .email]
            request.nonce = self.authVM.authManager.sha256(nonce)
        } onCompletion: { (result) in
            self.authVM.indicatorType = .loading(message: "One sec...")
            switch result {
           
            case .success(let authResults):
                switch authResults.credential {
                case let appleIDCredential as ASAuthorizationAppleIDCredential:
                    
                    guard let nonce = currentNonce else {
                        self.authVM.indicatorType = .error(message: "error")
                        return
                    }
                    guard let appleIDToken = appleIDCredential.identityToken else {
                        self.authVM.indicatorType = .error(message: "error")
                        return
                        
                    }
                    guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                        print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                        self.authVM.indicatorType = .error(message: "error")
                        return
                    }
                    
                    self.authVM.authManager.signInWithApple(idTokenString: idTokenString, nonce: nonce)
                    self.authVM.showIndicator = false
           
                default:
                    self.authVM.indicatorType = .error(message: "error")
                    break
                    
                }
            default:
                self.authVM.indicatorType = .error(message: "error")
                break
            }
            
        }.signInWithAppleButtonStyle(.white)
            
            }
            
        
    }
}
