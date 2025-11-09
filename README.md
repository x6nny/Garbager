# 🧹 Garbager — Lightweight Resource Cleanup Utility for Roblox

A simple and type-safe **garbage collection utility** for Roblox Studio written in **Luau (`--!strict`)**.
The `garbager` module helps you easily manage and clean up **instances, connections, threads, functions, and tables** — preventing memory leaks and keeping your game code tidy.

---

## 📦 Overview

The `garbager` class acts as a **resource manager** that tracks objects and disposes of them automatically when no longer needed.
It’s similar to **Maid** or **Trove**, but designed to be:

* 🔒 Strictly typed (`--!strict`)
* 🧠 Minimal and predictable
* ⚡ Compatible with threads, functions, `Instance`s, `RBXScriptConnection`s, and even nested tables

---

## 🚀 Installation

1. Copy the `garbager` module into your Roblox project.
2. Require it where needed:

   ```lua
   local Garbager = require(path.to.garbager)
   ```

---

## 🧩 Usage Examples

### ✅ Basic Example

```lua
local Garbager = require(path.to.garbager)
local myGarbage = Garbager.new()

-- Add an Instance
local part = Instance.new("Part")
part.Parent = workspace

myGarbage:Add(part)

-- Add a connection
local connection = part.Touched:Connect(function(hit)
	print(hit.Name, "touched")
end)
myGarbage:Add(connection)

-- Add a thread
local thread = task.spawn(function()
	while true do
		task.wait(1)
		print("Running...")
	end
end)
myGarbage:Add(thread)

-- Clean up everything later
myGarbage:Collect()
```

### 🧨 Destroying the Garbager Itself

```lua
local Garbage = Garbager.new()

-- Add some disposable items
local connection = game:GetService("RunService").Heartbeat:Connect(function() end)
Garbage:Add(connection)

-- When done with this context:
Garbage:Destroy() -- Cleans up and clears itself
```

### ♻️ Manually Removing Items

```lua
local g = Garbager.new()
local conn = workspace.ChildAdded:Connect(print)

g:Add(conn)
g:Remove(conn) -- Stops tracking without cleaning up immediately
```

---

## 🔧 Supported Types

| Type                  | Disposal Method                                                            |
| --------------------- | -------------------------------------------------------------------------- |
| `thread`              | `task.cancel(thread)`                                                      |
| `function`            | `task.spawn(func)`                                                         |
| `Instance`            | `Instance:Destroy()`                                                       |
| `RBXScriptConnection` | `connection:Disconnect()`                                                  |
| `table`               | Calls `Destroy()` if it exists, then recursively cleans all tracked values |

If a table contains values like `Instance`, `RBXScriptConnection`, or other supported types, they’ll also be cleaned automatically.

---

## 🧠 API Reference

### `Garbager.new<T>() → garbager<T>`

Creates a new garbager instance.

---

### **Methods**

| Method         | Description                                                                          |
| -------------- | ------------------------------------------------------------------------------------ |
| `Add(item)`    | Adds an item to be collected later. Supported types only.                            |
| `Remove(item)` | Removes an item from the collection without collecting it.                           |
| `Collect()`    | Cleans up all collected items using the appropriate cleanup methods.                 |
| `Destroy()`    | Calls `Collect()` and then clears the internal table (making the garbager unusable). |

---

### Example Lifecycle

```lua
local Garbage = Garbager.new()

-- Create a part
local part = Instance.new("Part")
part.Parent = workspace

Garbage:Add(part)

-- Add a connection
local conn = part.AncestryChanged:Connect(print)
Garbage:Add(conn)

-- Remove only the connection (not the part)
Garbage:Remove(conn)

-- Collect remaining items (destroys part)
Garbage:Collect()
```

---

## 🔍 Internal Logic

Internally, the module defines a set of **cleanup methods** mapped to Luau `typeof()` results:

```lua
local methods = {
	thread = task.cancel,
	function = task.spawn,
	Instance = game.Destroy,
	RBXScriptConnection = function(conn) conn:Disconnect() end,
	table = tbldestroy, -- recursively cleans tables
}
```

Each object added is associated with its proper cleanup function.
When `Collect()` is called, the garbager runs each corresponding method and clears the reference.

---

## 🧾 Type Definitions

```lua
export type garbager<T> = {
	Add: (self: garbager<T>, item: T) -> (),
	Remove: (self: garbager<T>, item: T) -> (),
	Collect: (self: garbager<T>) -> (),
	Destroy: (self: garbager<T>) -> (),
}
```

---

## ⚙️ Design Goals

* ✅ Simple and predictable cleanup
* 🧩 Works with any Roblox object type
* 🔒 Type-safe and `--!strict` compatible
* 🧠 Supports recursive table cleanup

---

## 🪪 License

**MIT License © 2025**

You’re free to use, modify, and distribute this code as long as the license notice is retained.

---

## 💡 Related Projects

If you like this module, you might also be interested in:

* [Maid](https://sleitnick.github.io/RbxUtil/api/Maid/) — classic cleanup helper by sleitnick
* [Trove](https://eryn.io/Trove) — an advanced resource manager for Roblox
