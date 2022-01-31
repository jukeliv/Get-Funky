package;

using StringTools;

class Boyfriend extends Character
{
	public var stunned:Bool = false;

	public function new(x:Float, y:Float,?bf:String = 'bf')
	{
		super(x, y,bf);
	}

	override function update(elapsed:Float)
	{
		if (animation.curAnim.name.endsWith('miss') && animation.curAnim.finished && !debugMode)
		{
			playAnim('idle', true, false, 10);
		}
		super.update(elapsed);
	}
}
