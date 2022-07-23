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
  proc getName(t:T):string=
    return name(T) # if you write T.Name and T has filed with name you got error

defineGetNameP(int)

defineGetNameP(string)

defineGetNameBM(DateTime)


proc toJson*(t:int):JsonNode =
  return JsonNode(kind:JInt,num:t)

proc toJson*(t:DateTime):JsonNode =
  return JsonNode(kind:JString,str:"TODO")

proc toJson*(t:string):JsonNode =
  return JsonNode(kind:JString,str:t)


proc toJson*[T](t:var seq[T]):JsonNode =
  result=JsonNode(kind:JArray)
  for i in t:
    result.add toJson(i)
  
#[method toJson*(t:BaseType):JsonNode {.base.}=
  return parseJson("""{"$type": \"BaseType\"}""")]#


method toJson*(t:RootObj):JsonNode {.base.}=
  return parseJson("""{"$type": \"BaseType\"}""")



macro dot*(obj: ref object, fld: string): untyped =
  newDotExpr(obj, newIdentNode(fld.strVal))



macro dot*(obj: object, fld: string): untyped =
  newDotExpr(obj, newIdentNode(fld.strVal))





template defineToJsonP*(T:type)=
  proc toJson(t:T):JsonNode=
    result=JsonNode(kind:JObject) #,fields:{: t.getName.toJson}.toOrderedTable)
    result.add("$type",t.getName.toJson)
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
  method toJson(t:T):JsonNode=
    result=JsonNode(kind:JObject,fields:{"$type": t.getName.toJson}.toOrderedTable)
    
    enumAllSerializedFields(T):
      echo fieldName  ,": ",FieldType ," : "
      var tmp= t.dot($(fieldName))
      when FieldType  is ref|ptr:
        if tmp != nil:
            result.add(fieldName,t.dot($(fieldName)).toJson())
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



template defineToAll*(T:type)=
  defineGetName(T)
  defineToJson(T)
  


template defineToAllP*(T:type)=
  defineGetNameP(T)
  defineToJsonP(T)