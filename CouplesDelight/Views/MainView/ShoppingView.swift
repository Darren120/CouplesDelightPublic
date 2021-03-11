//
//  ShoppingView.swift
//  CouplesDelight
//
//  Created by Darren Zou on 11/23/20.
//

import Foundation
struct Today: View {
    var animation: Namespace.ID
    @StateObject var detail : DetailViewModel
    
    var body: some View {
        
        ScrollView{
            
            VStack{
                
                HStack(alignment: .bottom) {
                    
                    VStack(alignment: .leading, spacing: 5) {
                        
                        Text("SATURDAY 14 NOVEMBER")
                            .foregroundColor(.gray)
                        
                        Text("Today")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                    
                    Spacer()
                    
                    Button(action: {}) {
                        
                        Image(systemName: "person.circle")
                            .font(.largeTitle)
                    }
                }
                .padding()
                
                ForEach(items){item in
                    
                    // CardView...

                    if detail.show{
                        
                        Rectangle()
                            .fill(Color.clear)
                            .frame(height: 320)
                            .padding(.horizontal)
                            .padding(.top)
                    }
                    else{
                        
                        TodayCardView(item: item,animation: animation)
                            .padding(.horizontal)
                            .padding(.top)
                            .onTapGesture {
                                
                                withAnimation(.spring()){
                                    
                                    detail.selectedItem = item
                                    detail.show.toggle()
                                }
                            }
                    }

                }
            }
            .padding(.bottom)
        }
        .background(Color.primary.opacity(0.06).ignoresSafeArea())
    }
}

// TodayCardView

import SwiftUI

struct TodayCardView: View {
    var item: TodayItem
    // getting Current Scheme Color
    @Environment(\.colorScheme) var color
    var animation: Namespace.ID
    
    var body: some View {
        
        VStack{
            
            Image(item.contentImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .matchedGeometryEffect(id: "image" + item.id, in: animation)
                .frame(width: UIScreen.main.bounds.width - 30)
            
            HStack{
                
                Image(item.logo)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 65, height: 65)
                    .cornerRadius(15)
                
                VStack(alignment: .leading, spacing: 6) {
                    
                    Text(item.title)
                        .fontWeight(.bold)
                    
                    Text(item.category)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer(minLength: 0)
                
                VStack{
                    
                    Button(action: {}) {
                        
                        Text("GET")
                            .fontWeight(.bold)
                            .padding(.vertical,10)
                            .padding(.horizontal,25)
                            .background(Color.primary.opacity(0.1))
                            .clipShape(Capsule())
                    }
                    
                    Text("In App Purchases")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
            }
            .matchedGeometryEffect(id: "content" + item.id, in: animation)
            .padding()
        }
        .frame(height: 320)
        .background(color == .dark ? Color.black : Color.white)
        .cornerRadius(15)
    }
}

//Detail

import SwiftUI

struct Detail: View {
    // Getting Current Selected Item...
    @ObservedObject var detail : DetailViewModel
    var animation: Namespace.ID
    
    @State var scale : CGFloat = 1
    
    var body: some View {

        ScrollView{
            
            VStack{
                
                // Updated Code For Avoiding Top Scroll
                GeometryReader{reader in
                    
                    ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
                        
                        Image(detail.selectedItem.contentImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .matchedGeometryEffect(id: "image" + detail.selectedItem.id, in: animation)
                            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2.5)

                        HStack{
                            
                            Text(detail.selectedItem.overlay)
                                .font(.title)
                                .fontWeight(.heavy)
                                .foregroundColor(.white)
                            
                            Spacer(minLength: 0)
                            
                            Button(action: {
                                withAnimation(.spring()){

                                    detail.show.toggle()
                                }
                            }) {
                                
                                Image(systemName: "xmark")
                                    .foregroundColor(Color.black.opacity(0.7))
                                    .padding()
                                    .background(Color.white.opacity(0.8))
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.horizontal)
                        // since we ignored top area...
                        .padding(.top,UIApplication.shared.windows.first!.safeAreaInsets.top + 10)
                    }
                        .offset(y: (reader.frame(in: .global).minY > 0 && scale == 1) ? -reader.frame(in: .global).minY : 0)
                    // Gesture For Closing Detail View....
                    .gesture(DragGesture(minimumDistance: 0).onChanged(onChanged(value:)).onEnded(onEnded(value:)))
                }
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2.5)
                
                HStack{
                    
                    Image(detail.selectedItem.logo)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 65, height: 65)
                        .cornerRadius(15)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        
                        Text(detail.selectedItem.title)
                            .fontWeight(.bold)
                        
                        Text(detail.selectedItem.category)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer(minLength: 0)
                    
                    VStack{
                        
                        Button(action: {}) {
                            
                            Text("GET")
                                .fontWeight(.bold)
                                .padding(.vertical,10)
                                .padding(.horizontal,25)
                                .background(Color.primary.opacity(0.1))
                                .clipShape(Capsule())
                        }
                        
                        Text("In App Purchases")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .matchedGeometryEffect(id: "content" + detail.selectedItem.id, in: animation)
                .padding()
                
                Text("Race through the ultimate street racing scene at dizzying speed withthe tap of your finger! Have fun winning the racing car collection of your dreams. Pick an event, choose a lineup of cars from your collection, and start racing for infamy in the first Forza game for mobile.\n\nCOLLECT AND UPGRADE ICONIC CARS\nRace to collect legendary cars at intense speed – from classic muscle to modern sports and retro supercars – turning your garage into a trophy case of iconic racing cars, with all the fun, attention to graphics detail, and speed Forza is known fo\n\nTRUE CINEMATIC RACING\nStreamlined controls focus on the fun - timing your gas, brake, and boost are the keys to victory, as action cams chase the racing adrenaline up close showcasing amazing graphics. The stunning, best in class, 3D visuals bring the action to life while you’re speeding across the asphalt. It’s a fun, new, and wholly unique way to enjoy Forza.\n\nRACE ON YOUR TERMS\nRace your collection of cars anytime, anywhere. Squeeze in a fun, quick one-minute race, or dive into immersive story driven events with multiple paths to victory in the cars you love. New controls let you easily race with the tap of a finger to control your gas, brake, and boost. Forza Street has something fun for you any time you feel like racing at high speed and boosting across the finish line to victory.")
                    .padding()

                Button(action: {}) {
                    
                    Label(title: {
                        Text("Share")
                            .foregroundColor(.primary)
                    }) {
                        
                        Image(systemName: "square.and.arrow.up.fill")
                            .font(.title2)
                            .foregroundColor(.primary)
                    }
                    .padding(.vertical,10)
                    .padding(.horizontal,25)
                    .background(Color.primary.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding()
            }
        }
        .scaleEffect(scale)
        .ignoresSafeArea(.all, edges: .top)
    }
    
    func onChanged(value: DragGesture.Value){
        
        // calculating scale value by total height...
        
        let scale = value.translation.height / UIScreen.main.bounds.height
        
        // if scale is 0.1 means the actual scale will be 1- 0.1 => 0.9
        // limiting scale value...
        
        if 1 - scale > 0.75{
        
            self.scale = 1 - scale
        }
    }
    
    func onEnded(value: DragGesture.Value){
        
        withAnimation(.spring()){
            
            // closing detail view when scale is less than 0.9...
            if scale < 0.9{
                detail.show.toggle()
            }
            scale = 1
        }
    }
}

// DetailViewModel

import SwiftUI

class DetailViewModel: ObservableObject {

    @Published var selectedItem = TodayItem(title: "", category: "", overlay: "", contentImage: "", logo: "")
    
    @Published var show = false
}

// Today Item

import SwiftUI

// Model And Model Data...

struct TodayItem: Identifiable {
    
    var id = UUID().uuidString
    var title: String
    var category: String
    var overlay: String
    var contentImage: String
    var logo: String
}

var items = [

    TodayItem(title: "Forza Street", category: "Ultimate Street Racing Game", overlay: "GAME OF THE DAY", contentImage: "l1-1", logo: "b1-1"),
    
    TodayItem(title: "Roblox", category: "Adventure", overlay: "Li Nas X Performs In Roblox", contentImage: "b1", logo: "l1"),
    
]
