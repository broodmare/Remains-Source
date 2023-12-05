package
{
	
	import flash.utils.*;
	import flash.display.MovieClip;
	
	import components.Settings;
	
	public class Res 
	{
		
		public static var localizationFile:XML;
		private static var rainbowcol:Array = ['red','or','yel','green','blu','purp'];

		public function Res() 
		{


		}

		//TODO: Remove. Fold into txt().
		public static function istxt(classKey:String, id:String):Boolean
		{
				var string = localizationFile[classKey].(@id == id);		
				if(string.length() > 0)
				{
					return true;
				}
				else
				{
					return false;
				}
		}
		
		//Text string localization
		public static function txt(classKey:String, id:String, nodeChildType:int = 0, dop:Boolean = false):String 
		{
			//trace('Res.as/txt() - classKey/ID: "' + classKey + '/' + id + '", nodeChildType: "' + nodeChildType + '" dop: "' + dop + '."')

			var xmlNode:XML;
   			var xmlNodeText:String = "";
			
			if (isTextNullCheck(classKey, id)) //Return blank text early if elements are malformed.
			{
				return xmlNodeText;
			}

			try 
			{
				xmlNode = localizationFile[classKey].(@id == id)[0]; //XML Node
				//trace('Res.as/txt() - xmlNode: "' + xmlNode + '".');

				switch(nodeChildType) //XML Node child elements.
				{
					case 0:
						xmlNodeText = xmlNode.n; // Access the 'n' child element (default behavior)
						break;
					case 1:
						xmlNodeText = xmlNode.info; // Access the 'info' child element
						break;
					case 2:
						xmlNodeText = xmlNode.mess; // Access the 'mess' child element
						break;
					case 3:
						xmlNodeText = xmlNode.help; // Access the 'help' child element
						break;
					default:
						trace('Res.as/txt() - nodeChildType for classKey/ID: "' + classKey + '/' + id + '" not found with nodeChildType: "' + nodeChildType + '".');
						break;
				}
			} 
			catch (err:Error) 
			{
				//trace('Res.as/txt() - Failed to retrieve string ID: "' + id + '", with classKey: "' + classKey + '". Error: "' + err.message + '".');
				xmlNodeText = 'ERROR';
				return xmlNodeText;
			}

			// Processing
			if (xmlNode.@m == '1')	// Contains material
			{						
				var spl:Array = xmlNodeText.split('|');
				if (spl.length >= 2) xmlNodeText = spl[Settings.matFilter ? 1 : 0];
			
			}
			if (nodeChildType >= 1 || dop) // Control keys
			{
				if (xmlNode.@s1.length()) xmlNodeText = addKeys(xmlNodeText, xmlNode);	
				try 
				{
					if (xmlNode[classKey][0].@s1.length) 
					{
						xmlNodeText = addKeys(xmlNodeText, xmlNode[classKey][0]);
					}
				} 
				catch (err) 
				{
					trace('Res.as/txt() - Failed adding control keys.');
				}
				xmlNodeText = xmlNodeText.replace(/\[br\]/g, '<br>');
				xmlNodeText = xmlNodeText.replace(/\[/g, "<span classData='yel'>");
				xmlNodeText = xmlNodeText.replace(/\]/g, "</span>");
			}
			
			if (dop) 
			{
				xmlNodeText = xmlNodeText.replace(/[\b\r\t]/g, '');
			}
			
			if (classKey == 'info' || classKey == 'eff' && nodeChildType == 2 || nodeChildType >= 1 && xmlNode.@st.length()) 
			{
				xmlNodeText = "<span classData = 'r" + xmlNode.@st + "'>" + xmlNodeText + "</span>";
			}

			//trace('Res.as/txt() - Returning localized text: "' + xmlNodeText + '."');
			return xmlNodeText;
		}

		private static function isTextNullCheck(classKey:String, id:String):Boolean
		{
			if (id == '') 
			{
				trace('Res.as/isTextNullCheck() - ID is blank.');
				return true;
			}
			if (localizationFile == null) 
			{
				trace('Res.as/isTextNullCheck() - localizationFile is null.');
				return true;
			}
			if (classKey == null || '') 
			{
				trace('Res.as/isTextNullCheck() - classKey is blank or null.');
				return true;
			}
			return false;
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
									if (node.attribute('s' + i).length())  s1 = s1.replace('@' + i, "<span classData = 'yel'>" + GameSession.currentSession.ctr.retKey(node.attribute('s' + i)) + "</span>");
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
						if (xml.attribute('s' + j).length())  s = s.replace('@' + j, "<span classData='r2'>" + GameSession.currentSession.ctr.retKey(xml.attribute('s' + j)) + "</span>");
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
			s = s.replace('@lp', GameSession.currentSession.pers.persName);
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
			return s.replace(/@lp/g, GameSession.currentSession.pers.persName);
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
					if (xml.attribute('s' + i ).length())  s = s.replace('@' + i, "<span classData='imp'>" + GameSession.currentSession.ctr.retKey(xml.attribute('s' + i)) + "</span>");
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
