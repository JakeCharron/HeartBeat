//
//  TableViewController.swift
//  HeartBeat
//
//  Created by JakeDev on 10/2/18.
//  Copyright © 2018 Jake Charron. All rights reserved.
//

import Firebase
import UIKit
import MapKit

class aedInfo: UIViewController, MKMapViewDelegate {
    
    var selectedAed = ""
    
    var aedDes = ""
    
    var aedTime = 0
    
    var isAed = false
    
    var mainInfoAed = aedPin()
    
    var aedCoord = CLLocationCoordinate2D()
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var infoAed: UILabel!
    @IBOutlet weak var aedTitle: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBAction func goToMaps(_ sender: Any) {
        
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: mainInfoAed.coordinate, addressDictionary:nil))
        
        mapItem.name = selectedAed
        
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if (isAed != true){
            print(isAed, " = isAed")
            print("Selected Aed: ", selectedAed)
            print(aedDes)
            
            mapView.showsUserLocation = true
            
            mapView.addAnnotation(self.mainInfoAed)
            
            aedTitle.text = mainInfoAed.title
            
//            aedTime = "\(time), mins"
            
            timeLabel.text = String(aedTime)
            
            infoAed.text = aedDes
            
            mapView.setCenter(mainInfoAed.coordinate, animated: false)
    
            let region = MKCoordinateRegion(center: mapView.userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            
            mapView.setRegion(region, animated: true)

            zoomToFitMapAnnotations(mapView: mapView)
            
        }else{
            
            print(isAed, " = isAed")
            
            print("no aed")
            
        }
        
        mapView.addAnnotation(self.mainInfoAed)

    }
    
    func zoomToFitMapAnnotations(mapView: MKMapView) {
        guard mapView.annotations.count > 0 else {
            return
        }
        var topLeftCoord: CLLocationCoordinate2D = CLLocationCoordinate2D()
        
        topLeftCoord.latitude = -90
        topLeftCoord.longitude = 180
        
        var bottomRightCoord: CLLocationCoordinate2D = CLLocationCoordinate2D()
        
        bottomRightCoord.latitude = 90
        bottomRightCoord.longitude = -180
        
        for annotation: MKAnnotation in mapView.annotations{
            topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude)
            topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude)
            bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude)
            bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude)
        }
        
        var region: MKCoordinateRegion = MKCoordinateRegion()
        region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5
        region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5
        region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.4
        region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.4
        region = mapView.regionThatFits(region)
        mapView.setRegion(region, animated: true)
    }
    
    
    
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        let renderer = MKPolylineRenderer(overlay: overlay)
        
        renderer.strokeColor = UIColor(red: 17.0/255.0, green: 147.0/255.0, blue: 255.0/255.0, alpha: 1)
        
        renderer.lineWidth = 5.0
        
        return renderer
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        
        let vc = segue.destination as? MainView
        
        
        if segue.destination is aedInfo{
            
            vc?.shown = true
            
        }
            
    }
    
    
class aedPin: NSObject, MKAnnotation
{
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var des : String?
    init(pinTitle:String, pinSubTitle:String, location:CLLocationCoordinate2D){
        self.title = pinTitle
        self.subtitle = pinSubTitle
        self.coordinate = location
        
    }
    override init() {
        self.title = nil
        self.subtitle = nil
        self.coordinate = CLLocationCoordinate2D()
        self.des = nil
    }
    func renameSubTitle(newSubtitle: String){
        self.subtitle = newSubtitle
    }
    
    func getLat() -> CLLocationDegrees{
        return coordinate.latitude
    }
    
    func getLong() -> CLLocationDegrees{
        return coordinate.longitude
    }
    
    func getCoordinate() -> CLLocationCoordinate2D{
        return coordinate
    }
    
    func getTitle() -> String{
        return title!
    }
    
    func copyAed(pin: aedPin){
        self.coordinate = pin.coordinate
        self.title = pin.title
        self.des = pin.des
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
        
        init(pinTitle:String, pinSubTitle:String, location:CLLocationCoordinate2D, description:String){
            self.title = pinTitle
            self.subtitle = pinSubTitle
            self.coordinate = location
            self.des = description
        }
        
    }
    
    }
}

//
//func showRouteOnMap(pickupCoordinate: CLLocationCoordinate2D, destinationCoordinate: CLLocationCoordinate2D) {
//
//    let sourcePlacemark = MKPlacemark(coordinate: pickupCoordinate, addressDictionary: nil)
//    let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate, addressDictionary: nil)
//
//    let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
//    let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
//
//    let sourceAnnotation = MKPointAnnotation()
//
//    if let location = sourcePlacemark.location {
//        sourceAnnotation.coordinate = location.coordinate
//    }
//
//    let destinationAnnotation = MKPointAnnotation()
//
//    if let location = destinationPlacemark.location {
//        destinationAnnotation.coordinate = location.coordinate
//    }
//
//    self.mapView.showAnnotations([sourceAnnotation,destinationAnnotation], animated: true )
//
//    let directionRequest = MKDirections.Request()
//    directionRequest.source = sourceMapItem
//    directionRequest.destination = destinationMapItem
//    directionRequest.transportType = .automobile
//
//
//    // Calculate the direction
//    let directions = MKDirections(request: directionRequest)
//
//    directions.calculate {
//        (response, error) -> Void in
//
//        guard let response = response else {
//            if let error = error {
//                print("Error: \(error)")
//            }
//
//            return
//        }
//
//        let route = response.routes[0]
//
//        self.mapView.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)
//
//        let rect = route.polyline.boundingMapRect
//        self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
//    }
//}
