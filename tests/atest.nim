import
  std/[times, typetraits, random, strutils, options, sets, tables],
  std/strformat,
#  macros,
  typetraits, unittest2,
  stew/shims/macros, stew/objects,
  serialization/object_serialization,
  serialization/testing/generic_suite,
  serialization,
  std/json,
  ../src/NSrilizer/Srilizer

static:
  echo "-=============---"

type  
  GameEventHolder* = object 
    action* : GameEvent


  GameEvent = ref object of RootObj
  
  PlayerRole* =  enum
    None=0,First=1 , Second=2, 


  ZombieCreate* = ref object of GameEvent
    health*:int
    changeBag*:bool

  ZombieDead* = ref object of GameEvent
    health*:int
    
  PlayerJoin* = ref object of GameEvent
    health*:int
    role*:PlayerRole

defineJsonFuncsEnum(PlayerRole)

defineToAll(GameEvent)


defineToAll(ZombieCreate)
defineToAll(ZombieDead)
defineToAll(PlayerJoin)

defineToAllP(GameEventHolder)


var z: GameEvent =ZombieCreate(health:100)
var
    a=GameEventHolder(action:PlayerJoin(health:100,role:PlayerRole.Second))



echo a.addr.toJson()