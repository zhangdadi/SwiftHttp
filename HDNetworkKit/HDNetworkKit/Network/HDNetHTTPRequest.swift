//
//  HDNetHTTPRequest.swift
//  HDNetFramework
//
//  Created by 张达棣 on 14-7-31.
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
*  HTTP POST 请求参数类
*/
public class HDNetHTTPMutipartDataFormItem: NSObject {
    var fileName: String? //文件名
    var content: AnyObject? //数据内容,NSString 或 NSData
    var contentType: String? //数据类型
    
    //+___________________________________________________
    public class func item(#int: Int!) -> HDNetHTTPMutipartDataFormItem! {
        var str: String = int.description;
        return HDNetHTTPMutipartDataFormItem.item(str: str)
    }
    public class func item(#float: Float!) -> HDNetHTTPMutipartDataFormItem! {
        var str: String = float.description;
        return HDNetHTTPMutipartDataFormItem.item(str: str)
    }
    
    public class func item(#str: String!) -> HDNetHTTPMutipartDataFormItem! {
        var item = HDNetHTTPMutipartDataFormItem()
        item.contentType = "text/plain"
        item.content = str
        return item
    }
    
    public class func item(#data: NSData!) -> HDNetHTTPMutipartDataFormItem!  {
        var item = HDNetHTTPMutipartDataFormItem()
        item.contentType = "application/octet-stream"
        item.content = data
        return item
    }
    
    public class func item(#data: NSData!, fileName: String!) -> HDNetHTTPMutipartDataFormItem!  {
        var item = HDNetHTTPMutipartDataFormItem()
        item.contentType = "application/octet-stream"
        item.content = data
        item.fileName = fileName
        return item
    }
}

//_______________________________________________________________________


/**
*  HTTP请求
*/
public class HDNetHTTPRequest: HDNetQueuedRequest, NSURLConnectionDataDelegate
{
    //url
    public var destURL: NSURL?
    // POST multiple part 数据
    public var multipartDict: [String: HDNetHTTPMutipartDataFormItem]?
    //是否有缓存
    public var cached: Bool = false
    
    final override var expectedSize: Int {
    var len = 0
        if _response != nil {
            len = Int(_response!.expectedContentLength)
        }
        if len <= 0 {
            return 0;
        }
        return len
    }
    
    var _connection: NSURLConnection!
    var _request: NSMutableURLRequest = NSMutableURLRequest()
    var _response: NSHTTPURLResponse? // http返回对象
    var _error: NSError?  // 网络错误
    var _downloadingData: NSMutableData?
    var _HTTPInProgress = false
    var _netActIndicator = HDNetActivityIndicator()
    
    //进度信息
    override var progressPercent: Float {
    var len: Float = 0
        if _response != nil {
            len = Float(_response!.expectedContentLength)
        }
        if len < 0 {
            return 0;
        }
        return Float(Float(completedSize)/len)
    }
    
    //+___________________________________________________
    
    override public init()
    {
        _request.timeoutInterval = 25 //超时时间
        _request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
    }
    
    //-___________________________________________________
    func _doClear()
    {
        _response = nil
        _connection = nil
    }
    
    final override func queuedInProgress() -> Bool
    {
        return _HTTPInProgress
    }
    
    final override func queuedStart() -> Bool
    {
        if _HTTPInProgress {
            return false
        }
        
        _doClear()
        _HTTPInProgress = true
        completedSize = 0
        
        _request.URL = destURL
        _prepareRequestContent()
        //建立连接
        _connection = NSURLConnection(request: _request, delegate: self, startImmediately: false)
        _connection.scheduleInRunLoop(NSRunLoop.currentRunLoop(), forMode: NSDefaultRunLoopMode)
        _connection.start()
        _netActIndicator.showNetActivityIndicator = true
        
        debugPrintln("HTTP - \(_request.URL?.absoluteString)")
        return true
    }
    
    func _prepareRequestContent()
    {
        if multipartDict == nil || multipartDict?.count == 0 {
            return
        }
        
        //分界线的标识符
        let MPBoundary = "0xKhTmLbOuNdArY"
        // body data
        var formBody = NSMutableData()
        var endBoundaryData = "\r\n--\(MPBoundary)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)
        
        //文本字段
        for (key, item) in multipartDict!
        {
            var header = String()
            
            //分界线
            header += "\r\n--\(MPBoundary)\r\n"
            //字段名称
            header += "Content-Disposition: form-data; name=\"\(key)\""
            if item.fileName != nil && item.content != nil {
                header += "; filename=\"\(item.fileName)\"\r\n"
            } else {
                header += "\r\n"
            }
            //格式
            if item.contentType != nil {
                header += "Content-Type: \(item.contentType)\r\n"
            }
            //编码
            if item.content != nil && item.content!.isKindOfClass(NSData) {
                header += "Content-Transfer-Encoding: binary\r\n"
            }
            //头结束
            header += "\r\n"
            // 加入头
            formBody.appendData(header.dataUsingEncoding(NSUTF8StringEncoding)!)
            //加入数据
            if item.content != nil && item.content!.isKindOfClass(NSData) {
                var data = item.content as NSData
                formBody.appendData(data)
            } else if item.content != nil {
                var text = item.content as NSString
                formBody.appendData(text.dataUsingEncoding(NSUTF8StringEncoding)!)
            }
        }
        
        //加入结束符
        formBody.appendData(endBoundaryData!)
        
        //设置HTTPHeader中Content-Type的值
        var contentType = "multipart/form-data; boundary=\(MPBoundary)"
        
        //设置HTTPHeader
        _request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        //设置Content-Length
        _request.setValue(formBody.length.description, forHTTPHeaderField: "Content-Length")
        //设置http body
        // FormBody开头多带了一个换行，http头不再添加
        _request.HTTPBody = formBody
        //http method
        _request.HTTPMethod = "POST"
    }
    
    func connection(connection: NSURLConnection!, didReceiveResponse response: NSURLResponse!)
    {
        assert(_connection === connection, "NSURLConnection异常")
        
        _response = response as? NSHTTPURLResponse
        // 获取下载的预期大小
        var len = Int(response.expectedContentLength)
        if len < 0 {
            len = 0
        }
        
        //下载数据
        _downloadingData = NSMutableData(capacity: len)
    }
    
    func connection(connection: NSURLConnection!, didReceiveData data: NSData!)
    {
        assert(_connection === connection, "NSURLConnection异常")
        
        //积累下载大小
        completedSize += data.length
        _downloadingData?.appendData(data)
        
        //通知下载进度
        delegate?.netRequestProgress?(self)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection!)
    {
        assert(_connection === connection, "connection异常")
        
        // 下载完成数据
        responseData = _downloadingData?.copy() as NSData!
        _downloadingData = nil
        
        _doCompleted(nil)
    }
    
    func connection(connection: NSURLConnection!, didFailWithError error: NSError!)
    {
        _doCompleted(error)
    }
    
    //下载完成
    func _doCompleted(error: NSError!)
    {
        // <下载中>标志
        _HTTPInProgress = false
        
        // 关闭网络下载指示
        _netActIndicator.showNetActivityIndicator = false
        
        _error = error
        
        self.cached = false
        // 分析数据结束
        if error == nil {
            if _response != nil && _response!.statusCode == 304 {
                // 缓存标志
                self.cached = true
            }
        } else {
            debugPrintln("HTTP *ERROR* - \(destURL?.absoluteString) : \(error)")
        }
        
        //通知完成
        requestCompleted(error)
    }
    
    final override func queuedStop()
    {
        if (_connection != nil) {
            _connection?.cancel()
            _connection = nil
            var error = NSError(domain: NSPOSIXErrorDomain, code: Int(EINTR), userInfo: nil)
            _doCompleted(error)
        }
    }
}


























