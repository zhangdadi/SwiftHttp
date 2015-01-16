#SwiftHttp

##1. 概述

```
 swift语言封闭方便使用的Http请求，只要简单的POST方法调用，传入url和请求参数字典就可以了。
 
```
    
    
##2. 功能特性

```
 1) 整个应用共享单一队列
    严重依赖网络连接的应用应该优化他们的网络并发连接数。十分不幸的是，现在还没有网络库可以正确的完成这些功能。让我来举个例子说明如果你不去优化或者控制网络的并发连接数会发生什么。
    假如你正在上传一系列的图片（比如Color和 Batch）到服务器。大多数的移动网络（3G）不允许一个给定的IP地址超过两个的并发的http请求。这就是说，在你的设备上，3G网络下，你不能同时打开超过两个的并发HTTP请求。EDGE网络就更差了，大多数情况下你甚至不能打开超过一个的连接。这个限制在传统的wifi的情况下是相当高的（6个）。但是，你的设备并不总是连接到Wifi下，你应该为受限制的网络环境考虑。在最普通的情况下你的设备都是连接到3G网络，就是说你被限制同时只能上传2张图片。现在问题的关键不是上传两张图片时很慢，而是当你上传图片时再打开一个新的View，这个view在加载图片的缩略图的时候。当你不去通过app控制正确的队列大小时，你的缩略图加载操作就会超时，这种现象可不是正确的。正确的做法是把缩略图的加载排好优先级，或者等待上传完成后再加载缩略图。这就要求你的app有一个全局的队列。HDNetwork自动的保证你的app的每一个队列的实例使用单一的共享队列。虽然MKNetworkKit自己不是单例的，但是他的共享队列是。
    
 2) 正确的显示网络连接的标志 
    现在有许多第三方的类使用记录网络调用的次数的方式来控制网络链接标志的显示。但HDNetwork使用的是单一共享队列原则来控制网络标志的显示。作为一个开发者，妈妈再也不用担心手动设置网络连接标志的问题了。
 
```

**3. 使用方法**

    1) 引入HDNetwork.framework
    2) 在使用的类里加入‘import HDNetwork’代码
    使用时 DNetHTTPRequestManager().GET(url, parameters: 参数, completion: 请求完成回调blcok)就可以。

**4. 示例**

```
1) POST请求
        HDNetHTTPRequestManager().POST("http://www.v2ex.com/api/nodes/all.json", parameters: nil, completion: {
            (data: NSData?, error: NSError?) -> Void in
            if error != nil {
                println("请求all失败")
                return
            }

            println("请求all成功")
            var json = JSON(data: data!, options: nil, error: nil)
            let mid = json[0]["id"].integerValue

     
2) GET请求

            //参数设置
            let paramDict = ["id": HDNetHTTPItem(value: mid!)]
            HDNetHTTPRequestManager().GET("http://www.v2ex.com/api/nodes/show.json", parameters: paramDict, completion: {
                (data: NSData?, error: NSError?) -> Void in
                if error != nil {
                   println("请求show.json失败")
                } else {
                    json = JSON(data: data!, options: nil, error: nil)
                    println(json)
                    var titel = json["title"].stringValue
                    println("请求show.json成功,标题为=\(titel)")
                }
            })
        })


```

    

 
