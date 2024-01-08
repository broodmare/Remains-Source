package locdata 
{
	// Class describing the terrain and player activity related to it
	// Contained within the game object
	
	public class LevelTemplate 
	{

		public var id:String;
		public var tip:String = '';
		public var level:Level;
		public var loaded:Boolean = false;
		
		public var levelParameters:XML;	//
		public var levelXMLData:XML; 	//
		
		public var begLocX:int = 0;			// Initial location
		public var begLocY:int = 0;
		public var mLocX:int = 1;			// Terrain size
		public var mLocY:int = 1;
		
		public var dif:Number = 0;			// Difficulty level
		public var biom:int = 0;			// Types of enemies and other things encountered
		public var conf:int = 0;			// Room configuration
		public var gameStage:int = 0;		// Game story stage, affects loot drops
		public var lootLimit:Number = 0;	// Limit of special item drops
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
		
		public function LevelTemplate(levelParam:XML) 
		{
			levelParameters = levelParam;
			id = levelParameters.@id;

			if (levelParameters.@tip.length()) 		tip 	= levelParameters.@tip;
			if (levelParameters.@dif.length()) 		dif 	= levelParameters.@dif;
			if (levelParameters.@biom.length()) 		biom 	= levelParameters.@biom;
			if (levelParameters.@conf.length()) 		conf 	= levelParameters.@conf;
			if (levelParameters.@stage.length()) 		gameStage = levelParameters.@stage;
			if (levelParameters.@limit.length()) 		lootLimit = levelParameters.@limit;
			if (levelParameters.@rnd.length()) 		rnd 	= true;
			if (levelParameters.@fin.length()) 		fin 	= levelParameters.@fin;
			if (levelParameters.@autolevel.length()) 	autoLevel = true;
			if (levelParameters.@prob.length()) 		prob 	= levelParameters.@prob;
			if (levelParameters.@list.length()) 		list 	= levelParameters.@list;
			if (levelParameters.@locx.length()) 		begLocX = levelParameters.@locx;
			if (levelParameters.@locy.length()) 		begLocY = levelParameters.@locy;
			if (levelParameters.@mx.length()) 			mLocX 	= levelParameters.@mx;
			if (levelParameters.@my.length()) 			mLocY 	= levelParameters.@my;
			if (levelParameters.@acc.length()) 		access 	= true;
			if (levelParameters.@exit.length()) 		exitProb = levelParameters.@exit;
			if (levelParameters.@loadscr.length()) 	loadScr = levelParameters.@loadscr;
			if (levelParameters.options.length()) 
			{
				if (levelParameters.options.@xp.length()) xp=levelParameters.options.@xp;
				if (levelParameters.options.@color.length()) color=levelParameters.options.@color;
				if (levelParameters.options.@backwall.length()) backwall=levelParameters.options.@backwall;
				if (levelParameters.options.@border.length()) border=levelParameters.options.@border;
				if (levelParameters.options.@skybox.length()) skybox=levelParameters.options.@skybox;
				if (levelParameters.options.@music.length()) sndMusic=levelParameters.options.@music;
				if (levelParameters.options.@postmusic.length()) postMusic=true;
				if (levelParameters.options.@rad.length()) rad=levelParameters.options.@rad;
				if (levelParameters.options.@wrad.length()) wrad=levelParameters.options.@wrad;
				if (levelParameters.options.@wtip.length()) tipWater=levelParameters.options.@wtip;
				if (levelParameters.options.@wopac.length()) opacWater=levelParameters.options.@wopac;
				if (levelParameters.options.@wdam.length()) wdam=levelParameters.options.@wdam;
				if (levelParameters.options.@wtipdam.length()) wtipdam=levelParameters.options.@wtipdam;
				if (levelParameters.options.@vis.length()) visMult=levelParameters.options.@vis;
				if (levelParameters.options.@darkness.length()) darkness=levelParameters.options.@darkness;
				if (levelParameters.options.@art.length()) artFire=levelParameters.options.@art;
			}
		}

		//посчитать, сколько испытаний завершено
		public function calcProbs():void
		{
			kolAllProb = 0;
			kolClosedProb = 0;
			for each(var xml in levelParameters.prob) 
			{
				kolAllProb++;
				if (GameSession.currentSession.game.triggers['prob_'+xml.@id] != null) kolClosedProb++
			}
		}
		
		public function save():Object 
		{
			var obj:Object = {};
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