//
//  MapViewController.swift
//  WorldTrotter
//
//  Created by Jeremy Broutin on 6/14/16.
//  Copyright © 2016 Jeremy Broutin. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
	
	var mapView: MKMapView!
	var locationButton: UIButton!
	var annotationButton: UIButton!
	
	
	// LOCALIZED STRINGS
	// Segmented control items
	let standardString = NSLocalizedString("Standard", comment: "Standard map view")
	let satelliteString = NSLocalizedString("Satellite", comment: "Satellite map view")
	let hybridString = NSLocalizedString("Hybrid", comment: "Hybrid map view")
	// Buttons titles
	let enableLocString = NSLocalizedString(" Enable your location ", comment: "Enable location button title")
	let disableLocString = NSLocalizedString(" Disable your location ", comment: "Disable location button title")
	let showAnnotString = NSLocalizedString(" See annotation ", comment: "See annotation button title")
	// Unauthorized location alert
	let alertTitle = NSLocalizedString("User Location not authorized", comment: "Unauthorized Location Alert Title")
	let alertMsg = NSLocalizedString("Please allow the app to know your location in your device settings.", comment: "Unauthorized Location Alert Title Message")
	
	
	// Locations/Annotations related variables
	var locationManager: CLLocationManager!
	var followUser = true
	var fixedLocations: [Location] = [
		Location(lat: 51.50998, lon: -0.1337, title: "Born location", subtitle: ""), // London
		Location(lat: -26.20401028, lon: 28.0473051, title: "Current location", subtitle: "Welcome to my house"), // Johanesburg
		Location(lat: 35.700691	, lon: 139.7753269, title: "Favorite location", subtitle: "Dream on Earth") // Tokyo
	]
	var annotationIndex = 0
	
	/* MARK: - App Life Cycle */
	
	override func loadView() {
		// Create a map view
		mapView = MKMapView()
		mapView.delegate = self
		
		locationButton = createDefaultButton(UIColor(red: 0.3333, green: 0.5765, blue: 0.8784, alpha: 1.0), title: enableLocString)
		locationButton.addTarget(self, action: #selector(MapViewController.locationBtnTouched), forControlEvents:.TouchUpInside)
		
		annotationButton = createDefaultButton(UIColor(red: 0.9098, green: 0.4627, blue: 0.7686, alpha: 1.0), title: showAnnotString)
		annotationButton.addTarget(self, action: #selector(MapViewController.annotationBtnTouched), forControlEvents: .TouchUpInside)
		
		// Set it as *the* view of this view controller
		// Note: When a view controller is created, the view property is nil
		// Note bis: If a view controller is asked for its view and its view is nil, loadView() is called
		view = mapView
		
		let segmentedControl = UISegmentedControl(items: [standardString, satelliteString, hybridString])
		segmentedControl.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.5) // half transparent
		segmentedControl.selectedSegmentIndex = 0
		
		addToViewProgrammatically(segmentedControl)
		addToViewProgrammatically(locationButton)
		addToViewProgrammatically(annotationButton)

		
		// Set constraints using elements anchors
		
		// Use TopLayoutGuide so that we don't underlap the status bar
		let topConstraint = segmentedControl.topAnchor.constraintEqualToAnchor(topLayoutGuide.bottomAnchor, constant: 8)
		// Use MarginsGuide to keep the edge flexible on all devices
		let margins = view.layoutMarginsGuide
		let leadingConstraint = segmentedControl.leadingAnchor.constraintEqualToAnchor(margins.leadingAnchor)
		let trailingConstraint = segmentedControl.trailingAnchor.constraintEqualToAnchor(margins.trailingAnchor)
		
		let buttonTrailingConstraint = locationButton.trailingAnchor.constraintEqualToAnchor(margins.trailingAnchor)
		let buttonBottomConstraint = locationButton.bottomAnchor.constraintEqualToAnchor(bottomLayoutGuide.topAnchor, constant: -10)
		
		let annotTrailingConstraint = annotationButton.trailingAnchor.constraintEqualToAnchor(locationButton.trailingAnchor)
		let annotBottomConstraint = annotationButton.bottomAnchor.constraintEqualToAnchor(locationButton.topAnchor, constant: -5)
		
		
		// Set the constraints to be active to affect the layout
		topConstraint.active = true
		leadingConstraint.active = true
		trailingConstraint.active = true
		
		buttonTrailingConstraint.active = true
		buttonBottomConstraint.active = true
		
		annotTrailingConstraint.active = true
		annotBottomConstraint.active = true
		
		
		// Add a target-action pair associated with .ValueChanged event for the segmentedControl
		segmentedControl.addTarget(self, action: #selector(MapViewController.mapTypeChanged(_:)), forControlEvents: .ValueChanged)
		
		// Get user location with authorization
		if CLLocationManager.locationServicesEnabled() {
			locationManager = CLLocationManager()
			locationManager.delegate = self
			locationManager.desiredAccuracy = kCLLocationAccuracyBest
			locationManager.requestAlwaysAuthorization()
		}
		
		// Drop the pings for the 3 locations
		for loc in fixedLocations {
			mapView.addAnnotation(loc)
		}
		
	}
	
	/* MARK: - Helper functions */
	
	func mapTypeChanged(segControl: UISegmentedControl){
		switch segControl.selectedSegmentIndex {
		case 0:
			mapView.mapType = .Standard
		case 1:
			mapView.mapType = .Hybrid
		case 2:
			mapView.mapType = .Satellite
		default:
			break
		}
	}
	
	func locationBtnTouched(){
		
		if followUser {
			print("followUser is true")
			if CLLocationManager.authorizationStatus() == .AuthorizedAlways {
				mapView.setUserTrackingMode(MKUserTrackingMode.Follow, animated: true) // tracks user location automatically
				followUser = !followUser // switch enabling status
				locationButton.setTitle(disableLocString, forState: .Normal) // update button title
			} else {
				// Show an alert asking the user to authorize its location
				let alertController = UIAlertController(title: alertTitle, message: alertMsg, preferredStyle: .Alert)
				let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
				alertController.addAction(okAction)
				presentViewController(alertController, animated: true, completion: nil)
				
				print("Cannot find user location because authorization is not granted.")
			}
		} else {
			print("followUser is false")
			mapView.setUserTrackingMode(.None, animated: true) // stop tracking user
			followUser = !followUser // switch enabling status
			locationButton.setTitle(enableLocString, forState: .Normal) // update button title
		}
		
	}
	
	func annotationBtnTouched(){
		
		if annotationIndex > fixedLocations.count-1 {
			annotationIndex = 0
		}
		
		let loc = fixedLocations[annotationIndex]
		annotationIndex += 1
		
		// Recenter the map on the newly dropped annotation
		let center = loc.coordinate
		let camera = MKMapCamera(lookingAtCenterCoordinate: center, fromDistance: 1000000.0, pitch: 0.0, heading: 0.0)
		mapView.setCamera(camera, animated: true)
	}
	
	func createDefaultButton(color: UIColor, title: String) -> UIButton {
		let button = UIButton(type: UIButtonType.RoundedRect)
		button.frame = CGRectMake(0, 0, 200, 100)
		button.layer.cornerRadius = 5
		button.backgroundColor = color
		button.setTitle(title, forState: .Normal)
		button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
		button.sizeToFit()
		
		return button
	}
	
	func addToViewProgrammatically(subView: UIView) {
		subView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(subView)
	}

	
	/* MARK: - App Life Cycle */
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		print("MapViewController loaded its view")
	}
	
}
