package unitdata 
{

	import weapondata.Bullet;
	
	public class UnitPhoenix extends Unit 
	{
		
		var t_fall:int=0;
		//var tameScr:Script;
		static var questOk:Boolean=false;
		
		public function UnitPhoenix(cid:String=null, ndif:Number=100, xml:XML=null, loadObj:Object=null)
		{
			id='phoenix';
			getXmlParam();
			initBlit();
			animState='stay';
			activateTrap=0;
			showNumbs=false;
			doop=true;
			levitPoss=false;
			stay=true;
			inter.active=true;
			inter.action=100;
			inter.cont=null;
			inter.userAction='tame';
			inter.update();
			inter.t_action=30;
			inter.actFun=tame;
		}
		
		public override function damage(dam:Number, tip:int, bul:Bullet=null, tt:Boolean=false):Number
		{
			die();
			return 1;
		}
		
		public override function die(sposob:int=0):void
		{
			if (hpbar) hpbar.visible=false;
			expl();
			exterminate();
			runScript();
			if (World.world.game) {
				World.world.game.triggers['frag_'+id]=0;
			}
		}
		
		public override function expl()
		{
			newPart('green_spark',25);
		}

		public override function animate()
		{
			if (aiState==0) animState='stay';
			else animState='fly';
			if (animState!=animState2) {
				anims[animState].restart();
				animState2=animState;
			}
			if (!anims[animState].st) {
				blit(anims[animState].id,Math.floor(anims[animState].f));
			}
			anims[animState].step();
		}
		
		public override function command(com:String, val:String=null):void
		{
			if (com=='tame') {
				die();
				var pet:UnitPet=World.world.gg.pets['phoenix'];
				World.world.gg.callPet('phoenix');
				pet.oduplenie=0;
				pet.setPos(X,Y);
			}
		}
		
		public override function setNull(f:Boolean=false):void
		{
			if (World.world.game.triggers['tame']>=5) die();
		}
		
		function tame() {
			if (!questOk) World.world.game.addQuest('tamePhoenix');
			storona=(X>World.world.gg.X)?-1:1;
			if (World.world.invent.items['radcookie'].kol>0) {
				World.world.game.incQuests('tame_ph');
				World.world.invent.minusItem('radcookie');
				if (World.world.game.triggers['tame']) World.world.game.triggers['tame']++;
				else World.world.game.triggers['tame']=1;
				if (World.world.game.triggers['tame']>=5 && !World.world.game.triggers['pet_phoenix']) {	//приручить
					if (World.world.game.runScript('tamePhoenix',this)) World.world.game.triggers['pet_phoenix']=1;

				} else {
					die();
					World.world.gui.messText('phoenixFeed2','',Y<300);
				}
			} else {
				World.world.gui.messText('phoenixFeed1','',Y<300);
			}
			if (World.world.game) {
				World.world.game.triggers['frag_'+id]=0;
			}
		}
		
		public override function control()
		{
			if (!stay) t_fall++;
			if (t_fall>=3 || dx>1 || dx<-1) die();
			if (!questOk && room.celObj==this) {
				World.world.game.triggers['frag_'+id]=0;
				World.world.game.addQuest('tamePhoenix');
				questOk=true;
			}
		}

	}
	
}
