package interdata 
{
	

	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.display.MovieClip;
	import flash.display.DisplayObject;

	import fl.controls.ColorPicker;
	import fl.events.ColorPickerEvent;
	import fl.events.SliderEvent;
	import fl.motion.Color;
	// Character Appearance Settings
	
	import stubs.appearanceEdtiorWindow;

	public class Appear 
	{

		public var window:MovieClip;
		public var col:Color = new Color;
		
		public var funOk:Function;
		public var funCancel:Function;
		
		public var cFur:uint 	= 0xA3A3A3;
		public var cHair:uint 	= 0x854609;
		public var cHair1:uint 	= 0xFFFFFF;
		public var cEye:uint 	= 0x16F343;
		public var cMagic:uint 	= 0x00FF00;
		public var tFur:uint, tHair:uint, tHair1:uint, tEye:uint, tMagic:uint;

		public static var trFur:ColorTransform 		= new ColorTransform(0.8,0.8,0.8);
		public static var trHair:ColorTransform 	= new ColorTransform(0xA3 / 0xFF, 0x56 / 0xFF, 0x0B / 0xFF);
		public static var trHair1:ColorTransform 	= new ColorTransform(1,1,1);
		public static var trEye:ColorTransform 		= new ColorTransform(0,0.9,0);
		public static var trMagic:ColorTransform 	= new ColorTransform(0,1,0);
		
		public static var trBlack:ColorTransform 	= new ColorTransform(0,0,0,0.2,0,255,100);
		
		public static var visHair1:Boolean = false;
		public static var fEye:int = 1, maxEye:int = 6;
		public static var fHair:int = 1, maxHair:int = 5;

		public static var ggArmorId:String 	= '';	//надетая броня
		public static var hideMane:int 		= 0;	//скрыть волосы
		public static var transp:Boolean 	= false;

		public var clist:Array = ['Fur','Hair','Hair1','Eye','Magic'];
		
		public var tek:String = 'Fur';
		
		public var temp:Object;
		public var def:Object;
		public var loadObj:Object;
		
		
		public var saved:Object;

		public function Appear():void
		{
			window = new appearanceEdtiorWindow(); //.swf Linkage

			for each(var l:String in clist) 
			{
				this['t' + l] = this['c' + l];
			}
			def = save();
			setColors();
			setTransforms();
			setColor('Fur', cFur);
		}
		
		//надписи
		public function setLang():void
		{
			window.butOk.text.text = 'OK';
			window.butCancel.text.text=Res.txt('gui', 'cancel');
			window.butDef.text.text=Res.txt('pip', 'default');
			window.title.text=Res.txt('gui', 'editAppearanceButton');
			window.tFur.text=Res.txt('gui', 'vidfur');
			window.tHair.text=Res.txt('gui', 'vidhair');
			window.tHair1.text=Res.txt('gui', 'vidhair1');
			window.tEye.text=Res.txt('gui', 'videye');
			window.tMagic.text=Res.txt('gui', 'vidmagic');
		}
		
		//присоединить диалоговое окно
		public function attach(mm:MovieClip, fo:Function, fc:Function):void
		{
			mm.addChild(window);
			window.fon.visible = true;
			temp = save();
			funcOn();
			funOk = fo;
			funCancel = fc;
			setColors();
			window.pers.gotoAndStop(2);
			window.pers.gotoAndStop(1);
		}
		//отсоединить диалоговое окно
		public function detach():void
		{
			if (window.parent) window.parent.removeChild(window);
			funcOff();
			funOk = null;
			funCancel = null;
			if (saved != null) 
			{
				load(saved);
				saved = null;
			}
		}
		
		public function funcOn():void
		{
			window.butOk.addEventListener(MouseEvent.CLICK, buttonOk);
			window.butCancel.addEventListener(MouseEvent.CLICK, buttonCancel);
			window.butDef.addEventListener(MouseEvent.CLICK, buttonDef);
			for each(var l:String in clist) 
			{
				window['color' + l].addEventListener(ColorPickerEvent.CHANGE, changeHandler);
				window['color' + l].addEventListener(Event.OPEN, openHandler);
			}
			window.slRed.addEventListener(SliderEvent.THUMB_DRAG, chColor);
			window.slGreen.addEventListener(SliderEvent.THUMB_DRAG, chColor);
			window.slBlue.addEventListener(SliderEvent.THUMB_DRAG, chColor);
			window.checkHair1.addEventListener(ColorPickerEvent.CHANGE, changeHair1);
			window.b1Eye.addEventListener(MouseEvent.CLICK, chBut);
			window.b2Eye.addEventListener(MouseEvent.CLICK, chBut);
			window.b1Hair.addEventListener(MouseEvent.CLICK, chBut);
			window.b2Hair.addEventListener(MouseEvent.CLICK, chBut);
		}

		public function funcOff():void
		{
			if (!window.butOk.hasEventListener(MouseEvent.CLICK)) return;
			window.butOk.removeEventListener(MouseEvent.CLICK, buttonOk);
			window.butCancel.removeEventListener(MouseEvent.CLICK, buttonCancel);
			window.butDef.removeEventListener(MouseEvent.CLICK, buttonDef);
			for each(var l:String in clist) 
			{
				window['color' + l].removeEventListener(ColorPickerEvent.CHANGE, changeHandler);
				window['color' + l].removeEventListener(Event.OPEN, openHandler);
			}
			window.slRed.removeEventListener(SliderEvent.THUMB_DRAG, chColor);
			window.slGreen.removeEventListener(SliderEvent.THUMB_DRAG, chColor);
			window.slBlue.removeEventListener(SliderEvent.THUMB_DRAG, chColor);
			window.checkHair1.removeEventListener(ColorPickerEvent.CHANGE, changeHair1);
			window.b1Eye.removeEventListener(MouseEvent.CLICK, chBut);
			window.b2Eye.removeEventListener(MouseEvent.CLICK, chBut);
			window.b1Hair.removeEventListener(MouseEvent.CLICK, chBut);
			window.b2Hair.removeEventListener(MouseEvent.CLICK, chBut);
		}
		
		// Press the OK button
		public function buttonOk(event:MouseEvent):void
		{
			if (funOk) funOk();
			GameSession.currentSession.saveConfig();
		}
		// Press the Cancel button
		public function buttonCancel(event:MouseEvent):void
		{
			load(temp);
			setTransforms();
			setColors();
			window.pers.gotoAndStop(2);
			window.pers.gotoAndStop(1);
			if (funCancel) funCancel();
		}
		// Press the def button
		public function buttonDef(event:MouseEvent):void
		{
			load(def);
			setTransforms();
			setColors();
			window.pers.gotoAndStop(2);
			window.pers.gotoAndStop(1);
		}
		
		// Set all color pickers to match the colors
		public function setColors():void
		{
			trace('Appear.as/setColors() - setColors() Executing.');
			for each(var l:String in clist) 
			{
				window['color' + l].selectedColor = this['c' + l];
			}

			window.checkHair1.selected = visHair1;
		}

		// Convert all colors to transforms
		public function setTransforms():void
		{
			for each(var l:String in clist) 
			{
				colorToTransform(this['c' + l], Appear['tr' + l]);
			}

		}
		
		
		public function save():Object 
		{
			if (saved != null) 
			{
				load(saved);
			}
			var obj:Object = {};
			for each(var l:String in clist) 
			{
				obj['c' + l] = this['c' + l];
			}
			obj.visHair1 = visHair1;
			obj.fEye = fEye;
			obj.fHair = fHair;
			return obj;
		}
		
		// Save when calling the save or load page
		public function saveOst():void
		{
			if (saved == null) saved = save();
		}
		
		public function load(obj:Object):void
		{
			trace('Appear.as/load() - load() Executing.');

			if (obj == null) 
			{
				trace('Appear.as/load() - Obj is null.');
				for each(var i:String in clist) 
				{
					this['c' + i] = this['t' + i];
				}
				visHair1 = false;
				fEye = 1;
				fHair = 1;
			} 
			else 
			{
				trace('Appear.as/load() - Obj found, loading appearance');
				for each(var j:String in clist) 
				{
					this['c'+j] = obj['c' + j];
				}
				visHair1 = obj.visHair1;
				fEye = obj.fEye;
				fHair = obj.fHair;
			}
			setTransforms();
		}
		
		// Convert color to transform
		public function colorToTransform(c:uint, ct:ColorTransform):void
		{
			var colMax:int = 290, colSd:Number = (290 - 255) / 255;
			col.tintMultiplier = 1;
			col.tintColor = c;
			ct.redMultiplier = col.redOffset / colMax + colSd;
			ct.greenMultiplier = col.greenOffset / colMax + colSd;
			ct.blueMultiplier = col.blueOffset / colMax + colSd;
			window.slRed.value = col.redOffset;
			window.slGreen.value = col.greenOffset;
			window.slBlue.value = col.blueOffset;
			setRGB();
		}
		
		//Labels
		public function setRGB():void
		{
			window.nRed.text 	= 'R:' + col.redOffset;
			window.nGreen.text = 'G:' + col.greenOffset;
			window.nBlue.text 	= 'B:' + col.blueOffset;
		}
		
		//Slider event
		public function chColor(event:SliderEvent):void
		{
			col.redOffset=window.slRed.value;
			col.greenOffset=window.slGreen.value;
			col.blueOffset=window.slBlue.value;
			setRGB();
			setColor(tek,col.color);
		}
		
		//Color picker events
		public function changeHandler(event:ColorPickerEvent):void
		{
			var myCP:ColorPicker = event.currentTarget as ColorPicker;
			var myCT:ColorTransform;
			var nam:String = myCP.name.substr(5);
			tek = nam;
			setColor(nam,myCP.selectedColor);
		}

		public function openHandler(event:Event):void
		{
			var myCP:ColorPicker = event.currentTarget as ColorPicker;
			var nam:String = myCP.name.substr(5);
			tek = nam;
			setColor(nam,myCP.selectedColor);
		}
		
		//Enable/disable second color
		public function changeHair1(e:Event):void
		{
			visHair1=window.checkHair1.selected;
			window.pers.gotoAndStop(2);
			window.pers.gotoAndStop(1);
		}
		
		//Buttons for selecting options
		public function chBut(event:MouseEvent):void
		{
			var nam:String = (event.currentTarget as flash.display.DisplayObject).name;
			if (nam == 'b1Eye') 
			{
				fEye--;
				if (fEye <= 0) fEye = maxEye;
			}
			if (nam == 'b2Eye') 
			{
				fEye++;
				if (fEye>maxEye) fEye = 1;
			}
			if (nam == 'b1Hair') 
			{
				fHair--;
				if (fHair <= 0) fHair = maxHair;
			}
			if (nam == 'b2Hair') 
			{
				fHair++;
				if (fHair > maxHair) fHair = 1;
			}
			window.pers.gotoAndStop(2);
			window.pers.gotoAndStop(1);
		}
		
		//set the model's color
		public function setColor(nam:String, c:uint):void
		{
			this['c' + nam] = c;
			colorToTransform(this['c' + nam], Appear['tr' + nam]);
			window['color' + nam].selectedColor = c;
			window.pers.gotoAndStop(2);
			window.pers.gotoAndStop(1);
		}
		
	}
	
}
