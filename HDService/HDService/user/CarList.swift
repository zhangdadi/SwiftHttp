//
//  CarList.swift
//  demoPhone
//
//  Created by 张达棣 on 14-8-3.
//  Copyright (c) 2014年 HD. All rights reserved.
//

import UIKit
import HDNetworkKit

public class DCData_carListInfo: NSObject {
    public var created: Int?
    public var mID: Int?
    public var name: String?
    public var title: String?
    public var url: NSURL?
    
}

public class DCData_carListObj: DCDataObject {
    public var listArray: [DCData_carListInfo]?
}

public class DCData_carListParam: NSObject {

}

public class DCDataCtrl_carList: DCDataControl {
    public var data: DCData_carListObj? //结果
    public var param = DCData_carListParam() //参数
    
    //初始化请求
    override func dataRequest() {
        autoRequest(urlSuffix: "nodes/all.json")
    }
    
    //解析数据
    override func dataProcess(data: NSData?, updateDate: NSDate)  {
        debugPrintln("dataProcess")
        var obj = DCData_carListObj()
        obj.updateDate = updateDate
        let json = JSON(data: data!, options: nil, error: nil)
        
        var list = [DCData_carListInfo]()
        
        for index in 0..<json.arrayValue!.count {
            var info = DCData_carListInfo()
            info.created = json[index]["created"].integerValue
            info.mID = json[index]["id"].integerValue
            info.name = json[index]["name"].stringValue
            info.title = json[index]["title"].stringValue
            info.url = json[index]["url"].URLValue
            list.append(info)
        }

        obj.listArray = list        
        outputData(obj)
    }
}

