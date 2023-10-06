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
	
	import components.Settings;
	import systems.XMLLoader;

	public class Snd 
	{

		public static var soundDataArray:Array 	= new Array();
		public static var globalVol 		= 0.4;
		public static var stepVol 			= 0.5;
		public static var musicVol 			= 0.2;


		public static var music:Sound;
		public static var musics:Array		= new Array();
		public static var sndNames:Array 	= ['mp5'];
		public static var musicName:String	= '';


		public static var onSnd:Boolean		= true;
		public static var onMusic:Boolean	= true;
			
		public static var resSnd:Loader;
		public static var resSounds:*;
		
		public static var musicCh:SoundChannel;
		public static var musicPrevCh:SoundChannel;
		public static var actionCh:SoundChannel;
		public static var currentMusicPrior:int = 0;
		
		public static var t_hit:int = 0;
		public static var t_combat:int = 0;
		public static var centrX:Number = 1000, centrY:Number = 500, widthX = 2000;
		public static var t_music:int = 0;
		public static var t_shum:int = 0;
		static var inited:Boolean = false;
		public static var off:Boolean = true;
		
		public static var shumArr:Array;

		//Holds all the XML data for sounds and music.
		public static var musicList:XML;
		public static var soundList:XML;
		public static var soundLocation; 
		public static var textLoader:XMLLoader;
		public static var soundURL:URLRequest;

		function Snd() 
		{
			
		}
		


		public static function initSnd() 
		{
			trace('Snd.as/initSnd() - Sound initializing ...');
			if (inited || !onSnd)  return;

			soundLocation = Settings.soundXMLLocation;
			soundList = new XML();

			mainMenuMusicSetup();
			
			soundURL = new URLRequest(soundLocation);
			textLoader = new XMLLoader();
			trace('Snd.as/initSnd() - Calling Textloader.as/load with ' + soundLocation);
			textLoader.load(soundURL.url, soundParser);

			shumArr = new Array();
			inited = true;
			

			trace('Snd.as/initSnd() - Sound initializated.')
		}








		public static function mainMenuMusicSetup()
		{
			try 
			{
				 trace("Snd.as/mainMenuMusicSetup() - Beginning main menu music setup...");
				var musicURL:URLRequest;
				var soundData:Sound;

				//LOAD MAIN MENU MUSIC
				var songURL = new URLRequest(Settings.musicPath + "mainmenu.mp3");
				trace("Snd.as/mainMenuMusicSetup() - looking for music at... " + songURL.url);
				var soundData = new Sound(songURL);
		
				
				soundDataArray['mainmenu'] = soundData; //Add the main menu music to the soundDataArray.
				if (musicVol > 0) playMusic('mainmenu'); //Play the music if music volume isn't 0.

				trace('Snd.as/mainMenuMusicSetup() - Main menu music loaded sucessfully.');

			}
			catch (err)
			{
				trace('Snd.as/mainMenuMusicSetup() - Main menu music failed to load.');
			}
		}

		public static function soundParser(xmlFile:XML)
		{
			trace('Snd.as/soundParser() - Beginning sound parsing with file (' + xmlFile + ')');
			var soundXML:XML = xmlFile;
			if (soundXML == null) trace('Snd.as/soundParser() - soundXML does not exist.');
			
			else
			try 
			{
				var fileCounter:int = 0;
				for each (var i in soundXML.res) //For each resource .swf load it...
				{
					fileCounter++;
					resSnd = new Loader();
					var fileSound:String = Settings.soundPath + i.@id;
					trace('Snd.as/soundParser() - Attempting to load resource id: ' + fileSound);
					var urlReq:URLRequest = new URLRequest(fileSound);
					resSnd.load(urlReq);
					resSnd.contentLoaderInfo.addEventListener(Event.COMPLETE, eventHandler); // When loaded, do this
					resSnd.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, eventHandler); // Error checker

					trace('Snd.as/soundParser() - Parsed ' + fileCounter + 'files.');

				}

			}
			catch (err)
			{
				trace('Snd.as/initSnd() - Loading sound resources failed.\n Reason:' + err.message);
			}

		}


		
		



		

		public static function eventHandler(event:Event):void 
		{
			switch (event.type) 
			{
				case Event.COMPLETE:

					var soundURL:String = event.target.url;

					soundURL = soundURL.substr(soundURL.lastIndexOf('/') + 1);

					resSounds = event.target.content;
					
					var soundData:Sound;

					trace('Snd.as/eventHandler. Loading Complete, attempting to do whatever the next thing is...' + resSounds);
					var xml = soundList.res.(@id == soundURL);
					if (xml.length)
					trace('XML output\n' + xml);
					{
						for each (var j in xml.soundData) 
						{
							var id = j.@id;
							if (j.soundData.length) 
							{
								soundDataArray[id] = new Array();
								for each (var e in j.s) 
								{
									soundData = resSounds.getSnd(e.@id);
									if (soundData != null) soundDataArray[id].push(soundData);
									else trace('res sound err '+ id + '.' + e.@id);
								}
							} 
							else 
							{
								soundData = resSounds.getSnd(id);
								if (soundData != null) soundDataArray[id] = soundData;
								else trace('res sound err '+id);
							}
						}
					}

					break;
				
				case IOErrorEvent.IO_ERROR:


					trace('Snd.as/eventHandler() - IO Error, Failed to load. Error: ' + IOErrorEvent(event).text);
					break;

				default:

					trace("Snd.as/eventHandler() - Unhandled event type: " + event.type + '. ');
					break;
			}
		}

		public static function loadMusic() 
		{
			var soundURL:URLRequest;
			var soundData:Sound;


			for each (var j in musicList.music.soundData) 
			{
				var id:String = j.@id;
				try 
				{
					soundURL = new URLRequest(Settings.musicPath+id+".mp3");
					soundData = new Sound(soundURL); 
					soundDataArray[id] = soundData;
					Settings.musicKol++;
				} 
				catch (err) 
				{
					trace('Snd.as/loadMusic() - Music resources loaded. Songs loaded: ', musics.length);
				}
			}
		}

		public static function save():*
		{
			var obj:Object 	= new Object();
			obj.globalVol 	= globalVol;
			obj.stepVol 	= stepVol;
			obj.musicVol 	= musicVol;
			return obj;
		}
		public static function load(obj) 
		{
			if (obj.globalVol 	!= null && !isNaN(obj.globalVol)) 	globalVol = obj.globalVol;
			if (obj.stepVol 	!= null && !isNaN(obj.stepVol)) 	stepVol   = obj.stepVol;
			if (obj.musicVol 	!= null && !isNaN(obj.musicVol)) 	musicVol  = obj.musicVol;
			if (musicCh) updateMusicVol();
		}
		
		public static function pan(x:Number):Number 
		{
			return (x - 250) / 500;
		}




		public static function combatMusic(sndMusic:String, sndMusicPrior:int=0, n:int=150) 
		{
			t_combat = n;
			if (sndMusicPrior > currentMusicPrior) 
			{
				currentMusicPrior = sndMusicPrior;
				playMusic(sndMusic);
			}
		}
		
		
		public static function playMusic(sndMusic:String=null, rep:int = 10000) 
		{
			//trace('musvol',musicVol);
			if (!inited) return;
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
			if (onMusic && soundDataArray[musicName] && soundDataArray[musicName].bytesTotal && soundDataArray[musicName].bytesLoaded == soundDataArray[musicName].bytesTotal) musicCh=soundDataArray[musicName].play(0,rep,trans);
		}

		public static function stopMusic() 
		{
			if (!inited || !musicCh) return;
			musicCh.stop();
		}

		public static function updateMusicVol()
		{
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
			if (!inited || !onSnd || off) return null;
			if (soundDataArray[txt]) {
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
		
		public static function pshum(txt:String,vol:Number = 1) 
		{
			if (!inited || !onSnd || off) return null;
			var shum:Object;
			if (shumArr[txt]) 
			{
				shum = shumArr[txt];
				if (shum.maxVol < vol) shum.maxVol = vol;
			}
			else if (soundDataArray[txt]) 
			{
				shum = new Object();
				shum.txt = txt;
				shum.curVol = vol;
				shum.maxVol = vol;
				shum.pl = false;
				shumArr[txt] = shum;
			}
		}
		
		public static function resetShum() 
		{

		}
		
		public static function step() 
		{
			if (t_hit > 0) t_hit--;
			if (t_music > 0 && musicPrevCh) 
			{
				if (t_music%10 == 1) 
				{
					var trans:SoundTransform = new SoundTransform(musicVol * t_music / 100, 0);
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
					playMusic(World.world.currentMusic);
				}
				if (World.world.pip == null || !World.world.pip.active && !World.world.sats.active) t_combat--;
			}
				t_shum--;
				if (t_shum <= 0) 
				{
					t_shum = 5;
					for each (var obj in shumArr) 
					{
						if (obj.curVol != obj.maxVol) 
						{
							if (!obj.pl && obj.maxVol > 0) 
							{
								var s:Sound = soundDataArray[obj.txt] as Sound;
								var trans:SoundTransform = new SoundTransform(obj.maxVol * globalVol, 0); 
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
								var trans:SoundTransform = new SoundTransform(obj.maxVol * globalVol, 0);
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
