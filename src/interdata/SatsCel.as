package interdata 
{
	
	import stubs.satsCel;
	import stubs.satsUnCel;

	public class SatsCel extends Obj
	{
		
		var kol:int=1;
		var cons:Number;
		var un:Object;
		var begined:Boolean=false;

		public function SatsCel(nUn:Object, nx:Number, ny:Number, ncons:Number, nkol:int=1) 
		{
			layer=5;
			room=GameSession.currentSession.room;
			var ramka:int=10;
			if (nUn==null) 
			{
				vis=new satsCel();
				X = nx;
				Y = ny;
				vis.x = X;
				vis.y = Y;
			} 
			else 
			{
				un=nUn;
				vis=new satsUnCel();
				un.n++;
				run();
				vis.scaleX=(un.u.scX+ramka*un.n)/100;
				vis.scaleY=(un.u.scY+ramka*un.n)/100;
			}
			cons=ncons/nkol;
			kol=nkol;
			addVisual();
		}
		
		public function remove():void
		{
			remVisual();
		}
		
		public function run():void
		{
			if (un) 
			{
				X=un.u.X;
				Y=un.u.Y-un.u.scY/2;
				vis.x=X;
				vis.y=Y;
			}
		}

	}
	
}
