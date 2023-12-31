package weapondata  
{
	import flash.display.MovieClip;
	
	import unitdata.Unit;
	import unitdata.UnitPlayer;
	import unitdata.Pers;
	import locdata.Tile;
	
	import components.Settings;
	
	import stubs.visualpaint;

	public class WPaint extends Weapon 
	{
		//Setting these three to public
		public var del:Object={x:0, y:0};
		public var celX:Number, celY:Number;
		public var pX:Number=-1, pY:Number=-1;
		
		public var color:int=1;
		public var paintId:String='p_black';
		public var paintNazv:String='';

		public function WPaint(own:Unit, id:String, nvar:int=0) 
		{
			super(own, id,nvar);
			vWeapon=visualpaint;
			vis=new vWeapon();
		}
		
	
		public function lineCel():int 
		{
			var res:int = 0;
			var bx:Number=owner.X;
			var by:Number=owner.Y-owner.scY*0.75;
			var ndx:Number=(celX-bx);
			var ndy:Number=(celY-by);
			var div:Number=Math.floor(Math.max(Math.abs(ndx),Math.abs(ndy))/Settings.maxdelta)+1;
			for (var i:int = 1; i<div; i++) 
			{
				celX=bx+ndx*i/div;
				celY=by+ndy*i/div;
				var t:Tile=GameSession.currentSession.room.getAbsTile(Math.floor(celX),Math.floor(celY));
				if (t.phis==1 && celX>=t.phX1 && celX<=t.phX2 && celY>=t.phY1 && celY<=t.phY2) 
				{
					return 0
				}
			}
			return 1;
		}
		
		public override function actions():void
		{
			var ds:Number = 40 * owner.storona;
			if (owner.player) 
			{
				celX=owner.celX;
				celY=owner.celY;
				storona=owner.storona;
				del.x=(celX-(owner.X+ds));
				del.y=(celY-owner.weaponY);
				norma(del,600);
				ds=(owner as UnitPlayer).pers.meleeS*owner.storona;
				var tx:int = celX-X;
				var ty:int = celY-Y;
				ready=((tx*tx+ty*ty)<100);
				del.x=((owner.X+ds+del.x)-X)/2;
				del.y=((owner.weaponY+del.y)-Y)/2;
				if (owner.player) 
				{
					norma(del,20);
				}
				pX=X;
				pY=Y;
				X+=del.x;
				Y+=del.y;
			}
		}
		
		public override function attack(waitReady:Boolean=false):Boolean 
		{
			GameSession.currentSession.grafon.paint(pX,pY,X,Y,GameSession.currentSession.ctr.keyStates.keyRun);
			return true;
		}

		public function setPaint(npaint:String, ncolor:uint, nblend:String):void
		{
			paintId=npaint;
			paintNazv=Res.txt('item',paintId);
			GameSession.currentSession.grafon.brTrans.color=ncolor

		}
		
		public override function animate():void
		{
			if (vis) 
			{
				vis.y=Y;
				vis.x=X;
				vis.scaleX=storona;
			}
		}
	}
}
