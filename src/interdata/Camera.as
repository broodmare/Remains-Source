package interdata 
{
	import flash.display.DisplayObject;
	
	import unitdata.Unit;
	import locdata.Room;
	
	
	public class Camera 
	{
		
		public var currentSession:GameSession;
		public var moved:Boolean;
		public var screenX:int=1280; // Screen dimensions
		public var screenY:int=800;
		public var X:int=200; // World coordinates of the camera center
		public var Y:int=200;
		public var vx:int;		// Visual world coordinates relative to the screen
		public var vy:int, ovy:int;
		public var maxsx:int=2000;	// Room dimensions
		public var maxsy:int=2000;
		public var maxvx:int=2000;	// Visual room boundaries
		public var maxvy:int=2000;
		public var celX:int;	// Mouse cursor coordinates relative to the screen
		public var celY:int;
		public var camRun:Boolean=false;
		public var otryv:Number=0;
		public var quakeX:Number=0;
		public var quakeY:Number=0;
		public var isZoom:int=0;
		public var scaleV:int =1;
		public var scaleS:int =1;
		public var dblack:Number=0;
		
		// Display mode
		public var showOn:Boolean=false;
		public var showX:Number=-1;
		public var showY:Number=0;
		
		public function Camera(session:GameSession) 
		{
			currentSession = session;
		}
		
		public function setLoc(room:Room):void
		{
			if (room == null) return;
			screenX=currentSession.swfStage.stageWidth;
			screenY=currentSession.swfStage.stageHeight;
			maxsx=room.roomPixelWidth;
			maxsy=room.roomPixelHeight;
			maxvx=maxsx-screenX;
			maxvy=maxsy-screenY;
			quakeX=quakeY=0;
			if (room.roomPixelWidth-40<=screenX && room.roomPixelHeight-40<=screenY) 
			{
				moved=false;
				vx=-maxvx/2;
				vy=-maxvy/2;
				currentSession.mainCanvas.x = currentSession.sats.vis.x = vx;
				currentSession.mainCanvas.y = currentSession.sats.vis.y = vy;
			} 
			else 
			{
				moved=true;
			}
			setZoom();
		}
		
		public function setKoord(mc:DisplayObject, nx:Number, ny:Number):void
		{
			mc.x=nx*scaleV+vx;
			mc.y=ny*scaleV+vy;
		}
		
		public function setZoom(turn:int=-1000):void
		{
			if (turn==1000) 
			{
				isZoom++;
				if (isZoom>2) isZoom=0;
				GameSession.currentSession.gui.infoText('zoom'+isZoom);
			} 
			else if (turn>=0) 
			{
				isZoom=turn;
			}
			
			if (isZoom==1) 
			{
				scaleV=Math.max(screenX/maxsx, screenY/maxsy);
			} 
			else if (isZoom==2) 
			{
				scaleV=Math.min(screenX/maxsx, screenY/maxsy);
			} 
			else 
			{
				scaleV=1;
			}
			scaleS=Math.min(screenX/1920, screenY/1000);
			if (scaleV>0.98) scaleV=1;
			maxvx=maxsx*scaleV-screenX;
			maxvy=maxsy*scaleV-screenY;
			currentSession.mainCanvas.scaleX=currentSession.sats.vis.scaleX=currentSession.mainCanvas.scaleY=currentSession.sats.vis.scaleY=scaleV;
			currentSession.vscene.scaleX=currentSession.vscene.scaleY=scaleS;
			if (screenY>maxsy*scaleV) 
			{
				GameSession.currentSession.grafon.borderTop.scaleY=-(screenY-maxsy*scaleV)/100/scaleV-0.5;
				GameSession.currentSession.grafon.borderBottom.scaleY=(screenY-maxsy*scaleV+5)/100/scaleV+0.5;
			} 
			else 
			{
				GameSession.currentSession.grafon.borderTop.scaleY=-0.5/scaleV;
				GameSession.currentSession.grafon.borderBottom.scaleY=0.6/scaleV;
			}
			if (screenX>maxsx*scaleV) 
			{
				GameSession.currentSession.grafon.borderLeft.scaleX=-(screenX-maxsx*scaleV)/100/scaleV-0.5;
				GameSession.currentSession.grafon.borderRight.scaleX=(screenX-maxsx*scaleV+5)/100/scaleV+0.5;
			} 
			else 
			{
				GameSession.currentSession.grafon.borderLeft.scaleX=-0.5/scaleV;
				GameSession.currentSession.grafon.borderRight.scaleX=0.5/scaleV;
			}
		}
		
		public function calc(un:Unit):void
		{
			if (currentSession.ctr.keyStates.keyZoom)
			{
				if (GameSession.currentSession.room && GameSession.currentSession.room.sky) 
				{
					setZoom(2);
				} 
				else 
				{
					setZoom(1000);
				}
				currentSession.ctr.keyStates.keyZoom=false;
			}
			if (moved) 
			{
				if ((currentSession.ctr.keyStates.keyLook || showOn) && otryv<1) 
				{
					if (showOn) otryv+=0.2;
					else otryv+=0.05;
				}
				if (!currentSession.ctr.keyStates.keyLook && !showOn && otryv>0) 
				{
					otryv-=0.2;
					if (otryv<0) otryv=0;
				}
				if (currentSession.ctr.keyStates.keyLook) {
					showX=-1;
				}
				if (!camRun) 
				{
					if (otryv>0) 
					{
						if (showX>=0) 
						{
							X=un.X*scaleV+otryv*(showX-screenX/2)*1.3;
							Y=un.Y*scaleV+otryv*(showY-screenY/2)*1.3;
						} 
						else 
						{
							X=un.X*scaleV+otryv*(celX-screenX/2);
							Y=un.Y*scaleV+otryv*(celY-screenY/2);
						}
					} 
					else 
					{
						X=un.X*scaleV;
						if (ovy-un.Y*scaleV>5 && ovy-un.Y*scaleV<50) 
						{
							Y=ovy-(ovy-un.Y*scaleV)/4;
						} 
						else Y=un.Y*scaleV;
					}
				}
				ovy=Y;
				if (maxvx<0) 
				{
					vx=-maxvx/2;
				} 
				else 
				{
					vx=-X+screenX/2;
					if (vx>0) vx=0;
					if (vx<-maxvx) vx=-maxvx;
				}
				if (maxvy<0) 
				{
					vy=-maxvy/2;
				} 
				else 
				{
					vy=-Y+screenY/2+100;
					if (vy>0) vy=0;
					if (vy<-maxvy) vy=-maxvy;
				}
			}
			if (quakeX!=0) 
			{
				if (Math.random()>0.2) quakeX*=-(Math.random()*0.3+0.5);
				if (quakeX<1 && quakeX>-1) quakeX=0;
			}
			if (quakeY!=0) 
			{
				if (Math.random()>0.2) quakeY*=-(Math.random()*0.3+0.5);
				if (quakeY<1 && quakeY>-1) quakeY=0;
			}
			currentSession.mainCanvas.x=currentSession.sats.vis.x=vx+quakeX;
			currentSession.mainCanvas.y=currentSession.sats.vis.y=vy+quakeY;
			Snd.centrX = X;
			Snd.centrY = Y;
			
			currentSession.celX=(celX-vx)/scaleV;
			currentSession.celY=(celY-vy)/scaleV;
			if (dblack>0) 
			{
				currentSession.vblack.visible=true;
				currentSession.vblack.alpha+=dblack/100;
				if (currentSession.vblack.alpha>=1) 
				{
					dblack=0;
				}
			}
			if (dblack<0) 
			{
				currentSession.vblack.alpha+=dblack/100;
				if (currentSession.vblack.alpha<=0) 
				{
					dblack=0;
					currentSession.vblack.visible=false;
				}
			}
		}
	}
}
