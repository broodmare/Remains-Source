# Remains-Source



---

Rework of the game made by Emaplu.

---

```
Remains.fla --
zastavka -> loadingWidget.
	duplicated zastavka removed.
MainFE renamed to Main.
import 'fe.Obj' calls changed to import 'Obj'.
Removed import protection.
Exported audio changed from Mono to Stereo.
Exported audio set at 128kbs mp3.
Flash version 30 -> 32.
voda -> waterMovieClip
pink -> pinkCloudMovieClip
govno -> greenCloudMovieClip

butEng removed.
butRus removed.

butLang 
	[russian] -> "langauge" so it's more obvious when mainMenu is broke.




"Test" levels, quest, and checks removed.

vfon = background


Renamed all 'loc' variables to avoid compiler ambigiuity with the loc folder.
Renamed all folders to reduce compiler ambiguity.
Reduced import nesting.
moved language files into '/data'.
moved '.swf' files into '/data'.
moved .xml files to '/data'.
Removed built in levels option/check.

Appear --
	Load()
		Fixed 'l' being defined twice.

Ctr --
	Grouped all key states into a keyState object.
		
Emitter --
	step()
		Fixed Emitter.emit setting rx twice instead of rx and ry.
	
Form --
	Fixed loop in setForms().
	fForms 	-> tileForms.
	oForms 	-> otherForms.
	id 		-> formID
	ed 		-> formLayer
	tip 	-> formType.
	back 	-> formRearTextureID
	rear 	-> formHasRearTexture.
	mat 	-> formMaterial
	
Game --
	lands 	-> levelArray.
	gotoLand -> gotoLevel.
	exitLand -> exitLevel.
	enterToCurLand -> enterCurrentLevel.
	
GameData --
	Split into levels.xml, npcs.xml, scripts.xml, quests.xml, and vendors.xml
	
Grafon --
	Moved initializers into the constructor instead of in the class definition.
	Fixed for loop in constructor.
	Fixed 'i' being defined twice in constructor.
	Fixed for loop in drawAllObjs().
	setBackgroundSize() -> setSkyboxSize.
	transpFon -> transparentBackground.
	drawBackWall() -> drawDecorativeBackground().
	(currentLocation.backwall, currentLocation.backform)
	
	vfon 		-> background.
	numbObj 	-> canvasLayerCount.
	visObjs 	-> canvasLayerArray.
	drawFon 	-> drawSkybox().
	setFonSize 	-> setBackgroundSize
	
	visual 		-> mainCanvas
	visBack 	-> layerBackground_1.
	visBack2 	-> layerBackground_2.
	visVoda 	-> layerWater.
	visaFront 	-> vis
	visLight 	-> layerLighting.
	visSats 	-> layerSats.
	sloy 		-> layer.
	ram* -> border*
	
	toFront -> isTopLayer

	numbMat 	-> materialCount
	numbFon 	-> skyboxCount
	numbBack 	-> bgObjectCount
	numbObj 	-> objectCount
	numbSprite  -> spriteCount
	back - what backwall is behind a tile.
	drawlayer - normal staircases '3', all other climbables '4'.
	vid - only climbables.
	1, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16,
	rear - should be drawn behind normal staircases? only normal staircasese don't have this.
	lurk - only mechanism and pipes.
	
languageList.xml (formerly lang.xml)--
	default -> defaultLang.


Level (formerly Land) --
	Land() -> Level().
	enterLand -> enterLevel().
	
	
LevelTemplates (formerly LandAct) --
	LandAct() -> LevelTemplates().
	
Main --
	zastavka -> loadingWidget.
	
MainMenu --
	MainMenu()
		Changed passed variable from a Sprite to a MovieClip.
	Consolidated event listeners.
	
Material --
		Imports a 'mask' propety from 'AllData.xml' as a generic class. This was changed to be imported as a string.
		If the import failed, it was set as a class that doesn't exist (TileMask).
		rear -> isBackwall
		Filter array changed to a static object and moved to 'TileFilter.as'.
	
Res --
	d 	 -> gameData.
	type -> classDataKey.
	removed pipText().
	removed guiText().
	
Room (formerly Location) --
	space 	-> roomTileArray
	unloadLocation() -> unloadRoom().
	locationActive -> roomActive.
	landProb -> roomProb
	acts 	-> activeObjects.
	limX 	-> roomPixelWidth
	limY 	-> roomPixelHeight
	spaceX 	-> roomWidth
	spaceY 	-> roomHeight
	rx 		-> roomCoordinateX
	ry 		-> roomCoordinateY
	rz 		-> roomCoordinateZ
	
	removed endLand().
	
	
RoomTemplate (formerly Room)

RoomContainer (formerly Rooms)

Sats --
	concatenating strings method changed from '+=' to '.appendText()' for performance.
Snd --
	inited 		-> soundInitialized.
	onSnd 		-> soundEnabled.
	onMusic 	-> musicEnabled.
	shumArr 	-> soundStage.
	resSounds 	-> soundResourceData



Tile --
	dec() 	-> parseLevelXML().
	front 	-> tileTexture
	back 	-> tileRearTexture
	rear 	-> tileHasRearTexture.
	mat 	-> tileMaterial.

Unit --
	SetLevel()
		Set MaxHP before HP.
		Before HP was being set before a max value was calculated.
		
World --
	ativateLand() -> activateLevel().
	allLandsLoaded -> allLevelsLoaded
	vfon -> skybox.
	main -> mainDisplay
	kolLands -> levelsFound
	kolLandsLoaded -> levelsLoaded
	visual -> mainCanvas
	vWait -> loadingScreen
	landDifLevel -> levelDifficultyLevel
	w -> world
	CellsX -> roomTileWidth
	CellsY -> roomTileHeight
	Settings moved into their own component class.
	Language loader moved into their own system class.
	removed extra setTransform() call during appearance menu initialization.
	removed savePath variable.
	Create configObj sooner, language setup needs it to complete it's tasks.
	
Texture.fla --
	fonCanter 		-> skyboxCanterlot
	fonClear 		-> skyboxClear
	fonDarkClouds 	-> skyboxDarkClouds
	fonDefault 		-> skyboxDefault
	fonEnclave 		-> skyboxEnclave
	fonFinalb 		-> skyboxFinalB
	fonFire 		-> skyboxFire
	fonRuins 		-> skyboxRuins
	fonWay 			-> skyboxWay


Cyclomatic complexity Highscore:

Unitplayer.control - 331
Unit.actAction - 331
Unitplayer.actions - 219
Unit.damage - 184
Unitplayer.anim - 169
UnitAlicorn.control - 160
Unit.run - 129
UnitHellhound.control - 126
UnitAnt.control - 123
Unit.getXmlParam - 115
Interact.Interact - 110
UnitAIRobot.control - 102
Consol.analis - 95
Bullet.run - 92
LootGen.lootCont - 89
Invent.usePotion - 86
PipPageVend.setSubPages - 84
Invent.take - 81
Script.com - 79
GUI.setCelObj - 79
PipPageInv.setSubPages - 75

```
<<<<<<< HEAD


=======
>>>>>>> 9e6dc3d18a2b8593e1d470612194cb8d972cceb2
