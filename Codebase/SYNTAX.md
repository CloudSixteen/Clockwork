Syntax
---------

```lua
--[[
	@codebase Client
	@details This is a simple demonstration library.
	@field stored A table of stored values.
	@field version The current version of something.
--]]
Clockwork.library = Clockwork:NewLibrary("Library");
Clockwork.library.stored = {};
Clockwork.library.version = 1.0;

--[[
	@codebase Shared
	@details This function is a utility function to do X, Y and Z.
	@param {String} The thing to do X with.
	@param {Float} The thing to do Y with.
	@param {Bool:String} The string or boolean to do Z with.
	@returns {Int} Some random integer.
	@returns {Bool} Returns true, always,
--]]
function Clockwork.library:DoSomething(first, second, third, ...)
	return math.random(1, 10), true;
end;

--[[
	@codebase Server
	@details This class does ALL the things.
	@field MyFloat A float representing something important.
	@name MyClass
--]]
MyClass = {MyFloat = 1.0};

--[[
	@codebase Server
	@details The most amazing function in the universe.
	@class MyClass
	@param {Table} The things to do.
--]]
function MyClass:AllTheThings(thingsToDo)
end;
```