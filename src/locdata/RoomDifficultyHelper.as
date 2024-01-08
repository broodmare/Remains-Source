package locdata 
{
    public class RoomDifficultyHelper
    {

        // Setting the difficulty level of the room based on the character's level and difficulty gradient
		public static function setRoomDifficulty(l:Level, room:Room, deep:Number):void
		{
            var level:Level = l;
            var template:LevelTemplate = level.levelTemplate;
            var difficulty:int = GameSession.currentSession.game.globalDif;

			var ml:Number = level.levelDifficultyLevel + deep;
			room.locDifLevel = ml;
			room.locksLevel = ml * 0.7;	    // level of locks
			room.mechLevel = ml / 4;		// level of mines and mechanisms
			room.weaponLevel = 1 + ml / 4;	// level of encountered weapons
			room.enemyLevel = ml;		    // level of enemies

			// influence of difficulty settings
			if (difficulty < 2) room.earMult *= 0.5;
			if (difficulty > 2) room.enemyLevel += (difficulty - 2) * 2;	// level of enemies based on difficulty

			// type of enemies
			if (template.biom == 0 && Math.random() < 0.25) room.tipEnemy = 1;
			if (room.tipEnemy < 0) room.tipEnemy = Math.floor(Math.random() * 3);
			if (template.biom == 1) room.tipEnemy = 0;
			if (template.biom == 2 && room.tipEnemy == 1 && Math.random() < ml / 20) room.tipEnemy = 3;	// slave traders
			if (template.biom == 3) 
			{
				room.tipEnemy = Math.floor(Math.random() * 3) + 3; // 4-mercenaries, 5-unicorns
			}
			if (ml > 12 && (template.biom == 0 || template.biom == 2 || template.biom == 3) && Math.random() < 0.1) room.tipEnemy = 6;	// zebras
			if (template.biom == 4) room.tipEnemy = 7;	// steel+robots
			if (template.biom == 5) 
			{
				if (Math.random() < 0.3) room.tipEnemy = 5;
				else room.tipEnemy = 8;	// pink
			}
			if (template.biom == 6) 
			{
				if (Math.random() > 0.3) room.tipEnemy = 9;	// enclave
				else room.tipEnemy = 10;// greyhounds
			}
			if (template.biom == 11) room.tipEnemy = 11; // enclave and greyhounds
			// number of enemies
			// type, minimum, maximum, random increase
			if (ml < 4) 
			{
				room.setUnitSpawnLimits(1, 3, 5, 2);
				room.setUnitSpawnLimits(2, 2, 4, 0);
				room.setUnitSpawnLimits(3, 3, 4, 2);
				room.setUnitSpawnLimits(4, 1, 2, 0);
				room.setUnitSpawnLimits(5, 1, 4, 2);
				if (room.tipEnemy == 6) room.setUnitSpawnLimits(2, 1, 3, 0);
				if (room.kolEnSpawn == 0) 
				{
					if (room.tipEnemy != 5) room.setUnitSpawnLimits(-1, 1, 2);
				}
				room.kolEnHid = 0;
			} 
			else if (ml < 10) 
			{
				room.setUnitSpawnLimits(1, 3, 6, 2);
				if (Math.random() < 0.15) room.setUnitSpawnLimits(2, 1, 1, 0);
				else if (room.tipEnemy == 6) room.setUnitSpawnLimits(2, 2, 3, 0);
				else room.setUnitSpawnLimits(2, 2, 5, 0);
				room.setUnitSpawnLimits(3, 3, 5, 2);
				room.setUnitSpawnLimits(4, 2, 3, 1);
				room.setUnitSpawnLimits(5, 2, 4, 2);
				if (room.kolEnSpawn == 0) 
				{
					if (room.tipEnemy != 5) room.setUnitSpawnLimits(-1, 2, 3);
				}
				room.kolEnHid = Math.floor(Math.random() * 3);
			} 
			else 
			{
				room.setUnitSpawnLimits(1, 4, 6, 2);
				if (Math.random() < 0.15) room.setUnitSpawnLimits(2, 1, 2, 0);
				else if (room.tipEnemy == 6) room.setUnitSpawnLimits(2, 3, 4, 0);
				else room.setUnitSpawnLimits(2, 3, 6, 0);
				room.setUnitSpawnLimits(3, 4, 7, 2);
				room.setUnitSpawnLimits(4, 2, 4, 1);
				room.setUnitSpawnLimits(5, 3, 6, 2);
				if (room.kolEnSpawn == 0) 
				{
					if (room.tipEnemy != 5) room.setUnitSpawnLimits(-1, 2, 4);
					else if (Math.random() > 0.4) room.setUnitSpawnLimits(-1, 1, 3);
				}
				room.kolEnHid = Math.floor(Math.random() * 4);
			}
			if (room.tipEnemy == 5 || room.tipEnemy == 10) 
			{
				room.setUnitSpawnLimits(2, 1, 3, 1);
			}
			if (template.biom == 11) 
			{
                room.setUnitSpawnLimits(2, 5, 8, 0);
			}
		}


    }
}