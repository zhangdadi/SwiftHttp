//
//  DCDataModel.swift
//  demoPhone
//
//  Created by 张达棣 on 14-8-3.
//  Copyright (c) 2014年 HD. All rights reserved.
//

import UIKit
import HDNetworkKit

struct ServerURLs {
    static let _service_Public = "http://www.v2ex.com/api/"
    static let _service_Test = ""
    
    static func getUrlPrefix() -> NSString {
        
        return _service_Public
    }
}

public class DCDataObject: HDNetDataObject {
    public var code: Int = 0
    public var errorMessage: String?
}

public class DCDataControl: HDNetDataControl {
    
    func setupCacheByTag() {

    }
    
    func setupCacheByTime() {
        
    }
    
    //子类重写的方法
    func dataRequest() {
        assert(false, "子类没有重写dataRequest")
    }
    
    //子类重写的方法
    func dataProcess(data: NSData?, updateDate: NSDate) {
        assert(false, "子类没有重写dataProcess")
    }
    
    func autoRequest(#urlPrefix: String, urlSuffix: String, mutiPart: Dictionary<String, HDNetHTTPMutipartDataFormItem>?) {
        var request = HDNetHTTPRequest()
        var url = NSURL(string: urlPrefix + urlSuffix)
        request.destURL = url
        request.multipartDict = mutiPart
        request.queue = QueueSingleton.shareInstance()
        self.netRequest = request
    }
    func autoRequest(#urlSuffix: String, mutiPart: Dictionary<String, HDNetHTTPMutipartDataFormItem>) {
        autoRequest(urlPrefix: ServerURLs.getUrlPrefix(), urlSuffix: urlSuffix, mutiPart: mutiPart)
    }
    func autoRequest(#urlSuffix: String) {
        autoRequest(urlPrefix: ServerURLs.getUrlPrefix(), urlSuffix: urlSuffix, mutiPart: nil)
    }
    
    func _autoInitParam() {
        var multipartDict: Dictionary<String, HDNetHTTPMutipartDataFormItem>?
        
    }
    
//-____________________________________________________________________
    final override public func _createRequest() {
        dataRequest()
    }
    
    final override public func _processResponse() {
        if netError != nil {
            //error
            
        } else {
            dataProcess(netRequest?.responseData, updateDate: NSDate())
        }
    }
}


public class DCDataPageControl: HDNetDataPageControl {
    //子类重写的方法
    func dataRequest() {
        assert(false, "子类没有重写dataRequest")
    }

    //子类重写的方法
    func dataProcess(data: NSData?, updateDate: NSDate) {
        assert(false, "子类没有重写dataProcess")
    }
    
    final override public func _createRequest() {
        dataRequest()
    }
    
    final override public func _processResponse() {
        if netError != nil {
            //error
            
        } else {
            dataProcess(netRequest?.responseData, updateDate: NSDate())
        }
    }
}
