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
	import components.XmlBook;
	
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
		var visPageX = 850;
		var visPageY = 540;
		var mapScale:Number = 2;
		var ms:Number = 2;
		var plTag:MovieClip;
		var targetLand:String = '';
		var game:Game;

		public function PipPageInfo(npip:PipBuck, npp:String) 
		{
			itemClass = visPipQuestItem;
			pageClass = visPipInfo;
			isLC = true;
			super(npip,npp);

			//объект карты
			visMap 	= new visPipMap(); 	// .swf linkage
			visWMap = new visPipWMap();	// .swf linkage


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
		

		//set public
		public override function setSubPages():void
		{
			trace('PipPageInfo.as/setSubPages() - updating subPages.');

			vis.bottext.visible		= false;
			vis.butOk.visible		= false;
			statHead.visible		= false;
			visMap.visible			= false;
			visWMap.visible			= false;
			vis.ico.visible			= false;
			vis.nazv.x		= 458;
			vis.info.x				= 458;
			vis.nazv.width	= 413;
			vis.info.width			= 458;
			pip.vis.butHelp.visible	= false;
			targetLand				= '';
			setTopText();

			game = GameSession.currentSession.game;
			if (page2 == 1) 
			{		//карта
				if (GameSession.currentSession.room.noMap) 
				{
					vis.emptytext.text=Res.txt('pip', 'emptymap');
				} 
				else 
				{
					vis.emptytext.text='';
					map.bitmapData=GameSession.currentSession.level.drawMap();
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
				if (GameSession.currentSession.room && GameSession.currentSession.room.base) {
					for each (var task in XmlBook.getXML("vendors").vendor.task)
					{
						if (checkQuest(task)) 
						{
							var j:Quest=game.quests[task.@id];
							if (j==null || j.state==0) 
							{
								vis.butOk.visible=true;
								vis.butOk.text.text=Res.txt('pip', 'alltask');
								break;
							}
						}
					}
				}
			} 
			else if (page2 == 3) 	//общая карта
			{
				vis.nazv.x=vis.info.x=584;
				vis.nazv.width=287;
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
				vis.butOk.text.text=Res.txt('pip', 'trans');
				visWMap.visible=true;
				pip.vis.butHelp.visible=true;
				pip.helpText=Res.txt('pip','helpWorld',0,true);
			} 
			else if (page2 == 4)
			{	//записи
				var doparr:Array=[];
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
					title=title.replace(/&lp/g,GameSession.currentSession.pers.persName);
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
				statHead.nazv.text='';
				statHead.mq.visible=false;
				statHead.kol.text=Res.txt('pip', 'frag');
				vis.ico.visible=true;
				for each (var xml in XmlBook.getXML("units").unit)
				{
					if (xml && xml.@cat.length()) 
					{
						var n:Object={id:xml.@id, objectName:Res.txt('unit',xml.@id), cat:xml.@cat, kol:-1};
						if (xml.@cat=='3' && GameSession.currentSession.game.triggers['frag_'+xml.@id]>=0) n.kol=int(GameSession.currentSession.game.triggers['frag_'+xml.@id]);
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
		//set public
		public override function setStatItem(item:MovieClip, obj:Object):void
		{
			item.id.text 			= obj.id;
			item.id.visible 		= false;
			item.nazv.text 	= obj.objectName;
			item.mq.visible 	 	= false;
			item.ramka.visible 		= false;
			item.nazv.alpha 	= 1;
			item.kol.text 			= '';
			item.kol.visible 		= false;
			if (page2 == 2) 
			{
				item.nazv.x=32;
				item.mq.visible=obj.main;
				item.mq.gotoAndStop(1);
				if (obj.state==2) 
				{
					item.nazv.alpha=item.mq.alpha=0.4;
					item.nazv.text+=' ('+Res.txt('pip', 'done')+')';
				} 
				else 
				{
					item.nazv.alpha=item.mq.alpha=1;
				}
			} 
			else if (page2==3) 
			{

			} 
			else if (page2==4) 
			{
				item.nazv.x=32;
				item.nazv.htmlText=obj.objectName.substr((obj.objectName.charAt(0)==' ')?3:0, 60);
				item.kol.text=obj.objectName;
				item.mq.visible=true;
				item.mq.alpha=1;
				item.mq.gotoAndStop(obj.ico+1);
			} 
			else if (page2==5) 
			{
				item.nazv.x=5;
				if (obj.cat=='1') item.nazv.htmlText='<b>'+item.nazv.text+'</b>';
				if (obj.cat=='2') item.nazv.htmlText='      <b>'+item.nazv.text+'</b>';
				if (obj.cat=='3') item.nazv.htmlText='            '+item.nazv.text;
				if (obj.kol>0) item.kol.text=obj.kol;
				item.kol.visible=true;
			}
		}

		
		//set public
		public override function statInfo(event:MouseEvent):void //информация об элементе
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
				vis.nazv.text=Res.txt('map',l.id);
				var s:String=Res.txt('map',l.id,1);
				if (!l.visited) s+="\n\n<span class ='blu'>"+Res.txt('pip', 'ls1')+"</span>";
				else if (l.passed) s+="\n\n<span class ='or'>"+Res.txt('pip', 'ls2')+"</span>";
				else if (l.tip=='base') s+="\n\n<span class ='or'>"+Res.txt('pip', 'ls4')+"</span>";
				else if (l.tip=='rnd') s+="\n\n<span class ='yel'>"+Res.txt('pip', 'ls3')+": "+(l.landStage+1)+"</span>";
				if (l.tip=='rnd' && l.kolAllProb>0) {
					s+="\n<span class ='yel'>"+Res.txt('pip', 'kolProb')+': '+l.kolClosedProb+'/'+l.kolAllProb+"</span>";
				}
				if (l.dif>0) s+='\n\n'+Res.txt('pip', 'recLevel')+' '+Math.round(l.dif);
				if (l.dif>GameSession.currentSession.pers.level) s+='\n\n'+Res.txt('pip', 'wrLevel');
				if (GameSession.currentSession.pers.speedShtr>=3) {
					s+='\n\n'+red(Res.txt('pip', 'speedshtr3'));
				} else if (GameSession.currentSession.pers.speedShtr==2) {
					s+='\n\n'+red(Res.txt('pip', 'speedshtr2'));
				} else if (GameSession.currentSession.pers.speedShtr==1) {
					s+='\n\n'+red(Res.txt('pip', 'speedshtr1'));
				}
				if (GameSession.currentSession.pers.speedShtr>=1) s+='\n'+Res.txt('pip', 'speedshtr0');
				vis.info.htmlText=s;
			} 
			else if (page2==4) 
			{
				vis.info.y = vis.nazv.y;
				var s:String = Res.messText(event.currentTarget.id.text, 0, false);
				s=s.replace(/&lp/g,GameSession.currentSession.pers.persName);
				s=s.replace(/\[/g,"<span class='yel'>");
				s=s.replace(/\]/g,"</span>");
				vis.info.htmlText = s;
			} 
			else if (page2 == 5) 
			{
				if (vis.ico.numChildren>0) vis.ico.removeChildAt(0);
				Unit.initIco(event.currentTarget.id.text)
				if (Unit.arrIcos[event.currentTarget.id.text]) vis.ico.addChild(Unit.arrIcos[event.currentTarget.id.text]);
				vis.nazv.text = event.currentTarget.nazv.text;
				vis.info.htmlText=Res.txt('unit',event.currentTarget.id.text,1)+'\n'+infoUnit(event.currentTarget.id.text, event.currentTarget.kol.text);
				vis.info.y=vis.ico.y+vis.ico.height+20;
				vis.ico.x = 685 - vis.ico.width / 2;
			}
			if (vis.scText) vis.scText.visible=false;
			if (vis.info.height<vis.info.textHeight && vis.scText) 
			{
				vis.scText.scrollPosition=0;
				vis.scText.maxScrollPosition=vis.info.maxScrollV;
				vis.scText.visible=true;
			}
		}
		
		//set public
		public function getParam(un, pun, cat:String, param:String):* 
		{
			if (un.length()==0) return null;
			if (un[cat].length() && un[cat].attribute(param).length()) return un[cat].attribute(param);
			if (pun==null || pun.length()==0) return null;
			if (pun[cat].length() && pun[cat].attribute(param).length()) return pun[cat].attribute(param);
			return null;
		}
		
		//set public
		public function infoUnit(id:String, kol):String 
		{
			var n:int = 0, delta;
			//юнит
			var un = XmlBook.getXML("units").unit.(@id == id);
			if (un.length()==0 || un.@cat!='3') return '';
			//родитель
			var pun;
			if (un.@parent.length()) 
			{
				var pun = XmlBook.getXML("units").unit.(@id == un.@parent);
			}
			//дельта
			delta=getParam(un, pun, 'vis', 'dkill');
			if (delta == null) delta = 5;
			if (delta <= 0) n = 10;
			else n = Math.floor(int(kol) / delta);
			
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
					s += Res.txt('pip', 'hp')+': '+yel(v_hp)+'\n';
					//порог урона и броня
					if (v_skin) 	s+=Res.txt('pip', 'skin')+': '+yel(v_skin)+'\n';
					if (v_aqual) 
					{
						if (v_armor) 	s+=Res.txt('pip', 'armor')+': '+yel(v_armor)+' ('+(v_aqual*100)+'%)  ';
						if (v_marmor) 	s+=Res.txt('pip', 'marmor')+': '+yel(v_marmor)+' ('+(v_aqual*100)+'%)';
						if (v_armor || v_marmor)s+='\n';
					}
				}
				if (n>=2) 
				{
					if ((v_visdam==1 || v_visdam==3) && v_damage) 
					{
						s+=Res.txt('pip', 'dam_melee')+': ';
						if (v_tipdam) s+=blue(Res.txt('pip', 'tipdam'+v_tipdam)); else s+=blue(Res.txt('pip', 'tipdam2'));
						s+=' ('+yel(v_damage)+')\n'
					}
					if ((v_visdam==2 || v_visdam==3) && v_sdamage) 
					{
						s+=Res.txt('pip', 'dam_shoot')+': ';
						if (v_stipdam) s+=blue(Res.txt('pip', 'tipdam'+v_stipdam)); else s+=blue(Res.txt('pip', 'tipdam0'));
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
								else s+=Res.txt('pip', 'enemy_weap')+': ';
								s+=blue(Res.txt('weapon', weap.@id));
								try 
								{
									var w = XmlBook.getXML("weapons").weapon.(@id == weap.@id);
									var dam=0;
									if (w.char[0].@damage>0) dam+=Number(w.char[0].@damage);
									if (w.char[0].@damexpl>0) dam+=Number(w.char[0].@damexpl);
									s+=' ('+yel(Res.numb(dam))+')';
								} 
								catch (err) 
								{

								}
								wk=true;
							}
						}
						s+='\n';
					}
				}
				//уклонение
				if (n>=3) {
					if (v_dexter!=null) 	s+=Res.txt('pip', 'dexter')+': '+yel((v_dexter>1?'+':'')+Math.round((v_dexter-1)*100)+'%')+'\n';
					if (v_observ) 	s+=Res.txt('pip', 'observ')+': '+yel((v_observ>0?'+':'')+v_observ)+'\n';
					if (v_skill!=null) 	s+=Res.txt('pip', 'weapskill')+': '+yel(Math.round(v_skill*100)+'%')+'\n';
				}
			}
			//сопротивления
			if (n>=3 && un.vulner.length()) 
			{
				s+=Res.txt('pip', 'resists')+': ';
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
		
		//set public
		public function vulner(n:int, val:Number):String 
		{
			return blue(Res.txt('pip', 'tipdam'+n))+': '+yel(Math.round((1-val)*100)+'%   ');
		}
		
		
		//set public
		public override function itemClick(event:MouseEvent):void
		{
			if (pip.gamePause) 
			{
				GameSession.currentSession.gui.infoText('gamePause');
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
					GameSession.currentSession.gui.infoText('noTravel');
				}
				pip.snd(1);
			}
		}
		
		//set public
		public function transOk(event:MouseEvent):void
		{
			if (pip.gamePause) {
				GameSession.currentSession.gui.infoText('gamePause');
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
				for each (var task in XmlBook.getXML("vendors").vendor.task)
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
		
		//set public
		public function setMapSize(cx:Number=350, cy:Number=285):void
		{
			if (mapScale>6) mapScale=6;
			if (mapScale<1) mapScale=1;
			map.scaleX=map.scaleY=mapScale;
			var tx=(visMap.vmap.x-cx)*mapScale/ms;
			var ty=(visMap.vmap.y-cy)*mapScale/ms;
			visMap.vmap.x=tx+cx;
			visMap.vmap.y=ty+cy;
			plTag.x=GameSession.currentSession.level.ggX/Settings.tilePixelWidth*mapScale;
			plTag.y=GameSession.currentSession.level.ggY/Settings.tilePixelHeight*mapScale;
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

		//set public
		public function funWMapClick(event:MouseEvent):void
		{
			trace(event.currentTarget.name);
		}

		//set public
		public function funWMapOver(event:MouseEvent):void
		{
			//trace(event.currentTarget.name);
		}
		
	}
	
}
