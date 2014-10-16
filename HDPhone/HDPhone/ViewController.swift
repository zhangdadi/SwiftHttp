//
//  ViewController.swift
//  HDPhone
//
//  Created by 张达棣 on 14-9-29.
//  Copyright (c) 2014年 张达棣. All rights reserved.
//

import UIKit
import HDService
import HDNetworkKit

class ViewController: UIViewController, HDNetCtrlDelegate {
    let car = DCDataCtrl_carList()
    let infoCtrl = DCDataCtrl_nodes()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        car.delegate = self //多点回调委托，可以同时指向多点对象并回调多个对象
        infoCtrl.delegate = self
    }

    @IBAction func buttonClick(sender: AnyObject) {
        car.refresh()
    }
    
    @IBAction func infoButtonClick(sender: AnyObject) {
        infoCtrl.param.mID = car.data?.listArray?[0].mID
        infoCtrl.refresh()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func netCtrlProgress(ctrl: HDNetDataModel) {
        println("下载进度=\(ctrl.progressValue)")
        
    }
    
    func netCtrlUpdate(ctrl: HDNetDataModel) {
        if ctrl === car {
            if car.data?.errorMessage != nil {
                println("请求错误=\(car.data?.errorMessage)")
            } else {
                println("获取的节点数＝\(car.data?.listArray?.count)")
            }
        }
        
        if ctrl === infoCtrl {
            if infoCtrl.data?.errorMessage != nil {
                println("请求错误=\(infoCtrl.data?.errorMessage)")
            } else {
                println("id = \(infoCtrl.data?.mID), name = \(infoCtrl.data?.name), title = \(infoCtrl.data?.title), url = \(infoCtrl.data?.url)")
            }
        }
    }
}

