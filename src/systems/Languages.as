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
			trace('Languages.as/languageSetup() - Running language setup.');
			languageLoader.removeEventListener(XMLLoader.XML_LOADED, languageSetup);


			languageListXML = languageLoader.xmlData;


			//This loads all languageIDs and LanguageData as essentially value-Key pairs.
			for each (var languageFile:XML in languageListXML.languageID) 
			{
                var languageID:String = languageFile.@id;
                var languageDataObject:Object = {name: languageFile.toString(), file: languageFile.@file};
                languageListObject[languageID] = languageDataObject;
                trace('Languages.as/languageSetup() - Language ID: "' + languageID + '", File: "' + languageDataObject.file + '", Name: "' + languageDataObject.name + '"');
            }

			//I think it should be moved to loading now.

			trace('Languages.as/languageSetup() - Trying to access languageFile for languageName: "' + languageName + '"');
			if (languageListObject.hasOwnProperty(languageName)) 
			{
				var languageFileURL:String = languageListObject[languageName].file;
				trace('Languages.as/languageSetup() - Calling loadLanguage() with: "' + languageFileURL + '"');
				loadLanguage(languageFileURL); 
			} 
			else 
			{
				trace('Languages.as/languageSetup() - Error: "' + languageName + '" not found in languageListObject.');
			}
			
        }


		public static function loadLanguage(languageID:String):void
		{

			var languageFileURL:String = (languageFilesLocation + languageID);

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


		public static function changeLanguage(languageID:String):void
		{
			// Check if the provided languageID exists in languageListObject
    		if (languageListObject.hasOwnProperty(languageID)) 
			{
				// Update the current language
				languageName = languageID;

        		// Fetch the file URL for the new language
        		var languageFileURL:String = languageListObject[languageID].file;

        		trace('Languages.as/changeLanguage() - Loading new language into memory. languageName: "' + languageName + '" URL: "' + languageFileURL + '"');
        
				// Load the new language into memory
				loadLanguage(languageFileURL);
				// Save the new configuration
				World.world.saveConfig();
   			} 
			else 
			{
        		trace('Languages.as/changeLanguage() - Provided languageID "' + languageID + '" does not exist. Falling back to current language.');
				languageName = 'en';
    		}

		} 
		
		
	}
}