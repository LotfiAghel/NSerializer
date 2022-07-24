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
{.used.}

type
  Meter* = distinct int
  Mile* = distinct int

  Simple* = object
    x*: int
    y*: string
    distance*: Meter
    ignored*: int

  Transaction* = object
    amount*: int
    time*: DateTime
    sender*: string
    receiver*: string

  BaseType* = object of RootObj
    a*: string
    b*: int

  BaseTypeRef* = ref BaseType

  DerivedType* = object of BaseType
    c*: int
    d*: string

  DerivedRefType* = ref object of BaseType
    c*: int
    d*: string
    time*: DateTime


  DerivedFromRefType* = ref object of DerivedRefType
    e*: int
    next*: DerivedRefType
    list: seq[DerivedRefType]

  RefTypeDerivedFromRoot* = ref object of RootObj
    a*: int
    b*: string


  Foo = object
    x*: uint64
    y*: string
    z*: seq[int]

  Bar = object
    b*: string
    f*: Foo

  # Baz should use custom serialization
  # The `i` field should be multiplied by two while deserializing and
  # `ignored` field should be set to 10
  Baz = object
    f*: Foo
    i*: int
    ignored* {.dontSerialize.}: int

  ListOfLists = object
    lists*: seq[ListOfLists]

  NoExpectedResult = distinct int

  ObjectKind* = enum
    A
    B

  CaseObject* = object
    case kind*: ObjectKind
    of A:
      a*: int
      other*: CaseObjectRef
    else:
      b*: int

  CaseObjectRef* = ref CaseObject

  HoldsCaseObject* = object
    value: CaseObject

  HoldsSet* = object
    a*: int
    s*: HashSet[string]

  HoldsOption* = object
    r*: ref Simple
    o*: Option[Simple]

  HoldsArray* = object
    data*: seq[int]

  AnonTuple* = (int, string, float64)

  AbcTuple* = tuple[a: int, b: string, c: float64]
  XyzTuple* = tuple[x: int, y: string, z: float64]

  HoldsTuples* = object
    t1*: AnonTuple
    t2*: AbcTuple
    t3*: XyzTuple


let jsonNode = parseJson("""{"key": 3.14}""")
jsonNode.add("type", parseJson("\"aa\""))
echo jsonNode


#[method toJson(t:BaseType):JsonNode {.base.}=
  return parseJson("""{"$type": \"BaseType\"}""")]#


defineToAll(DerivedRefType)



defineToAll(DerivedFromRefType)



let
  a = BaseType(a: "test", b: -1000)
  b = BaseTypeRef(a: "another test", b: 2000)
  c = RefTypeDerivedFromRoot(a: high(int), b: "")
  d = DerivedType(a: "a field", b: 1000, c: 10, d: "d field")
  e = DerivedRefType(a: "a field", b: -1000, c: 10, d: "")
  f = DerivedFromRefType(a: "a field", b: -1000, c: 10, d: "", e: 12, time: now().utc,
    next: DerivedFromRefType(a: "a field", b: -1000, c: 10, d: "", e: 12,
        time: now().utc),
   list: @[
      DerivedRefType(a: "a 0 field", b: -1000, c: 10, d: "", time: now().utc),
      DerivedRefType(a: "a 1 field", b: -1000, c: 10, d: "", time: now().utc),
      DerivedFromRefType(a: "a field", b: -1000, c: 10, d: "", e: 12, time: now().utc,list: @[DerivedRefType(a: "a field", b: -1000, c: 10, d: "", time: now().utc)])
    ])
#var z=getField(f)
static:
  echo "static"




echo f.getName()
echo f.next != nil
echo "==============--===="
var z = f.toJson()
echo z
echo "==============--==== json"

var f2 = DerivedFromRefType()

echo "f2.list.len " , f2.list.len
fromJson(f2, z)

echo f.list.len
echo "f2.list.len " , f2.list.len


echo "================== ft.tojson"
echo f2.toJson()
echo s_creators.len
dumpTree:
  f.b
  a

echo f.dot("a")

enumAllSerializedFields(DerivedFromRefType):
  echo fieldName
