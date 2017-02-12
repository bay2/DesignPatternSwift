//: [Previous](@previous)

import Foundation

/*:
 Swift 上单例的实现，其实很简单。我们只需要使用 `static` 就可以创建一个全局的实例了，不行像 OC 那样使用 `dispatch_once` 来保证线程安全。
  我们使用 `fileprivate` 来修饰我们的构造函数。这确保没有其他创建实例的手段。
 
 */
struct MazeFactory {
    
    static let interface = MazeFactory()
    
    fileprivate init() {
    }
    
    func makeMaze() {
        print("This is Maze.")
    }
    
}

MazeFactory.interface.makeMaze()

//: [Next](@next)
