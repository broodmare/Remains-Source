package interdata 
{

    public class KeyStates
    {

        public static function createKeyStatesObject(keyStatesObject:Object):Object
        {
            //This object holds every key and whether it's currently being pressed.
            keyStatesObject =
            {
            keyLeft		: false,
            keyRight	: false,
            keyDubLeft	: false,
            keyDubRight	: false,
            keyJump		: false,
            keySit		: false,
            keyDubSit	: false,
            keyBeUp		: false,
            keyRun		: false,
            keyAttack	: false,
            keyPunch	: false,
            keyReload	: false,
            keyGrenad	: false,
            keyMagic	: false,
            keyDef		: false,
            keyPet		: false,
            keyAction	: false,
            keyCrack	: false,
            keyTele		: false,
            keyPip		: false,
            keySats		: false,
            keyFly		: false,
            keyLook		: false,
            keyZoom		: false,
            keyFull		: false,
            keyItem		: false,
            keyPot		: false,
            keyMana		: false,
            keyItemPrev	: false,
            keyItemNext	: false,
            keyInvent	: false,
            keyStatus	: false,
            keySkills	: false,
            keyMed		: false,
            keyMap		: false,
            keyQuest	: false,
            keyWeapon1 	: false,
            keyWeapon2 	: false,
            keyWeapon3 	: false,
            keyWeapon4 	: false,
            keyWeapon5 	: false,
            keyWeapon6 	: false,
            keyWeapon7 	: false,
            keyWeapon8 	: false,
            keyWeapon9 	: false,
            keyWeapon10	: false,
            keyWeapon11	: false,
            keyWeapon12	: false,
            keyScrDown	: false, 
            keyScrUp	: false,
            rbmDbl		: false,
            keyDash		: false, 
            keyArmor	: false,
            keySpell1	: false, 
            keySpell2	: false, 
            keySpell3	: false, 
            keySpell4	: false,
            keyTest1	: false,
            keyTest2 	: false
            };

            return keyStatesObject;
        }


    }




}