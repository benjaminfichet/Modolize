-- Modolize needs ReturnCode.ms to be sourced somehow!
-- https://github.com/benjaminfichet/ReturnCode.git
----------------------------------------------------------------------------------------------
(
	if classof(ReturnCode) != StructDef then throw ("Modolize needs ReturnCode.ms to be sourced somehow!\n\tSee: https://github.com/benjaminfichet/ReturnCode.git\n\n")
)



/* 
	Class: ModoPathModel
		Represents a path in a .dot format. ie.: "C:\test\file" == "C:.test.file"
		Used by Modolizw in inter. to filein paths
		
		md = ModoPathModel()
		--> (ModoPathModel _a:undefined _s:undefined)
	
		md.initFromString @"C:.Users.benjaminf.Desktop.code"
		md.getString() 
		--> @"C:/Users/benjaminf/Desktop/code"

	Return: ReturnCode
*/
struct Modolize (
	public

	/*
		Modolize will be initialized with this at creation if this is undefined
		ie: 
			m = Modolize init_path:@"My/Path" -- instead of : 
			
			m = Modolize()
			m.init @"My/Path"
	*/
	init_path = undefined,
						  
	private
	basepath = undefined,

	fn _directory_exists d = ((dotnetclass "System.IO.Directory").Exists (d as string)),
	fn _file_exists      f = ((dotnetclass "System.IO.File").Exists (f as string)),
	fn _filein mod_str     = (
		

		-- Init the treedef mod
		local tDef = ModoPathModel()
		tDef.initFromArray (FilterString mod_str ".")

		-- init final str
		local tofilein_str = basepath
		
		-- Tree def array
		local tree_arr = tDef.getArray()
		local ret     = ReturnCode ret:(tree_arr.count > 0) reason:("Unable to parse str: "+mod_str)
		if ret.ret then (

			-- We need to take care of submodules
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
			)else(ret.reason = "Unable to make %finalPath%!")
			ret
		)
	),

	public
	fn init bp           = (this.set_basePath bp),
	fn validate_basePath = (ReturnCode.new (_directory_exists this.basepath) ok_reason:"Basepath is valid!" err_reason:"Invalid basepath!"),
	fn get_basePath      = (basepath),
	fn set_basePath p    = (
		this.basepath = p
		local ret = validate_basePath()
		if not ret.ret then (this.basepath = false)
		ret
	),
	fn set_path     p    = (set_basePath p),
	fn get_path          = (get_basePath()),

	fn filein mod_str = (
		local ret = validate_basePath()
		if ret.ret then (
			ret = _filein mod_str
		)
		ret
	),
	on create do (
		if classof(this.init_path) == String then (this.init this.init_path)
	)	
) 



--modo = Modolize()
--modo.set_basePath @"C:\Work\code\3ds\maxscript\Modolize"
--modo.filein "test.module_test.anotherModule.hello"
--modo.filein "test.hello"
--modo.validate_basePath()

--modo.init @"C:\symbdrives\BSSTools_Drive\SpiritTools"
--modo.filein "General_Tools.setup._functions.sym_functions"


--modo = Modolize init_path:@"C:\Work\code\3ds\maxscript\Modolize"
--modo.filein "test.hello"