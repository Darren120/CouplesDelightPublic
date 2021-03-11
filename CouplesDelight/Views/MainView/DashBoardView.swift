//
//  DashBoardView.swift
//  CouplesDelight
//
//  Created by Darren Zou on 11/23/20.
//
import Foundation
import SwiftUI
import SDWebImageSwiftUI
import FirebaseStorage
class DashBoardViewModel: ObservableObject {
    var images = ["https://firebasestorage.googleapis.com/v0/b/couples-delight.appspot.com/o/a%2F119678319_789178144990330_5635982498931696815_n.jpg?alt=media&token=b25f1844-aa9c-435b-9a2d-9d95d5234aad","https://firebasestorage.googleapis.com/v0/b/couples-delight.appspot.com/o/a%2F119678319_789178144990330_5635982498931696815_n.jpg?alt=media&token=b25f1844-aa9c-435b-9a2d-9d95d5234aad", "https://firebasestorage.googleapis.com/v0/b/couples-delight.appspot.com/o/a%2F119678319_789178144990330_5635982498931696815_n.jpg?alt=media&token=b25f1844-aa9c-435b-9a2d-9d95d5234aad"]
    func getImages(path: String) {
       let ref = Storage.storage().reference(withPath: "jC3mo6t4dls5rfn8PNl1")
        
        ref.list(withMaxResults: 10) { (list, err) in
            
            if let err = err {
                print(err.localizedDescription)
            }
            print(list.items.count)
            print(list.items.forEach({ (ref) in
                
                ref.downloadURL { (url, err) in
                    print(url)
                }
            }))
           
        }
       
    }
    
}
struct DashBoard: View {
    @State var pop = false
    @StateObject var dashBoardVM = DashBoardViewModel()
    @EnvironmentObject var authManager : AuthManager
    var body: some View {
        VStack{
            
            WebImage(url: URL(string: "https://firebasestorage.googleapis.com/v0/b/couples-delight.appspot.com/o/a%2F119678319_789178144990330_5635982498931696815_n.jpg?alt=media&token=b25f1844-aa9c-435b-9a2d-9d95d5234aad")).resizable().frame(width: 100, height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            Button {
               
                
                self.dashBoardVM.getImages(path: "")
                
            } label: {
                Text("AKSJDL")
            }
            Button {
               
                
                authManager.continueWithoutLink.toggle()
                
            } label: {
                Text("Pop")
            }
            ZStack{
            if !pop{
                VStack{
                    
                    Text("Hello!")
                    Button {
                        pop.toggle()
                        
                    } label: {
                        Text("Pop")
                    }
                    
                }
            }
        }
        if pop {
            Text("PPPPooopP!")
        }
        }.onAppear{
            UINavigationBar.appearance().setBackgroundImage(nil, for: .default)
        }.onTapGesture {
            print("aaa")
        }
    }
}


