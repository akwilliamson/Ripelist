//
//  PrivacyPolicy.swift
//  Ripelist
//
//  Created by Aaron Williamson on 3/4/16.
//  Copyright © 2016 Aaron Williamson. All rights reserved.
//

import UIKit

class PrivacyPolicyVC: UIViewController {
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = NSURL(string: "https://www.iubenda.com/privacy-policy/689270")
        let requestObj = NSURLRequest(URL: url!)
        webView.loadRequest(requestObj)
    }

}
