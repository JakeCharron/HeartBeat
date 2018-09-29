//
//  MainView.swift
//  HeartBeat
//
//  Created by JakeDev on 9/9/18.
//  Copyright © 2018 Jake Charron. All rights reserved.
//
import UIKit
import MapKit
import CoreLocation
import Firebase
class MainView: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate{
    
    var locationManager = CLLocationManager()
    var zoomSet = 0
    let regionRadius: CLLocationDistance = 2500
    
    var name = NSString()
    var long = NSNumber()
    var lat = NSNumber()
    
    var aedDict = NSMutableDictionary()
    
    @IBOutlet weak var map: MKMapView!
    
    @IBAction func goToAed(_ sender: Any){
        var current = map.selectedAnnotations[0]
        print("Current: ", current.title as Any)
        let coordinate = CLLocationCoordinate2D(latitude: current.coordinate.latitude , longitude: current.coordinate.longitude)
            let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate, addressDictionary:nil))
            mapItem.name = current.title!
            mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }

    @IBAction func goHome(_ sender: Any){
        let region = MKCoordinateRegion(center: map.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        map.setRegion(region, animated: true)
    }
    
    override func viewDidLoad(){
        
        super.viewDidLoad()
        
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
                let newAedPin = aedPin(pinTitle: newName as! String, pinSubTitle: "", location: newCoordinate)
                self.map.addAnnotation(newAedPin)
                self.requestDirections(aedPin: newAedPin)
                
                counter += 1

            }
            
        }
        
        map.delegate = self
        locationManager.delegate = self
        map.showsUserLocation = true
        map.isRotateEnabled = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        
        DispatchQueue.main.async {
            if CLLocationManager.authorizationStatus() == .authorizedWhenInUse{
                self.locationManager.startUpdatingLocation()
            }
            else{
                self.locationManager.requestWhenInUseAuthorization()
            }
        }
        
        }
    
    
    
    func createPin(title: NSString, latt: Double, longg: Double){
        print("Called: Current Pin \(title)")
        let newTitle : String = title as String
        let newLat : Double = latt
        let newLong : Double = longg
        let newCoordinate = CLLocationCoordinate2D(latitude: newLat , longitude: newLong )
        let newAedPin = aedPin(pinTitle: newTitle, pinSubTitle: "", location: newCoordinate)
        self.map.addAnnotation(newAedPin)
        self.requestDirections(aedPin: newAedPin)
    }
    
    
    
    
    func goToMap(mapItemName: String, pin: aedPin){
        let placemark : MKPlacemark = MKPlacemark(coordinate: pin.getCoordinate(), addressDictionary:nil)
        let mapItem:MKMapItem = MKMapItem(placemark: placemark)
        mapItem.name = mapItemName
        mapItem.openInMaps(launchOptions: nil)
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let region = MKCoordinateRegion(center:  map.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        map.setRegion(region, animated: true)
        map.setRegion(region, animated: true)
        locationManager.stopUpdatingLocation()
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
                aedPin.renameSubTitle(newSubtitle: "\(routeMins) Mins Away")
                self.map.addAnnotation(aedPin)
                self.map.addOverlay(route.polyline)
                self.map.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
            }
        }
    }
    
    
}

class aedPin: NSObject, MKAnnotation
{
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(pinTitle:String, pinSubTitle:String, location:CLLocationCoordinate2D)
    {
        self.title = pinTitle
        self.subtitle = pinSubTitle
        self.coordinate = location
        
    }
    
    func renameSubTitle(newSubtitle: String)
    {
        self.subtitle = newSubtitle
    }
    
    func getLat() -> CLLocationDegrees
    {
        return coordinate.latitude
    }
    
    func getLong() -> CLLocationDegrees
    {
        return coordinate.longitude
    }
    func getCoordinate() -> CLLocationCoordinate2D{
        return coordinate
    }
    func getTitle() -> String{
        return title!
    }
}

//                ref.child("aeds").child("/\(counter)").observe(.value) { (snapshot) in
//                    print("Snapshot", snapshot.childSnapshot(forPath: "<#T##String#>") as Any)
//                    if snapshot.key == ("lat"){
//                        self.lat = snapshot.value as! NSNumber
//                    }
//                    if snapshot.key == ("long"){
//                        self.long = snapshot.value as! NSNumber
//                    }
//                    if snapshot.key == ("name"){
//                        self.name = snapshot.value as! NSString
//                    }
//                    print("Called")
//
//                    self.createPin(title: self.name, latt: Double( truncating: self.lat), longg: Double( truncating: self.long))
//
//                    print("Checking Vars \n", "Name: \n", self.name, "Lat: \n", self.lat, "Long: ", self.long)
//                    print("Counting")
//                }
