package components
{

    import flash.events.Event;
    import flash.utils.Dictionary;

	import systems.XMLLoader;

    public class XmlBook
    {

        private static var xmlBook:Dictionary;
        private static const xmlFilesLocation:String = Settings.xmlBookDataLocation;

        private static var pageSetupCounter:int = 0;
        private static var bookSetup:Boolean = false;


		public function XmlBook() 
		{
            

		}


        public static function xmlBookSetup():void
        {
			trace('XmlBook.as/xmlBookSetup() - Loading XML Files..."');

			
			if (!bookSetup)
            {

                initializeXmlBook();

                for (var key:String in xmlBook)
                {
                    var xmlBookPageURL:String = xmlFilesLocation + key + ".xml";
                    var loader:XMLLoader = new XMLLoader();

                    //Creating an anonymouse function for each loader to run after each XML file is finished loading.
                    loader.addEventListener(XMLLoader.XML_LOADED, initializeXmlPage);

                    loader.load(xmlBookPageURL, key);
                }
                
            }
            else
            {
                trace('XmlBook.as/xmlBookSetup() - ERROR: xmlBook setup failed, xmlBook setup already completed.');
            }

        }


        private static function initializeXmlPage(event:Event):void
        {
            

            var currentLoader:Object =  event.currentTarget;
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

            //Alldata
            xmlBook["armors"]       = new XML();
            xmlBook["backgrounds"]  = new XML();
            xmlBook["effects"]      = new XML();
            xmlBook["items"]        = new XML();
            xmlBook["materials"]    = new XML();
            xmlBook["objects"]      = new XML();
            xmlBook["parameters"]   = new XML();
            xmlBook["particles"]    = new XML();
            xmlBook["perks"]        = new XML();
            xmlBook["skills"]       = new XML();
            xmlBook["units"]        = new XML();
            xmlBook["weapons"]      = new XML();

            //GameData
            xmlBook["levels"]       = new XML();
            xmlBook["npcs"]         = new XML();
            xmlBook["scripts"]      = new XML();
            xmlBook["quests"]       = new XML();
            xmlBook["vendors"]      = new XML();

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