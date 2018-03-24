--ModuleTreeDef


struct ModuleTreeDef (

	private
	_a = undefined,
	_s = undefined,

	public
	fn getString = (
		local ret = classof(this._a) == Array
		if ret then (
			local retStr = ""
			for i=1 to this._a.count do (
				retStr = retStr + this._a[i]
				if i < this._a.count then (retStr = retStr + ".")
			)
			ret = retStr
		)
		ret
	),

	fn getArray  = (
		local ret = classof(this._s) == String
		if ret then (ret = filterString this._s ".")
		ret
	),

	fn initFromArray a = (
		local ret = classof(a) == Array
		if ret then (
			this._a = a
			this._s = this.getString()
		)
		ret
	),

	fn initFromString s = (
		local ret = classof(s) == String
		if ret then (
			this._s = s
			this._a = this.getArray()
		)
		ret
	),

	on create do ()
)


if MODULIZE_TESTING_ON == true then (
	md = ModuleTreeDef()
	md.initFromArray #("ModuleA", "ModuleB", "FileC")
	format "#(\"ModuleA\", \"ModuleB\", \"FileC\") array to str: %\n" (md.getString())

	md = ModuleTreeDef()
	md.initFromString "ModuleA.ModuleB.FileC"
	format "ModuleA.ModuleB.FileC str to array: %\n" (md.getArray())
)