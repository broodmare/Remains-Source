package components
{
    import flash.events.Event;
    import flash.utils.Dictionary;

	import systems.XMLLoader;

    public class XmlBook
    {
        private static var xmlBook:Dictionary;
        private static const xmlFilesLocation:String = Settings.xmlBookDataLocation;
        private static var xmlFiles:Array = 
        [
            "armors", "backgroundObjects", "effects", "items", "materials",
            "objects", "parameters", "particles", "perks", "skills",
            "units", "weapons", "levels", "npcs", "scripts",
            "quests", "vendors", "sounds"
        ];
        private static var pageSetupCounter:int = 0;
        public static var bookSetup:Boolean = false;

		public function XmlBook() 
		{
            
		}

        public static function xmlBookSetup():void
        {
			trace('XmlBook.as/xmlBookSetup() - Loading XML Files.');

			if (!bookSetup)
            {
                initializeXmlBook();

                for (var key:String in xmlBook)
                {
                    var xmlBookPageURL:String = xmlFilesLocation + key + ".xml";
                    var loader:XMLLoader = new XMLLoader();
                    
                    loader.addEventListener(XMLLoader.XML_LOADED, initializeXmlPage); //Anonymous function for each loader to run after each XML file is finished loading.
                    loader.load(xmlBookPageURL, key);
                }
            }
            else trace('XmlBook.as/xmlBookSetup() - ERROR: xmlBook setup failed, xmlBook setup already completed.');
        }

        private static function initializeXmlPage(event:Event):void
        {
            var currentLoader:Object = event.currentTarget;
            currentLoader.removeEventListener(XMLLoader.XML_LOADED, initializeXmlPage);

            var currentXML:XML = currentLoader.xmlData
            var currentKey:String = currentXML.name().localName;   // Get the name of the root node in the XML to use as a key in the XmlBook Dictionary, Eg. <armors>

            xmlBook[currentKey] = currentXML;
            pageSetupCounter++

            var totalDictionaryKeys:int = countDictionaryKeys(xmlBook);
            if (pageSetupCounter >= totalDictionaryKeys) 
            {
                bookSetup = true;
                trace('XmlBook.as/initializeXmlPage() - All XML pages have been loaded.');
            }
        }

        private static function countDictionaryKeys(dictionary:Dictionary):int 
        {
            var dictionaryKeyCount:int = 0;
            for (var key:* in dictionary) 
            {
                dictionaryKeyCount++;
            }
            return dictionaryKeyCount;
        }

        private static function initializeXmlBook():void 
        {
            trace('XmlBook.as/initializeXmlBook() - New XmlBook created and initialized.');

            xmlBook = new Dictionary();

            for each (var xmlFile:String in xmlFiles) 
			{
				xmlBook[xmlFile] = new XML();
			}
        }
        
        public static function getXML(xmlKey:String):XML
        {
            if (xmlBook.hasOwnProperty(xmlKey)) 
            {
                return xmlBook[xmlKey];
            } 
            else 
            {
                trace('XmlBook.as/getXML() - Invalid XmlBook Lookup: "' + xmlKey + '."');
                return null;
            }
        }   
    }
}