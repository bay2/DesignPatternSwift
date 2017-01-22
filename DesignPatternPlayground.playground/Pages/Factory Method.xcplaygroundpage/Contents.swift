//: [Previous](@previous)

import Foundation

/*:
 我们以创建一系列弹框为例子，尝试运用工厂方法实现多种样式的弹框的创建。
 这个列子的实现我们使用参数化的工厂方法。
 */

/*: 
 这里我们定义了三种常见的弹框:
- done 只有一个确定按钮的弹框
- comfirm 有两个按钮（确定和取消）
- share 常见的分享用的弹框
 */
enum AlertViewType {
    case done, comfirm, share
}

/*:
 AlertView 是 Product 同时也是 Creator
 */
class AlertView {
    
    static func createAlertView(with type: AlertViewType) -> AlertView {
        
        switch type {
        case .done:
            return DoneAlertView()
            
        case .comfirm:
            return ComfirmAlertView()
            
        case .share:
            return ShareAlertView()
 
        }
        
    }
    
//: 这里我们给弹框定义了一个统一的接口
    func show() {
        
    }
    
}

//: DoneAlertView 是 ConcreteProduct（只有一个确定按钮的弹框）
class DoneAlertView: AlertView {
    
    override func show() {
        print("完成确认的弹框样式。")
    }
    
}

//: ComfirmAlertView 是 ConcreteProduct（只有一个确定按钮的弹框）
class ComfirmAlertView: AlertView {
    
    override func show() {
        print("有两个按钮（确定和取消）的弹框样式。")
    }
    
}

//: ShareAlertView 是 ConcreteProduct（常见的分享用的弹框）
class ShareAlertView: AlertView {
    
    override func show() {
        print("常见的分享用的弹框的弹框样式。")
    }
    
}

//: 最后我们看看用户该如何使用

let doneAlert = AlertView.createAlertView(with: .done)
doneAlert.show()

let comfirmAlert = AlertView.createAlertView(with: .comfirm)
comfirmAlert.show()

let shareAlert = AlertView.createAlertView(with: .share)
shareAlert.show()

//: [Next](@next)
