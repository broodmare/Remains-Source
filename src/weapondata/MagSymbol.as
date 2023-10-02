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
				location=World.world.location;
			} 
			else 
			{
				owner=own;
				location=own.location;
			}
			spellId=spell;
			X=nx;
			Y=ny;
			liv=20+otlozh;
			location.addObj(this);
		}
		
		public override function step() 
		{
			if (liv==20) Emitter.emit('magsymbol',location,X,Y);
			liv--;
			if (liv==1) spellCast();
			if (liv<=0) location.remObj(this);
		}
		
		public override function setNull(f:Boolean=false) 
		{
			location.remObj(this);
		}
		
		public function spellCast() 
		{
			var cel:Unit=World.world.gg;
			if (cel.location==location && !cel.invulner && cel.sost<=2) 
			{
				if (getRasst2(cel)<rad*rad) 
				{
					cel.addEffect(spellId);
				}
			}
		}
		
		public override function err():String 
		{
			if (location) location.remObj(this);
			return null;
		}
	}
}
