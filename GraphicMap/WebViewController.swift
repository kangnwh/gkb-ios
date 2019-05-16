//
//  WebViewController.swift
//  GraphicMap
//
//  Created by Eric Kang on 12/5/19.
//  Copyright © 2019 UoM. All rights reserved.
//

import UIKit
import WebKit
import CoreLocation

class WebViewController: ViewController, WKUIDelegate {

//    @IBOutlet var webViewContainer: UIView!
    
//    var nativeWebView: WKWebView!
    
    @IBOutlet var nativeWebView: WKWebView!
    
    let locationManager = CLLocationManager()
    
    func setupWKWebView(){

        let controller = nativeWebView.configuration.userContentController
        controller.add(self, name: "share")
        controller.add(self, name: "location")
        controller.add(self, name: "print")

        nativeWebView.translatesAutoresizingMaskIntoConstraints = false

        nativeWebView.allowsLinkPreview = false
        
        nativeWebView.contentScaleFactor = 1
        
        // Make sure our view is interactable
        nativeWebView.scrollView.isScrollEnabled = true

        // Things like this should be handled in web code
        nativeWebView.scrollView.bounces = false
        nativeWebView.scrollView.delegate = self

        // Disable swiping to navigate
        nativeWebView.allowsBackForwardNavigationGestures = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initLocationManager()
        setupWKWebView()
        nativeWebView.scrollView.delegate = self
//        let myURL = URL(string:"http://10.10.5.28:8080/")
        let myURL = URL(string:"http://115.146.90.170:5000/index.html")
//        let myURL = URL(string:"http://127.0.0.1:8080/index.html")
        let myRequest = URLRequest(url: myURL!)
        nativeWebView.load(myRequest)
    }
    

}

extension WebViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(scrollView == nativeWebView.scrollView){
            scrollView.contentOffset = CGPoint(x: 0, y: 0)
        }
        
    }
}

extension WebViewController: WKScriptMessageHandler{
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if(message.name == "share"){
            let dict = message.body as! [String:AnyObject]
            let url = URL(string: dict["url"] as! String)
            let title = dict["title"] as! String
            let description = dict["description"] as! String
            
            let vc = UIActivityViewController(activityItems: [url as Any,title,description],
                                              applicationActivities: [])
            present(vc, animated: true)
            
        }else if(message.name == "location"){
            guard let locValue: CLLocationCoordinate2D = self.locationManager.location?.coordinate else{
                return
            }
//            nativeWebView.evaluateJavaScript(
//                "console.log('abc from swift')"
//                , completionHandler: nil)
//
            let lat = Double(locValue.latitude)
            let log = Double(locValue.longitude)
            nativeWebView.evaluateJavaScript(
                "setLocation(\(lat),\(log))"
                , completionHandler: nil)
        }else if(message.name == "print"){
            
            print(message.body)
        }
        
    }
    
    
}

extension WebViewController: CLLocationManagerDelegate{
    func initLocationManager() {
        // 1
        let status = CLLocationManager.authorizationStatus()
        
        switch status {
        // 1
        case .notDetermined:
            self.locationManager.requestWhenInUseAuthorization()
            return
            
        // 2
        case .denied, .restricted:
            let alert = UIAlertController(title: "Location Services disabled", message: "Please enable Location Services in Settings", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            
            present(alert, animated: true, completion: nil)
            return
        case .authorizedAlways, .authorizedWhenInUse:
            break
            
        }
        
        // 4
        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()
    }
}
