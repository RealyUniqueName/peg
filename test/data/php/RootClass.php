<?php
/**
 * File comment
 */

use some\UsedInMethodBodies;

/**
 * Class comment
 */
class RootClass
{
    /**
     * Const comment
     */
    const TYPE_INT = 1;
    const TYPE_FLOAT = 1.5;
    const TYPE_SQ_STR = 'hello';
    const TYPE_DQ_STR = "world";
    const TYPE_BOOL = true;

    /**
     * Static var doc block
     *
     * @var bool
     */
    public static $staticVarName = false;
    /**
     * Static var doc block
     *
     * @var null|string
     */
    public static $staticNullable = null;

    /**
     * Decodes something
     *
     * @param string $encodedValue Encoded in some format
     * @param int $objectDecodeType Optional; flag indicating how to decode
     *     something.
     * @return mixed
     * @throws RuntimeException
     */
    public static function decode(string $encodedValue, $objectDecodeType = self::TYPE_INT)
    {
        return json_decode($encodedValue);
    }

    /**
     * Protected method
     *
     * @param SplQueue $queue
     * @return void
     */
    protected static function staticProtectedMethod($queue) {

    }

    /**
     * Private method
     */
    private static function staticPrivateMethod()
    {
        while(true) {
            switch(10) {
                case 12:
                    throw new UsedInMethodBodies('oops');
                default:
                    break 2;
            }
        }
    }
}
