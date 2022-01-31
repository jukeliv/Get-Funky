package;

import flixel.FlxGame;
import openfl.display.FPS;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		var framerate:Int = 120;
		#if web
		framerate = 60;
		#end
		addChild(new FlxGame(0, 0, FreeplayState,1,framerate,framerate,true,false));

		#if (!mobile&&!FLX_NO_DEBUG)
		addChild(new FPS(10, 3, 0xFFFFFF));
		#end
	}
}
