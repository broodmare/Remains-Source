package interdata 
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.display.MovieClip;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.StyleSheet;
	import flash.events.MouseEvent;
	
	import fl.events.ScrollEvent;
	
	import weapondata.Weapon;
	import unitdata.UnitPlayer;
	import graphdata.Emitter;
	import unitdata.Unit;
	import unitdata.Invent;
	import servdata.Item;
	import servdata.Script;
	import weapondata.WPaint;
	
	import components.Settings;
	import systems.Languages;
	
	public class GUI 
	{
		public var vis:MovieClip;
		public var active:Boolean = true;
		var weapon:TextField, holder:TextField, ammo:TextField, mana:TextField, celobj:TextField, info:TextField, item:TextField, hp:TextField, vitem:MovieClip, mess:MovieClip, dial:MovieClip, inform:MovieClip, imp:MovieClip, pet:MovieClip, pr_bar:MovieClip, levit_poss:MovieClip, tharrow:MovieClip;
		var txtTele:String, txtOpen:String, txtChance:String, txtSoft:String, txtHard:String, txtVeryHard:String, txtUnreal:String, txtUndef0:String, txtUndef1:String, txtUndef2:String, txtClose:String, txtHeavy:String;
		var txtMagia:String, txtArmorMana:String, txtMagiaOver:String, txtH2o:String, txtH2oOver:String, txtStam:String, txtUnlock:String, txtRemine:String, txtUse:String, txtHold:String, txtLock:String, txtZhopa:String, txtEmpty:String, txtDrop:String, txtOd:String;
		public var gg:UnitPlayer;
		public var celObj:Obj, prevObj:Obj, t_show:int = 0;
		
		public var guiPause:Boolean = false;
		public var showDop:Boolean  = false; // Show additional info when the cursor is in the lower part of the screen
		public var showFav:Boolean  = false; // Show additional info when the selector is called
		
		var arr:Array;		// Array of weapons for the selector
		var arrfav:Array;	// Array of weapons with hotkeys
		var wSelN:int = 0;
		var selMode:int = 0;
		
		var prevInfoText = '';
		var bulbText = '';
		
		public var style:StyleSheet = new StyleSheet(); 
		var styleObj:Object = {};
		var kolStr:int = 0, t_info:int = 0, t_sel:int = 0, t_bulb:int = 0, t_visibility:int = 30, float_dy:int = 0;
		public var t_item:int = 200;
		public var t_od:int   = 200;
		
		var screenX:int = 1200;
		var screenY:int = 800;
		
		public var t_mess:int = 0;
		var a_mess:Number  = 0;
		var id_mess:String = '';
		var s_mess:String  = '';
		
		var infoAlpha = 1;
		var realAlpha = 1;
		
		var kolEff:int = 12;
		var veff:Array;
		var effIsVis:Boolean = false;
		
		var informScript:Script;
		public var dialScript:Script;

		public function GUI(vgui:MovieClip) 
		{
			vis = vgui;
			vis.mouseChildren = false;
			vis.mouseEnabled = false;
			
			styleObj.color = "#00FF99"; 
			style.setStyle(".r", styleObj); 	// Default is green
			
			styleObj.color = "#999999"; 
			style.setStyle(".r0", styleObj);	// 0 - gray
			
			styleObj.color = "#00FFFF"; 
			style.setStyle(".r1", styleObj);	// 1 - cyan
			
			styleObj.color = "#FFFF00"; 
			style.setStyle(".r2", styleObj); 	// 2 - yellow
			
			styleObj.color = "#FF9900"; 
			style.setStyle(".r3", styleObj);	// 3 - orange
			
			styleObj.color = "#FC7FED"; 
			style.setStyle(".r4", styleObj);	// 4 - pink
			
			styleObj.color = "#FF3333"; 
			style.setStyle(".r5", styleObj);	// 5 - red
			
			styleObj.color = "#BB99FF"; 
			style.setStyle(".r6", styleObj);	// 6 - purple
			
			styleObj.color = "#C4926C"; 
			style.setStyle(".r7", styleObj);	// 7 - brown
			
			styleObj.color = "#98BD34"; 
			style.setStyle(".r8", styleObj);	// 8 - khaki
			
			styleObj.color = "#7777FF"; 
			style.setStyle(".r9", styleObj);	// 9 - blue
			
			styleObj.color = "#FF3333"; 
			style.setStyle(".warn", styleObj);	// warn - red

			styleObj.color = "#FF236A"; 
			style.setStyle(".crim", styleObj); 	// alicorn armor
			
			styleObj.fontWeight = "bold"; 
			styleObj.color = "#FFFF00"; 
			style.setStyle(".yel", styleObj); 	// highlighting important
			
			
			vis.toptext.visible = false;
			PipPage.setStyle(vis.toptext.txt);
			info = vis.info.getChildByName('infoText') as TextField;
			info.text = '';
			info.autoSize = TextFieldAutoSize.RIGHT;
			info.multiline = true;
			info.styleSheet = style;
			vis.odBar.bar.cacheAsBitmap=vis.odBar.bar2.cacheAsBitmap=vis.odBar.maska.cacheAsBitmap=vis.odBar.maska2.cacheAsBitmap=true;
			vis.odBar.bar.mask = vis.odBar.maska;
			vis.odBar.bar2.mask = vis.odBar.maska2;
			setSats(false);
			weapon = vis.textWeapon.getChildByName('weapon') 	as TextField;
			weapon.styleSheet = style;
			holder = vis.textWeapon.getChildByName('holder') 	as TextField;
			holder.styleSheet = style;
			ammo = vis.textWeapon.getChildByName('ammo') 	as TextField;
			celobj = vis.getChildByName('celObj') 			as TextField;
			celobj.autoSize = TextFieldAutoSize.CENTER;
			celobj.styleSheet = style;
			item = vis.textItem.getChildByName('kolItem') 	as TextField;
			mana = vis.textMana.getChildByName('mana') 		as TextField;
			hp = vis.getChildByName('hp') 					as TextField;
			vitem = vis.getChildByName('vItem') 			as MovieClip;
			mess = vis.getChildByName('mess') 				as MovieClip;
			dial = vis.getChildByName('dial') 				as MovieClip;
			inform = vis.getChildByName('inform') 			as MovieClip;
			imp = vis.getChildByName('imp') 				as MovieClip;
			pet = vis.getChildByName('hpPet') 				as MovieClip;
			pr_bar = vis.getChildByName('pr_bar') 			as MovieClip;
			levit_poss = vis.getChildByName('levit_poss') 	as MovieClip;
			tharrow = vis.getChildByName('tharrow') 		as MovieClip;
			vis.portCel.gotoAndStop(1);
			vis.portCel.visible = false;

			txtTele			= Res.txt('gui', 'tele');
			txtOpen			= Res.txt('gui', 'open');
			txtSoft			= Res.txt('gui', 'soft');
			txtHard			= Res.txt('gui', 'hard');
			txtVeryHard		= Res.txt('gui', 'veryhard');
			txtUnreal		= Res.txt('gui', 'unreal');
			txtUndef0		= Res.txt('gui', 'undef0');
			txtUndef1		= Res.txt('gui', 'undef1');
			txtUndef2		= Res.txt('gui', 'undef2');
			txtClose		= Res.txt('gui', 'close');
			txtUnlock		= Res.txt('gui', 'unlock');
			txtRemine		= Res.txt('gui', 'remine');
			txtUse			= Res.txt('gui', 'use');
			txtLock			= Res.txt('gui', 'lock');
			txtZhopa		= Res.txt('gui', 'zhopa');
			txtEmpty		= Res.txt('gui', 'empty');
			txtDrop			= Res.txt('gui', 'drop');
			txtHold			= Res.txt('gui', 'hold');
			txtHeavy		= Res.txt('gui', 'heavy');
			txtMagia		= Res.txt('gui', 'magia');
			txtArmorMana	= Res.txt('gui', 'armormana');
			txtChance		= Res.txt('gui', 'chance');
			txtMagiaOver	= Res.txt('gui', 'magiaover');
			txtH2o			= Res.txt('gui', 'h2o');
			txtH2oOver		= Res.txt('gui', 'h2over');
			txtStam			= Res.txt('gui', 'stam');
			txtOd			= Res.txt('pip', 'ap');

			vis.odBar.txt.text		= txtOd;
			vis.selector.visible	= false;
			vis.fav.visible			= false;
			vis.status.visible		= false;
			vis.hpbarboss.visible	= false;
			mess.alpha = 0;
			mess.visible 			= false;
			mess.mess.styleSheet 	= style;
			mess.mess.autoSize 		= TextFieldAutoSize.CENTER;
			dial.visible 			= false;
			inform.visible 			= false;
			imp.visible 			= false;
			levit_poss.visible 		= false;
			tharrow.visible 		= false;
			dial.txt.styleSheet 	= style;
			inform.txt.styleSheet 	= style;
			imp.txt.styleSheet 		= style;
			veff = [];
			for (var i:int = 0; i < kolEff; i++) 
			{
				veff[i] = vis['eff' + i];
			}
			informScript = new Script(<scr act = "inform" val = "id"/>);
			dialScript 	 = new Script(<scr act = "dialog" val = "id"/>);
			vis.inform.but0.addEventListener(MouseEvent.MOUSE_DOWN, showHelp);
			vis.inform.but0.text.text = Res.txt('gui', 'help');
			vis.blood.visible = false;
			vis.blood.stop();
		}
		
		public function resizeScreen(nx:int, ny:int):void
		{
			screenX=nx;
			screenY=ny;
			vis.textWeapon.y=ny-20;
			vis.info.x=nx-20;
			vis.odBar.x=nx-10;
			vis.odBar.y=ny-10;
			vis.visibility.x=nx-10;
			vis.visibility.y=ny-50;
			vis.selector.x=nx/2;
			vis.selector.y=ny/2;
			vis.sats.scaleX=nx/100;
			vis.sats.scaleY=ny/100;
			vis.hpbarboss.x=nx/2;
			var r:Number = nx - 275 * 2;

			if (r > 500) 
			{
				mess.x = 275;
				mess.mess.width = nx - 275 * 2;
			} 
			else 
			{
				mess.mess.width = 500;
				mess.x = (nx - 500) / 2;
			}

			if (screenX < 1200) 
			{
				dial.scaleX = dial.scaleY = screenX / 1200;
				dial.x = 0;
			} 
			else 
			{
				dial.scaleX = dial.scaleY = 1;
				dial.x = (screenX - 1200) / 2;
			}
			
			inform.x = Math.round(screenX / 2);
			imp.x 	 = Math.round(screenX / 2);
			imp.y 	 = Math.round(screenY / 2 - 50);
		}
		
		public function showSelector(turn:int=0, mode:int=0):void
		{
			if (turn != 0) t_sel = 60;
			if (vis.selector.visible) 
			{
				wSelN += turn;
				if (wSelN < 0) wSelN += arr.length;
				if (wSelN >= arr.length) wSelN -= arr.length;
				setSelector();
				return;
			}
			selMode = mode;
			wSelN = 0;
			var inv:Invent = GameSession.currentSession.invent;
			inv.getKolAmmos();
			arr = [];
			arrfav = [];
			if (mode==0) // Choosing a weapon
			{		
				for each(var obj in inv.weapons) 
				{
					if (obj is Weapon) 
					{
						var w:Weapon=obj as Weapon;
						var n:Object={id:w.id, objectName:w.objectName, skill:w.skill, sort1:w.skill, sort2:w.lvl};
						if (inv.favIds[w.id]) n.fav=inv.favIds[w.id];
						if (w.tip < 4) 
						{
							n.hp = Math.round(w.hp / w.maxhp * 100) + '%';
						}
						if (w.ammo != '' && w.ammo != null) 
						{
							if (inv.ammos[w.ammoBase] != null) n.ammo = inv.ammos[w.ammoBase] + w.hold;
							else if (inv.items[w.ammo] != null) n.ammo = inv.items[w.ammo].kol + w.hold;
							if (w.ammoBase != '') n.ammotip = (w.tip != 4) ? inv.items[w.ammoBase].objectName:'';
						}
						if (n.fav > 0) arrfav[n.fav] = n;
						if (w.respect == 1 || w.respect == 3 || w.spell)  continue;
						if (w.avail() <= 0 && w != gg.currentWeapon) continue;
						if (w.alicorn && !Settings.alicorn) continue;
						arr.push(n);
					}
				}
				if (arr.length > 1) arr.sortOn(['sort1','sort2'],[Array.NUMERIC,Array.NUMERIC]);
				for (var i in arr) 
				{
					if (gg.currentWeapon && arr[i].id==gg.currentWeapon.id) wSelN=i;
				}
				for (i=1; i<=Settings.kolHK*2+7; i++) 
				{
					if (i == Settings.kolHK*2+5) 
					{
						if (gg.throwWeapon) 
						{
							w=gg.throwWeapon;
							n={id:w.id, objectName:w.objectName, skill:w.skill, fav:i};
							if (w.ammo!='') n.ammo=inv.items[w.ammo].kol;
						} 
						else continue;
					} 
					else if (i == Settings.kolHK*2+6) 
					{
						if (gg.magicWeapon) 
						{
							w=gg.magicWeapon;
							n={id:w.id, objectName:w.objectName, skill:w.skill, fav:i};
							if (w.ammo!='') n.ammo=inv.items[w.ammo].kol;
						} 
						else continue;
					} 
					else if (i==Settings.kolHK*2+7) 
					{
						if (gg.currentSpell) 
						{
							n={id:gg.currentSpell.id, objectName:gg.currentSpell.objectName, fav:i};
							if (gg.currentSpell.t_culd>0) 
							{
								n.ammo=Math.ceil(gg.currentSpell.t_culd/Settings.fps)+' '+Res.txt('gui', 'sec');
							} 
							else n.ammo=Res.txt('gui', 'ready')
						} 
						else continue;
					} 
					else 
					{
						if (arrfav[i] || inv.fav[i]==null) continue;
						n={id:inv.fav[i], fav:i};
						n.objectName=Res.txt('item',n.id);

						if (!Res.istxt('item',n.id)) 
						{
							n.objectName=Res.txt('armor',n.id);
						} 
						else if (inv.items[n.id]!=null) 
						{
							n.ammo=inv.items[n.id].kol;
						} 
						else 
						{
							if (inv.items[w.ammoBase]!=null) n.ammo=inv.items[w.ammoBase].kol;
							else n.ammo=inv.items[w.ammo].kol;
						}

						if (inv.spells[n.id]!=null) 
						{
							if (inv.spells[n.id].t_culd>0) 
							{
								n.ammo=Math.ceil(inv.spells[n.id].t_culd/Settings.fps)+' '+Res.txt('gui', 'sec');
							} 
							else n.ammo=Res.txt('gui', 'ready')
						}
					}
					arrfav[i]=n;
				}
				if (arr.length > 1 || turn == 0) 
				{
					if (turn!=0) 
					{
						showFav=true;
						vis.selector.visible=true;
						gg.visSel=true;
						setSelector();
					}
					setFavs();
					setStatus();
				}
				gg.pers.setPonpon(vis.status.pon);
			} 
			else 
			{		// Choosing ammunition
				if (gg.currentWeapon==null || gg.currentWeapon.holder<=0 || gg.currentWeapon.ammoBase=='' || gg.currentWeapon.recharg>0 || gg.currentWeapon.alicorn || gg.currentWeapon.tip>=4) return;
				for each(var obj:Object in inv.items) 
				{
					if (obj && obj.base==gg.currentWeapon.ammoBase) 
					{
						n = {id:obj.id, objectName:obj.objectName, ammo:obj.kol};
						arr.push(n);
					}
				}
				if (arr.length > 1) 
				{
					for (var i in arr) 
					{
						if (gg.currentWeapon.ammo==arr[i].id) wSelN=i;
					}
					vis.selector.visible=true;
					gg.visSel=true;
					setSelector();
				}
			}
		}
		
		public function setFavs():void
		{
			for (var i:int = 1; i<=Settings.kolHK*2+7; i++) 
			{
				var mc:MovieClip=vis.fav.getChildByName('s'+i);
				if (arrfav[i]) 
				{
					mc.visible=true;
					mc.nazv.text=arrfav[i].objectName;

					if (arrfav[i].ammo!=null) mc.ammo.text=arrfav[i].ammo;
					else mc.ammo.text='';

					if (i<=Settings.kolHK) mc.fav.text=GameSession.currentSession.ctr.retKey('keyWeapon'+arrfav[i].fav);
					else if (i<=Settings.kolHK*2+4) 
					{
						if (i<=Settings.kolHK*2) mc.fav.text='^'+GameSession.currentSession.ctr.retKey('keyWeapon'+(arrfav[i].fav-Settings.kolHK));
						else mc.fav.text=GameSession.currentSession.ctr.retKey('keySpell'+(arrfav[i].fav-Settings.kolHK*2));
						mc.x=screenX-400;
					} 
					else if (i==Settings.kolHK*2+5) mc.fav.text=GameSession.currentSession.ctr.retKey('keyGrenad');
					else if (i==Settings.kolHK*2+6) mc.fav.text=GameSession.currentSession.ctr.retKey('keyMagic');
					else if (i==Settings.kolHK*2+7) mc.fav.text=GameSession.currentSession.ctr.retKey('keyDef');

					try 
					{
						mc.trol.gotoAndStop('w'+arrfav[i].skill);
					} 
					catch (err) 
					{
						mc.trol.gotoAndStop(1);
					}
				} 
				else 
				{
					mc.visible=false;
				}
			}
		}
		
		public function setStatus():void
		{
			if (GameSession.currentSession.game && GameSession.currentSession.game.triggers['nomed']) return;
			vis.status.visible=active;
		}
		
		public function setSelector():void
		{
			if (arr==null || arr.length == 0) return;
			var n:int=wSelN-3;
			if (n < 0) n += arr.length;
			if (n < 0) n += arr.length;
			for (var i:int = 1; i<=7; i++) 
			{
				var mc:MovieClip=vis.selector.getChildByName('s'+i);
				if (selMode==1 && (i==1 || i==7)) mc.visible=false;
				else mc.visible=true;
				mc.nazv.text=arr[n].objectName;
				if (arr[n].ammo!=null) mc.ammo.text=arr[n].ammo;
				else mc.ammo.text='';
				if (arr[n].fav>Settings.kolHK && arr[n].fav<=Settings.kolHK*2) mc.fav.text='^'+GameSession.currentSession.ctr.retKey('keyWeapon'+(arr[n].fav-Settings.kolHK));
				else if (arr[n].fav>0 && arr[n].fav<=Settings.kolHK) mc.fav.text=GameSession.currentSession.ctr.retKey('keyWeapon'+arr[n].fav);
				else mc.fav.text='';
				try 
				{
					mc.trol.gotoAndStop('w'+arr[n].skill);
				} 
				catch (err) 
				{
					mc.trol.gotoAndStop(1);
				}
				n++;
				if (n>=arr.length) n-=arr.length;
			}
		}
		
		public function unshowSelector(res:int=0):void
		{
			t_sel=0;
			vis.selector.visible=gg.visSel=false;
			showFav=false;
			vis.status.visible=false;
			try 
			{
				if (res>0) 
				{
					if (selMode==0 && (gg.currentWeapon==null || arr[wSelN].id!=gg.currentWeapon.id)) gg.changeWeapon(arr[wSelN].id);
					if (selMode==1 && gg.currentWeapon && gg.currentWeapon.ammo!=arr[wSelN].id) gg.currentWeapon.initReload(arr[wSelN].id);
				}
			} 
			catch(err) 
			{

			}
		}
		
		public function hpBarOnOff(turn:Boolean=true):void
		{
			vis.hpBar.visible=vis.hp.visible=vis.manaBar.visible=vis.xpBar.visible=(turn && active);
		}
		
		public function allOff():void
		{
			active=false;
			vis.hpBar.visible=vis.hp.visible=vis.manaBar.visible=vis.xpBar.visible=vis.textItem.visible=vis.textWeapon.visible=active;
			vis.odBar.visible=vis.hpPet.visible=vis.vItem.visible=vis.textMana.visible=active;
			vis.eff0.visible=vis.eff1.visible=vis.eff2.visible=vis.eff3.visible=vis.eff4.visible=vis.eff5.visible=active;
			vis.hpbarboss.visible=active;
		}

		public function allOn():void
		{
			active=true;
			vis.hpBar.visible=vis.hp.visible=vis.manaBar.visible=vis.xpBar.visible=vis.textItem.visible=vis.textWeapon.visible=vis.textMana.visible=true;
			setAll();			
		}

		
		public function setHolder():void
		{
			if (gg.currentWeapon) 
			{
				var w:Weapon = gg.currentWeapon;
				if (w.ammo) 
				{
					var n = '';
					var k:int = GameSession.currentSession.invent.items[w.ammo].kol;
					var s:String;
					if (w.tip != 4) 
					{
						if (w.hold < w.holder / 4) n = 2;
						if (w.hold < w.rashod) n = 3;
						if (w.hold + k < w.rashod) n = 5;
					}
					s = "<span class = 'r" + n + "'>";
					if (w.tip != 4) s += w.hold + '/' + w.holder + ' (' + k + ')';
					else s += k + w.hold;
					s += "</span>";
					holder.htmlText = s;
				} 
				else holder.htmlText = '';
			} 
			else holder.htmlText = '';
		}
		
		public function setWeapon():void
		{
			if (gg.currentWeapon) 
			{
				var s:String;
				var w:Weapon=gg.currentWeapon;
				var r:Number = Math.round(w.hp/w.maxhp*100);
				var n = '';

				if (r <= 0) 
				{
					r = 0;
					n = 5;
				} 
				else if (r < 20) 
				{
					n = 3;
				} 
				else if (r < 50) 
				{
					n = 2;
				}

				if (w.avail()==-1) n = 5;
				s="<span class = 'r"+n+"'>"+w.objectName;
				if (w.tip!=0 && w.tip<4) s+=' ('+r+'%)';
				s+="</span>";
				weapon.htmlText=s;
				vis.textWeapon.x=20+weapon.textWidth;

				if (w.ammo != '' && w.tip != 4) 
				{
					ammo.text = GameSession.currentSession.invent.items[w.ammo].objectName;
				}
				else if (w.id == 'paint') 
				{
					ammo.text = (w as WPaint).paintNazv;
				}
				else 
				{
					ammo.text = '';
				}
			} 
			else 
			{
				ammo.text 		= '';
				weapon.htmlText = '';
			}
			setHolder();
		}
		
		public function setOd():void
		{
			if (gg.currentWeapon == null || gg.currentWeapon.noSats) vis.odBar.visible = false;
			else vis.odBar.visible = active;
			t_od = 200;
			vis.odBar.bar.scaleX  = GameSession.currentSession.sats.odv / 50;
			vis.odBar.bar2.scaleX = GameSession.currentSession.sats.od  / 50;
		}
		
		public function setItems(turn:int = 0):void
		{
			if (turn < 0) 
			{
				vitem.visible = false;
				item.visible = false;
				vitem.gotoAndStop(1);
				item.text = '';
				return;
			}
			if (GameSession.currentSession.invent.cItem < 0) 
			{
				vitem.visible = false;
				item.visible = false;
				vitem.gotoAndStop(1);
				item.text = '';
			} 
			else 
			{
				t_item = 200;
				var ci:String = GameSession.currentSession.invent.itemsId[GameSession.currentSession.invent.cItem];
				vitem.visible = item.visible=active;
				try 
				{
					vitem.gotoAndStop(ci);
				} 
				catch(err) 
				{
					vitem.gotoAndStop(1);
				}
				item.text = Res.txt('item', ci) + ' ('+GameSession.currentSession.invent.items[ci].kol + ')';
			}
			setOtstup();
		}
		public function setHp():void
		{
			if (gg.hp>0) 
			{
				vis.hpBar.hp.scaleX=gg.hp/gg.maxhp;
				vis.hpBar.healhp.scaleX=Math.min(1,(gg.hp+gg.healhp)/gg.maxhp);
				if (gg.rad<=gg.maxhp) vis.hpBar.rad.scaleX=gg.rad/gg.maxhp;
				hp.text=Math.ceil(gg.hp)+'/'+Math.ceil(gg.maxhp);
				if (gg.hp/gg.maxhp<0.2 && vis.hpBar.hp.currentFrame==1) vis.hpBar.hp.gotoAndPlay(2);
				if (gg.hp/gg.maxhp>=0.2 && vis.hpBar.hp.currentFrame!=1) vis.hpBar.hp.gotoAndStop(1);
			} 
			else 
			{
				vis.hpBar.hp.scaleX=0;
				vis.hpBar.healhp.scaleX=0;
				hp.text='';
			}
			if (gg.drad>1)
			{
				vis.hpBar.drad.alpha=1;
			} 
			else 
			{
				vis.hpBar.drad.alpha=gg.drad;
			}
		}
		
		public function setVisibility():void
		{
			if (GameSession.currentSession.pip.active || !gg.showObsInd || gg.obs<3) 
			{
				vis.visibility.visible=false;
			} 
			else 
			{
				vis.visibility.visible=true;
				vis.visibility.gotoAndStop(Math.floor(gg.obs/gg.maxObs*40+1));
				GameSession.currentSession.cam.setKoord(vis.visibility,gg.X,gg.Y-80);
			}
		}
		
		public function setMana():void
		{
			if (gg.mana<10) mana.text=txtMagiaOver;
			else if (gg.mana<995 || gg.t_culd>0 || gg.currentSpell && gg.currentSpell.t_culd>0) mana.text=txtMagia+' '+Math.round(gg.mana/10)+'%';
			else mana.text='';
			vis.manaBar.mana.scaleX=gg.pers.manaHP/gg.pers.inMaxMana;
			if (gg.teleObj && gg.teleObj.massa>0.1) mana.appendText(' '+Math.round(gg.teleObj.massa*50)+'kg');
			if (gg.dmana<-5) mana.appendText(' ('+txtHeavy+')');
			if (gg.h2o<500) 
			{
				if (mana.text!='') mana.text+='\n';
				if (gg.h2o<10) mana.text+=txtH2oOver;
				else mana.text+=txtH2o+' '+Math.round(gg.h2o/10)+'%';
			}
			if (gg.stam<500 || Settings.testBattle && gg.stam<980) 
			{
				if (mana.text!='') mana.text+='\n';
				if (gg.stam<10) mana.text+=txtStam+' 0%';
				else mana.text+=txtStam+' '+Math.round(gg.stam/10)+'%';
			}
			if (gg.currentArmor && gg.currentArmor.mana<gg.currentArmor.maxmana) 
			{
				if (mana.text!='') mana.text+='\n';
				mana.text+=txtArmorMana+' '+Math.round(gg.currentArmor.mana/gg.currentArmor.maxmana*100)+'%';
			}
			if (gg.t_culd>0 || gg.currentSpell && gg.currentSpell.t_culd>0) mana.alpha=0.6;
			else mana.alpha=1;
			setOtstup();
		}
		
		public function setXp():void
		{
			var prun:Number=(gg.pers.xpCur-gg.pers.xpPrev)/(gg.pers.xpNext-gg.pers.xpPrev)
			vis.xpBar.xp.scaleX=prun;
		}
		
		public function setOtstup():void
		{
			if (pet.visible) 
			{
				vitem.y=70+30;
				vis.textItem.y=58+30;
			} 
			else 
			{
				vitem.y=70;
				vis.textItem.y=58;
			}

			if (vitem.visible) 
			{
				vis.textMana.y=vis.textItem.y+35;
			} 
			else 
			{
				vis.textMana.y=vis.textItem.y;
			}
		}
		
		
		public function setPet():void
		{
			if (gg.pet) 
			{
				pet.visible=true;
				if (gg.pet.hp>0) 
				{
					pet.hp.visible=true;
					pet.hp.scaleX=gg.pet.hp/gg.pet.maxhp;
				} 
				else 
				{
					pet.hp.visible=false;
				}
				if (gg.noPet>0) pet.txt.text=Math.floor(gg.noPet/Settings.fps);
				else pet.txt.text='';
				pet.ico.visible=(gg.noPet==0);
			} 
			else 
			{
				pet.visible=false;
			}
			setOtstup();
		}
		
		public function offCelObj():void
		{
			celObj=GameSession.currentSession.room.celObj=null;
			celobj.visible=false;
			unshowSelector();
		}
		
		public function setTopText(s:String=''):void
		{
			if (s!='') 
			{
				vis.toptext.visible=true;
				var ins:String=Res.txt('gui', s, 0, true);
				var myPattern:RegExp = /@/g; 
				vis.toptext.txt.htmlText=ins.replace(myPattern,'\n');
			} 
			else 
			{
				vis.toptext.visible=false;
			}
		}
		
		public function setEffects():void
		{
			if (!active) return;
			try 
			{
				var n:int=0;
				var t1:Boolean=false, t2:Boolean=false, t3:Boolean=false, t4:Boolean=false;
				effIsVis=false;
				for (var i:int = 0; i<kolEff; i++) 
				{

					if (GameSession.currentSession.pip.active) veff[i].alpha=0.2;
					else veff[i].alpha=1;

					if (!t1 && gg.cut>0) 
					{
						veff[i].visible=effIsVis=true;
						veff[i].txt.text=Math.round(gg.cut*10)/10;
						veff[i].vis.gotoAndStop('cut');
						t1=true;
						continue;
					} 
					else t1=true;

					if (!t2 && gg.poison>0) 
					{
						veff[i].visible=effIsVis=true;
						veff[i].txt.text=Math.round(gg.poison*10)/10;
						veff[i].vis.gotoAndStop('poison');
						t2=true;
						continue;
					} 
					else t2=true;

					if (!t3 && gg.shithp>0) 
					{
						veff[i].visible=effIsVis=true;
						veff[i].txt.text=Math.ceil(gg.shithp);
						veff[i].vis.gotoAndStop('shit');
						t3=true;
						continue;
					} 
					else t2=true;

					if (n<gg.effects.length && !gg.effects[n].vse) 
					{
						veff[i].visible=effIsVis=true;
						if (!gg.effects[n].forever) veff[i].txt.text=Math.floor(gg.effects[n].t/30);
						else veff[i].txt.text='∞';
						try 
						{
							if (gg.effects[n].tip==3) veff[i].vis.gotoAndStop('food');
							else veff[i].vis.gotoAndStop(gg.effects[n].id);
						} 
						catch(err) 
						{
							veff[i].vis.gotoAndStop(1);
						}
						n++;
					} 
					else 
					{
						veff[i].visible=false;
					}
				}
			} 
			catch(err)
			{

			}
		}
		
		public function setCelObj():void
		{
			celObj=GameSession.currentSession.room.celObj;
			if (celObj!=prevObj) 
			{
				if (Settings.shineObjs && prevObj && prevObj.vis && prevObj.levit==0)
				{
					prevObj.vis.transform.colorTransform=prevObj.cTransform;
				}
			}
			var warn:String = 'r';
			levit_poss.visible=false;
			if (GameSession.currentSession.pip.active) return;
			var s:String;
			pr_bar.visible=false;
			if (gg.teleObj) 
			{
				GameSession.currentSession.cur('action');
				celobj.visible=true;
				if (gg.teleObj.warn>0)  warn='warn';
				s="<span class = '"+warn+"'>"+gg.teleObj.objectName+"</span>"
				if (Settings.hintTele) s+='\n'+GameSession.currentSession.ctr.retKey('keyTele')+' - '+txtDrop;
				celobj.text=s;
				GameSession.currentSession.cam.setKoord(celobj,gg.teleObj.X,gg.teleObj.Y);
			} 
			else if (gg.actionObj!=null && gg.actionObj.owner) 
			{
				GameSession.currentSession.cur('action');
				try {
					celobj.visible=true;
					s=gg.actionObj.owner.objectName;
					var perc:Number=(gg.mt_action-gg.t_action)/gg.mt_action;
					if (perc>1) perc=1; if(perc<0) perc=0;
					pr_bar.visible=true;
					pr_bar.pr.scaleX=perc;
					s+='\n'+gg.actionObj.actionText;//+' '+gg.t_action;
					celobj.text=s;
					GameSession.currentSession.cam.setKoord(celobj,gg.actionObj.owner.X,gg.actionObj.owner.Y);
					GameSession.currentSession.cam.setKoord(pr_bar,gg.actionObj.owner.X,gg.actionObj.owner.Y);
				} 
				catch (err) {
					celobj.visible=false;
				}
			} 
			else if (celObj) 
			{
				if (t_show>0) 
				{
					celobj.visible=false;
					return;
				}
				celobj.visible=true;
				//Object name
				if (celObj.warn>0)  
				{
					warn='warn';
				}
				s="<span class = '"+warn+"'>"+celObj.objectName+"</span>";
				//Add object status
				if (celObj.inter && celObj.inter.stateText!='') s+=' ['+celObj.inter.stateText+']';
				//Telekinesis
				if (!GameSession.currentSession.room.base && celObj.stay && celObj.levitPoss && GameSession.currentSession.room.celDist<=GameSession.currentSession.pers.teleDist && celObj.massa<=GameSession.currentSession.pers.maxTeleMassa) {
					if (Settings.hintTele) s+='\n'+GameSession.currentSession.ctr.retKey('keyTele')+' - '+txtTele;
					//Glow
					if (Settings.shineObjs && celObj.vis) {
						celObj.vis.transform.colorTransform=gg.shineTransform;
					}
					levit_poss.visible=true;
					GameSession.currentSession.cam.setKoord(levit_poss,celObj.X,celObj.Y-5);
				}
				// Add a line about an action
				if (celObj.inter && celObj.inter.active && celObj.inter.action && GameSession.currentSession.room.celDist<= Settings.actionDist && GameSession.currentSession.gg.rat==0) {
					GameSession.currentSession.cur('action');
					if (!GameSession.currentSession.room.base && (celObj.inter.mine>0 || celObj.inter.lock>0) && !celObj.inter.is_act || celObj.inter.t_action) {
						// Locked and has a key
						//if (Settings.showAddInfo) s+='\nзамок '+celObj.inter.lock+';'+celObj.inter.lockLevel+', мина '+celObj.inter.mine+', уровень['+celObj.inter.allDif+']';
						if (celObj.inter.mine<=0 && celObj.inter.lock>0 && celObj.inter.lockKey && gg.invent.items[celObj.inter.lockKey] && gg.invent.items[celObj.inter.lockKey].kol>0) {
							s+='\n';
							if (Settings.hintKeys) s+=GameSession.currentSession.ctr.retKey('keyAction')+' ('+txtHold+') - ';
							s+=Res.txt('gui', 'usekey');
						 // Locked, key needed, but not available
						} else if (celObj.inter.mine<=0 && celObj.inter.lock>0 && celObj.inter.lockKey && celObj.inter.lockTip==0) {
							s+="\n(<span class = 'r5'>"+Res.txt('gui', 'required')+' '+Res.txt('item',celObj.inter.lockKey)+"</span>)"; 
						// Jammed
						} else if (celObj.inter.lock>=100) {
							//s+="\n(<span class = 'warn'>"+txtNoUnlock+"</span>)"; 
						} else if (celObj.inter.mine==0 && celObj.inter.lock>0 && celObj.inter.lockTip==0) {	//невскрываемый замок
							s+="\n(<span class = 'r3'>"+txtUndef0+"</span>)"; 
						} else if (celObj.inter.actionText!='') {
							var acts:String ='\n';
							if (Settings.hintKeys) acts+=GameSession.currentSession.ctr.retKey('keyAction')+' ('+txtHold+') - ';
							acts+=celObj.inter.actionText;
							if (celObj.inter.mine>0) {			//есть минирование
								s+=acts+dif(celObj.inter.mine, celObj.inter.mineTip);		
							} else if (celObj.inter.lock>0) { 	//есть замок
								if (celObj.inter.lockTip==1 || celObj.inter.lockTip==2) {
									if (GameSession.currentSession.pers.getLockMaster(celObj.inter.lockTip)<celObj.inter.lockLevel) {
										s+="\n(<span class = 'r3'>"+this['txtUndef'+celObj.inter.lockTip]+"</span>)"; 
									} else {
										s+=acts+'\n'+diflock(celObj.inter.getChance(celObj.inter.lock-GameSession.currentSession.pers.getLockTip(celObj.inter.lockTip)));
									}
								} else s+=acts+dif(celObj.inter.lock, celObj.inter.lockTip);
							} else {
								s+=acts;
							}
							//заколки
							if (celObj.inter.lockTip==1 && celObj.inter.lock>0 && celObj.inter.mine==0 && GameSession.currentSession.invent && GameSession.currentSession.invent.pin.kol>0) s+=" {<span class = 'r2'>"+GameSession.currentSession.invent.pin.kol+"</span>}";
							if (celObj.inter.cons) s+='\n('+Res.txt('gui', 'required')+': '+Res.txt('item',celObj.inter.cons)+')';
						}
					} else {
						s+='\n';
						if (Settings.hintKeys) s+=GameSession.currentSession.ctr.retKey('keyAction')+' - ';
						s+=celObj.inter.actionText;
					}
				} else if (celObj.warn>0)  {
					GameSession.currentSession.cur('combat');
				} else {
					GameSession.currentSession.cur('target');
				}
				if (celObj.inter && GameSession.currentSession.room.celDist <= Settings.actionDist) {
					acts="\n<span class = 'r3'>";
					if (Settings.hintKeys) acts+=GameSession.currentSession.ctr.retKey('keyCrack')+' - ';
					if (celObj.inter.mineTip==6 && celObj.inter.mine>0) {
						s+=acts+Res.txt('gui', 'actalarm')+"</span>";
					} else if (celObj.inter.lockTip==1 && celObj.inter.needRuna(gg)) {
						s+=acts+Res.txt('gui', 'runa')+"</span>";
					} else if (celObj.inter.lockTip==2 && celObj.inter.needRuna(gg)) {
						s+=acts+Res.txt('gui', 'reboot')+"</span>";
					}
				}
				if (gg.showObsInd && (celObj is Unit) && (celObj as Unit).fraction!=Unit.F_PLAYER && !(celObj as Unit).doop && (celObj as Unit).observ>gg.sneak+1) {
					s+=" <span class = 'r1'>(ʘ)</span>";
				}
				celobj.htmlText=s;
				GameSession.currentSession.cam.setKoord(celobj,celObj.X,celObj.Y);
			} else {
				celobj.visible=false;
				GameSession.currentSession.cur('target');
			}
			//if (GameSession.currentSession.t_battle>0) GameSession.currentSession.cur('combat');
			if (celobj.visible) {
				celobj.x-=celobj.width/2;
				if (celobj.y>GameSession.currentSession.cam.screenY-40-celobj.height) celobj.y=pr_bar.y=GameSession.currentSession.cam.screenY-40-celobj.height;
			}
			prevObj=celObj;
		}
		
		public function dif(lock:int, lockTip:int):String 
		{
			var pick=GameSession.currentSession.pers.getLockTip(lockTip);
			var s:String='';
			if (lock < pick) s=txtSoft; 
			else if (lock > pick+2) s="<span class = 'warn'>"+txtUnreal+"</span>"; 
			else if (lock > pick+1) s="<span class = 'r3'>"+txtVeryHard+"</span>"; 
			else if (lock > pick) s="<span class = 'r2'>"+txtHard+"</span>";
			if (s!='') return '\n ('+s+')';
			else return '';
		}
		
		public function diflock(n:Number):String 
		{
			var s:String=txtChance+': ';
			if (n<0.1) s+="<span class = 'warn'>";
			else if (n<0.3) s+="<span class = 'r3'>";
			else if (n<0.5) s+="<span class = 'r2'>";
			else s+="<span>";
			s+=Math.round(n*100)+'%</span>';
			return s;
		}
		
		public function setAll():void
		{
			setWeapon();
			setItems();
			setMana();
			setHp();
			setXp();
			setOd();
			setEffects();
			setPet();
		}
		
		public function showPortCel():void
		{
			vis.portCel.visible=true;
			var nx=Math.round(GameSession.currentSession.celX/Settings.tilePixelWidth)*Settings.tilePixelWidth;
			var ny=Math.round(GameSession.currentSession.celY/Settings.tilePixelHeight)*Settings.tilePixelHeight;
			GameSession.currentSession.cam.setKoord(vis.portCel,nx,ny);
			if (gg.checkPort()) 
			{
				if (gg.t_port<gg.pers.portTime) vis.portCel.gotoAndStop(1);
				else vis.portCel.gotoAndStop(2);
			} 
			else vis.portCel.gotoAndStop(3);
		}
		
		public function infoText(id:String, p1=0, p2=null, addlog:Boolean=true):void
		{
			var s:String=Res.txt('info', id);
			s=s.replace('@1','<b>'+p1+'</b>');
			if (p2!=null) s=s.replace('@2',p2);
			if (s!=prevInfoText) 
			{
				bulbText=s;
				info.htmlText+=bulbText+"<br>";
				if (addlog) GameSession.currentSession.log+=bulbText+"<br>";
				kolStr++;
				t_info=150;
				if (kolStr>6) remStr();
			}
			prevInfoText=s;
		}
		
		public function infoEffText(id:String):void
		{
			var s:String=Res.txt('eff',id,2);
			if (s==null || s=='') return;
			info.htmlText+=(s+"<br>");
			kolStr++;
			t_info=150;
			if (kolStr>6) remStr();
			//trace(s);
		}
		
		public function bulb(nx:int, ny:int):void
		{
			if (t_bulb>0) return
			Emitter.emit('gui',GameSession.currentSession.room,nx,ny-110,{txt:bulbText, ry:50});
			t_bulb=20;
		}
		
		public function floatText(txt:String, nx:int, ny:int, n:int=-1):void
		{
			var bulbText:String=txt;
			if (n>=0) 
			{
				bulbText="<span class = 'r"+n+"'>"+txt+"</span>";
			}
			if (t_bulb<=0) 
			{
				float_dy=0;
			} 
			else 
			{
				float_dy-=20;
			}
			ny=ny-80+float_dy;
			if (ny<40) ny-=100;
			if (nx<50) nx=50;
			if (nx>GameSession.currentSession.room.roomPixelWidth-50) nx=GameSession.currentSession.room.roomPixelWidth-50;
			Emitter.emit('take',GameSession.currentSession.room,nx,ny,{txt:bulbText});
			t_bulb=10;
		}
		
		public function remStr():void
		{
			if (kolStr<=1) {
				info.htmlText='';
			} 
			else 
			{
				info.htmlText=info.htmlText.substr(info.htmlText.search('<br>')+4);
			}

			if (kolStr>0) kolStr--;
		}
		
		
		// Message in the middle of the screen
		public function messText(id:String, str:String='', down:Boolean=false, push:Boolean=false, nt_mess:int = 150):void
		{
			t_mess = nt_mess;
			var s:String='';
			if (id!='' && id+'_'+str!=id_mess) 
			{
				if (id!='') s=Res.messText(id);
				id_mess=id+'_'+str;
			}
			if (str!='') s+=' '+str;
			if (s!='') 
			{
				if (push) mess.mess.htmlText+="<br>"+s;
				else mess.mess.htmlText=s;

				if (down) mess.y=screenY-50-mess.height;
				else mess.y=50;
			}
		}
		
		public function hpBarBoss(n:Number = 0):void
		{
			if (n<=0) vis.hpbarboss.visible=false;
			else 
			{
				vis.hpbarboss.visible=true;
				vis.hpbarboss.bar.scaleX=n;
			}
		}
		
		public function informText(str:String, knop:Boolean = false):void
		{
			if (knop) vis.mouseChildren=vis.mouseEnabled=true;
			informScript.acts[0].val=str;
			informScript.acts[0].opt2=knop?2:1;
			informScript.start();
		}
		
		public function dialog(dial:String):void
		{
			dialScript.acts[0].val=dial;
			dialScript.start();
		}
		
		public function showHelp(event:MouseEvent):void
		{
			GameSession.currentSession.ctr.keyStates.active=false;
			GameSession.currentSession.ctr.keyStates.keyPressed=false;
			if (GameSession.currentSession.room.prob) informText(GameSession.currentSession.room.prob.info+'<br><br>'+GameSession.currentSession.room.prob.help);
			event.stopPropagation();
		}
		public function scrollClick(event:MouseEvent):void
		{
			GameSession.currentSession.ctr.keyStates.active=false;
			GameSession.currentSession.ctr.keyStates.keyPressed=false;
			event.stopPropagation();
		}
		
		// Display dialogue line, return false if there is no line
		// id can be either a dialogue ID in text.xml or a pre-made line
		public function dialText(id = null, n:int = -1, down:Boolean = false, wait:Boolean = true):Boolean 
		{
			if (id == null) 
			{
				dial.visible 		= false;
				inform.visible 		= false;
				vis.mouseChildren 	= false;
				vis.mouseEnabled 	= false;
				return false;
			}
			var xml;

			if (id is String) 
			{
				//TODO: Don't access languages' stuff directly like this.
				xml = Languages.currentLanguageData.txt.(@id == id);
				if (xml.length() == 0) return false;
				xml = xml.n[0];
				if (xml.length() == 0) return false;
				if (n >= 0) 
				{
					xml = xml.r[n];
					if (xml == null) return false;
				}
				GameSession.currentSession.game.addNote(id);
			} 
			else if (id is XML) xml = id;
			var reg:int = 0;
			if (xml.@mod.length()) reg = xml.@mod;
			if (reg == 0) dial.visible = true;
			else inform.visible = true;
			var s:String = xml.toString();
			//маты
			if (xml && xml.@m.length()) 
			{
				var sar:Array=s.split('|');
				if (sar) 
				{
					if (Settings.matFilter && sar.length > 1) s=sar[1];
					else s=sar[0];
				}
			}
			for (var i:int = 1; i<=5; i++) 
			{
				if (xml.attribute('s'+i).length())  s=s.replace('@'+i,"<span class='imp'>"+GameSession.currentSession.ctr.retKey(xml.attribute('s'+i))+"</span>");
			}
			s=s.replace(/\[/g,"<span class='yel'>");
			s=s.replace(/\]/g,"</span>");
			s=s.replace(/[\b\r\t]/g,'');
			s=Res.lpName(s);
			if (reg == 0) 
			{
				inform.visible=false;
				dial.portret.gotoAndStop(1);
				if (xml.@p.length()) 
				{
					var sp:String=xml.@p;
					if (sp.substr(0,2)=='lp' && Settings.alicorn) 
					{
						sp = 'lpa';
						s = "<span class='crim'>"+s+"</span>";
					}
					try 
					{
						dial.portret.gotoAndStop(sp);
						
					} 
					catch(err) 
					{
						dial.portret.gotoAndStop(1);
					}
				}

				if (xml.@push>0) dial.txt.htmlText+="<br>"+s;
				else dial.txt.htmlText=s;

				dial.lmb.visible=wait;

				if (wait) dial.lmb.play();
				else dial.lmb.stop();
			} 
			else if (reg >= 1) 
			{
				dial.visible=false;

				if (xml.@push > 0) inform.txt.htmlText += "<br><br>" + s;
				else inform.txt.htmlText = s;

				inform.txt.scrollV = 0;
				inform.lmb.visible = wait;

				if (wait) inform.lmb.play();
				else inform.lmb.stop();

				inform.but0.visible = (reg == 2);
				if (inform.scText) inform.scText.visible = false;
				if (inform.txt.height < inform.txt.textHeight && inform.scText) 
				{
					inform.scText.maxScrollPosition = inform.txt.maxScrollV;
					inform.scText.visible = true;
				}

			}
			return true;
		}
		
		// Important message, pauses the game
		public function impMess(ntitle:String, ntext:String, nico:String=''):void
		{
			GameSession.currentSession.ctr.keyStates.active=false;
			GameSession.currentSession.ctr.keyStates.keyPressed=false;
			imp.ico.gotoAndStop(1);
			if (nico != '') 
			{
				try 
				{
					imp.ico.gotoAndStop(nico);
				} 
				catch(err) 
				{
					imp.ico.gotoAndStop(1);
				}
			}
			imp.title.text=ntitle;
			imp.txt.y=imp.ico.y+imp.ico.height+15;
			imp.txt.htmlText=ntext;
			imp.visible=true;
			Snd.ps('quest');
			t_bulb = 30;
			gg.stopAnim();
			guiPause = true;
		}
		
		public function critHP():void
		{
			Snd.ps('lowhp');
			if (vis.blood) 
			{
				vis.blood.visible = true;
				vis.blood.gotoAndPlay(1);
			}
		}
		
		public function step():void
		{
			setCelObj();
			if (kolStr>0 && !dialScript.running) 
			{
				t_info--;
				if (t_info == 0) remStr();
				if (t_info == 100) prevInfoText = '';
				if (t_info <= 0 && kolStr > 0) t_info = 60;
			}
			if (Math.abs(infoAlpha - realAlpha) > 0.01) 
			{
				if (infoAlpha>realAlpha) realAlpha += 0.1;
				if (infoAlpha<realAlpha) realAlpha -= 0.1;
			}
			
			if (gg.t_port>15) showPortCel()
			else vis.portCel.visible=false;

			if (Math.abs(vis.info.alpha-realAlpha)>0.05) vis.info.alpha=realAlpha;

			if (gg.h2o<500 || gg.stam<500 || gg.mana<1000 || gg.teleObj || gg.t_culd>0 || gg.currentArmor && gg.currentArmor.mana<gg.currentArmor.maxmana || Settings.testBattle && gg.stam<980 || gg.currentSpell && gg.currentSpell.t_culd>0) setMana();
			else if (mana.text!='') mana.text='';

			if (gg.effects.length || gg.poison>0 || gg.cut>0 || gg.shithp>0 || effIsVis) setEffects();
			if (t_sel>0) t_sel--;
			if (t_sel==1) unshowSelector(1);
			if (t_od>0) t_od--;
			if (t_od==1) vis.odBar.visible=false;
			if (t_bulb>0) t_bulb--;
			if (t_item>0) t_item--;
			if (t_item==1) setItems(-1);
			if (gg.currentWeapon) setHolder();
			setVisibility();

			if (t_mess>0) 
			{
				t_mess--;
				if (mess.alpha<1) mess.alpha+=0.1;
				if (mess.alpha>1) mess.alpha=1;
				if (!mess.visible) mess.visible=true;
			} 
			else 
			{
				if (mess.alpha>0) mess.alpha-=0.01;
				if (mess.alpha<=0 && mess.visible) mess.visible=false;
			}

			if (informScript.running) informScript.step();
			if (dialScript.running) dialScript.step();
			if (GameSession.currentSession.ctr.keyStates.active && guiPause) 
			{
				if (t_bulb<=0) 
				{
					guiPause=false;
					imp.visible=false;
				} 
				else 
				{
					GameSession.currentSession.ctr.keyStates.active=false;
				}
			}

			if (gg.teleObj && gg.pers.throwForce>0 && gg.teleObj.massa>0.1) 
			{
				tharrow.visible = true;
				var ndx = gg.teleObj.X - gg.X
				var ndy = gg.teleObj.Y - gg.teleObj.scY / 2 - gg.Y + gg.scY / 2 - 10;
				GameSession.currentSession.cam.setKoord(tharrow,GameSession.currentSession.gg.teleObj.X,GameSession.currentSession.gg.teleObj.Y-GameSession.currentSession.gg.teleObj.scY/2);
				tharrow.rotation = Math.atan2(ndy, ndx) / Math.PI * 180;
				var alph:Number = gg.throwForceRelat();
				tharrow.alpha = alph;

				if (alph >= 0.99) tharrow.gotoAndStop(1);
				else  tharrow.gotoAndStop(2);
			} 
			else tharrow.visible = false;

			if (showDop&&!GameSession.currentSession.sats.active && !vis.fav.visible && !GameSession.currentSession.catPause) 
			{
				showSelector();
			}
			vis.fav.visible=vis.status.visible=(showFav || showDop)&&!GameSession.currentSession.sats.active && !GameSession.currentSession.catPause;
		}
		
		public function setSats(turn:Boolean):void
		{
			vis.sats.visible = turn && active;
		}
	}	
}