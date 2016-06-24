//
//  BookWebViewController.swift
//  WorldTrotter
//
//  Created by Jeremy Broutin on 6/16/16.
//  Copyright © 2016 Jeremy Broutin. All rights reserved.
//

import UIKit

class BookWebViewController: UIViewController {
	
	@IBOutlet weak var webView: UIWebView!
	var webContentURLString = "https://www.bignerdranch.com"
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		print("BookWebViewController loaded its view")
		
		// load web view content
		let url = NSURL(string: webContentURLString)
		let request = NSURLRequest(URL: url!)
		webView.loadRequest(request)
	}
	
}
