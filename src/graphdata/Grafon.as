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

	import fl.motion.Color;

	import locdata.*;

	import components.Settings;
	import components.XmlBook;
	import systems.TileFilter;

	import stubs.visBlack;
	import stubs.tileFront;
	import stubs.tileVoda
	import stubs.tileGwall;

	public class Grafon 
	{
		
		public var room:Room;	//current Room.
		
		public var mainCanvas:Sprite;			// Sprite that all 6 layers are drawn onto (Screenspace?)
		public var layerBackground_1:Sprite;	// Layer 1
		public var layerBackground_2:Sprite;	// Layer 2
		public var layerWater:Sprite;			// Layer 3
		public var visFront:Sprite;				// Layer 4
		public var layerLighting:Sprite;		// Layer 5
		public var layerSats:Sprite;			// Layer 6
		

		public var canvasLayerArray:Array;
		public var skyboxLayer:MovieClip;
		
		public var resX:int;
		public var resY:int;

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




		//Export this to some kind of user settings. This might save on memory usage which is a premium for flash.

		public var dsFilter:DropShadowFilter;				// Adds a drop shadow to objects. (What objects?)
		public var infraTransform:ColorTransform;			// Fog of war stuff.
		public var defTransform:ColorTransform;				// Fog of war stuff.
		
		public var pa:MovieClip;							// Something for spraypainting.
		public var pb:MovieClip;							// Something for spraypainting.
		public var brTrans:ColorTransform;					// Something for spraypainting.
		public var brColor:Color;							// Something for spraypainting.
		public var brData:BitmapData;						// Something for spraypainting.
		public var brPoint:Point;							// Something for spraypainting.
		public var brRect:Rectangle;						// Something for spraypainting.
		public var paintMatrix:Matrix;						// Something for spraypainting.


		
		
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

		public var waterMovieClip:MovieClip;  						// Water tile MovieClip from pfe.fla (Why is this defined here? Check if I did that.)


		public function Grafon(nvis:Sprite)
		{
			
			trace('Grafon.as/Grafon() - Grafon initializing...');
			mapTileWidth 	= 48; 
			mapTileHeight 	= 25;

			trace('Grafon.as/Grafon() - Initializing TileFilter array.');
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
			frontBmp 	= new BitmapData(screenResX, screenResY, true, 0x0)
			frontBitmap =  new Bitmap(frontBmp);
			visFront.addChild(frontBitmap);
			
			backBmp		= new BitmapData(screenResX, screenResY, true, 0x0)
			backBitmap 	=  new Bitmap(backBmp);
			layerBackground_1.addChild(backBitmap);
			
			backBmp2 	= new BitmapData(screenResX, screenResY, true, 0x0)
			backBitmap2 =  new Bitmap(backBmp2);
			layerBackground_2.addChild(backBitmap2);

			vodaBmp 	= new BitmapData(screenResX, screenResY, true, 0x0)
			vodaBitmap  =  new Bitmap(vodaBmp);
			layerWater.addChild(vodaBitmap);
			
			satsBmp 	= new BitmapData(screenResX, screenResY, true, 0);
			satsBitmap  =  new Bitmap(satsBmp, 'auto', true);
			layerSats.addChild(satsBitmap);
			
			colorBmp 	= new BitmapData(screenResX, screenResY, true, 0);
			shadBmp 	= new BitmapData(screenResX, screenResY, true, 0);
			
			lightBmp 	= new BitmapData(lightX, lightY, true, 0xFF000000);
			lightBitmap =  new Bitmap(lightBmp, 'auto', true);
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

			//loader array setup
			grLoaderArray = [];


			
			//Resource URL list setup.
			trace('Grafon.as/Grafon() - Creating resource resource loader array...');
			for (var j:int = 0; j < resourceURLArray.length; j++)
			{
				//Populates the array with texture URLs.
				var resourceURL:String = resourceURLArray[j];

				//Instantiates a graphics loader for each URL in the array to load it's contents.
				grLoaderArray[j] = new GrLoader(j, resourceURL, this);
			}


			trace('Grafon.as/Grafon() - Adding mouse cursor...');
			createCursors();
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
			//tile and backwall arrays
			tileArray 		= [];	//Tiles and climbables
			backwallArray   = []; 	//Backwalls

			var tileArrayCount:int = 0;
			var backwallArrayCount:int = 0;

			trace('Grafon.as/Grafon() - Setting up materials...');

			for each (var newMat:XML in XmlBook.getXML("materials").mat) //for each <mat> item in AllData...
			{
				if (newMat.@vid.length() == 0)
				{
					if (newMat.@ed == '2') 
					{
						backwallArray[newMat.@id] = new Material(newMat);
						backwallArrayCount++;
					}
					else 
					{
						tileArray[newMat.@id] = new Material(newMat);
						tileArrayCount++;
					}
				}
			}
	
			trace('Grafon.as/Grafon() - Setup complete. tileArray count: "' + tileArrayCount + '." backwallArray count: "' + backwallArrayCount + '."');
			trace('Grafon.as/Grafon() - Setting resourcesLoaded to true.');
			resourcesLoaded = true;
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
		
		public function createCursors():void
		{
			createCursor(visCurArrow, 	'arrow');
			createCursor(visCurTarget, 	'target', 13, 13);
			createCursor(visCurTarget1, 'combat', 13, 13);
			createCursor(visCurTarget2, 'action', 13, 13);
		}
		
		public function createCursor(vcur:Class, objectName:String, nx:int = 0, ny:int = 0):void
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
		
		//================================================================================================		
		//							Initial Room Drawing
		//================================================================================================		
		
		public function getObj(textureName:String, loaderID:int = 0):* 
		{
			return this.grLoaderArray[loaderID].resource.getObj(textureName);
			// When this function is called, it takes a texture name and grLoader ID.
			// It then looks through the current Grafon's grLoaderArray for [loaderID].
			// In [LoaderID] it will then try run the getObj function contained inside it's 'resource' property.
			// The grLoader.resource will then (hopefully?) return the result.
		}
		
		// Draw the skybox texture.
		public function drawSkybox(skybox:MovieClip, textureID:String):void
		{
			if (textureID == '' || textureID == null) textureID = 'skyboxDefault';
			if (skyboxLayer && skybox.contains(skyboxLayer)) skybox.removeChild(skyboxLayer);
			
			
			skyboxLayer = getObj(textureID);						//Set the background to the specified texture.
			if (skyboxLayer) skybox.addChild(skyboxLayer); 	//If the background exists, add it to the background sprite.
		}
		
		public function setSkyboxSize(nx:Number, ny:Number):void
		{
			if (skyboxLayer)
			{
				if (nx>screenResX && ny>screenResY)
				{
					skyboxLayer.x = mainCanvas.x;
					skyboxLayer.y = mainCanvas.y;
					skyboxLayer.width = screenResX;
					skyboxLayer.height = screenResY;
				} 
				else 
				{
					var koef:Number = skyboxLayer.width/skyboxLayer.height;
					skyboxLayer.x = skyboxLayer.y = 0;
					if (nx >= ny*koef)
					{
						skyboxLayer.width = nx;
						skyboxLayer.height = nx/koef;
					} 
					else 
					{
						skyboxLayer.height = ny;
						skyboxLayer.width  = ny * koef;
					}
				}
			}
		}
		
		//Fog of war
		public function warShadow():void
		{
			if (World.world.pers.infravis)
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

		public function drawLoc(currentLocation:Room):void 
		{

			//####################
			//      STAGE 1   	
			//####################
			try
			{
				World.world.gr_stage = 1; 

				room = currentLocation;
				room.grafon = this;

				resX = room.roomWidth * tilepixelwidth;
				resY = room.roomHeight * tilepixelheight;
				
				var transparentBackground:Boolean = room.transparentBackground;
				if (room.backwall == 'sky') transparentBackground = true;	//If the decorative background layer is sky, set traansparentBackground to true.
			}
			catch (err:Error) 
			{
				trace('Grafon.as/drawLoc() - ERROR during stage 1. Error: "' + err.message + '".');
				World.world.showError(err)
			}
			


			//####################
			//      STAGE 2  
			//####################
			try
			{
				World.world.gr_stage = 2;

				// Borders
				borderTop.x = borderBottom.x = -50;
				borderRight.y = borderLeft.y = 0;
				borderTop.y = 0;
				borderLeft.x = 0;
				borderBottom.y = room.roomPixelHeight - 1;
				borderRight.x = room.roomPixelWidth - 1;
				borderTop.scaleX = borderBottom.scaleX = room.roomPixelWidth / 100+1;
				borderTop.scaleY = borderBottom.scaleY = 2;
				borderRight.scaleY = borderLeft.scaleY = room.roomPixelHeight / 100;
				borderRight.scaleX = borderLeft.scaleX = 2;
			}
			catch (err:Error) 
			{
				trace('Grafon.as/drawLoc() - ERROR during stage 2. Error: "' + err.message + '".');
				World.world.showError(err)
			}


			//####################
			//      STAGE 3   
			//####################
			try
			{
				World.world.gr_stage = 3;
				frontBmp.lock();
				backBmp.lock();
				backBmp2.lock();
				vodaBmp.lock();
				
				frontBmp.fillRect(screenArea, 0); 
				backBmp.fillRect(screenArea, 0);
				backBmp2.fillRect(screenArea, 0);
				vodaBmp.fillRect(screenArea, 0);
				satsBmp.fillRect(screenArea, 0);
				
				lightBmp.fillRect(lightRect, 0xFF000000); //White
				setLight();
				layerLighting.visible = room.black && Settings.black;
				warShadow();
				
				var darkness:int = 0xAA + room.darkness;
				if (darkness > 0xFF) darkness = 0xFF;
				if (darkness < 0) darkness = 0;
				colorBmp.fillRect(screenArea, darkness*0x1000000); //Black
				shadBmp.fillRect(screenArea, 0xFFFFFFFF); 		   //White
			}
			catch (err:Error) 
			{
				trace('Grafon.as/drawLoc() - ERROR during stage 3. Error: "' + err.message + '".');
				World.world.showError(err)
			}

				
			//####################
			//      STAGE 4   
			//####################
			try
			{
				World.world.gr_stage = 4; 

				var front:Sprite = new Sprite();	
				var back:Sprite = new Sprite();	
				var back2:Sprite = new Sprite();	
				var waterMovieClip:Sprite = new Sprite();	
				

				var mat:Material;

				for (var i:int = 0; i < tileArray.length; i++)
				{
					tileArray[i].used = false;
				}

				for (var j:int = 0; j < backwallArray.length; j++)
				{
					backwallArray[j].used = false;
				}
			}
			catch (err:Error) 
			{
				trace('Grafon.as/drawLoc() - ERROR during stage 4. Error: "' + err.message + '".');
				World.world.showError(err)
			}
				
				
			//####################
			//      STAGE 5   
			//####################
			try
			{
				World.world.gr_stage = 5;  // Creates a 2D grid, and iterates through it to draw the tiles(?)

				var tile:Tile; 					//Define a tile as an object to hold the current tile's properties in the grid.
				var tileSprite:MovieClip; 		//Define a tileSprite as an MovieClip to hold the current tile's sprite.

				for (var k:int = 0; k < room.roomWidth; k++) //for each tile in theroom's horizontal rows...
				{
					for (var l:int = 0; l < room.roomHeight; l++) //for each tile in the room's vertical columns...
					{

						tile = room.getTile(k, l); //Set the tile to modify as the current tile in the grid.

						
						room.tileKontur(k, l, tile);

						if (tileArray[tile.tileTexture]) tileArray[tile.tileTexture].used = true;
						if (backwallArray[tile.tileRearTexture]) backwallArray[tile.tileRearTexture].used = true;


						if (tile.vid > 0 || tile.vid2 > 0 || tile.water)
						{
							var spriteWidth:int = k * tilepixelwidth;
							var spriteHeight:int = l * tilepixelheight;

							if (tile.vid > 0) 
							{				
								tileSprite = new tileFront();
								tileSprite.gotoAndStop(tile.vid);
								if (tile.vRear) back2.addChild(tileSprite);
								else front.addChild(tileSprite);
								tileSprite.x = spriteWidth;
								tileSprite.y = spriteHeight;
							}
							if (tile.vid2 > 0) 
							{				
								tileSprite = new tileFront();
								tileSprite.gotoAndStop(tile.vid2);
								if (tile.v2Rear) back2.addChild(tileSprite);
								else front.addChild(tileSprite);
								tileSprite.x = spriteWidth;
								tileSprite.y = spriteHeight;
							}
							if (tile.water) 
							{				
								tileSprite = new tileVoda();
								tileSprite.gotoAndStop(room.tipWater+1);
								if (room.getTile(k, l - 1).water == 0 && room.getTile(k, l - 1).phis == 0) tileSprite.waterMovieClip.gotoAndStop(2);
								tileSprite.x = spriteWidth;
								tileSprite.y = spriteHeight;
								waterMovieClip.addChild(tileSprite);
							}
						}
					}
				}
			}
			catch (err:Error) 
			{
				trace('Grafon.as/drawLoc() - ERROR during stage 5. Error: "' + err.message + '".');
				World.world.showError(err)
			}

				
			//####################
			//      STAGE 6   
			//####################
			try
			{
				World.world.gr_stage = 6;
				vodaBmp.draw(waterMovieClip, null, null, null, null, false);
				frontBmp.draw(front, null, null, null, null, false);
			}
			catch (err:Error) 
			{
				trace('Grafon.as/drawLoc() - ERROR during stage 6. Error: "' + err.message + '".');
				World.world.showError(err)
			}
				
				
			//####################
			//      STAGE 7  		// TILE LAYER
			//####################
			try
			{
				World.world.gr_stage = 7;
				drawBackWall(currentLocation.backwall, currentLocation.backform);
			}
			catch (err:Error) 
			{
				trace('Grafon.as/drawLoc() - ERROR during stage 7. Error: "' + err.message + '".');
				World.world.showError(err)
			}
					

			//####################
			//      STAGE 8  		// BACKWALL LAYER
			//####################
			try
			{
				World.world.gr_stage = 8;  //Draw Background items in backwallArray.
				for (var m:int = 0; m < backwallArray.length; m++)
				{
					try 
					{
						drawTileSprite(backwallArray[m], false, false);
					} 
					catch (err)
					{
						World.world.showError(err, 'Error, Stage 8. Back Layer drawing matterial: ' + backwallArray[m].id);
					}
				}
			}
			catch (err:Error) 
			{
				trace('Grafon.as/drawLoc() - ERROR during stage 8. Error: "' + err.message + '".');
				World.world.showError(err)
			}


			//####################
			//      STAGE 9   		// CLIMBABLE LAYER
			//####################
			try
			{
				World.world.gr_stage = 9;  
				for (var n:int = 0; n < backwallArray.length; n++)
				{
					try 
					{
						drawTileSprite(backwallArray[n], true, false);
					} 
					catch (err)
					{
						World.world.showError(err, 'Error, Stage 9. Front Layer drawing matterial: ' + backwallArray[n].id);
					}
				}
			}
			catch (err:Error) 
			{
				trace('Grafon.as/drawLoc() - ERROR during stage 9. Error: "' + err.message + '".');
				World.world.showError(err)
			}


			//####################
			//      STAGE 10
			//####################
			try
			{
				World.world.gr_stage = 10; 
				satsBmp.copyChannel(backBmp, backBmp.rect, new Point(0, 0), BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);
				var darkness2:Number = 1 - (255 - darkness) /150;

				//background objects
				var ct:ColorTransform = new ColorTransform();
			}
			catch (err:Error) 
			{
				trace('Grafon.as/drawLoc() - ERROR during stage 10. Error: "' + err.message + '".');
				World.world.showError(err)
			}


			//####################
			//      STAGE 11  
			//####################
			try
			{
				World.world.gr_stage = 11; // Drawing background object sprites. 
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
			}
			catch (err:Error) 
			{
				trace('Grafon.as/drawLoc() - ERROR during stage 11. Error: "' + err.message + '".');
				World.world.showError(err)
			}


			//####################
			//      STAGE 12   - Apply Stage color transforms.
			//####################
			try
			{
				World.world.gr_stage = 12;    
				if (currentLocation.cTransform) //If the current room has a color transform, apply it to the front and water bitmaps.
				{
					frontBmp.colorTransform(frontBmp.rect, currentLocation.cTransform);
					vodaBmp.colorTransform(vodaBmp.rect, currentLocation.cTransform);
				}

				shadBmp.applyFilter(frontBmp, frontBmp.rect, new Point(0, 0), dsFilter);
			}
			catch (err:Error) 
			{
				trace('Grafon.as/drawLoc() - ERROR during stage 12. Error: "' + err.message + '".');
				World.world.showError(err)
			}


			//####################
			//      STAGE 13  - //Lighting
			//####################
			try
			{
				World.world.gr_stage = 13; // Darkening the background
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
			}
			catch (err:Error) 
			{
				trace('Grafon.as/drawLoc() - ERROR during stage 13. Error: "' + err.message + '".');
				World.world.showError(err)
			}


			//####################
			//      STAGE 14  		//Color Filter
			//####################
			try
			{
				World.world.gr_stage = 14;  
				backBmp2.draw(back, null, currentLocation.cTransform, null, null, false);
			}
			catch (err:Error) 
			{
				trace('Grafon.as/drawLoc() - ERROR during stage 14. Error: "' + err.message + '".');
				World.world.showError(err)
			}


			//####################
			//      STAGE 15		// SATS 
			//####################
			try
			{
				World.world.gr_stage = 15; 
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
			}
			catch (err:Error) 
			{
				trace('Grafon.as/drawLoc() - ERROR during stage 15. Error: "' + err.message + '".');
				World.world.showError(err)
			}
				

			//####################
			//      STAGE 16 - Render Pink Cloud if it exists.
			//####################
			try
			{
				World.world.gr_stage = 16;  
				if (room.gas > 0)
				{
					backgroundMatrix = new Matrix(); //Create a new transformation matrix and move the pink cloud to the bottom of the screen.
					backgroundMatrix.ty = 520;
					backBmp2.draw(getObj('back_pink_t', bgObjectCount), backgroundMatrix, new ColorTransform(1, 1, 1, 0.3));
				}
			}
			catch (err:Error) 
			{
				trace('Grafon.as/drawLoc() - ERROR during stage 16. Error: "' + err.message + '".');
				World.world.showError(err)
			}


			//####################
			//      STAGE 17
			//####################
			try
			{
				World.world.gr_stage = 17;  //Draw foreground objects such as beams, stairs, etc. 
				for (var q:int = 0; q > tileArray.length; q++)
				{
					drawTileSprite(tileArray[q], false, true);	//For each material in tileArray, draw the tile sprite. THIS IS WORKING.
				}

				backBmp2.draw(back2, null, currentLocation.cTransform, null, null, false); 
			}
			catch (err:Error) 
			{
				trace('Grafon.as/drawLoc() - ERROR during stage 17. Error: "' + err.message + '".');
				World.world.showError(err)
			}


			//####################
			//      STAGE 18   
			//####################
			try
			{
				World.world.gr_stage = 18; //Unlock all bitmaps, as the background is now rendered.
				if (currentLocation.cTransform && currentLocation.cTransformFon) 
				{
					skyboxLayer.transform.colorTransform = currentLocation.cTransformFon;
				} 
				else if (skyboxLayer.transform.colorTransform != defTransform) 
				{
					skyboxLayer.transform.colorTransform = defTransform;
				}
			}
			catch (err:Error) 
			{
				trace('Grafon.as/drawLoc() - ERROR during stage 18. Error: "' + err.message + '".');
				World.world.showError(err)
			}

			frontBmp.unlock();
			backBmp.unlock();
			backBmp2.unlock();
			vodaBmp.unlock();


			//####################
			//      STAGE 19
			//####################
			World.world.gr_stage = 19;  //Render all game objects.
			drawAllObjs();  //Draw all active objects


			//####################
			//      STAGE 20 FINISHED
			//####################
			World.world.gr_stage = 0;  //Screen is now rendered.
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
					lightBmp.setPixel32(i, j + 1, Math.floor((1-room.roomTileArray[i][j].visi)*255)*0x1000000);
				}
			}
			lightBmp.unlock();
		}
		
		// Drawing all visible (physical?) objects
		public function drawAllObjs():void
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
		
		// Filling the back wall with texture
		public function drawBackWall(tex:String, sposob:int = 0):void
		{
			
			if (tex == 'sky') return;
			var backgroundMatrix:Matrix = new Matrix();
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
		public function setMCT(spriteContainer:MovieClip, tile:Tile, isTopLayer:Boolean):void
		{
			if (spriteContainer.c1)
			{

				if (isTopLayer) 
				{
					spriteContainer.c1.gotoAndStop(tile.kont1+1);
					spriteContainer.c2.gotoAndStop(tile.kont2+1);
					spriteContainer.c3.gotoAndStop(tile.kont3+1);
					spriteContainer.c4.gotoAndStop(tile.kont4+1);
				} 

				else 
				{
					spriteContainer.c1.gotoAndStop(tile.pont1+1);
					spriteContainer.c2.gotoAndStop(tile.pont2+1);
					spriteContainer.c3.gotoAndStop(tile.pont3+1);
					spriteContainer.c4.gotoAndStop(tile.pont4+1);
				}
			}
		}


		// Drawing textured materials
		// Material: Material class.
		// isTopLayer If the material is drawn in front.
		// isClimbable If the material is a beam/stairs/etc.

		// m must be instantiated for this function!
		public function drawTileSprite(material:Material, isTopLayer:Boolean = false, isClimbable:Boolean = false):void
		{
			

			if (!material.used) return;  //If the material is not used, return.


			// If the material should be at the rear and we're drawing to the front, then return, and vice versa
			if (isTopLayer == material.isBackwall) return;


			var thisTile:Tile;
			var spriteContainer:MovieClip;

			var tileCanvas:Sprite 	= new Sprite();
			var tileTexture:Sprite 	= new Sprite();
			var maska:Sprite 		= new Sprite();
			var border:Sprite 		= new Sprite();
			var bmaska:Sprite 		= new Sprite();
			var floor:Sprite 		= new Sprite();
			var fmaska:Sprite 		= new Sprite();
			



			
			
			if (material.texture == null) tileTexture.graphics.beginFill(0x666666);
			else if (room.homeStable && material.alttexture != null) 
			{
				tileTexture.graphics.beginBitmapFill(material.alttexture);
			}
			else tileTexture.graphics.beginBitmapFill(material.texture);

			tileTexture.graphics.drawRect(0, 0, finalWidth, finalHeight);
			tileCanvas.addChild(tileTexture);
			tileCanvas.addChild(maska);

			if (material.border) 
			{
				border.graphics.beginBitmapFill(material.border);
				border.graphics.drawRect(0, 0, finalWidth, finalHeight);
				tileCanvas.addChild(border);
				tileCanvas.addChild(bmaska);
			}
			if (material.floor) 
			{
				floor.graphics.beginBitmapFill(material.floor);
				floor.graphics.drawRect(0, 0, finalWidth, finalHeight);
				tileCanvas.addChild(floor);
				tileCanvas.addChild(fmaska);
			}
			

			
			var isDraw:Boolean = false;

			//Loop for drawing tiles. Draws all tiles in an X axis, then increments the Y axis by 1.
			for (var i:int = 0; i < room.roomWidth; i++) //X axis
			{
				for (var j:int = 0; j < room.roomHeight; j++) //Y axis
				{
					thisTile = room.getTile(i, j); //What tile to draw.

					if (thisTile.tileTexture == material.id && (isTopLayer || isClimbable) || thisTile.tileRearTexture == material.id && !isTopLayer) 
					{
						isDraw = true;

						if (material.textureMask) 
						{
							try
							{
								setMask(spriteContainer, material.textureMask, thisTile, i, j, isTopLayer, maska);
							}
							catch(err)
							{
								trace('Grafon.as/drawTileSprite() - applying texturemask failed on tile ', thisTile, 'at ', i, ',', j)
							}
						}

						if (material.borderMask) 
						{
							try
							{
								setMask(spriteContainer, material.borderMask, thisTile, i, j, isTopLayer, bmaska);
							}
							catch(err)
							{
								trace('Grafon.as/drawTileSprite() - applying bordermask failed on tile ', thisTile, 'at ', i, ',', j)
							}
						}

						if (material.floorMask) 
						{ 
							try
							{
								spriteContainer = new material.floorMask();
								if (spriteContainer.c1) 
								{
									spriteContainer.c1.gotoAndStop(thisTile.kont1 + 1);
									spriteContainer.c2.gotoAndStop(thisTile.kont2 + 1);
								}
								fmaska.addChild(spriteContainer);
								spriteContainer.x = (i + 0.5) * tilepixelwidth;
								spriteContainer.y = (j + 0.5 + thisTile.zForm / 4) * tilepixelheight;
							}
							catch(err)
							{
								trace('Grafon.as/drawTileSprite() - applying floorMask failed on tile ', thisTile, 'at ', i, ',', j)
							}
						}
					}
				}
			}


			if (!isDraw) return; //If the tile's material should not be drawn, return.

			tileTexture.mask = maska; 
			border.mask = bmaska; 
			floor.mask = fmaska;

			tileTexture.cacheAsBitmap 	= Settings.bitmapCachingOption; 
			maska.cacheAsBitmap		 	= Settings.bitmapCachingOption; 
			border.cacheAsBitmap	 	= Settings.bitmapCachingOption; 
			bmaska.cacheAsBitmap 	 	= Settings.bitmapCachingOption; 
			floor.cacheAsBitmap 	 	= Settings.bitmapCachingOption; 
			fmaska.cacheAsBitmap 	 	= Settings.bitmapCachingOption; 

			if (material.appliedFilters) //If the material has any filters...
			{
				tileCanvas.filters = material.appliedFilters;  // Apply them to the sprite.
			}

			if (isTopLayer)
			{
				frontBmp.draw(tileCanvas, null, null, null, null, false);
			}
			else if (isClimbable) 
			{
				backBmp2.draw(tileCanvas, null, room.cTransform, null, null, false);
			}
			else 
			{
				backBmp.draw(tileCanvas, null, null, null, null, false);
			}


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
					if (spriteLists[id] == null) spriteLists[id] = getObj(id, spriteCount+1);
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

		// Enable SATS overlay??	
		public function onSats(on:Boolean):void
		{
			layerSats.visible = on;
			canvasLayerArray[2].visible =! on;
		}
			
		// Drawing water
		public function drawWater(tile:Tile, recurs:Boolean = true):void
		{
			var backgroundMatrix:Matrix = new Matrix();
			backgroundMatrix.tx = tile.X * tilepixelwidth;
			backgroundMatrix.ty = tile.Y * tilepixelheight;
			waterMovieClip.gotoAndStop(room.tipWater+1);
			if (room.getTile(tile.X, tile.Y - 1).water == 0 && room.getTile(tile.X, tile.Y - 1).phis == 0 ) waterMovieClip.gotoAndStop(2);
			else waterMovieClip.gotoAndStop(1);
			vodaBmp.draw(waterMovieClip, backgroundMatrix, room.cTransform, (tile.water > 0) ? 'normal':'erase', null, false);
			if (recurs) drawWater(room.getTile(tile.X, tile.Y+1), false);
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
			decal(erC, drC, nx, ny, 1, 0, 'hardlight');
		}
			
		// Bullet holes
		public function dyrka(nx:int, ny:int, tip:int, mat:int, soft:Boolean = false, ver:Number = 1):void
		{
			var erC:Class, drC:Class;
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
					if (mat == 2) Emitter.emit('kusoch', room, nx, ny, {kol:3});
					else Emitter.emit('kusochB', room, nx, ny, {kol:3});
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
					Emitter.emit('schepoch', room, nx, ny, {kol:3});
				}
			} 
			else if (mat == 7) // field
			{	
				Emitter.emit('pole', room, nx, ny, {kol:5});
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
				if (!soft && Math.random()*0.5<ver) drC = plaexpl_tre;
				centr = true;
			}			

			
			decal(erC, drC, nx, ny, sc, rc, bl);
		}
			
		public function decal(erC:Class, drD:Class, nx:Number, ny:Number, sc:Number = 1, rc:Number = 0, bl:String = 'normal'):void
		{
			var backgroundMatrix:Matrix = new Matrix();
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
				var dyrx:Number = Math.round(nagar.width/2+2)*2, dyry:Number = Math.round(nagar.height/2+2)*2;
				var res2:BitmapData  =  new BitmapData(dyrx, dyry, false, 0x0);
				var rdx:Number = 0;
				var rdy:Number = 0;
				if (nx - dyrx / 2 < 0) rdx = -(nx - dyrx / 2);
				if (ny - dyry / 2 < 0) rdy = -(ny - dyry / 2);
				var rect:Rectangle  =  new Rectangle(nx-dyrx/2+rdx, ny-dyry/2+rdy, nx+dyrx/2+rdx, ny+dyry/2+rdy);
				var pt:Point  =  new Point(0, 0);
				res2.copyChannel(frontBmp, rect, pt, BitmapDataChannel.ALPHA, BitmapDataChannel.GREEN);
				frontBmp.draw(nagar, backgroundMatrix, (bl == 'normal')?World.world.room.cTransform:null, bl, null, true);
				rect  =  new Rectangle(0, 0, dyrx, dyry);
				pt = new Point(nx-dyrx/2+rdx, ny-dyry/2+rdy);
				frontBmp.copyChannel(res2, rect, pt, BitmapDataChannel.GREEN, BitmapDataChannel.ALPHA);
			}
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
			if (ny1<ny2)
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
			brRect.right = rx2-rx1;
			brRect.top = 0;
			brRect.bottom = ry2-ry1;
			backBmp.copyChannel(brData, brRect, brPoint, BitmapDataChannel.GREEN, BitmapDataChannel.ALPHA);
		}
		
		public function specEffect(n:Number = 0):void
		{
			if (n == 0)
			{
				mainCanvas.filters = [];
				skyboxLayer.filters = [];
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
				skyboxLayer.filters = [new BlurFilter(n - 100, n - 100)];
			}
		}
	}
}
