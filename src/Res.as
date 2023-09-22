﻿package src {
	
	import flash.utils.*;
	import flash.display.MovieClip;
 
	public class Res 
	{
		
		public static var d:XML;
		public static var e:XML;
		
		public function Res() 
		{

		}
		

		public static var classData:Array = new Array();
		classData['u'] = 'unit';
		classData['w'] = 'weapon';
		classData['a'] = 'armor';
		classData['o'] = 'obj';
		classData['i'] = 'item';
		classData['e'] = 'eff';
		classData['f'] = 'info';
		classData['p'] = 'pip';
		classData['k'] = 'key';
		classData['g'] = 'gui';
		classData['m'] = 'map';
		classData[0] = 'n';
		classData[1] = 'info';
		classData[2] = 'mess';
		classData[3] = 'help';
		


		public static function istxt(type:String, id:String):Boolean 
		{
			var xl=d[classData[type]].(@id==id);
			//if (type=='w') trace (id,xl,xl.length());
			if (xl.length()==0) 
			{
				xl=e[classData[type]].(@id==id);
				if (xl.length()==0) return false;
			}
			return true;
		}
		

		public static function txt(type:String, id:String, razd:int=0, dop:Boolean=false):String 
		{
			if (id=='') return '';

			var s:String;
			var xl;

			try 
			{
				xl=d[classData[type]].(@id==id);	// Retrieve from the main language file
				s=xl[classData[razd]][0];		
			} catch (err) {}

			if (s==null) 
			{
				try {
					xl=e[classData[type]].(@id==id);	// Retrieve from the main language file
					s=xl[classData[razd]][0];		
				} catch (err) {}
			}
			if (s==null) 
			{
				if (type=='o') return '';
				if (razd==0) return '*'+classData[type]+'_'+id;			// If still not found, return just the id
				return '';
			}


			// Processing
			xl=xl[0];
			if (xl.@m=='1')	
			{						// Contains material
				var spl:Array=s.split('|');
				if (spl.length>=2) s=spl[World.w.matFilter?1:0];
			}
			if (razd>=1 || dop) 
			{
				if (xl.@s1.length()) s=addKeys(s,xl);	// Control keys
				try {
					if (xl[classData[razd]][0].@s1.length()) s=addKeys(s,xl[classData[razd]][0]);
				} catch (err) {}
				s=s.replace(/\[br\]/g,'<br>');
				s=s.replace(/\[/g,"<span classData='yel'>");
				s=s.replace(/\]/g,"</span>");
			}
			if (dop) {
				s=s.replace(/[\b\r\t]/g,'');
			}
			if (type=='f' || type=='e' && razd==2 || razd>=1 && xl.@st.length()) s="<span classData = 'r"+xl.@st+"'>"+s+"</span>";
			return s;
		}


		public static function guiText(id:String):String 
		{
			return txt('g',id);
		}


		public static function pipText(id:String):String 
		{
			return txt('p',id);
		}


		public static function messText(id:String, v:int=0, imp:Boolean=true):String 
		{
			var s:String='';
			try 
			{
				var xml = d.txt.(@id == id);

				if (xml.length() == 0) 
				{
					xml=e.txt.(@id==id);
				}

				if (xml.length() ==0 ) 
				{
					return '';
				}

				if (!imp && !(xml.@imp>0)) 
				{
					return '';
				}

				var type:int=xml.@imp;

				if (v == 1) 
				{
					s=xml.info[0];
				}
				else 
				{
					if (xml.n[0].r.length()) 
					{
						for each (var node in xml.n[0].r) 
						{
							var s1:String=node.toString();
							if (node.@m.length()) 
							{
								var sar:Array=s1.split('|');
								if (sar) 
								{
									if (World.w.matFilter && sar.length>1) s1=sar[1];
									else s1=sar[0];
								}
							}
							if (node.@s1.length()) 
							{
								for (var i=1; i<=5; i++) 
								{
									if (node.attribute('s'+i).length())  s1=s1.replace('@'+i,"<span classData='yel'>"+World.w.ctr.retKey(node.attribute('s'+i))+"</span>");
								}
							}

							s1=s1.replace(/[\b\r\t]/g,'');

							if (type==1) 
							{
								if (node.@p.length()==0) s+="<span classData='dark'>"+s1+"</span>"+'<br>';
								else 
								{
									var pers=node.@p;
									//if (pers.substr(0,2)!='lp') s+="<span classData='yel'>"+World.w.pers.persName+': '+"</span>"+s1+'<br>';
								
									if (pers.substr(0,2)=='lp') s+="<span classData='light'>"+' - '+s1+"</span>"+'<br>';
									else s+=' - '+s1+'<br>';
								}
							} 
							else s+=s1+'<br>';
						}
					} 

					else s=xml.n[0];
				}
				//s=s.replace('@lp',World.w.pers.persName);
				s=lpName(s);
				s=s.replace(/\[br\]/g,'<br>');
				if (xml.@s1.length()) 
				{
					for (var i=1; i<=5; i++) 
					{
						if (xml.attribute('s'+i).length())  s=s.replace('@'+i,"<span classData='r2'>"+World.w.ctr.retKey(xml.attribute('s'+i))+"</span>");
					}
				}
			} 
			catch (err) 
			{
				return 'err: '+id;
			}
			return (s == null)?'':s;
			//return '';
		}


		public static function advText(n:int):String 
		{
			var xml=d.advice[0];
			var s:String=xml.a[n];
			return (s==null)?'':s;
		}


		public static function repText(id:String, act:String, msex:Boolean=true):String 
		{
			var xl:XMLList = d.replic[0].rep.(@id == id && @act == act);
			if (xl.length() == 0) return '';
			xl = xl[0].r;	//AllData.lang

			var n = xl.length();

			if (n == 0) return '';

			var num:int=Math.floor(Math.random()*n);

			if (World.w.matFilter && xl[num].@m.length()) return '';

			var s:String=xl[num];
			var n1=s.indexOf('#');

			if (n1>=0) 
			{
				var n2=s.lastIndexOf('#');
				var ss:String=s.substring(n1+1,n2);
				s=s.substring(0,n1)+ss.split('|')[msex?0:1]+s.substring(n2+1);
			}
			s=s.replace('@lp',World.w.pers.persName);
			//if () s=matFilter(s);
			return s;
		}
		

		public static function namesArr(id:String):Array 
		{
			var xl:XMLList=d.names;
			if (xl.length()==0) return null;
			xl=xl[0].name.(@id==id);
			if (xl.length()==0) return null;
			xl=xl[0].r;
			var arr:Array=new Array();
			for each (var n in xl) arr.push(n.toString());
			return arr;
		}
		

		public static function lpName(s:String):String 
		{
			return s.replace(/@lp/g,World.w.pers.persName);
		}
		

		public static function getDate(d:Number):String 
		{
			var date:Date=new Date(d);
			return date.fullYear+'.'+(date.month>=9?'':'0')+(date.month+1)+'.'+(date.date>=10?'':'0')+date.date+'  '+date.hours+':'+(date.minutes>=10?'':'0')+date.minutes;
		}
		

		public static function numb(n:Number):String 
		{
			var k:int=Math.round(n*10);
			if (k%10==0) return (k/10).toString();
			else {
				if (n<0) return Math.ceil(k/10)+'.'+Math.abs(k%10);					
				return Math.floor(k/10)+'.'+(k%10);
			}
		}
		

		// Add control keys to a string
		public static function addKeys(s:String,xml:XML):String 
		{
			if (s==null) return '';
			for (var i=1; i<=5; i++) 
			{
				if (xml.attribute('s'+i).length())  s=s.replace('@'+i,"<span classData='imp'>"+World.w.ctr.retKey(xml.attribute('s'+i))+"</span>");
			}
			
			return s;
		}
		

		// Remove /r and /n characters from a string
		public static function formatText(string:String):String 
		{
			return string.replace(/\r\n/g,'<br>');
		}
		

		// String representation of game time
		public static function gameTime(n:Number):String 
		{
			var sec:int=Math.round(n/1000);
			var h:int=Math.floor(sec/3600);
			var m:int=Math.floor((sec-h*3600)/60);
			var s:int=sec%60;

			return h.toString()+':'+((m<10)?'0':'')+m+':'+((s<10)?'0':'')+s;
		}
		

		static var rainbowcol:Array=['red','or','yel','green','blu','purp']
		

		public static function rainbow(s:String):String 
		{
			var n = 0;
			var res:String='';
			for (var i=0; i<s.length; i++) {
				res+="<span classData='"+rainbowcol[n]+"'>"+s.charAt(i)+"</span>";
				n++;
				if (n>=6) n=0;
			}
			return res;
		}
		

		public static function getVis(id:String, def:Class=null):MovieClip 
		{
			var r:Class;
			try 
			{
				r=getDefinitionByName(id) as Class;
			} 
			catch (err:ReferenceError) 
			{
				r=def;
			}
			if (r) return new r()
			else return null;
		}
		

		public static function getClass(id1:String, id2:String=null, def:Class=null):Class {
			var r:Class;
			try 
			{
				r=getDefinitionByName(id1) as Class;
			} 
			catch (err:ReferenceError) 
			{
				if (id2==null) r=def;
				else {
					try {
						r=getDefinitionByName(id2) as Class;
					} catch (err:ReferenceError) {
						r=def;
					}
				}
			}
			return r;
		}
		

	}
	
}