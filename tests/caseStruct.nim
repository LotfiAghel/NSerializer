

type
      
    PlayerRole* =  enum
        None=0,First=1 , Second=2, 
    TestStruct* = object
      role* :PlayerRole
      case role2* :PlayerRole:
        of First:
            intV*:int
        of Second:
            boolV*:bool
        else:
            discard
var z =TestStruct()
var tmp=unsafeAddr(z.role)
echo z.role2 # compiled
z.role2=PlayerRole.Second
#var tmp2=unsafeAddr(z.role2) #  Error: expression has no address