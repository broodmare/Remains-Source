package src.graph 
{
import flash.display.BitmapData;
import flash.display.BitmapDataChannel;
import flash.display.Bitmap;
import flash.geom.Matrix;
import flash.geom.ColorTransform;
import flash.geom.Rectangle;
import flash.geom.Point;
import flash.display.Sprite;
import flash.display.MovieClip;
import flash.filters.BevelFilter;
import flash.filters.BlurFilter;
import flash.filters.GlowFilter;
import flash.filters.ColorMatrixFilter;
import flash.filters.DropShadowFilter;
import flash.utils.*;
import flash.net.URLRequest;
import flash.display.Loader;
import flash.events.Event;
import flash.events.ProgressEvent;
import flash.ui.MouseCursorData;
import flash.ui.Mouse;

import src.*;
import src.loc.*;	
import fl.motion.Color;

public class Grafon {
	
	public var location:Location;
	
	public var visual:Sprite;
	
	public var visBack:Sprite;
	public var visBack2:Sprite;
	public var visObjs:Array;
	const kolObjs = 6;
	public var visVoda:Sprite;
	public var visFront:Sprite;
	public var visLight:Sprite;
	public var visSats:Sprite;
	
	public var visFon:MovieClip;
	
	var resX:int, resY:int;

	//Textured area size
	var mapTileWidth:int = 48;  //Size of map width in tiles
	var mapTileHeight:int = 25;	//Size of map height in tiles
	
	//BITMAPS
	public var frontBmp:BitmapData;
	var frontBitmap:Bitmap;
	var vodaBmp:BitmapData;
	var vodaBitmap:Bitmap;
	var backBmp:BitmapData;
	var backBitmap:Bitmap;
	var backBmp2:BitmapData;
	var backBitmap2:Bitmap;
	public var lightBmp:BitmapData;
	var lightBitmap:Bitmap;
	public var satsBmp:BitmapData;
	var satsBitmap:Bitmap;
	var shadBmp:BitmapData;
	var colorBmp:BitmapData;


	var dsFilter:DropShadowFilter = new DropShadowFilter(7, 90, 0, 0.75, 16, 16, 1, 3, false, false, true);
	var infraTransform:ColorTransform = new ColorTransform(1, 1, 1, 1, 100);
	var defTransform:ColorTransform = new ColorTransform();
	
	public var pa:MovieClip = new paintaero();
	public var pb:MovieClip = new paintbrush();
	public var brTrans:ColorTransform = new ColorTransform();
	public var brColor:Color = new Color();
	var brData:BitmapData  =  new BitmapData(100, 100, false, 0x0);
	var brPoint:Point  =  new Point(0, 0);
	var brRect:Rectangle  =  new Rectangle(0, 0, 50, 50);

	var paintMatrix:Matrix = new Matrix();
	var voda = new tileVoda();
	
	//Frames
	public var ramT:MovieClip, ramB:MovieClip;
	public var ramL:MovieClip, ramR:MovieClip;
	
	var arrFront:Array;
	var arrBack:Array;
	
	var rectX:int = 1920, rectY:int = 1000;
	var allRect:Rectangle = new Rectangle(0, 0, rectX, rectY);
	
	var lightX:int = 49, lightY:int = 28;
	var lightRect:Rectangle = new Rectangle(0, 0, lightX, lightY);

	public var resIsLoad:Boolean = false;  // Have the textures been loaded?
	public var progressLoad:Number = 0;

	public static var spriteLists:Array = new Array(); 
	public static var texUrl:Array = ['texture.swf', 'texture1.swf', 'sprite.swf', 'sprite1.swf']; //URLs of the files to load
	public var grLoaders:Array;
	
	public static const numbMat = 0;		// Materials
	public static const numbFon = 0;		// Backgrounds
	public static const numbBack = 1;		// Decorations
	public static const numbObj = 1;		// Objects
	public static const numbSprite = 2;		// Starting number for sprite files
	
	var tilepixelwidth:Number = -1;
	var tilepixelheight:Number = -1;
	var finalWidth:Number = -1;
	var finalHeight:Number = -1;
	
	public function Grafon(nvis:Sprite)
	{
		//Precalculated for performance.
		tilepixelwidth = Tile.tilePixelWidth;
		tilepixelheight = Tile.tilePixelHeight;
		finalWidth = mapTileWidth * tilepixelwidth;
		finalHeight = mapTileHeight * tilepixelheight;

		visual = nvis;
		visBack = new Sprite();
		visBack2 = new Sprite();
		visVoda = new Sprite();
		visVoda.alpha = 0.6;
		visFront = new Sprite();
		visLight = new Sprite();
		visSats = new Sprite();
		visSats.visible = false;
		visSats.filters = [new BlurFilter(3, 3, 1)];
		
		//Array of all sprites to display.
		visObjs = new Array();
		for (var i = 0; i<kolObjs; i++) visObjs.push(new Sprite());
		
		visual.addChild(visBack);		//0 
		visual.addChild(visBack2);		//0
		visual.addChild(visObjs[0]);	//1
		visual.addChild(visObjs[1]);	//2
		visual.addChild(visObjs[2]);	//3
		visual.addChild(visFront);		//4
		visual.addChild(visObjs[3]);	//6
		visual.addChild(visVoda);		//5
		visual.addChild(visLight);		//7
		visual.addChild(visObjs[4]);	//8
		visual.addChild(visSats);		//9
		visual.addChild(visObjs[5]);	//10
		visLight.x = -tilepixelwidth / 2;
		visLight.y = -tilepixelheight / 2 - tilepixelheight;
		visLight.scaleX = tilepixelwidth;
		visLight.scaleY = tilepixelheight;
		


		frontBmp = new BitmapData(rectX, rectY, true, 0x0)
		frontBitmap  =  new Bitmap(frontBmp);
		visFront.addChild(frontBitmap);
		
		backBmp = new BitmapData(rectX, rectY, true, 0x0)
		backBitmap  =  new Bitmap(backBmp);
		visBack.addChild(backBitmap);
		
		backBmp2 = new BitmapData(rectX, rectY, true, 0x0)
		backBitmap2  =  new Bitmap(backBmp2);
		visBack2.addChild(backBitmap2);

		vodaBmp = new BitmapData(rectX, rectY, true, 0x0)
		vodaBitmap  =  new Bitmap(vodaBmp);
		visVoda.addChild(vodaBitmap);
		
		satsBmp = new BitmapData(rectX, rectY, true, 0);
		satsBitmap  =  new Bitmap(satsBmp, 'auto', true);
		visSats.addChild(satsBitmap);
		
		colorBmp = new BitmapData(rectX, rectY, true, 0);
		shadBmp = new BitmapData(rectX, rectY, true, 0);
		
		lightBmp = new BitmapData(lightX, lightY, true, 0xFF000000);
		lightBitmap  =  new Bitmap(lightBmp, 'auto', true);
		visLight.addChild(lightBitmap);




		ramT = new visBlack();
		ramB = new visBlack();
		ramR = new visBlack();
		ramL = new visBlack();

		ramT.cacheAsBitmap = true;
		ramB.cacheAsBitmap = true;
		ramR.cacheAsBitmap = true;
		ramL.cacheAsBitmap = true;

		visual.addChild(ramT);
		visual.addChild(ramB);
		visual.addChild(ramR);
		visual.addChild(ramL);
		

		grLoaders = new Array();
		for (var i in texUrl)
		{
			var textureURL:String = texUrl[i];
			grLoaders[i] = new GrLoader(i, textureURL, this);
		}
		createCursors();
	}
	

	public function checkLoaded(id:int) //GrLoader calls this function when it finishes loading. n is the ID of the loader that called it.
	{
		if (id == 0) //What to do if the loader is the first one.
		{
			// Populates front and back arrays with materials from MaterialData.XML
			arrFront = new Array();
			arrBack = new Array();

			for each (var p:XML in AllData.d.mat)
			{
				if (p.@vid.length() == 0)
				{
					if (p.@ed == '2') arrBack[p.@id] = new Material(p);
					else arrFront[p.@id] = new Material(p);
				}
			}
		}
		resIsLoad = (GrLoader.kolIsLoad >= GrLoader.kol);
	}
	
	//Determine progress of loading.
	public function allProgress()
	{
		progressLoad = 0; //Clear the current progress.
		for (var i in grLoaders) //for each loader in the array of loaders...
		{
			progressLoad += grLoaders[i].progressLoad; //Add the progress of the loader to the total progress.
		}
		progressLoad /= GrLoader.kol;
	}
	
	function createCursors()
	{
		createCursor(visCurArrow, 'arrow');
		createCursor(visCurTarget, 'target', 13, 13);
		createCursor(visCurTarget1, 'combat', 13, 13);
		createCursor(visCurTarget2, 'action', 13, 13);
		//if (!World.w.sysCur) Mouse.cursor = 'arrow';
		//Mouse.unregisterCursor('arrow');
	}
	
	function createCursor(vcur:Class, nazv:String, nx:int = 0, ny:int = 0)
	{
		var cursorData:Vector.<BitmapData>;
		var mouseCursorData:MouseCursorData;
		cursorData = new Vector.<BitmapData>();
		cursorData.push(new vcur());
		mouseCursorData  =  new MouseCursorData();
		mouseCursorData.data  =  cursorData;
		mouseCursorData.hotSpot = new Point(nx, ny);
		//mouseCursorData.frameRate  =  1;
		Mouse.registerCursor(nazv, mouseCursorData);
	}
	
	//================================================================================================		
	//							Initial Location Drawing
	//================================================================================================		
	

	//Grab a list of all objects in the room.
	//texture name
	//texture id?
	//asterisk indicating variable return types?
	public function getObj(tex:String, id:int = 0):* 
	{
		return this.grLoaders[id].resource.getObj(tex);
	}
	
	// Draw the background
	public function drawFon(vfon:MovieClip, tex:String)
	{
		if (tex == '' || tex == null) tex = 'fonDefault';
		if (visFon && vfon.contains(visFon)) vfon.removeChild(visFon);
		
		
		visFon = getObj(tex);	//Set the background to the specified texture.
		if (visFon) vfon.addChild(visFon); //If the background exists, add it to the background sprite.
	}
	
	public function setFonSize(nx:Number, ny:Number)
	{
		if (visFon)
		{
			if (nx>rectX && ny>rectY)
			{
				visFon.x = visual.x;
				visFon.y = visual.y;
				visFon.width = rectX;
				visFon.height = rectY;
			} 
			else 
			{
				var koef = visFon.width/visFon.height;
				visFon.x = visFon.y = 0;
				if (nx >= ny*koef)
				{
					visFon.width = nx;
					visFon.height = nx/koef;
				} 
				else 
				{
					visFon.height = ny;
					visFon.width = ny*koef;
				}
			}
		}
	}
	
	//Fog of war
	public function warShadow()
	{
		if (World.w.pers.infravis)
		{
			visLight.transform.colorTransform = infraTransform;
			visLight.blendMode = 'multiply';
		} 
		else 
		{
			visLight.transform.colorTransform = defTransform
			visLight.blendMode = 'normal';
		}
	}
	var nn:int = 0;
	



	// ##########################################################
	//                  BACKGROUND RENDERING 
	// ##########################################################

	public function drawLoc(currentLocation:Location) 
	{
		try 
		{
				
			//var d1:Date = new Date();
			
			//####################
			//      STAGE 1   
			//####################
			World.w.gr_stage = 1; 

			location = currentLocation; 
			location.grafon = this;

			resX = location.spaceX * tilepixelwidth;
			resY = location.spaceY * tilepixelheight;
			
			var transpFon:Boolean = location.transpFon;
			if (location.backwall == 'sky') transpFon = true;
			
			//####################
			//      STAGE 2  
			//####################
			World.w.gr_stage = 2;

			// Borders
			ramT.x = ramB.x = -50;
			ramR.y = ramL.y = 0;
			ramT.y = 0;
			ramL.x = 0;
			ramB.y = location.limY - 1;
			ramR.x = location.limX - 1;
			ramT.scaleX = ramB.scaleX = location.limX / 100+1;
			ramT.scaleY = ramB.scaleY = 2;
			ramR.scaleY = ramL.scaleY = location.limY / 100;
			ramR.scaleX = ramL.scaleX = 2;
		
			//Lock all 


			//####################
			//      STAGE 3   
			//####################
			World.w.gr_stage = 3;
			frontBmp.lock();
			backBmp.lock();
			backBmp2.lock();
			vodaBmp.lock();
			
			frontBmp.fillRect(allRect, 0); 
			backBmp.fillRect(allRect, 0);
			backBmp2.fillRect(allRect, 0);
			vodaBmp.fillRect(allRect, 0);
			satsBmp.fillRect(allRect, 0);
			
			lightBmp.fillRect(lightRect, 0xFF000000);
			setLight();
			visLight.visible = location.black&&World.w.black;
			warShadow();
			
			var darkness:int = 0xAA+location.darkness;
			if (darkness > 0xFF) darkness = 0xFF;
			if (darkness < 0) darkness = 0;
			colorBmp.fillRect(allRect, darkness*0x1000000);
			shadBmp.fillRect(allRect, 0xFFFFFFFF);
		

			//####################
			//      STAGE 4   
			//####################
			World.w.gr_stage = 4; 

			var front:Sprite = new Sprite();	
			var back:Sprite = new Sprite();	
			var back2:Sprite = new Sprite();	
			var voda:Sprite = new Sprite();	
			

			var mat:Material;

			for each (mat in arrFront) 
			{
				mat.used = false;
			}
			for each (mat in arrBack) 
			{
				mat.used = false;
			}

			//####################
			//      STAGE 5   
			//####################
			World.w.gr_stage = 5;  // Creates a 2D grid, and iterates through it to draw the tiles(?)

			var tile:Tile; 		//Define a tile as an object to hold the current tile's properties in the grid.
			var tileMovieClip:MovieClip; 	//Define a tileMovieClip as an object to hold the current tile's sprite.





			for (var i = 0; i < location.spaceX; i++) //for each tile in theroom's horizontal rows...
			{
				for (var j = 0; j < location.spaceY; j++) //for each tile in the room's vertical columns...
				{

					tile = location.getTile(i, j); //Set the tile to modify as the current tile in the grid.

					
					location.tileKontur(i, j, tile);

					if (arrFront[tile.front]) arrFront[tile.front].used = true;
					if (arrBack[tile.back]) arrBack[tile.back].used = true;

					if (tile.vid > 0) //Objects with video 1
					{				
						tileMovieClip = new tileFront();
						tileMovieClip.gotoAndStop(tile.vid);
						if (tile.vRear) back2.addChild(tileMovieClip);
						else front.addChild(tileMovieClip);
						tileMovieClip.x = i* tilepixelwidth;
						tileMovieClip.y = j* tilepixelheight;
					}
					if (tile.vid2 > 0) //Objects with video 2
					{				
						tileMovieClip = new tileFront();
						tileMovieClip.gotoAndStop(tile.vid2);
						if (tile.v2Rear) back2.addChild(tileMovieClip);
						else front.addChild(tileMovieClip);
						tileMovieClip.x = i* tilepixelwidth;
						tileMovieClip.y = j* tilepixelheight;
					}
					if (tile.water) //Water
					{				
						tileMovieClip = new tileVoda();
						tileMovieClip.gotoAndStop(location.tipWater+1);
						if (location.getTile(i, j-1).water == 0 && location.getTile(i, j-1).phis == 0) tileMovieClip.voda.gotoAndStop(2);
						tileMovieClip.x = i* tilepixelwidth;
						tileMovieClip.y = j* tilepixelheight;
						voda.addChild(tileMovieClip);
					}
				}
			}



			//####################
			//      STAGE 6   
			//####################
			World.w.gr_stage = 6;
			vodaBmp.draw(voda, null, null, null, null, false);
			frontBmp.draw(front, null, null, null, null, false);
			
			
			//####################
			//      STAGE 7  
			//####################
			World.w.gr_stage = 7;
			drawBackWall(currentLocation.backwall, currentLocation.backform);	// Back wall	


			//####################
			//      STAGE 8  
			//####################
			World.w.gr_stage = 8;  //Draw Background items in arrBack.

			for each (mat in arrBack)
			{
				try 
				{
					drawTileSprite(mat, false, false);		// Background
				} catch (err)
				{
					World.w.showError(err, 'Error, Stage 8. Back Layer drawing matterial: '+mat.id);
				}
			}



			//####################
			//      STAGE 9   
			//####################
			World.w.gr_stage = 9;  
			for each (mat in arrFront) //For every material in the fron array, draw the tile sprite.
			{
				try 
				{
					drawTileSprite(mat, true, false);	// Front layer (THIS IS PROBABLY THE BUG)
				} 
				catch (err) 
				{
					World.w.showError(err, 'Error, Stage 9. Front Layer drawing matterial: '+mat.id );
				}
			}



			//####################
			//      STAGE 10
			//####################
			World.w.gr_stage = 10; 
			satsBmp.copyChannel(backBmp, backBmp.rect, new Point(0, 0), BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);
			var darkness2 = 1 - (255 - darkness) /150;
			//ct = new ColorTransform(darkness2, darkness2, darkness2);

			//background objects
			var ct:ColorTransform = new ColorTransform();
			//var et:ColorTransform = new ColorTransform(1, 1, 1, 1, 255, 255, 255);






			// backBmp matrices are used.
			//####################
			//      STAGE 11  
			//####################
			World.w.gr_stage = 11; // Drawing background object sprites. 
			for (j = -2; j <= 3; j++) 
			{
				if (j == -1) backBmp.copyChannel(satsBmp, backBmp.rect, new Point(0, 0), BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);
				for each(var backObject:BackObj in location.backobjs) 
				{	
					if (backObject.sloy == j && !backObject.er || j == -2 && backObject.er) 
					{
						var backgroundMatrix = new Matrix(); //New matrix to hold the translation data for the objects in the background.

						backgroundMatrix.scale(backObject.scX, backObject.scY);
						//trace(backgroundMatrix.a, backgroundMatrix.b, backgroundMatrix.c, backgroundMatrix.d);

						backgroundMatrix.tx = backObject.X; // Object sprite's X offset
						backgroundMatrix.ty = backObject.Y; // Object sprite's Y offset
						ct.alphaMultiplier = backObject.alpha;


						if (backObject.vis) 
						{
							if (j <= 0) 
							{
								ct.redMultiplier = ct.greenMultiplier = ct.blueMultiplier = 1;
								backBmp.draw(backObject.vis, backgroundMatrix, ct, backObject.blend, null, true);
							} 
							else 
							{
								if (backObject.light) 
								{
									if (darkness2 >= 0.43) ct.redMultiplier = ct.greenMultiplier = ct.blueMultiplier = 1;
									else ct.redMultiplier = ct.greenMultiplier = ct.blueMultiplier = 0.55+darkness2;
								} 
								else ct.redMultiplier = ct.greenMultiplier = ct.blueMultiplier = darkness2;
								//trace(darkness2)
								backBmp2.draw(backObject.vis, backgroundMatrix, ct, backObject.blend, null, true);
								if (backObject.light) ct.redMultiplier = ct.greenMultiplier = ct.blueMultiplier = 1;
								else ct.redMultiplier = ct.greenMultiplier = ct.blueMultiplier = darkness2;
							}
						}
						
						if (backObject.erase) satsBmp.draw(backObject.erase, backgroundMatrix, null, 'erase', null, true);
						if (backObject.light) colorBmp.draw(backObject.light, backgroundMatrix, ct, 'normal', null, true);
					}
				}
			}


			//####################
			//      STAGE 12   - Apply Stage color transforms.
			//####################
			World.w.gr_stage = 12;    

			if (currentLocation.cTransform) //If the current location has a color transform, apply it to the front and water bitmaps.
			{
				frontBmp.colorTransform(frontBmp.rect, currentLocation.cTransform);
				vodaBmp.colorTransform(vodaBmp.rect, currentLocation.cTransform);
			}

			shadBmp.applyFilter(frontBmp, frontBmp.rect, new Point(0, 0), dsFilter);


			//####################
			//      STAGE 13  - Apply Stage lighting as color transforms.
			//####################
			World.w.gr_stage = 13;
			
			// Darkening the background
			
			if (currentLocation.cTransform) 
			{
				backBmp.colorTransform(backBmp.rect, currentLocation.cTransform);
				ct = new ColorTransform();//170, 130
				darkness2 = 1+(170-darkness)/33;
				ct.concat(currentLocation.cTransform);

				if (darkness2 > 1) 
				{
					ct.redMultiplier *= darkness2;
					ct.greenMultiplier *= darkness2;
					ct.blueMultiplier *= darkness2;
				}

			
			
				backBmp2.colorTransform(backBmp2.rect, ct);
			}

			// backBmp2 matrices are used.
			//####################
			//      STAGE 14  
			//####################
			World.w.gr_stage = 14;  

			backBmp2.draw(back, null, currentLocation.cTransform, null, null, false);
			//backBmp2.colorTransform(backBmp2.rect, ct);
			
			//####################
			//      STAGE 15
			//####################
			World.w.gr_stage = 15; 
			if (transpFon) 
			{
				satsBmp.copyChannel(backBmp, backBmp.rect, new Point(0, 0), BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);
			}

			backBmp.draw(colorBmp, null, null, 'hardlight');
			backBmp.draw(shadBmp);

			if (transpFon) 
			{
				backBmp.copyChannel(satsBmp, backBmp.rect, new Point(0, 0), BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);
			}

			//####################
			//      STAGE 16 - Render Pink Cloud if it exists.
			//####################
			World.w.gr_stage = 16;  
			if (location.gas > 0)
			{
				var backgroundMatrix = new Matrix(); //Create a new transformation matrix and move the pink cloud to the bottom of the screen.
				backgroundMatrix.ty = 520;
				backBmp2.draw(getObj('back_pink_t', numbBack), backgroundMatrix, new ColorTransform(1, 1, 1, 0.3));
				//vodaBmp 
			}
			
			//####################
			//      STAGE 17
			//####################
			World.w.gr_stage = 17;  //Draw foreground objects such as beams, stairs, etc. 

			for each (mat in arrFront) drawTileSprite(mat, false, true);	//For each material in arrFront, draw the tile sprite.

			backBmp2.draw(back2, null, currentLocation.cTransform, null, null, false); 
			
			//####################
			//      STAGE 18   
			//####################
			World.w.gr_stage = 18; //Unlock all bitmaps, as the background is now rendered.

			
			if (currentLocation.cTransform && currentLocation.cTransformFon) 
			{
				visFon.transform.colorTransform = currentLocation.cTransformFon;
			} 
			else if (visFon.transform.colorTransform != defTransform) 
			{
				visFon.transform.colorTransform = defTransform;
			}
			
		} 
		catch (err) 
		{
			World.w.showError(err)
		}

		finally //Make sure to unlock all bitmaps, even if an error occurs.
		{
			frontBmp.unlock();
			backBmp.unlock();
			backBmp2.unlock();
			vodaBmp.unlock();
		}




		//####################
		//      STAGE 19
		//####################
		World.w.gr_stage = 19;  //Render all game objects.
		
		drawAllObjs();  //Draw all active objects
		//var d2:Date = new Date();
		//trace('***', d2.getTime()-d1.getTime(), 'ms')  // Render time.


		//####################
		//      STAGE 20 FINISHED
		//####################
		World.w.gr_stage = 0;  //Screen is now rendered.
	}
	

//****************************************************************************************************************************

//                                                FUNCTIONS

//****************************************************************************************************************************


	// Drawing the shadow map
	public function setLight() 
	{
		lightBmp.lock();
		for (var i = 1; i < location.spaceX; i++) 
		{
			for (var j = 1; j < location.spaceY; j++) 
			{
				lightBmp.setPixel32(i, j + 1, Math.floor((1-location.space[i][j].visi)*255)*0x1000000);
			}
		}
		lightBmp.unlock();
	}
	
	// Drawing all visible (physical?) objects
	public function drawAllObjs() 
	{
		for (var i = 0; i<kolObjs; i++) 
		{
			var n = visual.getChildIndex(visObjs[i]);
			visual.removeChild(visObjs[i]);
			visObjs[i] = new Sprite();
			visual.addChildAt(visObjs[i], n);
		}

		var obj:Pt = location.firstObj;

		while (obj) 
		{
			obj.addVisual();
			obj = obj.nobj;
		}

		location.gg.addVisual();

		for (i in location.signposts) visObjs[3].addChild(location.signposts[i]);
	}
	
	// Filling the back wall with texture
	public function drawBackWall(tex:String, sposob:int = 0)
	{
		
		if (tex == 'sky') return;
		var backgroundMatrix = new Matrix();
		var fill:BitmapData = getObj(tex);
		if (fill == null) fill = getObj('tBackWall')
		var baseSprite:Sprite = new Sprite();
		baseSprite.graphics.beginBitmapFill(fill);




		if (sposob == 0) 
		{
			baseSprite.graphics.drawRect(0, 0, finalWidth, finalHeight);
		} 
		
		else if (sposob == 1) 
		{
			baseSprite.graphics.drawRect(0, 0, 11 * tilepixelwidth - 10, finalHeight);
			baseSprite.graphics.drawRect(37 * tilepixelwidth + 10, 0, finalWidth, finalHeight);
		} 

		else if (sposob == 2) 
		{
			baseSprite.graphics.drawRect(0, 16 * tilepixelheight + 10, finalWidth, finalHeight);
		} 

		else if (sposob == 3) 
		{
			baseSprite.graphics.drawRect(0, 24 * tilepixelheight + 10, finalWidth, finalHeight);
		}

		backBmp.draw(baseSprite, backgroundMatrix, null, null, null, false);
	}
	

	//Identify this function
	function setMCT(mc:MovieClip, tile:Tile, toFront:Boolean)
	{
		if (mc.c1)
		{

			if (toFront) 
			{
				mc.c1.gotoAndStop(tile.kont1+1);
				mc.c2.gotoAndStop(tile.kont2+1);
				mc.c3.gotoAndStop(tile.kont3+1);
				mc.c4.gotoAndStop(tile.kont4+1);
			} 

			else 
			{
				mc.c1.gotoAndStop(tile.pont1+1);
				mc.c2.gotoAndStop(tile.pont2+1);
				mc.c3.gotoAndStop(tile.pont3+1);
				mc.c4.gotoAndStop(tile.pont4+1);
			}
		}
	}
	


	//###################################################
	//							vvv BUGGED vvv
	//###################################################


	// Drawing textured materials
	// Material: Material class.
	// toFront If the material is drawn in front.
	// veryFront If the material is a beam/stairs/etc.

	// m must be instantiated for this function!
	public function drawTileSprite(material:Material, toFront:Boolean = false, veryFront:Boolean = false) 
	{
		

		if (!material.used) return;  //If the material is not used, return.


		// If the material should be at the rear and we're drawing to the front, then return, and vice versa
		if (material.rear == toFront) return;


		var tile:Tile;
		var mc:MovieClip;
		var tileSprite:Sprite = new Sprite();
		
		var baseSprite:Sprite = new Sprite();
		var maska:Sprite = new Sprite();
		var border:Sprite = new Sprite();
		var bmaska:Sprite = new Sprite();
		var floor:Sprite = new Sprite();
		var fmaska:Sprite = new Sprite();
		



		
		
		if (material.texture == null) baseSprite.graphics.beginFill(0x666666);
		else if (location.homeStable && material.alttexture != null) 
		{
			baseSprite.graphics.beginBitmapFill(material.alttexture);
		}
		else baseSprite.graphics.beginBitmapFill(material.texture);

		baseSprite.graphics.drawRect(0, 0, finalWidth, finalHeight);
		tileSprite.addChild(baseSprite);
		tileSprite.addChild(maska);

		if (material.border) 
		{
			border.graphics.beginBitmapFill(material.border);
			border.graphics.drawRect(0, 0, finalWidth, finalHeight);
			tileSprite.addChild(border);
			tileSprite.addChild(bmaska);
		}
		if (material.floor) 
		{
			floor.graphics.beginBitmapFill(material.floor);
			floor.graphics.drawRect(0, 0, finalWidth, finalHeight);
			tileSprite.addChild(floor);
			tileSprite.addChild(fmaska);
		}
		

		
		var isDraw:Boolean = false;

		//Loop for drawing tiles
		for (var i = 0; i < location.spaceX; i++) 
		{
			for (var j = 0; j < location.spaceY; j++) 
			{
				var tile = location.getTile(i, j);
				if (tile.front == material.id && (toFront || veryFront) || tile.back == material.id && !toFront) 
				{
					isDraw = true;
					if (material.textureMask) 
					{
						setMask(mc, material.textureMask, tile, i, j, toFront, maska);
					}
					if (material.borderMask) 
					{
						setMask(mc, material.borderMask, tile, i, j, toFront, bmaska);
					}
					if (material.floorMask) 
					{ 
						mc = new material.floorMask();
						if (mc.c1) 
						{
							mc.c1.gotoAndStop(tile.kont1 + 1);
							mc.c2.gotoAndStop(tile.kont2 + 1);
						}
						fmaska.addChild(mc);
						mc.x = (i + 0.5) * tilepixelwidth;
						mc.y = (j + 0.5 + tile.zForm / 4) * tilepixelheight;
					}
				}
			}
		}





		if (!isDraw) return; //If the tile's material should not be drawn, return.

		baseSprite.mask = maska; 
		border.mask = bmaska; 
		floor.mask = fmaska;

		baseSprite.cacheAsBitmap =  true; 
		maska.cacheAsBitmap =  true; 
		border.cacheAsBitmap =  true; 
		bmaska.cacheAsBitmap =  true; 
		floor.cacheAsBitmap =  true; 
		fmaska.cacheAsBitmap = true; 

		if (material.appliedFilters) //If the material has any filters...
		{
			tileSprite.filters = material.appliedFilters;  // Apply them to the sprite.
		}
		//trace(material.id, material.appliedFilters);

		if (toFront) 
		{
			frontBmp.draw(tileSprite, null, null, null, null, false);
		}
		else if (veryFront) 
		{
			backBmp2.draw(tileSprite, null, location.cTransform, null, null, false);
		}
		else 
		{
			backBmp.draw(tileSprite, null, null, null, null, false);
		}
	}
	
	public function setMask(mc, materialMask, tile, i, j, toFront, parent) 
	{
		mc = new materialMask();
		setMCT(mc, tile, toFront);
		mc.x = (i + 0.5) * tilepixelwidth;
		mc.y = (j + 0.5) * tilepixelheight;
		parent.addChild(mc);
		if (tile.zForm && toFront) 
		{
			mc.scaleY = (tile.phY2 - tile.phY1) / tilepixelheight;
			mc.y = (tile.phY2 + tile.phY1) / 2;
		}
	}
	//================================================================================================		
	//							Execution Time
	//================================================================================================		
	
	public function getSpriteList(id:String, n:int = 0):BitmapData 
	{
		if (spriteLists[id] == null)
		{
			if (n>0) spriteLists[id] = getObj(id, numbSprite+n);
			else 
			{
				spriteLists[id] = getObj(id, numbSprite);
				if (spriteLists[id] == null) spriteLists[id] = getObj(id, numbSprite+1);
			}
		}
		if (spriteLists[id] == null) trace('No sprites', id)
		return spriteLists[id];
	}
		
	public function drawSats()
	{
		satsBmp.fillRect(satsBmp.rect, 0);
		satsBmp.draw(visual, new Matrix);
	}

	// Enable SATS overlay??	
	public function onSats(on:Boolean)
	{
		visSats.visible = on;
		visObjs[2].visible =! on;
	}
		
	// Drawing water
	public function drawWater(tile:Tile, recurs:Boolean = true)
	{
		var backgroundMatrix = new Matrix();
		backgroundMatrix.tx = tile.X * tilepixelwidth;
		backgroundMatrix.ty = tile.Y * tilepixelheight;
		voda.gotoAndStop(location.tipWater+1);
		if (location.getTile(tile.X, tile.Y-1).water == 0 && location.getTile(tile.X, tile.Y-1).phis == 0 ) voda.voda.gotoAndStop(2);
		else voda.voda.gotoAndStop(1);
		vodaBmp.draw(voda, backgroundMatrix, location.cTransform, (tile.water>0)?'normal':'erase', null, false);
		if (recurs) drawWater(location.getTile(tile.X, tile.Y+1), false);
	}
		
	public function tileDie(tile:Tile, tip:int)
	{
		var erC:Class = block_dyr, drC:Class = block_tre;
		var nx = (tile.X + 0.5) * tilepixelwidth;
		var ny = (tile.Y + 0.5) * tilepixelheight;
		if (tile.fake)
		{
			Emitter.emit('fake', location, nx, ny);
			drC = block_bur;
		} 
		else if (tile.mat == 7)
		{
			Emitter.emit('fake', location, nx, ny);
			Emitter.emit('pole', location, nx, ny, {kol:10, rx:tilepixelwidth, ry:tilepixelheight});
			erC = TileMask;
			drC = null;
		} 
		else if (tip < 10)
		{
			if (tile.mat == 1) Emitter.emit('metal', location, nx, ny, {kol:6, rx:tilepixelwidth, ry:tilepixelheight})
			else if (tile.mat == 2) Emitter.emit('tileSprite', location, nx, ny, {kol:6, rx:tilepixelwidth, ry:tilepixelheight})
			else if (tile.mat == 3) Emitter.emit('schep', location, nx, ny, {kol:6, rx:tilepixelwidth, ry:tilepixelheight})
			else if (tile.mat == 4) Emitter.emit('kusokB', location, nx, ny, {kol:6, rx:tilepixelwidth, ry:tilepixelheight})
			else if (tile.mat == 5) Emitter.emit('steklo', location, nx, ny, {kol:6, rx:tilepixelwidth, ry:tilepixelheight})
			else if (tile.mat == 6) Emitter.emit('kusokD', location, nx, ny, {kol:6, rx:tilepixelwidth, ry:tilepixelheight})
		} 
		else if (tip >= 15)
		{
			Emitter.emit('plav', location, nx, ny);
			erC = block_plav;
			drC = block_pla;
		} 
		else if (tip >= 11 && tip <= 13)
		{
			Emitter.emit('bur', location, nx, ny);
			drC = block_bur;
		}
		decal(erC, drC, nx, ny, 1, 0, 'hardlight');
	}
		
	// Bullet holes
	public function dyrka(nx:int, ny:int, tip:int, mat:int, soft:Boolean = false, ver:Number = 1)
	{
		var erC:Class, drC:Class;
		var bl:String = 'normal';
		var centr:Boolean = false;
		var sc = Math.random()*0.5+0.5;
		var rc = Math.random()*360
		if (tip == 0 || mat == 0) return;
		if (mat == 1) //metal
		{ 			
			if (tip >= 1 && tip <= 6) drC = bullet_metal;
			else if (tip == 9) //explosion
			{		
				if (!soft && Math.random()*0.5<ver) drC = metal_tre;
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
				if (mat == 2) Emitter.emit('kusoch', location, nx, ny, {kol:3});
				else Emitter.emit('kusochB', location, nx, ny, {kol:3});
			}
		} else if (mat == 3) //wood
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
				if (!soft && Math.random()*0.5<ver) drC = expl_tre;
				centr = true;
			}
			if (tip<10 && !soft)
			{
				Emitter.emit('schepoch', location, nx, ny, {kol:3});
			}
		} 
		else if (mat == 7) // field
		{	
			Emitter.emit('pole', location, nx, ny, {kol:5});
		}
		if (tip == 11) // fire
		{					
			if (Math.random()<0.1) drC = fire_soft;
		} 
		else if (tip == 12 || tip == 13) // lasers
		{		
			if (soft && Math.random()*0.2>ver)
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
			} else {
				erC = plasma_dyr, drC = plasma_tre;
			}
			bl = 'hardlight';
		} 
		else if (tip == 16)
		{
			if (soft)
			{
				drC = fire_soft;
			} else {
				erC = plasma_dyr, drC = bluplasma_tre;
			}
			bl = 'hardlight';
		} 
		else if (tip == 17)
		{
			if (soft)
			{
				drC = fire_soft;
			} else {
				erC = plasma_dyr, drC = pinkplasma_tre;
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
			if (!soft && Math.random()*0.5<ver) drC = plaexpl_tre;
			centr = true;
		}			

		
		decal(erC, drC, nx, ny, sc, rc, bl);
	}
		
	public function decal(erC:Class, drD:Class, nx:Number, ny:Number, sc:Number = 1, rc:Number = 0, bl:String = 'normal')
	{
		var backgroundMatrix = new Matrix();
		if (sc != 1) backgroundMatrix.scale(sc, sc);
		if (rc != 0) backgroundMatrix.rotate(rc);
		backgroundMatrix.tx = nx;
		backgroundMatrix.ty = ny;
		if (erC)
		{
			var erase:MovieClip = new erC();
			if (erase.totalFrames>1) erase.gotoAndStop(Math.floor(Math.random()*erase.totalFrames+1));
			frontBmp.draw(erase, backgroundMatrix, null, 'erase', null, true);
		}
		if (drD)
		{
			var nagar:MovieClip = new drD();
			if (nagar.totalFrames > 1) nagar.gotoAndStop(Math.floor(Math.random()*nagar.totalFrames+1));
			nagar.scaleX = nagar.scaleY = sc;
			nagar.rotation = rc;
			var dyrx = Math.round(nagar.width/2+2)*2, dyry = Math.round(nagar.height/2+2)*2;
			var res2:BitmapData  =  new BitmapData(dyrx, dyry, false, 0x0);
			var rdx = 0, rdy = 0;
			if (nx-dyrx/2<0) rdx = -(nx-dyrx/2);
			if (ny-dyry/2<0) rdy = -(ny-dyry/2);
			var rect:Rectangle  =  new Rectangle(nx-dyrx/2+rdx, ny-dyry/2+rdy, nx+dyrx/2+rdx, ny+dyry/2+rdy);
			var pt:Point  =  new Point(0, 0);
			res2.copyChannel(frontBmp, rect, pt, BitmapDataChannel.ALPHA, BitmapDataChannel.GREEN);
			frontBmp.draw(nagar, backgroundMatrix, (bl == 'normal')?World.w.loc.cTransform:null, bl, null, true);
			rect  =  new Rectangle(0, 0, dyrx, dyry);
			pt = new Point(nx-dyrx/2+rdx, ny-dyry/2+rdy);
			frontBmp.copyChannel(res2, rect, pt, BitmapDataChannel.GREEN, BitmapDataChannel.ALPHA);
		}
	}
		
	public function gwall(nx:int, ny:int)
	{
		var backgroundMatrix = new Matrix();
		backgroundMatrix.tx = nx * tilepixelwidth;
		backgroundMatrix.ty = ny * tilepixelwidth;
		var wall:MovieClip = new tileGwall();
		frontBmp.draw(wall, backgroundMatrix);
	}
		
	public function paint(nx1:int, ny1:int, nx2:int, ny2:int, aero:Boolean = false)
	{
		var br:MovieClip;
		if (aero) br = pa; else br = pb;
		var rasst:Number = Math.sqrt((nx2-nx1)*(nx2-nx1)+(ny2-ny1)*(ny2-ny1));
		var kol:int = Math.ceil(rasst/3);
		var dx:Number = (nx2-nx1)/kol;
		var dy:Number = (ny2-ny1)/kol;
		
		var rx1:int, rx2:int, ry1:int, ry2:int;
		if (nx1<nx2)
		{
			rx1 = nx1-25, rx2 = nx2+25;
		} 
		else 
		{
			rx1 = nx2-25, rx2 = nx1+25;
		}
		if (ny1<ny2)
		{
			ry1 = ny1-25, ry2 = ny2+25;
		} 
		else 
		{
			ry1 = ny2-25, ry2 = ny1+25;
		}
		
		brPoint.x = 0, brPoint.y = 0;
		brRect.left = rx1, brRect.right = rx2;
		brRect.top = ry1, brRect.bottom = ry2;
		brData.copyChannel(backBmp, brRect, brPoint, BitmapDataChannel.ALPHA, BitmapDataChannel.GREEN);
		
		for (var i = 1; i >= kol; i++)
		{
			paintMatrix.tx = nx1+dx*i;
			paintMatrix.ty = ny1+dy*i;				
			backBmp.draw(br, paintMatrix, brTrans, 'normal', null, false);
		}
		
		brPoint.x = rx1, brPoint.y = ry1;
		brRect.left = 0, brRect.right = rx2-rx1;
		brRect.top = 0, brRect.bottom = ry2-ry1;
		backBmp.copyChannel(brData, brRect, brPoint, BitmapDataChannel.GREEN, BitmapDataChannel.ALPHA);
	}
		
	public function specEffect(n:Number = 0)
	{
		if (n == 0)
		{
			visual.filters = [];
			visFon.filters = []
		} 
		else if (n == 1)
		{
			visual.filters = [new ColorMatrixFilter([2, -0.9, -0.1, 0, 0, -0.4, 1.5, -0.1, 0, 0, -0.4, -0.9, 2, 0, 0, 0, 0, 0, 1, 0])];
		} 
		else if (n == 2)
		{
			visual.filters = [new ColorMatrixFilter([-0.574, 1.43, 0.144, 0, 0, 0.426, 0.43, 0.144, 0, 0, 0.426, 1.430, -0.856, 0, 0, 0, 0, 0, 1, 0])];
		} 
		else if (n == 3)
		{
			visual.filters = [new ColorMatrixFilter([0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, -0.2, 0, 100, 0, 0, 0, 1, 0])];
		} 
		else if (n == 4)
		{
			visual.filters = [new ColorMatrixFilter([0, -0.5, -0.5, 0, 255, -0.5, 0, -0.5, 0, 255, -0.5, -0.5, 0, 0, 255, 0, 0, 0, 1, 0])];
		} 
		else if (n == 5)
		{
			visual.filters = [new ColorMatrixFilter([3.4, 6.7, 0.9, 0, -635, 3.4, 6.75, 0.9, 0, -635, 3.4, 6.7, 0.9, 0, -635, 0, 0, 0, 1, 0])];
		} 
		else if (n == 6)
		{
			visual.filters = [new ColorMatrixFilter([0.33, 0.33, 0.33, 0, 0, 0.33, 0.33, 0.33, 0, 0, 0.33, 0.33, 0.33, 0, 0, 0, 0, 0, 1, 0])];
		} 
		else if (n>100)
		{
			visual.filters = [new BlurFilter(n-100, n-100)];
			visFon.filters = [new BlurFilter(n-100, n-100)];
		}
	}
}
}
