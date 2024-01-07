package locdata
{
  import flash.events.Event;
  import flash.utils.Dictionary;

  import components.Settings;
  import components.XmlBook;
  import systems.XMLLoader;

	public class LevelArray 
  {
    // These hold XML data containing special parameters for each level and all room data for each level.
    public static var levelVariantArray:Dictionary;   // Level variants created using templates and special parameters.
		public static var levelRoomDataArray:Dictionary;  // Level templates that are used by level variants to create unique levels.
    private static var templateFileNameList:Array;

    // These hold LevelTemplate objects after they've been initialized. These are what the game uses while running.
    public static var initializedLevelVariants:Array;
    public static var initializedProbLevels:Array;

    private static var levelsFound:int = 0;
    private static var levelsLoaded:int = 0;
    public static var allLevelsLoaded:Boolean = false; // Just in case, not sure if it'll be used.
    
    public static function loadAllGameLevels():void // Public function used by Game.as constructor to load all levels.
    {
      setupLevelTemplateArray();
    }

    // Step 1: Create dictionary entries for all level varirants, all base level designs, and create a list of all base level designs that need to be loaded.
    private static function setupLevelTemplateArray():void 
    {
      trace('LevelArray.as/setupLevelTemplateArray() - Initializing the level array.');
      levelVariantArray   = new Dictionary();
      levelRoomDataArray  = new Dictionary();
      templateFileNameList = [];

      for each (var variant:XML in XmlBook.getXML("levels").level)
      {
        var variantName:String = variant.@id;
        levelVariantArray[variantName] = variant;      // Copy the level settings for each level variant (always unique).
        trace('LevelArray.as/setupLevelTemplateArray() - Adding an entry for level variant: "' + variantName + '" in the level variant array.');

        var templateFileName:String = variant.@fileName;  //  Create a list of new Level data names (sometimes re-used)
        if (templateFileNameList[templateFileName] == null) 
        {
          trace('LevelArray.as/setupLevelTemplateArray() - Adding an entry for template: "' + templateFileName + '" to the template list.');
          templateFileNameList[templateFileName] = templateFileName;
        }
      }

      loadXMLRoomData();
    }

    // Step 2: Load room data into each base level design.
    private static function loadXMLRoomData():void // Load all data for templates into memory for variants to use.
    {
      trace('LevelArray.as/loadXMLRoomData() - Loading room data for all base level designs.');
      for each (var fileName:String in templateFileNameList)
      {
				var levelFilePath:String = (Settings.levelPath + fileName + '.xml');

				trace('LevelArray.as/setupLevelTemplateArray() - loading rooms for template: "' + fileName + '" from: "' + levelFilePath +'".');

        levelsFound++;
				var levelLoader = new XMLLoader();

        levelLoader.addEventListener(XMLLoader.XML_LOADED, createEventListener(fileName, levelRoomDataArray));
				levelLoader.load(levelFilePath, "setupLevelTemplateArray()");
      }

      function createEventListener(fileName:String, variantArray:Dictionary):Function 
      {
        return function(event:Event):void 
        {
          addDataToTemplate(fileName, variantArray)(event);
        };
      }
    }

    private static function addDataToTemplate(levelTemplate:String, levelRoomDataArray:Dictionary):Function 
    {
      return function(event:Event):void 
      {
          var currentLoader:XMLLoader = XMLLoader(event.currentTarget);
          currentLoader.removeEventListener(XMLLoader.XML_LOADED, arguments.callee);

          var levelTemplateXMLData:XML = currentLoader.xmlData;
          levelRoomDataArray[levelTemplate] = levelTemplateXMLData;
          trace('LevelArray.as/addLevelTemplateData() - Template: "' + levelTemplate + '" loaded.');

          levelsLoaded++;
          checkIfAllLevelsLoaded();
      };
    }

    private static function checkIfAllLevelsLoaded():void
    {
      if (levelsLoaded == levelsFound)
      {
        trace('LevelArray.as/checkIfAllLevelsLoaded() - "' + levelsLoaded + '" of "' + levelsFound + '" levels loaded. Initializing levels.');
        allLevelsLoaded = true;
        initializeLevels();
      }
    }

    // Step 3: Copy base level designs to every unique level variant.
    private static function initializeLevels():void
		{
			trace('LevelArray.as/initializeLevels() - Initializing level variants.');

      initializedProbLevels     = [];
      initializedLevelVariants  = [];

			for each (var levelVariant:XML in levelVariantArray)
			{
				var variantName:String  = levelVariant.@id;
				var templateName:String = levelVariant.@fileName;
        
        // Create a new Template for each level and add the XML data for it's rooms.
				trace('LevelArray.as/initializeLevels() - Initializing template for level variant: "' + variantName + '".');
				var template:LevelTemplate = new LevelTemplate(levelVariant);
				template.levelXMLData = levelRoomDataArray[templateName];

        // Mark template as loaded and add the intialized level variant to the correct storage array.
        template.loaded = true;
				if (template.prob == 0) initializedLevelVariants[template.id] = template;
				else initializedProbLevels[template.id] = template;
			}
		}

    public static function getLevelArray(arrayName:String):Array
    {
      switch(arrayName)
      {
        case 'initializedLevelVariants':
          return initializedLevelVariants;
        case 'initializedProbLevels':
          return initializedProbLevels;
        default:
          trace('LevelArray.as/getLevelArray() - ERROR: Array name: "' + arrayName + '" is not valid!');
          return null;
      }
    }
	}
}