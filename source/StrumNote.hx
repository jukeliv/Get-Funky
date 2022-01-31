package;

import flixel.util.FlxColor;
import openfl.display.GraphicsEndFill;
import flixel.FlxSprite;

import utilities.FunkinUtilities;

class StrumNote extends FlxSprite{
    public function new(strumY:Float,noteData:Int) {
        super();
        y = strumY;
        frames = FunkinUtilities.getFile('NOTE_assets',FunkinAssetType.SPARROW_ATLAS);
		animation.addByPrefix('green', 'arrowUP');
		animation.addByPrefix('blue', 'arrowDOWN');
		animation.addByPrefix('purple', 'arrowLEFT');
		animation.addByPrefix('red', 'arrowRIGHT');

		scrollFactor.set();
		setGraphicSize(Std.int(width * 0.7));
		updateHitbox();
		antialiasing = true;

        switch (Math.abs(noteData))
		{
			case 2:
                x += Note.swagWidth * 2;
				animation.addByPrefix('static', 'arrowUP');
				animation.addByPrefix('pressed', 'up press', 24, false);
				animation.addByPrefix('confirm', 'up confirm', 24, false);
			case 3:
                x += Note.swagWidth * 3;
				animation.addByPrefix('static', 'arrowRIGHT');
				animation.addByPrefix('pressed', 'right press', 24, false);
				animation.addByPrefix('confirm', 'right confirm', 24, false);
			case 1:
                x += Note.swagWidth * 1;
				animation.addByPrefix('static', 'arrowDOWN');
				animation.addByPrefix('pressed', 'down press', 24, false);
				animation.addByPrefix('confirm', 'down confirm', 24, false);
			case 0:
                x += Note.swagWidth * 0;
				animation.addByPrefix('static', 'arrowLEFT');
				animation.addByPrefix('pressed', 'left press', 24, false);
				animation.addByPrefix('confirm', 'left confirm', 24, false);
		}

		animation.play('static');
    }
    override public function update(elapsed:Float){
        super.update(elapsed);
        if(animation.curAnim.name != 'confirm'){
            color = FlxColor.fromString('#424242');
            alpha = 0.3;
        }
        else{
            color = FlxColor.WHITE;
            alpha = 1;
        }
    }
}