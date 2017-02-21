//
//  ResourceModule.swift
//  CloudUI
//
//  Created by Tobias Kraentzer on 25.01.17.
//  Copyright © 2017 Tobias Kräntzer. All rights reserved.
//

import UIKit
import CloudService

public class ResourceModule: UserInterfaceModule {

    public init() {
    }
    
    public func makeViewController() -> UIViewController {
        let viewController = ResourceViewController()
        return viewController
    }
    
}

class ResourceViewController: UIViewController, ResourceUserInterface {
    
    private(set) var resource: Resource? {
        didSet {
            label.text = resource?.path.href
        }
    }
    
    func present(_ resource: Resource, animated: Bool) {
        self.resource = resource
    }
    
    private let label: UILabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.yellow
        
        label.translatesAutoresizingMaskIntoConstraints = true
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        label.textAlignment = .center
        label.frame = view.bounds
        view.addSubview(label)
    }
}
