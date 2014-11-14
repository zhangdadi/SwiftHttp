//
//  HDNetDataThread.swift
//  HDNetFramework
//
//  Created by 张达棣 on 14-8-3.
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
*  全局的数据线程单例
*/
struct DataThreadInitSingleton{
    static func shareInstance() -> HDNetDataThread
    {
        struct Singleton{
            static var predicate: dispatch_once_t = 0
            static var instance: HDNetDataThread?
        }
        dispatch_once(&Singleton.predicate, {
            
            func gDataThreadInit() -> HDNetDataThread {
                var len: UInt = 0
                var ncpu: UInt = 0
                len = UInt(sizeofValue(ncpu))
                sysctlbyname("hw.ncpu", &ncpu, &len, nil, 0)
                
                if ncpu <= 1 {
                    debugPrintln("network in main thread")
                    return HDNetDataThread()
                } else {
                    debugPrintln("network multithreaded")
                    return  HDNetDataThread()
                }
            }
            
            Singleton.instance = gDataThreadInit()
        })
        return Singleton.instance!
    }
    
    //判断当前线程是否为数据线程
    static func isDataThread() -> Bool {
        return NSThread.currentThread().isEqual(DataThreadInitSingleton.shareInstance())
    }
}

//________________________________________________________________________________________
/**
*  全局队列
*/
struct QueueSingleton {
    static func shareInstance() -> HDNetRequestQueue {
        struct Singleton{
            static var predicate: dispatch_once_t = 0
            static var instance: HDNetRequestQueue? = nil
        }
        dispatch_once(&Singleton.predicate, {
            Singleton.instance = HDNetRequestQueue()
        })
        return Singleton.instance!
    }
}

//_________________________________________________________________
/**
*  数据线程
*/
class HDNetDataThread: NSThread {
    typealias Call = () -> ()
    typealias CallParm = (i: Int) -> ()
    var onCall: Call? {
        set {
            _callList.append(newValue!)
        }
        get {
            return nil
        }
    }

    
    func setOnCallParm(callParm: CallParm, parm: Int) {
        _callParmList.append(callParm)
        _parmList.append(parm);
    }
    
    
    var _callList = [Call]()
    var _callParmList = [CallParm]()
    var _parmList = [Int]()
    
    init(sender: HDNetDataThread)  {
        
    }
    
    convenience override init() {
        self.init(sender: self)
        self.start()
    }
    
    override func main() {
        // 数据线程优先级调低（界面线程应该是0.5）
        NSThread.setThreadPriority(0.3)
        var i = 0
        while true {
            if _callList.count > 0 {
                _callList[0]()
                let v = _callList.removeAtIndex(0)
            }
            if _callParmList.count > 0 {
                _callParmList[0](i: _parmList[0])
                let v = _callList.removeAtIndex(0)
                let p = _parmList.removeAtIndex(0);
            }
            
            NSRunLoop.currentRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate.distantFuture() as NSDate)
        }
    }
}

//_________________________________________________________________
/**
*  多点回调
*/
//class HDNetCallNode: NSObject {
//    weak var _data: HDNetCtrlDelegate?
//    var _next: HDNetCallNode?
//    
//    func push(data: HDNetCtrlDelegate) {
//        pop(data)
//        var temp = self
//        while temp._next != nil {
//            temp = temp._next!
//        }
//        var newNode = HDNetCallNode()
//        newNode._data = data
//        temp._next = newNode
//    }
//    
//    func pop(index:Int) {
//        var lastTemp: HDNetCallNode? = self
//        var temp: HDNetCallNode? = self._next
//        var i = 0
//        while lastTemp?._next != nil && i <= index {
//            if i == index {
//                lastTemp?._next = temp?._next
//                temp?._data = nil
//                temp = nil
//            }
//            lastTemp = lastTemp?._next
//            temp = temp?._next
//            ++i
//        }
//    }
//    
//    func pop(data: HDNetCtrlDelegate) {
//        var lastTemp: HDNetCallNode? = self
//        var temp: HDNetCallNode? = self._next
//        
//        while lastTemp?._next != nil {
//            if data === temp?._data {
//                lastTemp?._next = temp?._next
//                temp?._data = nil
//                temp = nil
//            }
//            lastTemp = lastTemp?._next
//            temp = temp?._next
//        }
//    }
//    
//    func callUpdate(sender: HDNetDataModel) {
//        var temp = self
//        var i = 0
//        while temp._next != nil {
//            temp = temp._next!
//            if temp._data != nil {
//                temp._data?.netCtrlUpdate?(sender)
//            } else {
//               pop(i)
//            }
//            ++i
//        }
//    }
//    
//    func callProgress(sender: HDNetDataModel) {
//        var temp = self
//        while temp._next != nil {
//            temp = temp._next!
//            temp._data?.netCtrlProgress?(sender)
//        }
//    }
//    
//    func _find(data:HDNetCtrlDelegate) -> Bool {
//        var temp = self
//        while temp._next != nil {
//            temp = temp._next!
//            if temp._data === data {
//                return true
//            }
//        }
//        return false
//    }
//}





