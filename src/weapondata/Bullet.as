package weapondata 
{
	
	import unitdata.Unit;
	import locdata.*;
	import graphdata.Emitter;
	import unitdata.UnitMsp;
	
	import components.Settings;
	
	import stubs.visualBullet;
	import stubs.visualRainbow;

	public class Bullet extends Obj
	{
		
		// Types of reactions to hitting a target
		// -1 - Miss, the bullet continues flying
		//  0 - Hit, the bullet disappears
		//  1 - Hit a solid surface (metal or stone)
		//  2 - Hit flesh
		//  3 - ? (Unknown)
		
		protected var vse:Boolean = false;
		
		public var owner:Unit;
		public var weap:Weapon;
		public var weapId:String;
		public var tipBullet:int = 0;	// Bullet type. 0 - regular, 1 - cold weapon
		public var rot:Number = 0, vel:Number = 15, liv:int = 100, begx:Number, begy:Number, knockx:Number, knocky:Number;
		public var ddy:Number = 0, ddx:Number = 0, accel:Number = 0, brakeR:Number = 0, vRot:Boolean = false;
		public var celX:Number = -100000;
		public var celY:Number = -100000;
		public var inWater:int = -1;
		public var isExpl:Boolean = false;
		
		public var partEmit:Boolean = true;	
		public var spring:int = 1;
		public var flame:int = 0;
		public var flare:String;
		public var outspace:Boolean = false;
		
		public var otbros:Number = 0; 
		public var probiv:Number = 0;
		public var parr:Array;
		
		public var babah:Boolean = false, tilehit:Boolean = false;
		public var off:Boolean = false;	//Disable damage to units
		public var checkLine:Boolean = false;	
		public var dist:Number = 0;
		
		public var destroy:Number = 0;	// Damage to blocks
		public var crack:int = 0;		// Container hacking
		//set public
		public var box:Box;
		public var tilePixelWidth:int  = -1;
		public var tilePixelHeight:int = -1;	// Damage to blocks for melee weapons (coordinates indicated by the cursor)
		public var damage:Number = 0;
		public var pier:Number = 0;		// Armor penetration
		public var armorMult:Number = 1;	// Armor modifier
		public var tipDamage:int = 0;
		public var tipDecal:int = 0;
		public var precision:Number = 0;	// Precision, indicates the distance at which the hit will be 100%, 0 if always hit
		public var antiprec:Number = 0;	// For sniper rifles, indicates the distance at which precision will begin to decrease
		public var miss:Number = 0;		// Probability of an unconditional miss
		public var desintegr:Number = 0;	// Probability of disintegration
		
		public var critCh:Number = 0;	// Critical chance
		public var critInvis:Number = 0;	// Critical chance for mobs without a target
		public var critDamMult:Number = 1;	// Critical damage multiplier
		public var critM:Number = 0;	// Additional critical
		
		public var explTip:int = 1;		// Explosion type, 1-normal, 2-gas cloud, 3-splatter
		public var explKol:int = 0;		// Number of explosions, 1s interval, 0 - instant explosion
		public var explPeriod:int = 10;
		public var damageExpl:Number = 0;	// Area damage
		public var explRadius:Number = 0;	// Explosion radius, if 0, then no explosion
		public var targetObj:Obj;		// Target object
		public var inWall:Boolean = false;
		//set public
		public var expl_t:int = 0;
		
		public var retDam:Boolean = false;	// Damage return


		public function Bullet(own:Unit, nx:Number, ny:Number, visClass:Class = null, addobj:Boolean = true) 
		{
			if (own == null) 
			{
				owner = new Unit();
				room = GameSession.currentSession.room;
			} 
			else 
			{
				owner = own;
				room = own.room;
			}
			X=begx = nx;
			Y=begy = ny;
			layer = 2;
			levitPoss = false;
			if (visClass) 
			{
				if (Settings.alicorn && own.player && visClass == visualBullet) visClass = visualRainbow;
				vis = new visClass();
				vis.stop();
				vis.x = X;
				vis.y = Y;
				vis.visible = false;
			}
			if (addobj) room.addObj(this);
		}
		
		public override function step():void
		{
			if (!babah) 
			{
				dy+=ddy;
				dx+=ddx;
				if (vRot) rot=Math.atan2(dy,dx);
				if (brakeR && dist>brakeR) 
				{
					vRot=true;
					dx*=0.9;
					dy*=0.9;
					vel*=0.9;
				}
				if (vRot) rot=Math.atan2(dy,dx);
				if (Math.abs(dx)<Settings.maxdelta && Math.abs(dy)<Settings.maxdelta)	run();
				else 
				{
					var div:Number =Math.floor(Math.max(Math.abs(dx),Math.abs(dy))/Settings.maxdelta)+1;
					for (var i:int=0; (i<div && !babah); i++) run(div);
				}
			}
			if (vis) 
			{
				vis.x=X;
				vis.y=Y;
				vis.rotation=rot*180/Math.PI;
				if (vis.laser && (spring>=2)) 
				{
					vis.laser.scaleX=Math.sqrt((X-begx)*(X-begx)+(Y-begy)*(Y-begy))/100;
				} 
				else if (spring==1 && vel>100) 
				{
					if (!babah) vis.scaleX=vel/100;
				} 
				else 
				{
					vis.scaleX=1;
				}
				vis.visible=true;
				if (liv<4 && vis.laser) 
				{
					vis.alpha=liv/4;
					if (weap) 
					{
						weap.getBulXY();
						vis.x=X+weap.bulX-begx;
						vis.y=Y+weap.bulY-begy;
					}
				}
			}
			if (expl_t>0) expl_t--;
			else liv--;
			if (expl_t>0 && expl_t%explPeriod==1) explRun();
			if (liv<=0 && !vse && explRadius>0) explosion();
			if (liv<=0 || room!=owner.room) 
			{
				vse=true;
			}
			if (vse) room.remObj(this);
		}
		
		public override function setNull(f:Boolean=false):void
		{
			room.remObj(this);
		}
		
		public override function err():String 
		{
			if (room) room.remObj(this);
			return 'Error bullet '+(owner?owner.objectName:'???')+' '+(weap?weap.objectName:'???');
		}
		
		public override function bindMove(nx:Number, ny:Number, ox:Number = -1, oy:Number = -1):void
		{
			if (ox >= 0) X = ox;
			if (oy >= 0) Y = oy;
			dx = nx - X;
			dy = ny - Y;
			vel=Math.sqrt(dx*dx+dy*dy);
			if (Math.abs(dx)<Settings.maxdelta && Math.abs(dy)<Settings.maxdelta) run();
			else 
			{
				var div:Number = Math.floor(Math.max(Math.abs(dx),Math.abs(dy)) / Settings.maxdelta)+1;
				for (var i:int = 0; i<div; i++) run(div);
			}
		}
		
		//возвращает собственную вероятность пули на попадание, в зависимости от пройденного расстояния и меткости
		public function accuracy():Number 
		{
			if (precision == 0) return 1;
			if (antiprec > 0 && dist < antiprec) return dist / antiprec * 0.75 + 0.25;
			return precision / dist;
		}
		
		// The bullet has hit the target
		// The target.udarBullet returns the result 'res'
		// -1 - Miss
		public function popadalo(res:int = 0):void
		{
			if (res < 0) return;			//не попал
			if (explRadius) 
			{
				explosion();
				if (vis) vis.visible = false;
			} 
			else if (tipDecal > 0 && tipDecal <= 6)  //пуля или удар
			{
				if (res == 1 || res == 2 || res == 5 || res == 7) 	//попадание по металлу или бетону
				{	
					if (vis) vis.gotoAndPlay(2);
					var koliskr:int = Math.floor(Math.random() * 5 + damage / 5);
					if (Settings.alicorn) koliskr *= 0.2;
					if (koliskr > 20) koliskr = 20;
					Emitter.emit('iskr_bul', room, X, Y, {dx:-dx/vel*10, dy:-dy/vel*10, kol:koliskr});
					if (flare != null && flare != '') Emitter.emit(flare, room, X, Y);
				} 
				else if (res == 3 || res == 4) 	//попадание по мясу или дереву
				{
					if (vis && dist < vel) 
					{
						vis.scaleX = dist / 100;
					}
				} 
				else 
				{
					if (vis && dist<vel) vis.visible = false;
				}
			} 
			else if (flare != null && flare != '') 
			{
				if (res > 0) Emitter.emit(flare, room, X, Y);
			}
			if (liv > 4) liv = 4;
			babah = true;
		}
		
		// Returns false if the object is already in the list of objects that the bullet has already interacted with
		// If not, it adds it to the list and returns true
		public function udar(un):Boolean 
		{
			if (parr == null) 
			{
				parr = new Array(un);
				return true;
			} 
			else 
			{
				for (var j in parr) 
				{
					if (parr[j] == un) return false;
				}
				parr.push(un);
				return true;
			}
		}
		

		public function run(div:int = 1):void
		{
			dist += vel / div;
			X += dx / div;
			Y += dy / div;
			if (room.sky) 
			{
				if (X < 0 || X >= room.roomPixelWidth || Y < 0 || Y >= room.roomPixelHeight) popadalo(0);
			} 
			else 
			{
				if (!outspace && X <0 || X >= room.roomWidth * Tile.tilePixelWidth || Y<0 || Y >= room.roomHeight * Tile.tilePixelHeight) popadalo(0);
				var t:Tile = room.getAbsTile(X,Y);
				if (t.water > 0) 
				{
					if (inWater == 0) 
					{
						if (partEmit && (tipDamage == Unit.D_BUL || tipDamage == Unit.D_PHIS || tipDamage == Unit.D_BLADE)) 
						{
							Emitter.emit('kap',room,X,Y,{dx:-dx/vel*10, dy:-dy/vel*10, kol:Math.floor(Math.random()*5+damage/5)});
							sound(11);
							partEmit = false;
						}
					}
					if (tipDamage == Unit.D_FIRE || tipDamage == Unit.D_LASER || tipDamage == Unit.D_PLASMA || tipDamage == Unit.D_SPARK || tipDamage == Unit.D_ACID) 
					{
						if (partEmit) 
						{
							Emitter.emit('steam', room, X, Y);
							partEmit = false;
						}
						popadalo(0);
					}
					inWater = 1;
				} 
				else 
				{
					if (inWater == 1) 
					{
						if (partEmit && (tipDamage == Unit.D_BUL || tipDamage == Unit.D_PHIS || tipDamage == Unit.D_BLADE)) 
						{
							Emitter.emit('kap',room,X,Y,{dx:dx/vel*10, dy:dy/vel*10, kol:Math.floor(Math.random()*5+damage/5)});
							sound(11);
							partEmit = false;
						}
					}
					inWater = 0;
				}
				if (!tilehit && (tilePixelWidth<0 || Math.floor(X/Settings.tilePixelWidth)==tilePixelWidth && Math.floor(Y/Settings.tilePixelHeight)==tilePixelHeight) && (t.phis==1 || t.phis==2 && Math.floor(X/Settings.tilePixelWidth)==tilePixelWidth && Math.floor(Y/Settings.tilePixelHeight)==tilePixelHeight) && X>=t.phX1 && X<=t.phX2 && Y>=t.phY1 && Y<=t.phY2) 
				{
					if (!inWall) 
					{
						popadalo(t.tileMaterial);
						sound(t.tileMaterial);
						if (weap) weap.crash();
						owner.crash(this);
						if (explRadius == 0) 
						{
							room.hitTile(t,destroy,X,Y,tipDecal);
							//trace('hitTile',destroy);
						}
						tilehit = true;
					}
				} 
				else 
				{
					inWall = false;
				}
			}

			if (off) return;
			for each(var un:Unit in room.units) 
			{
				if (targetObj) 
				{
					if (targetObj is Unit) un=targetObj as Unit;
					else break;
				}
				if (un.sost == 4 || un.disabled || un.trigDis || un.room != room) continue;
				if ((targetObj || un.fraction != owner.fraction) && X >= un.X1 && X <= un.X2 && Y >= un.Y1 && Y <= un.Y2) 
				{
					if (checkLine && weap && !weap.isLine(X, Y)) 	// Check if reachable to the object
					{
						off = true;
						return;
					}
					if (un.dopTestOn) 
					{
						if (!un.dopTest(this)) continue;
					}
					if (udar(un)) // If this bullet has not interacted with this object yet
					{ 
						var res:int = un.udarBullet(this); // Hit the object and check if the object dodged
						sound(res);
						if (probiv > 0 && damage > 0) 	// If the bullet is penetrative, let it continue flying
						{

						} 
						else 	// If not, destroy the bullet
						{	
							if (res >= 0) 
							{
								popadalo(res);
								if (weap) 
								{
									if ((un is unitdata.Mine || un is unitdata.UnitMsp) && un.sost > 2) weap.crash(15);
									else if (un.tipDamage == Unit.D_ACID) weap.crash(3);
									else weap.crash();
								}
								break;
							}
						}
					}
				}
				if (targetObj) break;
			}
			if (room.celObj && (room.celObj is Box) && crack && owner && owner.player) // Hack a container
			{
				box = room.celObj as Box;
				if (X >= box.X1 && X <= box.X2 && Y >= box.Y1 && Y <= box.Y2 && udar(box)) 
				{
					res = box.udarBullet(this, 1);
					sound(res);
					if (res >= 0) 
					{
						popadalo(res);
						if (weap) weap.crash();
					}
					if (box.dead && weap) weap.crash(box.montdam);
				}
			}
			if (GameSession.currentSession.gg.room == room && GameSession.currentSession.gg.teleObj && (GameSession.currentSession.gg.teleObj is Box) && owner != GameSession.currentSession.gg) 
			{
				box = GameSession.currentSession.gg.teleObj as Box;
				if (X >= box.X1 && X <= box.X2 && Y >= box.Y1 && Y <= box.Y2 && udar(box)) 
				{
					res = box.udarBullet(this, 0);
					sound(res);
					if (res >= 0) 
					{
						popadalo(res);
					}
				}
			}
			if (celX > -10000 && celY > -10000 && explRadius > 0) 
			{
				if (Math.abs(celX - X) < 50 && Math.abs(celY - Y) < 200 && Math.random() < 0.3) popadalo(100);
			}

			
		}
		
		public function sound(res:int):void
		{
			if (weap && weap.sndHit != '') 
			{
				Snd.ps(weap.sndHit, X, Y);
			}
			if (tipDecal <= 0 || tipDecal > 6) return;
			if (Snd.t_hit <= 0) 
			{
				if (res == 1) Snd.ps('hit_metal', X, Y, 0, 0.4);
				if (res == 2 || res == 4 || res == 6) Snd.ps('hit_concrete', X, Y, 0, 0.5);
				if (res == 3) Snd.ps('hit_wood', X, Y, 0, 0.5);
				if (res == 5) Snd.ps('hit_glass', X, Y, 0, 0.5);
				if (res == 7) Snd.ps('hit_pole', X, Y, 0, 0.5);
				if (res == 10) 
				{
					if (tipDamage == Unit.D_BUL) Snd.ps('hit_bullet', X, Y, 0, 0.8);
					else if (tipDamage == Unit.D_BLADE) Snd.ps('hit_blade', X, Y, 0, 0.8);
					else Snd.ps('hit_flesh', X, Y, 0, 0.5);		//удары по мясу
				}
				if (res == 11) Snd.ps('hit_water', X, Y, 0, 0.5);
				if (res == 12) Snd.ps('hit_slime', X, Y, 0, 0.5);		//удары по слизи
				Snd.t_hit = Math.random() * 3 + 3;
			}
		}
		
		//запустить процесс взрыва
		public function explosion():void
		{
			if (isExpl) return;
			var t:Tile = room.getAbsTile(X, Y);
			inWall = false;
			isExpl = true;
			levitPoss = false;
			if (t && t.phis && X >= t.phX1 && X <= t.phX2 && Y >= t.phY1 && Y <= t.phY2) inWall = true;
			if (targetObj && destroy > 0 && (targetObj is Box))  (targetObj as Box).damage(destroy);
			if (explKol <= 0) 
			{
				explRun();
			} 
			else 
			{
				explRun();
				expl_t = (explKol - 1) * explPeriod;
			}
		}
		
		//выполнить искусственный взрыв
		public function iExpl(ndamage:Number, ndestroy:Number, nradius:Number):void
		{
			room = owner.room;
			tipDamage = Unit.D_EXPL;
			otbros = 10;
			damageExpl = ndamage;
			destroy = ndestroy;
			explRadius = nradius;
			explosion();
		}
		
		//выполнять процесс взрыва
		public function explRun():void
		{
			if (destroy > 0) explDestroy();
			if (explTip == 1 || explTip == 3 && expl_t == 0) explBlast();	
			if (explTip == 2 || explTip == 3 && expl_t > 0)	 explGas();
			explVis();
		}
		
		
		//поражение всех стен в радиусе
		public function explDestroy():void
		{
			for (var i:Number = Math.floor((X - explRadius) / Tile.tilePixelWidth); i <= Math.floor((X + explRadius) / Tile.tilePixelWidth); i++) 
			{
				for (var j:Number = Math.floor((Y - explRadius) / Tile.tilePixelHeight); j <= Math.floor((Y + explRadius) / Tile.tilePixelHeight); j++) 
				{
					var tx:Number = X - (i + 0.5) * Tile.tilePixelWidth;
					var ty:Number = Y - (j + 0.5) * Tile.tilePixelHeight;
					var ter:Number = tx * tx + ty * ty;
					if (ter < explRadius * explRadius) room.hitTile(room.getTile(i, j), destroy, (i + 0.5) * Tile.tilePixelWidth, (j + 0.5) * Tile.tilePixelHeight, tipDecal);
				}
			}
		}
		
		//поражение всех юнитов, попавших в радиус, без отбрасывания и учёта стен
		public function explGas():void
		{
			for each(var un:Unit in room.units) 
			{
				if (un.sost==4 || un.invulner || un.disabled || un.trigDis || un.room!=room) continue;
				if (explTip==3 && !un.stay) continue; 
				var tx:Number = un.X-X;
				var ty:Number = un.Y-un.scY/2-Y;
				var rasst:Number = Math.sqrt(tx*tx+ty*ty);
				var dam:Number = damageExpl*(Math.random()*0.6+0.7);
				//дружественный огонь врагов
				if (weap && weap.owner.fraction == un.fraction && un.fraction != Unit.F_PLAYER) 
				{
					dam *= 0.25;
				}
				if (rasst<explRadius) 
				{
					if (rasst>explRadius*0.5) dam*=(2-rasst*2/explRadius);
					if (weap!=null) un.dieWeap=weap.id;
					if (weapId!=null) un.dieWeap=weapId;
					if (weap && weap.owner.fraction==Unit.F_PLAYER && un.player)  un.damage(dam*GameSession.currentSession.pers.autoExpl,tipDamage);
					else un.damage(dam,tipDamage);
				}
			}
		}
		
		// Damage all units with virtual fragments, taking into account wall protection
		public function explBlast():void
		{
			var tx:Number;
			var ty:Number;
			if (room!=owner.room) return;
			for each(var un:Unit in room.units) 
			{
				if (un.sost == 4 || un.invulner || un.disabled || un.trigDis || un.room!=room) continue;
				tx = un.X - X;
				ty = un.Y - un.scY / 2 - Y;
				var b:Bullet = explBullet(tx, ty, explRadius + un.scX);
				if (b) 
				{
					b.targetObj = un;
					// Friendly fire on enemies
					if (weap && weap.owner.fraction == un.fraction && un.fraction != Unit.F_PLAYER)
					{
						b.damage *= un.friendlyExpl;
					}
					// Fire on oneself
					if (un.player) 
					{
						if (weap && weap.owner.fraction == Unit.F_PLAYER) b.damage *= GameSession.currentSession.pers.autoExpl;
						var p={x:b.knockx, y:b.knocky};
						norma(p, 10);
						b.knockx = p.x;
						b.knocky = p.y;
					}
				}
			}
		}
		
		// Create a fragment
		public function explBullet(tx:Number, ty:Number, er:Number):Bullet 
		{
			var rasst:Number = Math.sqrt(tx*tx+ty*ty);
			var b:Bullet;
			if (rasst < er) 
			{
				b=new Bullet(owner,X,Y,null);
				b.inWall=inWall;
				b.vel=er*(1+rasst/er*4)/3;
				b.dx=tx/rasst*er/3;
				b.dy=ty/rasst*er/3;
				b.knockx=b.dx/b.vel;
				b.knocky=b.dy/b.vel;
				if (!room.levitOn) 
				{
					b.knockx=b.knocky=0;
				}
				b.damage=damageExpl;
				if (rasst>er*0.5) b.damage*=(2-rasst*2/er);
				b.otbros=otbros;
				b.pier=pier;
				b.weapId=weapId;
				b.tipDamage=tipDamage;
				b.precision=0;
				b.liv=3;
				b.weap=weap;
				b.critCh=critCh;
				b.critDamMult=critDamMult;
				b.critInvis=critInvis;
			}
			return b;
		}
		
		// Visual and sound effect of explosion
		public function explVis():void
		{
			if (weap && weap.visexpl) 
			{
				if (weap.visexpl=='sparkle') 
				{
					if (inWater>0) 
					{
						room.budilo(X,Y,700);
						Emitter.emit('explw',room,X,Y);
						Emitter.emit('bubble',room,X,Y,{kol:30, rx:100, ry:100, rdx:10, rdy:10});
						Snd.ps('expl_uw',X,Y);
					} 
					else 
					{
						room.budilo(X,Y,1500);
						Emitter.emit('expl',room,X,Y);
						Emitter.emit('sparkleexpl',room,X,Y);
						Emitter.emit('iskr',room,X,Y,{kol:16});
						Snd.ps('bale_e',X,Y);
					}
				} 
				else 
				{
					room.budilo(X,Y,500);
					Emitter.emit(weap.visexpl,room,X,Y);
				}
			} 
			else if (tipDamage==Unit.D_EMP) 
			{
				room.budilo(X,Y,500);
				Emitter.emit('impexpl',room,X,Y);
				Snd.ps('emp_e',X,Y);
			} 
			else if (tipDamage==Unit.D_CRIO) 
			{
				room.budilo(X,Y,500);
				Emitter.emit('iceexpl',room,X,Y);
				Emitter.emit('snow',room,X,Y,{kol:16});
				Snd.ps('cryo_e',X,Y);
			} 
			else if (tipDamage==Unit.D_PLASMA) 
			{
				room.budilo(X,Y,500);
				Emitter.emit('plaexpl',room,X,Y);
				Snd.ps('exppla_e',X,Y);
			} 
			else if (tipDamage==Unit.D_VENOM) 
			{
				Emitter.emit('gas',room,X,Y);
				if (expl_t==0) Snd.ps('gas_e',X,Y);
			} 
			else if (tipDamage==Unit.D_PINK) 
			{
				Emitter.emit('pinkgas',room,X,Y);
				if (expl_t==0) Snd.ps('gas_e',X,Y);
			} 
			else if (tipDamage==Unit.D_ACID) 
			{
				if (expl_t==0) 
				{
					Emitter.emit('acidexpl',room,X,Y);
					Emitter.emit('acidkap',room,X,Y, {kol:Math.floor(Math.random()*5+30)});
					Snd.ps('acid_e',X,Y);
					explLiquid('acid');
				} 
			} 
			else if (tipDamage==Unit.D_BALE) 
			{
				room.budilo(X,Y,3000);
				Emitter.emit('balefire',room,X,Y-60);
				Emitter.emit('baleblast',room,X,Y);
				Snd.ps('bale_e',X,Y);
			} 
			else if (tipDamage==Unit.D_EXPL) 
			{
				if (inWater>0) 
				{
					room.budilo(X,Y,700);
					Emitter.emit('explw',room,X,Y);
					Emitter.emit('bubble',room,X,Y,{kol:30, rx:100, ry:100, rdx:10, rdy:10});
					Snd.ps('expl_uw',X,Y);
				} 
				else 
				{
					room.budilo(X,Y,1500);
					Emitter.emit('expl',room,X,Y);
					Emitter.emit('flare',room,X,Y);
					Emitter.emit('iskr',room,X,Y,{kol:16});
					Snd.ps('expl_e',X,Y);
				}
			} 
			else if (tipDamage==Unit.D_FIRE) 
			{
				if (inWater>0) 
				{
					
				} 
				else if (expl_t==0) 
				{
					room.budilo(X,Y,500);
					Emitter.emit('fireexpl',room,X,Y);
					Emitter.emit('flare',room,X,Y);
					Emitter.emit('iskr',room,X,Y,{kol:16});
					Snd.ps('fire_e',X,Y);
					explLiquid('fire',-33);
				}
			}
			if (otbros>0)	GameSession.currentSession.quake((Math.random()*8-4)*otbros,otbros*0.8);
		}

		public function explLiquid(liq:String, ndy:int=0):void
		{
			for (var i=Math.floor((X-explRadius)/Tile.tilePixelWidth); i<=Math.floor((X+explRadius)/Tile.tilePixelWidth); i++) 
			{
				for (var j=Math.floor((Y-explRadius)/Tile.tilePixelHeight); j<=Math.floor((Y+explRadius)/Tile.tilePixelHeight); j++) 
				{
					var tx:Number = X-(i+0.5)*Tile.tilePixelWidth;
					var ty:Number = Y-(j+0.5)*Tile.tilePixelHeight;
					var ter:Number = tx*tx+ty*ty;
					if (ter<explRadius*explRadius) 
					{
						var t:Tile=room.getTile(i,j);
						if (j>1 && (t.phis || t.shelf) && (t.zForm || room.getTile(i,j-1).phis==0)) Emitter.emit(liq,room,(i+0.5)*Tile.tilePixelWidth+Math.random()*4-2,t.phY1+ndy);
					}
				}
			}
		}
	}
}
