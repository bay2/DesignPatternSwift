//: [Previous](@previous)

import Foundation

/*:
 # 生成器
 
 还是以构建迷宫游戏作为例子，来尝试使用 Swift 实现生成器模式。
 示例中，为了简单处理使用了许多强制解包的代码。在 Swift 开发中，尽量的少去使用强制解包的代码。
 */

//: 定义生成器
protocol MazeBuilder {
    
    func buildMaze()
    func buildRoom(n: Int)
    func buildDoor(roomFrom: Int, roomTo: Int)
    
    func getMaze() -> Maze?
    
}

extension MazeBuilder {
    
    func buildMaze() {}
    func buildRoom(n: Int) {}
    func buildDoor(roomFrom: Int, roomTo: Int) { }
    
    func getMaze() -> Maze? { return nil }
    
    
}

//: 首先我们需要定义一些基本的类型

enum Direction {
    case north, south, east, west
}

//: 定义 MapSite 表示地图位置
protocol MapSite {
    func enter()
}

extension MapSite {
    func enter() { }
}

protocol WallType: MapSite {
}

protocol DoorType: MapSite {
    
}

protocol RoomType: MapSite {
    
    var roomNo: Int { set get }
    
    var sides: [MapSite?] { set get }
    
    mutating func setSide(dect: Direction, site: MapSite)
    
}

extension RoomType {
    
    func getSide(dect: Direction) -> MapSite? {
        return sides[dect.hashValue]
    }
    
    mutating func setSide(dect: Direction, site: MapSite) {
        sides[dect.hashValue] = site
    }
    
}

//: 定义普通的房间
struct Room: RoomType {
    
    var sides: [MapSite?] = [nil, nil, nil, nil]
    var roomNo: Int
    
    init(no: Int) {
        roomNo = no
    }
    
}

extension Room: CustomStringConvertible {
    
    var description: String {
        return "Room"
    }
    
}


//: 定义普通的门
struct Door: DoorType {
    
    var isOpen = false
    var room1: RoomType
    var room2: RoomType
    
    init(r1: RoomType, r2: RoomType) {
        room1 = r1
        room2 = r2
    }
    
    
}

extension Door: CustomStringConvertible {
    
    var description: String {
        return "Door"
    }
    
}

//: 定义普通的墙
struct Wall: WallType {
    
}

extension Wall: CustomStringConvertible {
    
    var description: String {
        return "Wall"
    }
    
}


struct Maze {
    
    var roomDic: [String: RoomType] = [:]
    
    mutating func addRoom(room: RoomType) {
        roomDic["room_\(room.roomNo)"] = room
    }
    
    func room(form roomNo: Int) -> RoomType? {
        return roomDic["room_\(roomNo)"]
    }
    
    func getRoom(_ n: Int) -> Room {
        return roomDic["room_\(n)"] as! Room
    }
    
}

extension Maze: CustomStringConvertible {
    
    var description: String {
        
        var desc = "===========================\n"
        desc += "Maze room:\n"
        
        for (key, value) in roomDic {
            
            desc += "\(key) \(value) \n"
            desc += "north is \(value.getSide(dect: .north))\n"
            desc += "south is \(value.getSide(dect: .south))\n"
            desc += "east is \(value.getSide(dect: .east))\n"
            desc += "west is \(value.getSide(dect: .west))\n"
            
        }
        
        desc += "===========================\n"
        
        return desc
    }
    
}

//: 定义迷宫游戏

struct MazeGame {
    
    func createMaze(builder: MazeBuilder) -> Maze? {
        
        builder.buildMaze()
        
        builder.buildRoom(n: 1)
        builder.buildRoom(n: 2)
        
        builder.buildDoor(roomFrom: 1, roomTo: 2)
        
        return builder.getMaze()
        
    }
    
}

//: 标准的迷宫生成器
class StandarMazeBuilder: MazeBuilder {
    
    var currentMaze: Maze?
    
    func buildMaze() {
        currentMaze = Maze()
    }
    
    func buildRoom(n: Int) {
        
        var room = Room(no: n)
        
        room.setSide(dect: .east, site: Wall())
        room.setSide(dect: .north, site: Wall())
        room.setSide(dect: .south, site: Wall())
        room.setSide(dect: .west, site: Wall())
        
        currentMaze?.addRoom(room: room)
        
    }
    
//: commonWall 是个功能性操作，决定两个房间的公共墙壁的方位（为了简单处理我这里就固定返回一个值吧）
    func commonWall(r1: Room, r2: Room) -> Direction {
        return .north
    }
    
    func buildDoor(roomFrom: Int, roomTo: Int) {
        
        var r1 = currentMaze!.getRoom(roomFrom)
        
        var r2 = currentMaze!.getRoom(roomTo)
        
        let d = Door(r1: r1, r2: r2)
        
        r1.setSide(dect: commonWall(r1: r1, r2: r2), site: d)
        r2.setSide(dect: commonWall(r1: r2, r2: r1), site: d)
        
    }
    
    func getMaze() -> Maze? {
        return currentMaze
    }
    
}

//: 客户现在可以用 CreateMaze 和 StandarMazeBuilder 来创建个迷宫

let game = MazeGame()

let builder = StandarMazeBuilder()

game.createMaze(builder: builder)

let maze = builder.getMaze()

print("\(maze!)")

//: 接下来我们要创建生成器，它不创建迷宫。它仅对不同种类的构件进行计数。

class CountingMazeBuilder: MazeBuilder {
    
    
    var doors = 0
    var rooms = 0;
    
    func buildDoor(roomFrom: Int, roomTo: Int) {
        doors += 1
    }
    
    func buildRoom(n: Int) {
        rooms += 1
    }
    
    func getCounts() -> (r: Int, d: Int) {
        return (rooms, doors)
    }
    
}

//: 用户就可以这样使用 CountingMazeBuilder


let countingBuilder = CountingMazeBuilder()

game.createMaze(builder: countingBuilder)

let count = countingBuilder.getCounts()

print("The maze has \nrooms \(count.r) \ndoors \(count.d)")



//: [Next](@next)
