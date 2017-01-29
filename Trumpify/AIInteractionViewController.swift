//
//  AIInteractionViewController.swift
//  Trumpify
//
//  Created by Fabian Vergara on 2017-01-28.
//  Copyright © 2017 fvergara. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class AIInteractionViewController: UIViewController {
    
    
    @IBOutlet var labelTrump: UILabel!
    
    var string: String!
    
    @IBAction func goBackButtonPressed(_ sender: Any) {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let newStr = string.replacingOccurrences(of: "u2019", with: "'")
        labelTrump.text = newStr
    }
    
}
