# Roblox-DataCache
A Roblox module for storing user data across server-client model.

Welcome to the Roblox-DataCache wiki!

# Documentation

This is a documentation written by fredrick254 on his data-cache module. This was updated on 30/06/2020.
This module is intended for passage of data from client to server without need of worrying about any back-end operations. It is also intended to store data on the client preventing
hackers and exploiters from changing data inside it in any way. It can store data in any size which are properly arranged inside it. It also prevents memory leakage as you just have
to create one data-cache object per script.

# Constructors

## Cache data-cache.new()

Creates a new Cache Object, which represents an organized data structure.


## Cache data-cache.deserializeData([Table](https://developer.roblox.com/en-us/articles/Table) serializedData)


Deserializes data serialized with the serializeData() method of Cache. Is majorly used in the server when serialized data is passed from client or vice-versa.



# Cache Methods

## void addData([Table](https://developer.roblox.com/en-us/articles/Table) data)

##### The data parameter is required and has the following format

###### data = {[String](https://developer.roblox.com/en-us/articles/String) DataLabel, [Variant](https://developer.roblox.com/en-us/api-reference/lua-docs/Roblox-Globals#) ...}

For example:

```lua

  data = {"Numbers", ["data1"] = 123, ["data2"] = 456}
  
  or 
  
  data = {"Names" , "david", "Joe", "Roblox"}
```

##### ⚠⚠ Note on this method: If you add more data with DataLabel that already exists, it doesn't overwrite, instead it adds to the existing data. Hence make sure to remove data with the removeData() method if you intend to overwrite data.

DataLabel has to be as string and is remembered for future references.
The rest of the parameters can be any kind of dataype, provided they exist.

## void removeData([String](https://developer.roblox.com/en-us/articles/String) DataLabel, [String](https://developer.roblox.com/en-us/articles/String) or [Number](https://developer.roblox.com/en-us/articles/Numbers#:~:text=Numbers%20are%20notated%20with%20the,%2C%201.25%20%2C%20or%20%2D22.5%20.) Key)

#### ⚠ The DataLabel paramater is the only required parameter, with key you can remove a specific piece of data, hence it's advised to store well-labeled arrays

Removes a piece of data in the Cache object.

For example:

```lua
  Cache:removeData("Numbers", "data1") --removes 123
  
  Cache:removeData("Names", 1) --removes string literal "david"
```

## [Variant](https://developer.roblox.com/en-us/api-reference/lua-docs/Roblox-Globals#) getData([String](https://developer.roblox.com/en-us/articles/String) DataLabel, [String](https://developer.roblox.com/en-us/articles/String) or [Number](https://developer.roblox.com/en-us/articles/Numbers#:~:text=Numbers%20are%20notated%20with%20the,%2C%201.25%20%2C%20or%20%2D22.5%20.) Key)

#### ⚠ The DataLabel is the only required parameter, with Key you can get a specific piece of data.

Returns any known data type in Roblox lua without removing it. Majorly used for setting values saved from the Cache Object.

For example:

```lua
  print(Cache:getData("Numbers", "data1")) -- Outputs 123
  
  print(Cache:getData("Names", 1)) -- Outputs "david"
```

## void updateData([String](https://developer.roblox.com/en-us/articles/String) DataLabel, [String](https://developer.roblox.com/en-us/articles/String) or [Number](https://developer.roblox.com/en-us/articles/Numbers#:~:text=Numbers%20are%20notated%20with%20the,%2C%201.25%20%2C%20or%20%2D22.5%20.) Key, [Variant](https://developer.roblox.com/en-us/api-reference/lua-docs/Roblox-Globals#) Value)

#### ⚠ All arguments are required

Sets Value to the Key in a labelled dictionary or table. Majorly useful for setting specific values without worrying about anything under the radar.

For example:

```lua
  Cache:updateData("Numbers", "data1", 456)
```

## [Number](https://developer.roblox.com/en-us/articles/Numbers#:~:text=Numbers%20are%20notated%20with%20the,%2C%201.25%20%2C%20or%20%2D22.5%20.) num([String](https://developer.roblox.com/en-us/articles/String) DataLabel)

#### ⚠ DataLabel argument required

Returns the number of elements of data stored in any specific data structure inside the Cache object.

For example:

```lua
Cache:num("Numbers") --2
```

## void bindToAddedEvent([Function](https://developer.roblox.com/en-us/articles/Function) bindingFunction)

#### ⚠ bindingFunction argument required

Binds a function that runs automatically every time an element is added to the Cache Object in general. bindingData takes an argument that represents the data passed into the Cache Object.

For example:

```lua
  Cache:bindToAddedEvent(function(data)
    if data[1] == false then
      print("First key of data is false")
    end
  end)
```

## void bindToRemoveEvent([Function](https://developer.roblox.com/en-us/articles/Function) bindingFunction)

#### ⚠ bindingFunction argument required

Binds a function that runs automatically every time an element is removed to the Cache Object in general. bindingData takes an argument that represents the data removed from the Cache Object.

For example:

```lua
  Cache:bindToRemoveEvent(function(data)
    if data[1] == false then
      print("First key of data is false")
    end
  end)
  ```
  
  ## void updateDataIndex([String](https://developer.roblox.com/en-us/articles/String) DataLabel, [Number](https://developer.roblox.com/en-us/articles/Numbers#:~:text=Numbers%20are%20notated%20with%20the,%2C%201.25%20%2C%20or%20%2D22.5%20.) or [String](https://developer.roblox.com/en-us/articles/String) Key, [String](https://developer.roblox.com/en-us/articles/String) NewKey)

#### ⚠ All parameters are required

A new function that updates the key of any piece of data at any key value and updates it to the string NewKey. There are very few use cases for this found out, one of which was when referring to random instance(s) in a non-array table.

For example:

```lua
  local random = Random.new()
  local allData = Cache:addData({"Pets", PetModel1, PetModel2, PetModel3})
  allData:updateDataIndex("Pets", random:NextInteger(1, #allData:num("Pets")), "randomPet")
  local randomPet = allData:getData("Pets", "randomPet")
  allData:removeData("Pets", "randomPet") -- clean-up if you intend to delete it or utilize it
  
  randomPet:MoveTo(player.Character.HumanoidRootPart.Position)

```

## [Table](https://developer.roblox.com/en-us/articles/Table) serializeData()

#### ⚠ No parameters required

A recent function that returns a table serialized from Cache object using a very simple method. Major use case for transferring cached data from client to server or vice-versa, hence uses simple serialization methods to avoid delays.

For example:

```lua
--Client
local data_cache = require(game.ReplicatedStorage.Cache)

local a = game.ReplicatedStorage:WaitForChild("remote")

local Cache = data_cache.new()

Cache:addData({"Nubs", ["me"] = 1234, ["them"] = 4567})

local serialized= Cache:serializeData()

a:FireServer(serialized)

--Server
local data_cache = require(game.ReplicatedStorage.Cache)

game.ReplicatedStorage.RemoteEvent.OnServerEvent:Connect(function(_, serializedData)
	local unserialized = data_cache.deserializeData(serializedData)
	
	print(unserialized:getData("Nubs", "me")) --prints 1234
end)
```
This is as far as it goes as 'passing' metatable information across the server-client model.

This module is in it's very early stage and I intend to imrpove upon it. You can suggest features or better implemetations of certain features by taking a look at the source code in the repository. Thanks!!

# Made by fredrick254 from Roblox
