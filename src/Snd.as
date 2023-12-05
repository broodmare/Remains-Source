package
{
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.net.URLRequest;
	import flash.utils.*;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.EventDispatcher;
	import components.Settings;
	import systems.XMLLoader;

	import components.XmlBook;

	public class Snd extends EventDispatcher 
	{

		public static var soundDataArray:Array 	= []; //An array that holds arrays of loaded '.swf' sound packs. Each array is named after the <res> tag of each '.swf' and contains all sound IDs and data.
		public static var globalVol:Number 			= 0.4;
		public static var stepVol:Number			= 0.5;
		public static var musicVol:Number 			= 0.2;


		public static var music:Sound;
		public static var musics:Array			= [];
		public static var sndNames:Array 		= ['mp5'];
		public static var musicName:String		= '';


		public static var soundEnabled:Boolean	= true;
		public static var musicEnabled:Boolean	= true;
		
		public static var musicCh:SoundChannel;
		public static var musicPrevCh:SoundChannel;
		public static var actionCh:SoundChannel;
		public static var currentMusicPrior:int = 0;
		
		public static var t_hit:int 		= 0;
		public static var t_combat:int 		= 0;
		public static var centrX:Number		= 1000;
		public static var centrY:Number		= 500;
		public static var widthX:Number		= 2000;
		public static var t_music:int 		= 0;
		public static var t_shum:int 		= 0;
		public static var soundInitialized:Boolean = false;
		public static var off:Boolean 		= true;
		
		public static var soundStage:Array 	= [];

		//Holds all the XML data for sounds and music.
		public static const soundLocation:String 	= Settings.soundXMLLocation; 		//Location of sounds XML in game directory.
		public static const musicLocation:String	= Settings.musicXMLLocation;   	//Location of music XML in game directory.

		public static var soundList:XML;	//XML list of all sounds. formatted as: <sound> <s> </s> </sound>
		public static var musicList:XML;	//XML list of all music tracks.

		public static var soundTextLoader:XMLLoader = new XMLLoader();
		public static var musicTextLoader:XMLLoader = new XMLLoader();


		function Snd() 
		{
			
		}
		


		public static function initializeSound():void
		{
			trace('Snd.as/initializeSound() - Starting sound.');
			if (soundInitialized || !soundEnabled)  
			{
				trace('Snd.as/initializeSound() - error: Sound already intitialized.');
				return;
			}
			//TODO: START MAIN MENU MUSIC HERE

			trace('Snd.as/initializeSound() - Testing: "' + XmlBook.getXML("sounds").sound + '".');
			soundList = XmlBook.getXML("sounds").sound;
			Settings.soundFilesFound = soundList.s.length();

			trace('Snd.as/initializeSound() - Loading all sounds, soundList: "' + soundList + '".');
			var loadingCount:int = 0;
			for each (var soundFile:XML in soundList.s) 
			{
				var soundName:String = soundFile.@id;
				var soundURL:URLRequest = new URLRequest(Settings.soundPath + soundName + ".mp3");

				var soundData:Sound = new Sound(soundURL);

				soundData.addEventListener(IOErrorEvent.IO_ERROR, soundEventHandler);
				soundData.addEventListener(Event.COMPLETE, soundEventHandler);

				soundDataArray[soundName] = soundData; //Place the sound data into the soundDataArray as the sound file's name.
				loadingCount++;

			}
			trace('Snd.as/initializeSound() - Sound files found: "'+ Settings.soundFilesFound + '." Sound files loading: "' + loadingCount + '."');
			trace('Snd.as/initializeSound() - Sound initialized.');
			soundInitialized = true;	//Set sound to as initialized.
		}


		public static function soundEventHandler(event:Event):void
		{
			event.target.removeEventListener(IOErrorEvent.IO_ERROR, soundEventHandler);
			event.target.removeEventListener(Event.COMPLETE, soundEventHandler);

			switch (event.type) 
			{

				case Event.COMPLETE:
				//trace("Snd.as/soundParser() - Sound loaded: " + event.target.url);
				Settings.soundFilesLoaded++;
				break;

				case IOErrorEvent.IO_ERROR:
				trace("Snd.as/soundParser() - Sound failed to load: " + event.target.url);
				break;
			}
		}


		
		public static function loadMusic():void
		{
			
			trace('Snd.as/loadMusic() - Calling XMLLoader.as/load with ' + musicLocation);
			musicTextLoader.addEventListener(XMLLoader.XML_LOADED, loadMusicCont);
			musicTextLoader.load(musicLocation, "loadMusic()"); 

		}

		public static function loadMusicCont(event:Event):void //TODO, Remove into own soundloader class.
		{
			trace('Snd.as/loadMusicCont() - Music XML received.');

			event.target.removeEventListener(XMLLoader.XML_LOADED, loadMusicCont);
			if (musicTextLoader.xmlData != null)
			{
				try
				{
					musicList = musicTextLoader.xmlData;
				}
				catch(err:Error)
				{
					trace('Snd.as/loadMusicCont() - Failed setting musicList as: ' + musicTextLoader.xmlData);
				}
			}
			else 
			{
				trace('Snd.as/loadMusicCont() - musicTextLoader.xmlData was NULL.');
			}
			Settings.musicTracksFound = musicList.s.length();
			trace('Snd.as/loadMusicCont() - music tracks found: "' + Settings.musicTracksFound + '".'); 

			var loadingCount:int = 0;
			for each (var track:XML in musicList.s) 
			{
				var trackName:String = track.@id;


				var soundURL:URLRequest = new URLRequest(Settings.musicPath + trackName + ".mp3");
				var soundData:Sound = new Sound(soundURL);

				soundData.addEventListener(IOErrorEvent.IO_ERROR, musicEventHandler);
				soundData.addEventListener(Event.COMPLETE, musicEventHandler);

				soundDataArray[trackName] = soundData;
				loadingCount++;

			}
			trace('Snd.as/loadMusic() - Music tracks found: "'+ Settings.musicTracksFound + '." Music files loading: "' + loadingCount + '."');
 
 			trace('Snd.as/loadMusic() - Starting music if volume > 0.');
			if (musicVol > 0) playMusic('mainmenu'); //If music volume isn't set at 0, play.
		}

		public static function musicEventHandler(event:Event):void
		{
			event.target.removeEventListener(IOErrorEvent.IO_ERROR, musicEventHandler);
			event.target.removeEventListener(Event.COMPLETE, musicEventHandler);

			switch (event.type) 
			{

				case Event.COMPLETE:
				Settings.musicTracksLoaded++;
				break;

				case IOErrorEvent.IO_ERROR:
				trace("Snd.as/soundParser() - Sound failed to load: " + event.target.url);
				break;
			}
		}






		public static function save():*
		{
			var obj:Object 	= {};
			obj.globalVol 	= globalVol;
			obj.stepVol 	= stepVol;
			obj.musicVol 	= musicVol;
			return obj;
		}

		public static function load(obj:Object):void
		{
			trace('Snd.as/load() - applying settings from configObj...');
			if (obj.globalVol 	!= null && !isNaN(obj.globalVol)) 	globalVol = obj.globalVol;
			if (obj.stepVol 	!= null && !isNaN(obj.stepVol)) 	stepVol   = obj.stepVol;
			if (obj.musicVol 	!= null && !isNaN(obj.musicVol)) 	musicVol  = obj.musicVol;
			if (musicCh) 
			{
				trace('Snd.as/load() - calling Snd/updateMusicVol...');
				updateMusicVol();
			}
		}
		
		public static function pan(x:Number):Number 
		{
			return (x - 250) / 500;
		}




		public static function combatMusic(sndMusic:String, sndMusicPrior:int=0, n:int=150):void
		{
			t_combat = n;
			if (sndMusicPrior > currentMusicPrior) 
			{
				currentMusicPrior = sndMusicPrior;
				playMusic(sndMusic);
			}
		}
		
		
		public static function playMusic(sndMusic:String=null, rep:int = 10000):void
		{
			trace('Snd.as/playMusic() - Playing song: ' + sndMusic + '.');
			//trace('musvol',musicVol);
			if (!soundInitialized) return;
			if (sndMusic != null && musicCh && sndMusic == musicName) return;
			if (sndMusic != null) musicName = sndMusic;
			var trans:SoundTransform = new SoundTransform(musicVol, 0);
			if (musicCh) 
			{
				if (musicPrevCh || t_music > 0) musicPrevCh.stop();
				musicPrevCh = musicCh;
				musicCh = null;
				t_music = 100;
			}
			currentMusicPrior = 0;
			if (musicEnabled && soundDataArray[musicName] && soundDataArray[musicName].bytesTotal && soundDataArray[musicName].bytesLoaded == soundDataArray[musicName].bytesTotal) musicCh=soundDataArray[musicName].play(0,rep,trans);
		}

		public static function stopMusic():void
		{
			if (!soundInitialized || !musicCh) return;
			musicCh.stop();
		}

		public static function updateMusicVol():void
		{
			trace('Snd.as/updateMusicVol() - Updating music volume.');
			if (musicCh) 
			{
				var trans:SoundTransform = new SoundTransform(musicVol, 0);
				musicCh.soundTransform = trans;
			} 
			else 
			{
				playMusic();
			}
		}
		
		//PLAY SOUND
		public static function ps(txt:String, nx:Number = -1000, ny:Number = -1000, msec:Number = 0,vol:Number = 1):SoundChannel 
		{
			//trace(txt);
			if (!soundInitialized || !soundEnabled || off) return null;
			if (soundDataArray[txt]) 
			{
				var s:Sound;
				if (soundDataArray[txt] is Array) s = soundDataArray[txt][Math.floor(Math.random() * soundDataArray[txt].length)];
				else s = soundDataArray[txt] as Sound;
				if (s.bytesTotal>0 && s.bytesLoaded>=s.bytesTotal) 
				{
					var pan:Number=(nx-centrX)/widthX;
					if (nx == -1000) pan = 0;
					var trans:SoundTransform = new SoundTransform(vol * globalVol * (Math.random() * 0.1 + 0.9), pan); 
					return s.play(msec, 0, trans);
				}
			}
			return null;
		}
		
		public static function pshum(txt:String,vol:Number = 1):void
		{
			if (!soundInitialized || !soundEnabled || off) return;
			var shum:Object;
			if (soundStage[txt]) 
			{
				shum = soundStage[txt];
				if (shum.maxVol < vol) shum.maxVol = vol;
			}
			else if (soundDataArray[txt]) 
			{
				shum = {};
				shum.txt = txt;
				shum.curVol = vol;
				shum.maxVol = vol;
				shum.pl = false;
				soundStage[txt] = shum;
			}
		}
		
		public static function resetShum():void
		{

		}
		
		public static function step():void
		{
			var trans:SoundTransform;
			if (t_hit > 0) t_hit--;
			if (t_music > 0 && musicPrevCh) 
			{
				if (t_music % 10 == 1) 
				{
					trans = new SoundTransform(musicVol * t_music / 100, 0);
					musicPrevCh.soundTransform = trans;
				}
				if (t_music <= 5) 
				{
					musicPrevCh.stop();
					musicPrevCh = null;
					t_music = 0;
				}
				if (t_combat > 0) t_music -= 5;
				else t_music--;
			}
			if (t_combat > 0) 
			{
				if (t_combat == 1) 
				{
					currentMusicPrior = 0;
					playMusic(GameSession.currentSession.currentMusic);
				}
				if (GameSession.currentSession.pip == null || !GameSession.currentSession.pip.active && !GameSession.currentSession.sats.active) t_combat--;
			}
			t_shum--;
			if (t_shum <= 0) 
			{
				t_shum = 5;
				for each (var obj in soundStage) 
				{
					if (obj.curVol != obj.maxVol) 
					{
						if (!obj.pl && obj.maxVol > 0) 
						{
							var s:Sound = soundDataArray[obj.txt] as Sound;
							trans = new SoundTransform(obj.maxVol * globalVol, 0); 
							obj.ch = s.play(0, 10000, trans);
							obj.pl = true;
							//trace(obj.txt,'play')
						} 
						else if (obj.pl && obj.maxVol <= 0 && obj.ch) 
						{
							obj.ch.stop();
							obj.pl = false;
							//trace(obj.txt,'stop')
						} 
						else if (obj.pl && obj.maxVol > 0 && obj.ch) 
						{
							trans = new SoundTransform(obj.maxVol * globalVol, 0);
							obj.ch.soundTransform = trans;
							obj.curVol=obj.maxVol;
						}
					}
					obj.maxVol -= 0.2;
					if (obj.maxVol < 0) obj.maxVol = 0;
				}
			}
		}
	}
}
