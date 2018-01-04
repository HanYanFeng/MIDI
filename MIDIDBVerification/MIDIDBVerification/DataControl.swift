


import UIKit
class DataControl: NSObject {
    static var 单例 = DataControl()
    /// 储存曲谱简单全部模型
    var 简单曲谱模型数组 : [ScoreSimpl]
    var index: Int = 0
    override init() {
        简单曲谱模型数组 = []
    }
    
    func 通过id返回曲谱(scoreId : NSNumber) -> ScoreSimpl
    {
        var scoreSimpl : ScoreSimpl?
        for item in self.简单曲谱模型数组 {
            if item.iden ==  scoreId{
                scoreSimpl = item
                break
            }
        }
        if scoreSimpl == nil {
            scoreSimpl = self.简单曲谱模型数组.first
        }
        return scoreSimpl!
    }
    func getCurrentScoreSimpl() -> ScoreSimpl? {
        if index != 简单曲谱模型数组.count {
            return 简单曲谱模型数组[index]
        }
        return nil
    }
    func 下载任务BackData(urlString:String , back : @escaping ((_ succed : Bool,_ reason : String?, _ data : Data?) -> Void)){
        downLoadWithBackData(path: urlString) { (succed, reason , anyObject) in
            if succed {
                back(true, reason, anyObject as? Data)
            }else{
                back(false, reason, nil)
            }
        }
    }
    func 下载任务BackString(urlString:String , back : @escaping ((_ succed : Bool,_ reason : String?, _ path : String?) -> Void)){
        downLoadWith(path: urlString ,name: "score.db") { (suced, reacon, patch) in
            back(suced,reacon,patch?.path)
        }
    }
    func 通过id获取曲谱详情(scoreID : NSNumber,back: @escaping 网络访问回调类型)
    {
        NetWorkControl.通过id获取曲谱详情(scoreID: scoreID) { (succed, reason, anyObject) in
            if succed {
                if let scoreDetail = anyObject as? ScoreDetail {
                    back(true,nil,scoreDetail as AnyObject)
                }else{
                    back(false,"获取曲谱详情失败",nil)
                }
            }else{
                back(false,"获取曲谱详情失败",nil)
            }
        }
    }
}
