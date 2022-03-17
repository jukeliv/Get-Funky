package;

import flixel.util.FlxColor;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;

using StringTools;

/**
 * Loosley based on FlxTypeText lolol
 */
class Alphabet extends FlxSpriteGroup
{
	public var delay:Float = 0.05;
	public var paused:Bool = false;

	public var upperCaseColor:FlxColor = 0x08CFF2;
	public var defColor:FlxColor = 0x08F293;

	var _finalText:String = "";
	var _curText:String = "";

	// custom shit
	// amp, backslash, question mark, apostrophy, comma, angry faic, period
	var lastSprite:AlphaCharacter;

	public function new(x:Float, y:Float, text:String = "", ?bold:Bool = false)
	{
		super(x, y);

		_finalText = text;

		var arrayShit:Array<String> = text.split("");
		trace(arrayShit);

		for (character in arrayShit)
		{
			var xPos:Float = 0;
			if (lastSprite != null)
			{
				xPos = lastSprite.x + lastSprite.frameWidth - 40;
			}

			// var letter:AlphaCharacter = new AlphaCharacter(30 * loopNum, 0);
			var letter:AlphaCharacter = new AlphaCharacter(xPos, 0,upperCaseColor,defColor);
			letter.createBold((!AlphaCharacter.alphabet.contains(character.toLowerCase()))?AlphaCharacter.alphabet.charAt(0):character);
			add(letter);

			lastSprite = letter;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
	}
}

class AlphaCharacter extends FlxSprite
{
	public static var alphabet:String = "abcdefghijklmnopqrstuvwxyz";

	var numbers:String = "1234567890";
	var symbols:String = "|~#$%()*+-:;<=>@[]^_";

	var colorA:FlxColor;
	var colorB:FlxColor;
	public function new(x:Float, y:Float,colorUp:FlxColor,color:FlxColor)
	{
		super(x, y);
		colorA = color;
		colorB = colorUp;
		frames = utilities.FunkinUtilities.getFile('alphabet', utilities.FunkinUtilities.FunkinAssetType.SPARROW_ATLAS);

		antialiasing = true;
	}

	public function createBold(letter:String)
	{
		animation.addByPrefix(letter, letter.toUpperCase() + " bold", 24);

		if(letter.toUpperCase() == letter)
			this.color = colorB;
		else{
			this.color = colorA;
		}

		animation.play(letter);
		updateHitbox();
	}

	public function createLetter(letter:String):Void
	{
		var letterCase:String = "lowercase";
		if (letter.toLowerCase() != letter)
		{
			letterCase = 'capital';
		}

		animation.addByPrefix(letter, letter + " " + letterCase, 24);
		animation.play(letter);
	}
}
