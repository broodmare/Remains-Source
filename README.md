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
    - Adobe Animate
    - Fallout Equestria: Remains source code
    - A programming environment like JStudio, Visual Studio, Notepad++, etc.
        Note: I currently use Visual Studio Code as it's the only IDE with support for ActionScript via third party extensions.

Optional Tools:
    - Adobe Scout
        Good for performance debugging, but doesn't have as much detail when an error occurs as Adobe Animate.
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

