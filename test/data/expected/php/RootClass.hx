package php;
/**
	Class comment
**/
@:native("\\RootClass") extern class RootClass {
	/**
		Const comment
	**/
	@:phpClasConst
	public final TYPE_INT : Int;
	@:phpClasConst
	public final TYPE_FLOAT : Float;
	@:phpClasConst
	public final TYPE_SQ_STR : String;
	@:phpClasConst
	public final TYPE_DQ_STR : String;
	@:phpClasConst
	public final TYPE_BOOL : Bool;
	/**
		Static var doc block

		@var bool
	**/
	public static var staticVarName : Bool;
	/**
		Static var doc block

		@var null|string
	**/
	public static var staticNullable : Null<String>;
	/**
		Decodes something

		@param string $encodedValue Encoded in some format
		@param int $objectDecodeType Optional; flag indicating how to decode
		    something.
		@return mixed
		@throws RuntimeException
	**/
	public static function decode(encodedValue:String, ?objectDecodeType:Int):Any;
	/**
		Protected method

		@param SplQueue $queue
		@return void
	**/
	private static function staticProtectedMethod(queue:php.SplQueue):Void;
}