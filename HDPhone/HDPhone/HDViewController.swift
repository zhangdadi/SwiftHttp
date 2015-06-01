//
//  HDViewController.swift
//  HDPhone
//
//  Created by 张达棣 on 14-11-14.
//  Copyright (c) 2014年 张达棣. All rights reserved.
//

import UIKit
import HDNetwork

class HDViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        HDNetHTTPRequestManager().GET("http://apitest.aidianhui.com/api/city/GetEnableCities", parameters: nil) { (data, error) -> Void in
            println(data)
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
