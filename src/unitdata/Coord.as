package  unitdata
{
	import locdata.Room;
	
	public class Coord 
	{
		
		public var tip:String;
		public var room:Room;
		
		public var t1:int;
		public var t2:int;
		
		public var tr:int;
		public var liv1:Boolean=false;
		public var liv2:Boolean=false;
		public var liv3:Boolean=false;
		
		var kolAll:int=6;
		var kolClosed:int=3;
		public var opened:Array=[];

		public function Coord(newRoom:Room, ntip:String=null) 
		{
			room=newRoom;
			tip=ntip;
			tr=1;
			t1=100;
			t2=150;
			rndOpened();
		}
		
		function rndOpened() 
		{
			for (var i=1;i<=kolAll;i++) 
			{
				opened[i]=true;
			}
			for (i=1;i<=kolClosed;i++) 
			{
				opened[Math.floor(Math.random()*kolAll+1)]=false;
			}
		}
		
		public function step():void
		{
			t1--;
			if (t1<=0) 
			{
				t1=Math.floor(Math.random()*60+150);
				for (var i=1; i<=3; i++) 
				{
					tr++;
					if (tr>3) tr=1;
					if (this['liv'+tr]) break;
				}
			}
			t2--;
			if (t2==75) 
			{
				for (var i=1;i<=kolAll;i++) 
				{
					room.allAct(null,opened[i]?'red':'green','a'+i);
				}
			}
			if (t2==0) 
			{
				for (var i=1;i<=kolAll;i++) 
				{
					room.allAct(null,opened[i]?'open':'close','a'+i);
				}
				t2=300;
				rndOpened();
			}
		}
	}
}
