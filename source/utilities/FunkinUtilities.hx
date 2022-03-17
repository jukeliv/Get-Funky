package utilities;

import lime.text.Font;
import lime.utils.Assets;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

class FunkinUtilities {
    private static final soundExt:String = #if(!html)'ogg'#else'mp3'#end;
    /**
    * Returns a Path to dont use Haxe AssetsPath.hx
    * It can return a animation frames atlas if you use the
    * Asset Type "SPARROW_ATLAS"
    */
    public static function getFile(file:String,?type:FunkinAssetType = IMAGE):Dynamic{
        var daType = type;
        switch(daType){
            case IMAGE:
                return 'assets/images/$file.png';
            case FONT:
                return 'assets/fonts/$file';
            case XML:
                return 'assets/images/$file.xml';
            case INSTRUMENTAL:
                return getFile('songs/${file}_Inst',FunkinAssetType.MUSIC);
            case VOICES:
                return getFile('songs/${file}_Voices',FunkinAssetType.MUSIC);
            case MUSIC:
                return 'assets/music/$file.$soundExt';
            case JSON:
                return 'assets/data/$file.json';
            case SPARROW_ATLAS:
                return FlxAtlasFrames.fromSparrow(getFile(file,IMAGE),getFile(file,XML));
            case TXT:
                return 'assets/data/$file.txt';
            default:
                return 'assets/$file';
        }
    }
    public static function getTextArray(file:String):Array<String>{
        return (Assets.getText(getFile(file,FunkinAssetType.TXT)).trim().split('\n'));
    }
}
@:enum abstract FunkinAssetType(String) to String
{
    var IMAGE = 'IMAGE';
    var JSON = 'JSON';
    var FONT = 'FONT';
    var XML = 'XML';
    var INSTRUMENTAL = 'INSTRUMENTAL';
    var VOICES = 'VOICES';
    var MUSIC = 'MUSIC';
    var SOUNDS = 'SOUNDS';
    var TXT = 'TXT';
    var SPARROW_ATLAS = 'SPARROW_ATLAS';
}