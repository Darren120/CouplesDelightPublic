//
//  MapView.swift
//  CouplesDelight
//
//  Created by Darren Zou on 11/23/20.
//

import SwiftUI
import MapKit
import CoreLocation
import Firebase
import FirebaseFirestore
struct MapVieww: View {
    @EnvironmentObject var authManager : AuthManager
    @State var manager = CLLocationManager()
    @State var openMapView = false
    @State var allowLocationAlert = false
    var body: some View {
      
            VStack{
               NavigationLink(
                destination: Home(manager: self.$manager, obs: observer(couplesDoc: self.getCouplesLinkedDoc(), myUID: self.getMeUID(), baeUID: self.getBaeUID())),
                isActive: self.$openMapView,
                label: {
                    Text("")
                })
//                NavigationLazyView(NavigationLink("Start Map!", destination: Home(manager: self.$manager, obs: observer(couplesDoc: self.getCouplesLinkedDoc(), myUID: self.getMeUID(), baeUID: self.getBaeUID()))).navigationBarTitle("", displayMode: .inline))
                Button(action: {
                    let authorizationStatus = CLLocationManager.authorizationStatus()

                    if (authorizationStatus == CLAuthorizationStatus.denied ) {
                        
                        self.allowLocationAlert = true
                    } else {
                        openMapView.toggle()
                    }
                }, label: {
                    Text("Start Location Sharing")
                        
                }).alert(isPresented: self.$allowLocationAlert) { () -> Alert in
                    
                    Alert(title: Text("Error"), message: Text("Please Enable Location or this feature will not work as properly."), primaryButton: .default(Text("Cancel")) , secondaryButton: .default(Text("Go"), action: {
                        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {

                           UIApplication.shared.open(settingsUrl)

                         }
                    }))
                   
                }
                Text("By clicking Start Map, you agree and awkownlege that this service is for entertainment purposes only. We are not responiable for accuracy of the infomration provided. We are not a directional or GPS service.").font(.footnote).padding()
            }.navigationBarHidden(true)
        
    }
    func getCouplesLinkedDoc() -> String {
        return self.authManager.userSession!.couplesLinked.docID
    }
    func getMeUID() -> String {
        return self.authManager.userSession!.uid
    }
    func getBaeUID() -> String {
        return self.authManager.couplesLinked!.getBae(uid: getMeUID()).uid
    }
    struct Home : View {
        @Environment(\.presentationMode) var mode
        @State var map = MKMapView()
        @Binding var manager : CLLocationManager
        @State var alert = false
        @State var source : CLLocationCoordinate2D!
        @State var destination : CLLocationCoordinate2D!
        @State var name = ""
        @State var distance = ""
        @State var time = ""
        @State var autoCenter = true

        @StateObject var obs : observer
        
        var body: some View{
            
            ZStack{
                
                ZStack(){
                    
                    VStack(spacing: 0){
                       
                        VStack(alignment: .leading, spacing: 3){
                            HStack{
                            Text("Status: ").fontWeight(.bold).padding(.top)
                                Text((self.obs.timeSinceBaeOnline < 130 ? "Online" : "Offline")).foregroundColor(self.obs.timeSinceBaeOnline < 130 ? Color.green : Color.red).fontWeight(.bold).padding(.top)
                            }
                                
                            Text(self.obs.timeSinceBaeOnline < 130 ? "Showing last online location" : "Showing latest location" )
                                .fontWeight(.bold)
                            Text("Closest address: \(self.name)")
                                
                                Text(self.distance != "" ? ("Distance: "+self.distance+" kilometors") : ("Unavailable: Partner not connected"))
                            
                                Text(self.time != "" ? ("Estimated: "+self.time+" minutes") : ("Unavailable: Partner not connected"))
                                HStack{
                            Button(action: {
                                
                                let s = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: source.latitude, longitude: source.longitude)))
                                s.name = "Source"

                                let d = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: destination.latitude, longitude: destination.longitude)))
                                d.name = "Destination"
                                
                                MKMapItem.openMaps(with: [s, d], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
                                
                               
                                
                            }) {
                                
                                Text("Open in Apple Maps")
                                    .foregroundColor(.white)
                                    .padding(.vertical, 10)
                                    .frame(width: UIScreen.main.bounds.width / 2)
                            }
                            .background(Color.red)
                            .clipShape(Capsule())
                            Button(action: {
                                
                                withAnimation{
                                    self.autoCenter.toggle()
                                }
                                
                               
                                
                            }) {
                                
                                Text(self.autoCenter ? "Auto Center On" : "Auto Center off")
                                    .foregroundColor(.white)
                                    .padding(.vertical, 10)
                                    .frame(width: UIScreen.main.bounds.width / 2.3)
                            }
                            .background(Color.red)
                            .clipShape(Capsule())
                                }
                             
                                
                    
                            
                        }.padding(.bottom)
                      
                        if self.obs.data.count == 0{
                            Loader()
                        } else {
                            MapView(map: self.$map, manager: self.$manager, alert: self.$alert, source: self.$source, destination: self.$destination, name: self.$name,distance: self.$distance,time: self.$time, autoCenter: self.$autoCenter, obs: self.obs)
                                
                            .onAppear {
                               
                                self.manager.requestAlwaysAuthorization()
                                    
                            }.onDisappear {
                                print("bye")
                                self.obs.listner?.remove()
                            
                                map.removeOverlays(map.overlays)
                                map.removeAnnotations(map.annotations)
                                map.delegate = nil
                                manager.delegate = nil
                                manager.stopUpdatingLocation()
                                
                            }
                        }
                        
                    }
                    
                  
                }
                
                
                
              
            }.navigationBarTitle("", displayMode: .inline)
         
//            .alert(isPresented: self.$alert) { () -> Alert in
//
//                Alert(title: Text("Error"), message: Text("Please Enable Location or this feature will not work as properly."), primaryButton: .default(Text("Cancel"), action: {
//                    self.mode.wrappedValue.dismiss()
//                }) , secondaryButton: .default(Text("Go"), action: {
//                    if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
//
//                       UIApplication.shared.open(settingsUrl)
//
//                     }
//                }))
//
//            }
        }
    }

    struct Loader : View {
        
        @State var show = false
        
        var body: some View{
            
            GeometryReader{_ in
                
                VStack(spacing: 20){
                    
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(Color.red, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 30, height: 30)
                        .rotationEffect(.init(degrees: self.show ? 360 : 0))
                        .onAppear {
                            
                            withAnimation(Animation.default.speed(0.45).repeatForever(autoreverses: false)){
                                
                                self.show.toggle()
                            }
                    }
                    
                    Text("Please Wait....")
                }
                .padding(.vertical, 25)
                .padding(.horizontal, 40)
                .background(Color.white)
                .cornerRadius(12)
            }
            .background(Color.black.opacity(0.25).edgesIgnoringSafeArea(.all))
        }
    }

    // MapView





    struct MapView : UIViewRepresentable {
        
        func makeCoordinator() -> Coordinator {
          
            return Coordinator(parent1: self)
        }
        
        @Binding var map : MKMapView
        @Binding var manager : CLLocationManager
        @Binding var alert : Bool
        @Binding var source : CLLocationCoordinate2D!
        @Binding var destination : CLLocationCoordinate2D!
        @Binding var name : String
        @Binding var distance : String
        @Binding var time : String
        @Binding var autoCenter : Bool
        @ObservedObject var obs : observer
        
        func makeUIView(context: Context) ->  MKMapView {
            
            map.delegate = context.coordinator
            manager.delegate = context.coordinator
            map.showsUserLocation = true
            let gesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(context.coordinator.centerOnTap(ges:)))
            map.addGestureRecognizer(gesture)
            self.manager.desiredAccuracy = kCLLocationAccuracyBest
            self.manager.startUpdatingLocation()
            
            return map
        }
        
        func updateUIView(_ uiView:  MKMapView, context: Context) {
            
           
        }

        class Coordinator : NSObject,MKMapViewDelegate,CLLocationManagerDelegate{
            deinit {
                self.parent = nil
                print("Coord deinit")
            }
            var parent : MapView?
            var updateTick = 119
            let db = Firestore.firestore()
            var firstTime = true
            var lastBaeLocation = CLLocation(latitude: 0, longitude: 0)
            init(parent1 : MapView) {
                
                parent = parent1
                
            }
//            func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
//
//                switch manager.authorizationStatus {
//                            case .authorizedAlways , .authorizedWhenInUse:
//                                break
//                            case .notDetermined , .denied , .restricted:
//                                parent?.alert.toggle()
//                            default:
//                                break
//                        }
//            }
            func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//                print("abc")
//                guard let parent = parent else {
//                    print("parent is nil")
//                    return
//                }
//
//
//                if status == .denied {
//
//                  parent.alert.toggle()
//                }
//                else{
//                    print("WHAT THE FFF")
//                    parent.manager.startUpdatingLocation()
//
//                }
            }
            
            func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            
                print("updating")
                guard let parent = parent else {
                    print("parent is nil")
                    return
                }
                let geoSource = parent.obs.data["data"] as! [String : GeoPoint]
                let s1 = geoSource[parent.obs.myUID]!
                let s2 = geoSource[parent.obs.baeUID]!
                let last = locations.last!

                let latestLocation = CLLocation(latitude: (locations.last?.coordinate.latitude)!, longitude: locations.last!.coordinate.longitude)
                let selfOnFirebase = CLLocation(latitude: s1.latitude, longitude: s1.longitude)
                let selfDistanceDiff = selfOnFirebase.distance(from: latestLocation)
              
                   
             
                autoUpdateMovement(last: last, s2: s2, s1: s1, selfDistanceDiff: selfDistanceDiff,firstTime: firstTime)
               
                parent.obs.timeSinceBaeOnline = FirebaseFirestore.Timestamp.init(date: Date()).seconds - parent.obs.lastBaeOnline
                    print(parent.obs.timeSinceBaeOnline)
                
                
                firstTime = false
                updateTick+=1
                print("tick: \(updateTick)")
                if selfDistanceDiff > 130 || updateTick == 120 {
                    updateTick = 0
                    
                    var data : [String: Any] = ["geoPoints.\(parent.obs.myUID)" : GeoPoint(latitude: (last.coordinate.latitude), longitude: (last.coordinate.longitude))]
                    let now = FirebaseFirestore.Timestamp.init(date: Date())
                    data["lastOnline.\(parent.obs.myUID)"] = now
                    db.collection("CouplesLinked").document(parent.obs.couplesDocID).collection("Location").document("shared").updateData(data) { (err) in


                                    if err != nil{

                                        print((err?.localizedDescription)!)
                                        return
                                    }
                                    print("success")
                                }
                } else {
                    print("DIDNT UPDATE \(selfDistanceDiff)")
                }
                
            }
            
            @objc func centerOnTap(ges: UITapGestureRecognizer) {
                guard let parent = parent else {
                    print("parent is nil")
                    return
                }
                let geoSource = parent.obs.data["data"] as! [String : GeoPoint]
                let s1 = geoSource[parent.obs.myUID]!
                let s1Coord = CLLocationCoordinate2DMake(s1.latitude, s1.longitude)
                let coop = MKCoordinateRegion(center: s1Coord, latitudinalMeters: 10000, longitudinalMeters: 10000)
                parent.map.setRegion(coop, animated: true)
            }
            func autoUpdateMovement(last: CLLocation, s2: GeoPoint, s1 : GeoPoint, selfDistanceDiff: CLLocationDistance, firstTime: Bool) {
                guard let parent = parent else {
                    print("parent is nil")
                    return
                }

                let baeCoordOnFirebase = CLLocation(latitude: s2.latitude, longitude: s2.longitude)
                let baeDistanceDiff = baeCoordOnFirebase.distance(from: lastBaeLocation)
                
                if(baeDistanceDiff > 130 || selfDistanceDiff > 130){
                    self.lastBaeLocation = baeCoordOnFirebase
                    let s2Coord = CLLocationCoordinate2DMake(s2.latitude, s2.longitude)
                    let s1Coord = CLLocationCoordinate2DMake(s1.latitude, s1.longitude)
                    let point = MKPointAnnotation()
                    point.subtitle = "Destination"
                    point.coordinate = s2Coord
                    point.title = "Here!"
                    parent.destination = s2Coord
                    
                    let decoder = CLGeocoder()
                    decoder.reverseGeocodeLocation(CLLocation(latitude: s2.latitude, longitude: s2.longitude)) { [unowned self] (places, err) in
                        
                        if err != nil{
                            
                            print((err?.localizedDescription)!)
                            return
                        }
                        
                        parent.name = places?.first?.name ?? ""
                        point.title = places?.first?.name ?? ""
                        
     
                    }
                    
                    let req = MKDirections.Request()
                    req.source = MKMapItem(placemark: MKPlacemark(coordinate: s1Coord))
                    
                    req.destination = MKMapItem(placemark: MKPlacemark(coordinate: s2Coord))
                    
                    let directions = MKDirections(request: req)
                    
                    directions.calculate { [unowned self] (dir, err) in
                        
                        if err != nil{
                            
                            print((err?.localizedDescription)!)
                            return
                        }
                        
                        let polyline = dir?.routes[0].polyline
                        
                        let dis = dir?.routes[0].distance ?? 0
                      
                        if dis == 0 {
                            parent.distance = "Unavailble"
                        } else {
                            parent.distance = String(format: "%.1f", dis / 1000)
                        }
                        let time = dir?.routes[0].expectedTravelTime ?? 0
                        if time == 0 {
                           parent.time = "Unavailble"
                        } else {
                            parent.time = String(format: "%.1f", time / 60)
                        }
                        self.parent!.map.removeOverlays(self.parent!.map.overlays)
                        let line = dir?.routes[0].polyline
                        self.parent!.map.addOverlay(line!)
                     
                        parent.map.removeOverlays(parent.map.overlays)
                        
                        parent.map.addOverlay(polyline!)
                        if parent.autoCenter || firstTime {
                           
                        let coop = MKCoordinateRegion(center: s1Coord, latitudinalMeters: 10000, longitudinalMeters: 10000)
                            parent.source = s1Coord
                            parent.map.setRegion(coop, animated: true)
                        }
                    }
                    
                    parent.map.removeAnnotations(parent.map.annotations)
                  
                    parent.map.addAnnotation(point)
                }
                
            }
          
            func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
   
                let over = MKPolylineRenderer(overlay: overlay)
                over.strokeColor = .systemPink
                over.lineWidth = 3
                return over
            }
        }
    }


    class observer : ObservableObject {
        let db = Firestore.firestore()
        @Published var data = [String : Any](){
            didSet {
                
                self.objectWillChange.send()
            }
        }
        @Published var baeOnline = false
        @Published var listner: ListenerRegistration? {
            didSet {
                print("listener set to nil")
                self.objectWillChange.send()
            }
        }
        @Published var lastBaeOnline: Int64 = 132 {
            willSet{
                self.objectWillChange.send()
            }
        }
        @Published var timeSinceBaeOnline : Int64 = 132 {
            willSet{
                self.objectWillChange.send()
            }
        }
        var myUID: String
        var baeUID: String
        var couplesDocID: String
        deinit {
            print("Mapview deinit")
            self.listner = nil
        }
        init(couplesDoc: String, myUID : String, baeUID: String) {
            print("Mapview init")
            self.couplesDocID = couplesDoc
            self.myUID = myUID
            self.baeUID = baeUID
        
            listner = db.collection("CouplesLinked").document(couplesDoc).collection("Location").document("shared").addSnapshotListener { [weak self] (snap, err) in
                print("changed DB")
                if err != nil{

                    print((err?.localizedDescription)!)
                    return
                }
                
                guard let updates = snap?.get("geoPoints") as? [String : GeoPoint] else {
                    return
                }

                self?.data["data"] = updates
                guard let baeLastOnline = snap?.get("lastOnline") as? [String: FirebaseFirestore.Timestamp] else {
                    print("Cannot get date")
                    return
                }
              
                let lastBaeOnline = baeLastOnline[baeUID]!.seconds
         
                self?.lastBaeOnline = lastBaeOnline
                if updates[baeUID] == nil {
                    self?.baeOnline = false
                } else {
                    self?.baeOnline = true
                }
               

            }
        }
    }

}



