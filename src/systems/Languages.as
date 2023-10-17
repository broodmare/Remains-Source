package systems
{

	import flash.events.Event;

	import components.Settings;
	import systems.XMLLoader;

    public class Languages
    {


		//Language settings
		public static var languageName:String = 'en';

		public static var languageListObject:Object = {};
		public static var languageCount:int = 0;

		//Loading info
		public static var languageData:XML;

		public static var textLoaded:Boolean = false;

		public static var languageListXML:XML;

		public static var languageFilesLocation:String 
		public static var languageListURL:String;

		public static var languageLoader:XMLLoader;
		public static var languageDataLoader:XMLLoader;

        public function Languages()
        {
			
        }


		public static function languageStart():void
		{
			trace('Languages.as/languageStart() - Loading languages..."');

			languageFilesLocation = Settings.languageXMLLocation;

			languageListURL = (languageFilesLocation + "languageList.xml");
			
			trace('Languages.as/languageStart() - Attempting to available languages from: "' + languageListURL + '."');
			
			languageLoader = new XMLLoader();
			languageLoader.addEventListener(XMLLoader.XML_LOADED, languageSetup);

			trace('Languages.as/languageStart() - Calling XMLLoader.as/load with ' + languageListURL);
			languageLoader.load(languageListURL, "languageStart()");

		}

        public static function languageSetup(event:Event):void
        {
			
			trace('Languages.as/languageSetup() - Language list loaded, languageSetup() Executing...');
			languageLoader.removeEventListener(XMLLoader.XML_LOADED, languageSetup);
			
			World.world.load_log += 'Language list: ' + languageListURL + ' Loaded.\n';

			languageListXML = languageLoader.xmlData;
			
			if (languageListXML == null)
			{
				trace('Languages.as/languageSetup() - ERROR: languageListXML is null.');
			}
			
			if (World.world.configObj != null)
			{
				trace('Languages.as/languageSetup() - Setting current language.');
				languageName = World.world.configObj.data.language;
			}
			else
			{
				trace('Languages.as/languageSetup() - ERROR: World.world.configObj is null.');
			}
			
			
			
			if (languageListXML && languageListXML.languageID != null) 
			{
				trace('Languages.as/languageSetup() - Adding each language from xmlFile to languageListObject.');
				for each (var languageFile:XML in languageListXML.languageID) //Grab each langauge URL from languageListXML.
				{
						//Create an object with two properties. A 'file' property which stores that language's XML file name and the 'name' property, which grabs the text from each node used for each language name.
						var languageDataObject:Object = {objectName:languageFile[0], file:languageFile.@file}; //Sets the object's name as the first XML text (The language name) and saves the file URL.
						languageListObject[languageFile] = languageDataObject; //Saves the Name and File url as the language ID. eg. 'en', 'ru', etc.
						languageCount++;
				}
				trace('Languages.as/languageSetup() - Finished. Final languageCount is: "' + languageCount + '."');

			}
			else
			{
				trace('Languages.as/languageSetup() - ERROR: languageListXML.languageID is null!');
			}


			var languageFileURL:String = languageListObject[languageName].file;
			trace('Languages.as/languageSetup() - Loading current language into memory. languageName: "' + languageName + '." URL: "' + languageFileURL + '."');
			loadLanguage(languageFileURL); // Load the current language into memory as languageData.
			
        }


		public static function loadLanguage(fileURL:String):void
		{

			var languageFileURL:String = (languageFilesLocation + fileURL);

			languageDataLoader = new XMLLoader();
			languageDataLoader.addEventListener(XMLLoader.XML_LOADED, applyLanguage);

			trace('Languages.as/loadLanguage() - Calling XMLLoader.as/load with ' + languageFileURL);
			languageDataLoader.load(languageFileURL, "loadLanguage()");
		}

		public static function applyLanguage(event:Event):void
		{
			languageDataLoader.removeEventListener(XMLLoader.XML_LOADED, applyLanguage);

			
			languageData = languageDataLoader.xmlData;
			languageName = languageData.all.lang;
			trace('Languages.as/applyLanguage() - Lanuage applied: "' + languageName + '." Updating "Res.as" to use currentLanguageData.');

			Res.gameData = languageData;
			

			textLoaded = true;
			trace('Languages.as/applyLanguage() - Language setup complete.');
		}


		public static function changeLanguage(newLanguageID:String):void
		{
			trace('Languages.as/languageSetup() - Setting textLoaded to false.');
			textLoaded = false;
			
			languageName = newLanguageID
			var languageFileURL:String = languageListObject[newLanguageID].file;
			
			trace('Languages.as/languageSetup() - Loading new language into memory. languageName: "' + newLanguageID + '" URL: "' + languageFileURL + '"');
			loadLanguage(languageFileURL); // Load the current language into memory as languageData.

			World.world.saveConfig();
		} 
		
		
	}
}