//
//  PinAnnotation.swift
//  WorldTrotter
//
//  Created by Jeremy Broutin on 6/21/16.
//  Copyright © 2016 Jeremy Broutin. All rights reserved.
//

import MapKit

class Location: NSObject, MKAnnotation {
	
	var latitude: Double
	var longitude: Double
	var title: String?
	var subtitle: String?
	@objc var coordinate: CLLocationCoordinate2D
	
	init(lat: Double, lon: Double, title: String?, subtitle: String?){
		self.latitude = lat
		self.longitude = lon
		self.title = title
		self.subtitle = subtitle
		self.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
	}
	
}
