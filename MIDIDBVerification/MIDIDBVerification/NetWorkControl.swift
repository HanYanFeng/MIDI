//
//  NetWorkControl.swift
//  琴加
//
//  Created by 袁银花 on 2017/5/16.
//  Copyright © 2017年 韩艳锋. All rights reserved.
//

import UIKit
typealias 网络访问回调类型 = ( _ succed : Bool,_ reasion :String?, _ backObject : AnyObject?) -> Void

class NetWorkControl: NSObject {
    static func 加载所有曲谱信息(back : @escaping 网络访问回调类型){
        let urlStr = "保密"//
        postWithPath(path: urlStr, paras: ["platformType":"9","appVersion": "1.0.9"], success: { (any) in
            let data = any as? [String:AnyObject]
            if let data = data {
                let list = data["list"] as? [[String:AnyObject]]
                var backData : [ScoreSimpl] = []
                if let list = list {
                    for dic in list {
                        if let ssss = ScoreSimpl(dic: dic as [String : AnyObject]) {
                            backData.append(ssss)
                        }else{
                            print("错误100")
//                            back(false, "请求失败", nil)
//                            return
                        }
                    }
                    back(true, nil, backData as AnyObject?)
                }else{
                    back(false, "获取曲谱失败", nil)
                }
            }else{
                back(false, "获取曲谱失败", nil)
            }
        }) { (error) in
            back(false, "获取曲谱失败", nil)
        }
        
    }
    static func 通过id获取曲谱详情(scoreID : NSNumber,back: @escaping 网络访问回调类型)
    {
        let sendDara: [String: String] = [
            "id":"\(scoreID)",
            "platformType":"9",
            "appVersion":"1.0.9"
        ]
        
        getWithPath(path: "保密", paras: sendDara, success: { (any) in
            if  let data =  any as? [String : AnyObject] {
                if let item = data["item"] as? [String : AnyObject]{
                    if let backValue = ScoreDetail(dic: item) {
                        back(true,nil, backValue)
                    }else{
                        back(false, "解析失败", nil)
                    }
                }else{
                    back(false, "解析失败", nil)
                }
            }else{
                back(false, "解析失败", nil)
            }
        }) { (error) in
            let nserror = error as NSError
            back(false, "获取曲谱详情失败\(nserror.code)", nil)
        }
    }
}


func getWithPath(path: String,paras: Dictionary<String,Any>?,success: @escaping ((_ result: Any) -> ()),failure: @escaping ((_ error: Error) -> ())) {
    
    var i = 0
    var address = path
    if let paras = paras {
        
        for (key,value) in paras {
            
            if i == 0 {
                
                address += "?\(key)=\(value)"
            }else {
                
                address += "&\(key)=\(value)"
            }
            
            i += 1
        }
    }
    
    let url = URL(string: address.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
    
    let session = URLSession.shared
    var request = URLRequest(url: url!)

        request.cachePolicy = .returnCacheDataDontLoad
    let dataTask = session.dataTask(with: request) { (data, respond, error) in
        if let data = data {
            do{
                let result = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    success(result)
            }catch let error {
                failure(error)
                print(error)
            }
        }else {
                failure(error!)
        }
    }
    dataTask.resume()
}


// MARK:- post请求
func postWithPath(path: String,paras: Dictionary<String,Any>?,success: @escaping ((_ result: Any) -> ()),failure: @escaping ((_ error: Error) -> ())) {
   
    var i = 0
    var address: String = ""

    if let paras = paras {

        for (key,value) in paras {
            
            if i == 0 {
                
                address += "\(key)=\(value)"
            }else {
                
                address += "&\(key)=\(value)"
            }
            
            i += 1
        }
    }
    let url = URL(string: path)
    var request = URLRequest.init(url: url!)
    request.httpMethod = "POST"
    request.httpBody = address.data(using: .utf8)
//    request.cachePolicy = .reloadIgnoringLocalCacheData

        request.cachePolicy = .returnCacheDataDontLoad
    let session = URLSession.shared
    let dataTask = session.dataTask(with: request) { (data, respond, error) in
        
        if let data = data {
            if let result = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) {
                    success(result)
            }else{
            }
        }else {
                failure(error!)
        }
    }
    dataTask.resume()
}
func downLoadWith(path : String,name:String,back: @escaping 网络访问回调类型) {
    //创建URL对象
    let url = URL(string:path)
    if let url = url{
        let session = URLSession.shared
        var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 15)
        request.cachePolicy = .returnCacheDataDontLoad
        let dataTas = session.dataTask(with: request, completionHandler: { (backUrl, response, error) in
            if let backUrl = backUrl {
                let fileManager = FileManager.default
                let homeDirectory = NSHomeDirectory()
                let toUrl = homeDirectory + "/Documents/" + name
                try? fileManager.removeItem(atPath: toUrl)
                do{
                    try backUrl.write(to: URL(fileURLWithPath: toUrl))
                    back(true,nil,URL(fileURLWithPath: toUrl) as AnyObject?)
                }catch{
                    back(false,"下载失败",nil)
                }
//                try! fileManager.moveItem(atPath: srcUrl, toPath: toUrl)
            }else{
                let nserror = error! as NSError
                back(false,"下载失败\(nserror.code)",nil)
            }
        })
        dataTas.resume()

    }else{
        back(false,"下载失败\(-1)",nil)
    }
    
}

func downLoadWithBackData(path : String ,back: @escaping 网络访问回调类型) {
    let url = URL(string:path)
    if let url = url{
        var requse = URLRequest(url: url, cachePolicy: NSURLRequest.CachePolicy.returnCacheDataElseLoad, timeoutInterval: 20)
    
            requse.cachePolicy = .returnCacheDataDontLoad
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: requse, completionHandler: { (backUrl, response, error) in
            if let backUrl = backUrl {
                    back(true, nil, backUrl as AnyObject?)
            }else{
                let nserror = error! as NSError
                if nserror.code == -1009 {
                        back(false,"网络未连接",nil)
                }else{
                        back(false,"下载失败\(nserror.code)",nil)
                }
            }
        })
        dataTask.resume()
        
    }else{
            back(false,"下载失败\(-1)",nil)
    }
}

func downLoadWithBackDataNocachePolicy(path : String ,back: @escaping 网络访问回调类型) {
    let url = URL(string:path)
    if let url = url{
        var requse = URLRequest(url: url, cachePolicy: NSURLRequest.CachePolicy.returnCacheDataElseLoad, timeoutInterval: 20)
//        requse.cachePolicy = NSURLRequest.CachePolicy.reloadIgnoringCacheData;
      
            requse.cachePolicy = .returnCacheDataDontLoad
        let session = URLSession.shared
        let dataTask = session.downloadTask(with: requse, completionHandler: { (backUrl, response, error) in
            if let backUrl = backUrl {
                if let data = try? Data(contentsOf: backUrl ) {
                        back(true, nil, data as AnyObject?)
                }else{
                        back(false, "下载失败-3", nil)
                }
            }else{
                let nserror = error! as NSError
                if nserror.code == -1009 {
                        back(false,"网络未连接",nil)
                }else{
                        back(false,"下载失败\(nserror.code)",nil)
                }
            }
        })
        dataTask.resume()
        
    }else{
        back(false,"下载失败\(-1)",nil)
    }
}

/// 没有缓存的get请求 用于上传数据
///
/// - Parameters:
///   - path: 地址
///   - paras: 参数
///   - success: 成功回调
///   - failure: 失败回调
func 上传数据getMethods(path: String,paras: Dictionary<String,Any>?,success: @escaping ((_ result: Any) -> ()),failure: @escaping ((_ error: Error) -> ())) {
    
    var i = 0
    var address = path
    if let paras = paras {
        
        for (key,value) in paras {
            
            if i == 0 {
                
                address += "?\(key)=\(value)"
            }else {
                
                address += "&\(key)=\(value)"
            }
            
            i += 1
        }
    }
    
    let url = URL(string: address.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!)
    
    let session = URLSession.shared
    var request = URLRequest(url: url!)
    request.cachePolicy = .reloadIgnoringLocalCacheData

    let dataTask = session.dataTask(with: request) { (data, respond, error) in
        if let data = data {
            
            if let result = try? JSONSerialization.jsonObject(with: data, options: .allowFragments){
                
                    success(result)
            }
        }else {
                failure(error!)
        }
    }
    dataTask.resume()
}

/// 无缓存的post请求 用于上传数据
///
/// - Parameters:
///   - path: 地址
///   - paras: 上传的数据
///   - success: 成功回调
///   - failure: 失败回调
func 上传数据postWith(path: String,paras: Dictionary<String,Any>?,success: @escaping ((_ result: [String:Any]) -> ()),failure: @escaping ((_ error: Error) -> ())) {
    
    var i = 0
    var address: String = ""
    
    if let paras = paras {
        
        for (key,value) in paras {
            
            if i == 0 {
                
                address += "\(key)=\(value)"
            }else {
                
                address += "&\(key)=\(value)"
            }
            
            i += 1
        }
    }
    let url = URL(string: path)
    var request = URLRequest.init(url: url!)
    request.httpMethod = "POST"
    request.httpBody = address.data(using: .utf8)
    request.cachePolicy = .reloadIgnoringLocalCacheData
  
    let session = URLSession.shared
    let dataTask = session.dataTask(with: request) { (data, respond, error) in
        
        if let data = data {
            if let result = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) {
                    success(result as! [String: Any])
            }else{
                print("解析出错")
            }
        }else {
            failure(error!)
        }
    }
    dataTask.resume()
}
