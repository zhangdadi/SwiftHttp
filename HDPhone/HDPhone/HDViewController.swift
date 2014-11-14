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

        //POST请求
        HDNetHTTPRequestManager().POST("http://www.v2ex.com/api/nodes/all.json", parameters: nil, completion: {
            (data: NSData?, error: NSError?) -> Void in
            if error != nil {
                println("请求all失败")
                return
            }

            println("请求all成功")
            var json = JSON(data: data!, options: nil, error: nil)
            let mid = json[0]["id"].integerValue
            
            //GET请求
            //参数
            let paramDict = ["id": HDNetHTTPItem(value: mid!)]
            HDNetHTTPRequestManager().GET("http://www.v2ex.com/api/nodes/show.json", parameters: paramDict, completion: {
                (data: NSData?, error: NSError?) -> Void in
                if error != nil {
                   println("请求show.json失败")
                } else {
                    json = JSON(data: data!, options: nil, error: nil)
                    println(json)
                    var titel = json["title"].stringValue
                    println("请求show.json成功,标题为=\(titel)")
                }
            })
        })

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
