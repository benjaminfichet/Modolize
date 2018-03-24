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

--m = Modulo()
--m.init (@"C:\Work\code\3ds\maxscript\Modolize\")
--m.file_in "module_test.filetest"
--m.file_in "module_test.anotherModule.hello"
--m.file_in "test"

struct ModuleTreeNode (root_node, name)



fn makeModulesTreeFromString str tree:#() = (
	local ret = ModolizeRet ret:((classof str) == String) reason:"Was not given a string! (makeModulesTreeFromString())"
	if ret.ret then (
		ret.reason = ""

		-- Tokenize by dots
		local tokens = filterString str "."
		if tokens.count > 1 then (           -- We need to process submodules!

			-- first Module 
			local rNode = undefined
			if (classof(tree) == Array and (tree.count > 0)) then (rNode = tree[tree.count])
			append tree (ModuleTreeNode name:(tokens[1]) root_node:rNode)

			-- Rebuild the str without the first module to recurse over it
			local newStr = ""
			for i=2 to tokens.count do (
				
				newStr = newStr + tokens[i]
				if i<tokens.count then (newStr = newStr + ".")
			)

			--format "newStr: %\n" newStr

			-- Recurse the new str
			makeModulesTreeFromString newStr tree:tree
		)
		-- We are at the end
		if tokens.count == 1 do (
			local rNode = if (classof(tree) == Array and (tree.count > 0)) then (rNode = tree[tree.count]) else (undefined)
			append tree (ModuleTreeNode name:(tokens[1]) root_node:rNode)
		)
	)
	ret
)


str  = "module_test.anotherModule.hello"
--tree = #()
--
--makeModulesTreeFromString str tree:tree
--tree = tree[tree.count]
--print(tree)


0



struct ModuleNode (
	name, root_node, index
)





md = ModuleTreeDef()
md.initFromString "module_test.another_module.hellofile"
moduldef_array = md.getArray()
strdef_array   = md.getString()


-- Build up non chained modules array
non_chained_modules = #()

for i=1 to (moduldef_array.count) do (
	local mstr  = moduldef_array[i]
	local mnode = (ModuleNode name:m index:i)
	
	append non_chained_modules mnode
)

-- basic sanity check, should always pass!
-- (moduldef_array.count) (non_chained_modules.count) should be equal
assert_equal (moduldef_array.count) (non_chained_modules.count)


-- Chains modules in order
modules_tree = undefined
for i=2 to non_chained_modules.count do (
	-- Find 
	local str_name  = moduldef_array[i]
	local ncm       = non_chained_modules[i]
	local last_node = non_chained_modules[i-1]

	non_chained_modules[i].root_node = last_node
)







/*
for i=exploded_string.count to 1 by -1 do (
	local last_ = exploded_string[i]

	local rNode = try(exploded_string[i-1])catch(undefined)
	local mn = ModuleNode name:last_ root_node:rNode
)*/




--format "ModuleA.ModuleB.FileC str to array: %\n" (md.getArray())
