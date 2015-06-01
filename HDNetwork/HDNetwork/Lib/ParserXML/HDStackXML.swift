//
//  HDStackXML.swift
//  demoPhone
//
//  Created by 张达棣 on 14-8-10.
//  Copyright (c) 2014年 HD. All rights reserved.
//

import UIKit

class HDStackXML: NSObject {
    var _starckArray = [String]()
    
    /**
    *  入栈
    *
    */
    func push(str: String?) {
        if str == nil || str == "" || str == " " {
            return
        }
        
        _starckArray.append(str!)
    }
    
    
    /**
    *  出栈
    *
    */
    func pop() -> String? {
        var str = _starckArray.last
        _starckArray.removeLast()
        return str
    }
    
    func _stackCount() -> Int {
        return _starckArray.count
    }
}
