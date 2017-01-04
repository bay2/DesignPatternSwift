import Foundation

//: [Previous](@previous)

/*:
 例子：
 为电脑游戏创建一个迷宫。迷宫定义了一系列房间，一个房间知道他的邻居；可能的邻居要么是另一个房间，要么是一堵墙、或者是另一个房间的门。
 
 */


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
}

protocol DoorType: MapSite {
    
}

protocol RoomType: MapSite {
    
    var roomNo: Int { set get }
    
    var sides: [MapSite?] { set get }
    
    mutating func setSide(dect: Direction, site: MapSite)
    
}

//: 定义一个迷宫的类型，《设计模式》书中的例子是用 C++ 和 Smalltalk 去写的。而我是使用 Swift 去写，在使用 Swift 的时候，我更喜欢使用 struct 代替 class。
struct Maze {
    
    var roomDic: [String: RoomType] = [:]
    
    mutating func addRoom(room: RoomType) {
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

//: 定义普通的墙
struct Wall: WallType {
    func enter() {
    }
}

extension Wall: CustomStringConvertible {
    
    var description: String {
        return "Wall"
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


func == (lhs: RoomType, rhs: RoomType) -> Bool {
    return lhs.roomNo == rhs.roomNo
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
    
    mutating func otherSide(form room: RoomType) -> RoomType {
        
        isOpen = true
        
        if (room == room1) {
            return room2
        } else {
            return room1
        }
        
    }
    
}

extension Door: CustomStringConvertible {
    
    var description: String {
        return "Door"
    }
    
}

/*: 书中使用抽象类实现 MazeFactory，在 Swift 我们可以使用 Protocol 实现抽象类的功能。
 */
protocol MazeFactory {
    
    associatedtype RoomMazeType: RoomType
    associatedtype WallMazeType: WallType
    associatedtype DoorMazeType: DoorType
    
    func makeMaze() -> Maze
    
    func makeWall() -> WallMazeType
    
    func makeRoom(_ n: Int) -> RoomMazeType
    
    func makeDoor(r1: RoomMazeType, r2: RoomMazeType) -> DoorMazeType
    
    
}

//: 通过协议扩展给 MazeFactory 提供默认实现
extension MazeFactory {
    
    func makeMaze() -> Maze {
        return Maze()
    }
    
    func makeDoor(r1: Room, r2: Room) -> Door {
        return Door(r1: r1, r2: r2)
    }
    
    func makeRoom(_ n: Int) -> Room {
        return Room(no: n)
    }
    
    func makeWall() -> Wall {
        return Wall()
    }
    
}

//: 定义一个普通迷宫工厂，使用 MazeFactory 提供的默认实现构建（迷宫，门，房间，墙）
struct NormalMazeFactory: MazeFactory {
    
    typealias RoomMazeType = Room
    typealias WallMazeType  = Wall
    typealias DoorMazeType = Door

}

//: 定义一个迷宫游戏，通过 createMaze 方法来创建游戏中的迷宫
struct MazeGame {
    
    static func createMaze<T: MazeFactory>(mazeFactory: T) -> Maze {
        
        var maze = mazeFactory.makeMaze()
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

//: 使用工厂构建普通的迷宫
var normalMazeFactory = NormalMazeFactory()
var normalMaze = MazeGame.createMaze(mazeFactory: normalMazeFactory)
print(normalMaze)


/*:
 接下来，我们接到一个新的需求。我们需要添加一个创建施了魔法的迷宫。施了魔法的迷宫有以下几个不同点:
 1. 施了魔法的房间
 2. 需要咒语才能打开的门
 */

//: 施了魔法的房间，拥有普通房间的基本功能，这里我们可以继承之前定义的 RoomType 协议, 它比普通房间多了个咒语的属性
struct EnchantedRoom: RoomType {
    
    var sides: [MapSite?] = [nil, nil, nil, nil]
    var roomNo: Int
    var castSpell: Spell
    
    init (_ n: Int, spell: Spell) {
        roomNo = n
        castSpell = spell
    }
    
    
    
}

extension EnchantedRoom: CustomStringConvertible {
    
    var description: String {
        return "EnchantedRoom"
    }
    
}

//: 咒语
struct Spell {
}

//: 需要咒语才能打开的门
struct DoorNeedingSpell: DoorType {
    
    init(r1: EnchantedRoom, r2: EnchantedRoom) {
        
    }

}

extension DoorNeedingSpell: CustomStringConvertible {
    
    var description: String {
        return "DoorNeedingSpell"
    }
    
}

//: 施了魔法的迷宫工厂
struct EnchantedMazeFactory: MazeFactory {
    
    typealias RoomMazeType = EnchantedRoom
    typealias DoorMazeType = DoorNeedingSpell
    
    
    
    func makeDoor(r1: EnchantedRoom, r2: EnchantedRoom) -> DoorNeedingSpell {
        return DoorNeedingSpell(r1: r1, r2: r2)
    }

    func makeRoom(_ n: Int) -> RoomMazeType {
        return EnchantedRoom(n, spell: Spell())
    }

}

//: 使用工厂构建施了魔法的迷宫
var enchantedMazeFactory = EnchantedMazeFactory()
var enchantedMaze = MazeGame.createMaze(mazeFactory: enchantedMazeFactory)
print(enchantedMaze)


/*: 
 接下来，我们又接到一个新的需求，我们需要一个有炸弹💣的房间，如果炸弹💣爆炸则会炸毁房间的墙。
 */

//: 构建 RoomWithABomb 表示有炸弹的房间
struct RoomWithABomb: RoomType {
    
    var sides: [MapSite?] = [nil, nil, nil, nil]
    var roomNo: Int
    var isBombe: Bool
    
    init(_ n: Int, isBombe: Bool) {
        roomNo = n
        self.isBombe = isBombe
    }
    
    
}

extension RoomWithABomb: CustomStringConvertible {
    
    var description: String {
        return "RoomWithABomb Bombe is \(isBombe)"
    }
    
}

//: 构建 BombedWall 表示被炸毁的墙
struct BombedWall: WallType {
    
    var isBombed: Bool
    
    init(_ isBombe: Bool) {
        self.isBombed = isBombe
    }
    
}

extension BombedWall: CustomStringConvertible {
    var description: String {
        return "BombedWall Bombe is \(isBombed)"
    }
}



//: 构建炸弹迷宫的工厂
struct BombedMazeFactory: MazeFactory {
    
    
    typealias WallMazeType = BombedWall
    typealias RoomMazeType = RoomWithABomb
    
    func makeWall() -> BombedWall {
        return BombedWall(false)
    }
    
    func makeRoom(_ n: Int) -> RoomWithABomb {
        return RoomWithABomb(n, isBombe: false)
    }
    
    func makeDoor(r1: RoomWithABomb, r2: RoomWithABomb) -> Door {
        return Door(r1: r1, r2: r2)
    }
    
}

var bombedMazeFactory = BombedMazeFactory()
var bombedMaze = MazeGame.createMaze(mazeFactory: bombedMazeFactory)
print(bombedMaze)



//: [Next](@next)
