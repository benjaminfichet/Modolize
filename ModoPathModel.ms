/* 
	Class: ModoPathModel
		Represents a path in a .dot format. ie.: "C:\test\file" == "C:.test.file"
		Used by Modolizw in inter. to filein paths
		

		ex.:
		md = ModoPathModel()
		--> (ModoPathModel _a:undefined _s:undefined)
	
		md.initFromString @"C:.Users.benjaminf.Desktop.code"
		md.getString() 
		--> @"C:/Users/benjaminf/Desktop/code"
*/
struct ModoPathModel (

	private
	_a = undefined, -- The array which composes the path
	_s = undefined, -- The string path in dot format

	public
	/* 
		Function: getString
			Returns the complete string using the .dot notation

		Return: boolean|string
	*/
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

	/* 
		Function: getArray filterPattern:"."
			Returns an array from the string splitted by filterPattern which defaults to "."

		Return: boolean|string
	*/
	fn getArray filterPattern:"."  = (
		local ret = classof(this._s) == String
		if ret then (ret = filterString this._s filterPattern)
		ret
	),

	/* 
		Function: getPath()
			Returns the path in slash "/ format"

		Return: string
	*/
	fn getPath = (
		substituteString (getString()) "." @"\"
	),

	/* 
		Function: initFromArray a
			Inits the path using an array deifning the components

		Return: boolean
	*/
	fn initFromArray a = (
		local ret = classof(a) == Array
		if ret then (
			this._a = a
			this._s = this.getString()
		)
		ret
	),

	/* 
		Function: initFromString s
			Inits the path using a .dot string

		Return: boolean
	*/
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