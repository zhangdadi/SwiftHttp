//
//  Nodes.swift
//  HDService
//
//  Created by 张达棣 on 14-10-3.
//  Copyright (c) 2014年 张达棣. All rights reserved.
//

import UIKit
import HDNetworkKit

public class DCData_nodesObj: DCDataObject {
    public var mID: Int? //id
    public var name: String? //节点名
    public var title: String? //标题
    public var url: NSURL? //url
    
}

public class DCData_nodesParam: NSObject {
    public var mID: Int? //id
}

public class DCDataCtrl_nodes: DCDataControl {
    public var data: DCData_nodesObj? //结果
    public var param = DCData_nodesParam() //参数
    
    //初始化请求
    override func dataRequest() {
        /*
        //post请求 这样传参
        let muParam: [String: HDNetHTTPMutipartDataFormItem] = ["id": HDNetHTTPMutipartDataFormItem.item(int: param.mID)]
        autoRequest(urlSuffix: "nodes/show.json", mutiPart: muParam)
*/
        
        //get请求
        let urlParam = String("nodes/show.json?id=\(param.mID!)")
        autoRequest(urlSuffix: urlParam)
    }
    
    //解析数据
    override func dataProcess(data: NSData?, updateDate: NSDate)  {
        var obj = DCData_nodesObj()
        obj.updateDate = updateDate
        let json = JSON(data: data!, options: nil, error: nil)
        
        obj.mID = json["id"].integerValue
        obj.name = json["name"].stringValue
        obj.title = json["title"].stringValue
        obj.url = json["url"].URLValue
        outputData(obj)
    }
}
