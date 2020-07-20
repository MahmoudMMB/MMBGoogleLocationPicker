//
//  ViewController.swift
//  LocationPickerExample
//
//  Created by Jerome Tan on 3/29/16.
//  Copyright © 2016 Jerome Tan. All rights reserved.
//

import UIKit
import MMBGoogleLocationPicker
import MapKit

class ViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func presentLocationPickerButtonDidTap(button: UIButton) {
        LocationPicker.GMSServicesKey = "Your_Goole_map_key"
        LocationPicker.GMSPlacesClientKey = "Your_Goole_map_key"
        let locationPicker = LocationPicker.shared
        locationPicker.pickCompletion = { (pickedLocationItem) in
            if let coordinate = pickedLocationItem.coordinate {
                debugPrint("Picked location is (latitude: \(coordinate.latitude), longitude: \(coordinate.longitude))")
                self.mapView.removeAnnotations(self.mapView.annotations)
                let marker = MKPointAnnotation.init()
                marker.coordinate = coordinate
                self.mapView.addAnnotation(marker)
                self.mapView.showAnnotations(self.mapView.annotations, animated: true)
            }
        }
        locationPicker.addBarButtons()
        let navigationController = UINavigationController(rootViewController: locationPicker)
        navigationController.navigationBar.isTranslucent = false
        navigationController.navigationBar.tintColor = .white
        navigationController.navigationBar.barTintColor = #colorLiteral(red: 0.2588235294, green: 0.4039215686, blue: 0.6980392157, alpha: 1)
        navigationController.view.backgroundColor = #colorLiteral(red: 0.2588235294, green: 0.4039215686, blue: 0.6980392157, alpha: 1)
        navigationController.viewControllers.first?.view.backgroundColor = #colorLiteral(red: 0.2588235294, green: 0.4039215686, blue: 0.6980392157, alpha: 1)
        present(navigationController, animated: true, completion: nil)
    }
}
