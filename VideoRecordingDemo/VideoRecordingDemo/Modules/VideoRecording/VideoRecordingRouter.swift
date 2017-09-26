//
//  VideoRecordingRouter.swift
//  VideoRecordingDemo
//
//  Created by Dima Tsurkan on 9/26/17.
//  Copyright (c) 2017 Dima Tsurkan. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

@objc protocol VideoRecordingRoutingLogic {
    //func routeToSomewhere(segue: UIStoryboardSegue?)
}

protocol VideoRecordingDataPassing {
    var dataStore: VideoRecordingDataStore? { get }
}

class VideoRecordingRouter: NSObject, VideoRecordingRoutingLogic, VideoRecordingDataPassing {
    weak var viewController: VideoRecordingViewController?
    var dataStore: VideoRecordingDataStore?
  
    // MARK: Routing
  
    //func routeToSomewhere(segue: UIStoryboardSegue?)
    //{
    //  if let segue = segue {
    //    let destinationVC = segue.destination as! SomewhereViewController
    //    var destinationDS = destinationVC.router!.dataStore!
    //    passDataToSomewhere(source: dataStore!, destination: &destinationDS)
    //  } else {
    //    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    //    let destinationVC = storyboard.instantiateViewController(withIdentifier: "SomewhereViewController") as! SomewhereViewController
    //    var destinationDS = destinationVC.router!.dataStore!
    //    passDataToSomewhere(source: dataStore!, destination: &destinationDS)
    //    navigateToSomewhere(source: viewController!, destination: destinationVC)
    //  }
    //}

    // MARK: Navigation
  
    //func navigateToSomewhere(source: VideoRecordingViewController, destination: SomewhereViewController)
    //{
    //  source.show(destination, sender: nil)
    //}
  
    // MARK: Passing data
  
    //func passDataToSomewhere(source: VideoRecordingDataStore, destination: inout SomewhereDataStore)
    //{
    //  destination.name = source.name
    //}
}