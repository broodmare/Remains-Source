package components
{


    public class Settings
    {


		//Global constants
        public static var actionDist:int = 40000;
		public static const tilePixelWidth:int 	= 40;	//Tile Width
		public static const tilePixelHeight:int = 40;	//Tile Height
		public static const roomTileWidth:int 	= 48;   //Room Width
		public static const roomTileHeight:int 	= 25;   //Room Height
		public static const fps:int             = 30;
		public static const ddy:int             = 1;
		public static const maxdy:int           = 20;
		public static const maxwaterdy:int      = 20;
		public static const maxdelta:int        = 9;
		public static const oduplenie:int       = 100;
		public static const battleNoOut:int     = 120;
		public static const unitXPMult:Number   = 2;
		public static const kolHK:int           = 12;	//number of hotkeys
		public static const kolQS:int           = 4;	//number of quick spells
			
		public static const boxDamage:Number = 0.2;		//box attack strength multiplier



		//Settings variables
		public static var enemyAct:int;				//enemy activity, should be 3. If 0, enemies will not be active
		public static var roomsLoad:int;			//1-load from file
		public static var langLoad:int;				//1-load from file
		public static var addCheckSP:Boolean;		//add skill points when visiting checkpoints
		public static var weaponsLevelsOff:Boolean;	//disable using weapons of incorrect level
		public static var drawAllMap:Boolean;		//display the whole map without fog of war
		public static var black:Boolean;			//display fog of war
		public static var testMode:Boolean;		    //Test mode
		public static var chitOn:Boolean;  
		public static var chit:String;              //current cheat
		public static var chitX:String;    
		public static var showArea:Boolean;	        //Should the current room be rendered?
		public static var godMode:Boolean;	        //invincibility 
		public static var showAddInfo:Boolean;	    //show additional information
		public static var testBattle:Boolean;	    //stamina will be consumed outside of battle
		public static var testEff:Boolean;		    //effects will be 10 times shorter
		public static var testDam:Boolean;		    //cancel damage range
		public static var hardInv:Boolean;		    //limited inventory
		public static var alicorn:Boolean; 
		public static var maxParts:int;		        //maximum particles
		public static var zoom100:Boolean;			//zoom 100%
		public static var dialOn:Boolean;			//show dialogues with NPCs
		public static var showHit:int;				//show damage
		public static var matFilter:Boolean;		//material filter
		public static var helpMess:Boolean;		    //tutorial messages
		public static var shineObjs:Boolean;		//objects glow
		public static var sysCur:Boolean;			//system cursor
		public static var hintKeys:Boolean;		    //keyboard hints
		public static var hintTele:Boolean;		    //teleport hints
		public static var showFavs:Boolean;		    //show additional info when cursor is on top of the screen
		public static var errorShow:Boolean;   
		public static var errorShowOpt:Boolean;    
		public static var quakeCam:Boolean;		    //camera shake
		public static var vsWeaponNew:Boolean;		//automatically take new weapon if there is room
		public static var vsWeaponRep:Boolean;		//automatically take weapon for repair
		public static var vsAmmoAll:Boolean;		
		public static var vsAmmoTek:Boolean;		
		public static var vsExplAll:Boolean;		
		public static var vsMedAll:Boolean;		
		public static var vsHimAll:Boolean;		
		public static var vsEqipAll:Boolean;		
		public static var vsStuffAll:Boolean;		
		public static var vsVal:Boolean;		
		public static var vsBook:Boolean;		
		public static var vsFood:Boolean;		
		public static var vsComp:Boolean;		
		public static var vsIngr:Boolean;
        public static var bitmapCachingOption:Boolean;

        //files
        public static var soundPath:String;
        public static var musicPath:String;
        public static var levelPath:String;


        public static var textureURL:String;
        public static var spriteURL:String;
        public static var sprite1URL:String;
        public static var languageListURL:String;
        
        public static var musicKol:int;
		public static var musicLoaded:int;

		public static var soundXMLLocation:String;






        public function Settings()
        {



        }





        public static function settingsSetup():void
        {

		//Settings variables
		trace('Settings.as/settingsSetup() - Settings initializing...');




        //Game settings
		maxParts            = 100;			//maximum particles
		shineObjs           = false;		//objects glow
		sysCur              = false;		//system cursor
		showHit             = 2;			//show damage
		hintKeys            = true;			//keyboard hints
		hintTele            = true;			//teleport hints
		showFavs            = true;			//show additional info when cursor is on top of the screen
		errorShow           = true;
		errorShowOpt        = true;
		roomsLoad           = 1;  		    //1-load from file
		langLoad            = 1;  			//1-load from file
        bitmapCachingOption = true;


        //General player settings
		hardInv             = false;		//limited inventory
		alicorn             = false;        //Alicorn armor mode
		zoom100             = false;		//zoom 100%
		dialOn              = true;			//show dialogues with NPCs
		matFilter           = true;		    //material filter
		helpMess            = true;			//tutorial 
		addCheckSP          = false;		//add skill points when visiting checkpoints
		weaponsLevelsOff    = true;	        //disable using weapons of incorrect level
		quakeCam            = true;	        //camera shake

        //Debug options
		testMode            = false;		//Test mode
		chitOn              = false;
		chit                = ''; 			//current cheat
		chitX               = '';	
		showArea            = false;		//Should the current room be rendered?
		godMode             = false;		//invincibility 
		showAddInfo         = false;		//show additional information
		testBattle          = false;		//stamina will be consumed outside of battle
		testEff             = false;		//effects will be 10 times shorter
		testDam             = false;		//cancel damage range
		drawAllMap          = false;		//display the whole map without fog of war
		black               = true;			//display fog of war
		enemyAct            = 3;			//enemy activity, should be 3. If 0, enemies will not be active

        //Autopickup options
		vsWeaponNew         = true;		    //automatically take new weapon if there is room
		vsWeaponRep         = true;		    //automatically take weapon for repair
		vsAmmoAll           = true;		
		vsAmmoTek           = true;		
		vsExplAll           = true;		
		vsMedAll            = true;		
		vsHimAll            = true;		
		vsEqipAll           = true;		
		vsStuffAll          = true;		
		vsVal               = true;		
		vsBook              = true;		
		vsFood              = true;		
		vsComp              = true;		
		vsIngr              = true;


        //files
        soundPath 	    = 'data/sound.swf';
        musicPath 	    = 'Music/';
        textureURL 	    = 'data/texture.swf';
        spriteURL 	    = 'data/sprite.swf';
        sprite1URL 	    = 'data/sprite1.swf';
        levelPath 	    = 'Rooms/';

		languageListURL = 'data/languageList.xml';
		soundXMLLocation = 'data/xmldata/Sounds.xml';

        musicKol        = 0;
		musicLoaded     = 0;

		trace('Settings.as/settingsSetup() - Settings initialized. languageListURL:' + languageListURL);

        }
	}
}