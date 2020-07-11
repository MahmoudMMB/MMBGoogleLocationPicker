//
//  LocationItem.swift
//  LocationPicker
//
//  Created by Jerome Tan on 3/30/16.
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

import GoogleMaps
import GooglePlaces

open class LocationItem: NSObject, NSCoding {
    
    public let mapItem: GMSPlace?
    
    
    open var name: String {
        return mapItem?.name ?? address ?? formattedAddressString ?? ""
    }
    
    open var coordinate: CLLocationCoordinate2D?
    open var address: String?
    
    open var addressDictionary: GMSPlace? {
        return mapItem
    }
    
    open var formattedAddressString: String? {
        return mapItem?.formattedAddress
    }
    
    open override var description: String {
        return "Location item with map item: " + (mapItem?.description ?? "")
    }
    
    
    public init(mapItem: GMSPlace) {
        self.mapItem = mapItem
    }
    
    public init(coordinate: CLLocationCoordinate2D, place: GMSPlace?, address: String?) {
        self.coordinate = coordinate
        self.mapItem = place
        self.address = address
    }
    
    public required convenience init(coder aDecoder: NSCoder) {
        let latitude = aDecoder.decodeDouble(forKey: "latitude")
        let longitude = aDecoder.decodeDouble(forKey: "longitude")
        let addressDictionary = aDecoder.decodeObject(forKey: "addressDictionary") as? String
        self.init(coordinate: CLLocationCoordinate2D.init(latitude: latitude, longitude: longitude), place: nil, address: addressDictionary)
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(mapItem?.coordinate.latitude, forKey: "latitude")
        aCoder.encode(mapItem?.coordinate.longitude, forKey: "longitude")
        aCoder.encode(addressDictionary, forKey: "addressDictionary")
    }
    
}
