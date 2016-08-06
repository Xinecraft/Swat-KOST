class Utils extends Core.Object;

/**
 * Copyright (c) 2014 Sergei Khoroshilov <kh.sergei@gmail.com>
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright Notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

/**
 * List of objective class names
 * @type array<string>
 */
var array<string> ObjectiveClass;

/**
 * List of procedure class names
 * @type array<string>
 */
var array<string> ProcedureClass;

/**
 * List of ammo class names
 * @type array<string>
 */
var array<string> AmmoClass;

/**
 * Return the last 8 characters of a md5 hash computed of given Key, Port and unix timestamp values
 *
 * @param   string Key
 * @param   string Port
 * @param   string Unixtime
 * @return  string
 */
static function string ComputeHash(coerce string Key, coerce string Port, coerce string Unixtime)
{
    return Right(ComputeMD5Checksum(Key $ Port $ Unixtime), 8);
}

/**
 * Encode a string by replacing it with its corresponding position in array Array
 *
 * @param   string String
 * @param   array<string> Array
 * @return  string
 */
static function string EncodeString(coerce string String, array<string> Array)
{
    return string(class'Utils.ArrayUtils'.static.Search(Array, String, true));
}

/**
 * Join non empty keys with Delimiter
 *
 * @param   string Key1
 * @param   string Key2 (optional)
 * @param   string Key3 (optional)
 * @param   string Key4 (optional)
 * @param   string Key5 (optional)
 * @return  string
 */
static function string FormatDelimitedKey(string Key1, optional string Key2, optional string Key3, optional string Key4, optional string Key5)
{
    local int i;
    local array<string> Keys;

    Keys[0] = Key1;
    Keys[1] = Key2;
    Keys[2] = Key3;
    Keys[3] = Key4;
    Keys[4] = Key5;

    // Remove empty keys
    for (i = Keys.Length-1; i >= 0; i--)
    {
        if (Keys[i] == "")
        {
            Keys.Remove(i, 1);
        }
    }

    return class'Utils.ArrayUtils'.static.Join(Keys, class'Extension'.const.KEY_DELIMITER);
}

/**
 * Enclose non empty key components in square brackets
 *
 * @param   string Key1
 * @param   string Key2 (optional)
 * @param   string Key3 (optional)
 * @param   string Key4 (optional)
 * @param   string Key5 (optional)
 * @return  string
 */
static function string FormatArrayKey(string Key1, optional string Key2, optional string Key3, optional string Key4, optional string Key5)
{
    local int i;
    local array<string> Keys;

    Keys[0] = Key2;
    Keys[1] = Key3;
    Keys[2] = Key4;
    Keys[3] = Key5;

    for (i = Keys.Length-1; i >= 0; i--)
    {
        // Remove empty components
        if (Keys[i] == "")
        {
            Keys.Remove(i, 1);
        }
        // Otherwise enclose them in a pair of square brackets
        else
        {
            Keys[i] = "[" $ Keys[i] $ "]";
        }
    }

    return Key1 $ class'Utils.ArrayUtils'.static.Join(Keys, "");
}
