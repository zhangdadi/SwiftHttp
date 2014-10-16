//
//  HDNetActivityIndicator.swift
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

class HDNetActivityIndicator: NSObject
{
    var showNetActivityIndicator: Bool = false
    {
        willSet {
            if showNetActivityIndicator == newValue {
                return // 标志无变化
            }
            if newValue {
                //增加显示引用
                if NSThread.isMainThread() {
                    HDNetActivityIndicator.addShow()
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        HDNetActivityIndicator.addShow()
                        })
                }
            } else {
                // 减少显示引用
                if NSThread.isMainThread() {
                    HDNetActivityIndicator.subShow()
                } else {
                    dispatch_async(dispatch_get_main_queue(), {
                        HDNetActivityIndicator.subShow()
                        })
                }
            }
        }
    }
    struct _NetActivityIndicator {
        static var visibleCount: Int = 0 //显示引用数
    }
    
//-________________________________________________________
    deinit
    {
        showNetActivityIndicator = false
    }
    
    class func addShow()
    {
        _NetActivityIndicator.visibleCount++
        if _NetActivityIndicator.visibleCount == 1 {
            //显示
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        }
    }
    
    class func subShow()
    {
        _NetActivityIndicator.visibleCount--
        if _NetActivityIndicator.visibleCount == 0 {
            // 延时隐藏
            var popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Float(NSEC_PER_SEC)));
            dispatch_after(popTime, dispatch_get_main_queue(), {
                UIApplication.sharedApplication().networkActivityIndicatorVisible = _NetActivityIndicator.visibleCount != 0
                })
        }
    }
}
