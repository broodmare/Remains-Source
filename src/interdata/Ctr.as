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

		//TODO: load this dynamically.
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
		public var keyStates = {};				// All actionable keybinds and their state.

		public var mbNames:Array;				// Mouse Button Names

		public var keys:Array;					// Objects by Key Codes
		public var keyObj:Array;				// Objects in Order
		public var keyIds:Array;				// Objects by Action ID
		public var keyboardMode:int = 0;

		//set private
		private const dubleT:int = 5;		
		private var kR_t:int = 10;
		private var kL_t:int = 10;
		private var kD_t:int = 10;
		private var scr_t:int = 0;

		public var active:Boolean = true;

		//set private
		//uints (according to the compiler)
		private var keyboardA = Keyboard.A;
		private var keyboardZ = Keyboard.Z;
		private var keyboardW = Keyboard.W;
		private var keyboardQ = Keyboard.Q;
		

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
				keyboardA = Keyboard.A;
				keyboardZ = Keyboard.Z;
				keyboardW = Keyboard.W;
				keyboardQ = Keyboard.Q;
			}
			if (keyboardMode == 1) 
			{
				keyboardA = Keyboard.Q;
				keyboardZ = Keyboard.W;
				keyboardW = Keyboard.Z;
				keyboardQ = Keyboard.A;
			}
		}
		
		public function Ctr(loadObj = null):void
		{
			trace('Ctr.as/Ctr - Ctr() Controller initializing.');
			keyStates = KeyStates.createKeyStatesObject(keyStates);

			trace('Ctr.as/Ctr - Ctr() Naming keys...');
			keyNames = new Vector.<String>(256);
			keyDowns = new Vector.<Boolean>(256);

			mbNames = [];

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
			
			mbNames['lmb']	= Res.txt('key', 'lmb');
			mbNames['rmb']	= Res.txt('key', 'rmb');
			mbNames['mmb']	= Res.txt('key', 'mmb');
			mbNames['scrd']	= Res.txt('key', 'scrd');
			mbNames['scru']	= Res.txt('key', 'scru');
			
			gotoDef();
			if (loadObj) load(loadObj);
			updateKeys();
			
			trace('Ctr.as/Ctr - Ctr() Adding listeners to currentSession.swfStage.');
			if (GameSession.currentSession.swfStage == null)
			{
				trace('Ctr.as/Ctr - Ctr() currentSession.swfStage. is null!');
			}

			GameSession.currentSession.swfStage.addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, onMiddleMouseDown1);
			GameSession.currentSession.swfStage.addEventListener(MouseEvent.MIDDLE_MOUSE_UP, onMiddleMouseUp1);
			GameSession.currentSession.swfStage.addEventListener(MouseEvent.RIGHT_MOUSE_DOWN, onRightMouseDown1);
			GameSession.currentSession.swfStage.addEventListener(MouseEvent.RIGHT_MOUSE_UP, onRightMouseUp1);
			GameSession.currentSession.swfStage.addEventListener(MouseEvent.RIGHT_CLICK, onRightMouse);
			GameSession.currentSession.swfStage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown1);
			GameSession.currentSession.swfStage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp1);
			GameSession.currentSession.swfStage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove1);
			GameSession.currentSession.swfStage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel1);
			GameSession.currentSession.swfStage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyboardDownEvent);
			GameSession.currentSession.swfStage.addEventListener(KeyboardEvent.KEY_UP, onKeyboardUpEvent);


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
					if (keys['scrd']) keyStates[keys['scrd'].id] = false;
					if (keys['scru']) keyStates[keys['scru'].id] = false;
				}
			}
		}
		
		// Create associations between action objects and keys
		public function updateKeys():void
		{
			trace('Ctr.as/Ctr - updateKeys() executing ...');
			keys = [];
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
			keyObj = [];
			keyIds = [];
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
			var arr:Array = [];
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
		
		// Check Key-Pair from keyXML dictionary and try to return formatted keyCode as a string.
		public function retKey(id):String
		{
			var key:Object = keyIds[id]; 
			if (!key) 
			{
				trace('Ctr.as/retKey() - ERROR: invalid (Dictionary) key');
				return '?';
			}
			var keyPair:int = key.a1 || key.a2;
			if (!keyPair) 
			{
				trace('Ctr.as/retKey() - ERROR: No return found for key: "' + key + '".');
				return '???';
			}

			return "[" + (keyNames[keyPair] || mbNames[keyPair]) + "]";
		}
		
		public function permissKey(key:uint):Boolean 
		{

			//indexOf returns the first matched value in an array or -1. If a match is found, it will return something other than -1.
			//This satisfies the 'if' condition and returns false.
			return restrictedKeys.indexOf(key) == -1;
			
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
			GameSession.currentSession.cam.celX = event.stageX;
			GameSession.currentSession.cam.celY = event.stageY;
			if (GameSession.currentSession.gui) 
			{
				if (event.stageY < 100 && event.stageX > GameSession.currentSession.swfStage.stageWidth - 400) GameSession.currentSession.gui.infoAlpha = 0.2;
				else GameSession.currentSession.gui.infoAlpha = 1;
				
				GameSession.currentSession.gui.showDop = Settings.showFavs && (event.stageY > GameSession.currentSession.swfStage.stageHeight - 15);
			}
		}
		
		public function onMouseDown1(event:MouseEvent):void 
		{
			if (GameSession.currentSession.onConsol) return;
			if (GameSession.currentSession.clickReq == 1) 
			{
				GameSession.currentSession.clickReq = 2;
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
				if (keys['lmb']) 
				{
					keyStates[keys['lmb'].id] = true;
				}
			}
		}

		public function onMouseUp1(event:MouseEvent):void 
		{
			if (keys['lmb']) 
			{
				keyStates[keys['lmb'].id] = false;
			}
		}

		private function onRightMouse(event:MouseEvent):void 
		{
            // Disable the menu
        }

		public function onRightMouseDown1(event:MouseEvent):void 
		{
			if (GameSession.currentSession.onConsol) return;
			keyPressed 	= true;
			keyPressed2 = true;
			if (setkeyOn) 
			{
				requestOk('rmb');
				return;
			}
			if (keys['rmb']) 
			{
				keyStates[keys['rmb'].id] = true;
			}
		}

		public function onRightMouseUp1(event:MouseEvent):void 
		{
			if (keys['rmb']) 
			{
				keyStates[keys['rmb'].id] = false;
			}
		}

		public function onMiddleMouseDown1(event:MouseEvent):void 
		{
			if (GameSession.currentSession.onConsol) return;
			if (setkeyOn) 
			{
				requestOk('mmb');
				return;
			}
			if (keys['mmb']) 
			{
				keyStates[keys['mmb'].id] = true;
			}
		}

		public function onMiddleMouseUp1(event:MouseEvent):void 
		{
			if (keys['mmb']) 
			{
				keyStates[keys['mmb'].id] = false;
			}
		}

		public function onMouseWheel1(event:MouseEvent):void 
		{
			if (GameSession.currentSession.onConsol) return;
			if (setkeyOn) 
			{
				if (event.delta < 0) requestOk('scrd');
				if (event.delta > 0) requestOk('scru');
				return;
			}
			try 
			{
				if (GameSession.currentSession.gui.inform.visible && GameSession.currentSession.gui.inform.scText.visible) 
				{
					GameSession.currentSession.gui.inform.txt.scrollV -= event.delta;
					event.stopPropagation();
					return;
				}
			}
			catch(err) 
			{

			}
			if (event.delta < 0 && keys['scrd']) 
			{
				keyStates[keys['scrd'].id] = true;
			}
			if (event.delta > 0 && keys['scru']) 
			{
				keyStates[keys['scru'].id] = true;
			}
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
			if (!GameSession.currentSession.onConsol) 
			{
				if (event.keyCode < 256 && !keyDowns[event.keyCode]) 
				{
					if (keys[event.keyCode]) 
					{
						keyStates[keys[event.keyCode].id] = true;
						if (keys[event.keyCode].id == 'keyLeft'  && kL_t < dubleT) keyStates.keyDubLeft  = true;
						if (keys[event.keyCode].id == 'keyRight' && kR_t < dubleT) keyStates.keyDubRight = true;
						if (keys[event.keyCode].id == 'keySit' 	 && kD_t < dubleT) keyStates.keyDubSit   = true;
					}
				}
				if (event.keyCode < 256) keyDowns[event.keyCode] = true;
				if (GameSession.currentSession.pip && GameSession.currentSession.pip.reqKey) 
				{
					for (var i:int = 1; i <= 12; i++) 
					{
						if (keyStates['keyWeapon' + i]) 
						{
							keyStates['keyWeapon' + i] = false;
							GameSession.currentSession.pip.assignKey(i+(keyStates.keyRun ? 12 : 0));
						}
					}
					//Changed 'i' to 'j'.
					for (var j:int = 1; j <= 4; j++) 
					{
						if (keyStates['keySpell' + j]) 
						{
							keyStates['keySpell' + j] = false;
							GameSession.currentSession.pip.assignKey(24 + j);
						}
					}
					if (keyStates.keyGrenad) 
					{
						keyStates.keyGrenad = false;
						GameSession.currentSession.pip.assignKey(29);
					}
					if (keyStates.keyMagic) 
					{
						keyStates.keyMagic = false;
						GameSession.currentSession.pip.assignKey(30);
					}
				}
			}
			if (event.keyCode == Keyboard.END) 
			{
				GameSession.currentSession.consolOnOff()
			}
			if (Settings.chitOn && event.keyCode == Keyboard.HOME) 
			{
				keyStates.keyTest1 = true;
			}
			if (event.keyCode == Keyboard.DELETE && Settings.testMode)
			{
				GameSession.currentSession.onPause =! GameSession.currentSession.onPause;
			}
			if (event.keyCode == Keyboard.INSERT) 
			{
				GameSession.currentSession.redrawLoc();
			}
			if (event.keyCode == Keyboard.BACKQUOTE) keyStates.keyFly = true;
			if (Settings.chitOn) 
			{
				if (event.keyCode == Keyboard.INSERT) keyStates.keyTest2 = true;
			}
			if (keyStates.keyFull) // Only works in the event handler
			{
				if (!GameSession.currentSession.onConsol) GameSession.currentSession.swfStage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
				keyStates.keyFull = false;
			}
		}
		
		public function onKeyboardUpEvent(event:KeyboardEvent):void 
		{
			if (event.keyCode < 256) keyDowns[event.keyCode] = false;
			if (keys[event.keyCode]) 
			{
				keyStates[keys[event.keyCode].id] = false;

				if (keys[event.keyCode].id	== 'keyLeft') 	kL_t = 0;
				if (keys[event.keyCode].id	== 'keyRight') 	kR_t = 0;
				if (keys[event.keyCode].id	== 'keySit') 	kD_t = 0;
			}
		}
	}
	
}
