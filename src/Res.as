package
{
	
	import flash.utils.*;
	import flash.display.MovieClip;
	
	import components.Settings;
	
	public class Res 
	{
		
		public static var localizationFile:XML;
		
		//Localization strings sorted into various categories.
		public static const classData:Object = 
		{
			'u' : 'unit',
			'w' : 'weapon',
			'a' : 'armor',
			'o' : 'obj',
			'i' : 'item',
			'e' : 'eff',
			'f' : 'info',
			'p' : 'pip',
			'k' : 'key',
			'g' : 'gui',
			'm' : 'map',
			'0' : 'n',
			'1' : 'info',
			'2' : 'mess',
			'3' : 'help'
		};
		
		private static var rainbowcol:Array = ['red','or','yel','green','blu','purp'];

		public function Res() 
		{


		}
		




		public static function istxt(stringType:String, id:String):Boolean
		{
			    //trace('Res.as/istxt() - istxt() executing with stringType: ' + stringType + ' and ID: ' + id + '.');
				if (localizationFile == null) trace('Res.as/istxt() - Game data is null.');
				var xl:XMLList = localizationFile[classData[stringType]].(@id == id);
				return (xl.length() > 0);
		}
		

		public static function txt(classDataKey:String, id:String, classDataIndexNumber:int = 0, dop:Boolean = false):String 
		{
			trace('Res.as/txt() - txt() executing with classDataKey: "' + classDataKey + '" String ID: "' + id + '" classDataIndexNumber: "' + classDataIndexNumber + '" dop: "' + dop + '."')
			if (id == '') 
			{
				trace('Res.as/txt() - ID is blank, returning.');
				return '';
			}
			if (localizationFile == null) 
			{
				
				trace('Res.as/txt() - localizationFile is null.');
				return '';
			}
			if (classData[classDataKey] == null) 
			{
				trace('Res.as/txt() - Invalid classDataKey provided: ' + classDataKey);
				return '';
			}


			try 
			{
				//trace('Res.as/txt() - Trying to set "xl" as: ' + localizationFile[classData[classDataKey]].(@id == id));
				var xl = localizationFile[classData[classDataKey]].(@id == id);

				//trace('Res.as/txt() - Trying to set "s" as: ' + xl[classData[classDataIndexNumber]][0]);
				var s = xl[classData[classDataIndexNumber]][0];
			} 
			catch (err:Error) 
			{
				trace('Res.as/txt() - txt Error.' + err.message);
			}

			if (s == null || s == "") 
			{
				if (classDataKey == 'o') return '';
				if (classDataIndexNumber == 0) return '*' + classData[classDataKey] + '_' + id;			// If still not found, return just the id
				return '';
			}


			// Processing
			xl = xl[0];
			if (xl.@m == '1')	// Contains material
			{						
				var spl:Array = s.split('|');
				if (spl.length >= 2) s = spl[Settings.matFilter ? 1 : 0];
			}
			if (classDataIndexNumber >= 1 || dop) // Control keys
			{
				if (xl.@s1.length()) s = addKeys(s, xl);	
				try 
				{
					if (xl[classData[classDataIndexNumber]][0].@s1.length) 
					{
						s = addKeys(s, xl[classData[classDataIndexNumber]][0]);
					}
				} 
				catch (err) 
				{
					trace('Res.as/txt() - Failed adding control keys.');
				}
				s = s.replace(/\[br\]/g, '<br>');
				s = s.replace(/\[/g, "<span classData='yel'>");
				s = s.replace(/\]/g, "</span>");
			}
			if (dop) 
			{
				s = s.replace(/[\b\r\t]/g, '');
			}
			if (classDataKey == 'f' || classDataKey == 'e' && classDataIndexNumber == 2 || classDataIndexNumber >= 1 && xl.@st.length()) s = "<span classData = 'r" + xl.@st + "'>" + s + "</span>";
			
			//trace('Res.as/txt() - Returning string: "' + s + '."');
			return s;
		}


		public static function messText(id:String, v:int = 0, imp:Boolean = true):String 
		{
			trace('Res.as/messText() - messText Executing...');
			var s:String = '';
			try 
			{
				if (localizationFile == null) trace('Res.as/messText() - localizationFile is null.');
				var xml:XMLList = localizationFile.txt.(@id == id);

				if (xml.length() == 0) 
				{
					return '';
				}

				if (!imp && !(xml.@imp > 0)) 
				{
					return '';
				}

				trace('Res.as/messText() - Checking version...');
				var stringType:int = xml.@imp;

				if (v == 1) 
				{
					s = xml.info[0];
				}

				else 
				{
					if (xml.n[0].r.length()) 
					{
						for each (var node:XML in xml.n[0].r) 
						{
							var s1:String = node.toString();
							if (node.@m.length()) 
							{
								var sar:Array = s1.split('|');
								if (sar) 
								{
									if (Settings.matFilter && sar.length > 1) s1 = sar[1];
									else s1 = sar[0];
								}
							}
							if (node.@s1.length()) 
							{
								for (var i:int = 1; i <= 5; i++) 
								{
									if (node.attribute('s' + i).length())  s1 = s1.replace('@' + i, "<span classData = 'yel'>" + World.world.ctr.retKey(node.attribute('s' + i)) + "</span>");
								}
							}

							s1 = s1.replace(/[\b\r\t]/g,'');

							if (stringType == 1)
							{
								if (node.@p.length() == 0) s += "<span classData='dark'>" + s1 + "</span>"+'<br>';
								else 
								{
									var pers:String = node.@p;
									if (pers.substr(0, 2) == 'lp') s += "<span classData='light'>" + ' - ' + s1 + "</span>" + '<br>';
									else s += ' - ' + s1 + '<br>';
								}
							} 
							else s += s1 + '<br>';
						}
					} 

					else 
					{
						s = xml.n[0];
					}
				}
				
				s = lpName(s);
				s = s.replace(/\[br\]/g, '<br>');
				if (xml.@s1.length()) 
				{
					for (var j:int = 1; j <= 5; j++) 
					{
						if (xml.attribute('s' + j).length())  s = s.replace('@' + j, "<span classData='r2'>" + World.world.ctr.retKey(xml.attribute('s' + j)) + "</span>");
					}
				}
			} 
			catch (err) 
			{
				trace('Res.as/messText() - messText Failed.' + err.message)
			}
			return (s == null) ? '' : s; // If string is null, return a blank string, otherwise return the string.
		}


		public static function advText(n:int):String 
		{
			var xml:XML = localizationFile.advice[0];
			var s:XMLList = xml.a[n];
			return (s == null) ? '' : s;
		}

		//Replace text for different languages?
		public static function repText(id:String, act:String, msex:Boolean=true):String 
		{
			var xl:XMLList = localizationFile.replic[0].rep.(@id == id && @act == act);
			if (xl.length() == 0) return '';
			xl = xl[0].r;	//AllData.lang

			var n:int = xl.length();

			if (n == 0) return '';

			var num:int = Math.floor(Math.random() * n);

			if (Settings.matFilter && xl[num].@m.length) return '';

			var s:String = xl[num];
			var n1:int = s.indexOf('#');

			if (n1 >= 0) 
			{
				var n2:int = s.lastIndexOf('#');
				var ss:String = s.substring(n1 + 1, n2);
				s = s.substring(0, n1) + ss.split('|')[msex ? 0:1] + s.substring(n2 + 1);
			}
			s = s.replace('@lp', World.world.pers.persName);
			return s;
		}
		

		public static function namesArr(id:String):Array 
		{
			var xl:XMLList = localizationFile.names;
			if (xl.length() == 0) return null;
			xl = xl[0].name.(@id == id);
			if (xl.length() == 0) return null;
			xl = xl[0].r;
			var arr:Array = [];
			for each (var n:XML in xl) 
			{
				arr.push(n.toString());
			}
			return arr;
		}
		

		public static function lpName(s:String):String 
		{
			return s.replace(/@lp/g, World.world.pers.persName);
		}
		

		public static function getDate(currentDate:Number):String 
		{
			var date:Date = new Date(currentDate);
			return date.fullYear + '.' + (date.month >= 9 ? '':'0') + (date.month + 1) + '.' + (date.date >= 10 ? '':'0') + date.date + '  ' + date.hours + ':' + (date.minutes >= 10 ? '':'0') + date.minutes;
		}
		

		public static function numb(n:Number):String 
		{
			var k:int=Math.round(n * 10);
			if (k%10 == 0) return (k / 10).toString();
			else 
			{
				if (n < 0) return Math.ceil(k / 10) + '.' + Math.abs(k%10);					
				return Math.floor(k / 10) + '.' + (k%10);
			}
		}
		

		// Add control keys to a string
		public static function addKeys(s:String, xml:XML):String 
		{
			if (s == null) 
			{
				trace('Res.as/addKeys() -  ERROR: Passed string was null. XML: "' + xml + '."');
				return '';
			}

			try
			{
				for (var i:int = 1; i <= 5; i++) 
				{
					if (xml.attribute('s' + i ).length())  s = s.replace('@' + i, "<span classData='imp'>" + World.world.ctr.retKey(xml.attribute('s' + i)) + "</span>");
				}
			}
			catch(err:Error)
			{
				trace('Res.as/addKeys() -  ERROR: Error while transforming string: "' + s + '."');
			}


			return s;
		}
		

		// Remove /r and /n characters from a string
		public static function formatText(string:String):String 
		{
			return string.replace(/\r\n/g, '<br>');
		}
		

		// String representation of game time
		public static function gameTime(n:Number):String 
		{
			var sec:int = Math.round(n / 1000);
			var h:int = Math.floor(sec / 3600);
			var m:int = Math.floor((sec - h * 3600) / 60);
			var s:int = sec%60;

			return h.toString() + ':' + ((m < 10) ? '0':'') + m + ':' + ((s < 10)?'0':'') + s;
		}
		

		
		

		public static function rainbow(s:String):String 
		{
			var n:int = 0;
			var res:String = '';
			for (var i:int = 0; i < s.length; i++) 
			{
				res += "<span classData='" + rainbowcol[n] + "'>" + s.charAt(i) + "</span>";
				n++;
				if (n >= 6) n = 0;
			}
			return res;
		}
		

		public static function getVis(id:String, def:Class = null):MovieClip 
		{
			trace('Res/getVis() - getVis Executing...');
			var r:Class;
			try 
			{
				r = getDefinitionByName(id) as Class;
			} 
			catch (err:ReferenceError) 
			{
				r = def;
			}
			if (r) return new r()
			else return null;
		}
		

		public static function getClass(id1:String, id2:String = null, def:Class = null):Class 
		{
			//trace('Res/getClass() - getClass Executing...');
			var r:Class;
			try 
			{
				r = getDefinitionByName(id1) as Class;
			} 
			catch (err:ReferenceError) 
			{
				if (id2 == null) r = def;
				else 
				{
					try 
					{
						r = getDefinitionByName(id2) as Class;
					} 
					catch (err:ReferenceError) 
					{
						r = def;
					}
				}
			}
			return r;
		}
		

	}
	
}
