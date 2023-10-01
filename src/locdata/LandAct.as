package locdata 
{
	
	// Class describing the terrain and player activity related to it
	// Contained within the game object

	import servdata.Script;
	
	public class LandAct 
	{

		public var id:String;
		public var tip:String='';
		public var land:Land;
		public var loaded:Boolean=false;
		
		public var xmlland:XML;
		public var allroom:XML;
		public var begLocX:int=0;	// Initial location
		public var begLocY:int=0;
		public var mLocX:int=1;		// Terrain size
		public var mLocY:int=1;
		
		public var dif:Number=0;	// Difficulty level
		public var biom:int=0;		// Types of enemies and other things encountered
		public var conf:int=0;		// Room configuration
		public var gameStage:int=0;	// Game story stage, affects loot drops
		public var lootLimit:Number=0;				// Limit of special item drops
		public var list:int=0;		// Number in the list
		public var rnd:Boolean=false;
		public var autoLevel:Boolean=false;
		public var test:Boolean=false;
		public var fin:int=-1;
		public var prob:int=0;
		public var exitProb:String;
		public var loadScr:int=-1;
		
		public var 	kolAllProb:int=0;
		public var 	kolClosedProb:int=0;
		
		// Settings
		public var xp:int=100;		// Experience for collecting items
		public var rad:Number=0, wrad:Number=1;	// Air and water radioactivity
		public var wdam:Number=0, wtipdam:int=7;	// Water damage
		public var tipWater:int=0;				// Water appearance
		public var color:String;
		public var sndMusic:String;
		public var postMusic:Boolean=false;		 // Music doesn't switch to combat
		public var fon:String;				// Static background
		public var backwall:String;			// Back wall background
		public var border:String='A';			// Border material
		public var visMult:Number=1;		// Visibility
		public var opacWater:Number=0;		// Water opacity
		public var darkness:int=0;			// Darkening
		
		public var artFire:String;			// Artillery barrage trigger
		
		// Variables subject to saving
		public var lastCpCode:String;
		public var upStage:Boolean=false;		// Increase level
		public var landStage:int=0;				// Maximum terrain level reached
		public var access:Boolean=false;
		public var visited:Boolean=false;
		public var passed:Boolean=false;

		
		public function LandAct(land:XML) {
			xmlland=land;
			id=land.@id;
			//nazv=Res.mapText(id);
			//info=Res.mapInfo(id);
			if (land.@tip.length()) tip=land.@tip;
			if (land.@dif.length()) dif=land.@dif;
			if (land.@biom.length()) biom=land.@biom;
			if (land.@conf.length()) conf=land.@conf;
			if (land.@stage.length()) gameStage=land.@stage;
			if (land.@limit.length()) lootLimit=land.@limit;
			if (land.@rnd.length()) rnd=true;
			if (land.@test.length()) test=true;
			if (land.@fin.length()) fin=land.@fin;
			if (land.@autolevel.length()) autoLevel=true;
			if (land.@prob.length()) prob=land.@prob;
			if (land.@list.length()) list=land.@list;
			if (land.@locx.length()) begLocX=land.@locx;
			if (land.@locy.length()) begLocY=land.@locy;
			if (land.@mx.length()) mLocX=land.@mx;
			if (land.@my.length()) mLocY=land.@my;
			if (land.@acc.length()) access=true;
			if (land.@exit.length()) exitProb=land.@exit;
			if (land.@loadscr.length()) loadScr=land.@loadscr;
			if (land.options.length()) 
			{
				if (land.options.@xp.length()) xp=land.options.@xp;
				if (land.options.@color.length()) color=land.options.@color;
				if (land.options.@backwall.length()) backwall=land.options.@backwall;
				if (land.options.@border.length()) border=land.options.@border;
				if (land.options.@fon.length()) fon=land.options.@fon;
				if (land.options.@music.length()) sndMusic=land.options.@music;
				if (land.options.@postmusic.length()) postMusic=true;
				if (land.options.@rad.length()) rad=land.options.@rad;
				if (land.options.@wrad.length()) wrad=land.options.@wrad;
				if (land.options.@wtip.length()) tipWater=land.options.@wtip;
				if (land.options.@wopac.length()) opacWater=land.options.@wopac;
				if (land.options.@wdam.length()) wdam=land.options.@wdam;
				if (land.options.@wtipdam.length()) wtipdam=land.options.@wtipdam;
				if (land.options.@vis.length()) visMult=land.options.@vis;
				if (land.options.@darkness.length()) darkness=land.options.@darkness;
				if (land.options.@art.length()) artFire=land.options.@art;
			}
		}

		//посчитать, сколько испытаний завершено
		public function calcProbs() 
		{
			kolAllProb=0;
			kolClosedProb=0;
			for each(var xml in xmlland.prob) 
			{
				kolAllProb++;
				if (World.w.game.triggers['prob_'+xml.@id]!=null) kolClosedProb++
			}
		}
		
		public function save():Object 
		{
			var obj:Object=new Object();
			obj.cp=lastCpCode;
			obj.st=landStage;
			obj.access=access;
			obj.visited=visited;
			obj.passed=passed;
			return obj;
		}
		public function load(obj:Object) 
		{
			if (obj.cp!=null) lastCpCode=obj.cp;
			if (obj.st!=null) landStage=obj.st;
			if (obj.access!=null && !access) access=obj.access;
			if (obj.visited!=null) visited=obj.visited;
			if (obj.passed!=null) passed=obj.passed;
			return obj;
		}
	}
}