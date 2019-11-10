//
//  Navigation.swift
//  testQRScanner
//
//  Created by Ira Golubovich on 11/7/19.
//  Copyright © 2019 Ira Golubovich. All rights reserved.
//

import UIKit

extension UIViewController {
    func navigateTo(navigationItem: NavigationItem, animated: Bool, shouldPresentedModally: Bool = false, completion: (() -> Void)? = nil) {
        guard let viewController = navigationItem.viewControllerForNavigation else { return }
        if navigationController == nil || shouldPresentedModally {
            viewController.modalPresentationStyle = .overFullScreen
            present(viewController, animated: animated, completion: completion)
        } else {
            navigationController?.pushViewController(viewController, animated: animated)
        }
    }
}


enum NavigationItem {
    case scannedDataDetail(imageUrl: String)
    
    private var storyboardName: String {
        switch self {
        case .scannedDataDetail:
            return "ScannedData"
            
        }
    }
    
    private var viewControllerId: String {
        switch self {
        case .scannedDataDetail:
            return "ScannedDataViewController"
            
        }
    }
    
    var viewControllerForNavigation: UIViewController? {
        let viewController = createViewController()
        switch self {
        case .scannedDataDetail(let imageUrl):
            return createScannedDataViewController(viewController: viewController, url: imageUrl)
            
        }
    }
    
    private func createViewController() -> UIViewController {
        let viewController = UIStoryboard(name: self.storyboardName,
                                          bundle: nil).instantiateViewController(withIdentifier: self.viewControllerId)
        
        return viewController
    }
    
    private func createScannedDataViewController(viewController: UIViewController, url: String) -> UIViewController {
        guard let viewController = viewController as? ScannedDataViewController else {
            assertionFailure("Can't cast to ScannedDataViewController")
            return UIViewController()
        }
        
        viewController.url = url
        return viewController
    }
}
