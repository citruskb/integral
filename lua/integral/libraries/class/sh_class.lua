-- Pretty much copied from https://stackoverflow.com/questions/1092832/how-to-create-a-class-subclass-and-properties-in-lua
-- Seems useful and why reinvent the wheel?

Class = {}

function Class:Create(super, meta_name)
	local class, meta = {}, {}
	class.meta = meta

	-- When accessing an existing index
	function meta:__index(key)
		if class[key] ~= nil then
			return class[key]
		elseif super then
			return super.meta.__index(self, key)
		elseif class.meta[key] ~= nil then
			return class.meta[key]
		else
			return nil
		end
	end

	-- When indexing a new value into
	function meta:__newindex(key, val)
		if super then
			return super.meta.__newindex(self, key, val)
		else
			rawset(self, key, val)
		end
	end

	-- When trying to print
	function meta:__tostring()
		if self.ToString then
			return self:ToString()
		elseif super then
			return super.meta.__tostring(self)
		else
			error("Class has no ToString() func.")
		end
	end

	-- When trying call as a function (ie. obj())
	function meta:__call()
		if self.Call then
			return self:Call()
		elseif super then
			return super.meta.__call(self)
		else
			error("Class has no Call() func.")
		end
	end

	-- # operator (ie. #obj)
	function meta:__len()
		if self.Len then
			return self:Len()
		elseif super then
			return super.meta.__len(self)
		else
			error("Class has no Len() func.")
		end
	end

	-- Unary negation (ie. -obj)
	function meta:__unm()
		if self.Unm then
			return self:Unm()
		elseif super then
			return super.meta.__unm(self)
		else
			error("Class has no Unm() func.")
		end
	end

	-- self + other
	function meta:__add(other)
		if IsNumber(self) then return other:__add(self) end -- Handle number values.

		if self.Add then
			return self:Add(other)
		elseif super then
			return super.meta.__add(self, other)
		else
			error("Class has no Add(other) func.")
		end
	end

	-- self - other
	function meta:__sub(other)
		if IsNumber(self) then return other:__sub(self) end -- Handle number values.

		if self.Sub then
			return self:Sub(other)
		elseif super then
			return super.meta.__sub(self, other)
		else
			error("Class has no Sub(other) func.")
		end
	end

	-- a * b
	function meta:__mul(other)
		if IsNumber(self) then return other:__mul(self) end -- Handle number values.

		if self.Mul then
			return self:Mul(other)
		elseif super then
			return super.meta.__mul(self, other)
		else
			error("Class has no Mul(other) func.")
		end
	end

	-- a / b
	function meta:__div(other)
		if IsNumber(self) then return other:__div(self) end -- Handle number values.

		if self.Div then
			return self:Div(other)
		elseif super then
			return super.meta.__div(self, other)
		else
			error("Class has no Div(other) func.")
		end
	end

	-- a ^ b
	function meta:__pow(other)
		if IsNumber(self) then return other:__pow(self) end -- Handle number values.

		if self.Pow then
			return self:Pow(other)
		elseif super then
			return super.meta.__pow(self, other)
		else
			error("Class has no Pow(other) func.")
		end
	end

	-- a % b
	function meta:__mod(other)
		if IsNumber(self) then return other:__mod(self) end -- Handle number values.

		if self.Mod then
			return self:Mod(other)
		elseif super then
			return super.meta.__mod(self, other)
		else
			error("Class has no Mod(other) func.")
		end
	end

	-- a .. b
	function meta:__concat(other)
		if self.Concat then
			return self:Concat(other)
		elseif super then
			return super.meta.__concat(self, other)
		else
			error("Class has no Concat(other) func.")
		end
	end

	-- a == b
	function meta:__eq(other)
		if IsNumber(self) then return other:__eq(self) end -- Handle number values.

		if self.Eq then
			return self:Eq(other)
		elseif super then
			return super.meta.__eq(self, other)
		else
			error("Class has no Eq(other) func.")
		end
	end

	-- a < b
	function meta:__lt(other)
		if IsNumber(self) then return other:__lt(self) end -- Handle number values.

		if self.Lt then
			return self:Lt(other)
		elseif super then
			return super.meta.__lt(self, other)
		else
			error("Class has no Lt(other) func.")
		end
	end

	-- a <= b
	function meta:__le(other)
		if IsNumber(self) then return other:__le(self) end -- Handle number values.

		if self.Le then
			return self:Le(other)
		elseif super then
			return super.meta.__le(self, other)
		else
			error("Class has no Le(other) func.")
		end
	end

	function class:Create(...)
		local obj = setmetatable({}, self.meta)
		if obj.__Create then
			return obj:__Create(...)
		else
			return obj
		end
	end

	if meta_name then
		--print("Registering new metatable: ", meta_name)
		RegisterMetaTable(meta_name, meta)
	end

	return class
end