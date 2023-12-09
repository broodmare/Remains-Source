package graphdata
{
    import flash.geom.Point;
    import flash.display.BitmapData;
    import flash.ui.MouseCursorData;
	import flash.ui.Mouse;
    
    public class CursorHandler
    {

        public static function createCursors():void
		{
			createCursor(visCurArrow, 	'arrow');
			createCursor(visCurTarget, 	'target', 13, 13);
			createCursor(visCurTarget1, 'combat', 13, 13);
			createCursor(visCurTarget2, 'action', 13, 13);
		}
		
		public static function createCursor(vcur:Class, objectName:String, nx:int = 0, ny:int = 0):void
		{
			var cursorData:Vector.<BitmapData>;
			var mouseCursorData:MouseCursorData;
			cursorData = new Vector.<BitmapData>();
			cursorData.push(new vcur());
			mouseCursorData  =  new MouseCursorData();
			mouseCursorData.data  =  cursorData;
			mouseCursorData.hotSpot = new Point(nx, ny);
			Mouse.registerCursor(objectName, mouseCursorData);
		}








    }
}