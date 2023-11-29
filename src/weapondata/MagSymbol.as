package weapondata 
{
	
	import unitdata.Unit;
	import locdata.*;
	import graphdata.Emitter;
	
	public class MagSymbol extends Obj
	{
		
		protected var vse:Boolean=false;
		
		public var owner:Unit;
		public var spellId:String;
		public var rad:Number=100;
		public var liv:int=20;
		


		public function MagSymbol(own:Unit, spell:String, nx:Number, ny:Number, otlozh:int=0) 
		{
			if (own==null) 
			{
				owner=new Unit();
				room=World.world.room;
			} 
			else 
			{
				owner=own;
				room=own.room;
			}
			spellId=spell;
			X=nx;
			Y=ny;
			liv=20+otlozh;
			room.addObj(this);
		}
		
		public override function step():void
		{
			if (liv==20) Emitter.emit('magsymbol',room,X,Y);
			liv--;
			if (liv==1) castSpell();
			if (liv<=0) room.remObj(this);
		}
		
		public override function setNull(f:Boolean=false):void
		{
			room.remObj(this);
		}
		
		public function castSpell():void
		{
			var cel:Unit=World.world.gg;
			if (cel.room==room && !cel.invulner && cel.sost<=2) 
			{
				if (getRasst2(cel)<rad*rad) 
				{
					cel.addEffect(spellId);
				}
			}
		}
		
		public override function err():String 
		{
			if (room) room.remObj(this);
			return null;
		}
	}
}
