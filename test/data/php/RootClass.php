<?php
/**
 * File comment
 */

use SplQueue;

/**
 * Class comment
 */
class RootClass
{
    /**
     * Const comment
     */
    const TYPE_ONE  = 1;
    const TYPE_ZERO = 0;

    /**
     * Static var doc block
     *
     * @var bool
     */
    public static $staticVarName = false;

    /**
     * Decodes something
     *
     * @param string $encodedValue Encoded in some format
     * @param int $objectDecodeType Optional; flag indicating how to decode
     *     something.
     * @return mixed
     * @throws RuntimeException
     */
    public static function decode($encodedValue, $objectDecodeType = self::TYPE_ONE)
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

    }
}
