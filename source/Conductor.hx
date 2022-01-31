package;

import flixel.FlxG;

/**
 * ...
 * @author NinjaMuffin99
 */
class Conductor
{
	public static var bpm:Int = 100;
	/**
	 * beats in milliseconds
	 */
	public static var crochet:Float = ((60 / bpm) * 1000);
	/**
	 * steps in milliseconds
	 */
	public static var stepCrochet:Float = crochet / 4; 
	public static var songPosition:Float;
	public static var lastSongPos:Float;
	public static var offset:Float = 0;

	public static var safeFrames:Int = 10;
	/**
	 * is calculated in create(), is safeFrames in milliseconds
	 */
	public static var safeZoneOffset:Float = (safeFrames / 60) * 1000;

	public static function changeBPM(newBpm:Int)
	{
		bpm = newBpm;

		crochet = ((60 / bpm) * 1000);
		stepCrochet = crochet / 4;
	}
}
