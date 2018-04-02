--remodo.ms

-- reFilein can not really have any dependencies, so.. we need to define something like that and remember to update it!
struct ReturnCode (

	-- Variable: ret
    -- public - The main return code, usually a boolean. Can be something else for specific purposes.
	ret = undefined,
	

	-- Variable: data
    -- public - Let's say the return code is set as true, then maybe you want to return some data ? It is it here. 
	data = undefined,

	-- Variable: ret
    -- public - In case the ret code is set to false, then maybe the function did leave a reason for the fail ? It is it here. 
	reason = undefined,

	fn new bool err_reason:undefined ok_reason:undefined ok_data:undefined err_data:undefined = (
		local ret = ReturnCode ret:(bool)
		if ret.ret then (
			ret.data   = ok_data
			ret.reason = ok_reason
		)
		else (
			ret.data   = err_data
			ret.reason = err_reason
		)

		ret
	),

	on create do ()
)


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


	fn getPath = (
		substituteString (getString()) "." @"\"
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


struct reFilein (

	private
	basepath = undefined,

	_dotnet_system_io_dir  = "System.IO.Directory",
	_dotnet_system_io_file = "System.IO.File",

	fn _directory_exists d = ((dotnetclass _dotnet_system_io_dir).Exists (d as string)),
	fn _file_exists      f = ((dotnetclass _dotnet_system_io_file).Exists (f as string)),
	fn _filein mod_str = (
		local ret     = ReturnCode ret:false

		-- Init the treedef mod
		local tDef = ModuleTreeDef()
		tDef.initFromArray (FilterString mod_str ".")

		-- init final str
		local tofilein_str = basepath
		
		-- Tree def array
		local tree_arr = tDef.getArray()
		if tree_arr.count > 0 then (

			-- We need to take care of submodules path
			if tree_arr.count > 1 then (
				for i=1 to tree_arr.count-1 do (
					tofilein_str = tofilein_str + @"\" +  tree_arr[i]

					if i == tree_arr.count-1 then (tofilein_str = tofilein_str + @"\")
				)
			)

			-- append File
			if tree_arr.count == 1 then (tofilein_str = tofilein_str + @"\")
			tofilein_str = tofilein_str + tree_arr[tree_arr.count]

			-- finally this will filein
			local mspath  = tofilein_str + ".ms"
			local msepath = tofilein_str + ".mse"

			local finalPath = undefined
			if (_file_exists mspath) then (
				finalPath = mspath
				ret.reason = "Filein (" + mspath
			)else(
				if (_file_exists msepath) then (
					finalPath = msepath
					ret.reason = "Filein (" + msepath
				)else(ret.reason = "No file found! (" + tofilein_str + ".ms|.mse)" )
			)
			ret.ret = finalPath != undefined
			if ret.ret then (
				try(filein finalPath)catch(
					ret.ret = false
					ret.reason = ("*** Remodo filein error, invalid file:  "+finalPath+" ****\n\n"+(getCurrentException())+"\n" )
				)
			)
			ret
		)
	),


	public
	fn init bp           = (this.set_basePath bp),
	fn validate_basePath = ((ReturnCode()).new (_directory_exists this.basepath) ok_reason:"Basepath is valid!" err_reason:"Invalid basepath!"),
	fn get_basePath      = (basepath),
	fn set_basePath p    = (
		local ret = ReturnCode ret:((dotnetclass "System.IO.Directory").Exists p) reason:(p + " does not exist!")
		if ret.ret then (
			ret.reason = ""
			this.basepath = p

			ret = validate_basePath()
			if ret.ret then (ret.reason = "Basepath set successfuly!")
		)
		ret
	),

	

	fn filein mod_str = (
		local ret = validate_basePath()
		if ret.ret then (
			ret = _filein mod_str
		)
		ret
	),
	on create do ()
) 



 rfile = reFilein()
 rfile.set_basePath @"C:\Work\code\3ds\maxscript\Modolize"
 rfile.filein "module_test.anotherModule.hello"
 rfile.filein "hello"
 rfile.validate_basePath()