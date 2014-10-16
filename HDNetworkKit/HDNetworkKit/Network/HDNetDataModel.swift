//
//  HDNetDataModel.swift
//  HDNetFramework
//
//  Created by 张达棣 on 14-8-2.
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


public class HDNetDataObject: NSObject {
    public var updateDate:NSDate?
}

//___________________________________________________________________________
@objc public protocol HDNetCtrlDelegate: NSObjectProtocol {
    optional func netCtrlUpdate(ctrl:HDNetDataModel)
    optional func netCtrlProgress(ctrl:HDNetDataModel)
}


//__________________________________________________________________________
public class HDNetDataModel: NSObject, HDNetRequestDelegate {
//    //参数
//    var param:NSObject?
//    //数据内容
//    var data:HDNetDataObject?
    // 网络错误
    public var netError:NSError?
    // 是否正在下载中(包含正在下载中和正在队列中的请求)
    var isInProgress: Bool {
        get {
            return netRequest?.isInProgress ?? false
        }
        set {
            if netRequest != nil {
                netRequest!.isInProgress = newValue
            }
        }
    }
    // 进度值，从0到1
    public var progressValue: Float {
    if netRequest?.isInProgress ?? false {
        return netRequest?.progressPercent ?? 0
        }
        return 0
    }
    
    //多点回调通知
    weak public var delegate:HDNetCtrlDelegate? {
        get {
            return nil
        }
        set {
            _callList.push(newValue!)
        }
    }
    
    // 请求状态，用于多段请求.在此标识不为0时，持续进行请求
    var requestState = 0
    // 网络请求对象
    public var netRequest:HDNetRequest?
    var _callList = HDNetCallNode()
    
    //+_________________________________________________
    // 输出数据 必须在数据线程中调用
    public func outputData(newData: HDNetDataObject?) {
        assert(DataThreadInitSingleton.isDataThread(), "当前线程不是数据线程")
        _mainThreadAssigndata(newData)
    }
    // 调用通知 必须在数据线程中调用
    func callUpdate() {
        assert(DataThreadInitSingleton.isDataThread(), "当前线程不是数据线程")
        
        if isInProgress {
            return
        }
        
        isInProgress = true
        _mainThreadCallUpdate()
        self.isInProgress = false
    }
    
    // 启动请求 必须在数据线程中调用
    public func startRequestFunc() {
        assert(DataThreadInitSingleton.isDataThread(), "当前线程不是数据线程")
        setupRequestFunc()
        if netRequest == nil {
            //通知不加载
            callUpdate()
            return
        }
    }
    
    // 清除数据, 必须在数据线程中调用
    func clearResult() {
        outputData(nil)
        callUpdate()
    }
    
    //需要子类重写的内容,不需要调用super
    //子类创建网络请求并赋值给netRequest属性。在数据线程中执行
    public func _createRequest() {
        assert(false, "子类没有实现")
    }
    // 网络请求处理完毕，通知子类处理网络返回的数据。在数据线程中执行
    public func _processResponse() {
        assert(false, "子类没有实现")
        requestState = 0
    }
    
    deinit {
        debugPrintln("deinit")
        if netRequest != nil {
            netRequest!.delegate = nil
            DataThreadInitSingleton.shareInstance().onCall = self.netRequest!.cancel
            self.netRequest = nil
        }
    }
    
    //-_______________________________________________________
    // 有进度改变的通知
    func netRequestProgress(sender: HDNetRequest) {
        if netRequest === sender {
            _mainThreadCallProgress()
        }
    }
    // 请求完成的通知
    func netRequestCompletion(#sender: HDNetRequest, error: NSError?) {
        if netRequest !== sender {
            return
        }
        
        netError = error
        netRequest!.delegate = nil
        
        _processResponse()
        callUpdate()
        netRequest = nil
        if requestState != 0 { //判断是否持续进行请求
            // 继续下一个请求
            _setupRequest()
            if netRequest == nil {
                // 通知加载失败
                callUpdate()
            }
            return
        }
    }
    
    func setupRequestFunc() {
        //        assert(DataThreadInitSingleton.isDataThread(), "当前线程不是数据线程")
        clearRequest()
        requestState = 0
        _setupRequest()
    }
    
    func _setupRequest() {
        _createRequest()
        if netRequest != nil {
            netRequest!.delegate = self;
            netRequest?.start()
        }
        
        _mainThreadCallProgress()
    }
    
    func clearRequest() {
        //        assert(DataThreadInitSingleton.isDataThread(), "当前线程不是数据线程")
        
        if netRequest != nil {
            netRequest!.delegate = nil
            netRequest?.cancel()
            netRequest = nil
        }
    }
    
    //阻塞的主线程进度通知
    func _mainThreadCallProgress() {
        if NSThread.isMainThread() {
            self._callList.callProgress(self)
        } else {
            dispatch_sync(dispatch_get_main_queue(), {
                self._callList.callProgress(self)
            })
        }
    }
    
    //阻塞的主线程赋值
    func _mainThreadAssigndata(newData: HDNetDataObject?) {
        if NSThread.isMainThread() {
            if self.respondsToSelector(Selector("data")) {
                self.setValue(newData, forKey: "data");
            } else {
                assert(false, "请求结果属性名必需为data");
            }
        } else {
            if self.respondsToSelector(Selector("data")) {
                dispatch_sync(dispatch_get_main_queue(), {
                    self.setValue(newData, forKey: "data");
                })
            } else {
                assert(false, "请求结果属性名必需为data");
            }
        }
    }
    //阻塞的主线程通知
    func _mainThreadCallUpdate() {
        if NSThread.isMainThread() {
             _callList.callUpdate(self)
        } else {
            dispatch_sync(dispatch_get_main_queue(), {
                self._callList.callUpdate(self)
            })
        }
    }
}


