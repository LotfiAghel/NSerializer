# NSerializer


a Serializer with  derived class handling (Type name handling ) such as NewthonSoft serializer in C# NimSerializer

handle derived type with type name handlening

this project create json serilizer/deserilizer  function at compileTime with Macro

# support
## support Drived Class
## support enums
## support Generics
## support seq,hashTable
## dont suport case Arm Fields









#be careful it's in very primary stage
```
type  
  GameEventHolder* = object 
    action* : GameEvent

  GameEvent = ref object of RootObj
  
  PlayerRole* =  enum
    None=0,First=1 , Second=2, 
    
  PlayerJoin* = ref object of GameEvent
    health*:int
    role*:PlayerRole

  GenericClass[T] = ref object of GameEvent
    t*:T

defineJsonFuncsEnum(PlayerRole)

implAllFuncs(GameEvent)
implAllFuncs(PlayerJoin)
implAllFuncsP(GameEventHolder)
implAllFuncs(GenericClass[GameEventHolder])

var
    b=GenericClass[GameEventHolder](t:GameEventHolder(action:PlayerJoin(health:100,role:PlayerRole.Second)))

echo b.toJson()
```
output:
```
{
    "$type":"GenericClass[GameEventHolder]",
    "t":{
        "action":{
            "$type":"PlayerJoin",
            "health":100,
            "role":2
        }
    }
}
```



