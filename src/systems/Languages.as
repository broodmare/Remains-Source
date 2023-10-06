package systems
{


	import flash.net.URLLoader; 
	import flash.net.URLRequest; 
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.system.Capabilities;

	import components.Settings;
	import systems.XMLLoader;

    public class Languages
    {


		//Language settings
		public static var currentLanguageName:String; 		//Current langauge. Set to 'en'.
		public static var defaultLanguageName:String; 		//Default langauge. Set to 'en'.
		public static var languageList:Object;
		public static var languageCount:int = 0;

		//Loading info
		public static var currentLanguageData:Object;
		public static var defaultLanguageData:Object;
		public static var textLoaded:Boolean = false;
		public static var textLoadFailed:Boolean = false;


		public static var languageListXML:XML;
		public static var langURL:String;

		public static var languageLoader:XMLLoader;
		public static var languageURL:URLRequest;


        public function Languages()
        {
            
			
        }


		public static function languageStart()
		{


			//Sets Language setting defaults
            currentLanguageName     = 'en'; //Hardcoded for now
            defaultLanguageName     = 'en'; //Hardcoded for now
			langURL = Settings.languageListURL;

			
			trace('Languages.as/languageStart() - Starting language setup...\n' + 'langURL is ' + langURL);
            World.world.textProgressLoad = 0;

			try
			{
				
				languageURL = new URLRequest(langURL);
				languageLoader = new XMLLoader();
				languageLoader.load(languageURL.url, languageSetup, funProgress)
				World.world.load_log += 'Language list: ' + languageURL.url + ' Loaded.\n';
				trace('Languages.as/languageSetup() - Language list: ' + languageURL.url + ' Loaded.');
			}
			catch (err) 
			{
				textLoadFailed = true;
				World.world.load_log += 'Error in language file: ' + languageURL.url + '\n';
				trace('Languages.as/onCompleteLoadLang() - Error in language file: ' + languageURL.url);
			}
		}

        public static function languageSetup(langXML:XML)
        {
			textLoaded = true;

			languageListXML = langXML;
			Res.d = languageListXML;
			

			//Set currentLanguage as the game's saved lanaguge if it exists.
			if (World.world.configObj.data.language != null) currentLanguageName = World.world.configObj.data.language; 

			//If the languageXML exists and has a default language option, set it as the default language.
			if (languageListXML && languageListXML.@defaultLanguage.length) defaultLanguageName = languageListXML.@defaultLanguage; 


			for each (var xmlFile:XML in languageListXML.languageID) //Grab each langauge URL location in the file and save each one as an object.
			{
				if (xmlFile.@off.length == 0 || !(xmlFile.@off > 0))
				{
					var obj:Object = {file:xmlFile.@file, nazv:xmlFile[0]};
					languageList[xmlFile.@id] = obj;
					languageCount++;
				}
			}

			if (languageList[currentLanguageName] == null) currentLanguageName = defaultLanguageName; // If there was no language saved , set it to default.

			defaultLanguageData = [languageList[defaultLanguageName].file, true]; // Load the default langauge
			if (currentLanguageName != defaultLanguageName) // If the current language is different from the default, load it as well.
			{
				currentLanguageData = [languageList[currentLanguageName].file]; // Set the current langauge data as information from the XML.
			} 
			else 
			{
				currentLanguageData = defaultLanguageData; //Otherwise Just copy over default language
			}

        }

		public static function funProgress(progress:Number):void 
		{
			World.world.textProgressLoad = progress;
        }


		//select new language
		public static function defuxLang(languageID:String)
		{
			currentLanguageName = languageID;
			textLoadFailed = false;
			if (languageID != defaultLanguageName) 
			{
				textLoaded = false;
				currentLanguageData = [languageList[languageID].file];
			} 
			else
			{
				Res.d = Res.e;
				World.world.pip.updateLang();
			}
			World.world.saveConfig();
		}

	}
}