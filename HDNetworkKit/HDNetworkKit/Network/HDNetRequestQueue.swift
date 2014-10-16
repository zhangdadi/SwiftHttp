//
//  HDNetRequestQueue.swift
//  HDNetFramework
//
//  Created by 张达棣 on 14-7-23.
//  Copyright (c) 2014年 HD. All rights reserved.
//
//  若发现bug请致电:z_dadi@163.com,在此感谢你的支持。
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


import UIKit

/**
*  带队列的网络请求
*/
public class HDNetQueuedRequest: HDNetRequest
{
    public var queue: HDNetRequestQueue? //队列
    var _fProcessingQueue: HDNetRequestQueue? // 正在排队中的队列
    final override var isInProgress: Bool
    {
        get {
            if let v = _fProcessingQueue {
                if v.isInQueue(request: self) { //判断请求是否在队列中
                    return true
                }
            }
            return queuedInProgress() //判断请求是否在进行中
        }
        set {
            super.isInProgress = newValue
        }
    }
    
//+__________________________________________
    // 开始请求，子类应重写此方法
    func queuedStart() -> Bool
    {
        return false;
    }
    // 停止请求，子类应重写此方法
    func queuedStop()
    {
    }
    // 判断请求本身是否在进行中，子类重写此方法
    func queuedInProgress() -> Bool
    {
        return false
    }
    
//-__________________________________________
    final override func start() -> Bool
    {
        if queue == nil {
            return queuedStart()
        }
        queue?.enqueueRequest(self)
        return true
    }
    
    final override func cancel()
    {
        if _fProcessingQueue != nil {
            if _fProcessingQueue!.removeRequest(self) {
                return
            }
        }
        
        if isInProgress == false {
            return
        }
        queuedStop()
    }
    
    override func requestCompleted(error: NSError?)
    {
        if _fProcessingQueue != nil {
            _fProcessingQueue!.notifyRequestCompleted(self)
            _fProcessingQueue = nil
        }
        super.requestCompleted(error)
    }
    
    //新加入队列
    func onRequestQueueEnter(sender: HDNetRequestQueue)
    {
        _fProcessingQueue = sender
    }
    //退出队列
    func onRequestQueueLeave(sender: HDNetRequestQueue)
    {
        if _fProcessingQueue == sender {
            _fProcessingQueue = nil
        }
    }
}

//_______________________________________________________________________
/**
*  队列
*/
public class HDNetRequestQueue: NSObject
{
    var _requestQueue = [HDNetQueuedRequest]()
    var _requestCount: UInt = 0
    var _maxParrielRequestCount: UInt = 1 //最大的同时下载数
    
//+___________________________________________________
    // 将请求加入队尾
    func enqueueRequest(request: HDNetQueuedRequest!)
    {
        assert(request.isInProgress == false, "请求正在进行中")
        
        //从队列中删除
        var exists = _internalRemoveRequest(request)
        //重新加入队列
        _requestQueue.append(request)
        if exists == false {
            // 通知请求对象：新加入队列
            request.onRequestQueueEnter(self)
        }
        
        // 继续请求
        _continueProcessRequest()
    }
    
    // 移除请求
    func removeRequest(request: HDNetQueuedRequest!) -> Bool
    {
        if _internalRemoveRequest(request) {
            // 通知请求对象：退出队列
            request.onRequestQueueLeave(self)
            return true
        }
        return false
    }
    
    // 判断请求是否在队列中
    func isInQueue(#request: HDNetQueuedRequest!) -> Bool
    {
        for item in _requestQueue {
            if item == request {
                return true
            }
        }
        return false
    }
    
    // 由HDNetQueuedRequest调用，通知HDNetRequestQueue下载已完成
    func notifyRequestCompleted(request: HDNetQueuedRequest!)
    {
        assert(_requestCount != 0, "请求队列已为0")
        _requestCount--
        request.onRequestQueueLeave(self)
        _continueProcessRequest()
    }
    
//-___________________________________________________
    func _continueProcessRequest()
    {
        _doProcessRequest()
    }
    
    func _doProcessRequest()
    {
        while _requestCount < _maxParrielRequestCount {
            if _requestQueue.count == 0 {
                //没有等待中的请求
                return
            }
            //提取请求
            var request = _requestQueue[0]
            _requestQueue.removeAtIndex(0)
            
            //开始
            if request.queuedStart() {
                _requestCount++
            } else {
                //请求失败
            }
        }
    }
    
    func _internalRemoveRequest(request: HDNetQueuedRequest!) -> Bool
    {
        var i = 0
        for item in _requestQueue {
            if item == request {
                debugPrintln("删除")
                _requestQueue.removeAtIndex(i)
                return true
            }
            ++i
        }
        return false
    }
}
