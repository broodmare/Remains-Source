# Remains-Source
---

This project is an attempt to translate, re-write, and optimize the Fallout Equestria: Remains game made by Empalu.

This is not a complete remake and still uses Flash and ActionScript instead of a new engine.

---


```
Current project goals:

    - Load all XML data at runtime instead of being hardcoded.
    - Load as many resources possible from a directory instead of .swf libraries.
    - Translate the source code into English.
    - Make the source code easy to read and understand through refactoring and properly descriptive variable/function naming.
    - Convert all code to use strict typing. This will make it easier to port to other languages eventually if needed.
    - Document how the source code functions.
    - Optimize the source code when possible.
```

```
Possible Goals:

    - Loading multiple XML sources and patching at startup to allow for multiple mod files.
    - Rewrite parts of the UI to remove the dependency on Adobe Animate to compile.
    - Implement modern flash rendering and hardware acceleration with the Starling Engine.
    - Improvements or stand-alone level editor.
    - Unlocked refresh rate, while the animations are set at 30fps, other elements may be able to refresh faster.
    - NPC behavior modification.
    - Support for custom scripts/quests/etc.
```

```
FAQ:

    Q: Does the game currently work?
    A: No.

    Q: Does the game function the same as the original?
    A: Ideally yes, however due to the nature of re-writing large parts of code, some things may end up working slightly differently.

    Q: Will you continue working on the base game or story?
    A: No. However, this would allow other people to continue to work on the game and create content without the need for Adobe Flash, recompiling the game, or having to distribute multiple copies of the game for each change.

    Q: Is this compatible with the old source code files?
    A: No. Part of localization was to change the names of some properties in the '.fla' project files. The original '.as' files or new ones based it may not work correctly or at all.
```

```
Broad Overview of Changes:

    - Restructured the entire project layout.
    - Ongoing translation and formatting on almost every file, this has broken a lot of things.
    - Grafon (The rendering class) and its alternative version have been reduced to one class and heavily modified. (Status: Mostly Non-functional)
    - The MainMenu class has been heavily re-written. (Status: Functional)
    - Hardcoded XML files have been removed from the source code and are loaded at runtime via a new XMLBook class.
    - Res.as (The class responsible for text localization.) has been rewritten and simplified dramatically. (Status: Functional, Buggy)
    - Sounds have been unpacked from a '.swf' library. (Status: Unknowm Functionality)
```

```
Requirements to work on this project and compile:
    - Adobe Animate ("What be a pirate's favorite letter? Tis the C")
    - Fallout Equestria: Remains source code <https://drive.google.com/uc?id=1m8k_yV1zFC-KmQafSGHaCipeuAsEjqPr>
    - A programming environment like IntelliJ, Visual Studio, Notepad++, etc.
        Note: I currently use Visual Studio Code as it's the only IDE with support for ActionScript via the "ActionScript &MXML" and "AS3, MXML, and SWF Extenstion Pack" extensions.

Optional Tools:
    - Adobe Scout
        Good for performance debugging, but doesn't have as much detail when an error occurs as Adobe Animate.
```

```
New Folder Structure and File Decsriptions

    [src] - Main directory for the game
        [data] - Directory for extracted resources and compiled '.swf' resource libraries
            xmldata - XML files and previously hard-coded XML data. These are loaded into an array at runtime inside the XmlBook class.
            sound - .mp3 sound files previously contained in the 'sound.swf' library.
            music - .mp3 sound files
            rooms - Each '.xml' file is a level. The XML contains all possible rooms for that level.
        [components] - Classes for storing data about the game.
            Settings.as
            XmlBook.as
        [graphdata] - Classes for rendering the screen.
            BackObj.as
            BulletHoles.as
            CursorHander.as
            Displ.as - Class that handles the mainMenu background animation.
            Emitter.as
            Grafon.as - Renders the current room.
            GrLoader.as - Loads resources from '.swf.' libraries.
            Material.as
            Part.as
        [interdata] - Classes to handle the GUI.
            Appear.as - Player appearance
            Camera.as
            Ctr.as - Player movement controller
            GUI.as
            Keystates.as - Object to hold the state of all keypresses.
            PipBuck.as
            PipPage.as
            PipPageApp.as
            PipPageInfo.as
            PipPageInv.as
            PipPageMed.as
            PipPageOpt.as
            PipPageStat.as
            PipPageVault.as
            PipPageVend.as
            PipPageWork.as
            Sats.as
            SatsCel.as
            Stand.as
        [locdata] - Classes to handle items in the game. (Levels, Rooms, Tiles, etc.)
            Area.as
            Bonus.as
            Box.as
            CheckPoint.as
            Form.as
            Game.as
            Level.as
            LevelLoader.as
            LevelTemplate.as
            Loot.as
            Probation.as
            Quest.as
            Room.as
            RoomTemplate.as
            Tile.as
            Trap.as
        [roomdata] - ???
        [servdata] - Scripts
        [stubs] - These are used to reduce compiler errors and serve no other purpose. The actual classes are contained in the '.fla' files, however IDEs and Compilers other than Adobe Flash cannot see these linkages.
        [systems] - Classes for manipulating data (eg. Load XML files)
        [unitdata] - Classes for ingame units AND some other things (Armor, Coordinates, Effects, Inventory, Spells)
        [weapondata] - Classes for handling Weapons, Attacks, and Bullets.

        GameSession.as - Main class that holds everything needed for the game
        Main.as - Class reponsible for intitial loading screen and opening the MainMenu
        MainMenu.as - Class responsible for main menu functions and starting a new GameSession.
        Obj.as - Primitive class for objects.
        Pt.as - Primitive class for objects.
        Res.as - Class resposible for localizing text.
        Snd.as - Class resposible for playing sound and music.
```



```
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
=======

