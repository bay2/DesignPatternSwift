//: [Previous](@previous)

import Foundation


class Manipulator {
    
}

protocol Shape {
    
    func boundingBox() -> (bottomLeft: CGPoint, topRight: CGPoint)
    
    func createManipulator() -> Manipulator
    
}

extension Shape {
    
    func boundingBox() -> (bottomLeft: CGPoint, topRight: CGPoint) {
        return (CGPoint.zero, CGPoint.zero)
    }
    
    func createManipulator() -> Manipulator {
        return Manipulator()
    }
}

class TextView {
    func getOrigin() -> CGPoint {
        return CGPoint(x: 10, y: 10)
    }
    
    func getExtent() -> CGSize {
        return CGSize(width: 10, height: 10)
    }
    
    func isEmpty() -> Bool {
        return false
    }
}

//: 我们采用对象适配器， TextShape 需要维护一个 TextView 对象。

class TextShape: Shape {
    
    let textView: TextView
    
    init(_ textView: TextView) {
        self.textView = textView
    }
    
    func boundingBox() -> (bottomLeft: CGPoint, topRight: CGPoint) {
        
        let origin = textView.getOrigin()
        let extent = textView.getExtent()
        
        let bottom = origin.x
        let left = origin.y
        
        return (CGPoint(x: bottom, y: left), topRight: CGPoint(x: bottom + extent.height, y: left + extent.width))
    
    }
    
    func createManipulator() -> Manipulator {
        return Manipulator()
    }
    
    func isEmpty() -> Bool {
        return textView.isEmpty()
    }
    
}

//: [Next](@next)
