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
  ../src/NSerializer/Serializer

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
    s* : HashSet[int]
    

  ZombieDead* = ref object of GameEvent
    health*:int
    
  PlayerJoin* = ref object of GameEvent
    health*:int
    role*:PlayerRole

  GenericClass[T] = ref object of GameEvent
    t*:T




defineJsonFuncsEnum(PlayerRole)

implAllFuncs(GameEvent)


implAllFuncs(ZombieCreate)
implAllFuncs(ZombieDead)
implAllFuncs(PlayerJoin)


implAllFuncsP(GameEventHolder)

#implAllFuncs(GenericClass)
implAllFuncs(GenericClass[GameEventHolder])



var
    a=GameEventHolder(action:ZombieCreate(health:100,s : initHashSet[int]()))
    b=GenericClass[GameEventHolder](t:GameEventHolder(action:PlayerJoin(health:100,role:PlayerRole.Second)))



echo a.addr.toJson()
echo b.toJson()
#output false