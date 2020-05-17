//
//  ReplaceViewSegue.swift
//  CS342 Library
//
//  Created by Santiago Gutierrez on 9/1/19.
//  Copyright © 2019 Stanford University. All rights reserved.
//

import UIKit

class ReplaceViewSegue: UIStoryboardSegue {
    
    override func perform() {
        let controllerToReplace = source.childViewControllers.first
        let destinationControllerView = destination.view
        
        destinationControllerView?.translatesAutoresizingMaskIntoConstraints = true
        destinationControllerView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        destinationControllerView?.frame = source.view.bounds
        
        controllerToReplace?.willMove(toParentViewController: nil)
        source.addChildViewController(destination)
        
        source.view.addSubview(destinationControllerView!)
        controllerToReplace?.view.removeFromSuperview()
        
        destination.didMove(toParentViewController: source)
        controllerToReplace?.removeFromParentViewController()
    }
}
