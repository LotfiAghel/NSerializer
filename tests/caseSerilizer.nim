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
  PlayerRole* =  enum
    None=0,First=1 , Second=2, 

  GameEventHolder* = object 
    action* : int
    case role* :PlayerRole:
        of First:
            intV*:int
        of Second:
            boolV*:bool
        else:
            zV:int

 



echo "hii"


defineJsonFuncsEnum(PlayerRole)


implAllFuncsP(GameEventHolder)


static :
  var typeAst = getType(GameEventHolder)[1]
  var typeImpl: NimNode
  let isSymbol = not typeAst.isTuple

  if not isSymbol:
    typeImpl = typeAst
  else:
    typeImpl = getImpl(genSym(typeAst))
  

  
  for field in recordFields(typeImpl):
    echo "salam"


var
    a=GameEventHolder(role:PlayerRole.Second,action:100)



echo a.addr.toJson()
#output false