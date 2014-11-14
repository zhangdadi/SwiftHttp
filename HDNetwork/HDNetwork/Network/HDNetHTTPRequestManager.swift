//
//  HDNetHTTPRequestManager.swift
//  HDNetworkKit
//
//  Created by 张达棣 on 14-11-14.
//  Copyright (c) 2014年 张达棣. All rights reserved.
//

import UIKit

/**
*  http请求完成后回调的block
*
*  @param NSData  请求的数据，如果请求成功有数据，否则为nil
*  @param NSError 错误信息，如果请求失败则不为nil。
*
*/
typealias HDNetCompletionBlock = (data: NSData?, error: NSError?) -> Void

/**
*  下载进度条
*
*  @param UInt64 已下载的大小
*  @param UInt64 总的大小
*
*/
typealias HDNetProgressBlock = (size: UInt64, total: UInt64) -> Void


public class HDNetHTTPRequestManager: NSObject, HDNetRequestDelegate {
    var _netRequest: HDNetHTTPRequest?
    var _progressBlock: HDNetProgressBlock?
    var _completionBlock: HDNetCompletionBlock?
    /**
    清除请求
    */
    public func clearRequest() {
        if _netRequest != nil {
            _netRequest?.delegate = nil
            _netRequest?.cancel()
            _netRequest = nil
        }
    }
    
    public func GET(URLString: String, parameters: [String: HDNetHTTPItem]?, completion: (data: NSData?, error: NSError?) ->Void) -> Void {
        _completionBlock = completion
        self.clearRequest()
        
        _netRequest = HDNetHTTPRequest()
        _netRequest?.destURL = NSURL(string: URLString)
        _netRequest?.multipartDict = parameters
        _netRequest?.methodType = HDHTTPMethodType.GET
        startRequest()
        
    }
    
    public func POST(URLString: String, parameters: [String: HDNetHTTPItem]?, completion: (data: NSData?, error: NSError?) ->Void) -> Void {
        _completionBlock = completion
        self.clearRequest()
        
        _netRequest = HDNetHTTPRequest()
        _netRequest?.destURL = NSURL(string: URLString)
        _netRequest?.multipartDict = parameters
        _netRequest?.methodType = HDHTTPMethodType.POST
        startRequest()

    }
    
    public func set(progress: (size: UInt64, total: UInt64) -> Void) {
        _progressBlock = progress
    }
    
    //----
    func startRequest() {
        weak var weakSelf = self
         DataThreadInitSingleton.shareInstance().onCall = weakSelf?.setupRequest
    }
    
     func setupRequest() {
        assert(DataThreadInitSingleton.isDataThread(), "当前线程不是数据线程")
        
        if _netRequest != nil {
            _netRequest?.delegate = self
            _netRequest?.start()
        } else {
            // 通知不加载
            callUpdate()
        }
        
        // notify progress
        callProgress()
    }
    
    // MARK: - HDNetRequestDelegate
    func netRequestCompletion(#sender: HDNetRequest, error: NSError?) {
        callUpdate()
    }
    
    func netRequestProgress(sender: HDNetRequest) {
        callProgress()
    }
    
    //阻塞的主线程进度通知
    func callUpdate() {
        if NSThread.isMainThread() {
            if _completionBlock != nil {
                _completionBlock!(data: _netRequest?.responseData, error: _netRequest?._error)
            }
        } else {
            dispatch_sync(dispatch_get_main_queue(), {
                if self._completionBlock != nil {
                    self._completionBlock!(data: self._netRequest?.responseData, error: self._netRequest?._error)
                }
            })
        }
    }
    
    func callProgress() {
        if NSThread.isMainThread() {
            
        } else {
            dispatch_sync(dispatch_get_main_queue(), {
                
            })
        }
    }
}
