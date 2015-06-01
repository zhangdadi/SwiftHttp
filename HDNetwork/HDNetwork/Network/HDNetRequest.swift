//
//  HDNetRequest.swift
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

@objc protocol HDNetRequestDelegate : NSObjectProtocol
{
    // 有进度改变的通知
    optional func netRequestProgress(sender: HDNetRequest)
    // 请求完成的通知
    optional func netRequestCompletion(#sender: HDNetRequest, error: NSError?)
}

//_______________________________________________________________________

class HDNetRequest: NSObject
{
    var isInProgress: Bool = false  //请求是否在进行中
    var delegate: HDNetRequestDelegate? //通知
    var responseData: NSData? // 网络返回数据
    // 进度值，从0到1
    var progressPercent: Float {
        return 0
    }
    var completedSize: Int = 0  // 已下载的字节数
    var expectedSize: Int { // 预期下载的字节数
    return 0
    }
    
    //+___________________________________________________
    //（网络请求回调）通知网络请求完毕
    func requestCompleted(error: NSError?)
    {
        delegate?.netRequestCompletion?(sender: self, error: error)
    }
    
    //开始请求,子类调用请求应用此方法，而不要用queuedStart
    func start() -> Bool
    {
        assert(false, "需要子类实现")
        return false
    }
    
    //取消请求,子类取消请求应用此方法，而不要用queuedStop
    func cancel()
    {
        assert(false, "需要子类实现")
    }
}

