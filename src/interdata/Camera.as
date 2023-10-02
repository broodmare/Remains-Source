package interdata 
{
	import flash.display.DisplayObject;
	
	import unitdata.Unit;
	import locdata.Location;
	
	
	public class Camera 
	{
		
		public var world:World;
		public var moved:Boolean;
		public var screenX:int=1280; // Screen dimensions
		public var screenY:int=800;
		public var X:int=200; // World coordinates of the camera center
		public var Y:int=200;
		public var vx:int;		// Visual world coordinates relative to the screen
		public var vy:int, ovy:int;
		public var maxsx:int=2000;	// Location dimensions
		public var maxsy:int=2000;
		public var maxvx:int=2000;	// Visual location boundaries
		public var maxvy:int=2000;
		public var celX:int;	// Mouse cursor coordinates relative to the screen
		public var celY:int;
		public var camRun:Boolean=false;
		public var otryv:Number=0;
		public var quakeX:Number=0;
		public var quakeY:Number=0;
		public var isZoom:int=0;
		public var scaleV=1;
		public var scaleS=1;
		public var dblack:Number=0;
		
		// Display mode
		public var showOn:Boolean=false;
		public var showX:Number=-1;
		public var showY:Number=0;
		
		public function Camera(nw:World) 
		{
			world = nw;
		}
		
		public function setLoc(location:Location) 
		{
			if (location == null) return;
			screenX=world.swfStage.stageWidth;
			screenY=world.swfStage.stageHeight;
			maxsx=location.limX;
			maxsy=location.limY;
			maxvx=maxsx-screenX;
			maxvy=maxsy-screenY;
			quakeX=quakeY=0;
			if (location.limX-40<=screenX && location.limY-40<=screenY) {
				moved=false;
				vx=-maxvx/2;
				vy=-maxvy/2;
				world.mainCanvas.x=world.sats.vis.x=vx;
				world.mainCanvas.y=world.sats.vis.y=vy;
			} else {
				moved=true;
			}
			//moved=true;
			setZoom();
		}
		
		public function setKoord(mc:DisplayObject, nx:Number, ny:Number) {
			mc.x=nx*scaleV+vx;
			mc.y=ny*scaleV+vy;
		}
		
		public function setZoom(turn:int=-1000) {
			if (turn==1000) {
				isZoom++;
				if (isZoom>2) isZoom=0;
				World.world.gui.infoText('zoom'+isZoom);
			} else if (turn>=0) {
				isZoom=turn;
			}
			
			if (isZoom==1) {
				scaleV=Math.max(screenX/maxsx, screenY/maxsy);
			} else if (isZoom==2) {
				scaleV=Math.min(screenX/maxsx, screenY/maxsy);
			} else {
				scaleV=1;
			}
			scaleS=Math.min(screenX/1920, screenY/1000);
			//scaleV*=0.5;
			if (scaleV>0.98) scaleV=1;
			maxvx=maxsx*scaleV-screenX;
			maxvy=maxsy*scaleV-screenY;
			world.mainCanvas.scaleX=world.sats.vis.scaleX=world.mainCanvas.scaleY=world.sats.vis.scaleY=scaleV;
			world.vscene.scaleX=world.vscene.scaleY=scaleS;
			if (screenY>maxsy*scaleV) {
				World.world.grafon.ramT.scaleY=-(screenY-maxsy*scaleV)/100/scaleV-0.5;
				World.world.grafon.ramB.scaleY=(screenY-maxsy*scaleV+5)/100/scaleV+0.5;
			} else {
				World.world.grafon.ramT.scaleY=-0.5/scaleV;
				World.world.grafon.ramB.scaleY=0.6/scaleV;
			}
			if (screenX>maxsx*scaleV) {
				World.world.grafon.ramL.scaleX=-(screenX-maxsx*scaleV)/100/scaleV-0.5;
				World.world.grafon.ramR.scaleX=(screenX-maxsx*scaleV+5)/100/scaleV+0.5;
			} else {
				World.world.grafon.ramL.scaleX=-0.5/scaleV;
				World.world.grafon.ramR.scaleX=0.5/scaleV;
			}
		}
		
		public function calc(un:Unit) {
			if (world.ctr.keyZoom) {
				if (World.world.location && World.world.location.sky) {
					setZoom(2);
				} else {
					setZoom(1000);
				}
				world.ctr.keyZoom=false;
			}
			if (moved) {
				if ((world.ctr.keyLook || showOn) && otryv<1) {
					if (showOn) otryv+=0.2;
					else otryv+=0.05;
				}
				if (!world.ctr.keyLook && !showOn && otryv>0) {
					otryv-=0.2;
					if (otryv<0) otryv=0;
				}
				if (world.ctr.keyLook) {
					showX=-1;
				}
				if (!camRun) {
					if (otryv>0) {
						if (showX>=0) {
							X=un.X*scaleV+otryv*(showX-screenX/2)*1.3;
							Y=un.Y*scaleV+otryv*(showY-screenY/2)*1.3;
						} else {
							X=un.X*scaleV+otryv*(celX-screenX/2);
							Y=un.Y*scaleV+otryv*(celY-screenY/2);
						}
					} else {
						X=un.X*scaleV;
						if (ovy-un.Y*scaleV>5 && ovy-un.Y*scaleV<50) {
							Y=ovy-(ovy-un.Y*scaleV)/4;
						} else Y=un.Y*scaleV;
					}
				}
				ovy=Y;
				if (maxvx<0) {
					vx=-maxvx/2;
				} else {
					vx=-X+screenX/2;
					if (vx>0) vx=0;
					if (vx<-maxvx) vx=-maxvx;
				}
				if (maxvy<0) {
					vy=-maxvy/2;
				} else {
					vy=-Y+screenY/2+100;
					if (vy>0) vy=0;
					if (vy<-maxvy) vy=-maxvy;
				}
			}
			if (quakeX!=0) {
				if (Math.random()>0.2) quakeX*=-(Math.random()*0.3+0.5);
				if (quakeX<1 && quakeX>-1) quakeX=0;
			}
			if (quakeY!=0) {
				if (Math.random()>0.2) quakeY*=-(Math.random()*0.3+0.5);
				if (quakeY<1 && quakeY>-1) quakeY=0;
			}
			world.mainCanvas.x=world.sats.vis.x=vx+quakeX;
			world.mainCanvas.y=world.sats.vis.y=vy+quakeY;
			Snd.centrX=X, Snd.centrY=Y;
			
			world.celX=(celX-vx)/scaleV;
			world.celY=(celY-vy)/scaleV;
			if (dblack>0) {
				world.vblack.visible=true;
				world.vblack.alpha+=dblack/100;
				if (world.vblack.alpha>=1) {
					dblack=0;
				}
			}
			if (dblack<0) {
				world.vblack.alpha+=dblack/100;
				if (world.vblack.alpha<=0) {
					dblack=0;
					world.vblack.visible=false;
				}
			}
		}

	}
	
}
