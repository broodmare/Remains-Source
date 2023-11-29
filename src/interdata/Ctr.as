package interdata 
{
	
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.display.StageDisplayState;
	
	import components.Settings;
	
	public class Ctr 
	{
		
		public var restrictedKeys:Array = 
		[
			Keyboard.CONTROL, 
			Keyboard.ESCAPE, 
			Keyboard.TAB, 
			Keyboard.CAPS_LOCK, 
			Keyboard.DELETE, 
			Keyboard.END, 
			Keyboard.HOME, 
			Keyboard.INSERT
		];


		public var keyXML:XML =
		<keys>
			<key id = 'keyLeft' 	def = {Keyboard.A}/>
			<key id = 'keyRight' 	def = {Keyboard.D}/>
			<key id = 'keyBeUp' 	def = {Keyboard.W}/>
			<key id = 'keySit' 		def = {Keyboard.S}/>
			<key id = 'keyJump' 	def = {Keyboard.SPACE}/>
			<key id = 'keyRun' 		def = {Keyboard.SHIFT}/>
			<key id = 'keyDash'/> 
 			  
  			<key id = 'keyAttack' 	def = 'lmb'/>
			<key id = 'keyPunch' 	def = {Keyboard.F}/>
			<key id = 'keyReload' 	def = {Keyboard.R}/>
			<key id = 'keyGrenad' 	def = {Keyboard.G}/>
			<key id = 'keyMagic' 	def = {Keyboard.T}/>
			<key id = 'keyDef' 		def = {Keyboard.C}/>
			<key id = 'keyPet' 		def = {Keyboard.U}/>
			<key id = 'keyAction' 	def = {Keyboard.E}/>
			<key id = 'keyCrack' 	def = {Keyboard.Y}/>
			<key id = 'keyTele' 	def = {Keyboard.Q} alt = 'rmb'/>
			<key id = 'keyPip' 		def = {Keyboard.TAB}/>
			<key id = 'keyArmor' 	def = {Keyboard.N}/>
			<key id = 'keySats' 	def = {Keyboard.V} alt = 'mmb'/>
  
  			<key id = 'keyInvent' 	def = {Keyboard.I}/>
			<key id = 'keyStatus' 	def = {Keyboard.O}/>
			<key id = 'keySkills' 	def = {Keyboard.K}/>
			<key id = 'keyMed' 		def = {Keyboard.L}/>
			<key id = 'keyMap' 		def = {Keyboard.M}/>
			<key id = 'keyQuest' 	def = {Keyboard.J}/>
			<key id = 'keyItem' 	def = {Keyboard.P}/>
			<key id = 'keyPot'		def = {Keyboard.H}/>
			<key id = 'keyMana' 	def = {Keyboard.B}/>
			<key id = 'keyItemNext' def = {Keyboard.RIGHTBRACKET}/>
			<key id = 'keyItemPrev' def = {Keyboard.LEFTBRACKET}/>
			<key id = 'keyScrDown' 	def = 'scrd'/>
			<key id = 'keyScrUp' 	def = 'scru'/>
			<key id = 'keyWeapon1' 	def = {Keyboard.NUMBER_1}/>
			<key id = 'keyWeapon2' 	def = {Keyboard.NUMBER_2}/>
			<key id = 'keyWeapon3' 	def = {Keyboard.NUMBER_3}/>
			<key id = 'keyWeapon4' 	def = {Keyboard.NUMBER_4}/>
			<key id = 'keyWeapon5' 	def = {Keyboard.NUMBER_5}/>
			<key id = 'keyWeapon6' 	def = {Keyboard.NUMBER_6}/>
			<key id = 'keyWeapon7' 	def = {Keyboard.NUMBER_7}/>
			<key id = 'keyWeapon8' 	def = {Keyboard.NUMBER_8}/>
			<key id = 'keyWeapon9' 	def = {Keyboard.NUMBER_9}/>
			<key id = 'keyWeapon10' def = {Keyboard.NUMBER_0}/>
			<key id = 'keyWeapon11' def = {Keyboard.MINUS}/>
			<key id = 'keyWeapon12' def = {Keyboard.EQUAL}/>
			<key id = 'keySpell1' 	def = {Keyboard.Z}/>
			<key id = 'keySpell2' 	def = {Keyboard.X}/>
			<key id = 'keySpell3'/>
			<key id = 'keySpell4'/>
			 
 			<key id = 'keyLook' 	def = {Keyboard.SEMICOLON}/>
			<key id = 'keyZoom' 	def = {Keyboard.QUOTE}/>
			<key id = 'keyFull' 	def = {Keyboard.ENTER}/>
		</keys>;
		

		public var keyDowns:Vector.<Boolean>;	// Key Press States
		public var keyNames:Vector.<String>;	// Key Names by Codes
		public var mbNames:Array;				// Mouse Button Names
		public var keys:Array;					// Objects by Key Codes
		public var keyObj:Array;				// Objects in Order
		public var keyIds:Array;				// Objects by Action ID

		public var keyStates:Object =
		{
		keyLeft		: false,
		keyRight	: false,
		keyDubLeft	: false,
		keyDubRight	: false,
		keyJump		: false,
		keySit		: false,
		keyDubSit	: false,
		keyBeUp		: false,
		keyRun		: false,
		keyAttack	: false,
		keyPunch	: false,
		keyReload	: false,
		keyGrenad	: false,
		keyMagic	: false,
		keyDef		: false,
		keyPet		: false,
		keyAction	: false,
		keyCrack	: false,
		keyTele		: false,
		keyPip		: false,
		keySats		: false,
		keyFly		: false,
		keyLook		: false,
		keyZoom		: false,
		keyFull		: false,
		keyItem		: false,
		keyPot		: false,
		keyMana		: false,
		keyItemPrev	: false,
		keyItemNext	: false,
		keyInvent	: false,
		keyStatus	: false,
		keySkills	: false,
		keyMed		: false,
		keyMap		: false,
		keyQuest	: false,
		keyWeapon1 	: false,
		keyWeapon2 	: false,
		keyWeapon3 	: false,
		keyWeapon4 	: false,
		keyWeapon5 	: false,
		keyWeapon6 	: false,
		keyWeapon7 	: false,
		keyWeapon8 	: false,
		keyWeapon9 	: false,
		keyWeapon10	: false,
		keyWeapon11	: false,
		keyWeapon12	: false,
		keyScrDown	: false, 
		keyScrUp	: false,
		rbmDbl		: false,
		keyDash		: false, 
		keyArmor	: false,
		keySpell1	: false, 
		keySpell2	: false, 
		keySpell3	: false, 
		keySpell4	: false,
		keyTest1	: false,
		keyTest2 	: false
		};

		public var keyboardMode:int = 0;
		
		//set private
		private const dubleT:int = 5;		
		private var kR_t:int = 10, kL_t:int = 10, kD_t:int = 10, scr_t:int = 0;
		
		public var active:Boolean = true;
		
		//set private
		private var KeyboardA = Keyboard.A, KeyboardZ = Keyboard.Z, KeyboardW = Keyboard.W, KeyboardQ = Keyboard.Q;
		
		
		public var setkeyOn:Boolean 	= false;
		public var setkeyRequest		= null;
		
		//set private
		private var setkeyFun:Function;
		
		public var keyPressed:Boolean	= false;
		public var keyPressed2:Boolean	= false;
		
		public function clearAll():void
		{
			    for (var key:String in keyStates) 
				{
					keyStates[key] = false;
				}
		}
		
		public function setKeyboard():void
		{
			if (keyboardMode == 0) 
			{
				KeyboardA = Keyboard.A;
				KeyboardZ = Keyboard.Z;
				KeyboardW = Keyboard.W;
				KeyboardQ = Keyboard.Q;
			}
			if (keyboardMode == 1) 
			{
				KeyboardA = Keyboard.Q;
				KeyboardZ = Keyboard.W;
				KeyboardW = Keyboard.Z;
				KeyboardQ = Keyboard.A;
			}
		}
		
		public function Ctr(loadObj = null):void
		{
			trace('Ctr.as/Ctr - Ctr() Controller initializing.');

			trace('Ctr.as/Ctr - Ctr() Naming keys...');
			keyNames 	= new Vector.<String>(256);
			keyDowns 	= new Vector.<Boolean>(256);
			mbNames 	= [];

			for (var i = Keyboard.A; i <= Keyboard.Z; i++) 
			{
				keyNames[i] = String.fromCharCode(65 + i - Keyboard.A);
			}

			for (i = Keyboard.NUMBER_0; i <= Keyboard.NUMBER_9; i++) 
			{
				keyNames[i] = (i - Keyboard.NUMBER_0).toString();
			}

			for (i = Keyboard.NUMPAD_0; i <= Keyboard.NUMPAD_9; i++) 
			{
				keyNames[i] = 'Numpad ' + (i - Keyboard.NUMPAD_0);
			}

			for (i = Keyboard.F1; i <= Keyboard.F12; i++) 
			{
				keyNames[i] = 'F' + (i-Keyboard.F1 + 1);
			}

			keyNames[Keyboard.UP]			= 'up';
			keyNames[Keyboard.DOWN]			= 'down';
			keyNames[Keyboard.LEFT]			= 'left';
			keyNames[Keyboard.RIGHT]		= 'right';
			keyNames[Keyboard.SPACE]		= "Spacebar";
 
			keyNames[Keyboard.END]			= 'End';
			keyNames[Keyboard.INSERT]		= 'Insert';
			keyNames[Keyboard.HOME]			= 'Home';
			keyNames[Keyboard.DELETE]		= 'Delete';
			keyNames[Keyboard.PAGE_DOWN]	= 'Page Down';
			keyNames[Keyboard.PAGE_UP]		= 'Page Up';
 
			keyNames[Keyboard.ENTER]		= 'Enter';
			keyNames[Keyboard.ESCAPE]		= 'Esc';
			keyNames[Keyboard.BACKSPACE]	= 'Backspace';
			keyNames[Keyboard.CAPS_LOCK]	= 'Caps Lock';
			keyNames[Keyboard.CONTROL]		= 'Ctrl';
			keyNames[Keyboard.SHIFT]		= "Shift";
			keyNames[Keyboard.ALTERNATE]	= 'Alt';
			keyNames[Keyboard.TAB]			= "Tab";
 
			keyNames[Keyboard.COMMA]		= ',';
			keyNames[Keyboard.MINUS]		= '-';
			keyNames[Keyboard.EQUAL]		= '=';
			keyNames[Keyboard.SLASH]		= '/';
			keyNames[Keyboard.QUOTE]		= "'";
			keyNames[Keyboard.SEMICOLON]	= ";";
			keyNames[Keyboard.PERIOD]		= ".";
			keyNames[Keyboard.BACKQUOTE]	= '`';
			keyNames[Keyboard.BACKSLASH]	= '\\';
			keyNames[Keyboard.LEFTBRACKET]	= "{";
			keyNames[Keyboard.RIGHTBRACKET]	= "}";
			
			keyNames[Keyboard.NUMPAD_ADD]		= "Numpad +";
			keyNames[Keyboard.NUMPAD_DECIMAL]	= "Numpad .";
			keyNames[Keyboard.NUMPAD_DIVIDE]	= "Numpad /";
			keyNames[Keyboard.NUMPAD_MULTIPLY]	= "Numpad *";
			keyNames[Keyboard.NUMPAD_SUBTRACT]	= "Numpad -";
			keyNames[Keyboard.NUMPAD_ENTER]		= "Numpad Enter";
			
			mbNames['lmb']	= Res.txt('k', 'lmb');
			mbNames['rmb']	= Res.txt('k', 'rmb');
			mbNames['mmb']	= Res.txt('k', 'mmb');
			mbNames['scrd']	= Res.txt('k', 'scrd');
			mbNames['scru']	= Res.txt('k', 'scru');
			
			gotoDef();
			if (loadObj) load(loadObj);
			updateKeys();
			
			trace('Ctr.as/Ctr - Ctr() Adding listeners to world.swfStage.');
			if (World.world.swfStage == null)
			{
				trace('Ctr.as/Ctr - Ctr() world.swfStage. is null!');
			}
			World.world.swfStage.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN,	onMiddleMouseDown1);
			World.world.swfStage.addEventListener(MouseEvent.MIDDLE_MOUSE_UP,	onMiddleMouseUp1);
			World.world.swfStage.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN,	onRightMouseDown1);
			World.world.swfStage.addEventListener(MouseEvent.RIGHT_MOUSE_UP,	onRightMouseUp1);
			World.world.swfStage.addEventListener(MouseEvent.RIGHT_CLICK, 		onRightMouse);
			World.world.swfStage.addEventListener(MouseEvent.MOUSE_DOWN,		onMouseDown1);
			World.world.swfStage.addEventListener(MouseEvent.MOUSE_UP,			onMouseUp1);
			World.world.swfStage.addEventListener(MouseEvent.MOUSE_MOVE, 		onMouseMove1);
			World.world.swfStage.addEventListener(MouseEvent.MOUSE_WHEEL,		onMouseWheel1);
			World.world.swfStage.addEventListener(KeyboardEvent.KEY_DOWN,		onKeyboardDownEvent);
			World.world.swfStage.addEventListener(KeyboardEvent.KEY_UP,			onKeyboardUpEvent);


			trace('Ctr.as/Ctr - Ctr() Controller finished setup.');
		}
		
		public function step():void
		{
			if (kR_t  < 100) kR_t++;
			if (kL_t  < 100) kL_t++;
			if (kD_t  < 100) kD_t++;
			if (scr_t > 0) 
			{
				scr_t--;
				if (scr_t == 0) 
				{
					if (keys['scrd']) this[keys['scrd'].id] = false;
					if (keys['scru']) this[keys['scru'].id] = false;
				}
			}
		}
		
		// Create associations between action objects and keys
		public function updateKeys():void
		{
			trace('Ctr.as/Ctr - updateKeys() executing ...');
			keys = new Array();
			for each(var obj in keyObj) 
			{
				if (obj.a1) keys[obj.a1] = obj;
				if (obj.a2) keys[obj.a2] = obj;
			}
		}
		
		// Default settings
		public function gotoDef():void
		{
			trace('Ctr.as/Ctr - gotoDef() executing...');
			keyObj = new Array();
			keyIds = new Array();
			for (var i in keyXML.key) 
			{
				var obj:Object = {id:keyXML.key[i].@id};
				if (keyXML.key[i].@def.length()) obj.a1 = keyXML.key[i].@def.toString();
				if (keyXML.key[i].@alt.length()) obj.a2 = keyXML.key[i].@alt.toString();
				keyObj.push(obj);
				keyIds[keyXML.key[i].@id] = obj;
			}
		}
		
		public function save():* 
		{
			var arr:Array = new Array();
			for (var i in keyIds) 
			{
				arr[i] = {a1:keyIds[i].a1, a2:keyIds[i].a2};
			}
			return arr;
		}
		
		public function load(arr:Array):void
		{
			for (var i in arr) 
			{
				if (keyIds[i]) 
				{
					checkKey(arr[i].a1);
					checkKey(arr[i].a2);
					if (keyIds[i].a1 != Keyboard.TAB) keyIds[i].a1 = arr[i].a1;
					keyIds[i].a2 = arr[i].a2;
				}
			}
		}
		
		public function checkKey(a:String):void
		{
			if (a == null) return;
			for (var k in keyIds) 
			{
				if (keyIds[k]) 
				{
					if (keyIds[k].a1 == a) keyIds[k].a1 = null;
					if (keyIds[k].a2 == a) keyIds[k].a2 = null;
				}
			}
		}
		
		// Return the visible key name by action code
		public function retKey(id):String
		{
			if (keyIds[id] == null) 
			{
				return '?'
			}

			var key = keyIds[id].a1;

			if (key == null) 
			{
				key = keyIds[id].a2;
			}

			if (key == null) 
			{
				return '???';
			}

			if (key > 0 && key < 256) 
			{
				return "[" + keyNames[key] + "]";
			}
			else 
			{
				return "[" + mbNames[key] + "]";
			}
		}
		
		public function permissKey(key:uint):Boolean 
		{

			//indexOf returns the first matched value in an array or -1. If a match is found, it will return something other than -1.
			//This satisfies the 'if' condition and returns false.
			if (restrictedKeys.indexOf(key) != -1) 
			{
				return false;
			}
			else
			{
				return true;
			}
			
		}
		
		// Send a request to change the key, execute the fun function upon completion
		public function requestKey(fun:Function = null):void
		{
			setkeyOn		= true;
			setkeyRequest	= null;
			setkeyFun		= fun;
		}
		
		// Request completed
		public function requestOk(nkey):void
		{
			setkeyOn		= false;
			setkeyRequest	= nkey;
			if (setkeyFun) 	setkeyFun();
		}

		public function onMouseMove1(event:MouseEvent):void 
		{
			World.world.cam.celX = event.stageX;
			World.world.cam.celY = event.stageY;
			if (World.world.gui) 
			{
				if (event.stageY < 100 && event.stageX > World.world.swfStage.stageWidth - 400) World.world.gui.infoAlpha = 0.2;
				else World.world.gui.infoAlpha = 1;
				
				World.world.gui.showDop = Settings.showFavs && (event.stageY > World.world.swfStage.stageHeight - 15);
			}
		}
		public function onMouseDown1(event:MouseEvent):void 
		{
			if (World.world.onConsol) return;
			if (World.world.clickReq == 1) 
			{
				World.world.clickReq = 2;
				return;
			}
			keyPressed = true;
			if (setkeyOn) 
			{
				requestOk('lmb');
				event.stopPropagation();
				return;
			}

			if (!active) 
			{
				active = true;
			} 
			else 
			{
				if (keys['lmb']) this[keys['lmb'].id] = true;
			}
		}
		public function onMouseUp1(event:MouseEvent):void 
		{
			if (keys['lmb']) this[keys['lmb'].id] = false;
		}
		private function onRightMouse(event:MouseEvent):void 
		{
            // Disable the menu
        }
		public function onRightMouseDown1(event:MouseEvent):void 
		{
			if (World.world.onConsol) return;
			keyPressed 	= true;
			keyPressed2 = true;
			if (setkeyOn) 
			{
				requestOk('rmb');
				return;
			}
			if (keys['rmb']) this[keys['rmb'].id] = true;
		}
		public function onRightMouseUp1(event:MouseEvent):void 
		{
			if (keys['rmb']) this[keys['rmb'].id] = false;
		}
		public function onMiddleMouseDown1(event:MouseEvent):void 
		{
			if (World.world.onConsol) return;
			if (setkeyOn) 
			{
				requestOk('mmb');
				return;
			}
			if (keys['mmb']) this[keys['mmb'].id] = true;
		}
		public function onMiddleMouseUp1(event:MouseEvent):void 
		{
			if (keys['mmb']) this[keys['mmb'].id] = false;
		}
		public function onMouseWheel1(event:MouseEvent):void 
		{
			if (World.world.onConsol) return;
			if (setkeyOn) 
			{
				if (event.delta < 0) requestOk('scrd');
				if (event.delta > 0) requestOk('scru');
				return;
			}
			try 
			{
				if (World.world.gui.inform.visible && World.world.gui.inform.scText.visible) 
				{
					World.world.gui.inform.txt.scrollV -= event.delta;
					event.stopPropagation();
					return;
				}
			}
			catch(err) 
			{

			}
			if (event.delta < 0 && keys['scrd']) this[keys['scrd'].id] = true;
			if (event.delta > 0 && keys['scru']) this[keys['scru'].id] = true;
			scr_t = 3;
			event.stopPropagation();
		}
		
		public function onKeyboardDownEvent(event:KeyboardEvent):void 
		{
			if (setkeyOn) 
			{
				if (permissKey(event.keyCode)) requestOk(event.keyCode);
				else if (event.keyCode==Keyboard.DELETE) requestOk(null);
				else if (event.keyCode==Keyboard.TAB || event.keyCode==Keyboard.ESCAPE) requestOk(-1);
				return;
			}
			if (!World.world.onConsol) 
			{
				if (event.keyCode < 256 && !keyDowns[event.keyCode]) 
				{
					if (keys[event.keyCode]) 
					{
						this[keys[event.keyCode].id] = true;
						if (keys[event.keyCode].id == 'keyLeft'  && kL_t < dubleT) keyStates.keyDubLeft  = true;
						if (keys[event.keyCode].id == 'keyRight' && kR_t < dubleT) keyStates.keyDubRight = true;
						if (keys[event.keyCode].id == 'keySit' 	 && kD_t < dubleT) keyStates.keyDubSit   = true;
					}
				}
				if (event.keyCode < 256) keyDowns[event.keyCode] = true;
				if (World.world.pip && World.world.pip.reqKey) 
				{
					for (var i:int = 1; i <= 12; i++) 
					{
						if (this['keyWeapon' + i]) 
						{
							this['keyWeapon' + i] = false;
							World.world.pip.assignKey(i+(keyStates.keyRun ? 12 : 0));
						}
					}
					//Changed 'i' to 'j'.
					for (var j:int = 1; j <= 4; j++) 
					{
						if (this['keySpell' + j]) 
						{
							this['keySpell' + j] = false;
							World.world.pip.assignKey(24 + j);
						}
					}
					if (keyStates.keyGrenad) 
					{
						keyStates.keyGrenad = false;
						World.world.pip.assignKey(29);
					}
					if (keyStates.keyMagic) 
					{
						keyStates.keyMagic = false;
						World.world.pip.assignKey(30);
					}
				}
			}
			if (event.keyCode == Keyboard.END) 
			{
				World.world.consolOnOff()
			}
			if (Settings.chitOn && event.keyCode == Keyboard.HOME) 
			{
				keyStates.keyTest1 = true;
			}
			if (event.keyCode == Keyboard.DELETE && Settings.testMode)
			{
				World.world.onPause =! World.world.onPause;
			}
			if (event.keyCode == Keyboard.INSERT) 
			{
				World.world.redrawLoc();
			}
			if (event.keyCode == Keyboard.BACKQUOTE) keyStates.keyFly = true;
			if (Settings.chitOn) 
			{
				if (event.keyCode == Keyboard.INSERT) keyStates.keyTest2 = true;
			}
			if (keyStates.keyFull) // Only works in the event handler
			{
				if (!World.world.onConsol) World.world.swfStage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
				keyStates.keyFull = false;
			}
		}
		
		public function onKeyboardUpEvent(event:KeyboardEvent):void 
		{
			if (event.keyCode < 256) keyDowns[event.keyCode] = false;
			if (keys[event.keyCode]) 
			{
				this[keys[event.keyCode].id] = false;

				if (keys[event.keyCode].id	== 'keyLeft') 	kL_t = 0;
				if (keys[event.keyCode].id	== 'keyRight') 	kR_t = 0;
				if (keys[event.keyCode].id	== 'keySit') 	kD_t = 0;
			}
		}
	}
	
}
