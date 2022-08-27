# NSerializer


a Serializer with  derived class handling such as NewthonSoft serializer in C# NimSerializer

handle derived type with type name handlening

support enums
support Generics

dont support case items 







#be careful it's in very primary stage
`
var b=GenericClass[GameEventHolder](t:GameEventHolder(action:PlayerJoin(health:100,role:PlayerRole.Second)))

{
    "$type":"GenericClass[atest.GameEventHolder]",
    "t":{
        "action":{
            "$type":"PlayerJoin",
            "health":100,
            "role":2
        }
    }
}
`

