--!strict
local garbager = {}
garbager.__index = garbager

--> types
export type garbager<T> = {
	Add : (garbager<T>, item : T) -> (),
	Remove : (garbager<T>, item : T) -> (),
	Collect : (garbager<T>) -> (),
	Destroy : (garbager<T>) -> (),
}

--> methods
local methods = {
	['thread'] = task.cancel,
	['function'] = task.spawn,
	['Instance'] = game.Destroy,
	['RBXScriptConnection'] = function(connection : RBXScriptConnection)
		connection:Disconnect()
	end,
}

--[=[

	Garbage Collect the full table
	@private
	@param tbl Table

]=]
function tbldestroy(tbl : any)
	local destroy = tbl.Destroy or tbl.destroy

	if destroy then
		destroy(tbl)
	end

	for i, v in pairs(tbl) do
		if methods[typeof(v)] then
			methods[typeof(v)](v)
		end
	end
end

methods['table'] = tbldestroy

--> Constructor

--[=[

	Create a new garbage collection class
	@public

]=]
function garbager.new<T>() : garbager<T>
	return setmetatable({
		Collection = {}
	}, garbager) :: any
end

--> Methods

--[=[

	Add a item to garbage collection to be collected when collected
	@public
	@param item thread | function | Instance | RBXScriptConnection | table

]=]
function garbager:Add<T>(item : T)
	assert(methods[typeof(item)], 'Passed item is not a valid item to add to garbage collection.')
	self.Collection[item] = methods[typeof(item)]
end

--[=[

	Remove a item from garbage collection
	@public
	@param item thread | function | Instance | RBXScriptConnection | table

]=]
function garbager:Remove<T>(item : T)
	assert(self.Collection[item], `Passed item was never added to garbage collection, make sure you call 'garbager:Add(item)' before calling 'garbager:Remove(item)'.`)
	self.Collection[item] = nil
end

--[=[

	Collect all items in garbage collection
	@public
	
]=]
function garbager:Collect()
	for item, method in pairs(self.Collection) do
		method(item)
		self.Collection[item] = nil
	end
end

--[=[

	Collect all items in garbage collection and destroy the class
	@public
	
]=]
function garbager:Destroy()
	self:Collect()
	table.clear(self)
end

--> return
return garbager