package systems
{

	import flash.events.Event;
	import flash.utils.Dictionary;

	import components.Settings;
	import systems.XMLLoader;

    public class Languages
    {


		//Language settings
		public static var languageName:String = 'en';

		public static var languageListDictionary:Dictionary;
		public static var languageCount:int = -1; //Set to -1 instead of 0 since the language count starts by incrementing by 1.


		
		//Loading info
		public static var currentLanguageData:XML;

		public static var textLoaded:Boolean = false;

		public static var languageLoader:XMLLoader;
		public static var languageDataLoader:XMLLoader;

		private static const languageFilesLocation:String = Settings.languageXMLLocation

        public function Languages()
        {
			
        }


		public static function languageStart():void
		{
			trace('Languages.as/languageStart() - Creating langauge dictionary and loading languages..."');
			initializeLanguageDictionary();
			
			for (var language:* in languageListDictionary)
			{
				var languageFileURL:String = (languageFilesLocation + 'text_' + language + '.xml');

				trace('Languages.as/languageStart() - Trying to load: "' + languageFileURL + '"');
				languageLoader = new XMLLoader();
				languageLoader.addEventListener(XMLLoader.XML_LOADED, languageSetup);

				languageLoader.load(languageFileURL, "languageStart()");
			}
		}

        public static function languageSetup(event:Event):void
        {


			var currentLoader =  event.currentTarget;
			currentLoader.removeEventListener(XMLLoader.XML_LOADED, languageSetup);

			trace('Languages.as/languageSetup() - currentLoader.xmlData.lang.@id: "' + currentLoader.xmlData.lang.@id + '"');
            var language:String = currentLoader.xmlData.lang.@id;


            var languageData:XML = currentLoader.xmlData;

			trace('Languages.as/languageSetup() - Adding language "' + language + '" to language dictionary.');
            languageListDictionary[language] = languageData;

			//Hardcoded just to get this shit to work first.
			if (language == "en")
			{
				trace('Languages.as/languageSetup() - English text file loaded, calling applyLanguage().');
				applyLanguage(language); 
			}
			
        }

		public static function applyLanguage(languageID:String):void
		{

			currentLanguageData = languageListDictionary[languageID];
			languageName = currentLanguageData.lang.@id;

			
			trace('Languages.as/applyLanguage() - Lanuage applied: "' + languageName + '." Updating "Res.as" to use currentLanguageData for the localization file.');
			Res.localizationFile = currentLanguageData;
			

			textLoaded = true;
			trace('Languages.as/applyLanguage() - Language setup complete.');
		}


		public static function changeLanguage(languageID:String):void
		{

			// Update the current language
			languageName = languageID;

			// Fetch the file URL for the new language
			var languageFileURL:String = languageListDictionary[languageID].file;

			trace('Languages.as/changeLanguage() - Loading new language into memory. languageName: "' + languageName + '" URL: "' + languageFileURL + '"');
	
			// Load the new language into memory
			applyLanguage(languageFileURL);
			// Save the new configuration
			World.world.saveConfig();


		}

		private static function initializeLanguageDictionary()
		{
			languageListDictionary = new Dictionary();
			
			//This is going to be hardcoded for now.
			languageListDictionary["en"] = new XML();
			languageListDictionary["es"] = new XML();
			languageListDictionary["de"] = new XML();
			languageListDictionary["jp"] = new XML();
			languageListDictionary["pl"] = new XML();
			languageListDictionary["ru"] = new XML();
			languageListDictionary["zh"] = new XML();
		}
		
	}
}