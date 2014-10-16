#HDNetworkKit-swift

使用方法

界面层：

```
let infoCtrl = DCDataCtrl_nodes() //初始化
infoCtrl.delegate = self //多点回调委托，可以同时指向多点对象并回调多个对象
infoCtrl.param.mID = car.data?.listArray?[0].mID //组织参数
infoCtrl.refresh() //请求

```
服务层DCDataCtrl_nodes接口定义

```
public class DCData_nodesObj: DCDataObject { //结果类,界面层直接拿到就使用
    public var mID: Int? //id
    public var name: String? //节点名
    public var title: String? //标题
    public var url: NSURL? //url
    
}

public class DCData_nodesParam: NSObject { //参数类
    public var mID: Int? //id
}

public class DCDataCtrl_nodes: DCDataControl {
    public var data: DCData_nodesObj? //结果
    public var param = DCData_nodesParam() //参数
    
    //初始化请求
    override func dataRequest() {
        //post请求 这样传参
        let muParam: [String: HDNetHTTPMutipartDataFormItem] = ["id": HDNetHTTPMutipartDataFormItem.item(int: param.mID)]
        autoRequest(urlSuffix: "nodes/show.json", mutiPart: muParam)
    }
    
    //解析数据
    override func dataProcess(data: NSData?, updateDate: NSDate)  {
        var obj = DCData_nodesObj()
        obj.updateDate = updateDate
        let json = JSON(data: data!, options: nil, error: nil)
        
        obj.mID = json["id"].integerValue
        obj.name = json["name"].stringValue
        obj.title = json["title"].stringValue
        obj.url = json["url"].URLValue
        outputData(obj)
    }
}

```

项目工程驾构图

![1](http://zhangdadi.github.io/image/HDNetworkKit/1.png)