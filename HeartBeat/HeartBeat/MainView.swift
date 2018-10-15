//
//  MainView.swift
//  HeartBeat
//
//  Created by Jake Charron and Jordan Schmidt on 9/9/18.
//  Copyright © 2018 Jake Charron and Jordan Schmidt. All rights reserved.
//
import UIKit
import MapKit
import CoreLocation
import Firebase

class MainView: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate{
    
    var locationManager = CLLocationManager()
    var zoomSet = 0
    let regionRadius: CLLocationDistance = 2500
    
    var shown = false
    var aedTitle = String()
    var aedCoord = CLLocationCoordinate2D()
    var aedDes = ""
    
    var name = NSString()
    var long = NSNumber()
    var lat = NSNumber()
    
    var noSelectedAed = false
    
    var emptyCoord = CLLocationCoordinate2D()
    
    var aedDict = NSMutableDictionary()
    
    @IBOutlet weak var map: MKMapView!
    
    @IBAction func goToAed(_ sender: Any){
        if (map.selectedAnnotations.isEmpty){
        
            print("map is empty", map.selectedAnnotations)
            
        }else{
            
            print("map is not empty", map.annotations)
            
            let current = map.selectedAnnotations[0]
            
            print("Current: ", current.title as Any)
            
            let coordinate = CLLocationCoordinate2D(latitude: current.coordinate.latitude , longitude: current.coordinate.longitude)
            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
            
            mapItem.name = current.title!
            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
            
        }
    }

    @IBAction func goHome(_ sender: Any){
        
        let region = MKCoordinateRegion(center: map.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        map.setRegion(region, animated: true)
        
    }
    
    let locManger  = CLLocationManager()
    
    override func viewDidLoad(){
        
        super.viewDidLoad()
        if shown == false{
            let url:NSURL = NSURL(string: "telprompt://911")!
            UIApplication.shared.openURL(url as URL)
        }
        self.locManger.startUpdatingLocation()

        
        if (noSelectedAed != true){
            var ref: DatabaseReference!
            ref = Database.database().reference()
            ref.child("aeds").observeSingleEvent(of: .value) { (snapshot) in
                
                var counter = 1
                
                while (counter <= snapshot.childrenCount){
                    
                    let newSnap = snapshot.childSnapshot(forPath: "\(counter)")
            
                    let newLat = newSnap.childSnapshot(forPath: "lat").value
                    let newLong = newSnap.childSnapshot(forPath: "long").value
                    let newName = newSnap.childSnapshot(forPath: "name").value

                    let newCoordinate = CLLocationCoordinate2D(latitude: newLat as! CLLocationDegrees , longitude: newLong as! CLLocationDegrees )
                    
                    let AedPin = aedPin(pinTitle: newName as! String, pinSubTitle: "", location: newCoordinate, description: "")
                    
                    self.map.addAnnotation(AedPin)
                    self.requestDirections(aedPin: AedPin)
                    
                    counter += 1
                }
            }
            
            map.delegate = self
            map.showsUserLocation = true
            map.isRotateEnabled = true
            
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
        
            
        }else{
            let alert = UIAlertController(title: "Info Page", message: "Selected a Aed to see info about it", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            
            self.present(alert, animated: true)
        }
        
        let span = MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        
        let location = CLLocationCoordinate2DMake((self.locManger.location?.coordinate.latitude)!, (self.locManger.location?.coordinate.longitude)!)
        
        let region = MKCoordinateRegion(center: location, span: span)
        
        map.setRegion(region, animated: false)
        
        
        //stop location updating
        self.locManger.stopUpdatingLocation()
    }
    
    
    
    func createPin(title: NSString, latt: Double, longg: Double){
        print("Called: Current Pin \(title)")
        let newTitle : String = title as String
        let newLat : Double = latt
        let newLong : Double = longg
        let newCoordinate = CLLocationCoordinate2D(latitude: newLat , longitude: newLong )
        let newAedPin = aedPin(pinTitle: newTitle, pinSubTitle: "", location: newCoordinate, description: "")
        self.map.addAnnotation(newAedPin)
        self.requestDirections(aedPin: newAedPin)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer
    {
        let polylineRenderer = MKPolylineRenderer(overlay: overlay)
        polylineRenderer.strokeColor = UIColor.darkGray
        polylineRenderer.fillColor = UIColor.darkGray
        polylineRenderer.lineWidth = 4
        return polylineRenderer
    }
    
    func map(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        if annotation is MKUserLocation{return nil}
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "customannotation")
        annotationView.image = UIImage(named: "location")
        annotationView.canShowCallout = true
        return annotationView
    }
    
    func requestDirections(aedPin: aedPin){
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: MKUserLocation().coordinate))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: aedPin.coordinate))
        request.requestsAlternateRoutes = false
        request.transportType = .automobile
        let directions = MKDirections(request: request)
        directions.calculate{ [unowned self] response, error in
            guard let unwrappedResponse = response else { return }
            for route in unwrappedResponse.routes{
                let routeMins = Int(route.expectedTravelTime)/60
                print("\(routeMins/60) mins away ")
                self.map.addAnnotation(aedPin)
                self.map.addOverlay(route.polyline)
                self.map.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let region = MKCoordinateRegion(center:  map.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        map.setRegion(region, animated: true)
        map.setRegion(region, animated: true)
        locationManager.stopUpdatingLocation()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        
        print("switching to aedINfo")
        let vc = segue.destination as? aedInfo
        print("made vc Var ", vc as Any)
        if segue.destination is aedInfo{
            
            let current = self.map.selectedAnnotations[0]
            if current.title != ""{
                
                print("Current Aed: ", current.title as Any)
                let currentPin = aedPin()
                
                currentPin.coordinate = current.coordinate
                currentPin.title = current.title ?? "currenttitle not available"
                
                print(self.aedTitle)
                vc?.selectedAed = currentPin.title ?? "notSelected"
                
                print(self.aedDes)
                vc?.aedDes = currentPin.des ?? "no title"
                
                var currentDes = String()
                
                var ref: DatabaseReference!
                ref = Database.database().reference()
                print("database made")
                ref.child("aeds").observeSingleEvent(of: .value) { (snapshot) in
                    
                    var counter = 1
                    
                    while (counter <= snapshot.childrenCount){
                        print("While loop engaged")
                        let newSnap = snapshot.childSnapshot(forPath: "\(counter)")
                        
                        if ((newSnap.childSnapshot(forPath: "name").value as! String).uppercased() == (current.title as! String).uppercased()){
                            
                            currentDes = newSnap.childSnapshot(forPath: "des").value as! String
                            vc?.aedDes = (currentDes as String)
                            print("Current Description: ", currentDes.uppercased())
                        }
                        
                        
                        counter += 1
                    }
                    
                }
                print("vc aed props and aedDes Vars set to mainview vars")
                vc?.mainInfoAed.coordinate = current.coordinate
                vc?.mainInfoAed.title = current.title ?? ""
                vc?.aedDes = currentDes
                print("variables made")
            }
            
        }
        
    }


class aedPin: NSObject, MKAnnotation{
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var des : String?
    override init() {
        self.title = nil
        self.subtitle = nil
        self.coordinate = CLLocationCoordinate2D()
        self.des = nil
    }
    init(pinTitle:String, pinSubTitle:String, location:CLLocationCoordinate2D, description:String)
    {
        self.title = pinTitle
        self.subtitle = pinSubTitle
        self.coordinate = location
        self.des = description
    }

}

}
