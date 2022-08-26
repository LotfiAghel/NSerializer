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
  stew/shims/macros, stew/objects

var s_creators* : Table[string,proc():ref RootObj ]


method getName*(t:ref RootObj):string{.base.}=
  return "RootObj"

template implGetNameBM*(T:type)=
  method getName*(t:T):string=
    return T.name


template implGetName*(T:type)=
  method getName*(t:T):string=
    return name(T) # if you write T.Name and T has filed with name you got error

template implGetNameP*(T:type)=
  proc getName*(t:ptr T):string=
    return name(T) # if you write T.Name and T has filed with name you got error

implGetNameP(int)
implGetNameP(bool)

implGetNameP(string)

implGetNameBM(DateTime)


proc toJson*(t:ptr int):JsonNode =
  return JsonNode(kind:JInt,num:t[])

proc toJson*(t:ptr bool):JsonNode =
  return JsonNode(kind:JBool,bval:t[])

proc toJson*(t:ptr DateTime):JsonNode =
  return JsonNode(kind:JString,str:"TODO")

proc fromJson*(t:ptr DateTime,js:JsonNode) =
  t[]= now().utc # TODO wrong 

proc toJson*(t:ptr string):JsonNode =
  return JsonNode(kind:JString,str:t[])

proc fromJson*(T:typedesc[string];t:ptr string,js:JsonNode) =
  t[]=js.str


proc fromJson*(t:ptr string,js:JsonNode) =
  t[]=js.str

proc fromJson*(t:ptr int,js:JsonNode) =
  t[]=js.num.int

proc fromJson*(t:ptr bool,js:JsonNode) =
  t[]=js.bval

proc toJson*[T](t:ptr seq[T]):JsonNode =
  result=JsonNode(kind:JArray)
  for i in 0..<t[].len:
    when T is ref|ptr:
      result.add toJson(t[][i])
    else:
      result.add toJson(t[][i].addr)

proc fromJsonS*[T](t:ptr seq[T],js:JsonNode) =
  t[].setLen(js.elems.len)
  for i in 0..<js.elems.len:
    T.fromJson(t[][i].addr,js.elems[i]  )


proc toJson*[T](t:ptr HashSet[T]):JsonNode =
  result=JsonNode(kind:JArray)
  for i in t[]:
    when T is ref|ptr:
      result.add toJson(i)
    else:
      var x=i
      result.add toJson(x.addr)

proc fromJson*[T](a:ptr HashSet[T],js:JsonNode) =
  for i in 0..<js.elems.len:
    var t:T
    fromJson(t.addr,js.elems[i]  )
    a[].incl t


proc createWithName*(defaultName:string,js:JsonNode):ref RootObj=
  echo fmt"create {defaultName} ", js
  if js.hasKey("$type"):
    var z=js["$type"].str
    echo fmt"create {z}"
    result=s_creators[z]()
  else:
    result=s_creators[defaultName]()

proc createWithName*[T](js:JsonNode):T=
  
  if js.hasKey("$type"):
    var z=js["$type"].str
    echo fmt"create {z}"
    static:
      echo "createWithName[",name(T),"]"
    var functions=s_creators[z]
    result=cast[T](functions())
  else:
    result=T()

proc fromJson*[T](t:ptr seq[T],js:JsonNode) =
  t[].setLen(js.elems.len)
  for i in 0..<js.elems.len:
    when T is ref|ptr:
      static:
        echo "T is ref|ptr"
      #echo fmt"T is ref|ptr {i}"
      var tmp=createWithName[T](js.elems[i])# T() #TODO handle drived class
      t[][i]=cast[T](tmp)
      fromJson(t[][i],js.elems[i]  )
    else:
      static:
        echo "not T is ref|ptr"
      #echo "not T is ref|ptr"
      fromJson(t[][i].addr,js.elems[i]  )
      

#[method toJson*(t:BaseType):JsonNode {.base.}=
  return parseJson("""{"$type": \"BaseType\"}""")]#


method toJson*(t:RootObj):JsonNode {.base.}=
  return JsonNode(kind:JObject,fields:OrderedTable[string,JsonNode]())

method toJson*(t:ptr RootObj):JsonNode {.base.}=
  return parseJson("""{"$type": \"RootObj\"}""")

method toJson*(t:ref RootObj):JsonNode {.base.}=
  return JsonNode(kind:JObject,fields:OrderedTable[string,JsonNode]())


method fromJson*(t:ptr RootObj,js:JsonNode) {.base.}=
  discard

method fromJson*(t:ref RootObj,js:JsonNode) {.base.}=
  discard

macro dot*(obj: ref object, fld: string): untyped =
  newDotExpr(obj, newIdentNode(fld.strVal))


macro dot*(obj: ptr object, fld: string): untyped =
  newDotExpr(obj, newIdentNode(fld.strVal))

macro dot*(obj: object, fld: string): untyped =
  newDotExpr(obj, newIdentNode(fld.strVal))


proc checkWhen():bool=
  return true
macro echoType(T:untyped)=
  echo T.getImpl().treeRepr 


template forOnFields0(T: type, body: untyped): untyped =
  var typeAst = getType(T)[1]
  var typeImpl: NimNode
  let isSymbol = not typeAst.isTuple
  echo typeAst.treeRepr
  if not isSymbol:
    typeImpl = typeAst
  else:
    typeImpl = getImpl(typeAst)
  

  var i = 0
  for field in recordFields(typeImpl):
    body
template forOnFields*(T: type, body): untyped =
  when T is ref|ptr:
    type TT = type(default(T)[])
    forOnFields0(TT, body)
  else:
    forOnFields0(T, body)

template convertFilds(T:type,t:T | ptr T)=
   
    enumAllSerializedFields(T):
      static:
        echo "toJson : ",realFieldName  ,": ",FieldType ," : ",FieldType  is enum ," >",fieldCaseDiscriminator ,"> " #,field.isPublic
        #echo fieldCaseDiscriminator0.treeRepr
        #echo fieldCaseDiscriminator0.caseField.treeRepr
        #echo fieldCaseDiscriminator0.caseBranch.treeRepr
        #echo fieldCaseBranches
        #echo fieldCaseBranches0.treeRepr
        echo ".."
        #if fieldCaseBranches!=nil:
        #  echo fieldCaseBranches.treeRepr
        echo ",,"
        #[if fieldCaseBranches.len > 0:
          echo ">", fieldCaseBranches[0].treeRepr]#
      
      when FieldType  is ref|ptr:
        var tmp= t.dot($(realFieldName))
        if tmp != nil:
            result.add(fieldName,t.dot($(realFieldName)).toJson())
        else:
            echo "nil"    
      else:
        when FieldType  is enum:
          var tmp = t.dot($(realFieldName))
          static:
            echo realFieldName
          result.add(realFieldName,tmp.unsafeAddr.toJson())
        else:
          when fieldCaseDiscriminator == "" :
            var tmp = t.dot($(realFieldName)).unsafeAddr
            static:
              echo realFieldName
            result.add(realFieldName,tmp.toJson())
          else:
            # TODO
            discard


proc getDiscriminator(field:FieldDescription):NimNode=
  return newLit(if field.caseField == nil: ""
                           else: $field.caseField[0][1].skipPragma)

template fromJsonFields(T:type,t:T | ptr T,js:JsonNode)=
    enumAllSerializedFields(T):
      #echo fieldName  ,": ",FieldType ," : "
      if(js.hasKey(fieldName)):
        when FieldType  is ref|ptr:
          var tmp=createWithName[FieldType](js[fieldName])
          fromJson(tmp,js[fieldName])
          static:
            echo fieldName
          t.dot($(fieldName))=tmp
        else:
          
          when fieldCaseDiscriminator == "":
            when FieldType  is enum:
              var tmp :type(t.dot($(realFieldName)))
              static:
                echo realFieldName
              fromJson(tmp.addr,js[fieldName])
              t.dot($(realFieldName))=tmp
            else:
              var tmpP= t.dot($(fieldName)).unsafeAddr
              fromJson(tmpP,js[fieldName])

template impelSerDesrFuncsP*(T:type)=
  proc toJson*(t:ptr T):JsonNode=
    result=JsonNode(kind:JObject) #,fields:{: t.getName.toJson}.toOrderedTable)
    static:
      echoType(T)
    convertFilds(T,t)

  proc fromJson*(t: ptr T,js:JsonNode)=

    fromJsonFields(T,t,js)

template defineJsonFuncsEnum*(T:type)=
  proc toJson*(t:ptr T):JsonNode=
    result=JsonNode(kind:JInt,num:t[].ord) #,fields:{: t.getName.toJson}.toOrderedTable)
  proc fromJson*(t: ptr T,js:JsonNode)=
    t[]=cast[T](js.num)

#[proc fromJson*(T:type;t: ptr T,js:JsonNode)=
  
  enumAllSerializedFields(T):
    static:
      echo "========================================="
      echo fieldName  ,": ",FieldType ," : "
    
    when FieldType  is ref|ptr:
      var tmp=FieldType()
      t.dot($(fieldName))=tmp
      FieldType.fromJson(tmp,js[fieldName])
    else:
      when FieldType  is seq:
        var tmpP= t.dot($(fieldName)).addr
        fromJsonS(tmpP,js[fieldName])
      else:
        var tmpP= t.dot($(fieldName)).addr
        FieldType.fromJson(tmpP,js[fieldName])
]# 




template impelSerDesrFuncsBM*(T:type)=
  method toJson*(t:T):JsonNode{.base.}=
    result=JsonNode(kind:JObject,fields:{"$type": t.getName.toJson}.toOrderedTable)
    
    enumAllSerializedFields(T):
      #echo fieldName  ,": ",FieldType ," : "
      var tmp= t.dot($(fieldName))
      when FieldType  is ref|ptr:
        if tmp != nil:
            result.add(fieldName,tmp.toJson())
        else:
            echo "nil"    
      else:
        result.add(fieldName,tmp.toJson())
  method fromJson*(t:  T,js:JsonNode){.base.}=

    enumAllSerializedFields(T):
      #echo fieldName  ,": ",FieldType ," : "
      
      when FieldType  is ref|ptr:
        var tmp=FieldType()
        fromJson(tmp,js[fieldName])
        t.dot($(fieldName))=tmp
      else:
        var tmpP= t.dot($(fieldName)).addr
        fromJson(tmpP,js[fieldName])

macro myGetType(T: type): untyped =
  var typeAst = getType(T)[1]
  var typeImpl: NimNode
  let isSymbol = not typeAst.isTuple
  echo typeAst.treeRepr
  if not isSymbol:
    typeImpl = typeAst
  else:
    typeImpl = getImpl(typeAst)
  return typeImpl


template impelSerDesrFuncs*(T:type)=
  static:
      echo "define toJson for ", name(T)
  when T  is ref|ptr:
    s_creators[name(T)]= proc():ref RootObj=
      return T()
  method toJson*(t: T):JsonNode=
    #static:
    #  echoType(T)
    result=JsonNode(kind:JObject)
    when T  is ref|ptr:
        var name=t.getName
        result.add("$type",name.addr.toJson)
    convertFilds(T,t)
    
  method fromJson*(t: T,js:JsonNode)=

    fromJsonFields(T,t,js)      
  


template implAllFuncs*(T:type)=
  implGetName(T)
  impelSerDesrFuncs(T)
  

template implAllFuncsBM*(T:type)=
  implGetNameBM(T)
  impelSerDesrFuncsBM(T)

template implAllFuncsP*(T:type)=
  implGetNameP(T)
  impelSerDesrFuncsP(T)