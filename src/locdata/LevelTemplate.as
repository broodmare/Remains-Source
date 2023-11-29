package locdata 
{
	
	// Class describing the terrain and player activity related to it
	// Contained within the game object

	import servdata.Script;
	
	public class LevelTemplate 
	{

		public var id:String;
		public var tip:String='';
		public var level:Level;
		public var loaded:Boolean=false;
		
		public var levelData:XML;
		public var allroom:XML;
		public var begLocX:int=0;			// Initial location
		public var begLocY:int=0;
		public var mLocX:int=1;				// Terrain size
		public var mLocY:int=1;
		
		public var dif:Number=0;			// Difficulty level
		public var biom:int=0;				// Types of enemies and other things encountered
		public var conf:int=0;				// Room configuration
		public var gameStage:int=0;			// Game story stage, affects loot drops
		public var lootLimit:Number=0;			// Limit of special item drops
		public var list:int=0;				// Number in the list
		public var rnd:Boolean=false;
		public var autoLevel:Boolean=false;
		public var fin:int=-1;
		public var prob:int=0;
		public var exitProb:String;
		public var loadScr:int=-1;
		
		public var 	kolAllProb:int=0;
		public var 	kolClosedProb:int=0;
		
		// Settings
		public var xp:int=100;					// Experience for collecting items
		public var rad:Number=0;
		public var wrad:Number=1;				// Air and water radioactivity
		public var wdam:Number=0;
		public var wtipdam:int=7;				// Water damage
		public var tipWater:int=0;				// Water appearance
		public var color:String;
		public var sndMusic:String;
		public var postMusic:Boolean=false;		 // Music doesn't switch to combat
		public var skybox:String;				// Static background
		public var backwall:String;				// Back wall background
		public var border:String='A';			// Border material
		public var visMult:Number=1;			// Visibility
		public var opacWater:Number=0;			// Water opacity
		public var darkness:int=0;				// Darkening
		
		public var artFire:String;				// Artillery barrage trigger
		
		// Variables subject to saving
		public var lastCpCode:String;
		public var upStage:Boolean=false;		// Increase level
		public var landStage:int=0;				// Maximum terrain level reached
		public var access:Boolean=false;
		public var visited:Boolean=false;
		public var passed:Boolean=false;

		
		public function LevelTemplate(l:XML) 
		{
			var levelXML:XML = l;

			levelData = levelXML;
			id = levelXML.@id;

			if (levelXML.@tip.length()) 		tip 	= levelXML.@tip;
			if (levelXML.@dif.length()) 		dif 	= levelXML.@dif;
			if (levelXML.@biom.length()) 		biom 	= levelXML.@biom;
			if (levelXML.@conf.length()) 		conf 	= levelXML.@conf;
			if (levelXML.@stage.length()) 		gameStage = levelXML.@stage;
			if (levelXML.@limit.length()) 		lootLimit = levelXML.@limit;
			if (levelXML.@rnd.length()) 		rnd 	= true;
			if (levelXML.@fin.length()) 		fin 	= levelXML.@fin;
			if (levelXML.@autolevel.length()) 	autoLevel = true;
			if (levelXML.@prob.length()) 		prob 	= levelXML.@prob;
			if (levelXML.@list.length()) 		list 	= levelXML.@list;
			if (levelXML.@locx.length()) 		begLocX = levelXML.@locx;
			if (levelXML.@locy.length()) 		begLocY = levelXML.@locy;
			if (levelXML.@mx.length()) 			mLocX 	= levelXML.@mx;
			if (levelXML.@my.length()) 			mLocY 	= levelXML.@my;
			if (levelXML.@acc.length()) 		access 	= true;
			if (levelXML.@exit.length()) 		exitProb = levelXML.@exit;
			if (levelXML.@loadscr.length()) 	loadScr = levelXML.@loadscr;
			if (levelXML.options.length()) 
			{
				if (levelXML.options.@xp.length()) xp=levelXML.options.@xp;
				if (levelXML.options.@color.length()) color=levelXML.options.@color;
				if (levelXML.options.@backwall.length()) backwall=levelXML.options.@backwall;
				if (levelXML.options.@border.length()) border=levelXML.options.@border;
				if (levelXML.options.@skybox.length()) skybox=levelXML.options.@skybox;
				if (levelXML.options.@music.length()) sndMusic=levelXML.options.@music;
				if (levelXML.options.@postmusic.length()) postMusic=true;
				if (levelXML.options.@rad.length()) rad=levelXML.options.@rad;
				if (levelXML.options.@wrad.length()) wrad=levelXML.options.@wrad;
				if (levelXML.options.@wtip.length()) tipWater=levelXML.options.@wtip;
				if (levelXML.options.@wopac.length()) opacWater=levelXML.options.@wopac;
				if (levelXML.options.@wdam.length()) wdam=levelXML.options.@wdam;
				if (levelXML.options.@wtipdam.length()) wtipdam=levelXML.options.@wtipdam;
				if (levelXML.options.@vis.length()) visMult=levelXML.options.@vis;
				if (levelXML.options.@darkness.length()) darkness=levelXML.options.@darkness;
				if (levelXML.options.@art.length()) artFire=levelXML.options.@art;
			}
		}

		//посчитать, сколько испытаний завершено
		public function calcProbs():void
		{
			kolAllProb = 0;
			kolClosedProb = 0;
			for each(var xml in levelData.prob) 
			{
				kolAllProb++;
				if (World.world.game.triggers['prob_'+xml.@id] != null) kolClosedProb++
			}
		}
		
		public function save():Object 
		{
			var obj:Object=new Object();
			obj.cp = lastCpCode;
			obj.st = landStage;
			obj.access = access;
			obj.visited = visited;
			obj.passed = passed;
			return obj;
		}
		public function load(obj:Object):Object
		{
			if (obj.cp != null) lastCpCode = obj.cp;
			if (obj.st != null) landStage = obj.st;
			if (obj.access != null && !access) access = obj.access;
			if (obj.visited != null) visited = obj.visited;
			if (obj.passed != null) passed = obj.passed;
			return obj;
		}
	}
}
