//: [Previous](@previous)

import Foundation

//: 首先创建个枚举表示四个方向
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

/*:定义 3 个 protocol 分别表示 3 种地图上的元素
 1. 墙（WallType）
 2. 门（DoorType）
 3. 房间（RoomType）
 */
protocol WallType: MapSite {
    
    func clone() -> WallType
    
}

protocol DoorType: MapSite {
    
    func clone() -> DoorType
    func initialize(r1: RoomType, r2: RoomType)
    
}

protocol RoomType: MapSite {
    
    var roomNo: Int { set get }
    
    var sides: [MapSite?] { set get }
    
    mutating func setSide(dect: Direction, site: MapSite)
    
    init(no: Int)
    
}


//:定义一个抽象工厂
protocol MazeFactory {
    
    
    func makeMaze() -> Maze
    
    func makeWall() -> WallType
    
    func makeRoom(_ n: Int) -> RoomType
    
    func makeDoor(r1: RoomType, r2: RoomType) -> DoorType
    
    
}

class Maze {
    
    var roomDic: [String: RoomType] = [:]
    
    func addRoom(room: RoomType) {
        roomDic["room_\(room.roomNo)"] = room
    }
    
    func room(form roomNo: Int) -> RoomType? {
        return roomDic["room_\(roomNo)"]
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

//: 由于 RoomType 的 getSide，setSide 属于 Room 的通用操作。所以这里通过协议扩展对这两个操作进行实现
extension RoomType {
    
    func getSide(dect: Direction) -> MapSite? {
        return sides[dect.hashValue]
    }
    
    mutating func setSide(dect: Direction, site: MapSite) {
        sides[dect.hashValue] = site
    }
    
}


//: 定义普通的门
class Door: DoorType {
    
    var isOpen = false
    var room1: RoomType
    var room2: RoomType
    
    init(r1: RoomType, r2: RoomType) {
        room1 = r1
        room2 = r2
    }
    
    init() {
        room1 = Room()
        room2 = Room()
    }
    
    
}

extension Door: CustomStringConvertible {
    
    var description: String {
        return "Door"
    }
    
}

//: 定义普通的墙
class Wall: WallType {
    
}

extension Wall: CustomStringConvertible {
    
    var description: String {
        return "Wall"
    }
    
}



//: 定义普通的房间
struct Room: RoomType {
    
    var sides: [MapSite?] = [nil, nil, nil, nil]
    var roomNo: Int
    
    init(no: Int) {
        roomNo = no
    }
    
    init() {
        roomNo = 0
    }
    
}

extension Room: CustomStringConvertible {
    
    var description: String {
        return "Room"
    }
    
}

//: 定义一个迷宫游戏，通过 createMaze 方法来创建游戏中的迷宫
struct MazeGame {
    
    static func createMaze<T: MazeFactory>(mazeFactory: T) -> Maze {
        
        let maze = mazeFactory.makeMaze()
        var r1 = mazeFactory.makeRoom(1)
        var r2 = mazeFactory.makeRoom(2)
        let theDoor = mazeFactory.makeDoor(r1: r1, r2: r2)

        
        r1.setSide(dect: .north, site: mazeFactory.makeWall())
        r1.setSide(dect: .east, site: theDoor)
        r1.setSide(dect: .south, site: mazeFactory.makeWall())
        r1.setSide(dect: .west, site: mazeFactory.makeWall())

        r2.setSide(dect: .north, site: mazeFactory.makeWall())
        r2.setSide(dect: .east, site: mazeFactory.makeWall())
        r2.setSide(dect: .south, site: mazeFactory.makeWall())
        r2.setSide(dect: .west, site: theDoor)
        
        maze.addRoom(room: r1)
        maze.addRoom(room: r2)
        
        return maze
        
    }
    
}


//: MazePrototyprFactory 存有 Maze, DoorType, WallType, RoomType 的原型
//: 新的构造器只初始化它的原型
class MazePrototypeFactory<W, D, R>: MazeFactory where W: WallType, D: DoorType, R: RoomType {
    
    var prototypeMaze: Maze
    var prototypeDoor: D
    var prototypeWall: W
    var prototypeRoom: R
    
    func makeRoom(_ n: Int) -> RoomType {
        return R(no: n)
    }
    
    func makeMaze() -> Maze {
        return Maze()
    }
    
    init(m: Maze, d: D, w: W, r: R) {
        prototypeMaze = m
        prototypeDoor = d
        prototypeWall = w
        prototypeRoom = r
    }
    
}

//: 定义克隆函数
extension Door {
    
    func clone() -> DoorType {
        let cloneDoor = Door(r1: self.room1, r2: self.room2);
        cloneDoor.isOpen = self.isOpen
        return cloneDoor
    }
    
    func initialize(r1: RoomType, r2: RoomType) {
        room1 = r1
        room2 = r2
    }
    
}

extension Wall {
    
    func clone() -> WallType {
        return Wall()
    }
}


//: 现在我们以克隆原型的方式定义，makeWall 和 makeDoor
extension MazePrototypeFactory {
    
    func makeWall() -> WallType {
        return prototypeWall.clone()
    }
    
    func makeDoor(r1: RoomType, r2: RoomType) -> DoorType {
        let door = prototypeDoor.clone()
        door.initialize(r1: r1, r2: r2)
        return door
    }
    
}


//: 我们只需要使用基本的原型进行初始化,就可以由 MazePrototypeFactory 来创建一个原型的或缺省得迷宫
let simpleMazeFactory = MazePrototypeFactory(m: Maze(), d: Door(), w: Wall(), r: Room())
let game = MazeGame.createMaze(mazeFactory: simpleMazeFactory)

print("\(game)")

//: 和之前的例子一样，我们又需要定义一个 Bombed 的迷宫

//: 构建 RoomWithABomb 表示有炸弹的房间
struct RoomWithABomb: RoomType {
    

    
    var sides: [MapSite?] = [nil, nil, nil, nil]
    var roomNo: Int
    var isBombe: Bool
    
    init(_ n: Int, isBombe: Bool) {
        roomNo = n
        self.isBombe = isBombe
    }
    
    init(no: Int) {
        self.roomNo = no
        self.isBombe = false
    }
    
    init() {
        self.roomNo = 0
        self.isBombe = false
    }
    
}

extension RoomWithABomb: CustomStringConvertible {
    
    var description: String {
        return "RoomWithABomb Bombe is \(isBombe)"
    }
    
}

//: 构建 BombedWall 表示被炸毁的墙
struct BombedWall: WallType {
    
    internal func clone() -> WallType {
        return BombedWall(self.isBombed)
    }

    
    var isBombed: Bool
    
    init(_ isBombe: Bool) {
        self.isBombed = isBombe
    }
    
    init() {
        self.isBombed = false
    }
    
}

extension BombedWall: CustomStringConvertible {
    var description: String {
        return "BombedWall Bombe is \(isBombed)"
    }
}


let bombMazeFactory = MazePrototypeFactory(m: Maze(), d: Door(), w: BombedWall(), r: RoomWithABomb())
let bombedGame = MazeGame.createMaze(mazeFactory: bombMazeFactory)

print("\(bombedGame)")


//: [Next](@next)
