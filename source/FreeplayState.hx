package;

import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import utilities.FunkinUtilities;

class FreeplayState extends MusicBeatState
{
	var songs:Array<String> = ["Bopeebo", "Dadbattle", "Fresh", "Tutorial"];

	var selector:FlxText;
	var curSelected:Int = 0;

	override function create()
	{
		FlxG.sound.playMusic(FunkinUtilities.getFile('songs/${songs[curSelected]}',FunkinAssetType.MUSIC),0.7);
		
		var bg:FlxSprite = FunkinUtilities.getFile('stageback');
		add(bg);

		for (i in 0...songs.length)
		{
			var songText:Alphabet = new Alphabet(40, (70 * i) + 30, songs[i]);
			//songText.defColor = FlxColor.BLUE;
			add(songText);
		}

		selector = new FlxText();
		selector.size = 40;
		selector.text = ">";
		add(selector);

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		super.create();
	}

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.UP)
		{
			changeSelected(-1);
		}
		if (FlxG.keys.justPressed.DOWN)
		{
			changeSelected(1);
		}

		selector.y = (70 * curSelected) + 30;

		if (FlxG.keys.justPressed.ENTER)
		{
			PlayState.SONG = Song.loadFromJson(songs[curSelected].toLowerCase());
			FlxG.switchState(new PlayState());
		}

		super.update(elapsed);
	}
	private function changeSelected(change:Int){
		curSelected+=change;
		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;
		FlxG.sound.playMusic(FunkinUtilities.getFile('songs/${songs[curSelected]}',FunkinAssetType.MUSIC),0.7);
	}
}
