package weapondata  
{
	import flash.display.MovieClip;
	
	import unitdata.Unit;
	import unitdata.UnitPlayer;
	import unitdata.Pers;
	import locdata.Tile;
	
	import components.Settings;
	import components.XmlBook;
	
	import stubs.visVzz;

	public class WClub extends Weapon 
	{
		//setting to public 
		public var anim:Number=0;
		public var rapid_act:Number=10;	//актуальная скорость атаки
		public var sin0:Number,cos0:Number,sin1:Number,cos1:Number,sin2:Number,cos2:Number;
		public var vzz:Array;
		public var kolvzz:int=0;
		public var visvzz:MovieClip;	//шлейф за оружием
		public var stepdlina:int=10;
		public var del:Object={x:0, y:0};
		public var lasM:Boolean=false;
		public var mtip:int=0;		//тип холодного оружия
		
		public var powerMult:Number=1;
		public var curDam:Number=0;
		public var combo:int=0;
		public var t_combo:int=0;
		public var sndPl:Boolean=false;
		
		public var blumR:Number=0;
		public var plX:Number=0, plY:Number=0;
		public var atDlina:Number=100;
		public var celRX:Number=0, celRY:Number=0;

		public var celX:Number, celY:Number;
		public var meleeR:Number=1;	//радиус действия телекинеза
		public var levitRun:Number=10;	//скорость перемещения телекинезом
		
		public var rapidMult:Number=1;
		//end of set to public 


		public var quakeX:Number=0;
		public var quakeY:Number=0;
		
		public var powerfull:Boolean=false;	//можно усиливать удар
		public var combinat:Boolean=false;	//каждый 4й удар усиленный

		public function WClub(own:Unit, id:String, nvar:int=0)
		{
			var node:XML = XmlBook.getXML("weapons").weapon.(@id == id)[0];
			if (node.vis[0].@lasm>0) lasM=true;
			if (!lasM) 
			{
				visvzz=new visVzz();
			} 
			else 
			{
				visvzz=new MovieClip() 
			}
			visvzz.visible=false;
			visvzz.stop();
			super(own,id,nvar);
			vis.stop();
			speed=15;
			satsMelee=noTrass=true;
			if (node.@mtip.length()) mtip=node.@mtip;
			if (node.phis[0].@long>0) dlina=node.phis[0].@long;
			if (node.phis[0].@minlong>0) mindlina=node.phis[0].@minlong;
			else mindlina=dlina;
			if (node.char[0].@pow.length()) powerfull=true;
			if (node.char[0].@combo.length()) combinat=true;
			visvzz.scaleX=visvzz.scaleY=dlina/100;
			visvzz.alpha=10/rapid;
			if (visvzz.alpha>1) visvzz.alpha=1;
			kolvzz=Math.round((dlina-mindlina)/stepdlina);
			vzz=[];
			storona=owner.storona;
			b=new Bullet(own,X-(dlina/2)*storona,Y-dlina,null,false);
			b.weap=this;
			b.tipBullet=1;
			setBullet(b);
			b.knockx=storona;
			b.knocky=-0.2;
			b.liv=10;
			b.probiv=0.75;
			b.dx=b.dy=b.vel=0;
			if (node.@crack.length()) b.crack=node.@crack;
			checkLine=true;
			b.checkLine=checkLine;
			rot=-Math.PI/2-(Math.PI/6)*storona;
			cos0=Math.cos(rot);
			sin0=Math.sin(rot);
			for (var i:int = 0; i<=kolvzz; i++) 
			{
				var nx:int = X+cos2*(mindlina+i*stepdlina)+anim*storona*(mindlina+i*stepdlina);
				var ny:int = Y+sin2*(mindlina+i*stepdlina);
				vzz[i]={X:0,Y:0};
			}
			if (!auto && !powerfull)combinat=true;
		}
		
		public override function addVisual():void
		{
			super.addVisual();
			if (visvzz) GameSession.currentSession.grafon.canvasLayerArray[layer].addChild(visvzz);
		}

		public override function remVisual():void
		{
			super.remVisual();
			if (visvzz && visvzz.parent) visvzz.parent.removeChild(visvzz);
		}

		public override function setPers(gg:UnitPlayer, pers:Pers):void
		{
			super.setPers(gg,pers);
			rapidMult=1/pers.meleeSpdMult;
			damMult*=pers.meleeDamMult;
		}
		
		public function lineCel():int 
		{
			var res:int =0;
			var bx:Number=owner.X;
			var by:Number=owner.Y-owner.scY*0.75;
			var ndx:Number=(celX-bx);
			var ndy:Number=(celY-by);
			var div:Number =Math.floor(Math.max(Math.abs(ndx),Math.abs(ndy))/Settings.maxdelta)+1;
			for (var i:int =1; i<div; i++) 
			{
				celX=bx+ndx*i/div;
				celY=by+ndy*i/div;
				var t:Tile=GameSession.currentSession.room.getAbsTile(Math.floor(celX),Math.floor(celY));
				if (t.phis==1 && celX>=t.phX1 && celX<=t.phX2 && celY>=t.phY1 && celY<=t.phY2) 
				{
					return 0
				}
			}
			return 1;
		}
		
		public override function actions():void
		{
			var ds:int =40*owner.storona;
			meleeR=GameSession.currentSession.pers.meleeR;
			if (room && room.sky) meleeR*=10;
			if (owner.player) 
			{
				levitRun=(owner as UnitPlayer).pers.meleeRun;
				if (room.sky) levitRun*=4;
				if (mtip==0) 
				{
					celX=owner.celX-dlina*0.8*storona;
					celY=owner.celY+dlina*0.3;
					lineCel();
					storona=(owner.celX>owner.X-100*owner.storona)?1:-1;
					del.x=(celX-(owner.X+ds));
					del.y=(celY-owner.weaponY);
					norma(del,meleeR);
					ds=(owner as UnitPlayer).pers.meleeS*owner.storona;
				} 
				else 
				{
					if (mtip==2 || t_attack<=0) 
					{
						celRX=owner.celX;
						celRY=owner.celY;
					}
					celX=celRX;
					celY=celRY;
					if (mtip==2 || t_attack<=0) 
					{
						(owner as UnitPlayer).lineCel();
						celRX=owner.celX;
						celRY=owner.celY;
					}
					if (mtip==2) 
					{
						del.x=(celRX-(owner.X+ds));
						del.y=(celRY-owner.weaponY);
						norma(del,dlina-(dlina-mindlina)/2);
						celRX-=del.x;
						celRY-=del.y;
					}
					storona=(celRX>owner.X)?1:-1;
					del.x=(celRX-(owner.X+ds));
					del.y=(celRY-owner.weaponY);
					norma(del,meleeR);
					ds=(owner as UnitPlayer).pers.meleeS*owner.storona;
				}
			} 
			else 
			{
				if (mtip==0) 
				{
					celX=owner.celX-dlina*0.8*storona;
					celY=owner.celY+dlina*0.3;
				} 
				else 
				{
					celX=owner.celX;
					celY=owner.celY;
				}
				storona=owner.storona;
				ready=true;
			}
			if (krep>0 || !X) 
			{
				X=owner.weaponX;
				Y=owner.weaponY;
				ready=true;
			} 
			else 
			{
				var tx:int=celX-X;
				var ty:int=celY-Y;
				if (mtip!=0) 
				{
					tx=celRX-X;
					ty=celRY-Y;
				}
				ready=((tx*tx+ty*ty)<100);			//вот тут баг с копьями
				del.x=((owner.X+ds+del.x)-X)/2;
				del.y=((owner.weaponY+del.y)-Y)/2;
				if (owner.player) 
				{
					norma(del,Math.max(levitRun,1/massa));
				}
				blumR=(del.x*storona+del.y)/2;
				X+=del.x;
				Y+=del.y;
			}
			visvzz.visible=false;
			if (t_attack>0) 
			{
				var isPow:Boolean=false;
				if (powerfull && t_attack<rapid_act*5/6 && pow>2 && pow<rapid_act*2.15) 
				{
					//trace(Math.round(pow/(rapid_act*2.15)*100));
					anim=-1/4;
					if (mtip==1) quakeY=pow/(rapid_act*2.15)*30*(Math.random()-0.5);
					else quakeY=pow/(rapid_act*2.15)*30;
					powerMult=1+pow/(rapid_act*2.15);
					b.damage=curDam*powerMult;
					b.otbros=otbros*otbrosMult*powerMult;
					isPow=true;
					//усиление удара
				} 
				if (!isPow) 
				{
					if (t_attack==1)is_shoot=true;
					if (t_attack>=rapid_act*5/6) 
					{
						anim=-(rapid_act-t_attack)/rapid_act*1.5;
					} 
					else if (t_attack>=rapid_act/2 && t_attack<rapid_act*5/6) 
					{
						anim=-1/4+((rapid_act-t_attack)/rapid_act-1/6)*3.75;
					} 
					else 
					{
						anim=t_attack*2/rapid_act;
					}
				}
				if (mtip==0) 
				{
					rot=-Math.PI/2+(-Math.PI/6+anim*Math.PI)*storona;
					if (t_attack>=rapid_act/2 && t_attack<rapid_act*5/6) 
					{
						if (!isPow) 
						{
							visvzz.visible=true;
							if (powerMult>1.5) 
							{
								visvzz.alpha=1;
								visvzz.gotoAndStop(2);
							} 
							else 
							{
								visvzz.alpha=Math.min(10/rapid_act,1);
								visvzz.gotoAndStop(1);
							}
						}
						cos2=Math.cos(rot);
						sin2=Math.sin(rot);
						for (var i:int=0; i<=kolvzz; i++) 
						{
							var nx:int=X+cos2*(mindlina+i*stepdlina);
							var ny:int=Y+sin2*(mindlina+i*stepdlina);
							if (!isPow) b.bindMove(nx,ny, vzz[i].X, vzz[i].Y);
							vzz[i].X=nx;
							vzz[i].Y=ny;
						}
						if (lasM) vis.gotoAndStop(3);
						if (!isPow && sndShoot!='' && !sndPl) 
						{
							Snd.ps(sndShoot,X,Y,0,Math.random()*0.5+0.5);
							sndPl=true;
						}
					} 
					else 
					{
						if (lasM) vis.gotoAndStop(2);
						sndPl=false;
					}
				} 
				else if (mtip==1) 
				{
					rot=Math.atan2(celY-(owner.Y-owner.scY/2),celX-owner.X);
					cos2=Math.cos(rot);
					sin2=Math.sin(rot);
					plX=cos2*anim*atDlina;
					plY=sin2*anim*atDlina;
					if (t_attack>=rapid_act/2 && t_attack<rapid_act*5/6) 
					{
						nx=X+cos2*dlina+plX;
						ny=Y+sin2*dlina+plY;
						if (!isPow) b.bindMove(nx,ny, vzz[0].X, vzz[0].Y);
						vzz[0].X=nx;
						vzz[0].Y=ny;
						if (lasM) vis.gotoAndStop(3);
						if (!isPow && sndShoot!='' && !sndPl) 
						{
							Snd.ps(sndShoot,X,Y,0,Math.random()*0.5+0.5);
							sndPl=true;
						}
					} 
					else 
					{
						if (lasM) vis.gotoAndStop(2);
						sndPl=false;
					}
				} 
				else if (mtip==2) 
				{
					rot=Math.atan2(celY-(owner.Y-owner.scY/2),celX-owner.X);
					cos2=Math.cos(rot);
					sin2=Math.sin(rot);
					if (t_attack==1) 
					{
						cos2=Math.cos(rot);
						sin2=Math.sin(rot);
						b.bindMove(X+cos2*mindlina, Y+sin2*mindlina, X+cos2*dlina, Y+sin2*dlina);
						if (lasM) vis.gotoAndStop(3);
						if (sndShoot!='' && !sndPl) 
						{
							Snd.ps(sndShoot,X,Y,0,Math.random()*0.5+0.5);
							sndPl=true;
						}
					} 
					else 
					{
						if (lasM) vis.gotoAndStop(2);
						sndPl=false;
					}
				}
				if (!isPow) t_attack--;
			
			} 
			else 
			{
				if (lasM) vis.gotoAndStop(1);
				sin1=sin2=sin0; cos1=cos2=cos0;
				if (mtip==0) 
				{
					rot=-Math.PI/2-Math.PI/6*storona;
				} 
				else 
				{
					rot=Math.atan2(celY-(owner.Y-owner.scY/2),celX-owner.X);
				}
			}
			if (sndPrep!='') 
			{
				if (!is_pattack && is_attack) 
				{
					sndCh=Snd.ps(sndPrep,X,Y,t_prep*30);
				}	//звук раскрутки
				if (is_attack && sndCh!=null && sndCh.position>snd_t_prep2-300) 
				{
					sndCh.stop();
					sndCh=Snd.ps(sndPrep,X,Y,snd_t_prep1+200);
				}//	звук продолжения
				if (is_pattack && !is_attack && t_prep>0 && sndCh!=null && sndCh.position<snd_t_prep2-400)	
				{
					sndCh.stop();
					sndCh=Snd.ps(sndPrep,X,Y,snd_t_prep2+100);
				}	//звук остановки
			}
			if (recharg && hold<holder && t_attack==0) 
			{
				t_rech--;
				if (t_rech<=0) 
				{
					hold++;
					t_rech=recharg;
				}
			}
			if (t_auto>0) 
			{
				t_auto--;
			} 
			else pow=0;
			if (t_combo>0) 
			{
				t_combo--;
			} 
			else combo=0;
			if (t_attack==0 && t_reload>0) t_reload--;
			if (t_reload==Math.round(10*reloadMult)) reloadWeapon();
			is_pattack=is_attack;
			is_attack=false;
		}
		protected override function shoot():Bullet 
		{
			var sk:int=1;
			if (owner) 
			{
				sk=owner.weaponSkill;
				if (owner.player) sk=weaponSkill;
			}
			if (hp<maxhp/2) breaking=(maxhp-hp)/maxhp*2-1;
			else breaking=0;
			b.off=false;
			b.room=owner.room;
			b.knockx=storona;
			curDam=resultDamage(damage,sk);
			b.damage=curDam*ammoDamage;
			b.otbros=otbros*otbrosMult;
			b.dist=0;
			b.tilehit=false;
			b.parr=null;
			b.partEmit=true;
			if (mtip==0) 
			{
				sin2=sin0; cos2=cos0;
				for (var i:int = 0; i <= kolvzz; i++) 
				{
					vzz[i].X=X+cos2*(mindlina+i*stepdlina);
					vzz[i].Y=Y+sin2*(mindlina+i*stepdlina);
				}
			} 
			else 
			{
				cos2=Math.cos(rot);
				sin2=Math.sin(rot);
				vzz[0].X=X+cos2*(dlina-0.25*atDlina);
				vzz[0].Y=Y+sin2*(dlina-0.25*atDlina);
			}
			b.X=X+cos2*dlina;
			b.Y=Y+sin2*dlina;
			b.inWater=0;
			if (room.getAbsTile(b.X, b.Y).water>0) b.inWater=1;
			if (mtip==0) 
			{
				b.tilePixelWidth=Math.floor(owner.celX/Settings.tilePixelWidth);
				b.tilePixelHeight=Math.floor(owner.celY/Settings.tilePixelHeight);
			}
			if (mtip==2) 
			{
				quakeX=Math.random()*otbros;
				quakeY=Math.random()*otbros;
			}
			if (holder>0 && hold>0) 
			{
				hold-=rashod;
				if (owner.player && room.train && ammo!='recharg') GameSession.currentSession.invent.items[ammo].kol+=rashod;
			}
			t_auto=3;
			return b;
		}

		//результирующий урон
		public override function resultDamage(dam0:Number, sk:Number=1):Number 
		{
			return (dam0+damAdd)*damMult*sk*skillPlusDam*(1-breaking*0.6);
		}
		//результирующее время атаки
		public override function resultRapid(rap0:Number, sk:Number=1):Number 
		{
			if (mtip==2) return rap0/skillConf;
			return rap0/skillConf*rapidMult/owner.rapidMultCont;
		}
		
		protected override function weaponAttack():void
		{
			powerMult=1;
			if (t_attack<=0) 
			{
				setBullet(b);
				rapid_act=resultRapid(rapid);
				if (room.getAbsTile(X,Y).water) rapid_act*=2; 
				visvzz.alpha=Math.min(10/rapid_act,1);
				t_attack=rapid_act;
				shoot();
				if (combinat) {
					t_combo=rapid_act+20;
					combo++;
					if (combo>=4) {
						powerMult=2;
						b.damage=curDam*powerMult;
						b.otbros=otbros*otbrosMult*powerMult;
						combo=0;
					}
				}
			} 
			else if (t_attack>10) combo=0;
		}
		
		public override function crash(dam:int=1):void
		{
			if (owner.player) 
			{
				if (!room.train && !Settings.alicorn) hp-=dam+ammoHP;
				if (hp<0) hp=0;
				GameSession.currentSession.gui.setWeapon();
			}
			if (otbros>5) 
			{
				GameSession.currentSession.quake(otbros*b.dx/b.vel, otbros*b.dy/b.vel);
			}
			if (mtip==0 || mtip==1) 
			{
				quakeX=-otbros*b.dx/b.vel;
				quakeY=-otbros*b.dy/b.vel;
			} 
			else 
			{
				quakeX=Math.random()*otbros*2;
				quakeY=Math.random()*otbros*2;
			}
		}
		
		public override function animate():void
		{
			if (quakeX!=0) 
			{
				quakeX*=(Math.random()*0.3+0.5);
				if (quakeX<1 && quakeX>-1) quakeX=0;
			}
			if (quakeY!=0) 
			{
				quakeY*=(Math.random()*0.3+0.5);
				if (quakeY<1 && quakeY>-1) quakeY=0;
			}
			vis.y=Y+plY+quakeY;
			if (krep==0) 
			{
				vis.x=X+plX+quakeX;
				vis.scaleY=storona;
				vis.rotation=rot*180/Math.PI+blumR; 
				visvzz.x=vis.x;
				visvzz.y=vis.y;
				visvzz.rotation=vis.rotation;
				visvzz.scaleY=dlina/100*storona;
			} 
			else 
			{
				vis.x=X;
				vis.scaleY=owner.storona;
				vis.rotation=90*owner.storona-90+owner.weaponR*owner.storona;
			}
		}
	}
}
