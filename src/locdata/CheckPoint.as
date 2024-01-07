package locdata 
{
	import flash.geom.ColorTransform;
	import flash.display.MovieClip;
	
	import servdata.Interact;
	import locdata.LevelArray;

	import components.Settings;
	import components.XmlBook;
	
	import stubs.vischeckpoint;
	
	public class CheckPoint extends Obj
	{

		public var id:String;
		public var vis2:MovieClip;
		
		public var active:int = 0;
		public var teleOn:Boolean=false;
		public var used:Boolean=false;
		public var main:Boolean=false;
		public var hide:Boolean=false;
		
		public var locked:Boolean=false;
		
		public var area:Area;

		public function CheckPoint(newRoom:Room, nid:String, nx:int=0, ny:int=0, xml:XML=null, loadObj:Object=null) 
		{
			id=nid;
			room=newRoom;
			layer=0;
			prior=1;
			id=nid;
			levitPoss=false;
			var node:XML = XmlBook.getXML("objects").obj.(@id == id)[0];
			
			X = nx;
			Y = ny;
			scX=node.@size*Settings.tilePixelWidth;
			scY=node.@wid*Settings.tilePixelHeight;
			objectName=Res.txt('obj','checkpoint');
			
			X1 = X - scX / 2;
			X2 = X + scX / 2;
			Y1 = Y - scY;
			Y2 = Y;
			X=nx;
			Y=ny;
			var vClass:Class=Res.getClass('vischeckpoint', null, vischeckpoint);
			vis=new vClass();
			vis.x=X;
			vis.y=Y;

			vis.gotoAndStop(1);
			try 
			{
				if (id.charAt(10)) 
				{
					vis.lock.gotoAndStop(int(id.charAt(10)));
					locked=true;
				}
				else vis.lock.visible = false;
			} 
			catch (err) 
			{

			}

			X1 = X - scX / 2;
			X2 = X + scX / 2;
			Y1 = Y - scY;
			Y2 = Y;
			cTransform=room.cTransform;
			room.getAbsTile(X-20,Y+10).shelf=true;
			room.getAbsTile(X+20,Y+10).shelf=true;
			
			inter = new Interact(this,node,xml,loadObj);
			inter.userAction='activate';
			inter.actFun=activate;
			inter.update();
			inter.active=true;
			inter.action=100;
			
			area=new Area(room);
			area.setSize(X1,Y1,X2,Y2);
			area.over=areaActivate;
			
			if (xml && xml.@main.length()) main=true;
			if (xml && xml.@tele.length()) teleOn=true;
			if (xml && xml.@hide.length()) hide=true;
			
			if (loadObj) 
			{
				active=loadObj.act;
				if (active == undefined) active = 0;
				if (active == 1)  vis.osn.gotoAndStop('reopen');
				if (active == 2)  vis.osn.gotoAndStop('open');
				if (loadObj.used) used = true;
			}

			if (main) 
			{
				area=null;
				active=2;
				teleOn=true;
				vis.osn.gotoAndStop('open');
				room.level.currentCP=this;
				inter.actFun=teleport;
				inter.userAction='returnm';
				inter.t_action=30;
				inter.update();
				vis.fiol.gotoAndStop(25);
			}
			if (hide) 
			{
				vis.visible=false;
				objectName='';
				inter.active=false;
			}
		}
		
		public override function addVisual():void
		{
			if (vis && !hide) 
			{
				GameSession.currentSession.grafon.canvasLayerArray[layer].addChild(vis);
				if (cTransform) {
					vis.transform.colorTransform=cTransform;
				}
			}
		}

		public override function remVisual():void
		{
			super.remVisual();
		}
		
		public override function save():Object 
		{
			if (active==0) return null;
			var obj:Object = {};
			inter.save(obj);
			obj.act=active;
			if (used) obj.used=1;
			return obj;
		}
		
		public override function command(com:String, val:String = null):void
		{
			activate();
		}
		
		//активировать контрольную точку. если параметр true - не добавлять скилл-поинт
		public function activate(first:Boolean = false):void
		{
			if (inter.lock > 0 || inter.mine > 0) return;
			if (active == 2) 
			{
				return;
			}

			if (active == 0 && !first)
			{
				if (GameSession.currentSession.pers.manaCPres) GameSession.currentSession.pers.heal(GameSession.currentSession.pers.manaCPres, 6);
				if (GameSession.currentSession.pers.xpCPadd) GameSession.currentSession.pers.expa(room.unXp * 3);
			}
			active = 2;
			GameSession.currentSession.pers.currentCP = this;
			GameSession.currentSession.pers.currentCPCode = code;
			if (code) 
			{
				GameSession.currentSession.pers.prevCPCode = code;
				room.level.levelTemplate.lastCpCode = code;
			}
			room.level.currentCP = this;

			if (first) 
			{
				vis.osn.gotoAndStop('open');
				if (GameSession.currentSession.game.mReturn && teleOn && !used) vis.fiol.gotoAndStop(25);
			} 
			else 
			{
				vis.osn.play();
				if (GameSession.currentSession.game.mReturn && teleOn && !used) vis.fiol.gotoAndPlay(1);
			}

			if (used) vis.fiol.gotoAndStop(1);

			if (GameSession.currentSession.game.mReturn && teleOn && !used) 
			{
				inter.actFun = teleport;
				inter.userAction = 'returnb';
				inter.t_action = 30;
				inter.update();
			} 
			else 
			{
				inter.active = false;
				inter.actionText = '';
			}
			GameSession.currentSession.gui.infoText('checkPoint');
			GameSession.currentSession.saveGame();
		}
		
		public function teleport():void
		{
			if (!main) 
			{
				GameSession.currentSession.game.gotoLevel(GameSession.currentSession.game.baseId);
				if (Settings.hardInv && GameSession.currentSession.level.rnd) 
				{
					used = true;
					inter.active = false;
					inter.actionText = '';
					vis.fiol.gotoAndStop(1);
				}
			} 
			else if (GameSession.currentSession.game.missionId != 'rbl') GameSession.currentSession.game.gotoLevel(GameSession.currentSession.game.missionId);
		}
		
		public function areaActivate():void
		{
			if (active == 0) activate();
		}
		
		public function deactivate():void
		{
			if (main) return;
			inter.active =! hide;
			active = 1;
			vis.osn.gotoAndStop('reopen');
			vis.fiol.gotoAndStop(1);
			inter.actFun = activate;
			inter.userAction = 'activate';
			inter.t_action = 0;
			inter.update();
		}
		
		public override function step():void
		{
			onCursor = (X1 < GameSession.currentSession.celX && X2 > GameSession.currentSession.celX && Y1 < GameSession.currentSession.celY && Y2 > GameSession.currentSession.celY) ? prior:0;
			if (inter) inter.step();
			if (main) 
			{
				if (GameSession.currentSession.game.missionId && LevelArray.initializedLevelVariants[GameSession.currentSession.game.missionId] && LevelArray.initializedLevelVariants[GameSession.currentSession.game.missionId].tip!='base') inter.active = true;
				else inter.active = false;
				return;
			}

			if (locked && inter.lock == 0 && inter.mine == 0) 
			{
				locked = false;
				vis.lock.visible = false;
			}
			
			if (area) area.step();
			if (active == 2 && GameSession.currentSession.pers.currentCP != this) deactivate();
		}	
	}	
}