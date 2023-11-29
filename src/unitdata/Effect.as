package unitdata 
{

	import flash.geom.ColorTransform;

	import graphdata.Emitter;
	
	import components.Settings;
	import components.XmlBook;
	
	public class Effect 
	{
		
		public var owner:Unit;
		public var id:String;
		public var tip:int=0;
		public var forever:Boolean=false;
		public var t:int=1;
		public var lvl:int=1;
		public var lvl1:int=0, lvl2:int=0, lvl3:int=0;					// Effect levels
		public var val:Number;
		public var player:Boolean=false;		// Effect applies to the player character
		public var params:Boolean=false;		// Effect modifies parameters
		public var add:Boolean=false;			// Effect duration is cumulative
		public var se:Boolean=true;				// Show message
		public var him:int=0;					// Effect caused by chemistry, 1-positive, 2-negative																					
		public var ad:Boolean=false;			// Dependency on chemistry
		public var post:String;

		//Setting these two public
		public var postBad:Boolean=false;
		public var del:Array;
		
		
		public var vse:Boolean=false;		//действие окончено

		public function Effect(nid:String, own:Unit=null, nval:Number=0) 
		{
			if (own==null) owner=World.world.gg;
			else owner=own;
			player=owner.player;
			id=nid;
			val=nval;
			getXmlParam();
		}
		
		public function getXmlParam():void
		{
			t=1;
			post=null;
			postBad=false;
			del=new Array();
			him=0;
			lvl=1;
			forever=false;
			var node:XMLList = XmlBook.getXML("effects").eff.(@id == id);
			if (node.length()) 
			{
				tip=node.@tip;
				t=node.@t*30;
				if (Settings.testEff) t=node.@t*3;
				if (val==0) val=node.@val;
				if (node.sk.length()) params=true;
				if (node.@post.length()) post=node.@post;
				if (node.@postbad.length()) 
				{
					post=node.@postbad;
					postBad=true;
				}
				if (node.@him.length()) him=node.@him;
				if (node.@lvl1.length()) lvl1=node.@lvl1;
				if (node.@lvl2.length()) lvl2=node.@lvl2;
				if (node.@lvl3.length()) lvl3=node.@lvl3;
				if (node.@add.length()) add=true;
				if (node.del.length()) 
				{
					for each(var ndel in node.del) del.push(ndel.@id);
				}
			}
			if (t==0) 
			{
				t=30;
				forever=true;
			}
		}
		
		public function setEff():void
		{
			if (del.length) 
			{
				for each(var ndel in del) 
				{
					for each(var eff:Effect in owner.effects) 
					{
						if (eff.id==ndel) 
						{
							eff.unsetEff(false,false,false);
							break;
						}
					}
				}
			}
			if (params) 
			{
				if (player) (owner as UnitPlayer).pers.setParameters();
				else owner.setEffParams();
			}
			if (id=='potion_fly' || id=='potion_shadow') 
			{
				owner.newPart('black',15);
			}
			if (id=='potion_shadow') 
			{
				if (player) 
				{
					(owner as UnitPlayer).uncallPet(true);
					(owner as UnitPlayer).changeWeapon('not');
				}
			}
			if (id=='potion_rat') 
			{
				if (player) (owner as UnitPlayer).ratOn();
			}
			if (id=='potion_infra') 
			{
				World.world.grafon.warShadow();
			}
			if (id=='reanim' && player) 
			{
				(owner as UnitPlayer).noReanim=true;
			}
			if (id=='stupor' && player) 
			{
				(owner as UnitPlayer).stam=0;
			}
			if (id=='fetter' && player) 
			{
				(owner as UnitPlayer).fetX=owner.X;
				(owner as UnitPlayer).fetY=owner.Y;
			}
			if (id=='stealth' || id=='stealth_armor') 
			{
				(owner as UnitPlayer).f_stealth=true;
				(owner as UnitPlayer).setFilters();
			}
			if (id=='bloodinv' && player) 
			{
				(owner as UnitPlayer).f_inv=true;
				(owner as UnitPlayer).setFilters();
				owner.newPart('blood',30);
			}
			if (id=='curse') World.world.game.triggers['curse']=1;
			visEff();
		}
		
		// Check the level of the effect
		public function checkT():void
		{
			if (lvl1>0) 
			{
				var plvl:int = lvl;
				lvl = 1;
				if (t / 30 > lvl1) lvl = 2;
				if (t / 30 > lvl2) lvl = 3;
				if (t / 30 > lvl3) lvl = 4;
				if (plvl != lvl && params) 
				{
					if (player) (owner as UnitPlayer).pers.setParameters();
					else owner.setEffParams();
				}
			}
		}
		
		public function visEff():void
		{
			if (id=='potion_shadow' && player) 
			{
				(owner as UnitPlayer).f_shad=true;
				(owner as UnitPlayer).setFilters();
			}
			if (id=='inhibitor') 
			{
				if (owner.vis.inh) 
				{
					owner.vis.inh.visible=true;
					owner.vis.inh.gotoAndPlay(1);
				}
			}
			if (id=='freezing') 
			{
				var freezTransform:ColorTransform=new ColorTransform(0.7,0.7,1,1,100,100,130);
				if (owner.cTransform) freezTransform.concat(owner.cTransform);
				owner.vis.transform.colorTransform=freezTransform;
			}
		}
		
		public function unsetEff(onPost:Boolean=true, inf:Boolean=true, setParam:Boolean=true):void 
		{
			if (id=='potion_rat') 
			{
				if ((owner as UnitPlayer).ratOff()) 
				{
					if ((owner as UnitPlayer).retPet!='') (owner as UnitPlayer).callPet((owner as UnitPlayer).retPet,true);
				} 
				else 
				{
					if (t<20) t=29;
					return;
				}
			}
			vse=true;
			if (player && inf && se) 
			{
				if (tip==3) World.world.gui.infoText('endFoodEffect',Res.txt('e',id));
				else World.world.gui.infoText('endEffect',Res.txt('e',id));
			}
			if (post && onPost) 		// Replacement of the effect with a post-effect
			{
					id=post;
					var isBad:Boolean=postBad;
					getXmlParam();
					if (isBad) 
					{
						var proc = World.world.pers.addictions[id];
						if (proc >= World.world.pers.ad1) 
						{
							forever = true;
							ad = true;
						}
						if (proc>=World.world.pers.ad2) lvl=2;
						if (proc>=World.world.pers.ad3) lvl=3;
					}
					vse=false;
			}
			if (params && setParam) 
			{
				if (player) (owner as UnitPlayer).pers.setParameters();
				else owner.setEffParams();
			}
			if (id=='stealth' || id=='stealth_armor') 
			{
				(owner as UnitPlayer).f_stealth=false;
				(owner as UnitPlayer).setFilters();
			}
			if (id=='potion_fly') 
			{
				owner.isFly=false;
				owner.newPart('black',15);
			}
			if (id=='potion_shadow' && player) 
			{
				(owner as UnitPlayer).f_shad=false;
				(owner as UnitPlayer).f_stealth=false;
				(owner as UnitPlayer).setFilters();
				if ((owner as UnitPlayer).retPet!='') (owner as UnitPlayer).callPet((owner as UnitPlayer).retPet,true);
			}
			if (id=='potion_infra') 
			{
				World.world.grafon.warShadow();
			}
			if (id=='reanim' && player) 
			{
				(owner as UnitPlayer).noReanim=false;
			}
			if (id=='inhibitor') 
			{
				if (owner.vis.inh) owner.vis.inh.visible=false;
			}
			if (id=='freezing') 
			{
				if (owner.cTransform) owner.vis.transform.colorTransform=owner.cTransform;
				else owner.vis.transform.colorTransform=new ColorTransform();
			}
			if (id=='sacrifice' && player) 
			{
				(owner as UnitPlayer).noReanim=false;
			}
			if (id=='bloodinv' && player) 
			{
				(owner as UnitPlayer).f_inv=false;
				(owner as UnitPlayer).setFilters();
			}
		}
		
		public function secEffect():void
		{
			checkT();
			if (id == 'burning') 
			{
				if (owner.isPlav) t = 1;
				else 
				{
					owner.damage(val, Unit.D_FIRE,null,true);
					owner.shok=33;
				}
			}
			if (id == 'pinkcloud') 
			{
				owner.damage(val,Unit.D_PINK,null,true);
			}
			if (id == 'blindness' && player) 
			{
				if (owner.sost<4) Emitter.emit('blind',owner.room,owner.X-300+Math.random()*600,owner.Y-200+Math.random()*400);
			}
			if (id == 'chemburn') 
			{
				owner.damage(val,Unit.D_ACID,null,true);
			}
			if (id == 'drunk' && lvl>3) 
			{
				owner.damage(val,Unit.D_POISON,null,true);
				Emitter.emit('poison',owner.room,owner.X+owner.storona*20,owner.Y-40);
			}
			if (id == 'namok') 
			{
				if (!owner.isPlav && owner.sost < 4) Emitter.emit('kap',owner.room,owner.X,owner.Y-owner.scY*0.25,{md:0.1});
			}
			if (id == 'hydra' && owner.sost==1) 
			{
				owner.heal(val);
				if (owner.player) 
				{
					owner.heal(val/2, 3, false);
					(owner as UnitPlayer).pers.heal(val,4);
					(owner as UnitPlayer).pers.heal(val,5);
				}
			}
			if (id == 'inhibitor') 
			{
				for each (var un:Unit in owner.room.units) 
				{
					if (owner.isMeet(un) && un.fraction != owner.fraction && un.rasst2 < val * val) un.slow = 40;
				}
			}
			if (id == 'fetter') 
			{
				Emitter.emit('slow', owner.room, (owner as UnitPlayer).fetX, (owner as UnitPlayer).fetY);
			}
		}

		public function stepEffect():void
		{
			if (id == 'burning') 
			{
				if (owner.sost<4) Emitter.emit('flame', owner.room, owner.X, owner.Y - owner.scY / 2);
			}
			if (id == 'sacrifice' && t == 5) 
			{
				owner.damage(owner.maxhp * 0.5, Unit.D_INSIDE);
				owner.newPart('blood', 50);
			}
		}
		
		public function step():void
		{
			if (t%30 == 0) 
			{
				secEffect();
			}
			stepEffect();
			t--; 
			if (t <= 0) 
			{
				if (forever) t = 30;
				else 
				{
					unsetEff();
				}
			}
		}
	}
}
