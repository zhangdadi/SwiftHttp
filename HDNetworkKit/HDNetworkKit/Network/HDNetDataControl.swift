//
//  HDNetDataControl.swift
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

public class HDNetDataControl: HDNetDataModel {
    
    //+________________________________________
    // 刷新：清空当前数据，并重新下载
    public func refresh() {
        weak var weakSelf = self
        DataThreadInitSingleton.shareInstance().onCall = weakSelf?._refreshFunc
    }
    
    // 更新：下载数据然后替换原内容
    public func update() {
        weak var weakSelf = self
        DataThreadInitSingleton.shareInstance().onCall = weakSelf?.startRequestFunc
        
    }
    
    // 加载：如果无数据则下载，否则不做操作
    public func load() {
        weak var weakSelf = self
        DataThreadInitSingleton.shareInstance().onCall = weakSelf?._loadFunc
    }
    
    // 加载缓存：只尝试加载缓存数据
    public func loadCache() {
        weak var weakSelf = self
        DataThreadInitSingleton.shareInstance().onCall = weakSelf?._loadCacheFunc

    }
    
    //-__________________________________________________________________________
    func _refreshFunc() {
        outputData(nil)
        startRequestFunc()
    }
    
    func _loadFunc() {
        if isInProgress {
            return
        }
//        if data != nil && netError == nil {
//            return
//        }
        
        startRequestFunc()
    }
    
    func _loadCacheFunc() {
        if isInProgress {
            return
        }
//        if data != nil && netError == nil {
//            return
//        }
        
        setupRequestFunc()
        clearRequest()
    }
}


//__________________________________________________________________________
public class HDNetDataPageControl: HDNetDataModel {
    // 是否还有更多页面可以加载
    var hasMorePage = false
    // 是否正在进行首次加
    var isLoadingFirst: Bool {
    if netRequest == nil || pageCount != 0 || requestingPage != 0 {
        return false
    } else {
        return netRequest!.isInProgress
        }
    }
    // 请求中的页号
    var _requestingPage = 0
    var requestingPage: Int {
    return _requestingPage
    }
    // 当前已知的页数，用于整理页面加载标志
    var pageCount: Int {
    get {
        return _pageNeedLoad.count
    }
    set {
        _pageNeedLoad = [Bool](count: newValue, repeatedValue: true)
    }
    }
    
    var _pageNeedLoad = [Bool]() //是否需要下载，已经下载过的页面为true
    var _requestintParam: NSObject?
    //+________________________________________
    // 刷新：清空当前数据，并重新下载
    public func refresh() {
        weak var weakSelf = self
        DataThreadInitSingleton.shareInstance().onCall = weakSelf?._refreshFunc

    }
    // 更新：下载数据然后替换原内容
    public func update() {
        weak var weakSelf = self
        DataThreadInitSingleton.shareInstance().onCall = weakSelf?._updateFunc

    }
    // 加载：如果无数据则下载，否则不做操作
    public func load() {
        weak var weakSelf = self
        DataThreadInitSingleton.shareInstance().onCall = weakSelf?._loadFunc
    }
    // 清空：清除所有数据
    public func clear() {
        weak var weakSelf = self
        DataThreadInitSingleton.shareInstance().onCall = weakSelf?.clearRequest
    }
    
    // 重置下载标志：让loadPageAtItemIndex方法重新加载内容
    public func setNeedsUpdate() {
        weak var weakSelf = self
        DataThreadInitSingleton.shareInstance().onCall = weakSelf?._setNeedsUpdateFunc
    }
    // 重新加载特定项目所在页面的内容
    public func loadPageAtItemIndex(index: Int) {
        weak var weakSelf = self
        DataThreadInitSingleton.shareInstance() .setOnCallParm(_loadPageAtItemIndexFunc, parm: index)

    }
    // 加载更多页面，如果hasMorePage为真
    public func loadMore() {
        weak var weakSelf = self
        DataThreadInitSingleton.shareInstance().onCall = weakSelf?._loadMoreFunc

    }
    
    //需要子类重写的内容,不需要调用super
    func convertItemIndexToPageIndex(itemIndex: Int) -> Int {
        assert(false, "子类没有重写")
        return -1
    }
    
    //-_______________________________________________________________________
    func _updateFunc() {
        _requestingPage = 0
        _setNeedsUpdateFunc()
        startRequestFunc()
    }
    
    func _refreshFunc() {
        outputData(nil)
        pageCount = 0
        _requestingPage = 0
        startRequestFunc()
    }
    
    func _loadFunc() {
        if isInProgress {
            return
        }
        
//        if data != nil && netError == nil {
//            return
//        }
        
        pageCount = 0
        _requestingPage = 0
        startRequestFunc()
    }
    
    
    func _loadMoreFunc() {
        if isInProgress {
            return
        }
        
//        if data == nil {
//            pageCount = 0
//            _requestingPage = 0
//            startRequestFunc()
//        } else {
//            if !hasMorePage {
//                return
//            }
//            hasMorePage = false
//            _requestingPage = pageCount
//            startRequestFunc()
//        }
    }
    
    func _setNeedsUpdateFunc() {
        for var i = 0; i < _pageNeedLoad.count; ++i {
            _pageNeedLoad[i] = true
        }
    }
    
    func _loadPageAtItemIndexFunc(index: Int) {
        if isInProgress {
            return
        }
        
        var pageIndex = convertItemIndexToPageIndex(index)
        if pageIndex >= pageCount {
            return
        }
        
        if _pageNeedLoad[pageIndex] == false {
            return
        }
        
        _pageNeedLoad[pageIndex] = false
        _requestingPage = pageIndex
        startRequestFunc()
    }
    
}









