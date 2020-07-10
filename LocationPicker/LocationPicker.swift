//
//  LocationPicker.swift
//  LocationPicker
//
//  Created by Jerome Tan on 3/28/16.
//
//  The MIT License (MIT)
//
//  Copyright (c) 2016 Jerome Tan
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import UIKit
import GoogleMaps
import GooglePlaces
import MapKit

open class LocationPicker: UIViewController, UIGestureRecognizerDelegate {
    public static var shared: LocationPicker {
        return LocationPicker.init(nibName: "LocationPicker", bundle: Bundle.init(for: LocationPicker.self))
    }
    // MARK: Types
    public static var googleMapKey: String = "" {
        willSet {
            GMSServices.provideAPIKey(newValue)
            GMSPlacesClient.provideAPIKey(newValue)
        }
    }
    // MARK: Types
    
    public enum NavigationItemOrientation {
        case left
        case right
    }
    
    public enum LocationType: Int {
        case currentLocation
        case searchLocation
        case alternativeLocation
    }
    
    
    // MARK: - Completion closures
    
    /**
     Completion closure executed after everytime user select a location.
     
     - important:
     If you override `func locationDidSelect(locationItem: LocationItem)` without calling `super`, this closure would not be called.
     
     - Note:
     This closure would be executed multiple times, because user may change selection before final decision.
     
     To get user's final decition, use `var pickCompletion` instead.
     
     Alternatively, the same result can be achieved by:
     * Delegate
     1. conform to `protocol LocationPickerDelegate`
     2. set the `var delegate`
     3. implement `func locationDidSelect(locationItem: LocationItem)`
     * Overrride
     1. create a subclass of `class LocationPicker`
     2. override `func locationDidSelect(locationItem: LocationItem)`
     
     - SeeAlso:
     `var pickCompletion: ((LocationItem) -> Void)?`
     
     `func locationDidSelect(locationItem: LocationItem)`
     
     `protocol LocationPickerDelegate`
     */
    open var selectCompletion: ((LocationItem) -> Void)?
    
    /**
     Completion closure executed after user finally pick a location.
     
     - important:
     If you override `func locationDidPick(locationItem: LocationItem)` without calling `super`, this closure would not be called.
     
     - Note:
     This closure would be executed only once in `func viewWillDisappear(animated: Bool)` before this instance of `LocationPicker` dismissed.
     
     To get user's every selection, use `var selectCompletion` instead.
     
     Alternatively, the same result can be achieved by:
     * Delegate
     1. conform to `protocol LocationPickerDelegate`
     2. set the `var delegate`
     3. implement `func locationDidPick(locationItem: LocationItem)`
     * Override
     1. create a subclass of `class LocationPicker`
     2. override `func locationDidPick(locationItem: LocationItem)`
     
     - SeeAlso:
     `var selectCompletion: ((LocationItem) -> Void)?`
     
     `func locationDidPick(locationItem: LocationItem)`
     
     `protocol LocationPickerDelegate`
     */
    open var pickCompletion: ((LocationItem) -> Void)?
    
    /**
     Completion closure executed after user delete an alternative location.
     
     - important:
     If you override `func alternativeLocationDidDelete(locationItem: LocationItem)` without calling `super`, this closure would not be called.
     
     - Note:
     This closure would be executed when user delete a location cell from `tableView`.
     
     User can only delete the location provided in `var alternativeLocations` or `dataSource` method `alternativeLocationAtIndex(index: Int) -> LocationItem`.
     
     Alternatively, the same result can be achieved by:
     * Delegate
     1. conform to `protocol LocationPickerDataSource`
     2. set the `var dataSource`
     3. implement `func commitAlternativeLocationDeletion(locationItem: LocationItem)`
     * Override
     1. create a subclass of `class LocationPicker`
     2. override `func alternativeLocationDidDelete(locationItem: LocationItem)`
     
     - SeeAlso:
     `func alternativeLocationDidDelete(locationItem: LocationItem)`
     
     `protocol LocationPickerDataSource`
     */
    open var deleteCompletion: ((LocationItem) -> Void)?
    
    /**
     Handler closure executed when user try to fetch current location without location access.
     
     - important:
     If you override `func locationDidDeny(LocationPicker: LocationPicker)` without calling `super`, this closure would not be called.
     
     - Note:
     If this neither this closure is not set and the delegate method with the same purpose is not provided, an alert view controller will be presented, you can configure it using `func setLocationDeniedAlertControllerTitle` or provide a fully cutomized `UIAlertController` to `var locationDeniedAlertController`.
     
     Alternatively, the same result can be achieved by:
     * Delegate
     1. conform to `protocol LocationPickerDelegate`
     2. set the `var delegate`
     3. implement `func locationDidDeny(LocationPicker: LocationPicker)`
     * Override
     1. create a subclass of `class LocationPicker`
     2. override `func locationDidDeny(LocationPicker: LocationPicker)`
     
     - SeeAlso:
     `func locationDidDeny(LocationPicker: LocationPicker)`
     
     `protocol LocationPickerDelegate`
     
     `var locationDeniedAlertController`
     
     `func setLocationDeniedAlertControllerTitle`
     
     */
    open var locationDeniedHandler: ((LocationPicker) -> Void)?
    
    
    // MARK: Optional variables
    
    /// Delegate of `protocol LocationPickerDelegate`
    open weak var delegate: LocationPickerDelegate?
    
    /// DataSource of `protocol LocationPickerDataSource`
    open weak var dataSource: LocationPickerDataSource?
    
    /**
     Locations that show in the location list.
     
     - Note:
     Alternatively, `LocationPicker` can obtain locations via DataSource:
     1. conform to `protocol LocationPickerDataSource`
     2. set the `var dataSource`
     3. implement `func numberOfAlternativeLocations() -> Int` to tell the `tableView` how many rows to display
     4. implement `func alternativeLocationAtIndex(index: Int) -> LocationItem`
     
     - SeeAlso:
     `func numberOfAlternativeLocations() -> Int`
     
     `func alternativeLocationAtIndex(index: Int) -> LocationItem`
     
     `protocol LocationPickerDataSource`
     */
    open var alternativeLocations: [LocationItem]?
    
    /**
     Alert Controller shows when user try to fetch current location without location permission.
     
     - Note:
     If you are content with the default alert controller, don't set this property, just change the text in it by calling `func setLocationDeniedAlertControllerTitle` or change the following text directly.
     
     var locationDeniedAlertTitle
     var locationDeniedAlertMessage
     var locationDeniedGrantText
     var locationDeniedCancelText
     
     - SeeAlso:
     `func setLocationDeniedAlertControllerTitle`
     
     `var locationDeniedHandler: ((LocationPicker) -> Void)?`
     
     `func locationDidDeny(LocationPicker: LocationPicker)`
     
     `protocol LocationPickerDelegate`
     */
    open var locationDeniedAlertController: UIAlertController?
    
    // MARK: UI Customizations
    
    /// Text that indicates user's current location. __Default__ is __`"Current Location"`__.
    open var currentLocationText = "Current Location".localized
    
    /// Text of search bar's placeholder. __Default__ is __`"Search for location"`__.
    open var searchBarPlaceholder = "Search for location".localized
    
    /// Text of location denied alert title. __Default__ is __`"Location access denied"`__
    open var locationDeniedAlertTitle = "Location access denied".localized
    
    /// Text of location denied alert message. __Default__ is __`"Grant location access to use current location"`__
    open var locationDeniedAlertMessage = "Grant location access to use current location".localized
    
    /// Text of location denied alert _Grant_ button. __Default__ is __`"Grant"`__
    open var locationDeniedGrantText = "Grant".localized
    
    /// Text of location denied alert _Cancel_ button. __Default__ is __`"Cancel"`__
    open var locationDeniedCancelText = "Cancel".localized
    
    
    /// Longitudinal distance in meters that the map view shows when user select a location and before zoom in or zoom out. __Default__ is __`1000`__.
    open var defaultLongitudinalDistance: Float = 15.0
    
    /// Distance in meters that is used to search locations. __Default__ is __`10000`__
    open var searchDistance: Double = 10000
    
    /// `mapView.scrollEnabled` is set to this property's value after view is loaded. __Default__ is __`true`__
    open var isMapViewScrollEnabled = true
    
    
    open var isForceReverseGeocoding = false
    
    
    /// `tableView.backgroundColor` is set to this property's value afte view is loaded. __Default__ is __`UIColor.whiteColor()`__
    open var tableViewBackgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    
    /// The color of the icon showed in current location cell. __Default__ is __`UIColor(hue: 0.447, saturation: 0.731, brightness: 0.569, alpha: 1)`__
    open var currentLocationIconColor = #colorLiteral(red: 0.1176470588, green: 0.5098039216, blue: 0.3568627451, alpha: 1)
    
    /// The color of the icon showed in search result location cells. __Default__ is __`UIColor(hue: 0.447, saturation: 0.731, brightness: 0.569, alpha: 1)`__
    open var searchResultLocationIconColor = #colorLiteral(red: 0.1176470588, green: 0.5098039216, blue: 0.3568627451, alpha: 1)
    
    /// The color of the icon showed in alternative location cells. __Default__ is __`UIColor(hue: 0.447, saturation: 0.731, brightness: 0.569, alpha: 1)`__
    open var alternativeLocationIconColor = #colorLiteral(red: 0.1176470588, green: 0.5098039216, blue: 0.3568627451, alpha: 1)
    
    /// The color of the pin showed in the center of map view. __Default__ is __`UIColor(hue: 0.447, saturation: 0.731, brightness: 0.569, alpha: 1)`__
    open var pinColor = #colorLiteral(red: 0.1176470588, green: 0.5098039216, blue: 0.3568627451, alpha: 1)
    
    /// The color of primary text color. __Default__ is __`UIColor(colorLiteralRed: 0.34902, green: 0.384314, blue: 0.427451, alpha: 1)`__
    open var primaryTextColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    
    /// The color of secondary text color. __Default__ is __`UIColor(colorLiteralRed: 0.541176, green: 0.568627, blue: 0.584314, alpha: 1)`__
    open var secondaryTextColor = #colorLiteral(red: 0.541176, green: 0.568627, blue: 0.584314, alpha: 1)
    
    
    /// The image of the icon showed in current location cell. If this property is set, the `var currentLocationIconColor` won't be adopted.
    open var currentLocationIcon: UIImage? = nil
    
    /// The image of the icon showed in search result location cells. If this property is set, the `var searchResultLocationIconColor` won't be adopted.
    open var searchResultLocationIcon: UIImage? = nil
    
    /// The image of the icon showed in alternative location cells. If this property is set, the `var alternativeLocationIconColor` won't be adopted.
    open var alternativeLocationIcon: UIImage? = nil
    
    /// The image of the pin showed in the center of map view. If this property is set, the `var pinColor` won't be adopted.
    open var pinImage: UIImage? = nil
    
    /// The size of the pin's shadow. Set this value to zero to hide the shadow. __Default__ is __`5`__
    open var pinShadowViewDiameter: CGFloat = 5
    
    // MARK: - UI Elements
    
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet var contentView: UIView!
    
    public var resultsViewController: GMSAutocompleteResultsViewController?
    public var searchController: UISearchController?
    public var resultView: UITextView?
    //    public var mapView = GMSMapView()
    public let pinView = UIImageView()
    public let pinShadowView = UIView()
    //    public var contentView = UIView()
    
    open private(set) var barButtonItems: (doneButtonItem: UIBarButtonItem, cancelButtonItem: UIBarButtonItem)?
    
    
    // MARK: Attributes
    
    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()
    
    private var selectedLocationItem: LocationItem?
    private var searchResultLocations = [LocationItem]()
    
    private var alternativeLocationCount: Int {
        return alternativeLocations?.count ?? dataSource?.numberOfAlternativeLocations() ?? 0
    }
    
    
    /// This property is used to record the longitudinal distance of the map view. This is neccessary because when user zoom in or zoom out the map view, func showMapViewWithCenterCoordinate(coordinate: CLLocationCoordinate2D, WithDistance distance: Double) will reset the region of the map view.
    open var longitudinalDistance: Float = 15.0
    
    
    /// This property is used to record whether the map view center changes. This is neccessary because private func showMapViewWithCenterCoordinate(coordinate: CLLocationCoordinate2D, WithDistance distance: Double) would trigger func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) which calls func reverseGeocodeLocation(location: CLLocation), and this method calls private func showMapViewWithCenterCoordinate(coordinate: CLLocationCoordinate2D, WithDistance distance: Double) back, this would lead to an infinite loop.
    open var isMapViewCenterChanged = false
    
    private var mapViewHeightConstraint: NSLayoutConstraint!
    private var mapViewHeight: CGFloat {
        return view.frame.height * 0.65
    }
    
    private var pinViewCenterYConstraint: NSLayoutConstraint!
    private var pinViewImageHeight: CGFloat {
        return pinView.image!.size.height
    }
    
    
    // MARK: Customs
    
    /**
     Add two bar buttons that confirm and cancel user's location pick.
     
     - important:
     If this method is called, only when user tap done button can the pick closure, method and delegate method be called.
     If you don't provide `UIBarButtonItem` object, default system style bar button will be used.
     
     - Note:
     You don't need to set the `target` and `action` property of the buttons, `LocationPicker` will handle the dismission of this view controller.
     
     - parameter doneButtonItem:      An `UIBarButtonItem` tapped to confirm selection, default is a _Done_ `barButtonSystemItem`
     - parameter cancelButtonItem:    An `UIBarButtonITem` tapped to cancel selection, default is a _Cancel_ `barButtonSystemItem`
     - parameter doneButtonOrientation: The direction of the done button, default is `.Right`
     */
    public func addBarButtons(doneButtonItem: UIBarButtonItem? = nil,
                              cancelButtonItem: UIBarButtonItem? = nil,
                              doneButtonOrientation: NavigationItemOrientation = .right) {
        let doneButtonItem = doneButtonItem ?? UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
        doneButtonItem.isEnabled = false
        doneButtonItem.target = self
        doneButtonItem.setTitleTextAttributes([NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17)], for: .normal)
        doneButtonItem.action = #selector(doneButtonDidTap(barButtonItem:))
        
        let cancelButtonItem = cancelButtonItem ?? UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: nil)
        cancelButtonItem.target = self
        cancelButtonItem.setTitleTextAttributes([NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 17)], for: .normal)
        cancelButtonItem.action = #selector(cancelButtonDidTap(barButtonItem:))
        
        switch doneButtonOrientation {
        case .right:
            navigationItem.leftBarButtonItem = cancelButtonItem
            navigationItem.rightBarButtonItem = doneButtonItem
        case .left:
            navigationItem.leftBarButtonItem = doneButtonItem
            navigationItem.rightBarButtonItem = cancelButtonItem
        }
        
        barButtonItems = (doneButtonItem, cancelButtonItem)
    }
    
    /**
     If you are content with the icons provided in `LocaitonPicker` but not with the colors, you can change them by calling this method.
     
     This mehod can also change the color of text color all over the UI.
     
     - Note:
     You can set the color of three icons and the pin in map view by setting the attributes listed below, but to keep the UI consistent, this is not recommanded.
     
     var currentLocationIconColor
     var searchResultLocationIconColor
     var alternativeLocationIconColor
     var pinColor
     
     If you are not satisified with the shape of icons and pin image, you can change them by setting the attributes below.
     
     var currentLocationIconImage
     var searchResultLocationIconImage
     var alternativeLocationIconImage
     var pinImage
     
     - parameter themeColor:         The color of all icons
     - parameter primaryTextColor:   The color of primary text
     - parameter secondaryTextColor: The color of secondary text
     */
    public func setColors(themeColor: UIColor? = nil, primaryTextColor: UIColor? = nil, secondaryTextColor: UIColor? = nil) {
        self.currentLocationIconColor = themeColor ?? self.currentLocationIconColor
        self.searchResultLocationIconColor = themeColor ?? self.searchResultLocationIconColor
        self.alternativeLocationIconColor = themeColor ?? self.alternativeLocationIconColor
        self.pinColor = themeColor ?? self.pinColor
        self.primaryTextColor = primaryTextColor ?? self.primaryTextColor
        self.secondaryTextColor = secondaryTextColor ?? self.secondaryTextColor
    }
    
    /**
     Set text of alert controller presented when user try to get current location but denied app's authorization.
     
     If you are content with the default alert controller provided by `LocationPicker`, just call this method to change the alert text to your any language you like.
     
     - Note:
     If you are not satisfied with the default alert controller, just set `var locationDeniedAlertController` to your fully customized alert controller. If you don't want to present an alert controller at all in such situation, you can customize the behavior of `LocationPicker` by setting closure, using delegate or overriding.
     
     - parameter title:      Text of location denied alert title
     - parameter message:    Text of location denied alert message
     - parameter grantText:  Text of location denied alert _Grant_ button text
     - parameter cancelText: Text of location denied alert _Cancel_ button text
     */
    public func setLocationDeniedAlertControllerTexts(title: String? = nil, message: String? = nil, grantText: String? = nil, cancelText: String? = nil) {
        self.locationDeniedAlertTitle = title ?? self.locationDeniedAlertTitle
        self.locationDeniedAlertMessage = message ?? self.locationDeniedAlertMessage
        self.locationDeniedGrantText = grantText ?? self.locationDeniedGrantText
        self.locationDeniedCancelText = cancelText ?? self.locationDeniedCancelText
    }
    
    
    /**
     Decide if an item from MKLocalSearch should be displayed or not
     
     - parameter locationItem:      An instance of `LocationItem`
     */
    open func shouldShowSearchResult(for mapItem: MKMapItem) -> Bool {
        return true
    }
    
    
    // MARK: - View Controller
    
    // MARK: - View Controller
    open override func viewDidLoad() {
        super.viewDidLoad()
        resultsViewController = GMSAutocompleteResultsViewController()
        resultsViewController?.delegate = self
        
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController
        
        // Put the search bar in the navigation bar.
        searchController?.searchBar.sizeToFit()
        navigationItem.titleView = searchController?.searchBar
        
        // When UISearchController presents the results view, present it in
        // this view controller, not one further up the chain.
        definesPresentationContext = true
        
        // Prevent the navigation bar from being hidden when searching.
        searchController?.hidesNavigationBarDuringPresentation = false
        
        setupLocationManager()
        setupViews()
        layoutViews()
        setupCurrentLocation()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pinShadowView.center = self.view.center
        pinView.center = self.view.center
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        guard barButtonItems?.doneButtonItem == nil else { return }
        
        if let locationItem = selectedLocationItem {
            locationDidPick(locationItem: locationItem)
        }
    }
    
    
    // MARK: Initializations
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10
        if #available(iOS 9.0, *) {
            locationManager.requestLocation()
        } else {
            locationManager.startUpdatingLocation()
        }
    }
    
    private func centerMapOnLocation(location: CLLocation) {
        let regionRadius: CLLocationDistance = 500
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude, longitude: location.coordinate.longitude, zoom: defaultLongitudinalDistance)
        self.mapView.camera = camera
    }
    
    private func setupCurrentLocation() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied:
            locationDidDeny(locationPicker: self)
        default:
            break
        }
        
        if let currentLocation = locationManager.location {
            reverseGeocodeLocation(currentLocation)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                self.centerMapOnLocation(location: currentLocation)
            }
        }
    }
    
    private func setupViews() {
        view.backgroundColor = #colorLiteral(red: 0.07058823529, green: 0.4941176471, blue: 0.7960784314, alpha: 1)
        mapView.delegate = self
        
        pinView.image = pinImage ?? StyleKit.imageOfPinIconFilled(color: pinColor)
        
        pinShadowView.layer.cornerRadius = pinShadowViewDiameter / 2
        pinShadowView.clipsToBounds = false
        pinShadowView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.8)
        pinShadowView.layer.shadowColor = UIColor.black.cgColor
        pinShadowView.layer.shadowOffset = CGSize(width: 0, height: 0)
        pinShadowView.layer.shadowRadius = 2
        pinShadowView.layer.shadowOpacity = 1
        
        if isMapViewScrollEnabled {
            let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureInMapViewDidRecognize(panGestureRecognizer:)))
            panGestureRecognizer.delegate = self
            mapView.addGestureRecognizer(panGestureRecognizer)
        }
        
        view.addSubview(pinShadowView)
        view.addSubview(pinView)
        //        mapView.frame = CGRect.init(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        //        view.addSubview(mapView)
    }
    
    private func layoutViews() {
        mapView.translatesAutoresizingMaskIntoConstraints = false
        pinView.translatesAutoresizingMaskIntoConstraints = false
        pinShadowView.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 9.0, *) {
            //            mapView.topAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
            //            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            //            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
            //            mapView.bottomAnchor.constraint(equalTo: view.topAnchor).isActive = true
            
            //            mapViewHeightConstraint = mapView.heightAnchor.constraint(equalToConstant: view.frame.height * 0.65)
            //            mapViewHeightConstraint.isActive = true
            
            pinView.centerXAnchor.constraint(equalTo: mapView.centerXAnchor).isActive = true
            pinViewCenterYConstraint = pinView.centerYAnchor.constraint(equalTo: mapView.centerYAnchor, constant: -pinViewImageHeight / 2)
            pinViewCenterYConstraint.isActive = true
            
            pinShadowView.centerXAnchor.constraint(equalTo: mapView.centerXAnchor).isActive = true
            pinShadowView.centerYAnchor.constraint(equalTo: mapView.centerYAnchor).isActive = true
            pinShadowView.widthAnchor.constraint(equalToConstant: pinShadowViewDiameter).isActive = true
            pinShadowView.heightAnchor.constraint(equalToConstant: pinShadowViewDiameter).isActive = true
            
        } else {
            
            //            NSLayoutConstraint(item: mapView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
            //            NSLayoutConstraint(item: mapView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0).isActive = true
            //            NSLayoutConstraint(item: mapView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
            //            NSLayoutConstraint(item: mapView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0).isActive = true
            
            //            mapViewHeightConstraint = NSLayoutConstraint(item: mapView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: view.frame.height * 0.65)
            //            mapViewHeightConstraint.isActive = true
            
            NSLayoutConstraint(item: pinView, attribute: .centerX, relatedBy: .equal, toItem: mapView, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
            pinViewCenterYConstraint = NSLayoutConstraint(item: pinView, attribute: .centerY, relatedBy: .equal, toItem: mapView, attribute: .centerY, multiplier: 1, constant: -pinViewImageHeight / 2)
            pinViewCenterYConstraint.isActive = true
            
            NSLayoutConstraint(item: pinShadowView, attribute: .centerX, relatedBy: .equal, toItem: mapView, attribute: .centerX, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: pinShadowView, attribute: .centerY, relatedBy: .equal, toItem: mapView, attribute: .centerY, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: pinShadowView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: pinShadowViewDiameter).isActive = true
            NSLayoutConstraint(item: pinShadowView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: pinShadowViewDiameter).isActive = true
        }
    }
    
    
    // MARK: Gesture Recognizer
    
    @objc func panGestureInMapViewDidRecognize(panGestureRecognizer: UIPanGestureRecognizer) {
        switch(panGestureRecognizer.state) {
        case .began:
            break
        case .ended:
            isMapViewCenterChanged = true
            selectedLocationItem = nil
            geocoder.cancelGeocode()
            
            resultView?.text = nil
            if let doneButtonItem = barButtonItems?.doneButtonItem {
                doneButtonItem.isEnabled = false
            }
        default:
            break
        }
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
    // MARK: Buttons
    
    @objc private func doneButtonDidTap(barButtonItem: UIBarButtonItem) {
        if let locationItem = selectedLocationItem {
            dismiss(animated: true, completion: nil)
            locationDidPick(locationItem: locationItem)
        }
    }
    
    @objc private func cancelButtonDidTap(barButtonItem: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: UI Mainipulations
    private func showMapView(withCenter coordinate: CLLocationCoordinate2D, distance: Float) {
        //        mapViewHeightConstraint.constant = mapViewHeight
        DispatchQueue.main.async {
            let camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude, longitude: coordinate.longitude, zoom: distance)
            if let map =  self.mapView {
                map.animate(to: camera)
            }
        }
    }
    
    private func closeMapView() {
        //        mapViewHeightConstraint.constant = 0
    }
    
    
    // MARK: Location Handlers
    
    /**
     Set the given LocationItem as the currently selected one. This will update the searchBar and show the map if possible.
     
     - parameter locationItem:      An instance of `LocationItem`
     */
    public func selectLocationItem(_ locationItem: LocationItem) {
        selectedLocationItem = locationItem
        resultView?.text = locationItem.name
        if let coordinate = locationItem.coordinate {
            showMapView(withCenter: coordinate, distance: longitudinalDistance)
        } else {
            closeMapView()
        }
        
        barButtonItems?.doneButtonItem.isEnabled = true
        locationDidSelect(locationItem: locationItem)
    }
    
    private func reverseGeocodeLocation(_ location: CLLocation) {
        let placeName = GMSGeocoder()
        
        let selectedLocation = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        placeName.reverseGeocodeCoordinate(selectedLocation) { response, error in
            guard let address = response?.firstResult(), let lines = address.lines else {
                let mapItem = LocationItem.init(coordinate: location.coordinate, place: nil, address: "\(location.coordinate.latitude),\(location.coordinate.longitude)")
                self.selectLocationItem(mapItem)
                return
            }
            let addressLabel = lines.joined(separator: "\n")
            print(addressLabel)
            let mapItem = LocationItem.init(coordinate: location.coordinate, place: nil, address: addressLabel)
            self.selectLocationItem(mapItem)
        }
        
        
        //        geocoder.cancelGeocode()
        //        geocoder.reverseGeocodeLocation(location, completionHandler: { (placemarks, error) -> Void in
        //            guard error == nil else {
        //                print(error!)
        //                return
        //            }
        //            guard let placemarks = placemarks else { return }
        //            var placemark = placemarks[0]
        //            if !self.isRedirectToExactCoordinate {
        //                placemark = MKPlacemark(coordinate: location.coordinate, addressDictionary: placemark.addressDictionary as? [String : NSObject])
        //            }
        //            if !(self.resultView?.isFirstResponder ?? true) {
        //                let mapItem = LocationItem.init
        //                self.selectLocationItem(LocationItem(mapItem: mapItem))
        //            }
        //        })
    }
    
}


// MARK: - Callbacks

extension LocationPicker {
    
    /**
     This method would be called everytime user select a location including the change of region of the map view.
     
     - important:
     This method includes the following codes:
     
     selectCompletion?(locationItem)
     delegate?.locationDidSelect?(locationItem)
     
     So, if you override it without calling `super.locationDidSelect(locationItem)`, completion closure and delegate method would not be called.
     
     - Note:
     This method would be called multiple times, because user may change selection before final decision.
     
     To do something with user's final decition, use `func locationDidPick(locationItem: LocationItem)` instead.
     
     Alternatively, the same result can be achieved by:
     * Closure
     1. set `var selectCompletion`
     * Delegate
     1. conform to `protocol LocationPickerDelegate`
     2. set the `var delegate`
     3. implement `func locationDidPick(locationItem: LocationItem)`
     
     - SeeAlso:
     `var selectCompletion: ((LocationItem) -> Void)?`
     
     `func locationDidPick(locationItem: LocationItem)`
     
     `protocol LocationPickerDelegate`
     
     - parameter locationItem: The location item user selected
     */
    @objc open func locationDidSelect(locationItem: LocationItem) {
        selectCompletion?(locationItem)
        delegate?.locationDidSelect?(locationItem: locationItem)
    }
    
    /**
     This method would be called after user finally pick a location.
     
     - important:
     This method includes the following codes:
     
     pickCompletion?(locationItem)
     delegate?.locationDidPick?(locationItem)
     
     So, if you override it without calling `super.locationDidPick(locationItem)`, completion closure and delegate method would not be called.
     
     - Note:
     This method would be called only once in `func viewWillDisappear(animated: Bool)` before this instance of `LocationPicker` dismissed.
     
     To get user's every selection, use `func locationDidSelect(locationItem: LocationItem)` instead.
     
     Alternatively, the same result can be achieved by:
     * Closure
     1. set `var pickCompletion`
     * Delegate
     1. conform to `protocol LocationPickerDelegate`
     2. set the `var delegate`
     3. implement `func locationDidPick(locationItem: LocationItem)`
     
     - SeeAlso:
     `var pickCompletion: ((LocationItem) -> Void)?`
     
     `func locationDidSelect(locationItem: LocationItem)`
     
     `protocol LocationPickerDelegate`
     
     - parameter locationItem: The location item user picked
     */
    @objc open func locationDidPick(locationItem: LocationItem) {
        pickCompletion?(locationItem)
        delegate?.locationDidPick?(locationItem: locationItem)
    }
    
    /**
     This method would be called after user delete an alternative location.
     
     - important:
     This method includes the following codes:
     
     deleteCompletion?(locationItem)
     dataSource?.commitAlternativeLocationDeletion?(locationItem)
     
     So, if you override it without calling `super.alternativeLocationDidDelete(locationItem)`, completion closure and delegate method would not be called.
     
     - Note:
     This method would be called when user delete a location cell from `tableView`.
     
     User can only delete the location provided in `var alternativeLocations` or `dataSource` method `alternativeLocationAtIndex(index: Int) -> LocationItem`.
     
     Alternatively, the same result can be achieved by:
     * Closure
     1. set `var deleteCompletion`
     * Delegate
     1. conform to `protocol LocationPickerDataSource`
     2. set the `var dataSource`
     3. implement `func commitAlternativeLocationDeletion(locationItem: LocationItem)`
     
     - SeeAlso:
     `var deleteCompletion: ((LocationItem) -> Void)?`
     
     `protocol LocationPickerDataSource`
     
     - parameter locationItem: The location item needs to be deleted
     */
    open func alternativeLocationDidDelete(locationItem: LocationItem) {
        deleteCompletion?(locationItem)
        dataSource?.commitAlternativeLocationDeletion?(locationItem: locationItem)
    }
    
    /**
     This method would be called when user try to fetch current location without granting location access.
     
     - important:
     This method includes the following codes:
     
     locationDeniedHandler?(self)
     delegate?.locationDidDeny?(self)
     
     So, if you override it without calling `super.locationDidDeny(locationPicker)`, completion closure and delegate method would not be called.
     
     - Note:
     If you wish to present an alert view controller, just ignore this method. You can provide a fully cutomized `UIAlertController` to `var locationDeniedAlertController`, or configure the alert view controller provided by `LocationPicker` using `func setLocationDeniedAlertControllerTitle`.
     
     Alternatively, the same result can be achieved by:
     * Closure
     1. set `var locationDeniedHandler`
     * Delegate
     1. conform to `protocol LocationPickerDelegate`
     2. set the `var delegate`
     3. implement `func locationDidDeny(LocationPicker: LocationPicker)`
     
     - SeeAlso:
     `var locationDeniedHandler: ((LocationPicker) -> Void)?`
     
     `protocol LocationPickerDelegate`
     
     `var locationDeniedAlertController`
     
     `func setLocationDeniedAlertControllerTitle`
     
     - parameter locationPicker `LocationPicker` instance that needs to response to user's location request
     */
    public func locationDidDeny(locationPicker: LocationPicker) {
        locationDeniedHandler?(self)
        delegate?.locationDidDeny_?(locationPicker: self)
        
        if locationDeniedHandler == nil && delegate?.locationDidDeny_ == nil {
            if let alertController = locationDeniedAlertController {
                present(alertController, animated: true, completion: nil)
            } else {
                let alertController = UIAlertController(title: locationDeniedAlertTitle, message: locationDeniedAlertMessage, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: locationDeniedGrantText, style: .default, handler: { (alertAction) in
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.openURL(url)
                    }
                }))
                alertController.addAction(UIAlertAction(title: locationDeniedCancelText, style: .cancel, handler: nil))
                present(alertController, animated: true, completion: nil)
            }
        }
    }
    
}


// MARK: Map View Delegate

extension LocationPicker: GMSMapViewDelegate {
    public func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        //        longitudinalDistance = mapView.camera.position.zoom
        //        if gesture {
        //            UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut, animations: {
        //                self.pinView.frame.origin.y -= self.pinViewImageHeight / 2
        //            }, completion: nil)
        //        }
    }
    public func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        longitudinalDistance = position.zoom
        if isMapViewCenterChanged {
            isMapViewCenterChanged = false
            if #available(iOS 10, *) {
                let coordinate = position.target
                reverseGeocodeLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
            } else {
                let adjustedCoordinate = gcjToWgs(coordinate: position.target)
                reverseGeocodeLocation(CLLocation(latitude: adjustedCoordinate.latitude, longitude: adjustedCoordinate.longitude))
            }
        }
    }
}
extension LocationPicker: MKMapViewDelegate {
    
    public func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        if !animated {
            UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut, animations: {
                self.pinView.frame.origin.y -= self.pinViewImageHeight / 2
            }, completion: nil)
        }
    }
    
    public func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        longitudinalDistance = Float(getLongitudinalDistance(fromMapRect: mapView.visibleMapRect))
        if isMapViewCenterChanged {
            isMapViewCenterChanged = false
            if #available(iOS 10, *) {
                let coordinate = mapView.centerCoordinate
                reverseGeocodeLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
            } else {
                let adjustedCoordinate = gcjToWgs(coordinate: mapView.centerCoordinate)
                reverseGeocodeLocation(CLLocation(latitude: adjustedCoordinate.latitude, longitude: adjustedCoordinate.longitude))
            }
        }
        
        if !animated {
            UIView.animate(withDuration: 0.35, delay: 0, options: .curveEaseOut, animations: {
                self.pinView.frame.origin.y += self.pinViewImageHeight / 2
            }, completion: nil)
        }
    }
    
}


// MARK: Location Manager Delegate

extension LocationPicker: CLLocationManagerDelegate {
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //        if (tableView.indexPathForSelectedRow as NSIndexPath?)?.row == 0 {
        let currentLocation = locations[0]
        reverseGeocodeLocation(currentLocation)
        guard #available(iOS 9.0, *) else {
            locationManager.stopUpdatingLocation()
            return
        }
        //        }
    }
    
}
extension LocationPicker: GMSAutocompleteResultsViewControllerDelegate {
    public func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                                  didAutocompleteWith place: GMSPlace) {
        searchController?.isActive = false
        // Do something with the selected place.
        print("Place name: \(place.name)")
        print("Place address: \(place.formattedAddress)")
        print("Place attributions: \(place.attributions)")
        let coordinate = place.coordinate
        let locationItem = LocationItem.init(coordinate: coordinate, place: place, address: place.name)
        //        if self.isForceReverseGeocoding {
        //            reverseGeocodeLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude))
        //        } else {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
            self.selectLocationItem(locationItem)
        }
        //        }
    }
    
    
    public func resultsController(_ resultsController: GMSAutocompleteResultsViewController,
                                  didFailAutocompleteWithError error: Error){
        // TODO: handle the error.
        print("Error: ", error.localizedDescription)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
