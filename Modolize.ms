--poc.ms
struct ModolizeRet (
	ret = undefined,
	reason = undefined
)

struct Modolize (

	fs_base = undefined,
	fs_dir  = undefined,
	fs_name = undefined,
	fs_ext  = undefined,

	fn _file_in f_path = (
		local ret = ModolizeRet ret:(doesFileExist f_path)
		if ret.ret then (
			ret.ret = false
			try(
				filein f_path
				ret.ret = true
				ret.reason = "File(d)in ("+(f_path)+")"
			)catch(
				ret.ret = false
				ret.reason = "Unable to filein, prob errors in ("+(f_path)+")'s code."
			)
		)else(ret.reason = ("File does not exists ("+f_path+")"))
		ret
	),

	fn relative_file_in f_name = (this._file_in (fs_dir + f_name)),
	fn global_file_in   f_path = (this._file_in f_path),
	fn refresh = (
		
	),

	fn init basefile = (this.setBasefile basefile),
	fn setBasefile b = (
		this.fs_base = b
		this.fs_name = getFilenameFile(this.fs_base)
		this.fs_dir  = getFilenamePath(this.fs_base)
		this.fs_ext  = getFilenameType(this.fs_base)
	),

	on create do ()
)

--x = Modolize()
--x.relative_file_in "test.ms"



struct ModuloFile (
	base = undefined,
	dir  = undefined,
	name = undefined,
	ext  = undefined,

	fn init fs_base = (
		this.base = fs_base
		this.dir   = getFilenamePath(this.base)
		this.name  = getFilenameFile (this.base)
		this.ext   = getFilenameType(this.base)
	),

	fn validate = (
		local vExt = this.ext == ".ms"
		local vFile= doesFileExist this.base
		(vExt and vFile)
	),

	fn file_in = (
		local ret = this.validate()
		if ret then (
			--break("ModuloFile file_in")
			filein this.base
		)
		ret
	),
	on create do ()
)

struct Modulo (
	name       = undefined,
	subs       = undefined,
	files      = undefined,
	fs_dir     = undefined,

	fn init fs_dir = (
		this.fs_dir = fs_dir
		local fspl = filterString fs_dir @"\"
		this.name = fspl[fspl.count]

		local dirs = getDirectories (fs_dir + @"*")
		for d in dirs do (
			local dfiles = getFiles (d + @"*.ms")
			if dfiles.count > 0 then (
				local mo = Modulo()
				mo.init d
				append this.subs (mo)
				--break()
			)
		)

		local fs_files = getFiles (fs_dir + @"*.ms")
		for f in fs_files do (
			local mf = ModuloFile()
			mf.init f
			append this.files (mf)
			--break()
		)
		
	),


	fn get_module mname = (
		local ret = false
		local s = for i in this.subs where i.name == mname collect i
		if s.count > 0 then (ret = s[1])
		ret
	),

	fn get_file fname = (
		local ret = false
		local s = for i in this.files where i.name == fname collect i
		if s.count > 0 then (ret = s[1])
		ret
	),

	fn file_in modstr modulo_object:undefined index:1 = (
		if modulo_object == undefined then (modulo_object = this) -- Do we search the submodule from a modulo object and not from this ?
		local tokens = filterString modstr "."

		-- We need to filein a file from fs_dir
		if tokens.count == 1 then (
			local mfile = modulo_object.get_file tokens[1]
			if mfile != false then (
				mfile.file_in()
			)
		)

		-- We need to filein a file a submodule file
		if tokens.count > 1 then ( 

			local basemodulo = this.get_module tokens[1]
			if basemodulo != false then (

				-- Make new sub str
				local new_modstr = ""
				for i = index to tokens.count do (
					new_modstr = new_modstr + tokens[i]
					if i < tokens.count do (
						new_modstr = new_modstr + "."
					)
				)
				if new_modstr != "" then (modulo_object.file_in new_modstr modulo_object:basemodulo index:(index+1))
			)
		)
	),

	on create do (
		subs  = #()
		files = #()
	)
)

m = Modulo()
m.init (@"C:\Work\code\3ds\maxscript\Modolize\")
m.file_in "module_test.filetest"
m.file_in "module_test.anotherModule.hello"
--m.file_in "test"