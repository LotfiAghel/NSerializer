import
  std/[times, typetraits, random, strutils, options, sets, tables],
  std/strformat,
#  macros,
  typetraits, unittest2,
  stew/shims/macros, stew/objects,
  serialization/object_serialization,
  serialization/testing/generic_suite,
  serialization,
  std/json


template defineGetNameBM*(T:type)=
  method getName(t:T):string{.base.}=
    return T.name


template defineGetName*(T:type)=
  method getName(t:T):string=
    return name(T) # if you write T.Name and T has filed with name you got error

template defineGetNameP*(T:type)=
  proc getName(t:ptr T):string=
    return name(T) # if you write T.Name and T has filed with name you got error

defineGetNameP(int)

defineGetNameP(string)

defineGetNameBM(DateTime)


proc toJson*(t:ptr int):JsonNode =
  return JsonNode(kind:JInt,num:t[])

proc toJson*(t:DateTime):JsonNode =
  return JsonNode(kind:JString,str:"TODO")

proc toJson*(t:ptr string):JsonNode =
  return JsonNode(kind:JString,str:t[])

proc fromJson*(T:typedesc[string];t:ptr string,js:JsonNode) =
  t[]=js.str


proc fromJson*(t:ptr string,js:JsonNode) =
  t[]=js.str

proc toJson*[T](t:ptr seq[T]):JsonNode =
  result=JsonNode(kind:JArray)
  for i in 0..<t[].len:
    when T is ref|ptr:
      result.add toJson(t[][i])
    else:
      result.add toJson(t[][i].addr)

proc fromJsonS*[T](t:ptr seq[T],js:JsonNode) =
  t[].setlen(js.elems.len)
  for i in 0..<js.elems.len:
    T.fromJson(t[][i].addr,js.elems[i]  )

proc fromJson*[T](t:ptr seq[T],js:JsonNode) =
  t[].setlen(js.elems.len)
  for i in 0..<js.elems.len:
    fromJson(t[][i].addr,js.elems[i]  )

#[method toJson*(t:BaseType):JsonNode {.base.}=
  return parseJson("""{"$type": \"BaseType\"}""")]#


method toJson*(t:RootObj):JsonNode {.base.}=
  return parseJson("""{"$type": \"BaseType\"}""")



macro dot*(obj: ref object, fld: string): untyped =
  newDotExpr(obj, newIdentNode(fld.strVal))


macro dot*(obj: ptr object, fld: string): untyped =
  newDotExpr(obj, newIdentNode(fld.strVal))

macro dot*(obj: object, fld: string): untyped =
  newDotExpr(obj, newIdentNode(fld.strVal))





template defineToJsonP*(T:type)=
  proc toJson*(t:ptr T):JsonNode=
    result=JsonNode(kind:JObject) #,fields:{: t.getName.toJson}.toOrderedTable)
    when T  is ref|ptr:
      result.add("$type",t.getName.toJson)
    enumAllSerializedFields(T):
      static:
        echo fieldName  ,": ",FieldType ," : "
      
      when FieldType  is ref|ptr:
        var tmp= t.dot($(fieldName))
        if tmp != nil:
            result.add(fieldName,tmp.toJson())
        else:
            echo "nil"    
      else:
        var tmp= t.dot($(fieldName)).addr
        result.add(fieldName,tmp.toJson())
  proc fromJson*(t: ptr T,js:JsonNode)=

    enumAllSerializedFields(T):
      echo fieldName  ,": ",FieldType ," : "
      
      when FieldType  is ref|ptr:
        var tmp=FieldType()
        fromJson(tmp.addr,js[fieldName])
        t.dot($(fieldName))=tmp
      else:
        var tmpP= t.dot($(fieldName)).addr
        fromJson(tmpP,js[fieldName])

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




template defineToJsonBM*(T:type)=
  method toJson(t:T):JsonNode{.base.}=
    result=JsonNode(kind:JObject,fields:{"$type": t.getName.toJson}.toOrderedTable)
    
    enumAllSerializedFields(T):
      echo fieldName  ,": ",FieldType ," : "
      var tmp= t.dot($(fieldName))
      when FieldType  is ref|ptr:
        if tmp != nil:
            result.add(fieldName,tmp.toJson())
        else:
            echo "nil"    
      else:
        result.add(fieldName,tmp.toJson())
  proc fromJson(t:T,js:JsonNode):JsonNode=
    #result=cast
    
    enumAllSerializedFields(T):
      echo fieldName  ,": ",FieldType ," : "
      var tmp= t.dot($(fieldName))
      when FieldType  is ref|ptr:
        if tmp != nil:
            result.add(fieldName,tmp.toJson())
        else:
            echo "nil"    
      else:
        result.add(fieldName,tmp.toJson())


template defineToJson*(T:type)=
  method toJson(t:var T):JsonNode=
    result=JsonNode(kind:JObject)
    
    enumAllSerializedFields(T):
      echo fieldName  ,": ",FieldType ," : "
      
      when FieldType  is ref|ptr:
        result.add("$type",t.getName.toJson)
        var tmp= t.dot($(fieldName))
        if tmp != nil:
            result.add(fieldName,t.dot($(fieldName)).toJson())
        else:
            echo "nil"    
      else:
        var tmp = t.dot($(fieldName)).addr
        result.add(fieldName,tmp.toJson())
  proc fromJson(t:T,js:JsonNode):JsonNode=
    #result=cast
    
    enumAllSerializedFields(T):
      echo fieldName  ,": ",FieldType ," : "
      
      when FieldType  is ref|ptr:
        var tmp= t.dot($(fieldName))
        if tmp != nil:
            result.add(fieldName,tmp.toJson())
        else:
            echo "nil"    
      else:
        var tmp= t.dot($(fieldName)).addr
        result.add(fieldName,tmp.toJson())



template defineToAll*(T:type)=
  defineGetName(T)
  defineToJson(T)
  


template defineToAllP*(T:type)=
  defineGetNameP(T)
  defineToJsonP(T)