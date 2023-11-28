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
		public static var languageCount:int = 0;
		
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

		//TODO: un-hardcode english.
        public static function languageSetup(event:Event):void
        {


			var currentLoader:Object = event.currentTarget;
			currentLoader.removeEventListener(XMLLoader.XML_LOADED, languageSetup);

            var language:String = currentLoader.xmlData.lang.@id;
            var languageData:XML = currentLoader.xmlData;

			trace('Languages.as/languageSetup() - Adding language "' + language + '" to language dictionary.');
			if (languageListDictionary[language] != null)
			{
				languageListDictionary[language] = languageData;

				//Hardcoded just to get this shit to work first.
				if (language == "en")
				{
					trace('Languages.as/languageSetup() - English text file loaded, calling applyLanguage().');
					applyLanguage(language); 
				}
			}
			else 
			{
				trace('Languages.as/languageSetup() - Language file: "' + language + '" not recognized, discarding.');
			}

			
        }

		public static function applyLanguage(languageID:String):void
		{

			currentLanguageData = languageListDictionary[languageID];
			languageName = currentLanguageData.lang.@id;

			
			trace('Languages.as/applyLanguage() - Lanuage applied: "' + languageName + '."');
			Res.localizationFile = currentLanguageData;
			
			textLoaded = true;
			trace('Languages.as/applyLanguage() - Language setup complete.');
		}


		public static function changeLanguage(languageID:String):void
		{
			if (languageListDictionary[languageID] != null)
			{
				languageName = languageID;

				trace('Languages.as/changeLanguage() - Changing language to: "' + languageName + '" and saving.');
				
				applyLanguage(languageName);
				World.world.saveConfig();
			}
			else 
			{
				trace('Languages.as/changeLanguage() - Language ID: "' + languageName + '" not recognized, failed to change language.');
			}
			
		}

		//TODO: un-hardcode supported languages.
		private static function initializeLanguageDictionary():void
		{
			languageListDictionary = new Dictionary();
			
			//This is going to be hardcoded for now.
			languageListDictionary["en"] = new XML();
			languageListDictionary["es"] = new XML();
			languageListDictionary["de"] = new XML();
			languageListDictionary["jp"] = new XML();
			languageListDictionary["pl"] = new XML();
			languageListDictionary["ru"] = new XML();
			languageListDictionary["ch"] = new XML();
		}
		
	}
}