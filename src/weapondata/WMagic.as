package weapondata 
{
	
	import unitdata.Unit;
	import unitdata.UnitPlayer;
	import unitdata.Pers;
	
	import components.Settings;
	
	public class WMagic extends Weapon 
	{
		
		public function WMagic(own:Unit, nid:String, nvar:int=0) 
		{
			super(own,nid,nvar);
			if (prep) animated=false;
		}

		public override function attack(waitReady:Boolean=false):Boolean 
		{
			//trace('atk');
			if (!waitReady && !Settings.alicorn && !auto && t_auto>0) 
			{
				t_auto=3;
				return false;
			}
			skillConf=1;
			if (t_rel>0) return false;
			if (owner.player && (World.world.pers.spellsPoss==0 || alicorn && !Settings.alicorn)) 
			{
				World.world.gui.infoText('noSpells');
				World.world.gui.bulb(X,Y);
				Snd.ps('nomagic');
				return false;
			}
			if (owner.player && respect == 1)
			{
				World.world.gui.infoText('disSpell',null,null,false);
				Snd.ps('nomagic');
				return false;
			}
			if (owner.player) 
			{
				if (!checkAvail()) return false;
			}
			is_attack=true;
			if (t_prep < prep + 10) t_prep += 2;
			if (t_prep>=prep && t_attack<=0)
			{
				if (owner.player && dmana>World.world.pers.manaHP) 
				{
					t_rel = t_prep * 3;
					World.world.gui.infoText('noMana');
					World.world.gui.bulb(X,Y);
					Snd.ps('nomagic');
				} 
				else if (dmagic<=owner.mana || owner.mana>=owner.maxmana*0.99) 
				{
					if (dkol<=0) t_attack=rapid;
					else t_attack = rapid * (dkol + 1);
				} 
				else 
				{
					t_rel = t_prep * 3;
					if (owner.player) 
					{
						World.world.gui.infoText('noMana');
						World.world.gui.bulb(X,Y);
						Snd.ps('nomagic');
					}
				}
			}
			return true;
		}
		
		public override function setPers(gg:UnitPlayer, pers:Pers):void
		{
			super.setPers(gg,pers);
			dmana=mana*pers.allDManaMult*pers.warlockDManaMult;
			dmagic=magic*pers.allDManaMult*pers.warlockDManaMult;
			damMult*=pers.spellsDamMult;
		}
		
		//результирующий урон
		public override function resultDamage(dam0:Number, sk:Number=1):Number 
		{
			return (dam0+damAdd)*damMult*sk;
		}
		//результирующая дальность
		public override function resultPrec(pm:Number=1, sk:Number=1):Number 
		{
			return precision*precMult*pm;
		}
		protected override function shoot():Bullet 
		{
			if (super.shoot()) 
			{
				owner.mana-=dmagic;
				owner.dmana=0;
				if (owner.player) 
				{
					World.world.pers.manaDamage(dmana);
				}
			}
			return b;
		}
		
		public override function animate():void
		{
			
			if (!vis) return;
			vis.x=X;
			vis.y=Y;
			if (prep) 
			{
				if (t_prep>1) vis.gotoAndStop(t_prep);
				else vis.gotoAndStop(1);
			}
		}
	}
}
