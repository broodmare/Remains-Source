package unitdata 
{
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.utils.*;
	import flash.media.SoundChannel;
	import flash.filters.GlowFilter;

	import weapondata.*;
	import locdata.*;
	import servdata.*;
	import graphdata.Emitter;
	import graphdata.Grafon;
	import graphdata.Part;
	
	import components.Settings;
	import components.XmlBook;

	import stubs.hpBar;

	public class Unit extends Obj
	{
		
		public static const
			D_BUL:int = 0,       // Bullets       +
			D_BLADE:int = 1,     // Blade         +
			D_PHIS:int = 2,      // Blunt         +
			D_FIRE:int = 3,      // Fire          *
			D_EXPL:int = 4,      // Explosion     +
			D_LASER:int = 5,     // Laser         *
			D_PLASMA:int = 6,    // Plasma        *
			D_VENOM:int = 7,     // Venom
			D_EMP:int = 8,       // EMP
			D_SPARK:int = 9,     // Lightning     *
			D_ACID:int = 10,     // Acid          *
			D_CRIO:int = 11,     // Cold          *
			D_POISON:int = 12,   // Poison
			D_BLEED:int = 13,    // Bleeding
			D_FANG:int = 14,     // Beast         +
			D_BALE:int = 15,     // Doom
			D_NECRO:int = 16,    // Necromancy
			D_PSY:int = 17,      // Psychic
			D_ASTRO:int = 18,    // Astrology ???
			D_PINK:int = 19,     // Pink Cloud
			D_INSIDE:int = 100,  // ???
			D_FRIEND:int = 101;  // Friendship

		public static var txtMiss:String;
		
		public static var arrIcos:Array;
		
		public var id:String;
		var mapxml:XML;
		var uniqName:Boolean=false;
		
		// Coordinates and sizes
		public var sitY:Number=40, stayY:Number=40, sitX:Number=40, stayX:Number=40;	// Dimensions
		public var begX:Number=-1, begY:Number=-1; 		// Initial point
		public var rasst:Number=0;	// Distance to the player character
		
		public var level:int=0;
		public var hero:int=0;
		public var boss:Boolean=false;
		// Health points (HP)
		public var maxhp:Number=100;
		public var hpmult:Number=1;
		public var hp:Number=100;
		public var cut:Number=0;	// Wounds
		public var poison:Number=0;	// Poison
		public var critHeal:Number=0.2;
		public var shithp:Number=0;
		var t_hp:int;
		public var mana:Number=1000, maxmana:Number=1000, dmana:Number=1;
		// Armor and vulnerabilities
		public var invulner:Boolean=false;
		public var allVulnerMult:Number=1;
		public var skin:Number=0, armor:Number=0, marmor:Number=0, armor_hp:Number=0, armor_maxhp:Number=0, armor_qual:Number=0;		// Skin, armor, probability that it will work
		public var shitArmor:Number=20;
		public var vulner:Array;		
		public var begvulner:Array;
		public static var begvulners:Array=new Array();
		public var dexter:Number=1, dexterPlus:Number=0;			// Evasion, 1 - standard, greater than 1 - more, 0 - always hit	
		public var dodge:Number=0, undodge:Number=0;			// Probability to dodge in close combat, bonus to hit probability, 1 - always
		public var transp:Boolean=false;	// Transparent to bullets that do not cause damage
		public var damWall:Number=0;		// Damage from hitting a wall
		public var damWallSpeed:Number=12;
		public var dopTestOn:Boolean=false;	// Complex hit check
		public var friendlyExpl:Number=0.25;
		// Damage
		public var dam:Number=0;			// Character's own damage
		public static const kolVulners:int = 20;
		public var tipDamage:int=D_PHIS;		// Damage type
		public var radDamage:Number=0;		// Radiation damage
		public var retDamage:Boolean=false; // Return damage from the character to the enemy
		public var relat:Number=0;			// Reverse return damage, from the enemy to the character
		public var destroy:Number=-1;			// Block damage on collision
		public var collisionTip:int=1;
		public var dieWeap:String;			// Weapon from which the character was killed
		public var levitAttack:Number=1;	// How successful the attack will be in levitation state
		public var noAgro:Boolean=false;	// Does not attack first
		
		// Movement
		// Movement parameters
		public var fixed:Boolean=false;		// Do not move at all
		public var bind:Obj;				// Binding
		public var mater:Boolean=true;		// Interact with walls
		public var massaFix:Number=1;		// Mass of the fixed object
		public var massaMove:Number=1;		// Mass of the moving object
		public var walk:int;				// Movement on the surface, 1 - right, -1 - left, 0 - no movement
		public var maxSpeed:Number=10, walkSpeed:Number=5, runSpeed:Number=10, sitSpeed:Number=3, lazSpeed:Number=5, plavSpeed:Number=5;
		public var accel:Number=5, brake:Number=1, levitaccel:Number=1.6, knocked:Number=1;
		public var jumpdy:Number=15, plavdy:Number=1, levidy:Number=1, elast:Number=0, jumpBall:Number=0;
		public var ddyPlav:Number=1; // Pushing force
		public var osndx:Number=0, osndy:Number=0;
		public var levit_max:int = 0; // Maximum levitation time, if 0, then levitation is not limited
		public var levit_r:int=0;		// How much time the object was levitated
		public var grav:Number=1;
		public var slow:int=0;			// External slowdown
		public var tormoz:Number=1;		// dx is multiplied by this value if the object is on the ground
		public var t_throw:int=0;		// Enabled after throwing
		// Variables
		public var stayPhis:int;
		public var stayOsn:Box=null;
		public var stayMat:int;
		public var tykMat:int;
		protected var shX1:Number, shX2:Number;	// How much you don't fit
		protected var diagon:int=0;
		public var porog:Number=10, porog_jump:Number=4; // Automatic lifting
		public var isSit:Boolean=false, isFly:Boolean=false, isRun:Boolean=false, isPlav:Boolean=false, isLaz:int=0, inWater:Boolean=false, isUp:Boolean=false;
		public var throu:Boolean=false, isJump:Boolean=false, turnX:int=0, turnY:int=0, kray:Boolean=false;
		public var pumpObj:Interact;	// The object you bumped into (for opening doors by mobs)
		private var namok_t:int=0;
		var visDamDY:int=0;


		// Weapon
		public var currentWeapon:Weapon;
		public var weaponSkill:Number=1;		// Proficiency with weapons
		public var spellPower:Number=1;		// Power of non-weapon spellsм
		public var mazil:int=0;			// Additional random bullet spread
		public var critCh:Number=0;		// Additional crit chance
		public var critInvis:Number=0;	// Crit chance modifier for mobs with no target on the bullet owner
		public var critDamMult:Number=2;	// Critical damage multiplier
		public var precMult:Number=1;	// Accuracy modifier for the player character (for others, it's 1)
		public var precMultCont:Number=1;	// Accuracy modifier decreasing from critical effects
		public var rapidMultCont:Number=1;	// Attack speed modifier for melee weapons, decreasing from critical effects
		public var weaponKrep:int=1;	
		public var weaponX:Number, weaponY:Number, weaponR:Number=0;
		public var magicX:Number, magicY:Number;
		public var childObjs:Array;			// Subordinate objects
		public var isShoot:Boolean=false;	// Set to true by the weapon when a shot is fired

		//AI
		var aiNapr:int=1, aiVNapr:int=0; // Direction in which AI aims to move
		var aiTTurn:int=10, aiPlav:int=0; 
		var aiState:int=0;	// AI state
		var aiTCh:int=Math.floor(Math.random()*10);	// AI state change timer
		var aiSpok:int=0, maxSpok:int=30;	// 0 - calm, 1-9 - excited, maxSpok - attacking the target
		// Coordinates and appearance of the target
		public var celX:Number=0, celY:Number=0, celDX:Number=0, celDY:Number=0;
		public var acelX:Number=0, acelY:Number=0;	// Anti-target
		public var celUnit:Unit;	// Who is the target
		public var priorUnit:Unit;	// Who is the enemy
		public var eyeX:Number=-1000, eyeY:Number=-1000;	// Line of sight
		
		// States
		public var sost:int=1;  // 1 - alive, 2 - inoperative, 3 - deceased, 4 - destroyed and no longer processed
		public var shok:int=0, maxShok:int=30;
		public var stun:int=0;
		public var neujaz:int=0, neujazMax:int=20;
		public var disabled:Boolean=false;
		public var gamePause:Boolean=false;	// Inactive, can be activated by command
		public var oduplenie:int=100;
		public var lootIsDrop:Boolean =false;	// Has loot already dropped
		public var aiTip:String;
		public var t_emerg:int=0, max_emerg:int=0;
		public var wave:int=0;	// Enemy belongs to a wave
		public var transT:Boolean=false;	// Passes through a magical wall
		public var postDie:Boolean=false;	// Initially a corpse
		
		// Options
		public var blood:int=0; // Blood: 0 - none, 1 - regular, 2 - green
		public var mat:int=0; // 0 - flesh, 1 - metal
		public var acidDey:Number=0;	// Armor corrosion by acid
		public var trup:Boolean=true; // Leave a corpse or destroy it
		public var overLook:Boolean=true; // Can see what's behind
		public var plav:Boolean=true; // If true - floats, otherwise walks on the bottom
		public var showNumbs:Boolean=true;	// Display damage
		public var activateTrap:int=2;	// Activate traps and mines
		public var isSats:Boolean=true;	// Be a target for GPS
		public var msex:Boolean=true;		// Male gender
		public var doop:Boolean=false;	// True is set for those who do not track targets
		public var plaKap:Boolean=true;	// Splashes
		public var noBox:Boolean=false;	// Does not receive blows from boxes
		public var areaTestTip:String;
		public var mHero:Boolean=false;	// Can become a hero
		public var isRes:Boolean=false;	// Resurrects after death
		public var mech:Boolean=false;	// Mechanism
		public var noDestr:Boolean=false; // Do not destroy after death
		
		public var opt:Object;
		public static var opts:Array=new Array();
		
		// Faction
		public var fraction:int=0, player:Boolean=false;
		public static const F_PLAYER=100, F_MONSTER=1, F_RAIDER=2, F_ZOMBIE=3, F_ROBOT=4;
		public var npc:Boolean=false;	// The unit is an NPC and is displayed on the map
		
		// Unit visibility to others (camouflage), the higher the value, the farther the object can be seen
		public var visibility:int=1000, stealthMult:Number=1;	// At what distance it becomes visible
		public var detecting:int=80;	// Distance of unconditional detection
		public var demask:Number=0;
		public var invis:Boolean=false;
		public var noise:int=0, noiseRun:int=200, noise_t:int=30;			// Sound
		public var isVis:Boolean=true; 		// Visible or not to the player character
		public var volMinus:Number=0;	// Decrease in volume of sound effects
		public var light:Boolean=false;	// Remove the fog of war at this point
		
		// Visibility of other units
		public var observ:Number=0;			// Observability
		public var vision:Number=1;			// Vision multiplier
		public var ear:Number=1;			// Hearing multiplier
		public var unres:Boolean=false;		// Do not react to sounds
		public var vAngle:Number=0;			// Field of view angle
		public var vKonus:Number=0;			// Field of view cone
		
		// Effects
		public var effects:Array;
		
		// Random name
		public var id_name:String;
		// Dialogues
		public var t_replic:int=Math.random()*100-50;
		public var id_replic:String='';
		
		// Visual part
		// Blitting
		var blitId:String;		// Bitmap ID
		public var animState:String='',animState2:String='';
		public var blitData:BitmapData;
		var blitX:int=120, blitY:int=120;
		var blitDX:int=-1, blitDY:int=-1;
		var blitRect:Rectangle;
		var blitPoint:Point;
		var visData:BitmapData;
		var visBmp:Bitmap;
		var anims:Array;
		
		var ctrans:Boolean=true;	// Apply color filter
		// Health bar
		public var hpbar:MovieClip;
		public static var heroTransforms=[new ColorTransform(1,0.8,0.8,1,64,0,0,0),new ColorTransform(0.8,1,1,1,0,32,64,0),new ColorTransform(1,0.8,1,1,32,0,64,0),new ColorTransform(0.8,1,0.8,1,0,64,0,0)];
		// Deadly effects
		var timerDie:int=0;	// Delayed death
		var burn:Desintegr;
		var bloodEmit:Emitter;
		var numbEmit:Emitter;
		var hitPart:Part, t_hitPart:int=0, hitSumm:Number=0, t_mess:int=0;
		// Sounds
		public var sndMusic:String;
		var sndMusicPrior:int=0;
		public var sndDie:String;
		public var sndRun:String;
		public var sndRunDist:Number=800;
		public var sndRunOn:Boolean=false;
		var sndVolkoef:Number=1;

		// Parent
		var mother:Unit;
		var kolChild:int=0;

		public var scrDie:Script, scrAlarm:Script;
		public var questId:String;	// ID for a collectible quest
		
		public var trig:String;		// Appearance condition
		public var trigDis:Boolean=false;	// Disabled by trigger
		
		public var xp:int=0;	// Experience
		
		static var ppp:Point=new Point();
		
		static const robotKZ=75;
		static const damWallStun=45;



		// Parameters for creating a unit
		// cid - creation identifier, based on which the real identifier will be determined inside the class constructor
		// dif - difficulty level for this unit
		// xml - individual parameters taken from the map
		// loadObj - object for loading the unit's state
		public function Unit(cid:String=null, ndif:Number=100, xml:XML=null, loadObj:Object=null) {
			vulner=new Array();
			inter=new Interact(this,null,xml,loadObj);
			inter.active=false;
			for (var i=0; i<kolVulners; i++) vulner[i]=1;
			vulner[D_EMP]=0;
			effects=new Array();
			layer=2, prior=1, warn=1;
			numbEmit=Emitter.arr['numb'];
			if (xml) {
				if (xml.@turn.length()) {
					if (xml.@turn>0) storona=1;
					if (xml.@turn<0) storona=-1;
				} else {
					storona=isrnd()?1:-1;
					aiNapr=storona;
				}
				if (xml.@name.length()) {
					uniqName=true;
					objectName=Res.txt('u',xml.@name);
				}
				if (xml.@ai.length()) aiTip=xml.@ai;
				if (xml.@hpmult.length()) hpmult=xml.@hpmult;
				if (xml.@multhp.length()) hpmult=xml.@multhp;
				if (xml.@unres.length()) unres=true;
				if (xml.@qid.length()) questId=xml.@qid;
				if (xml.@trig.length()) trig=xml.@trig;
				if (xml.@hero.length()) hero=xml.@hero;
				if (xml.@observ.length()) observ=xml.@observ;
				if (xml.@light.length()) light=true;
				if (xml.@noagro.length()) noAgro=true;
				if (xml.@dis.length()) {
					gamePause=true;
					disabled=true;
				}
				if (xml.@die.length()) postDie=true;
			}

			if (loadObj && loadObj.dead && !postDie) 
			{
				sost=4;
				disabled=true;
				trace(this, objectName)
			}
			mapxml=xml;
		}
		
		public static function create(id:String, dif:int, xml:XML=null, loadObj:Object=null, ncid:String=null):Unit //TODO: Replace with dictionary
		{
			if (id=='mwall') return new UnitMWall(null,0,null,null);
			if (id=='scythe') return new UnitScythe(null,0,null,null);
			if (id=='ttur') return new UnitThunderTurret(ncid,0,null,null);
			var node:XML = XmlBook.getXML("objects").obj.(@id == id)[0];
			if (node==null) 
			{
				trace('Не найден юнит',id);
				return null;
			}
			var uc:Class;
			var cn:String=node.@cl;
			switch (cn) 
			{
				case 'Mine': uc=Mine;break;
				case 'UnitTrap': uc=UnitTrap;break;
				case 'UnitTrigger': uc=UnitTrigger;break;
				case 'UnitDamager': uc=UnitDamager;break;
				case 'UnitRaider': uc=UnitRaider;break;
				case 'UnitSlaver': uc=UnitSlaver;break;
				case 'UnitZebra': uc=UnitZebra;break;
				case 'UnitRanger': uc=UnitRanger;break;
				case 'UnitEncl': uc=UnitEncl;break;
				case 'UnitMerc': uc=UnitMerc;break;
				case 'UnitZombie': uc=UnitZombie;break;
				case 'UnitAlicorn': uc=UnitAlicorn;break;
				case 'UnitHellhound': uc=UnitHellhound;break;
				case 'UnitRobobrain': uc=UnitRobobrain;break;
				case 'UnitProtect': uc=UnitProtect;break;
				case 'UnitGutsy': uc=UnitGutsy;break;
				case 'UnitEqd': uc=UnitEqd;break;
				case 'UnitSentinel': uc=UnitSentinel;break;
				case 'UnitTurret':uc=UnitTurret;break;
				case 'UnitBat': uc=UnitBat;break;
				case 'UnitFish': uc=UnitFish;break;
				case 'UnitBloat': uc=UnitBloat;break;
				case 'UnitBloatEmitter': uc=UnitBloatEmitter;break;
				case 'UnitSpriteBot': uc=UnitSpriteBot;break;
				case 'UnitDron': uc=UnitDron;break;
				case 'UnitVortex': uc=UnitVortex;break;
				case 'UnitMonstrik': uc=UnitMonstrik;break;
				case 'UnitAnt': uc=UnitAnt;break;
				case 'UnitSlime': uc=UnitSlime;break;
				case 'UnitRoller': uc=UnitRoller;break;
				case 'UnitNPC': uc=UnitNPC;break;
				case 'UnitCaptive': uc=UnitCaptive;break;
				case 'UnitPonPon': uc=UnitPonPon;break;
				case 'UnitTrain': uc=UnitTrain;break;
				case 'UnitMsp': uc=UnitMsp;break;
				case 'UnitTransmitter': uc=UnitTransmitter;break;
				case 'UnitNecros': uc=UnitNecros;break;
				case 'UnitSpectre': uc=UnitSpectre;break;
				case 'UnitBossRaider': uc=UnitBossRaider;break;
				case 'UnitBossAlicorn': uc=UnitBossAlicorn;break;
				case 'UnitBossUltra': uc=UnitBossUltra;break;
				case 'UnitBossNecr': uc=UnitBossNecr;break;
				case 'UnitBossDron': uc=UnitBossDron;break;
				case 'UnitBossEncl': uc=UnitBossEncl;break;
				case 'UnitThunderHead': uc=UnitThunderHead;break;
				case 'UnitDestr': uc=UnitDestr;break;
			}
			if (uc==null) 
			{
				return null;
			}
			var cid:String=null;						// Creation identifier
			if (node.@cid.length()) cid=node.@cid;
			if (ncid!=null) cid=ncid;
			var un:Unit=new uc(cid,dif,xml,loadObj);
			if (xml && xml.@code.length()) un.code=xml.@code;
			return un;
		}
		
		public override function save():Object 
		{
			var obj:Object=new Object();
			if (sost>=3 && !postDie) obj.dead=true;
			if (inter) inter.save(obj);
			return obj;
		}
		
		public function getXmlParam(mid:String=null):void
		{
			var setOpts:Boolean=false;
			if (opts[id]) 
			{
				opt=opts[id];
				begvulner=begvulners[id];
			} 
			else 
			{
				opt=new Object();
				opts[id]=opt;
				begvulner=new Array();
				begvulners[id]=begvulner;
				setOpts=true;
			}
			var node:XML;
			var isHero:Boolean=false;
			if (mid==null) 
			{
				if (hero>0) isHero=true;
				mid=id;
			}
			var node0:XML = XmlBook.getXML("units").unit.(@id == mid)[0];
			if (mid && !uniqName) objectName=Res.txt('u',mid);
			if (node0.@fraction.length()) fraction=node0.@fraction;
			inter.cont=mid;
			if (node0.@cont.length() && inter) inter.cont=node0.@cont;
			if (fraction==F_PLAYER) warn=0;

			if (node0.@xp.length()) xp = node0.@xp * Settings.unitXPMult; //TODO - Probably redundant, remove from World.

			//физические параметры
			if (node0.phis.length()) 
			{
				node=node0.phis[0];
				if (node.@sX.length()) stayX=scX=node.@sX;
				if (node.@sY.length()) stayY=scY=node.@sY;
				if (node.@sitX.length()) sitX=node.@sitX; else sitX=stayX;
				if (node.@sitY.length()) sitY=node.@sitY; else sitY=stayY/2;
				if (node.@massa.length()) massaMove=node.@massa/50;
				if (node.@massafix.length()) massaFix=node.@massafix/50;
				else massaFix=massaMove;
			}
			massa=massaFix;
			if (massa>=1) destroy=0;
			//Movement parameters
			if (node0.move.length()) 
			{
				node=node0.move[0];
				if (node.@speed.length()) maxSpeed=node.@speed;
				if (node.@run.length()) runSpeed=node.@run;
				if (node.@accel.length()) accel=node.@accel;
				if (node.@jump.length()) jumpdy=node.@jump;
				if (node.@knocked.length()) knocked=node.@knocked;		// Knockback multiplier from weapons
				if (node.@plav.length()) plav=(node.@plav>0);			// If = 0, the unit does not float but walks on the bottom
				if (node.@brake.length()) brake=node.@brake;			// Braking
				if (node.@levit.length()) levitPoss=(node.@levit>0);	// If = 0, the unit cannot be lifted by telekinesis
				if (node.@levit_max.length()) levit_max=node.@levit_max;// Maximum levitation time
				if (node.@levitaccel.length()) levitaccel=node.@levitaccel;	// Acceleration in the levitation field, determines the ability of an enemy to break free from telekinetic grip
				if (node.@float.length()) ddyPlav=node.@float;			// Value of the repelling force
				if (node.@porog.length()) porog=node.@porog;			// Automatic lift when moving horizontally
				if (node.@fixed.length()) fixed=(node.@fixed>0);		// If = 1, the unit is attached
				if (node.@damwall.length()) damWall=node.@damwall;		// Damage from hitting a wall
			}
			//Combat parameters
			if (node0.comb.length()) 
			{
				node=node0.comb[0];
				if (node.@hp.length()) hp=maxhp=node.@hp*hpmult;
				if (fraction!=F_PLAYER && World.world.game.globalDif<=1) 
				{
					if (World.world.game.globalDif==0) maxhp*=0.4;
					if (World.world.game.globalDif==1) maxhp*=0.7;
					hp=maxhp;
				}
				if (node.@skin.length()) skin=node.@skin;
				if (node.@armor.length()) armor=node.@armor;
				if (node.@marmor.length()) marmor=node.@marmor;
				if (node.@aqual.length()) armor_qual=node.@aqual;		// Armor quality
				if (node.@armorhp.length()) armor_hp=armor_maxhp=node.@armorhp*hpmult;
				else armor_hp=armor_maxhp=hp;
				
				if (node.@krep.length()) weaponKrep=node.@krep;			// Weapon grip, 0 - telekinesis
				if (node.@dexter.length()) dexter=node.@dexter;			// Evasion
				if (node.@damage.length()) dam=node.@damage;			// Own damage
				if (node.@tipdam.length()) tipDamage=node.@tipdam;		// Type of own damage
				if (node.@skill.length()) weaponSkill=node.@skill;		// Weapon proficiency
				if (node.@raddamage.length()) radDamage=node.@raddamage;// Radiation self-damage
				if (node.@vision.length()) vision=node.@vision;			// Vision
				if (node.@observ.length()) observ+=node.@observ;		// Observability
				if (node.@ear.length()) ear=node.@ear;					// Hearing
				if (node.@levitatk.length()) levitAttack=node.@levitatk;// Attack during levitation
			}
			// Vulnerabilities
			if (node0.vulner.length()) 
			{
				//public static const D_BUL=0, D_BLADE=1, D_PHIS=2, D_FIRE=3, D_EXPL=4, D_LASER=5, D_PLASMA=6, D_VENOM=7, D_EMP=8, D_SPARK=9, D_ACID=10, D_INSIDE=100;
				node = node0.vulner[0];
				if (node.@bul.length()) vulner[D_BUL] = node.@bul;
				if (node.@blade.length()) vulner[D_BLADE] = node.@blade;
				if (node.@phis.length()) vulner[D_PHIS] = node.@phis;
				if (node.@fire.length()) vulner[D_FIRE] = node.@fire;
				if (node.@expl.length()) vulner[D_EXPL] = node.@expl;
				if (node.@laser.length()) vulner[D_LASER] = node.@laser;
				if (node.@plasma.length()) vulner[D_PLASMA] = node.@plasma;
				if (node.@venom.length()) vulner[D_VENOM] = node.@venom;
				if (node.@emp.length()) vulner[D_EMP] = node.@emp;
				if (node.@spark.length()) vulner[D_SPARK] = node.@spark;
				if (node.@acid.length()) vulner[D_ACID] = node.@acid;
				if (node.@cryo.length()) vulner[D_CRIO] = node.@cryo;
				if (node.@poison.length()) vulner[D_POISON] = node.@poison;
				if (node.@bleed.length()) vulner[D_BLEED] = node.@bleed;
				if (node.@fang.length()) vulner[D_FANG] = node.@fang;
				if (node.@pink.length()) vulner[D_PINK] = node.@pink;
			}
			// Visual parameters
			if (node0.vis.length()) 
			{
				node=node0.vis[0];
				if (node.@sex=='w') msex=false;
				if (node.@blit.length()) 
				{
					blitId=node.@blit;
					if (node.@sprX>0) blitX=node.@sprX;
					if (node.@sprY>0) blitY=node.@sprY;
					else blitY=node.@sprX;
					if (node.@sprDX.length()) blitDX=node.@sprDX;
					if (node.@sprDY.length()) blitDY=node.@sprDY;
				}
				if (node.@replic.length()) id_replic=node.@replic;
				if (node.@noise.length()) noiseRun=node.@noise;
			}
			// Sound Parameters
			if (node0.snd.length()) 
			{
				node=node0.snd[0];
				if (node.@music.length()) 
				{
					sndMusic=node.@music;
					sndMusicPrior=1;
				}
				if (node.@musicp.length()) sndMusicPrior=node.@musicp;
				if (node.@die.length()) sndDie=node.@die;
				if (node.@run.length()) sndRun=node.@run;
			}
			// Other Parameters
			if (node0.param.length()) 
			{
				node=node0.param[0];
				if (node.@invulner.length()) invulner=(node.@invulner>0);	// Full invulnerability
				if (node.@overlook.length()) overLook=(node.@overlook>0);	// Can look behind
				if (node.@sats.length()) isSats=(node.@sats>0);				// Display as target in GPS
				if (node.@acttrap.length()) activateTrap=node.@acttrap;		// Unit activates traps: 0 - none, 1 - only player-placed
				if (node.@npc.length()) npc=(node.@npc>0);					// Display on the map as an NPC
				if (node.@trup.length()) trup=(node.@trup>0);				// Leave a corpse after death
				if (node.@blood.length()) blood=node.@blood;				// Blood
				if (node.@retdam.length()) retDamage=node.@retdam>0;		// Damage reflection
				if (node.@hero.length()) 
				{
					mHero=true;												// Can be a hero
					id_name=node.@hero;
				}
				if (setOpts) 
				{
					if (node.@pony.length()) opt.pony=true;					// Is a pony
					if (node.@zombie.length()) opt.zombie=true;				// Is a zombie
					if (node.@robot.length()) opt.robot=true;				// Is a robot
					if (node.@insect.length()) opt.insect=true;				// Is an insect
					if (node.@monster.length()) opt.monster=true;			// Is a monster
					if (node.@alicorn.length()) opt.alicorn=true;			// Is an alicorn
					if (node.@mech.length()) 
					{
						opt.mech=true;										// Is a mechanism
						mech=true;
					}
					if (node.@hbonus.length()) opt.hbonus=true;				// Is a bonus
					if (node.@izvrat.length()) opt.izvrat=true;				// Is a pervert
				}
			}
			if (blood == 0) vulner[D_BLEED] = 0;
			if (opt) 
			{
				if (opt.robot || opt.mech) 
				{
					vulner[D_NECRO] = 0;
					vulner[D_BLEED] = 0;
					vulner[D_VENOM] = 0;
					vulner[D_POISON] = 0;
				}
			}
			if (node0.blit.length()) 
			{
				if (anims == null) anims = new Array();
				for each(var xbl:XML in node0.blit) 
				{
					anims[xbl.@id] = new BlitAnim(xbl);
				}
			}
			if (setOpts) for (var i = 0; i < kolVulners; i++) begvulner[i] = vulner[i];
		}
		
		public function getXmlWeapon(dif:int):Weapon 
		{
			var node0:XML = XmlBook.getXML("units").unit.(@id == id)[0];
			var weap:Weapon;
			for each(var n:XML in node0.w) 
			{
				if (n.@f.length()) continue;
				if (n.@dif.length() && n.@dif>dif) continue;
				if (n.@ch.length()==0 || isrnd(n.@ch)) 
				{
					weap=Weapon.create(this,n.@id);
					if (weap) return weap;
				}
			}
			return null;
		}
		
		public function getName():String 
		{
			if (World.world.game==null || id_name==null) return '';
			var arr:Array=World.world.game.names[id_name];
			if (arr==null || arr.length == 0) arr=Res.namesArr(id_name); 	//подготовить массив имён
			if (arr==null || arr.length == 0) return '';
			World.world.game.names[id_name]=arr;
			var n=Math.floor(Math.random()*arr.length);
			var s=arr[n];
			arr.splice(n,1);
			return s;
		}
		
		public function checkTrig():Boolean 
		{
			if (trig) 
			{
				if (trig=='eco' && (World.world.pers==null || World.world.pers.eco==0)) return false;
				if (World.world.game.triggers[trig]!=1) return false;
			}
			return true;
		}
		
		//поместить созданный юнит в локацию
		public function putLoc(newRoom:Room, nx:Number, ny:Number):void
		{
			if (room!=null) return;
			room=newRoom;
			if (room.mirror) 
			{
				storona=-storona;
				aiNapr=storona;
			}
			setPos(nx,ny);
			if (collisionAll()) 
			{
				if (!collisionAll(-Tile.tilePixelWidth)) 
				{
					setPos(nx-Tile.tilePixelWidth,ny);
				}
			}
			if (inter) inter.room=newRoom;
			if (inter && inter.saveLoot==2) 
			{
				inter.loot(true);	//если состояние 2, сгенерировать критичный лут
			}
			if (sost>=3) return;
			begX=X, begY=Y;
			if (hero==0) cTransform=room.cTransform;
			else cTransform=heroTransforms[hero-1];
			if (room.biom==5) 
			{
				vulner[D_PINK]=0;	//неуязв. к розовому облаку
			}
			//прикреплённые скрипты
			if (mapxml) 
			{
				if (mapxml.scr.length()) 
				{
					for each (var xscr in mapxml.scr) 
					{
						var scr:Script=new Script(xscr,room.level, this);
						if (scr.eve=='die' || scr.eve==null) scrDie=scr;
						if (scr.eve=='alarm') scrAlarm=scr;
					}
				}
				if (mapxml.@scr.length()) scrDie=World.world.game.getScript(mapxml.@scr,this);
				if (mapxml.@alarm.length()) scrAlarm=World.world.game.getScript(mapxml.@alarm,this);
			}
			if (postDie) 
			{
				sost=3;
				setCel(null, X+storona*100,Y+50);
				lootIsDrop=true;
				die();
			};
		}

		// Set the level of the mob (the value is added to the level set through the map, default is 0)
		public function setLevel(nlevel:int = 0):void
		{
			level += nlevel;
			if (level < 0) level = 0;
			maxhp = hp*(1 + level*0.11);
			hp = hp*(1 + level*0.11);
			dam*=(1+level*0.07);
			radDamage*=(1+level*0.1);
			critCh=level*0.01;
			armor*=(1+level*0.05);
			marmor*=(1+level*0.05);
			skin*=(1+level*0.05);
			armor_hp=armor_maxhp=armor_hp*(1+level*0.1);
			observ+=Math.min(nlevel*0.6,15)*(0.9+Math.random()*0.2);
			if (currentWeapon && currentWeapon.tip==0) 
			{
				currentWeapon.damage*=(1+level*0.07);
			} 
			else 
			{
				weaponSkill*=(1+level*0.035);
			}
			damWall*=(1+level*0.04);
		}
		
		//сделать героем
		public function setHero(nhero:int=1):void
		{
			if (!mHero) return;
			if (hero==0) hero=nhero;
			if (hero>0) 
			{
				if (!uniqName) 
				{
					var s=getName();
					if (s!=null && s!='') objectName=s;
				}
				xp*=5;
			}
			if (hero==1) 
			{
				hp=maxhp=maxhp*2.5;
				dam*=1.8;
				if (currentWeapon) currentWeapon.damage*=1.5;
			} 
			else if (hero==2 || hero==3) 
			{
				hp=maxhp=maxhp*3;
				dam*=1.2;
			} 
			else if (hero==4) 
			{
				hp=maxhp=maxhp*2;
				dam*=1.4;
				observ+=8;
				walkSpeed*=1.4;
				sitSpeed*=1.4;
				runSpeed*=1.25;
			}
			setHeroVulners();
			//trace(id,hero)
		}
		
		public function setHeroVulners():void
		{
			vulner[D_EMP]*=0.8;
			vulner[D_BALE]*=0.7;
			vulner[D_NECRO]*=0.7;
			vulner[D_ASTRO]*=0.7;
			if (hero==2) 
			{
				vulner[D_BUL]*=0.5;
				vulner[D_PHIS]*=0.65;
				vulner[D_BLADE]*=0.65;
				vulner[D_EXPL]*=0.75;
			}
			if (hero==3) 
			{
				vulner[D_LASER]*=0.6;
				vulner[D_PLASMA]*=0.5;
				vulner[D_EMP]*=0.75;
				vulner[D_SPARK]*=0.7;
				vulner[D_FIRE]*=0.7;
			}
		}
		
		// Set to the initial state; if f = true, return to the original position
		public override function setNull(f:Boolean = false):void
		{
			if (boss && isNoResBoss()) f=false;
			if (sost==1) 
			{
				if (f) 
				{
					// Reset effects
					if (effects.length > 0) 
					{
						for each (var eff in effects) eff.unsetEff();
						effects = new Array();
					}
					stun=cut=poison=0;
					oduplenie=Math.round(Settings.oduplenie*(Math.random()*0.2+0.9));
					if (!gamePause) disabled=false;		//включить
					hp = maxhp;			//восстановить хп
					armor_hp = armor_maxhp;
					if (hpbar) visDetails();
					//вернуть в исходную точку
					if (begX>0 && begY>0) setPos(begX, begY);
					dx = 0;
					dy = 0;
					setWeaponPos();
				}
				if (currentWeapon) currentWeapon.setNull();
			}
			levit = 0;
		}
		
		// Condition under which the boss does not restore HP
		public function isNoResBoss():Boolean 
		{
			var res=false;
			try 
			{
				res = World.world.game.globalDif <= 3 && room && room.level.template.tip != 'base';
			} 
			catch(err) {}
			return res;
		}
		
		public override function err():String 
		{
			return 'Error unit ' + objectName;
		}
		
		
		
		public override function step():void
		{
			if (disabled || trigDis) return;
			if (t_emerg > 0)
			{
				t_emerg--;
				setVisPos();
				if (vis) 
				{
					if (t_emerg > 0) 
					{
						var tf=t_emerg/(max_emerg+1);
						vis.filters=[new GlowFilter(0xAADDFF,tf,tf*20,tf*20,1,3)];
						vis.alpha=1-tf;
					} 
					else 
					{
						vis.filters=[];
						vis.alpha=1;
					}
				}
				return;
			}
			if (sost == 2) 
			{
				timerDie--;
				if (timerDie<=0) die();
			}
			if (inter) inter.step();
			getRasst2();
			if (radioactiv) ggModum();	//действие на ГГ (радиация)
			forces();		//внешние силы, влияющие на ускорение
			control();		//управление игроком или ИИ

			//движение
			if (fixed) 
			{

			} 
			else if (bind || Math.abs(dx+osndx)<Settings.maxdelta && Math.abs(dy+osndy)<Settings.maxdelta)	
			{
				run();
			} 
			else 
			{
				var div=Math.floor(Math.max(Math.abs(dx+osndx),Math.abs(dy+osndy))/Settings.maxdelta)+1;
				for (var i=0; i<div; i++) run(div);
			}
			checkWater();
			actions();		//различные действия
			setVisPos();
			if (hpbar) setHpbarPos();
			if (burn==null) animate();		//анимация
			else 
			{
				burn.step();
				if (burn.vse) exterminate();
			}
			onCursor=(isVis && !disabled && sost<4 && X1<World.world.celX && X2>World.world.celX && Y1<World.world.celY && Y2>World.world.celY)?prior:0;

			//подчинённые объекты
			for (i in childObjs) if (childObjs[i]) 
			{
				try 
				{
					childObjs[i].step();
				} 
				catch(err) 
				{
					childObjs[i].err();
				}
			}
			visDamDY=0;
			if (sndRunOn && sndRun && room && room.roomActive) sndRunPlay();

		}
		
		public function control():void
		{

		}
		
//**************************************************************************************************************************
//
//				Movement
//
//**************************************************************************************************************************
		//Move to a point
		public function setPos(nx:Number,ny:Number):void
		{
			X=nx, Y=ny;
			Y1=Y-scY, Y2=Y, X1=X-scX/2, X2=X+scX/2;
			setCel();
		}
		
		
		// Exiting the room
		public function outLoc(napr:int, portX:Number=-1, portY:Number=-1):Boolean 
		{
			// 1 - left, 2 - right, 3 - down, 4 - up
			// Should return false for all characters except the main character
			if (isFly || levit) return false;
			if (napr==3) 
			{
				if (room.bezdna || jumpdy<=0 || sost==3) 	// Falling beyond the room boundaries
				{	
					disabled=true;
					dy=0;
					if (sost==3) 
					{
						sost=4;
						room.remObj(this);
					}
					remVisual();
				} 
				else 
				{
					dy=-jumpdy;
					dx=storona*maxSpeed;
				}
			} 
			return false;
		}
		
		// Gradual appearance
		public function emergence(n:int=30):void
		{
			t_emerg=max_emerg=n;
		}

		// Acting forces
		public function forces():void
		{
			if (levit) 
			{
				dy *= 0.8;
				dx *= 0.8;
				isLaz=0;
			}
			if (isPlav) 
			{
				if (!levit) dy+=Settings.ddy*ddyPlav;
				dy *= 0.8;
				dx *= 0.8;
			} 
			else if (isFly) 
			{
				if (t_throw>0) 
				{

				} 
				else 
				{
					if ((dx*dx+dy*dy)>maxSpeed*maxSpeed) 
					{
						dx*=0.7;
						dy*=0.7;
					}
					if (dx > -brake && dx < brake) dx = 0;
					if (dy > -brake && dy < brake) dy = 0;
				}
			} 
			else 
			{
				if (inWater) dx *= 0.5;
				if (!levit && isLaz == 0) 
				{
					var t:Tile = room.getAbsTile(X, Y - scY / 4);
					if (t.grav > 0 && dy<Settings.maxdy*t.grav || t.grav < 0 && dy > Settings.maxdy * t.grav) dy += Settings.ddy * t.grav * grav;
				}
				if (stay) 
				{
					dx*=tormoz;
					if (walk<0) 
					{
						if (dx < -maxSpeed) dx += brake;
					} 
					else if (walk>0) 
					{
						if (dx>maxSpeed) dx -= brake;
					} 
					else 
					{
						if (dx>-brake && dx<brake) dx = 0;
						else if (dx>0) dx -= brake;
						else if (dx<0) dx += brake;
					}
					if (room.quake && massa<=2 && sost==1) 
					{
						var pun:Number=(1+(2-massa)/2)*room.quake;
						if (pun > 10) pun = 10;
						dy = -pun * Math.random();
						dx += pun * (Math.random()*2-1);
					}
				}
			}
			if (slow > 0) 
			{
				dx *= 0.75;
				dy *= 0.75;
			}
			osndx = 0;
			osndy = 0;
			if (stayOsn) 
			{
				if (stayOsn.cdx > 10 || stayOsn.cdx < -10 || stayOsn.cdy > 10 || stayOsn.cdy < -10) 
				{
					stay=false;
				} 
				else 
				{
					osndx = stayOsn.cdx;
					osndy = stayOsn.cdy;
				}
			}
			stayOsn = null;
		}
		
		
		
		public function run(div:int=1):void
		{
			if (room.sky) 
			{
				run2(div);
				return;
			}
			//Movement
			var t:Tile, t2:Tile;
			var i:int;
			var newmy:Number = 0;
			var autoSit:Boolean = false;
			
			if (!throu && stay && diagon!=0 && dy>=0) 
			{
				if (!collisionAll(dx/div,-dx/div*diagon)) 
				{
					X+=dx/div;
					Y-=dx/div*diagon;
					Y1=Y-scY, Y2=Y;
					X1=X-scX/2, X2=X+scX/2;
					dy=0;
					checkDiagon(0);
				} 
				else if (-dx/div*diagon>0 && !collisionAll(dx/div,0)) 
				{
					diagon=0;
				}
				return;
			}			
			diagon=0;
			// HORIZONTAL
			if (!isLaz) 
			{
				X += (dx + osndx) / div;
				if (X - scX / 2 < 0) 
				{
					if (!outLoc(1)) 
					{
						X = scX / 2;
						dx = Math.abs(dx) * elast;
						turnX=1;
						kray=true;
					}
				}
				if (X+scX/2>=room.roomPixelWidth) 
				{
					if (!outLoc(2)) 
					{
						X = room.roomPixelWidth - 1 - scX / 2;
						dx = -Math.abs(dx) * elast;
						turnX=-1;
						kray=true;
					}
				}
				X1 = X - scX / 2, X2 = X + scX / 2;
				//Move to the left
				if (dx + osndx < 0) 
				{
					if (!player && stay && shX1 > 0.5) 
					{
						newmy = checkDiagon(-5);
						if (newmy > 0) 
						{
							Y = newmy;
							Y1 = Y - scY;
							Y2 = Y;
						}
					}
					if (player && !isSit && !isFly && !isPlav && !levit && (!stay || isUp || shX1 > 0.5)) 
					{
						newmy = checkDiagon(-2, -1);
						if (newmy > 0) 
						{
							Y = newmy;
							Y1 = Y - scY, Y2 = Y;
						}
					}
					if (player && isUp && stay && !isSit) 
					{
						var x1Floor:int = Math.floor(X1 / Tile.tilePixelWidth);
						var y1Floor:int = Math.floor(Y1 / Tile.tilePixelHeight);

						t = room.roomTileArray[x1Floor][y1Floor];
						t2 = room.roomTileArray[x1Floor][y1Floor + 1];
						
						if ((t.phis == 0 || t.phis == 3) && !(t2.phis == 0 || t2.phis == 3) && t2.zForm == 0) 
						{
							Y = t2.phY1;
							Y2 = t2.phY1;
							sit(true);
							autoSit = true;
						}
					}
					if (mater) 
					{
						for (i=Math.floor(Y1/Tile.tilePixelHeight); i<=Math.floor(Y2/Tile.tilePixelHeight); i++) 
						{
							t=room.roomTileArray[Math.floor(X1/Tile.tilePixelWidth)][i];
							if (collisionTile(t)) 
							{
								if (t.door && t.door.inter) pumpObj=t.door.inter;
								if (Y2-t.phY1<=(stay?porog:porog_jump) && !collisionAll(-20,t.phY1-Y2)) 
								{
									Y=t.phY1;
								} 
								else 
								{
									X=t.phX2+scX/2;
									if (t_throw>0 && dx<-damWallSpeed && damWall) damageWall(2);
									if (destroy>0 && destroyWall(t,1)) 
									{
										dx*=0.75;
									} 
									else 
									{
										dx=Math.abs(dx)*elast;
										turnX=1;
										if (t.tileMaterial==1) tykMat=1;
										X1=X-scX/2, X2=X+scX/2;
									}
								}
							}
						}
					}
				}
				//Move to the right
				if (dx+osndx>0) {
					if (!player && stay && shX2>0.5) 
					{
						newmy=checkDiagon(-5);
						if (newmy>0) 
						{
							Y=newmy;
							Y1=Y-scY, Y2=Y;
						}
					}
					if (player && !isSit && !isFly && !isPlav && !levit && (!stay || isUp || shX2>0.5)) 
					{
						newmy=checkDiagon(-2,1);
						if (newmy>0) 
						{
							Y=newmy;
							Y1=Y-scY, Y2=Y;
						}
					}
					if (player && isUp && stay && !isSit) 
					{
						t=room.roomTileArray[Math.floor(X2/Tile.tilePixelWidth)][Math.floor(Y1/Tile.tilePixelHeight)];
						t2=room.roomTileArray[Math.floor(X2/Tile.tilePixelWidth)][Math.floor(Y1/Tile.tilePixelHeight)+1];
						if ((t.phis==0 || t.phis==3) && !(t2.phis==0 || t2.phis==3) && t2.zForm==0) 
						{
							Y=Y2=t2.phY1;
							sit(true);
							autoSit=true;
						}
					} 
					if (mater) 
					{
						for (i=Math.floor(Y1/Tile.tilePixelHeight); i<=Math.floor(Y2/Tile.tilePixelHeight); i++) 
						{
							t=room.roomTileArray[Math.floor(X2/Tile.tilePixelWidth)][i];
							if (collisionTile(t)) 
							{
								if (t.door && t.door.inter) pumpObj=t.door.inter;
								if (Y2-t.phY1<=(stay?porog:porog_jump) && !collisionAll(20,t.phY1-Y2)) 
								{
									Y=t.phY1;
								} 
								else 
								{
									X=t.phX1-scX/2;
									if (t_throw>0 && dx>damWallSpeed && damWall) damageWall(1);
									if (destroy>0 && destroyWall(t,2)) 
									{
										dx*=0.75;
									} 
									else 
									{
										dx=-Math.abs(dx)*elast;
										turnX=-1;
										if (t.tileMaterial==1) tykMat=1;
										X1=X-scX/2, X2=X+scX/2;
									}
								}
							}
						}
					}
				}
				Y1=Y-scY, Y2=Y;
			}
			// Repulsion
			
			
			// VERTICAL
			// Move down
			newmy=0;
			if (dy+osndy>0) 
			{
				if (dy>0) 
				{
					stay=false;
					stayPhis=stayMat=0;
				}
				//diagon=0;
				shX1=shX2=1; // If >0, then you are not completely standing on the ground
				if (levit || plav && isPlav || isFly) {	// Flight, levitation, or swimming
					diagon=0;
					Y+=(dy+osndy)/div;
					if (Y>room.roomPixelHeight) 
					{
						if (!outLoc(3)) 
						{
							Y=room.roomPixelHeight-1;
							dy=0;
							turnY=-1;
						}
					}
					Y1=Y-scY, Y2=Y;
					if (mater) 
					{
						for (i=Math.floor(X1/Tile.tilePixelWidth); i<=Math.floor(X2/Tile.tilePixelWidth); i++) 
						{
							t=room.roomTileArray[i][Math.floor(Y2/Tile.tilePixelHeight)];
							if (collisionTile(t)) 
							{
								Y=t.phY1;
								Y1=Y-scY, Y2=Y;
								dy=0;
								turnY=-1;
								if (t.tileMaterial==1) tykMat=1;
							}
						}
					}
				} 
				else 
				{						// Falling
					if (mater) 
					{
						for (i=Math.floor(X1/Tile.tilePixelWidth); i<=Math.floor(X2/Tile.tilePixelWidth); i++) 
						{
							t=room.roomTileArray[i][Math.floor((Y2+dy/div)/Tile.tilePixelHeight)];
							if (collisionTile(t,0,dy/div)) 
							{
								if (-(X1-t.phX1)/scX<shX1) shX1=-(X1-t.phX1)/scX;
								if ((X2-t.phX2)/scX<shX2) shX2=(X2-t.phX2)/scX;
								newmy=t.phY1;
								if (t.tileMaterial>0) stayMat=t.tileMaterial;
								if (t.phis>=1 && !(transT && t.phis==3)) 
								{
									stayPhis=1;
									if (t_throw>0 && dy>damWallSpeed && damWall) damageWall(3);
									if (destroy>0 || massa>=1) destroyWall(t,3);
								} 
								else if (t.shelf && stayPhis==0) 
								{
									stayPhis=2;
									stayMat=t.tileMaterial;
								}
								diagon=0;
							}
						}
					}
					if (newmy==0 && !throu) newmy=checkDiagon(dy/div);
					if (newmy==0 && !throu) newmy=checkShelf(dy/div, osndy/div);
					if (newmy) 
					{	// Bugs!!!!!
						Y1=newmy-scY;
						for (i=Math.floor(X1/Tile.tilePixelWidth); i<=Math.floor(X2/Tile.tilePixelWidth); i++) 
						{
							t=room.roomTileArray[i][Math.floor((newmy-scY)/Tile.tilePixelHeight)];
							if (collisionTile(t)) newmy=0;
						}
					}
					if (newmy) 
					{
						Y=newmy;
						Y1=Y-scY, Y2=Y;
						if (dy>16) makeNoise(noiseRun,true);
						else if (dy>9) makeNoise(noiseRun/2,true);
						if (dy>5) sndFall();
						if (jumpBall>0 && dy>3) {
							dy=-dy*jumpBall;
							turnY=-1;
						} 
						else 
						{
							dy=0;
							
						}
						stay=true;
						fracLevit=0;
		
						isLaz=0;
					} 
					else 
					{
						Y+=dy/div;
						Y1=Y-scY, Y2=Y;
					}
					if (Y>room.roomPixelHeight) 
					{
						if (!outLoc(3)) 
						{
							Y=room.roomPixelHeight-1;
							turnY=-1;
							Y1=Y-scY, Y2=Y;
						}
					}
				}
			}
			// Move up
			if (dy+osndy<0) 
			{
				if (dy<0) 
				{
					stay=false;
					diagon=0;
				}
				if (Y-scY<0) 
				{
					if (!outLoc(4)) 
					{
						Y=scY-0.1;
						dy=0;
						turnY=1;
					}
				}
				if (dy>0) 
				{
					newmy=checkShelf(dy/div, osndy/div);
					if (newmy) 
					{
						Y=newmy;
						Y1=Y-scY, Y2=Y;
						dy=0;
						stay=true;
					}
				} 
				else 
				{
					Y+=(dy+osndy)/div;
					Y1=Y-scY, Y2=Y;
				}
				if (mater) 
				{
					for (i=Math.floor(X1/Tile.tilePixelWidth); i<=Math.floor(X2/Tile.tilePixelWidth); i++) 
					{
						t=room.roomTileArray[i][Math.floor(Y1/Tile.tilePixelHeight)];
						if (collisionTile(t)) 
						{
							if (t_throw>0 && dy<-damWallSpeed && damWall) damageWall(4);
							if (destroy>0) destroyWall(t,4);
							Y=t.phY2+scY;
							Y1=Y-scY, Y2=Y;
							dy=0;
							turnY=1;
							if (t.tileMaterial==1) tykMat=1;
							stay=false;
						}
					}
				}
			} 
			if (autoSit)
			{
				autoSit=false;	
				unsit();
			}
		}
		
		public function run2(div:int=1):void
		{
			X+=dx/div;
			Y+=dy/div;
			if (X-scX/2<0) 
			{
				X=scX/2;
				dx=Math.abs(dx)*elast;
				turnX=1;
			}
			if (X+scX/2>=room.roomPixelWidth) 
			{
				X=room.roomPixelWidth-1-scX/2;
				dx=-Math.abs(dx)*elast;
				turnX=-1;
			}
			if (Y-scY<0) 
			{
				Y=scY-0.1;
				dy=0;
				turnY=1;
			}
			if (Y>room.roomPixelHeight) 
			{
				Y=room.roomPixelHeight-1;
				dy=0;
				turnY=-1;
			}
			X1=X-scX/2, X2=X+scX/2;
			Y1=Y-scY, Y2=Y;
		}
		
		public function sit(turn:Boolean):void
		{
			if (isSit==turn) return;
			isSit=turn;
			if (isSit) 
			{
				scX=sitX, scY=sitY;
			} 
			else 
			{
				scX=stayX, scY=stayY;
			}
			X1=X-scX/2, X2=X+scX/2,	Y1=Y-scY;
		}
		
		public function unsit():void
		{
			sit(false);
			if (collisionAll()) 
			{
				sit(true);
			}
		}
		
		public function collisionAll(gx:Number=0, gy:Number=0):Boolean 
		{
			if (room.sky) return false;
			for (var i=Math.floor((X1+gx)/Tile.tilePixelWidth); i<=Math.floor((X2+gx)/Tile.tilePixelWidth); i++) 
			{
				for (var j=Math.floor((Y1+gy)/Tile.tilePixelHeight); j<=Math.floor((Y2+gy)/Tile.tilePixelHeight); j++) 
				{
					if (i<0 || i>=room.roomWidth || j<0 || j>=room.roomHeight) continue;
					if (collisionTile(room.roomTileArray[i][j],gx,gy)) return true;
				}
			}
			return false;
		}
		
		public function collisionTile(t:Tile, gx:Number=0, gy:Number=0):int 
		{
			if (!t || (t.phis==0 || transT&&t.phis==3) && !t.shelf) return 0;  //пусто
			if (X2+gx<=t.phX1 || X1+gx>=t.phX2 || Y2+gy<=t.phY1 || Y1+gy>=t.phY2) 
			{
				return 0;
			} 
			else if ((t.phis==0 || transT&&t.phis==3) && t.shelf && (Y2-(stay?porog:porog_jump)>t.phY1 || throu || t_throw>0 || levit || isFly || diagon!=0))  //полка 
			{ 
				return 0;
			}
			else return 1;
		}

		// Search for stairs
		public function checkStairs(ny:int=-1, nx:int=0):Boolean 
		{
			try 
			{
				var i=Math.floor((X+nx)/Tile.tilePixelWidth);
				var j=Math.floor((Y+ny)/Tile.tilePixelHeight);
				if (j>=room.roomHeight) j=room.roomHeight-1;
				if (room.roomTileArray[i][j].phis>=1 && !(transT&&room.roomTileArray[i][j].phis==3)) 
				{
					isLaz=0;
					return false;
				}
				if ((room.roomTileArray[i][j] as Tile).stair) 
				{
					isLaz=storona=(room.roomTileArray[i][j] as Tile).stair;
					if (isLaz==-1) X=(room.roomTileArray[i][j] as Tile).phX1+scX/2;
					else X=(room.roomTileArray[i][j] as Tile).phX2-scX/2;
					X1=X-scX/2, X2=X+scX/2;
					stay=false;
					sit(false);
					return true;
				}
			} catch (err) {}
			isLaz=0;
			return false;
		}
		// Search for liquid
		public function checkWater():Boolean 
		{
			var pla=inWater;
			try {
				if ((room.roomTileArray[Math.floor(X/Tile.tilePixelWidth)][Math.floor((Y-scY*0.75)/Tile.tilePixelHeight)] as Tile).water>0) 
				{
					isPlav=true;
					inWater=true;
					if (plav) 
					{
						stay=false;
						sit(false);
					}
				} 
				else 
				{
					isPlav=false;
					if (scY<=Tile.tilePixelHeight) 
					{
						inWater=false;
					} 
					else if ((room.roomTileArray[Math.floor(X/Tile.tilePixelWidth)][Math.floor((Y-scY*0.25)/Tile.tilePixelHeight)] as Tile).water>0) 
					{
						inWater=true;
					} 
					else inWater=false;
				}
			} catch (err) 
			{
				isPlav=inWater=false;
			}
			if (pla!=inWater && (dy>8 || dy<-8 || plaKap)) 
			{
				Emitter.emit('kap',room,X,Y-scY*0.25+dy,{dy:-Math.abs(dy)*(Math.random()*0.3+0.3), kol:Math.floor(Math.abs(dy*massa*2)+1)});
				
			}
			if (pla!=inWater && dy>5) 
			{
				if (massa>2) sound('fall_water0', 0, dy/10);
				else if (massa>0.4) sound('fall_water1', 0, dy/10);
				else if (massa>0.2) sound('fall_water2', 0, dy/10);
				else sound('fall_item_water', 0, dy/10);
			}
			if (pla!=inWater && dy<-5 && massa>0.4) sound('fall_water2', 0, -dy/10);
			if (inWater && !isPlav && (dx>3 || dx<-3)) Emitter.emit('kap',room,X,Y-scY*0.25,{rx:scX});
			if (isPlav) 
			{
				namok_t++;
				if (namok_t>=100) 
				{
					namok_t=0;
					addEffect('namok');
				}
			} else if (namok_t>0) 
			{
				namok_t--
			}
			return isPlav;
		}

		// Search for an object to stand on
		public function checkShelf(pdy:Number, pdy2:Number = 0):Number 
		{
			for (var i in room.objs) 
			{
				var b:Box=room.objs[i] as Box;
				if (!b.invis && b.shelf && !b.levit && !(X2<b.X1 || X1>b.X2) && Y2 + pdy2 <= b.Y1 && Y2 + pdy + pdy2 > b.Y1) 
				{
					shX1=shX2=1;
					if (-(X1-b.X1)/scX<shX1) shX1=-(X1-b.X1)/scX;
					if ((X2-b.X2)/scX<shX2) shX2=(X2-b.X2)/scX;
					stayMat=b.mat;
					stayPhis=2;
					stayOsn=b;
					if (!b.stay) 
					{
						b.dy += dy * massa / (massa + b.massa);
						b.fixPlav = false;
					}
					return b.Y1;
				}
			}
			return 0;
		}
		
		// Search for steps
		public function checkDiagon(dy:Number, napr:int=0):Number 
		{
			var ddy:Number, newmy:Number=0;
			var t:Tile = room.getAbsTile(X, Y + dy);
			if (diagon==0) 
			{
				if (t.diagon!=0 && (napr==0 || t.diagon==napr)) 
				{
					ddy=t.getMaxY(X);
					if (ddy<Y+dy) 
					{
						diagon=t.diagon;
						newmy=ddy;
					}
				} 
				else 
				{
					t = room.getAbsTile(X, Y + 40);
					if (t.diagon != 0 && (napr == 0 || t.diagon == napr)) 
					{
						ddy=t.getMaxY(X);
						if (ddy<Y+dy) 
						{
							diagon = t.diagon;
							newmy = ddy;
						}
					}
				}
			} 
			else 
			{
				if (t.diagon!=0 && (napr == 0 || t.diagon==napr)) 
				{
					ddy = t.getMaxY(X);
					diagon = t.diagon;
					newmy = ddy;
				} 
				else 
				{
					t = room.getAbsTile(X, Y - 40);
					if (t.diagon !=0 && (napr == 0 || t.diagon==napr)) 
					{
						ddy=t.getMaxY(X);
						diagon=t.diagon;
						newmy=ddy;
					} 
					else diagon = 0;
				}
			}
			if (diagon != 0 && (napr == 0 || t.diagon==napr)) 
			{
				shX1 = 0;
				shX2 = 0;
				stayPhis = 2;
				stayMat = t.tileMaterial;
			}
			return newmy;
		}
		
		// Teleportation
		public function teleport(nx:Number,ny:Number,eff:int=0):void
		{
			if (eff > 0) Emitter.emit('tele', room, X, Y - scY / 2,{rx:scX, ry:scY, kol:30});
			setPos(nx, ny);
			if (currentWeapon) 
			{
				setWeaponPos(currentWeapon.tip);
				currentWeapon.setNull();
			}
			isLaz = 0;
			levit = 0;
			if (eff>0) Emitter.emit('teleport', room, X, Y - scY / 2);
		}
		
		// Detach from a fixed position
		public function otryv():void
		{
			fixed = false;
		}

//**************************************************************************************************************************
//
//				Visual Part
//
//**************************************************************************************************************************

		public static function initIcos():void
		{
			arrIcos=new Array();
			for each (var xml in XmlBook.getXML("units").unit) 
			{
				if (xml.@cat=='3') 
				{
					var bmpd:BitmapData;
					var ok:Boolean=false;
					if (xml.vis.length() && xml.vis.@blit.length()) 
					{

					} 
					else if (xml.vis.length() && xml.vis.@vclass.length()) 
					{
						var dvis:MovieClip=Res.getVis(xml.vis.@vclass);
						var sprX:int=dvis.width+2;
						var sprY:int=dvis.height+2;
						bmpd=new BitmapData(sprX,sprY,true,0x00000000);
						var m:Matrix=new Matrix();
						m.tx=-dvis.getRect(dvis).left;
						m.ty=-dvis.getRect(dvis).top;
						bmpd.draw(dvis,m);
						ok=true;
					}
					if (ok) 
					{
						var bmp:Bitmap=new Bitmap(bmpd);
						arrIcos[xml.@id]=bmp;
					}
				}
			}
		}
		
		public static function initIco(nid:String):void
		{
			if (arrIcos==null) arrIcos=new Array();
			if (arrIcos[nid]) return;
			var xml = XmlBook.getXML("units").unit.(@id == nid);
			if (xml.vis.length() && xml.vis.@blit.length()) 
			{
				var bmpd:BitmapData;
				var data:BitmapData=World.world.grafon.getSpriteList(xml.vis.@blit);
				if (data==null) return;
				var sprX:int=xml.vis.@sprX;
				var sprY:int=(xml.vis.@sprY>0)?xml.vis.@sprY:sprX;
				var begSprX:int=(xml.vis.@icoX>0)?xml.vis.@icoX:0;
				var begSprY:int=(xml.vis.@icoY>0)?xml.vis.@icoY:0;
				var rect:Rectangle = new Rectangle(begSprX*sprX, begSprY*sprY, (begSprX+1)*sprX, (begSprY+1)*sprY);
				bmpd=new BitmapData(sprX,sprY);
				bmpd.copyPixels(data,rect,new Point(0,0));
				var bmp:Bitmap=new Bitmap(bmpd);
				arrIcos[nid]=bmp;
			}
		}
		
		public function initBlit()
		{
			blitData=World.world.grafon.getSpriteList(blitId);
			blitRect = new Rectangle(0, 0, blitX, blitY);
			blitPoint = new Point(0,0);
			vis=new MovieClip();
			var osn=new Sprite();
			visData=new BitmapData(blitX,blitY,true,0);
			visBmp=new Bitmap(visData);
			vis.addChild(osn);
			osn.addChild(visBmp);
			if (blitDX>=0) visBmp.x=-blitDX;
			else visBmp.x=-blitX/2;
			if (blitDY>=0) visBmp.y=-blitDY;
			else visBmp.y=-blitY+10;
			animState='stay';
		}
		
		public function blit(blstate:int, blframe:int)
		{
			blitRect.x=blframe*blitX, blitRect.y=blstate*blitY;
			visData.copyPixels(blitData,blitRect,blitPoint);
		}
		
		public override function addVisual():void
		{
			if (disabled) return;
			trigDis=!checkTrig();
			if (trigDis) return;
			super.addVisual();
			if (!player && !hpbar && vis) 
			{
				hpbar = new hpBar();
				if (hero <= 0) hpbar.goldstar.visible = false;
				if (invis) hpbar.visible = false;
				visDetails();
			}
			if (hpbar && room && room.roomActive) World.world.grafon.canvasLayerArray[3].addChild(hpbar);
			if (cTransform && ctrans) vis.transform.colorTransform=cTransform;
			if (childObjs) {
				for (var i in childObjs) 
				{
					if (childObjs[i] != null && childObjs[i].vis) 
					{
						childObjs[i].addVisual();
					}
				}
			}
		}
		
		public override function remVisual():void
		{
			super.remVisual();
			if (hpbar && hpbar.parent) hpbar.parent.removeChild(hpbar);
			if (childObjs) 
			{
				for (var i in childObjs) 
				{
					if (childObjs[i]) childObjs[i].remVisual();
				}
			}
		}
		
		public function animate():void
		{

		}
		
		protected function sndFall():void
		{

		}
		
		public function sndRunPlay():void
		{
				if (rasst2 < sndRunDist * sndRunDist) 
				{
					sndVolkoef = (sndRunDist - Math.sqrt(rasst2)) / sndRunDist;
					if (sndVolkoef < 0.5) sndVolkoef *= 2;
					else sndVolkoef = 1;
					Snd.pshum(sndRun, sndVolkoef);
				}
		}
		
		public function newPart(nid:String, kol:int = 1, frame:int = 0):void
		{
			Emitter.emit(nid, room, X, Y - scY / 2,{kol:kol, frame:frame});
		}

		public function setVisPos():void
		{
			if (vis) 
			{
				vis.x = X;
				vis.y = Y;
				vis.scaleX = storona;
			}
		}

		public function visDetails():void
		{
			if (hpbar==null) return;
			if ((hp<maxhp || armor_qual>0 && armor_hp<armor_maxhp || hero>0) && hp>0 && !invis || boss) 
			{
				if (boss) 
				{
					World.world.gui.hpBarBoss(hp/maxhp);
					hpbar.visible=false;
				} 
				else 
				{
					hpbar.visible=true;
					if (hp<maxhp) 
					{
						hpbar.bar.visible=true;
						hpbar.bar.gotoAndStop(Math.floor((1-hp/maxhp)*20+1));
					} 
					else hpbar.bar.visible=false;
					if (armor_qual>0) 
					{
						hpbar.armor.visible=true;
						hpbar.armor.gotoAndStop(Math.floor((1-armor_hp/armor_maxhp)*20+1));
					} 
					else hpbar.armor.visible=false;
				}
			} 
			else hpbar.visible=false;
		}
		
		public function setHpbarPos():void
		{
			if (boss) 
			{
				hpbar.y=60;
				hpbar.x=World.world.cam.screenX/2;
			} 
			else 
			{
				hpbar.y=Y-stayY-20;
				if (hpbar.y<20) hpbar.y=20;
				hpbar.x=X;
				if (room && room.zoom!=1) hpbar.scaleX=hpbar.scaleY=room.zoom;
			}
		}
		
		
		public function sound(sid:String, msec:Number=0, vol:Number=1):SoundChannel 
		{
			return Snd.ps(sid,X,Y,msec,vol);
		}

//**************************************************************************************************************************
//
//				Actions
//
//**************************************************************************************************************************

		public function actions():void
		{
			if (isNaN(dx)) 
			{
				trace(objectName, 'dx!!!');
				dx=0;
			}
			if (isNaN(dy)) 
			{
				trace(objectName, 'dy!!!');
				dy=0;
			}
			if (neujaz>0) neujaz--;
			if (shok>0) shok--;
			if (oduplenie>0) 
			{
				if (opt && opt.izvrat && World.world.pers.socks || noAgro) {}
				else oduplenie--;
			}
			if (noise>0) noise-=20;
			if (noise_t>0) noise_t--;
			// Noise while walking
			if (stay && (dx>12|| dx<-12))  makeNoise(noiseRun);
			else if (stay && (dx>7 || dx<-7))  makeNoise(noiseRun/2);
			else if (stay && (dx>3 || dx<-3))  makeNoise(noiseRun/4);
			if (isFly && (dx>3 || dx<-3 || dy>3 || dy<-3))  makeNoise(noiseRun/2);
			
			// Eye position
			eyeX=X+scX*0.25*storona;
			eyeY=Y-scY*0.75;
			
			// Levitation
			if (sost==1) 
			{
				if (levit) 
				{
					levit_r++;
				} 
				else 
				{
					if (levit_r==1) levitPoss=true;
					if (levit_r>60) levit_r=60;
					if (levit_r>0) levit_r--;
				}
			}
			if (levit) 
			{
				if (!fixed && massa!=massaMove) otryv();
				if (fixed) 
				{
					if (levit_r>75) otryv();
				}
				massa=massaMove;
			}
			
			if (demask>0) demask-=5;
			if (effects.length > 0) 
			{
				for (var i=0; i<effects.length; i++) 
				{
					if (!(effects[i] as Effect).vse) (effects[i] as Effect).step();
					else 
					{
						effects.splice(i,1);
						i--;
					}
				}
			}
			
			// Damage from water
			// Periodic effects
			if (cut>0 || poison>0 || inWater && room.wdam>0) 
			{
				if (t_hp<=0) 
				{
					t_hp=30;
					if (cut>0) 
					{
						damage(Math.sqrt(cut),D_BLEED,null,true);
						cut-=critHeal;
						if (cut<0) cut=0;
					}
					if (poison>0) 
					{
						damage(Math.sqrt(poison),D_POISON,null,true);
						poison-=critHeal;
						if (poison<0) poison=0;
						Emitter.emit('poison',room,X,Y-scY*0.5);
					}
					if (inWater && room.wdam>0) 
					{
						damage(room.wdam,room.wtipdam,null,true);
					}
				}
			}
			if (stun>0) 
			{
				stun--;
				if (stun%10==0) 
				{
					//trace(stun)
					if (opt && opt.robot) 
					{
						Emitter.emit('discharge',room,X,Y-scY*0.5);
						Emitter.emit('iskr',room,X,Y-scY*0.5,{kol:5});
					} 
					else if (!mech) Emitter.emit('stun',room,X,Y-scY*0.75);
				}
			}
			if (t_hp>0) t_hp--;
			if (slow>0) 
			{
				slow--;
				if (!fixed && slow%10==0 && vis && vis.visible && (dx>3 || dx<-3 || dy>5 || dy<-5)) Emitter.emit('slow',room,X,Y-scY*0.25);
			}
			if (t_throw>0) t_throw--;
			// Accumulated display of damage numbers
			if (Settings.showHit==2) 
			{
				if (t_hitPart>0) 
				{
					t_hitPart--;
				} 
				else 
				{
					hitSumm=0;
					hitPart=null;
				}
			}
			if (t_mess>0) t_mess--;
		}
		
		public function makeNoise(n:int, hlup:Boolean=false):void
		{
			if (n<=0) return;
			if (noise<n) noise=n;
			if (noise_t==0 || hlup && noise_t<=20) 
			{
				noise_t=30;
				if (room && room.roomActive && !getTileVisi()) 
				{
					if (!player) Emitter.emit('noise',room,X,Y,{rx:40, ry:40, alpha:Math.min(1,n/500)});
				}
			}
		}
		
		
//--------------------------------------------------------------------------------------------------------------------
//				Attack

		// Attack the target with the unit's own damage using the body
		public function attKorp(cel:Unit, mult:Number=1):Boolean 
		{
			if (sost>1 || cel==null || cel.room!=room || burn!=null) return false;
			if (cel.X1>X2 || cel.X2<X1 || cel.Y1>Y2 || cel.Y2<Y1 || cel.neujaz>0) return false;
			return cel.udarUnit(this, mult);
		}
		// The hit reached the target
		public function crash(b:Bullet):void
		{
			if (b.weap) makeNoise(b.weap.noise, true);
		}
		// Set weapon position
		public function setWeaponPos(tip:int=0):void
		{
			weaponX=X;
			weaponY=Y-scY*0.5;
			magicX=X;
			magicY=Y-scY*0.5;
		}
		public function setPunchWeaponPos(w:WPunch):void
		{
			w.X=X+scX/3*storona;
			w.Y=Y-scY*0.75;
			w.rot=(storona>0)?0:Math.PI;
		}
		
		public function destroyWall(t:Tile, napr:int=0):Boolean 
		{
			if (isPlav || levit || sost!=1) return false;
			if (napr==3 && dy>15 && destroy<50 && massa>=1) 
			{
				room.hitTile(t,50,(t.X+0.5)*Tile.tilePixelWidth,(t.Y+0.5)*Tile.tilePixelHeight,100);
				if (t.phis==0) return true;
			}
			if (destroy>0 && (dx>10 && napr==2 || dx<-10 && napr==1 || dy<-10 && napr==4  || dy>10 && napr==3)) room.hitTile(t,destroy,(t.X+0.5)*Tile.tilePixelWidth,(t.Y+0.5)*Tile.tilePixelHeight,(napr==3?100:9));
			if (t.phis==0) return true;
			return false;
		}
		
		public function explosion(tdam:Number, ttipdam:int=4, trad:Number=200, tkol:int=0, totbros:Number=0, tdestroy:Number=0, tdecal:int=0):void
		{
			var bul:Bullet=new Bullet(this,X,Y-3,null,tkol>1);
			bul.weapId=id;
			bul.damageExpl=tdam;
			bul.tipDamage=ttipdam;
			bul.explKol=tkol;
			if (tkol>1) bul.explTip=2;
			else if (ttipdam==10) bul.explTip=3;
			bul.explRadius=trad;
			bul.tipDecal=tdecal;
			bul.otbros=totbros;
			bul.destroy=tdestroy;
			bul.explosion();
			bul.babah=true;
		}
		
		
//--------------------------------------------------------------------------------------------------------------------
//				Effects

		// Add an effect
		public function addEffect(id:String, val:Number=0, t:int=0, se:Boolean=true):Effect 
		{
			if (id==null || id=='') return null;
			var eff:Effect = new Effect(id, this, val);
			if (t>0) eff.t=t*Settings.fps;
			// Get a temporary effect
			for (var i in effects) 
			{
				if (eff.tip==3 && effects[i].tip==3) 
				{
					effects[i]=eff;
					eff.setEff();
					return eff;
				}
				if (effects[i].id==id || effects[i].id==eff.post) 
				{
					if (effects[i].val>eff.val) eff.val=effects[i].val;
					if (eff.add) 
					{
						eff.t+=effects[i].t;
						if (eff.t>30000) eff.t=30000;
						eff.checkT();
					}
					effects[i]=eff;
					eff.setEff();
					return eff;
				}
			}
			eff.se=se;
			effects.push(eff);
			if (player && se) World.world.gui.infoEffText(id);
			eff.setEff();
			return eff;
		}
		
		public function remEffect(id:String):void
		{
			for each(var eff in effects) 
			{
				if (eff!=null && eff.id==id) eff.unsetEff();
			}
		}
		
		public function setSkillParam(xml:XML, lvl1:int, lvl2:int=0):void
		{
			if (xml==null) return;
			for each(var sk in xml.sk) 
			{
				var val:Number, lvl:int;
				if (sk.@dop.length()) lvl=lvl2;
				else lvl=lvl1;
				if (sk.@vd.length()) val=Number(sk.@v0)+lvl*Number(sk.@vd);
				else if (sk.attribute('v'+lvl).length()) val=Number(sk.attribute('v'+lvl));
				else val=Number(sk.@v0);
				if (sk.@tip=='res') vulner[sk.@id]-=val;
				else if (hasOwnProperty(sk.@id)) 
				{
					if (sk.@ref=='add') this[sk.@id]+=val;
					else if (sk.@ref=='mult') this[sk.@id]*=val;
					else this[sk.@id]=val;
				}
			}
			
		}
		public function setEffParams():void
		{
			try 
			{
				tormoz=1;
				precMultCont=1;			
				rapidMultCont=1;
				if (begvulner==null) return;
				for (var i=0; i<kolVulners; i++) vulner[i]=begvulner[i];
				if (!player && room.biom==5) 
				{
					vulner[D_PINK]=0;	// Immune to the pink cloud
				}
				for each(var eff:Effect in effects) 
				{
					var effid=eff.id;
					var sk:XML = XmlBook.getXML("effects").eff.(@id == effid)[0];
					setSkillParam(sk, eff.vse?0:1);
				}
				setHeroVulners();
			} 
			catch (err) 
			{
				trace('Error in effects',objectName)
			}
		}
		
//--------------------------------------------------------------------------------------------------------------------
//				Damage Types
		
		/*D_BUL=0,      // Bullets      +
		D_BLADE=1,      // Blade        +
		D_PHIS=2,       // Blunt        +
		D_FIRE=3,       // Fire         *
		D_EXPL=4,       // Explosion    +
		D_LASER=5,      // Laser        *
		D_PLASMA=6,     // Plasma       *
		D_VENOM=7,      // Toxins
		D_EMP=8,        // EMP
		D_SPARK=9,      // Lightning    *
		D_ACID=10,      // Acid         *
		D_CRIO=11,      // Cold         *
		D_POISON=12,    // Poisoning
		D_BLEED=13,     // Bleeding
		D_FANG=14,      // Beasts       +
		D_BALE=15,      // Balefire
		D_NECRO=16,     // Necro
		D_PSY=17,       // Psi
		D_ASTRO=18,     // Cosmic
		D_INSIDE=100;   // ???*/


		// Get damage
		public function damage(dam:Number, tip:int, bul:Bullet=null, tt:Boolean=false):Number 
		{
			if (invulner) return 0;
			if (sost==1) dieWeap=null;
			if (tip<kolVulners) dam*=vulner[tip];			// Vulnerabilities
			//var damageNumb:Part;
			var isCrit:int=0;
			var isShow:Boolean=false;
			if (bul) 
			{					// Critical damage
				// Damage specific types
				if (bul.owner && bul.owner.player && opt) 
				{
					if (opt.pony) dam*=(bul.owner as UnitPlayer).pers.damPony;
					if (opt.zombie) dam*=(bul.owner as UnitPlayer).pers.damZombie;
					if (opt.robot) dam*=(bul.owner as UnitPlayer).pers.damRobot;
					if (opt.insect) dam*=(bul.owner as UnitPlayer).pers.damInsect;
					if (opt.monster) dam*=(bul.owner as UnitPlayer).pers.damMonster;
					if (opt.alicorn) dam*=(bul.owner as UnitPlayer).pers.damAlicorn;
				}
				
			}
			if (dam==0) return 0;
			// Reduce electrical damage
			if (tip==D_SPARK) 
			{
				if (!stay && !inWater && isLaz==0) dam*=0.5;
			}
			// Poison damage only affects living units
			if (tip==D_VENOM && sost!=1) 
			{
				return 0;
			}
			var mess:String;
			// Damage to armor
			if (!player && armor_hp>0 && (shithp<=0 || dam>shitArmor) && (armor>0 || marmor>0) && (tip<=D_BALE && tip!=D_EMP && tip!=D_POISON && tip!=D_BLEED || tip==D_ASTRO)) 
			{
				var damarm=dam;
				if (shithp>0) damarm-=shitArmor;
				if (bul && bul.armorMult>1) damarm/=bul.armorMult;
				if (tip==D_ACID) damarm*=4;
				else if (tip==D_EXPL) damarm*=2;
				armor_hp-=damarm;
				if (armor_hp<=0) 	// Armor destruction
				{
					armor_hp=0;
					armor_qual=0;
					mess=Res.txt('g', 'abr');
				}
			}

			if (dam<0) 
			{
				heal(-dam);
				return 0;
			}
			var armor2=0;		// Armor and armor penetration
			if (!tt) 
			{
				if (tip==D_BUL || tip==D_BLADE || tip==D_EXPL || tip==D_PHIS || tip==D_FANG || tip==D_ACID) 
				{
					armor2=skin;
					if (armor_qual>0 && isrnd(armor_qual)) armor2+=armor;
				}
				if (tip==D_FIRE || tip==D_LASER || tip==D_PLASMA || tip==D_SPARK || tip==D_CRIO || tip==D_ASTRO) 
				{
					armor2=skin;
					if (armor_qual>0 && isrnd(armor_qual)) armor2+=marmor;
				}
				if (shithp>0) 
				{
					shithp-=dam;
					if (shithp<0) shithp=0;
					armor2+=shitArmor;
				}
				if (bul) 
				{
					armor2*=bul.armorMult;
					armor2-=bul.pier;
				}
				if (armor2>0) 
				{
					dam-=armor2;
					if (bul && bul.probiv>0) 	// If the bullet is armor-piercing, subtract armor value from damage
					{
						bul.damage-=armor2/bul.probiv;
					}
				}
			}
			if (bul) 	// Critical damage
			{
				if (Math.random()<bul.critCh) 
				{
					dam*=bul.critDamMult;
					isCrit=1;
				}
				if (!doop && celUnit!=bul.owner && bul.critInvis>0) 
				{
					if (Math.random()<bul.critInvis) 
					{
						dam*=2;
						isCrit+=2;
					}
				}
			}
			if (dam>0) 
			{
				var sposob: int = 0;		// Method of dying
				if (bul && bul.desintegr && (tip==D_LASER || tip==D_PLASMA)) 	// Instant disintegration
				{
					if (hp<=dam*10 && isrnd(bul.desintegr)) 
					{
						sposob=1;
						dam*=12;
					}
				}
				if (tip!=D_POISON && tip!=D_BLEED && tip!=D_INSIDE) dam*=allVulnerMult;
				isShow=((sost==1 || sost==2) && showNumbs && dam>0.5);
				if (bul && bul.probiv>0) 
				{
					if (maxhp>dam*20) bul.damage=0;
					else if (maxhp>dam) bul.damage*=bul.probiv;
					else bul.damage*=1-(1-bul.probiv)*maxhp/dam;
				}
				hp-=dam;
				var nshok=Math.round((Math.random()*0.8+0.2)*maxShok*4*dam/maxhp);
				if (nshok>maxShok) nshok=maxShok;
				if (tt || nshok<5) nshok=0;
				if (shok<nshok) shok=nshok;
				if (hp<=0) 
				{
					if (bul && bul.weap) dieWeap=bul.weap.id;
					if (bul && bul.weapId) dieWeap=bul.weapId;
					if (tip==D_FIRE && (hp<=-maxhp*3 || !trup)) sposob=1;
					if (tip==D_LASER && (hp<=-maxhp*3 || !trup || isrnd())) sposob=1;
					if (tip==D_PLASMA || tip==D_ACID) sposob=2;
					if (tip==D_ASTRO || tip==D_FRIEND) sposob=3;
					if (tip==D_CRIO) sposob=4;
					if (timerDie<=0) die(sposob);
					else sost=2;
				}
				// Electric and EMP damage stun robots
				if ((tip==D_SPARK || tip==D_EMP) && opt && opt.robot && sost==1 && Math.random()<dam/maxhp) 
				{
					mess=Res.txt('g', 'kz');
					if (stun<robotKZ) stun=robotKZ;
				}
				// Explosions cause concussion
				if (tip==D_EXPL && opt && !opt.robot && !mech && !doop && sost==1 && Math.random()<dam/maxhp) 
				{
					mess=Res.txt('e','contusion');
					addEffect('contusion');
				}
				if (!tt && demask<200) demask=200;	// An invisible object becomes visible when taking damage
				// Additional effects
				if (bul && bul.weap) 
				{								
					if (bul.weap.dopEffect!=null && bul.weap.dopCh>0 && (bul.weap.dopCh>=1 || Math.random()<bul.weap.dopCh)) 
					{
						if (bul.weap.dopEffect=='igni' && vulner[D_FIRE]>0.1) 
						{
							addEffect('burning',bul.weap.dopDamage);
							mess=Res.txt('e','burning');
						}
						if (bul.weap.dopEffect=='ice' && vulner[D_CRIO]>0.1 && !mech) 
						{
							mess=Res.txt('e','freezing');
							addEffect('freezing');
						}
						if (bul.weap.dopEffect=='blind' && vulner[D_LASER]>0.1 && !mech && !doop) 
						{
							mess=Res.txt('e','blindness');
							addEffect('blindness');
						}
						if (bul.weap.dopEffect=='acid' && vulner[D_ACID]>0.1) 
						{
							mess=Res.txt('e','chemburn');
							addEffect('chemburn',bul.weap.dopDamage);
						}
						if (bul.weap.dopEffect=='pink' && vulner[D_PINK]>0.1) 
						{
							mess=Res.txt('e','pinkcloud');
							addEffect('pinkcloud',bul.weap.dopDamage);
						}
						if (bul.weap.dopEffect=='poison' && vulner[D_POISON]>0.1) 
						{
							if (player && poison<=0) World.world.gui.infoText('poison');
							poison+=bul.weap.dopDamage;
						}
						if (bul.weap.dopEffect=='cut' && vulner[D_BLEED]>0.1 && !mech) 
						{
							if (player && cut<=0) World.world.gui.infoText('cut');
							cut+=bul.weap.dopDamage;
						}
						if (bul.weap.dopEffect=='stun') 
						{
							if (!mech && opt && !opt.robot && Math.random()<dam/maxhp && sost==1) 
							{
								stun=bul.weap.dopDamage;
								//trace(stun);
								if (player && stun<=0) World.world.gui.infoText('stun');
								if (stun>1) mess=Res.txt('g', 'stun');
							}
						}
					}
					if (bul.weap.ammoFire) 
					{
						addEffect('burning',bul.weap.ammoFire);
						mess=Res.txt('e','burning');
					}
				}
				// Return damage to the owner of the bullet
				if (bul && bul.owner && bul.owner.relat>0) 
				{
					bul.owner.damage(dam*bul.owner.relat, D_INSIDE);
				}
				if (tip==D_INSIDE && dam<5) isShow=false;
				if (blood>0 && (tip==D_BUL || tip==D_BLADE || tip==D_PHIS || tip==D_BLEED || tip==D_FANG)) 	//кровь
				{
					if (bloodEmit==null) 
					{
						if (blood==1) bloodEmit=Emitter.arr['blood'];
						if (blood==2) bloodEmit=Emitter.arr['gblood'];
						if (blood==3) bloodEmit=Emitter.arr['pblood'];
					}
					if (!(player && Settings.alicorn)) 
					{
						if (bul) 
						{
							bloodEmit.cast(room,bul.X,bul.Y,{dx:bul.dx/bul.vel*5, dy:bul.dy/bul.vel*5,kol:Math.floor(Math.random()*5+dam/5)});
						} 
						else 
						{
							bloodEmit.cast(room,X,Y-scY/2,{kol:Math.floor(dam/3)});
						}
						if (blood==1 && tip!=D_BLEED && massa>0.2) 
						{
							var ver=Math.random();
							if (tip==D_BLADE) ver=ver*ver;
							if (isCrit>0) ver*=0.3;
							if (dam/1000>ver) 
							{
								var st:int=1;
								if (bul && bul.dx<0) st=-1;
								if (bul==null && Math.random()<0.5) st=-1;
								Emitter.emit('bloodexpl'+Math.floor(Math.random()*3+1),room,X+80*st+(Math.random()-0.5)*scX*0.5,Y-Math.random()*scY*0.5-40,{mirr:(st<0?1:0)});
							}
						}
					}
				}
				if (mat==10 && bul) 
				{
					Emitter.emit('pole2',room,bul.X,bul.Y);
				}
				if (isShow) // Show damage
				{
					var vnumb:int=1;
					var castX:Number = X;
					var castY:Number = Y - scY / 2;
					if (bul) {castX=bul.X; castY=bul.Y;}
					if (player || isCrit>=2) vnumb=2;
					if (tt) vnumb=3;
					if (player && tt && tip==D_PINK) vnumb=11;
					if (Settings.showHit==1 || tt) 
					{
						visDamDY-=15;
						numbEmit.cast(room,castX,castY+visDamDY,{txt:Math.round(dam).toString(), frame:vnumb, rx:40, scale:((isCrit==1 || isCrit==3)?1.6:1)});
					} 
					else if (Settings.showHit==2) 
					{
						hitSumm+=dam;
						if (hitPart==null) 
						{
							hitPart=numbEmit.cast(room,castX,castY+visDamDY,{txt:Math.round(dam).toString(), frame:vnumb, rx:40, scale:((isCrit==1 || isCrit==3)?1.6:1)});
						} 
						else
						{
							if (isCrit==1 || isCrit==3) 
							{
								hitPart.vis.scaleX=hitPart.vis.scaleY=1.6/World.world.cam.scaleV;
							}
							hitPart.vis.numb.text=Math.round(hitSumm);
							hitPart.liv=60;
						}
						t_hitPart=10;
					}
				}
				if (hp>0 && !player && isrnd()) replic('dam');
			} 
			else if (Settings.showHit==2) t_hitPart=10
			visDetails();
			if (Settings.showHit>=1 && t_mess<=0) 
			{
				if (hp>0 && mess) 
				{
					numbEmit.cast(room,X,Y-scY/2,{txt:mess, frame:5, rx:20, ry:20});
					t_mess=45;
				}
			}
			if (!tt) alarma();
			return dam;
		}
		
		// Hit the wall: 1 - right, 2 - left, 3 - bottom, 4 - top
		public function damageWall(napr:int=0):void
		{
			t_throw=0;
			if (damWall>0) 
			{
				var dam=Math.sqrt(dx*dx+dy*dy)/damWallSpeed*damWall;
				damage(dam,D_PHIS);
				if (Math.random()<dam/maxhp) stun=damWallStun;
				if (napr>0) 
				{
					var nx:Number = X;
					var ny:Number = Y - scY / 2;
					if (napr==1) nx = X + scX / 2;
					if (napr==2) nx = X - scX / 2;
					if (napr==3) ny = Y;
					if (napr==4) ny = Y - scY;
					Emitter.emit('bum',room,nx,ny);//,{scale:dam/damWall}
					Snd.ps('hit_flesh',X,Y);
				}
			}
		}
		
		public function heal(hl:Number, tip:int=0, ismess:Boolean=true):void
		{
			if (hp==maxhp) return;
			if (hl>maxhp-hp) 
			{
				hl=maxhp-hp;
				hp=maxhp;
			} 
			else 
			{
				hp+=hl;
			}
			visDetails();
			if (Settings.showHit>=1) 
			{
				if ((sost==1 || sost==2) && showNumbs && hl>0.5) numbEmit.cast(room,X,Y-scY/2,{txt:('+'+Math.round(hl)), frame:4, rx:20, ry:20});
			}
		}
		
		public function dopTest(bul:Bullet):Boolean 
		{
			return true;
		}
		
		// Check for bullet hit, apply damage if the bullet hit, return -1 if it missed
		public override function udarBullet(bul:Bullet, sposob:int=0):int 
		{
			var acc:Number=bul.accuracy();
			if ((bul.miss<=0 || Math.random()>bul.miss) && (dexter<=0 || bul.precision<=0 && bul.tipBullet==0 || bul.tipBullet==0 && Math.random()<acc/(dexter+dexterPlus+0.05) || bul.tipBullet==1 && dodge<1 && (dodge<=0 || Math.random()>dodge))) 
			{
				//trace('попал',bul.precision/bul.dist);
				var dm=0;
				if (transp && (vulner[bul.tipDamage]<=0 || invulner)) 
				{
					return -1;
				} 
				else if (bul.damage>0) 
				{
					if (retDamage && bul.retDam && bul.owner)  //возврат урона
					{
						bul.owner.udarUnit(this);
					}
					dm=bul.damage*(Math.random()*0.6+0.7);
					if (Settings.testDam) dm=bul.damage;
					dm=damage(dm, bul.tipDamage, bul);
					otbros(bul);
					if (bul.owner && bul.owner.fraction!=0) priorUnit=bul.owner;
					if (!invulner && dm<=0 || mat==1) return 1;
					else if (mat==12) return 12;
					else return 10;
				} 
				else return 0;
			} 
			else 
			{
				if (Settings.showHit==1 || Settings.showHit==2 && t_hitPart==0) 
				{
					visDamDY-=15;
					t_hitPart=10;
					if (sost<3 && isVis && !invulner && bul.flame==0) numbEmit.cast(room,X,Y-scY/2+visDamDY,{txt:txtMiss, frame:10, rx:40, alpha:0.5});
				}
				return -1;
			}
		}
		// Unit-to-unit attack
		public function udarUnit(un:Unit, mult:Number=1):Boolean 
		{
			if (neujaz>0) return false;
			neujaz=neujazMax;
			if (dodge-un.undodge>0 && isrnd(dodge-un.undodge)) 
			{
				if (Settings.showHit>=1)	numbEmit.cast(room,X,Y-scY/2,{txt:txtMiss, frame:10, rx:20, ry:20, alpha:0.5});
				return false;
			}
			var sila=Math.random()*0.4+0.8;
			if (un.collisionTip==1) 
			{
				var ndx=(un.dx*un.massa+dx*massa)/(un.massa+massa);
				var ndy=(un.dy*un.massa+dy*massa)/(un.massa+massa);
				dx=(-dx+ndx)*knocked+ndx, dy=(-dy+ndy)*knocked+ndy;
				un.dx=(-un.dx+ndx)*un.knocked+ndx, un.dy=(-un.dy+ndy)*un.knocked+ndy;
			}
			if (un.currentWeapon && un.currentWeapon.tip==1) 
			{
				damage((un.currentWeapon.damage*0.5+un.dam)*sila*mult, un.currentWeapon.tipDamage)
			} 
			else 
			{
				damage((un.dam)*sila*mult, un.tipDamage);
			}
			var sc:Number=(un.dam*sila*mult) / 20;
			if (sc<0.5) sc=0.5;
			if (sc>3) sc=3;
			if (un.tipDamage == Unit.D_SPARK) 
			{
				Emitter.emit('moln',room,X,Y-scY/2,{celx:un.X, cely:(un.Y-un.scY/2)});
				Snd.ps('electro',X,Y);
			} 
			else if (un.tipDamage == Unit.D_ACID) 
			{
				Emitter.emit('buma',room,(X+un.X)/2,(Y-scY/2+un.Y-un.scY/2)/2,{scale:sc});
				Snd.ps('acid',X,Y);
			} 
			else if (un.tipDamage == Unit.D_NECRO) 
			{
				Emitter.emit('bumn',room,(X+un.X)/2,(Y-scY/2+un.Y-un.scY/2)/2,{scale:sc});
				Snd.ps('hit_necr',X,Y);
			} 
			else if (un.tipDamage == Unit.D_FANG) 
			{
				Emitter.emit('bum',room,(X+un.X)/2,(Y-scY/2+un.Y-un.scY/2)/2,{scale:sc});
				Snd.ps('fang_hit',X,Y);
			} 
			else 
			{
				Emitter.emit('bum',room,(X+un.X)/2,(Y-scY/2+un.Y-un.scY/2)/2,{scale:sc});
				Snd.ps('hit_flesh',X,Y);
			}
			priorUnit=un;
			return true;
		}
		// Impact by a falling object
		public function udarBox(un:Box):int 
		{
			if (neujaz>0 || noBox || un.room!=room) return 0;
			if (un.molnDam>0) 
			{
				damage(un.molnDam, D_SPARK);
				return 1;
			}
			neujaz=neujazMax;
			if (!fixed) 
			{
				var ndx=(un.dx*un.massa+dx*massa)/(un.massa+massa);
				var ndy=(un.dy*un.massa+dy*massa)/(un.massa+massa);
				dx=(-dx+ndx)*knocked+ndx, dy=(-dy+ndy)*knocked+ndy;
				un.dx=(-un.dx+ndx)*0.25+ndx, un.dy=(-un.dy+ndy)*0.25+ndy;
			} 
			else 
			{
				un.dx*=0.5;
				un.dy*=0.5;
			}
			damage(un.massa*(un.vel2-50)*Settings.boxDamage, D_PHIS);
			priorUnit=null;
			return 2;
		}
		// Bullet recoil effect
		public function otbros(bul:Bullet):void
		{
			if (invulner) return;
			var sila=Math.random()*0.4+0.8;
			sila*=knocked/massa;
			if (sila>3) sila=3;
			dx+=bul.knockx*bul.otbros*sila;
			dy+=bul.knocky*bul.otbros*sila;
			if (bul.explRadius>0) 
			{

			}
		}
		
		// Activation from passive mode
		public function alarma(nx:Number=-1,ny:Number=-1):void
		{
			oduplenie = 0;
			if (nx>0 && ny>0 && celUnit == null) 
			{
				setCel(null,nx,ny);
			}
		}
		// Awaken everyone around
		public function budilo(rad:Number=500):void
		{
			makeNoise(noiseRun * 1.2);
			//trace('budilo');
			for each(var un:Unit in room.units) 
			{
				if (un && un != this && un.fraction == fraction && un.sost == 1 && !un.unres) 
				{
					var nx = un.X - X;
					var ny = un.Y - Y;
					if (opt && opt.robot && un.opt && un.opt.robot)
					{
						if (nx * nx + ny * ny < rad * rad) un.alarma(celX, celY);
					} 
					else 
					{
						//trace(un.ear);
						if (nx * nx + ny * ny < rad * rad * un.ear * un.ear) un.alarma(X + (Math.random() - 0.5) * 250, Y + (Math.random() - 0.5) * 250);
					}
				}
			}
		}
		// Deactivation (for security systems)
		public function hack(sposob:int = 0):void
		{

		}
		
		
//--------------------------------------------------------------------------------------------------------------------
//				Death
		
		public override function die(sposob:int = 0):void
		{
			if (hpbar) hpbar.visible=false;
			if (boss) 
			{
				World.world.gui.hpBarBoss();
				if (sndMusic) Snd.combatMusic(sndMusic, sndMusicPrior, 90);
			}
			if (sposob==0 && sost==1 && sndDie) sound(sndDie);
			if (noDestr) // Don't remove after death
			{			
				sost=3;
			} 
			else if (sposob>0) 	// Killed by an exotic method
			{
				isFly=false;
				initBurn(sposob);
				dexter=100;
				fraction=0;
				throu=false;
				sost=3;
			} 
			else if (trup && hp>-maxhp*2) 	// Leave a corpse that is not completely destroyed
			{
				replic('die');
				isFly=false;
				scX=sitX, scY=sitY;
				X1=X-scX/2, X2=X+scX/2,	Y1=Y-scY;
				fraction=0;
				throu=false;
				porog=0;
				sost=3;
			} 
			else if (trup && blood>0) 		// There is blood
			{
				if (burn==null) sound('trup');
				initBurn(4+blood);
				isFly=false;
				fraction = 0;
				throu = false;
				porog = 0;
				sost = 3;
			} 
			else if (burn==null) 			// Destroy
			{
				if (trup && blood>0) sound('trup');
				expl();
				exterminate();
			}
			shithp = 0;
			walk = 0;
			elast = 0;
			isLaz = 0;
			stun = 0;
			transT = true;
			sndRunOn = false;
			plaKap = false;
			if (!doop && World.world.t_battle>30) World.world.t_battle=30;
			if (!lootIsDrop && (!isRes || sost==4 || burn)) 
			{
				lootIsDrop=true;
				if (mother) mother.kolChild--;
				if (hero>0) World.world.gui.infoText('killHero',objectName);
				runScript();
				dropLoot();
				incStat();
				if (xp>0) 
				{
					room.takeXP(xp,X,Y,true);
					xp=0;
				}
				if (room.prob) room.prob.check();
				if (opt && opt.hbonus) 
				{
					room.createHealBonus(X, Y-scY/2);
				}
			}
		}
		
		// Destroy, remove from the world
		public function exterminate():void
		{
			radioactiv=0;
			levitPoss=false;
			if (sost!=4) room.remObj(this);
			sost=4;
			disabled=true;
		}
		
		// Explosion, guts, or other effect after death
		public function expl():void
		{
			if (blood) 
			{
				if (bloodEmit==null) 
				{
					if (blood == 1) bloodEmit=Emitter.arr['blood'];
					if (blood == 2) bloodEmit=Emitter.arr['gblood'];
					if (blood == 3) bloodEmit=Emitter.arr['pblood'];
				}
				bloodEmit.cast(room,X,Y,{kol:massa*50, rx:scX/2, ry:scY/2});
			}
		}
		// Called in any case at the moment of death, only once!
		public function dropLoot():void
		{
			if (inter) inter.loot();
			if (hero>0 && !(opt.robot==true) && isrnd(0.75)) LootGen.lootId(room,X,Y-scY/2,'essence');
			// Dropping a precious gem
			if (World.world.pers && World.world.pers.dropTre>0 && xp>0) 
			{
				if (Math.random()<World.world.pers.dropTre*xp/4000) LootGen.lootId(room,X,Y-scY/2,'gem'+Math.floor(Math.random()*3+1));
			}
		}
		
		public function initBurn(sposob:int):void
		{
			if (burn!=null) return;
			remVisual();
			burn=new Desintegr(this,sposob);
			childObjs=[];
			addVisual();
			
			levitPoss=false;
			
			setVisPos();
		}

		public function runScript():void
		{
			if (scrDie) scrDie.start();
			if (questId) 
			{
				if (room.level.itemScripts[questId]) room.level.itemScripts[questId].start();
				World.world.game.incQuests(questId);
			}
			if (wave && room.prob) room.prob.checkWave(true);
			// Perform an action like destroying a certain number of enemies with a specific weapon
			if (dieWeap!=null && World.world.game.triggers['look_'+dieWeap]>0 && xp>0) 
			{
				World.world.game.incQuests('kill_'+dieWeap);
			}
		}

		// Modify statistics
		public function incStat(sposob:int=0):void
		{
			if (World.world.game) 
			{
				if (World.world.game.triggers['frag_'+id]>0) World.world.game.triggers['frag_'+id]++;
				else World.world.game.triggers['frag_'+id]=1;
			}
		}
		
//--------------------------------------------------------------------------------------------------------------------
//				Service functions for AI

		// Ability to interact with a unit
		public function isMeet(un:Unit):Boolean 
		{
			return un != null && room == un.room && !un.disabled && !un.trigDis && un.sost != 4 && un != this;
		}
		// Determines if a unit doesn't obstruct line of sight, returns true if it doesn't
		public function getTileVisi(r:Number=0.3):Boolean 
		{
			return (room.getAbsTile(X, Y - scY / 2).visi > r);
		}
		
		// Listen to another unit
		public function listen(ncel:Unit):Number 
		{
			var noi=ncel.noise*ear*room.earMult;	// Radius of sound audibility
			if (noi<=0) return 0;
			var r2:Number;		// Distance to the object squared
			if (ncel.player) r2=rasst2;
			else 
			{
				var nx=ncel.X-X;
				var ny=ncel.Y-ncel.scY/2-Y+scY/2;
				r2=nx*nx+ny*ny;
			}
			if (noi*noi>r2) return (1-r2/(noi*noi))*4;
			return 0;
		}

		// Look at another unit
		// Parameters: 
		// ncel - target unit
		// over - look around in all directions
		// visParam - parameter for determining visibility range, defaults to vision
		// nDist - object visibility distance, defaults to calculated value
		// Returns the value by which the hero's obs is increased
		public function look(ncel:Unit, over:Boolean=true, visParam:Number=0, nDist:Number=0):Number 
		{
			if (ncel==null || nDist<=0 && visParam<=0 && vision<=0) return 0;
			var cx=(ncel.X - eyeX);
			var cy=(ncel.Y - ncel.scY * 0.6 - eyeY);
			if (eyeX == -1000 || eyeY == -1000) 
			{
				eyeX = X;
				eyeY = Y - 30;
				//trace('Point of view not set', objectName);
			}
			// Visibility distance
			var distVis = nDist;		// take from parameter
			if (nDist <= 0) distVis = (ncel.visibility * ncel.stealthMult * room.visMult + ncel.demask) * (visParam ? visParam:vision);	//или вычислить
			// if there's no vision behind, and the object is above or below 45 degrees, reduce the distance
			if (vKonus == 0 && !over && cy * cy > cx * cx && cy > 0) 
			{
				distVis *= (0.5 + 0.5 * Math.abs(cx / cy));
			}
			// if the distance is greater than the visibility distance, return 0
			var r2:Number = cx * cx + cy * cy;
			if (r2 > distVis * distVis * 16) return 0;
			// if there's no vision behind, and the object is behind, return 0
			if (vKonus == 0 && !over && cx * storona < 0 && r2 > detecting * detecting) return 0;
			// vision cone
			if (vKonus > 0) 
			{
				var ug:Number = Math.atan2(cy, cx);
				var dug:Number = vAngle - ug;
				if (dug >  Math.PI) dug -= Math.PI * 2;
				if (dug < -Math.PI) dug += Math.PI * 2;
				if (Math.abs(dug) > vKonus / 2) return 0;
			}
			
			// Check the line of sight
			var div:Number = Math.floor(Math.max(Math.abs(cx),Math.abs(cy))/Settings.maxdelta)+1;
			for (var i:Number = (mater ? 1:4); i < div; i++) 
			{
				var nx:Number =X+scX*0.25*storona+cx*i/div;
				var ny:Number =Y-scY*0.75+cy*i/div;
				var t:Tile=World.world.room.getTile(Math.floor(nx/Tile.tilePixelWidth),Math.floor(ny/Tile.tilePixelHeight));
				if (t.phis==1 && nx>=t.phX1 && nx<=t.phX2 && ny>=t.phY1 && ny<=t.phY2) 
				{
					return 0;
				}
			}
			if (r2 < ncel.detecting * ncel.detecting) return 20;
			if (r2 < distVis * distVis) return 4;
			return (distVis * distVis) / r2 * 4;
		}
		// Get a target for AI
		public function findCel(over:Boolean=false):Boolean 
		{
			if (oduplenie>0) return false;
			var ncel:Unit;
			if (priorUnit && isMeet(priorUnit) && priorUnit.fraction!=fraction && priorUnit.sost<3 && priorUnit.hp>-priorUnit.maxhp && (!priorUnit.doop || priorUnit.levit)) ncel=priorUnit;
			else if (isMeet(room.gg) && !room.gg.invulner && fraction!=F_PLAYER) ncel=room.gg;
			else return false;
			if (ncel.player) 
			{
				var res1:Number=listen(ncel);
				if (res1) {
					(ncel as UnitPlayer).observation(res1);
				}
				var res2:Number=look(ncel,overLook || over);
				if (res2>0) {
					(ncel as UnitPlayer).observation(res2,observ);
					if ((ncel as UnitPlayer).obs>=(ncel as UnitPlayer).maxObs) 
					{
						setCel(ncel);
						return true;
					}
				} else if (res1>0){
					if ((ncel as UnitPlayer).obs>=(ncel as UnitPlayer).maxObs) 
					{
						setCel(null,ncel.X+(Math.random()-0.5)*200, ncel.Y+(Math.random()-0.5)*200);
					}
					if (res1>1) return true;
				}
			} 
			else 
			{
				if (look(ncel, overLook || over) > 0.5) 
				{
					setCel(ncel);
					return true;
				}
			}
			celUnit = null;
			priorUnit = null;
			return false;
		}
		// Set a target to a unit or a point
		public function setCel(un:Unit = null, cx:Number = -10000, cy:Number = -10000):void
		{
			if (un && isMeet(un)) 
			{
				celX=un.X+un.scX/4*un.storona, celY=un.Y-un.scY/2;
				celUnit=un;
				if (un.player) {
					World.world.t_battle=Settings.battleNoOut;
					World.world.cur();
					room.detecting=true;
					if (sndMusic && !room.postMusic) Snd.combatMusic(sndMusic, sndMusicPrior, boss?10000:150);
				}
			} 
			else if (cx>-10000 && cy>-10000) 
			{
				celX=cx, celY=cy;
				celUnit=null;
			} 
			else 
			{
				celX=X, celY=Y-scY/2;
				celUnit=null;
			}
			celDX=celX-X;
			celDY=celY-Y+scY;
		}
		
		public function findGrenades():Boolean 
		{
			for (var i=0; i<10; i++) 
			{
				if (room.grenades[i]==null) continue;
				var gx:Number=room.grenades[i].X-X;
				var gy:Number=room.grenades[i].Y-Y+scY/2;
				if (gx*gx+gy*gy<400*400) 	//граната есть
				{
					if (room.isLine(X,Y-scY*0.75,room.grenades[i].X, room.grenades[i].Y)) 
					{
						acelX=room.grenades[i].X;
						acelY=room.grenades[i].Y;
						return true;
					}
				}
			}
			return false;
		}
		
		public function findLevit():Boolean
		{
			if (isMeet(room.gg) && room.gg.teleObj) 
			{
				var gx:Number=room.gg.teleObj.X-X;
				if (!overLook && gx*storona<0) return false;
				var gy:Number=room.gg.teleObj.Y-room.gg.teleObj.scY/2-Y+scY/2;
				if (gx*gx+gy*gy<vision*vision*1000*1000 && room.isLine(X,Y-scY*0.75,room.gg.teleObj.X, room.gg.teleObj.Y-room.gg.teleObj.scY/2)) return true;
			}
			return false;
		}
		
		public override function command(com:String, val:String=null):void
		{
			super.command(com,val);
			if (com=='activate') 
			{
				gamePause=false;
				disabled=false;
				setNull(true);
				addVisual();
				Emitter.emit('tele',room,X,Y-scY/2,{rx:scX, ry:scY, kol:30});
			}
			if (com=='fraction') 
			{
				fraction=int(val);
				if (fraction==F_PLAYER) warn=0;
				else warn=1;
			}
			//trace(com,val);
		}
		
//--------------------------------------------------------------------------------------------------------------------
//				Conversations

		public function replic(s:String):void
		{
			//trace(id,s);
			if (sost!=1 || id_replic=='' || !room.roomActive) return;
			var s_replic:String;
			if (s=='dam') 
			{
				if (isrnd(0.05)) t_replic=0;
			} 
			if (s=='die') 
			{
				if (isrnd()) t_replic=0;
			} 
			if (t_replic<=0) 
			{
				if (s=='attack') 
				{
					t_replic=50+Math.random()*100;
				} 
				else 
				{
					t_replic=110+Math.random()*150;
				}
				s_replic=Res.repText(id_replic, s, msex);
				if (s_replic!='' && s_replic!=null) 
				{
					Emitter.emit('replic',room,X,Y-110,{txt:s_replic, ry:50});
				}
			}
		}
		
		
//--------------------------------------------------------------------------------------------------------------------
//				Random
		protected function isrnd(n:Number=0.5):Boolean 
		{
			return Math.random()<n;
		}
		
		
	}
	
}
