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
			if (GameSession.currentSession.game) {
				GameSession.currentSession.game.triggers['frag_'+id]=0;
			}
		}
		
		public override function expl():void
		{
			newPart('green_spark',25);
		}

		public override function animate():void
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
				var pet:UnitPet=GameSession.currentSession.gg.pets['phoenix'];
				GameSession.currentSession.gg.callPet('phoenix');
				pet.oduplenie=0;
				pet.setPos(X,Y);
			}
		}
		
		public override function setNull(f:Boolean=false):void
		{
			if (GameSession.currentSession.game.triggers['tame']>=5) die();
		}
		
		public function tame():void
		{
			if (!questOk) GameSession.currentSession.game.addQuest('tamePhoenix');
			storona=(X>GameSession.currentSession.gg.X)?-1:1;
			if (GameSession.currentSession.invent.items['radcookie'].kol>0) {
				GameSession.currentSession.game.incQuests('tame_ph');
				GameSession.currentSession.invent.minusItem('radcookie');
				if (GameSession.currentSession.game.triggers['tame']) GameSession.currentSession.game.triggers['tame']++;
				else GameSession.currentSession.game.triggers['tame']=1;
				if (GameSession.currentSession.game.triggers['tame']>=5 && !GameSession.currentSession.game.triggers['pet_phoenix']) {	//приручить
					if (GameSession.currentSession.game.runScript('tamePhoenix',this)) GameSession.currentSession.game.triggers['pet_phoenix']=1;

				} else {
					die();
					GameSession.currentSession.gui.messText('phoenixFeed2','',Y<300);
				}
			} else {
				GameSession.currentSession.gui.messText('phoenixFeed1','',Y<300);
			}
			if (GameSession.currentSession.game) {
				GameSession.currentSession.game.triggers['frag_'+id]=0;
			}
		}
		
		public override function control():void
		{
			if (!stay) t_fall++;
			if (t_fall>=3 || dx>1 || dx<-1) die();
			if (!questOk && room.celObj==this) {
				GameSession.currentSession.game.triggers['frag_'+id]=0;
				GameSession.currentSession.game.addQuest('tamePhoenix');
				questOk=true;
			}
		}

	}
	
}
