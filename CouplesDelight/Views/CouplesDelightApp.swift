//
//  CouplesDelightApp.swift
//  CouplesDelight
//
//  Created by Darren Zou on 10/24/20.
//

import SwiftUI
import AuthenticationServices
// STATE OBJECT FOR VIEW MODELS TO PRESIST DATA SO PARENT DONT RE-INIT CHILD VIEWS
@main
struct CouplesDelightApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    @StateObject var authManager = AuthManager(firestoreService: MasterAPIService())
    @State var continueWithoutLink = false
    var body: some Scene {
        WindowGroup {
            
            ZStack{
             CustomGradientBackground()
                VStack{
                    if !self.authManager.dontShowBoarding {
                        
                        OnBoarding().environmentObject(self.authManager).animation(.none)
                  
                    } else {
                        
                        switch self.authManager.authState {
                        case .none:
                            VStack{
                                ZStack{
                                    LottieView(loopMode: .loop, filename: "heartLoader").padding(.bottom, 70)
                                    Text("Loading...").font(.system(size: 20, weight: .bold, design: Font.Design.rounded)).padding(.top, 200).padding(.leading)
                                }
                                
                            }
//                            VStack{
//                                LottieView(loopMode: .loop, filename: "heartLoader")
//                                Text("Loading...").font(.system(size: 10, weight: .bold, design: Font.Design.rounded))
//                            }
                        case .authView:
                            AuthView(authVM: AuthViewModel(authManager: self.authManager)).environmentObject(self.authManager).animation(.none).onAppear{UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)}
                        case .createProfileView:
                            CreateProfileView(profileVM: CreateProfileViewModel(authManager: self.authManager)).animation(.none).onAppear{UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)}
                        case .linkView:
                            LinkView(linkVM: LinkViewModel(authManager: self.authManager)).animation(.none).onAppear{UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)}
                        case .mainView:
                            MainTabView().environmentObject(self.authManager).onAppear{UINavigationBar.appearance().setBackgroundImage(nil, for: .default)}
                        }
                    }

                }
            }
            
            
            
        }
    }
//    func showLinkView() -> Bool {
//        (authManager.userSession!.linked.exist && !self.authManager.continueWithoutLink)
//    }
    
}

//struct CustomTabView: View {
//    @Namespace var animation
//    @StateObject var detailObject = DetailViewModel()
//    @EnvironmentObject var authManager : AuthManager
//    @State var index  = 1
//    
//    init() {
//        UITabBar.appearance().barTintColor = UIColor(Color("red"))
//        
//    }
//    var body: some View {
//     
//            ZStack{
//                
//                TabView(selection: $index) {
//                    LazyView(testA(authVM: AuthViewModel(authManager: self.authManager), index: self.$index)).tabItem {
//                        Image(systemName: "house")
//                        Text("Bone").fontWeight(.heavy)
//                    }.tag(1)
//                    LazyView(testtb(authVM: AuthViewModel(authManager: self.authManager))).tabItem {
//                        Image(systemName: "house")
//                        Text("Home").fontWeight(.heavy)
//                    }.tag(2)
//                    LazyView(Today(detail: self.detailObject)).tabItem {
//                        Image(systemName: "bag")
//                        Text("Deals").fontWeight(.heavy)
//                    }.tag(3)
//                }.opacity(detailObject.show ? 0 : 1)
//                            
//                            if detailObject.show{
//                                
//                                Detail(detail: detailObject, animation: animation)
//                            }
//                if self.authManager.disabeParent {
//                    HStack {
//                        Spacer()
//                        VStack{
//                            Spacer()
//                            
//                            
//                            
//                            Spacer()
//                        }
//                        Spacer()
//                    }.background(Color.black.opacity(0.13).edgesIgnoringSafeArea(.all)).edgesIgnoringSafeArea(.all)
//                }
//                
//            }
//        }
//    
//}


struct testA: View {
    @StateObject var authVM  : AuthViewModel
    var crypto = CryptoService()
    @Binding var index : Int
    @State var a = "aa"
    @State var togg = false
    @State var currentNonce : String?
    var body: some View {
        ZStack{
            LinearGradient(gradient: .init(colors: [Color.pink,Color.orange,Color.red]), startPoint: .top, endPoint: .bottom).edgesIgnoringSafeArea(.all)
            VStack{
                SignInWithAppleButton(.continue) { (request) in
                    
                    let nonce = self.authVM.authManager.randomNonceString()
                    currentNonce = nonce
                    request.requestedScopes = [.fullName, .email]
                    request.nonce = self.authVM.authManager.sha256(nonce)
                } onCompletion: { (result) in
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
                            
                            //Creating a request for firebase
                            self.authVM.authManager.linkAppleAccount(idTokenString: idTokenString, nonce: nonce)
                            
                            
                        default:
                            self.authVM.indicatorType = .error(message: "error")
                            break
                            
                        }
                    default:
                        self.authVM.indicatorType = .error(message: "error")
                        break
                    }
                }.frame(width: 150, height: 35, alignment: .center)
                
                
                Button {
                    self.authVM.authManager.delegateTest()
                } label: {
                    Text(("Unlink Apple Account"))
                }
                Button {
                    self.authVM.authManager.skipLinking()
                } label: {
                    Text(("Link account"))
                }
                NavigationLink(destination: testtb(authVM: self.authVM)) {
                    Text(self.authVM.authManager.userSession?.firstName ?? "GOOO")
                }
            }
            
            if self.authVM.showIndicator {
                AppStateView(indicatorType: Binding(self.$authVM.indicatorType)!, showIndicator: self.$authVM.showIndicator, autoDisable: true)
            }
        }
        
        
    }
    
}
struct testtb: View {
    @StateObject var authVM  : AuthViewModel
    var body: some View {
        VStack{
            Button {
                self.authVM.authManager.signOut()
            } label: {
                Text("clcik")
            }
            
        }
    }
}

