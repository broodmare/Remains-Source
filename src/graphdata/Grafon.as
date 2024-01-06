package graphdata
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
	import flash.filters.BlurFilter;
	import flash.filters.ColorMatrixFilter;
	import flash.filters.DropShadowFilter;

	import fl.motion.Color;

	import locdata.*;
	import locdata.Room;

	import components.Settings;
	import components.XmlBook;

	import stubs.visBlack;
	import stubs.tileFront;
	import stubs.tileVoda
	import stubs.tileGwall;

	public class Grafon
	{

		public var room:Room;

		public var mainCanvas:Sprite;			// Sprite that all 6 layers are drawn onto (Screenspace?)
		public var layerBackground_1:Sprite;	// Layer 1
		public var layerBackground_2:Sprite;	// Layer 2
		public var layerWater:Sprite;			// Layer 3
		public var visFront:Sprite;				// Layer 4
		public var layerLighting:Sprite;		// Layer 5
		public var layerSats:Sprite;			// Layer 6
		
		public var canvasLayerArray:Array;
		public var skyboxTexture:MovieClip;
		
		//public var resX:int;
		//public var resY:int;

		//Textured area size
		public var mapTileWidth:int;  	//Size of map width in tiles
		public var mapTileHeight:int;	//Size of map height in tiles
		
		//BITMAPS
		public var frontBitmap:Bitmap;
		public var vodaBitmap:Bitmap;
		public var backBitmap:Bitmap;
		public var backBitmap2:Bitmap;
		public var lightBitmap:Bitmap;
		public var satsBitmap:Bitmap;

		//BITMAP DATA
		public var frontBmp:BitmapData;
		public var vodaBmp:BitmapData;
		public var backBmp:BitmapData;
		public var backBmp2:BitmapData;
		public var lightBmp:BitmapData;
		public var satsBmp:BitmapData;
		public var shadBmp:BitmapData;
		public var colorBmp:BitmapData;

		public var dsFilter:DropShadowFilter;				// Adds a drop shadow to objects. (What objects?)
		public var infraTransform:ColorTransform;			// Fog of war stuff.
		public var defTransform:ColorTransform;				// Fog of war stuff.

		// Spraypainting TODO: Move to another class.
		public var pa:MovieClip;
		public var pb:MovieClip;
		public var brTrans:ColorTransform;
		public var brColor:Color;
		public var brData:BitmapData;
		public var brPoint:Point;
		public var brRect:Rectangle;
		public var paintMatrix:Matrix;

		//Screen Borders
		public var borderTop:MovieClip;						// Black border around the screen
		public var borderBottom:MovieClip;					// Black border around the screen
		public var borderLeft:MovieClip;					// Black border around the screen
		public var borderRight:MovieClip;					// Black border around the screen
		
		public var tileArray:Array;							// Holds all interactable tiles and climbables (ladders, beams, stairs).
		public var backwallArray:Array; 					// Holds all decorative background (backwall) textures.
		
		public var screenResX:int;							// Horizontal screen resolution
		public var screenResY:int;							// Vertical screen resolution
		public var screenArea:Rectangle;					// Screen area (Width x Height)
		public var lightX:int;								// Width of bitmap used for lighting.
		public var lightY:int;								// Height of the bitmap used for lighting.	//Why is this different?
		public var lightRect:Rectangle;						// Area of the bitmap used for lighting. 

		public var grLoaderArray:Array; 					// Array to hold resource loaders.
		public var resourcesLoaded:Boolean;					// Have the textures been loaded?
		public var progressLoad:Number;						// Progess of all loaders as a number.

		public static var spriteLists:Array = [];	//Array of all active sprites.
		public static var resourceURLArray:Array = ['data/texture.swf', 'data/texture1.swf', 'data/sprite.swf', 'data/sprite1.swf']; //URLs of the files to load

		public static const canvasLayerCount:int = 6; 		// Number of Layers to be rendered on mainCanvas.
		public static const activeMaterials:int  = 0;		// Active Materials 
		public static const skyboxCount:int   	 = 0;		// Active Skybox Textures
		public static const bgObjectCount:int 	 = 1;		// Active Background Objects
		public static const objectCount:int   	 = 1;		// Active Objects
		public static const spriteCount:int   	 = 2;		// Active Sprites (starts at 2 because of Main and MainMenu)
		public var tilepixelwidth:int; 						// Tile Width in pixels.
		public var tilepixelheight:int;						// Tile Height in pixels.
		public var finalWidth:int;							// (mapTileWidth * tilepixelwidth) 	 - Precalculated to save time.
		public var finalHeight:int;							// (mapTileHeight * tilepixelheight) - Precalculated to save time.
		
		public var nn:int;									// Something for side quests? Why is this here?

		public var voda:MovieClip;  						// Water tile MovieClip from pfe.fla

		//moved variables
		private var transparentBackground:Boolean;
		private var darkness:int;
		private var canvasTileFront:Sprite; 							// Texture that ALL tile front textures are drawn to
		private var canvasTileBack:Sprite; 							// Texture that ALL tile background textures are drawn to
		private var back2:Sprite; 							// Texture that back walls and skyboxes are drawn to
		private var canvasWater:Sprite;							// water texture?

		//defines
		//Colors as ARGB values
		private static var TRANSPARENT:uint = 0x00000000;
		private static var BLACK:uint = 0xFF000000;
		private static var WHITE:uint = 0xFFFFFFFF;


		public function Grafon(nvis:Sprite)
		{
			
			trace('Grafon.as/Grafon() - Grafon initializing...');
			mapTileWidth 	= 48; 
			mapTileHeight 	= 25;

			//trace('Grafon.as/Grafon() - Initializing TileFilter array.');
			var tilefilter:TileFilter = new TileFilter();

			dsFilter 		= new DropShadowFilter(7, 90, 0, 0.75, 16, 16, 1, 3, false, false, true);
			infraTransform 	= new ColorTransform(1, 1, 1, 1, 100);
			defTransform 	= new ColorTransform();
			
			pa 				= new paintaero();
			pb 				= new paintbrush();
			
			brTrans 		= new ColorTransform();
			brColor 		= new Color();
			brData  		= new BitmapData(100, 100, false, 0x0);
			brPoint  		= new Point(0, 0);
			brRect 			= new Rectangle(0, 0, 50, 50);

			paintMatrix 	= new Matrix();

			screenResX 		= 1920;
			screenResY 		= 1000;
			screenArea 		= new Rectangle(0, 0, screenResX, screenResY);

			lightX 			= 49;
			lightY 			= 28;
			lightRect 		= new Rectangle(0, 0, lightX, lightY);
			
			progressLoad 	= 0;
			resourcesLoaded = false; 
			
			nn = 0;

			tilepixelwidth 	= Tile.tilePixelWidth;
			tilepixelheight = Tile.tilePixelHeight;
			finalWidth 	= mapTileWidth 	* tilepixelwidth;
			finalHeight = mapTileHeight * tilepixelheight;

			mainCanvas 			= nvis;
			layerBackground_1 	= new Sprite();
			layerBackground_2 	= new Sprite();
			layerWater 			= new Sprite();
			layerWater.alpha 	= 0.6;
			visFront 			= new Sprite();
			layerLighting 		= new Sprite();
			layerSats 			= new Sprite();
			canvasLayerArray 	= [];

			layerSats.visible 	= false;
			layerSats.filters 	= [new BlurFilter(3, 3, 1)];
			
			trace('Grafon.as/Grafon() - Adding sprites to main canvas...');
			for (var i:int = 0; i < canvasLayerCount; i++) 
			{
				canvasLayerArray.push(new Sprite());
			}

			mainCanvas.addChild(layerBackground_1);		//0
			mainCanvas.addChild(layerBackground_2);		//0
			mainCanvas.addChild(canvasLayerArray [0]);	//1
			mainCanvas.addChild(canvasLayerArray [1]);	//2
			mainCanvas.addChild(canvasLayerArray [2]);	//3
			mainCanvas.addChild(visFront);				//4   Ghost walls, Decals, Color transform, dropShadow (isTopLayer) indicates this.
			mainCanvas.addChild(canvasLayerArray [3]);	//6 
			mainCanvas.addChild(layerWater);			//5  water bitmap is applied to this
			mainCanvas.addChild(layerLighting);			//7
			mainCanvas.addChild(canvasLayerArray [4]);	//8
			mainCanvas.addChild(layerSats);				//9
			mainCanvas.addChild(canvasLayerArray [5]);	//10
			
			layerLighting.x = -tilepixelwidth / 2;
			layerLighting.y = -tilepixelheight / 2 - tilepixelheight;
			layerLighting.scaleX = tilepixelwidth;
			layerLighting.scaleY = tilepixelheight;
			
			trace('Grafon.as/Grafon() - Creating bitmaps...');
			frontBmp 	= new BitmapData(screenResX, screenResY, true, TRANSPARENT)
			frontBitmap =  new Bitmap(frontBmp);
			visFront.addChild(frontBitmap);
			
			backBmp		= new BitmapData(screenResX, screenResY, true, TRANSPARENT)
			backBitmap 	=  new Bitmap(backBmp);
			layerBackground_1.addChild(backBitmap);
			
			backBmp2 	= new BitmapData(screenResX, screenResY, true, TRANSPARENT)
			backBitmap2 =  new Bitmap(backBmp2);
			layerBackground_2.addChild(backBitmap2);

			vodaBmp 	= new BitmapData(screenResX, screenResY, true, TRANSPARENT)
			vodaBitmap  =  new Bitmap(vodaBmp);
			layerWater.addChild(vodaBitmap);
			
			satsBmp 	= new BitmapData(screenResX, screenResY, true, TRANSPARENT);
			satsBitmap  =  new Bitmap(satsBmp, 'auto', true);
			layerSats.addChild(satsBitmap);
			
			colorBmp 	= new BitmapData(screenResX, screenResY, true, TRANSPARENT);
			shadBmp 	= new BitmapData(screenResX, screenResY, true, TRANSPARENT);
			
			lightBmp 	= new BitmapData(lightX, lightY, true, BLACK);
			lightBitmap = new Bitmap(lightBmp, 'auto', true);
			layerLighting.addChild(lightBitmap);

			borderTop 	 = new visBlack();
			borderBottom = new visBlack();
			borderRight  = new visBlack();
			borderLeft   = new visBlack();

			borderTop.cacheAsBitmap 	= Settings.bitmapCachingOption;
			borderBottom.cacheAsBitmap 	= Settings.bitmapCachingOption;
			borderRight.cacheAsBitmap 	= Settings.bitmapCachingOption;
			borderLeft.cacheAsBitmap 	= Settings.bitmapCachingOption;

			mainCanvas.addChild(borderTop);
			mainCanvas.addChild(borderBottom);
			mainCanvas.addChild(borderRight);
			mainCanvas.addChild(borderLeft);

			grLoaderArray = [];
			
			trace('Grafon.as/Grafon() - Creating resource resource loader array...');
			for (var j:int = 0; j < resourceURLArray.length; j++) //Resource URL list setup.
			{
				var resourceURL:String = resourceURLArray[j]; //Populates the array with texture URLs.
				grLoaderArray[j] = new GrLoader(j, resourceURL, this); //Instantiates a graphics loader for each URL in the array to load it's contents.
			}

			trace('Grafon.as/Grafon() - Adding mouse cursor...');
			CursorHandler.createCursors();

			trace('Grafon.as/Grafon() - Grafon intitialized. ');
		}

		//Check if all instances of GrLoader have finished.
		public function checkLoaded():void
		{
			var allLoaded:Boolean = true;

			for each (var loader:Object in grLoaderArray)
			{
				if (!loader.isLoad)
				{
					allLoaded = false;
					break;
				}
			}

			if (allLoaded)
			{
				trace('Grafon.as/checkLoaded() - All resources loaded, calling material Setup!');
				materialSetup();
			}
		}
		
		public function materialSetup():void
		{
			trace('Grafon.as/materialSetup() - Setting up materials');
			tileArray 		= [];	//Holds all Backwall Materials regardless of whether they're currently being used.
			backwallArray   = []; 	//Holds all Backwall Materials regardless of whether they're currently being used.

			for each (var newMat:XML in XmlBook.getXML("materials").mat)
			{
				if (newMat.@vid.length() == 0) // Not a stair or beam
				{
					if (newMat.@drawLayer == 2) //Back wall texture
					{
						backwallArray[newMat.@id] = new Material(newMat);
					}
					else //Tile texture
					{
						tileArray[newMat.@id] = new Material(newMat);
					}
				}
			}
			trace('Grafon.as/Grafon() - Setup complete. tileArray count: "' + countArray(tileArray) + '." backwallArray count: "' + countArray(backwallArray) + '." Setting resourcesLoaded to true.');
			resourcesLoaded = true;
		}

		private function countArray(array:Array):int
		{
			var count:int = 0;
			for (var key:* in array) 
			{
				count++;
			}
    		return count;
		}

		//Determine progress of loading.
		public function allProgress():void
		{
			progressLoad = 0; //Clear the current progress.
			for (var loaderID:String in grLoaderArray) //for each loader in the array of loaders...
			{
				progressLoad += grLoaderArray[loaderID].progressLoad; //Add the progress of the loader to the total progress.
			}
			
			progressLoad /= GrLoader.instanceCount;
		}
		

		
		//================================================================================================		
		//							Initial Room Drawing
		//================================================================================================		
		
		// When this function is called, it takes a texture name and grLoader ID.
		// It then looks through the current Grafon's grLoaderArray for [loaderID].
		// In [LoaderID] it will then try run the getObj function contained inside it's 'resource' property.
		// The grLoader.resource will then (hopefully?) return the result.
		public function getObj(textureName:String, loaderID:int = 0):* 
		{
			var obj:* = grLoaderArray[loaderID].resource.getObj(textureName);
			return obj;
		}
		
		public function changeSkybox():void
		{
			var textureID:String = GameSession.currentSession.level.levelTemplate.skybox;
			if (textureID == '' || textureID == null) textureID = 'fonDefault';
			trace('Grafon.as/changeSkybox() - Rendering skybox texture ID: "' + textureID + '".');

			if (skyboxTexture && GameSession.currentSession.skybox.contains(skyboxTexture)) GameSession.currentSession.skybox.removeChild(skyboxTexture); //Remove the old skybox texture from the canvas.

			skyboxTexture = getObj(textureID); // Retrieve the skybox texture.
			if (skyboxTexture) GameSession.currentSession.skybox.addChild(skyboxTexture); //Add the texture to the canvas for rendering.
			else trace('Grafon.as/changeSkybox() - ERROR - Could not change skybox texture!');
		}
		
		public function setSkyboxSize(nx:Number, ny:Number):void
		{
			if (skyboxTexture)
			{
				if (nx > screenResX && ny > screenResY)
				{
					skyboxTexture.x = mainCanvas.x;
					skyboxTexture.y = mainCanvas.y;
					skyboxTexture.width = screenResX;
					skyboxTexture.height = screenResY;
				} 
				else 
				{
					var koef:Number = skyboxTexture.width / skyboxTexture.height;
					skyboxTexture.x = skyboxTexture.y = 0;
					if (nx >= ny*koef)
					{
						skyboxTexture.width = nx;
						skyboxTexture.height = nx/koef;
					} 
					else 
					{
						skyboxTexture.height = ny;
						skyboxTexture.width  = ny * koef;
					}
				}
			}
		}
		
		public function warShadow():void //Fog of war
		{
			if (GameSession.currentSession.pers.infravis)
			{
				layerLighting.transform.colorTransform = infraTransform;
				layerLighting.blendMode = 'multiply';
			} 
			else 
			{
				layerLighting.transform.colorTransform = defTransform
				layerLighting.blendMode = 'normal';
			}
		}

		// ##########################################################
		//                  BACKGROUND RENDERING 
		// ##########################################################

		public function drawLoc(roomToRender:Room):void 
		{
			GameSession.currentSession.gr_stage = 1;
			intializeRoomAndSkyType();

			GameSession.currentSession.gr_stage = 2;
			determineRoomBorderSize();
			
			GameSession.currentSession.gr_stage = 3;
			redrawLighting();

			GameSession.currentSession.gr_stage = 4;
			resetScreen();

			GameSession.currentSession.gr_stage = 5;
			drawAllTilesToCanvas();

			//####################
			//      STAGE 6   
			//####################
			//trace('Grafon.as/drawLoc - RENDERING STEP 6/20');
			GameSession.currentSession.gr_stage = 6;
			vodaBmp.draw(canvasWater, null, null, null, null, false);
			frontBmp.draw(canvasTileFront, null, null, null, null, false);

				
			//####################
			//      STAGE 7  		// Background rendering
			//####################
			//trace('Grafon.as/drawLoc - RENDERING STEP 7/20');
			GameSession.currentSession.gr_stage = 7;
			drawBackWall(room.backwall, room.backform);
			

			//####################
			//      STAGE 8  		// BACKWALL LAYER
			//####################
			//trace('Grafon.as/drawLoc - RENDERING STEP 8/20');
			GameSession.currentSession.gr_stage = 8;  //Draw Background items in backwallArray.
			for (var m:int = 0; m < backwallArray.length; m++)
			{
				drawTileSprite(backwallArray[m], false, false);
			}


			//####################
			//      STAGE 9   		// CLIMBABLE LAYER
			//####################
			//trace('Grafon.as/drawLoc - RENDERING STEP 9/20');
			GameSession.currentSession.gr_stage = 9;  
			for (var n:int = 0; n < backwallArray.length; n++)
			{
				drawTileSprite(backwallArray[n], true, false);
			}
			

			//####################
			//      STAGE 10
			//####################
			//trace('Grafon.as/drawLoc - RENDERING STEP 10/20');
			GameSession.currentSession.gr_stage = 10;
			satsBmp.copyChannel(backBmp, backBmp.rect, new Point(0, 0), BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);
			var darkness2:Number = 1 - (255 - darkness) /150;
			var ct:ColorTransform = new ColorTransform(); //background objects

			//####################
			//      STAGE 11  
			//####################
			//trace('Grafon.as/drawLoc - RENDERING STEP 11/20');
			GameSession.currentSession.gr_stage = 11; // Drawing background object sprites.
			for (var o:int = -2; o <= 3; o++) 
			{
				if (o == -1) backBmp.copyChannel(satsBmp, backBmp.rect, new Point(0, 0), BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);


				for (var p:int = 0; p > room.backobjs.length; p++)
				{	
					if (room.backobjs[p].layer == o && !room.backobjs[p].er || o == -2 && room.backobjs[p].er) 
					{
						var backgroundMatrix:Matrix = new Matrix(); //New matrix to hold the translation data for the objects in the background.

						backgroundMatrix.scale(room.backobjs[p].scX, room.backobjs[p].scY);

						backgroundMatrix.tx = room.backobjs[p].X; // Object sprite's X offset
						backgroundMatrix.ty = room.backobjs[p].Y; // Object sprite's Y offset
						ct.alphaMultiplier = room.backobjs[p].alpha;


						if (room.backobjs[p].vis) 
						{
							if (o <= 0) 
							{
								ct.redMultiplier = ct.greenMultiplier = ct.blueMultiplier = 1;
								backBmp.draw(room.backobjs[p].vis, backgroundMatrix, ct, room.backobjs[p].blend, null, true);
							} 
							else 
							{
								if (room.backobjs[p].light) 
								{
									if (darkness2 >= 0.43) ct.redMultiplier = ct.greenMultiplier = ct.blueMultiplier = 1;
									else ct.redMultiplier = ct.greenMultiplier = ct.blueMultiplier = 0.55+darkness2;
								} 
								else ct.redMultiplier = ct.greenMultiplier = ct.blueMultiplier = darkness2;
								backBmp2.draw(room.backobjs[p].vis, backgroundMatrix, ct, room.backobjs[p].blend, null, true);
								if (room.backobjs[p].light) ct.redMultiplier = ct.greenMultiplier = ct.blueMultiplier = 1;
								else ct.redMultiplier = ct.greenMultiplier = ct.blueMultiplier = darkness2;
							}
						}
						
						if (room.backobjs[p].erase) satsBmp.draw(room.backobjs[p].erase, backgroundMatrix, null, 'erase', null, true);
						if (room.backobjs[p].light) colorBmp.draw(room.backobjs[p].light, backgroundMatrix, ct, 'normal', null, true);
					}
				}
			}

			//####################
			//      STAGE 12   - Apply Stage color transforms.
			//####################
			//trace('Grafon.as/drawLoc - RENDERING STEP 12/20');
			GameSession.currentSession.gr_stage = 12;   
			if (room.cTransform) //If the current room has a color transform, apply it to the front and water bitmaps.
			{
				frontBmp.colorTransform(frontBmp.rect, room.cTransform);
				vodaBmp.colorTransform(vodaBmp.rect, room.cTransform);
			}

			shadBmp.applyFilter(frontBmp, frontBmp.rect, new Point(0, 0), dsFilter);


			//####################
			//      STAGE 13  - //Lighting
			//####################
			//trace('Grafon.as/drawLoc - RENDERING STEP 13/20');
			GameSession.currentSession.gr_stage = 13; // Darkening the background
			if (room.cTransform) 
			{
				backBmp.colorTransform(backBmp.rect, room.cTransform);
				ct = new ColorTransform();
				darkness2 = 1 + (170 - darkness) / 33;
				ct.concat(room.cTransform);

				if (darkness2 > 1) 
				{
					ct.redMultiplier *= darkness2;
					ct.greenMultiplier *= darkness2;
					ct.blueMultiplier *= darkness2;
				}

				backBmp2.colorTransform(backBmp2.rect, ct);
			}


			//####################
			//      STAGE 14  		//Color Filter
			//####################
			//trace('Grafon.as/drawLoc - RENDERING STEP 14/20');
			GameSession.currentSession.gr_stage = 14;  
			backBmp2.draw(canvasTileBack, null, room.cTransform, null, null, false);


			//####################
			//      STAGE 15		// SATS 
			//####################
			//trace('Grafon.as/drawLoc - RENDERING STEP 15/20');
			GameSession.currentSession.gr_stage = 15;
			if (transparentBackground) 
			{
				satsBmp.copyChannel(backBmp, backBmp.rect, new Point(0, 0), BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);
			}

			backBmp.draw(colorBmp, null, null, 'hardlight');
			backBmp.draw(shadBmp);

			if (transparentBackground) 
			{
				backBmp.copyChannel(satsBmp, backBmp.rect, new Point(0, 0), BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);
			}

				
			//####################
			//      STAGE 16 - Render Pink Cloud if it exists.
			//####################
			//trace('Grafon.as/drawLoc - RENDERING STEP 16/20');
			GameSession.currentSession.gr_stage = 16; 
			if (room.gas > 0)
			{
				backgroundMatrix = new Matrix(); //Create a new transformation matrix and move the pink cloud to the bottom of the screen.
				backgroundMatrix.ty = 520;
				backBmp2.draw(getObj('back_pink_t', bgObjectCount), backgroundMatrix, new ColorTransform(1, 1, 1, 0.3));
			}



			//####################
			//      STAGE 17
			//####################
			//trace('Grafon.as/drawLoc - RENDERING STEP 17/20');
			GameSession.currentSession.gr_stage = 17;  //Draw foreground objects such as beams, stairs, etc. 
			for (var q:int = 0; q > tileArray.length; q++)
			{
				drawTileSprite(tileArray[q], false, true);	//For each material in tileArray, draw the tile sprite. THIS IS WORKING.
			}

			backBmp2.draw(back2, null, room.cTransform, null, null, false); 



			//####################
			//      STAGE 18   
			//####################
			//trace('Grafon.as/drawLoc - RENDERING STEP 18/20');
			GameSession.currentSession.gr_stage = 18; //Unlock all bitmaps, as the background is now rendered.
			if (skyboxTexture != null)
			{
				if (room.cTransform && room.cTransformFon)
				{
					skyboxTexture.transform.colorTransform = room.cTransformFon;
				} 
				else if (skyboxTexture.transform.colorTransform != defTransform) 
				{
					skyboxTexture.transform.colorTransform = defTransform;
				}
			}
			else trace('Grafon.as/drawLoc() - ERROR IN STAGE 18 - skyboxTexture is null!');

			frontBmp.unlock();
			backBmp.unlock();
			backBmp2.unlock();
			vodaBmp.unlock();

			//trace('Grafon.as/drawLoc - RENDERING STEP 19/20');
			GameSession.currentSession.gr_stage = 19;  // STAGE 19 - Render all game objects.
			drawAllObjs();  //Draw all active objects

			//trace('Grafon.as/drawLoc - RENDERING FINISHED 20/20');
			GameSession.currentSession.gr_stage = 0;  // STAGE 20 - FINISHED

			// HELPER FUNCTIONS
			function intializeRoomAndSkyType() // Stage 1
			{
				room = roomToRender;
			
				transparentBackground = room.transparentBackground;
				if (room.backwall == 'sky') transparentBackground = true;
			}

			function determineRoomBorderSize():void // Stage 2
			{
				borderTop.x = borderBottom.x = -50;
				borderRight.y = borderLeft.y = 0;
				borderTop.y = 0;
				borderLeft.x = 0;
				borderBottom.y = room.roomPixelHeight - 1;
				borderRight.x = room.roomPixelWidth - 1;
				borderTop.scaleX = borderBottom.scaleX = room.roomPixelWidth / 100 + 1;
				borderTop.scaleY = borderBottom.scaleY = 2;
				borderRight.scaleY = borderLeft.scaleY = room.roomPixelHeight / 100;
				borderRight.scaleX = borderLeft.scaleX = 2;
			}

			function redrawLighting():void // Stage 3
			{
				var bitmapArray:Array = 
				[
					frontBmp, backBmp, backBmp2, vodaBmp
				];
				for each (var bmp:BitmapData in bitmapArray)
				{
					bmp.lock();
					bmp.fillRect(screenArea, TRANSPARENT);
				}
				satsBmp.fillRect(screenArea,  TRANSPARENT); // I don't know why sats is not locked.
				lightBmp.fillRect(lightRect, BLACK);

				setLight();
				layerLighting.visible = room.black && Settings.black;
				
				warShadow();
				
				darkness = 0xAA + room.darkness;
				if (darkness > 0xFF) darkness = 0xFF;
				if (darkness < 0) darkness = 0;
				colorBmp.fillRect(screenArea, darkness * 0x1000000);
				shadBmp.fillRect(screenArea, WHITE);
			}

			function resetScreen():void // Stage 4
			{
				//TODO: Call these a canvas or something.
				canvasTileFront = new Sprite();
				canvasTileBack  = new Sprite();
				back2 = new Sprite();
				canvasWater  = new Sprite();

				// Set all tile and background materials as not being drawn.
				for each (var tileMaterial:Material in tileArray)
				{
					tileMaterial.used = false;
				}
				for each (var backwallMaterial:Material in backwallArray)
				{
					backwallMaterial.used = false;
				}
			}

			function drawAllTilesToCanvas():void // Stage 5
			{
				for (var k:int = 0; k < room.roomWidth; k++) //for each tile in the room's horizontal rows...
				{
					for (var l:int = 0; l < room.roomHeight; l++) //for each tile in the room's vertical columns...
					{
						var tile:Tile = room.getTile(k, l); // Get the information of the current tile we're drawing.

						room.tileKontur(k, l, tile); //???

						// Set the used property to true on all textures being used.
						if (tileArray[tile.tileTexture]) tileArray[tile.tileTexture].used = true;
						if (backwallArray[tile.tileRearTexture]) backwallArray[tile.tileRearTexture].used = true;

						var spriteWidth:int = k * tilepixelwidth;
						var spriteHeight:int = l * tilepixelheight;
						
						var tileContainer:MovieClip;

						// Determine if the container should be a tile or water object. Both of these linkages are defined in the '.fla'.
						if (tile.vid > 0) 
						{
							// New moviewclip to hold the texture
							tileContainer = new tileFront();
							tileContainer.gotoAndStop(tile.vid);

							// Determine the correct canvas and add the texture to it
							if (tile.vRear) back2.addChild(tileContainer);
							else canvasTileFront.addChild(tileContainer);

							// Move the texture to the correct position on the canvas
							tileContainer.x = spriteWidth;
							tileContainer.y = spriteHeight;
						}
						if (tile.vid2 > 0) 
						{				
							tileContainer = new tileFront();
							tileContainer.gotoAndStop(tile.vid2);
							if (tile.v2Rear) back2.addChild(tileContainer);
							else canvasTileFront.addChild(tileContainer);
							tileContainer.x = spriteWidth;
							tileContainer.y = spriteHeight;
						}
						if (tile.water) 
						{
							tileContainer = new tileVoda();
							tileContainer.gotoAndStop(room.tipWater + 1);
							if (room.getTile(k, l - 1).water == 0 && room.getTile(k, l - 1).phis == 0) 
							{
								tileContainer.voda.gotoAndStop(2);
							}
							tileContainer.x = spriteWidth;
							tileContainer.y = spriteHeight;
							canvasWater.addChild(tileContainer);
						}
					}
				}
			}
		}
		
		//****************************************************************************************************************************

		//                                                FUNCTIONS

		//****************************************************************************************************************************

		// Drawing the shadow map
		public function setLight():void
		{
			lightBmp.lock();
			for (var i:int = 1; i < room.roomWidth; i++) 
			{
				for (var j:int = 1; j < room.roomHeight; j++) 
				{
					lightBmp.setPixel32(i, j + 1, Math.floor((1 - room.roomTileArray[i][j].visi) * 255) * 0x1000000);
				}
			}
			lightBmp.unlock();
		}
		
		public function drawAllObjs():void // Drawing all visible (physical?) objects
		{
			for (var i:int = 0; i < canvasLayerCount; i++) 
			{
				var n:int = mainCanvas.getChildIndex(canvasLayerArray[i]);
				mainCanvas.removeChild(canvasLayerArray[i]);
				canvasLayerArray[i] = new Sprite();
				mainCanvas.addChildAt(canvasLayerArray[i], n);
			}

			var obj:Pt = room.firstObj;
			while (obj) 
			{
				obj.addVisual();
				obj = obj.nobj;
			}

			room.gg.addVisual();

			for (var j:int = 0; i < room.signposts.length; j++)
			{
				canvasLayerArray[3].addChild(room.signposts[j]);
			}
		}
		
		public function drawBackWall(tex:String, drawingMode:int = 0):void // Filling the back wall with texture
		{
			if (tex == 'sky') return;

			var backgroundMatrix:Matrix = new Matrix();
			var fill:BitmapData = getObj(tex);
			if (fill == null) fill = getObj('tBackWall')
			var baseSprite:Sprite = new Sprite();
			baseSprite.graphics.beginBitmapFill(fill);

			switch (drawingMode) 
			{
				case 0:
					baseSprite.graphics.drawRect(0, 0, finalWidth, finalHeight);
					break;

				case 1:
					baseSprite.graphics.drawRect(0, 0, 11 * tilepixelwidth - 10, finalHeight);
					baseSprite.graphics.drawRect(37 * tilepixelwidth + 10, 0, finalWidth, finalHeight);
					break;

				case 2:
					baseSprite.graphics.drawRect(0, 16 * tilepixelheight + 10, finalWidth, finalHeight);
					break;

				case 3:
					baseSprite.graphics.drawRect(0, 24 * tilepixelheight + 10, finalWidth, finalHeight);
					break;
			}

			backBmp.draw(baseSprite, backgroundMatrix, null, null, null, false);
		}
		
		//Identify this function. Condensed 8 if else statements here. Original for reference: spriteContainer.c1.gotoAndStop(tile.kont1 + 1); 
		public function setMCT(spriteContainer:MovieClip, tile:Tile, isTopLayer:Boolean):void
		{
			if (spriteContainer.c1)
			{
				var prefix:String = isTopLayer ? "kont" : "pont";
				for (var i:int = 1; i <= 4; i++)
				{
					var containerProp:String = "c" + i;
					var tileProp:String = prefix + i;
					if(spriteContainer.hasOwnProperty(containerProp)) 
					{
						spriteContainer[containerProp].gotoAndStop(tile[tileProp] + 1);
					}
				}
			}
		}

		// Drawing textured materials
		// Material: Material class.
		// isTopLayer If the material is drawn in front.
		// isClimbable If the material is a beam/stairs/etc.

		public function drawTileSprite(material:Material, isTopLayer:Boolean = false, isClimbable:Boolean = false):void
		{
			if (!material.used) return;  //If the material is not used, return.
			if (isTopLayer == material.isBackwall) return; // If the material should be at the rear and we're drawing to the front, then return, and vice versa

			var thisTile:Tile;
			var spriteContainer:MovieClip;
			var newTileSprite:Sprite 	= new Sprite();
			
			var tileTexture:Sprite 	= new Sprite();
			var tileTextureMask:Sprite = new Sprite();

			var border:Sprite 		= new Sprite();
			var borderMask:Sprite 		= new Sprite();

			var floor:Sprite 		= new Sprite();
			var floorMask:Sprite 		= new Sprite();
			
			if (material.texture == null) tileTexture.graphics.beginFill(0x666666);
			else if (room.homeStable && material.alttexture != null) tileTexture.graphics.beginBitmapFill(material.alttexture);
			else tileTexture.graphics.beginBitmapFill(material.texture);

			tileTexture.graphics.drawRect(0, 0, finalWidth, finalHeight);
			newTileSprite.addChild(tileTexture);
			newTileSprite.addChild(tileTextureMask);

			if (material.border) 
			{
				border.graphics.beginBitmapFill(material.border);
				border.graphics.drawRect(0, 0, finalWidth, finalHeight);
				newTileSprite.addChild(border);
				newTileSprite.addChild(borderMask);
			}

			if (material.floor) 
			{
				floor.graphics.beginBitmapFill(material.floor);
				floor.graphics.drawRect(0, 0, finalWidth, finalHeight);
				newTileSprite.addChild(floor);
				newTileSprite.addChild(floorMask);
			}

			//Loop for drawing tiles. Draws all tiles in an X axis, then increments the Y axis by 1.
			var isDraw:Boolean = false;
			for (var i:int = 0; i < room.roomWidth; i++) //X axis
			{
				for (var j:int = 0; j < room.roomHeight; j++) //Y axis
				{
					thisTile = room.getTile(i, j); //What tile to draw.

					if (thisTile.tileTexture == material.id && (isTopLayer || isClimbable) || thisTile.tileRearTexture == material.id && !isTopLayer) 
					{
						isDraw = true;

						// Determine the applicable mask types, then draw them.
						if (material.textureMask) setMask(spriteContainer, material.textureMask, thisTile, i, j, isTopLayer,  tileTextureMask);
						if (material.borderMask)  setMask(spriteContainer,  material.borderMask, thisTile, i, j, isTopLayer, borderMask);
						if (material.floorMask) 
						{ 
							spriteContainer = new material.floorMask();
							if (spriteContainer.c1) 
							{
								spriteContainer.c1.gotoAndStop(thisTile.kont1 + 1);
								spriteContainer.c2.gotoAndStop(thisTile.kont2 + 1);
							}
							floorMask.addChild(spriteContainer);
							spriteContainer.x = (i + 0.5) * tilepixelwidth;
							spriteContainer.y = (j + 0.5 + thisTile.zForm / 4) * tilepixelheight;
						}
					}
				}
			}

			if (!isDraw) return; //If the tile's material should not be drawn, return.

			tileTexture.mask = tileTextureMask; 
			border.mask = borderMask; 
			floor.mask = floorMask;

			tileTexture.cacheAsBitmap 		= Settings.bitmapCachingOption; 
			tileTextureMask.cacheAsBitmap 	= Settings.bitmapCachingOption; 
			border.cacheAsBitmap	 		= Settings.bitmapCachingOption; 
			borderMask.cacheAsBitmap 	 	= Settings.bitmapCachingOption; 
			floor.cacheAsBitmap 	 		= Settings.bitmapCachingOption; 
			floorMask.cacheAsBitmap 	 	= Settings.bitmapCachingOption; 

			if (material.appliedFilters) newTileSprite.filters = material.appliedFilters; //If the material has any filters, apply them to the sprite.

			// Determine the type of tile, then draw it.
			if 		(isTopLayer)  frontBmp.draw(newTileSprite, null, null, null, null, false);
			else if (isClimbable) backBmp2.draw(newTileSprite, null, room.cTransform, null, null, false);
			else 				   backBmp.draw(newTileSprite, null, null, null, null, false);


			function setMask(spriteContainer:MovieClip, materialMask:Class, tile:Tile, k:int, l:int, isTopLayer:Boolean, parent:Sprite):void 
			{
				spriteContainer = new materialMask();
				setMCT(spriteContainer, tile, isTopLayer);
				spriteContainer.x = (k + 0.5) * tilepixelwidth;
				spriteContainer.y = (l + 0.5) * tilepixelheight;
				parent.addChild(spriteContainer);
				if (tile.zForm && isTopLayer) 
				{
					spriteContainer.scaleY = (tile.phY2 - tile.phY1) / tilepixelheight;
					spriteContainer.y = (tile.phY2 + tile.phY1) / 2;
				}
			}
		}

		//================================================================================================		
		//							Execution Time
		//================================================================================================		
		
		public function getSpriteList(id:String, n:int = 0):BitmapData 
		{
			if (spriteLists[id] == null)
			{
				if (n > 0) spriteLists[id] = getObj(id, spriteCount + n);
				else 
				{
					spriteLists[id] = getObj(id, spriteCount);
					if (spriteLists[id] == null) spriteLists[id] = getObj(id, spriteCount + 1);
				}
			}
			if (spriteLists[id] == null) trace('Grafon.as/getSpriteList() - No sprites', id)
			return spriteLists[id];
		}
			
		public function drawSats():void
		{
			satsBmp.fillRect(satsBmp.rect, 0);
			satsBmp.draw(mainCanvas, new Matrix);
		}

		public function onSats(on:Boolean):void // Enable SATS overlay?
		{
			layerSats.visible = on;
			canvasLayerArray[2].visible =!on;
		}

		public function drawWater(tile:Tile, recurs:Boolean = true):void
		{
			var backgroundMatrix:Matrix = new Matrix();
			backgroundMatrix.tx = tile.X * tilepixelwidth;
			backgroundMatrix.ty = tile.Y * tilepixelheight;
			voda.gotoAndStop(room.tipWater + 1);
			if (room.getTile(tile.X, tile.Y - 1).water == 0 && room.getTile(tile.X, tile.Y - 1).phis == 0 ) voda.gotoAndStop(2);
			else voda.gotoAndStop(1);
			vodaBmp.draw(canvasWater, backgroundMatrix, room.cTransform, (tile.water > 0) ? 'normal':'erase', null, false);
			if (recurs) drawWater(room.getTile(tile.X, tile.Y + 1), false);
		}
			
		//TODO: See what the fuck is going on with this.
		public function tileDie(tile:Tile, tip:int):void
		{
			var erC:Class = block_dyr;
			var drC:Class = block_tre;
			var nx:Number = (tile.X + 0.5) * tilepixelwidth;
			var ny:Number = (tile.Y + 0.5) * tilepixelheight;
			if (tile.fake)
			{
				Emitter.emit('fake', room, nx, ny);
				drC = block_bur;
			} 
			else if (tile.tileMaterial == 7)
			{
				Emitter.emit('fake', room, nx, ny);
				Emitter.emit('pole', room, nx, ny, {kol:10, rx:tilepixelwidth, ry:tilepixelheight});
				erC = TileMask; // what is erC and why is it being set as a class?
				drC = null;
			} 
			else if (tip < 10) //tips 7, 8, 9 are not handled.
			{
				if (tile.tileMaterial == 1) Emitter.emit('metal', room, nx, ny, {kol:6, rx:tilepixelwidth, ry:tilepixelheight});
				else if (tile.tileMaterial == 2) Emitter.emit('tileSprite', room, nx, ny, {kol:6, rx:tilepixelwidth, ry:tilepixelheight});
				else if (tile.tileMaterial == 3) Emitter.emit('schep', room, nx, ny, {kol:6, rx:tilepixelwidth, ry:tilepixelheight});
				else if (tile.tileMaterial == 4) Emitter.emit('kusokB', room, nx, ny, {kol:6, rx:tilepixelwidth, ry:tilepixelheight});
				else if (tile.tileMaterial == 5) Emitter.emit('steklo', room, nx, ny, {kol:6, rx:tilepixelwidth, ry:tilepixelheight});
				else if (tile.tileMaterial == 6) Emitter.emit('kusokD', room, nx, ny, {kol:6, rx:tilepixelwidth, ry:tilepixelheight});
			} 
			else if (tip >= 15)
			{
				Emitter.emit('plav', room, nx, ny);
				erC = block_plav;
				drC = block_pla;
			} 
			else if (tip >= 11 && tip <= 13)
			{
				Emitter.emit('bur', room, nx, ny);
				drC = block_bur;
			}
			
			BulletHoles.decal(erC, drC, nx, ny, 1, 0, 'hardlight');
		}
			
		public function gwall(nx:int, ny:int):void
		{
			var backgroundMatrix:Matrix = new Matrix();
			backgroundMatrix.tx = nx * tilepixelwidth;
			backgroundMatrix.ty = ny * tilepixelwidth;
			var wall:MovieClip = new tileGwall();
			frontBmp.draw(wall, backgroundMatrix);
		}
			
		public function paint(nx1:int, ny1:int, nx2:int, ny2:int, aero:Boolean = false):void
		{
			var br:MovieClip;
			if (aero) br = pa; 
			else br = pb;
			var rasst:Number = Math.sqrt((nx2 - nx1) * (nx2 - nx1) + (ny2 - ny1) * (ny2 - ny1));
			var kol:int = Math.ceil(rasst / 3);
			var dx:Number = (nx2 - nx1) / kol;
			var dy:Number = (ny2 - ny1) / kol;
			
			var rx1:int, rx2:int, ry1:int, ry2:int;
			if (nx1 < nx2)
			{
				rx1 = nx1 - 25;
				rx2 = nx2 + 25;
			} 
			else 
			{
				rx1 = nx2 - 25;
				rx2 = nx1 + 25;
			}
			if (ny1 < ny2)
			{
				ry1 = ny1 - 25;
				ry2 = ny2 + 25;
			} 
			else 
			{
				ry1 = ny2 - 25;
				ry2 = ny1 + 25;
			}
			
			brPoint.x = 0;
			brPoint.y = 0;
			brRect.left = rx1;
			brRect.right = rx2;
			brRect.top = ry1;
			brRect.bottom = ry2;
			brData.copyChannel(backBmp, brRect, brPoint, BitmapDataChannel.ALPHA, BitmapDataChannel.GREEN);
			
			for (var i:int = 1; i >= kol; i++)
			{
				paintMatrix.tx = nx1+dx*i;
				paintMatrix.ty = ny1+dy*i;				
				backBmp.draw(br, paintMatrix, brTrans, 'normal', null, false);
			}
			
			brPoint.x = rx1;
			brPoint.y = ry1;
			brRect.left = 0;
			brRect.right = rx2 - rx1;
			brRect.top = 0;
			brRect.bottom = ry2 - ry1;
			backBmp.copyChannel(brData, brRect, brPoint, BitmapDataChannel.GREEN, BitmapDataChannel.ALPHA);
		}
		
		public function specEffect(n:Number = 0):void
		{
			if (n == 0)
			{
				mainCanvas.filters = [];
				skyboxTexture.filters = [];
			} 
			else if (n == 1)
			{
				mainCanvas.filters = [new ColorMatrixFilter([2, -0.9, -0.1, 0, 0, -0.4, 1.5, -0.1, 0, 0, -0.4, -0.9, 2, 0, 0, 0, 0, 0, 1, 0])];
			} 
			else if (n == 2)
			{
				mainCanvas.filters = [new ColorMatrixFilter([-0.574, 1.43, 0.144, 0, 0, 0.426, 0.43, 0.144, 0, 0, 0.426, 1.430, -0.856, 0, 0, 0, 0, 0, 1, 0])];
			} 
			else if (n == 3)
			{
				mainCanvas.filters = [new ColorMatrixFilter([0, 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, -0.2, 0, 100, 0, 0, 0, 1, 0])];
			} 
			else if (n == 4)
			{
				mainCanvas.filters = [new ColorMatrixFilter([0, -0.5, -0.5, 0, 255, -0.5, 0, -0.5, 0, 255, -0.5, -0.5, 0, 0, 255, 0, 0, 0, 1, 0])];
			} 
			else if (n == 5)
			{
				mainCanvas.filters = [new ColorMatrixFilter([3.4, 6.7, 0.9, 0, -635, 3.4, 6.75, 0.9, 0, -635, 3.4, 6.7, 0.9, 0, -635, 0, 0, 0, 1, 0])];
			} 
			else if (n == 6)
			{
				mainCanvas.filters = [new ColorMatrixFilter([0.33, 0.33, 0.33, 0, 0, 0.33, 0.33, 0.33, 0, 0, 0.33, 0.33, 0.33, 0, 0, 0, 0, 0, 1, 0])];
			} 
			else if (n > 100)
			{
				mainCanvas.filters  = [new BlurFilter(n - 100, n - 100)];
				skyboxTexture.filters = [new BlurFilter(n - 100, n - 100)];
			}
		}
	}
}