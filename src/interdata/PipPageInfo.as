package interdata 
{
	
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.text.TextField;

	import locdata.Game;
	import locdata.Quest;
	import locdata.LevelTemplate;
	import unitdata.Unit;
	
	import components.Settings;
	
	import stubs.visPipQuestItem;
	import stubs.visPipInfo;
	import stubs.visPipMap;
	import stubs.visPipWMap;

	public class PipPageInfo extends PipPage
	{
		
		var visMap:MovieClip;
		var visWMap:MovieClip;
		public var map:Bitmap;
		public var mbmp:BitmapData;
		var visPageX=850, visPageY=540;
		var mapScale:Number=2, ms:Number=2;
		var plTag:MovieClip;
		var targetLand:String='';
		var game:Game;

		public function PipPageInfo(npip:PipBuck, npp:String) 
		{
			itemClass = visPipQuestItem;
			pageClass = visPipInfo;
			isLC = true;
			super(npip,npp);

			//объект карты
			visMap 	= new visPipMap();
			visWMap = new visPipWMap();
			vis.addChild(visMap);
			vis.addChild(visWMap);
			visMap.x  = 12;
			visMap.y  = 75;
			visWMap.x = 17;
			visWMap.y = 80;

			//битмап
			map = new Bitmap();
			visMap.vmap.addChild(map);
			visMap.vmap.mask = visMap.maska;
			plTag = visMap.vmap.plTag;
			visMap.vmap.swapChildren(map,plTag);

			vis.butOk.addEventListener(MouseEvent.CLICK,transOk);
			visMap.addEventListener(MouseEvent.MOUSE_DOWN,onMouseDown);
			visMap.addEventListener(MouseEvent.MOUSE_UP,onMouseUp);
			visMap.butZoomP.addEventListener(MouseEvent.CLICK,funZoomP);
			visMap.butZoomM.addEventListener(MouseEvent.CLICK,funZoomM);
			visMap.butCenter.addEventListener(MouseEvent.CLICK,funCenter);
			trace('PipPageInfo.as/PipPageInfo() - Created PipPageInfo page.');
		}
		

		override function setSubPages():void
		{
			trace('PipPageInfo.as/setSubPages() - updating subPages.');

			vis.bottext.visible		= false;
			vis.butOk.visible		= false;
			statHead.visible		= false;
			visMap.visible			= false;
			visWMap.visible			= false;
			vis.ico.visible			= false;
			vis.objectName.x		= 458;
			vis.info.x				= 458;
			vis.objectName.width	= 413;
			vis.info.width			= 458;
			pip.vis.butHelp.visible	= false;
			targetLand				= '';
			setTopText();

			game = World.world.game;
			if (page2 == 1) 
			{		//карта
				if (World.world.room.noMap) 
				{
					vis.emptytext.text=Res.txt('p', 'emptymap');
				} 
				else 
				{
					vis.emptytext.text='';
					map.bitmapData=World.world.level.drawMap();
					setMapSize();
					visMap.visible=true;
				}
			} 
			else if (page2==2) 
			{	//задания
				for each(var i:Quest in game.quests) 
				{
					if (i.state>0) 
					{
						var n:Object={id:i.id, objectName:i.objectName, main:i.main, sort:(i.main?0:1), state:i.state};
						arr.push(n);
					}
				}
				if (arr.length) arr.sortOn(['state','sort','objectName']);
				if (World.world.room && World.world.room.base) {
					for each (var task in GameData.d.vendor.task) 
					{
						if (checkQuest(task)) 
						{
							var j:Quest=game.quests[task.@id];
							if (j==null || j.state==0) 
							{
								vis.butOk.visible=true;
								vis.butOk.text.text=Res.txt('p', 'alltask');
								break;
							}
						}
					}
				}
			} 
			else if (page2 == 3) 	//общая карта
			{
				vis.objectName.x=vis.info.x=584;
				vis.objectName.width=287;
				vis.info.width=332;
				if (pip.travel) setTopText('infotravel');
				for each (var level:LevelTemplate in game.levelArray) 
				{
					if (level.prob) continue;
					level.calcProbs();
					var sim:MovieClip=visWMap[level.id];
					if (sim) 
					{
						sim.alpha=1;
						sim.zad.gotoAndStop(1);
						sim.sign.stop();
						sim.sign.visible=false;
						sim.visible=false;
						if (!sim.hasEventListener(MouseEvent.CLICK)) 
						{
							sim.addEventListener(MouseEvent.CLICK,itemClick);
							sim.addEventListener(MouseEvent.MOUSE_OVER,statInfo);
						}
						try 
						{
							sim.sim.gotoAndStop(level.id);
						} 
						catch (err) 
						{
							sim.sim.gotoAndStop(1);
						}
						//trace(level.id, Settings.testMode);
						if (!Settings.testMode) continue;
						if (!game.checkTravel(level.id)) sim.alpha=0.5;
						if (Settings.testMode && !level.visited && !level.access) sim.alpha=0.3;
						if (Settings.helpMess && !level.visited && level.access) 
						{
							sim.sign.play();
							sim.sign.visible=true;
						}
						if (Settings.testMode || level.visited || level.access) sim.visible = true;
					}
				}
				vis.butOk.text.text=Res.txt('p', 'trans');
				visWMap.visible=true;
				pip.vis.butHelp.visible=true;
				pip.helpText=Res.txt('p','helpWorld',0,true);
			} 
			else if (page2 == 4)
			{	//записи
				var doparr:Array=new Array();
				for each (var note:String in game.notes) 
				{
					var xml=Res.localizationFile.txt.(@id==note);
					var nico:int=0;
					if (xml && xml.@imp>0) 
					{
						nico=int(xml.@imp);
					} 
					else continue;
					var title:String;
					if (xml.n.t.length()) title=xml.n.t[0];
					else title=xml.n.r[0];
					title=title.replace(/&lp/g,World.world.pers.persName);
					var n:Object={id:note, objectName:title, ico:nico};
					if (nico==3) doparr.push(n);
					else arr.push(n);
				}
				arr.reverse();
				arr=doparr.concat(arr);
			} 
			else if (page2 == 5) 	//противники
			{
				if (Unit.arrIcos==null) Unit.initIcos();
				var prevObj:Object=null;
				statHead.visible=true;
				statHead.objectName.text='';
				statHead.mq.visible=false;
				statHead.kol.text=Res.txt('p', 'frag');
				vis.ico.visible=true;
				for each(var xml in AllData.d.unit) 
				{
					if (xml && xml.@cat.length()) 
					{
						var n:Object={id:xml.@id, objectName:Res.txt('u',xml.@id), cat:xml.@cat, kol:-1};
						if (xml.@cat=='3' && World.world.game.triggers['frag_'+xml.@id]>=0) n.kol=int(World.world.game.triggers['frag_'+xml.@id]);
						if (xml.@cat=='2') 
						{
							prevObj=n;
						} 
						else if (xml.@cat=='3') 
						{
							if (prevObj && n.kol>=0) 
							{
								if (prevObj.kol<0) prevObj.kol=0;
								prevObj.kol+=n.kol;
							}
							if (prevObj) n.prev=prevObj.id;
						}
						arr.push(n);
					}
				}
				arr=arr.filter(isKol);		//отфильтровать
			}

			trace('PipPageInfo.as/setSubPages() - Finished updating subPages.');

		}
		
		private function isKol(element:*, index:int, arr:Array):Boolean 
		{
            return (element.kol >= 0 || element.cat == '1');
        }		
		//один эемент списка
		override function setStatItem(item:MovieClip, obj:Object):void
		{
			item.id.text 			= obj.id;
			item.id.visible 		= false;
			item.objectName.text 	= obj.objectName;
			item.mq.visible 	 	= false;
			item.ramka.visible 		= false;
			item.objectName.alpha 	= 1;
			item.kol.text 			= '';
			item.kol.visible 		= false;
			if (page2 == 2) 
			{
				item.objectName.x=32;
				item.mq.visible=obj.main;
				item.mq.gotoAndStop(1);
				if (obj.state==2) 
				{
					item.objectName.alpha=item.mq.alpha=0.4;
					item.objectName.text+=' ('+Res.txt('p', 'done')+')';
				} 
				else 
				{
					item.objectName.alpha=item.mq.alpha=1;
				}
			} 
			else if (page2==3) 
			{

			} 
			else if (page2==4) 
			{
				item.objectName.x=32;
				item.objectName.htmlText=obj.objectName.substr((obj.objectName.charAt(0)==' ')?3:0, 60);
				item.kol.text=obj.objectName;
				item.mq.visible=true;
				item.mq.alpha=1;
				item.mq.gotoAndStop(obj.ico+1);
			} 
			else if (page2==5) 
			{
				item.objectName.x=5;
				if (obj.cat=='1') item.objectName.htmlText='<b>'+item.objectName.text+'</b>';
				if (obj.cat=='2') item.objectName.htmlText='      <b>'+item.objectName.text+'</b>';
				if (obj.cat=='3') item.objectName.htmlText='            '+item.objectName.text;
				if (obj.kol>0) item.kol.text=obj.kol;
				item.kol.visible=true;
			}
		}

		
		override function statInfo(event:MouseEvent):void //информация об элементе
		{
			vis.info.y=vis.ico.y;
			if (page2==2) 
			{
				vis.info.htmlText=infoQuest(event.currentTarget.id.text);
			} 
			else if (page2==3) 
			{
				var l:LevelTemplate=game.levelArray[event.currentTarget.name];
				if (l==null) return;
				vis.objectName.text=Res.txt('m',l.id);
				var s:String=Res.txt('m',l.id,1);
				if (!l.visited) s+="\n\n<span class ='blu'>"+Res.txt('p', 'ls1')+"</span>";
				else if (l.passed) s+="\n\n<span class ='or'>"+Res.txt('p', 'ls2')+"</span>";
				else if (l.tip=='base') s+="\n\n<span class ='or'>"+Res.txt('p', 'ls4')+"</span>";
				else if (l.tip=='rnd') s+="\n\n<span class ='yel'>"+Res.txt('p', 'ls3')+": "+(l.landStage+1)+"</span>";
				if (l.tip=='rnd' && l.kolAllProb>0) {
					s+="\n<span class ='yel'>"+Res.txt('p', 'kolProb')+': '+l.kolClosedProb+'/'+l.kolAllProb+"</span>";
				}
				if (l.dif>0) s+='\n\n'+Res.txt('p', 'recLevel')+' '+Math.round(l.dif);
				if (l.dif>World.world.pers.level) s+='\n\n'+Res.txt('p', 'wrLevel');
				if (World.world.pers.speedShtr>=3) {
					s+='\n\n'+red(Res.txt('p', 'speedshtr3'));
				} else if (World.world.pers.speedShtr==2) {
					s+='\n\n'+red(Res.txt('p', 'speedshtr2'));
				} else if (World.world.pers.speedShtr==1) {
					s+='\n\n'+red(Res.txt('p', 'speedshtr1'));
				}
				if (World.world.pers.speedShtr>=1) s+='\n'+Res.txt('p', 'speedshtr0');
				vis.info.htmlText=s;
			} 
			else if (page2==4) 
			{
				vis.info.y=vis.objectName.y;
				var s:String=Res.messText(event.currentTarget.id.text,0,false);
				s=s.replace(/&lp/g,World.world.pers.persName);
				s=s.replace(/\[/g,"<span class='yel'>");
				s=s.replace(/\]/g,"</span>");
				vis.info.htmlText=s;
			} 
			else if (page2==5) 
			{
				if (vis.ico.numChildren>0) vis.ico.removeChildAt(0);
				Unit.initIco(event.currentTarget.id.text)
				if (Unit.arrIcos[event.currentTarget.id.text]) vis.ico.addChild(Unit.arrIcos[event.currentTarget.id.text]);
				vis.objectName.text=event.currentTarget.objectName.text;
				vis.info.htmlText=Res.txt('u',event.currentTarget.id.text,1)+'\n'+infoUnit(event.currentTarget.id.text, event.currentTarget.kol.text);
				vis.info.y=vis.ico.y+vis.ico.height+20;
				vis.ico.x=685-vis.ico.width/2; //460 910
			}
			if (vis.scText) vis.scText.visible=false;
			if (vis.info.height<vis.info.textHeight && vis.scText) 
			{
				vis.scText.scrollPosition=0;
				vis.scText.maxScrollPosition=vis.info.maxScrollV;
				vis.scText.visible=true;
			}
		}
		
		function getParam(un, pun, cat:String, param:String):* 
		{
			if (un.length()==0) return null;
			if (un[cat].length() && un[cat].attribute(param).length()) return un[cat].attribute(param);
			if (pun==null || pun.length()==0) return null;
			if (pun[cat].length() && pun[cat].attribute(param).length()) return pun[cat].attribute(param);
			return null;
		}
		
		function infoUnit(id:String, kol):String 
		{
			var n:int=0, delta;
			//юнит
			var un=AllData.d.unit.(@id==id);
			if (un.length()==0 || un.@cat!='3') return '';
			//родитель
			var pun;
			if (un.@parent.length()) pun=AllData.d.unit.(@id==un.@parent);
			//дельта
			delta=getParam(un,pun,'vis','dkill');
			if (delta==null) delta=5;
			if (delta<=0) n=10;
			else n=Math.floor(int(kol)/delta);
			
			var v_hp=getParam(un,pun,'comb','hp');
			var v_skin=getParam(un,pun,'comb','skin');
			var v_aqual=getParam(un,pun,'comb','aqual');
			var v_armor=getParam(un,pun,'comb','armor');
			var v_marmor=getParam(un,pun,'comb','marmor');
			var v_dexter=getParam(un,pun,'comb','dexter');
			var v_skill=getParam(un,pun,'comb','skill');
			var v_observ=getParam(un,pun,'comb','observ');
			var v_visdam=getParam(un,pun,'vis','visdam');
			var v_damage=getParam(un,pun,'comb','damage');
			var v_tipdam=getParam(un,pun,'comb','tipdam');
			var v_sdamage=getParam(un,pun,'vis','sdamage');
			var v_stipdam=getParam(un,pun,'vis','stipdam');
			
			var s:String='\n';
			if (un.comb.length()) 
			{
				var node=un.comb[0];
				if (n>=1) 
				{
					//ХП
					s+=Res.txt('p', 'hp')+': '+yel(v_hp)+'\n';
					//порог урона и броня
					if (v_skin) 	s+=Res.txt('p', 'skin')+': '+yel(v_skin)+'\n';
					if (v_aqual) 
					{
						if (v_armor) 	s+=Res.txt('p', 'armor')+': '+yel(v_armor)+' ('+(v_aqual*100)+'%)  ';
						if (v_marmor) 	s+=Res.txt('p', 'marmor')+': '+yel(v_marmor)+' ('+(v_aqual*100)+'%)';
						if (v_armor || v_marmor)s+='\n';
					}
				}
				if (n>=2) 
				{
					if ((v_visdam==1 || v_visdam==3) && v_damage) 
					{
						s+=Res.txt('p', 'dam_melee')+': ';
						if (v_tipdam) s+=blue(Res.txt('p', 'tipdam'+v_tipdam)); else s+=blue(Res.txt('p', 'tipdam2'));
						s+=' ('+yel(v_damage)+')\n'
					}
					if ((v_visdam==2 || v_visdam==3) && v_sdamage) 
					{
						s+=Res.txt('p', 'dam_shoot')+': ';
						if (v_stipdam) s+=blue(Res.txt('p', 'tipdam'+v_stipdam)); else s+=blue(Res.txt('p', 'tipdam0'));
						s+=' ('+yel(v_sdamage)+')\n'
					}
					if (un.w.length()) 
					{
						var wk:Boolean=false;
						for each (var weap in un.w) 
						{
							if (!(weap.@no>0)) 
							{
								if (wk) s+=', ';
								else s+=Res.txt('p', 'enemy_weap')+': ';
								s+=blue(Res.txt('w', weap.@id));
								try 
								{
									var w=AllData.d.weapon.(@id==weap.@id);
									var dam=0;
									if (w.char[0].@damage>0) dam+=Number(w.char[0].@damage);
									if (w.char[0].@damexpl>0) dam+=Number(w.char[0].@damexpl);
									s+=' ('+yel(Res.numb(dam))+')';
								} 
								catch (err) 
								{

								};
								wk=true;
							}
						}
						s+='\n';
					}
				}
				//уклонение
				if (n>=3) {
					if (v_dexter!=null) 	s+=Res.txt('p', 'dexter')+': '+yel((v_dexter>1?'+':'')+Math.round((v_dexter-1)*100)+'%')+'\n';
					if (v_observ) 	s+=Res.txt('p', 'observ')+': '+yel((v_observ>0?'+':'')+v_observ)+'\n';
					if (v_skill!=null) 	s+=Res.txt('p', 'weapskill')+': '+yel(Math.round(v_skill*100)+'%')+'\n';
				}
			}
			//сопротивления
			if (n>=3 && un.vulner.length()) 
			{
				s+=Res.txt('p', 'resists')+': ';
				node=un.vulner[0];
				if (node.@emp.length()) 	s+=vulner(Unit.D_EMP,node.@emp);
				if (node.@bul.length()) 	s+=vulner(Unit.D_BUL,node.@bul);
				if (node.@blade.length()) 	s+=vulner(Unit.D_BLADE,node.@blade);
				if (node.@phis.length()) 	s+=vulner(Unit.D_PHIS,node.@phis);
				if (node.@expl.length()) 	s+=vulner(Unit.D_EXPL,node.@expl);
				if (node.@laser.length()) 	s+=vulner(Unit.D_LASER,node.@laser);
				if (node.@plasma.length()) 	s+=vulner(Unit.D_PLASMA,node.@plasma);
				if (node.@fire.length()) 	s+=vulner(Unit.D_FIRE,node.@fire);
				if (node.@cryo.length()) 	s+=vulner(Unit.D_CRIO,node.@cryo);
				if (node.@spark.length()) 	s+=vulner(Unit.D_SPARK,node.@spark);
				if (node.@venom.length()) 	s+=vulner(Unit.D_VENOM,node.@venom);
				if (node.@acid.length()) 	s+=vulner(Unit.D_ACID,node.@acid);
			}
			return s;
		}
		
		function vulner(n:int, val:Number):String 
		{
			return blue(Res.txt('p', 'tipdam'+n))+': '+yel(Math.round((1-val)*100)+'%   ');
		}
		
		
		override function itemClick(event:MouseEvent):void
		{
			if (pip.gamePause) 
			{
				World.world.gui.infoText('gamePause');
				return;
			}
			if (page2==3 && (pip.travel || Settings.testMode)) 
			{
				if (targetLand!='' && visWMap[targetLand]) 
				{
					visWMap[targetLand].zad.gotoAndStop(1);
				}
				var id=event.currentTarget.name;
				if (game.checkTravel(id)) 
				{
					targetLand=id;
					setStatItems();
					vis.butOk.visible=true;
					if (targetLand!='' && visWMap[targetLand]) 
					{
						visWMap[targetLand].zad.gotoAndStop(2);
					}
				} 
				else 
				{
					vis.butOk.visible=false;
					World.world.gui.infoText('noTravel');
				}
				pip.snd(1);
			}
		}
		
		function transOk(event:MouseEvent):void
		{
			if (pip.gamePause) {
				World.world.gui.infoText('gamePause');
				return;
			}
			if (page2==3 && (pip.travel || Settings.testMode)) 
			{
				if (game.levelArray[targetLand] && game.levelArray[targetLand].loaded) {
					game.beginMission(targetLand);
					pip.onoff(-1);
				} 
				else 
				{
					
				}
			}
			if (page2==2) 
			{
				for each (var task in GameData.d.vendor.task)
				 {
					if (task.@man=='1') continue;
					if (checkQuest(task)) {
						var q:Quest=game.quests[task.@id];
						if (q==null || q.state==0) game.addQuest(task.@id,null,false,false,false);
					}
				}
				setStatus();
			}
		}
		
		public function onMouseDown(event:MouseEvent):void 
		{
			visMap.vmap.startDrag();
		}
		public function onMouseUp(event:MouseEvent):void 
		{
			visMap.vmap.stopDrag();
			setMapSize();
		}
		public function funZoomP(event:MouseEvent):void 
		{
			mapScale++;
			setMapSize(visMap.fon.width/2, visMap.fon.height/2);
		}
		public function funZoomM(event:MouseEvent):void 
		{
			mapScale--;
			setMapSize(visMap.fon.width/2, visMap.fon.height/2);
		}
		public function funCenter(event:MouseEvent):void 
		{
			visMap.vmap.x=visMap.fon.width/2-plTag.x;
			visMap.vmap.y=visMap.fon.height/2-plTag.y;
		}
		
		function setMapSize(cx:Number=350, cy:Number=285):void
		{
			if (mapScale>6) mapScale=6;
			if (mapScale<1) mapScale=1;
			map.scaleX=map.scaleY=mapScale;
			var tx=(visMap.vmap.x-cx)*mapScale/ms;
			var ty=(visMap.vmap.y-cy)*mapScale/ms;
			visMap.vmap.x=tx+cx;
			visMap.vmap.y=ty+cy;
			plTag.x=World.world.level.ggX/Settings.tilePixelWidth*mapScale;
			plTag.y=World.world.level.ggY/Settings.tilePixelHeight*mapScale;
			ms=mapScale;
		}
		
		public override function scroll(dn:int=0):void
		{
			if (page2==1) 
			{
				if (dn>0) mapScale++;
				if (dn<0) mapScale--;
				setMapSize(visMap.mouseX, visMap.mouseY);
			}
		}

		function funWMapClick(event:MouseEvent):void
		{
			trace(event.currentTarget.name);
		}
		function funWMapOver(event:MouseEvent):void
		{
			//trace(event.currentTarget.name);
		}
		
	}
	
}
