package graphdata
{
	import flash.display.BitmapData;
	import flash.display.BitmapDataChannel;
	import flash.display.Bitmap;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Matrix;
	import flash.display.MovieClip;

	import locdata.Room;

    public class BulletHoles
    {
		private static var currentRoom:Room = GameSession.currentSession.room;

        //Logic for bullet holes?
		public static function renderBulletHoles(nx:int, ny:int, tip:int, mat:int, soft:Boolean = false, ver:Number = 1):void
		{
			

			var erC:Class;
			var drC:Class;
			var bl:String = 'normal';
			var centr:Boolean = false;
			var sc:Number = Math.random() * 0.5 + 0.5;
			var rc:Number = Math.random() * 360

			if (tip == 0 || mat == 0) return;
			if (mat == 1) //metal
			{ 			
				if (tip >= 1 && tip <= 6) drC = bullet_metal;
				else if (tip == 9) //explosion
				{		
					if (!soft && Math.random() * 0.5 < ver) drC = metal_tre;
					centr = true;
				}
			} 
			else if (mat == 2 || mat == 4 || mat == 6) //stone
			{	
				if (tip >= 1 && tip <= 3) //bullets
				{					
					if (tip>1 && Math.random()>0.5) erC = bullet_dyr;
					drC = bullet_tre;
					if (tip == 2) sc += 0.5;
					if (tip == 3) sc += 1;
				} 
				else if (tip >= 4 && tip <= 6) //strikes
				{			
					if (!soft) drC = punch_tre;
					if (tip == 5) sc += 0.5;
					if (tip == 6) sc += 1;
				} 
				else if (tip == 9) //explosion
				{					
					if (!soft && Math.random()*0.5<ver) drC = expl_tre;
					centr = true;
				}
				if (tip<10 && !soft)
				{
					if (mat == 2) Emitter.emit('kusoch', currentRoom, nx, ny, {kol:3});  //room used to be defined in grafon
					else Emitter.emit('kusochB', currentRoom, nx, ny, {kol:3});    //room used to be defined in grafon
				}
			} 
			else if (mat == 3) //wood
			{	
				if (tip >= 1 && tip <= 3) //bullets
					{					
					erC = bullet_dyr;
					drC = bullet_wood;
					rc = 0;
					if (tip == 2) sc += 0.5;
					if (tip == 3) sc += 1;
				} 
				else if (tip >= 4 && tip <= 6) // punches
				{			
					if (!soft) drC = punch_tre;
					if (tip == 5) sc += 0.5;
					if (tip == 6) sc += 1;
				} 
				else if (tip == 9) // explosion
				{					
					if (!soft && Math.random() * 0.5 < ver) drC = expl_tre;
					centr = true;
				}
				if (tip<10 && !soft)
				{
					Emitter.emit('schepoch', currentRoom, nx, ny, {kol:3});    //room used to be defined in grafon
				}
			} 
			else if (mat == 7) // field
			{	
				Emitter.emit('pole', currentRoom, nx, ny, {kol:5});    //room used to be defined in grafon
			}

			if (tip == 11) // fire
			{					
				if (Math.random() < 0.1) drC = fire_soft;
			} 
			else if (tip == 12 || tip == 13) // lasers
			{		
				if (soft && Math.random() * 0.2 > ver)
				{
					drC = fire_soft;
				} 
				else 
				{
					drC = laser_tre;
				}
				if (tip == 13) sc *= 0.6;
				bl = 'hardlight';
			} 
			else if (tip == 15) // plasma
			{
				if (soft)
				{
					drC = plasma_soft;
				} 
				else 
				{
					erC = plasma_dyr;
					drC = plasma_tre;
				}
				bl = 'hardlight';
			} 
			else if (tip == 16)
			{
				if (soft)
				{
					drC = fire_soft;
				} else {
					erC = plasma_dyr;
					drC = bluplasma_tre;
				}
				bl = 'hardlight';
			} 
			else if (tip == 17)
			{
				if (soft)
				{
					drC = fire_soft;
				} else {
					erC = plasma_dyr;
					drC = pinkplasma_tre;
				}
				bl = 'hardlight';
			} 
			else if (tip == 18)
			{
				drC = cryo_soft;
				bl = 'hardlight';
			} 
			else if (tip == 19) // explosion
			{
				if (!soft && Math.random() * 0.5 < ver) drC = plaexpl_tre;
				centr = true;
			}			

			
			decal(erC, drC, nx, ny, sc, rc, bl);
		}

        //Rendering for bullet holes.
        public static function decal(erC:Class, drD:Class, nx:Number, ny:Number, sc:Number = 1, rc:Number = 0, bl:String = 'normal'):void
		{
			var backgroundMatrix:Matrix = new Matrix();
			if (sc != 1) backgroundMatrix.scale(sc, sc);
			if (rc != 0) backgroundMatrix.rotate(rc);
			backgroundMatrix.tx = nx;
			backgroundMatrix.ty = ny;
			if (erC)
			{
				var erase:MovieClip = new erC();
				if (erase.totalFrames > 1) erase.gotoAndStop(Math.floor(Math.random() * erase.totalFrames + 1));
				currentRoom.grafon.frontBmp.draw(erase, backgroundMatrix, null, 'erase', null, true);
			}
			if (drD)
			{
				var nagar:MovieClip = new drD();
				if (nagar.totalFrames > 1) nagar.gotoAndStop(Math.floor(Math.random() * nagar.totalFrames + 1));
				nagar.scaleX = nagar.scaleY = sc;
				nagar.rotation = rc;
				var dyrx:Number = Math.round(nagar.width  / 2 + 2) * 2;
				var dyry:Number = Math.round(nagar.height / 2 + 2) * 2;
				var res2:BitmapData  =  new BitmapData(dyrx, dyry, false, 0x0);
				var rdx:Number = 0;
				var rdy:Number = 0;
				if (nx - dyrx / 2 < 0) rdx = -(nx - dyrx / 2);
				if (ny - dyry / 2 < 0) rdy = -(ny - dyry / 2);
				var rect:Rectangle  =  new Rectangle(nx - dyrx / 2 + rdx, ny - dyry / 2 + rdy, nx + dyrx / 2 + rdx, ny + dyry / 2 + rdy);
				var pt:Point  =  new Point(0, 0);
				res2.copyChannel(currentRoom.grafon.frontBmp, rect, pt, BitmapDataChannel.ALPHA, BitmapDataChannel.GREEN);
				currentRoom.grafon.frontBmp.draw(nagar, backgroundMatrix, (bl == 'normal') ? currentRoom.cTransform:null, bl, null, true);
				rect  =  new Rectangle(0, 0, dyrx, dyry);
				pt = new Point(nx - dyrx / 2 + rdx, ny - dyry / 2 + rdy);
				currentRoom.grafon.frontBmp.copyChannel(res2, rect, pt, BitmapDataChannel.GREEN, BitmapDataChannel.ALPHA);
			}
		}
    }
}