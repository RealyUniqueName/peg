package php;

/**
 * Class comment
 */
@:native("\\RootClass")
extern class RootClass {
	/**
	 * Const comment
	 */
	@:phpClassConst static final TYPE_INT:Int;

	@:phpClassConst static final TYPE_FLOAT:Float;

	@:phpClassConst static final TYPE_SQ_STR:String;

	@:phpClassConst static final TYPE_DQ_STR:String;

	@:phpClassConst static final TYPE_BOOL:Bool;

	/**
	 * Static var doc block
	 *
	 * @var bool
	 */
	static var staticVarName:Bool;

	/**
	 * Static var doc block
	 *
	 * @var null|string
	 */
	static var staticNullable:Null<String>;

	/**
	 * Decodes something
	 *
	 * @param string $encodedValue Encoded in some format
	 * @param int $objectDecodeType Optional; flag indicating how to decode
	 *     something.
	 * @return mixed
	 * @throws RuntimeException
	 */
	static function decode(encodedValue:String, ?objectDecodeType:Int):Any;

	/**
	 * Protected method
	 *
	 * @param SplQueue $queue
	 * @return void
	 */
	private static function staticProtectedMethod(queue:SplQueue):Void;

}