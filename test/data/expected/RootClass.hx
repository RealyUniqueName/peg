package ;

import php.SplQueue;

/**
 * Class comment
 */
@:native("\\RootClass")
extern class RootClass {
	/**
	 * Const comment
	 */
	@:phpClassConst static final TYPE_ONE:Int;

	@:phpClassConst static final TYPE_ZERO:Int;

	/**
	 * Static var doc block
	 *
	 * @var bool
	 */
	static var staticVarName:Bool;

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
