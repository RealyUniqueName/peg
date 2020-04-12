<?php

/*
 * This file is part of the Foo package.
 *
 * (c) Ivan Ivanov <ivan@ivanov.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

namespace Vendor\Framework\Foo;

/**
 * A class to do foo.
 *
 * @author Ivan Ivanov <ivan@ivanov.com>
 */
final class Foo
{
    /**
     * @param string[] $foo Default foo
     * @param int   $bar Something bar
     * @param int   $baz Fallback baz
     *
     * @see RootInterface::TYPE_INT for something
     */
    public static function something(array $foo = [], int $bar = 1, int $baz = 2): \RootClass
    {
        if (\some_fun('arg')) {
            if ('abc' !== \ROOT_CONST || func(true) || func1('arg1') || func2(1.23)) {
                return new SomeClass($foo, $bar, $baz);
            }

            @smthng('', SOME_CONST);
        }

        return new RootClass($foo, $bar);
    }

    /**
     * Creates a foo.
     */
    public static function bar(string $foo, array $bar = [], int $baz = 6, int $quux = 50): Foo
    {
        $root = self::something([], $baz, $quux);

        return Something::doBar($foo, $bar, $baz);
    }
}
