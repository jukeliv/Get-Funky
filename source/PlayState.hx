package;

import Section.SwagSection;
import Song.SwagSong;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import utilities.FunkinUtilities;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;

using StringTools;

class PlayState extends MusicBeatState
{
	public static var instance:PlayState = null;
	public static var curLevel:String = 'Bopeebo';
	public static var SONG:SwagSong;

	public var vocals:FlxSound;

	private var dad:Character;
	private var gf:Character;
	public var boyfriend:Boyfriend;

	private var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	private var strumLine:FlxSprite;
	private var curSection:Int = 0;

	private var sectionScores:Array<Dynamic> = [[], []];
	private var sectionLengths:Array<Int> = [];

	private var camFollow:FlxObject;
	private var strumLineNotes:FlxTypedGroup<StrumNote>;
	private var playerStrums:FlxTypedGroup<StrumNote>;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	private var gfSpeed:Int = 1;
	private var health:Float = 1;
	private var combo:Int = 0;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	private var healthHeads:FlxSprite;
	private var UI_camera:FlxCamera;

	var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override public function create()
	{
		instance = this;

		PlayerSettings.init();

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson(curLevel);

		var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(FunkinUtilities.getFile('stageback'));
		// bg.setGraphicSize(Std.int(bg.width * 2.5));
		// bg.updateHitbox();
		bg.antialiasing = true;
		bg.scrollFactor.set(0.9, 0.9);
		bg.active = false;
		add(bg);

		var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(FunkinUtilities.getFile('stagefront'));
		stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
		stageFront.updateHitbox();
		stageFront.antialiasing = true;
		stageFront.scrollFactor.set(0.9, 0.9);
		stageFront.active = false;
		add(stageFront);

		var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(FunkinUtilities.getFile('stagecurtains'));
		stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
		stageCurtains.updateHitbox();
		stageCurtains.antialiasing = true;
		stageCurtains.scrollFactor.set(1.3, 1.3);
		stageCurtains.active = false;

		gf = new Character(400, 130, 'gf');
		gf.scrollFactor.set(0.95, 0.95);
		gf.antialiasing = true;
		add(gf);

		dad = new Character(100, 100, SONG.player2);
		add(dad);

		switch (SONG.player2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
			case "spooky":
				dad.y += 200;
		}

		boyfriend = new Boyfriend(770, 450,SONG.player1);
		add(boyfriend);

		add(stageCurtains);

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		UI_camera = new FlxCamera(0, 0, FlxG.width, FlxG.height, 1);

		strumLineNotes = new FlxTypedGroup<StrumNote>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<StrumNote>();

		startingSong = true;

		startCountdown();

		generateSong(SONG.song);

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);
		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = 1.05;

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(FunkinUtilities.getFile('healthBar'));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		// healthBar
		add(healthBar);

		healthHeads = new FlxSprite();
		var headTex = FunkinUtilities.getFile('healthHeads',FunkinAssetType.SPARROW_ATLAS);
		healthHeads.frames = headTex;
		healthHeads.animation.add('healthy', [0]);
		healthHeads.animation.add('unhealthy', [1]);
		healthHeads.y = healthBar.y - (healthHeads.height / 2);
		healthHeads.scrollFactor.set();
		healthHeads.antialiasing = true;
		add(healthHeads);

		super.create();
	}

	function startCountdown():Void
	{
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			switch (swagCounter)
			{
				case 0:
					FlxG.sound.play('assets/sounds/intro3' + TitleState.soundExt, 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(FunkinUtilities.getFile('ready'));
					ready.scrollFactor.set();
					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play('assets/sounds/intro2' + TitleState.soundExt, 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic('assets/images/set.png');
					set.scrollFactor.set();
					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play('assets/sounds/intro1' + TitleState.soundExt, 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic('assets/images/go.png');
					go.scrollFactor.set();
					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play('assets/sounds/introGo' + TitleState.soundExt, 0.6);
				case 4:
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	var lastReportedPlayheadPosition:Int = 0;

	function startSong():Void
	{
		lastReportedPlayheadPosition = 0;

		startingSong = false;
		FlxG.sound.playMusic(FunkinUtilities.getFile(SONG.song,FunkinAssetType.INSTRUMENTAL));
		vocals.play();
	}

	var debugNum:Int = 0;

	private function generateSong(dataPath:String):Void
	{
		generateStaticArrows(0);
		generateStaticArrows(1);

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(FunkinUtilities.getFile(curSong,FunkinAssetType.VOICES));
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);
			for (songNotes in section.sectionNotes)
			{
				sectionScores[0].push(0);
				sectionScores[1].push(0);

				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes.noteData > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
			daBeats += 1;
			}
		}

		trace(unspawnNotes.length);

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			FlxG.log.add(i);
			var babyArrow:StrumNote = new StrumNote(strumLine.y,i);

			babyArrow.y -= 10;
			babyArrow.alpha = 0;
			FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});

			babyArrow.ID = i;

			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);

			if (player == 1)
				playerStrums.add(babyArrow);
			strumLineNotes.add(babyArrow);
		}
	}

	var sectionScored:Bool = false;

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			FlxG.sound.music.pause();
			vocals.pause();
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			vocals.time = FlxG.sound.music.time;

			FlxG.sound.music.play();
			vocals.play();
			paused = false;
		}

		super.closeSubState();
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ENTER)
		{
			persistentUpdate = false;
			persistentDraw = true;
			FlxG.sound.pause();
			vocals.pause();
			boyfriend.stunned = true;
			paused = true;

			openSubState(new PauseSubState());
		}

		if (FlxG.keys.justPressed.ESCAPE)
		{
			FlxG.switchState(new ChartingState());
		}

		healthHeads.setGraphicSize(Std.int(FlxMath.lerp(100, healthHeads.width, 0.98)));
		healthHeads.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (healthHeads.width / 2);

		if (healthBar.percent < 20)
			healthHeads.animation.play('unhealthy');
		else
			healthHeads.animation.play('healthy');

		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */
		if (FlxG.keys.justPressed.EIGHT)
			FlxG.switchState(new AnimationDebug(SONG.player2));

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			if(!paused)
				Conductor.songPosition = FlxG.sound.music.time;

			vocals.time = Conductor.songPosition;

			// Interpolation type beat
			if (Conductor.lastSongPos != Conductor.songPosition)
			{
				Conductor.lastSongPos = Conductor.songPosition;
			}
		}

		var playerTurn:Int = 0;
		if (sectionLengths.length > curSection)
			playerTurn = totalBeats % (sectionLengths[curSection] * 8);

		if (playerTurn == (sectionLengths[curSection] * 8) - 1 && !sectionScored)
		{
			// popUpScore();
			sectionScored = true;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (camFollow.x != dad.getMidpoint().x + 150 && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
				vocals.volume = 1;
			}

			if (PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 100)
			{
				camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
			}
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(1.05, FlxG.camera.zoom, 0.96);
		}

		if (playerTurn < 4)
		{
			sectionScored = false;
		}

		FlxG.watch.addQuick("beatShit", totalBeats);

		if (curSong == 'Fresh')
		{
			switch (totalBeats)
			{
				case 16:
					camZooming = true;
					gfSpeed = 2;
				case 48:
					gfSpeed = 1;
				case 80:
					gfSpeed = 2;
				case 112:
					gfSpeed = 1;
				case 163:
					FlxG.sound.music.stop();
					curLevel = 'Bopeebo';
					FlxG.switchState(new TitleState());
			}
		}

		if (curSong == 'Bopeebo')
		{
			switch (totalBeats)
			{
				case 127:
					FlxG.sound.pause();
					vocals.pause();
					curLevel = 'Fresh';
					FlxG.switchState(new PlayState());
			}
		}
		// better streaming of shit

		if (health <= 0)
		{
			boyfriend.stunned = true;
			FlxG.sound.pause();
			vocals.pause();
			FlxG.switchState(new GameOverState());
		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 1500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.y > FlxG.height)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}

				if (!daNote.mustPress && daNote.wasGoodHit)
				{
					dad.playAnim(Character.singMap[daNote.noteData]);

					vocals.volume = 1;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				var strumNote = daNote.mustPress?playerStrums.members[daNote.noteData].x:strumLineNotes.members[daNote.noteData].x;
				daNote.x = strumNote;
				daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

				if (daNote.y < -daNote.height)
				{
					if (daNote.tooLate)
					{
						noteMiss(daNote.noteData,0.05);
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				if(daNote.isSustainNote && daNote.mustPress){

					if(daNote.prevNote.tooLate){
						daNote.tooLate = true;
						daNote.destroy();
					}

				}
			});
		}

		keyShit();
	}

	private function popUpScore(strumtime:Float):Void
	{
		var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;

		var rating:FlxSprite = new FlxSprite();

		var daRating:String = "sick";

		if (noteDiff > Conductor.safeZoneOffset * 0.9)
		{
			daRating = 'shit';
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.75)
		{
			daRating = 'bad';
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.2)
		{
			daRating = 'good';
		}

		rating.loadGraphic(FunkinUtilities.getFile(daRating,FunkinAssetType.IMAGE));
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.setGraphicSize(Std.int(rating.width * 0.7));
		rating.updateHitbox();
		rating.antialiasing = true;
		rating.velocity.x -= FlxG.random.int(0, 10);

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(FunkinUtilities.getFile('combo'));
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.antialiasing = true;
		comboSpr.velocity.y -= 150;
		comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
		comboSpr.updateHitbox();
		comboSpr.velocity.x += FlxG.random.int(1, 10);
		add(rating);

		var seperatedScore:Array<Int> = [];

		seperatedScore.push(Math.floor(combo / 100));
		seperatedScore.push(Math.floor((combo - (seperatedScore[0] * 100)) / 10));
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic('assets/images/num' + Std.int(i) + '.png');
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;
			numScore.antialiasing = true;
			numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			numScore.updateHitbox();
			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);
			add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}

		coolText.text = Std.string(seperatedScore);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});

		curSection += 1;
	}

	private function keyShit():Void
		{
	
			var controlArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
	
			if ((controls.UP || controls.RIGHT || controls.DOWN || controls.LEFT) && !boyfriend.stunned && generatedMusic)
			{
				//boyfriend.holdTimer = 0;
	
				var possibleNotes:Array<Note> = [];
	
				var ignoreList:Array<Int> = [];
	
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate)
					{
						// the sorting probably doesn't need to be in here? who cares lol
						possibleNotes.push(daNote);
						possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
	
						ignoreList.push(daNote.noteData);
					}
	
				});
	
				if (possibleNotes.length > 0)
				{
					var daNote = possibleNotes[0];
	
					// Jump notes
					if (possibleNotes.length >= 2)
					{
						if (possibleNotes[0].strumTime == possibleNotes[1].strumTime)
						{
							for (coolNote in possibleNotes)
							{
								if (controlArray[coolNote.noteData])
									goodNoteHit(coolNote);
								else
								{
									var inIgnoreList:Bool = false;
									for (shit in 0...ignoreList.length)
									{
										if (controlArray[ignoreList[shit]])
											inIgnoreList = true;
									}
									if (!inIgnoreList)
										badNoteCheck();
								}
							}
						}
						else if (possibleNotes[0].noteData == possibleNotes[1].noteData)
						{
							noteCheck(controlArray[daNote.noteData], daNote);
						}
						else
						{
							for (coolNote in possibleNotes)
							{
								noteCheck(controlArray[coolNote.noteData], coolNote);
							}
						}
					}
					else // regular notes?
					{
						noteCheck(controlArray[daNote.noteData], daNote);
					}
					/* 
						if (controlArray[daNote.noteData])
							goodNoteHit(daNote);
					 */
					// trace(daNote.noteData);
					/* 
						switch (daNote.noteData)
						{
							case 2: // NOTES YOU JUST PRESSED
								if (upP || rightP || downP || leftP)
									noteCheck(upP, daNote);
							case 3:
								if (upP || rightP || downP || leftP)
									noteCheck(rightP, daNote);
							case 1:
								if (upP || rightP || downP || leftP)
									noteCheck(downP, daNote);
							case 0:
								if (upP || rightP || downP || leftP)
									noteCheck(leftP, daNote);
						}
					 */
					if (daNote.wasGoodHit)
					{
						daNote.destroy();
					}
				}
				else
				{
					badNoteCheck();
				}
			}
	
			if ((controls.UP || controls.RIGHT || controls.DOWN || controls.LEFT) && !boyfriend.stunned && generatedMusic)
			{
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && daNote.isSustainNote)
					{
						switch (daNote.noteData)
						{
							// NOTES YOU ARE HOLDING
							case 2:
								if (controls.UP)
									goodNoteHit(daNote);
							case 3:
								if (controls.RIGHT)
									goodNoteHit(daNote);
							case 1:
								if (controls.DOWN)
									goodNoteHit(daNote);
							case 0:
								if (controls.LEFT)
									goodNoteHit(daNote);
						}
					}
				});
			}
	
			if (/*boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 &&*/ !controls.UP && !controls.DOWN && !controls.RIGHT && !controls.LEFT)
			{
				if (boyfriend.animation.curAnim.name.startsWith('sing'))
					boyfriend.playAnim('idle', true, false, boyfriend.animation.getByName('idle').numFrames - 1);
			}
	
			playerStrums.forEach(function(spr:FlxSprite)
			{
				switch (spr.ID)
				{
					case 2:
						if (controls.UP && spr.animation.curAnim.name != 'confirm')
							spr.animation.play('pressed');
						if (!controls.UP)
							spr.animation.play('static');
					case 3:
						if (controls.RIGHT && spr.animation.curAnim.name != 'confirm')
							spr.animation.play('pressed');
						if (!controls.RIGHT)
							spr.animation.play('static');
					case 1:
						if (controls.DOWN && spr.animation.curAnim.name != 'confirm')
							spr.animation.play('pressed');
						if (!controls.DOWN)
							spr.animation.play('static');
					case 0:
						if (controls.LEFT && spr.animation.curAnim.name != 'confirm')
							spr.animation.play('pressed');
						if (!controls.LEFT)
							spr.animation.play('static');
				}
				spr.centerOffsets();
			});
		}

	function noteMiss(direction:Int = 1,?healthMiss:Float = 0.08):Void
	{
		if (!boyfriend.stunned)
		{
			health -= healthMiss;
			vocals.volume = 0;

			if (combo > 5)
			{
				gf.playAnim('sad');
			}
			combo = 0;

			FlxG.sound.play(FunkinUtilities.getFile('missnote' + FlxG.random.int(1, 3),FunkinAssetType.SOUNDS), FlxG.random.float(0.05, 0.2));

			boyfriend.stunned = true;

			// get stunned for 5 seconds
			new FlxTimer().start(5 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});

			boyfriend.playAnim(Character.singMap[direction] + 'miss', true);
		}
	}

	function badNoteCheck()
	{
		// just double pasting this shit cuz fuk u
		// REDO THIS SYSTEM!
		var keyShitArray = [controls.LEFT_P,controls.DOWN_P,controls.UP_P,controls.RIGHT_P];

		var gamepad = FlxG.gamepads.lastActive;
		if (gamepad != null)
		{
			keyShitArray[0] = gamepad.anyJustPressed(["DPAD_LEFT", "LEFT_STICK_DIGITAL_LEFT", X]);
			keyShitArray[1] = gamepad.anyJustPressed(["DPAD_RIGHT", "LEFT_STICK_DIGITAL_RIGHT", B]);
			keyShitArray[2] = gamepad.anyJustPressed(['DPAD_UP', "LEFT_STICK_DIGITAL_UP", Y]);
			keyShitArray[3] = gamepad.anyJustPressed(["DPAD_DOWN", "LEFT_STICK_DIGITAL_DOWN", A]);
		}

		for(i in 0... keyShitArray.length){
			if(keyShitArray[i])
				noteMiss(i);
		}
	}

	function noteCheck(keyP:Bool, note:Note):Void
	{
		trace(note.noteData + ' note check here ' + keyP);
		if (keyP)
			goodNoteHit(note);
		else
			badNoteCheck();
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			popUpScore(note.strumTime);
			combo += 1;

			if (note.noteData >= 0)
				health += 0.03;
			else
				health += 0.007;
			
			boyfriend.playAnim(Character.singMap[note.noteData]);

			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					spr.animation.play('confirm', true);
				}
			});

			sectionScores[1][curSection] += note.noteScore;
			note.wasGoodHit = true;
			vocals.volume = 1;

			note.kill();
			notes.remove(note, true);
			note.destroy();
		}
	}

	override function stepHit()
	{
		if (vocals.time > Conductor.songPosition + Conductor.stepCrochet || vocals.time < Conductor.songPosition - Conductor.stepCrochet)
		{
			vocals.pause();
			vocals.time = Conductor.songPosition;
			vocals.play();
		}
		super.stepHit();
	}

	override function beatHit()
	{
		super.beatHit();

		if(curSong == 'Bopeebo')
			switch(curBeat){
				case 7 | 15 | 23 | 31 | 39 | 48 | 49 | 55 | 63 | 71 | 79 | 87 | 95 | 103 | 111 | 119:
					boyfriend.playAnim('hey',true);
				}

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, FlxSort.DESCENDING);
		}

		if (camZooming && FlxG.camera.zoom < 1.35 && totalBeats % 4 == 0)
			FlxG.camera.zoom += 0.025;

		dad.dance();
			boyfriend.dance();

		healthHeads.setGraphicSize(Std.int(healthHeads.width + 20));

		if (totalBeats % gfSpeed == 0)
			gf.dance();
	}
}
