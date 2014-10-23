#HDNetworkKit-swift
用三层架构把界面层、服务层和网络层比较彻底的区分开来，大大的降低大模块之间的耦合度，有关网络数据之间的逻辑处理都放到服务层上，网络层管理网络请求，界面层负责界面显示，界面层请求数据唯一要做的就是组织参数，发起请求，显示结果就可以，不用做多余的处理，也不用知道这数据是以什么方式获取了，更不用知道请求这数据的url等，只要以a.param.uid=123这种方式组织好参数，然后NSString *name = a.data.name这种方式获取结果展示，如下图所示：

![1](http://zhangdadi.github.io/image/HDNetworkKit/1.jpg)
![2](http://zhangdadi.github.io/image/HDNetworkKit/2.png)


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
