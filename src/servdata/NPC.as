package servdata 
{
	
	import unitdata.UnitNPC;

	public class NPC 
	{

		public var xml:XML;			// XML from GameData
		public var id:String='';			// NPC id
		public var vid:String;			// id of the linked vendor
		public var owner:Obj;				// owner, a physical object, for example, a unit
		public var vendor:Vendor;			// linked vendor object
		public var inter:Interact;			// owner's interaction

		public var hidden:Boolean=false;	// the unit linked to the NPC will be hidden
		// savable states
		public var rep:int=0;
		public var zzzGen:Boolean=false;
		
		public var npcInter:String='';		// type of interaction
		// interaction options displayed near the cursor, for example, "talk," when there is dialogue and when there isn't
		public var userAction1:String, userAction2:String;
		public var ndial:String;	// dialogue when there's nothing more to say
		
		
		public function NPC(nxml:XML, loadObj:Object=null, nvid:String=null, ndif:int=100) {
			xml=nxml;
			if (xml) {
				id=xml.@id;
				if (xml.@vendor.length()) vid=xml.@vendor;
				if (xml.@inter.length()) npcInter=xml.@inter;
				if (xml.@ua1.length()) userAction1=xml.@ua1;
				if (xml.@ua2.length()) userAction2=xml.@ua2;
				if (xml.@ndial.length()) ndial=xml.@ndial;
			}
			if (loadObj) {
				if (loadObj.rep!=null) rep=loadObj.rep;
			}
			if (nvid!=null) vid=nvid;
			// Create a vendor object
			if (vid!=null && vid!='') {
				if (World.world.game.vendors[vid]){
					vendor = World.world.game.vendors[vid];
				} else {
					vendor = new Vendor(ndif, null, null, vid);
					if (vid=='doctor') {
						npcInter='doc';
					} else {
						npcInter='vr';
					}
				}
			}
		}

		public function save():Object {
			var obj=new Object();
			obj.rep=rep;
			return obj;
		}
		
		// Setting up interaction, called when connecting to the unit
		public function setInter() {
			if (id=='adoc' && rep<=1) inter.t_action=45;
		}
		
		// This function is called when the unit is created
		public function init() {
			if (id=='calam') {
				if (rep==0 || trig('rbl_visited')>0) {
					hidden=true;
				}
				if (rep==1) (owner as UnitNPC).aiTip='agro';
			}
			if (id=='steel2') refresh();
		}
		
		function trig(s:String):* {
			return World.world.game.triggers[s];
		}
		
		// This function is called when generating a map with the unit
		public function refresh() {
			if (id=='calam') {
				if (rep==0 && owner) owner.command('ai','');
			}
			if (id=='calam2') hidden=(trig('storm')>0);
			if (id=='calam3') hidden=(trig('storm')!=1);
			if (id=='calam4') hidden=(trig('storm')!=2 && trig('storm')!=3);
			if (id=='calam5') hidden=(trig('storm')!=3);
			if (id=='steel2') hidden=(trig('mbase_visited')>0);
			if (id=='steel') hidden=(trig('storm')==5);
			if (id=='askari') hidden=(trig('story_ranger')>0);
			if (id=='askari2') hidden=!(trig('story_ranger')>0) || trig('storm')>0;
			if (id=='patient') zzzGen=(rep==2);
			if (id=='observer') hidden=(trig('observer')!=1);
			if (id=='observer2') hidden=(trig('storm')!=2);
			if (id=='askari3') hidden=!(trig('storm')>=2);
			if (id=='mentor') hidden=(trig('theend')>0);
		}
		
		// This function is called when a flying unit lands
		public function landing() {
			if (id=='calam') {
				rep=1;
			}
		}
		
		// Activate interaction with NPC
		public function activate() {
			if (check(true) && npcInter!='patient') return;
			if (npcInter=='travel') {
				World.world.pip.travel=true;
				World.world.pip.onoff(3,3);
				World.world.pip.travel=true;
			} else if (npcInter=='doc' || npcInter=='vdoc') {
				pip(6);
			} else if (npcInter=='adoc') {
				if (rep<=1)	{
					repair();
				} else {
					pip(6);
				}
			} else if (npcInter=='patient') {
				patient();
			} else if (vendor) {
				pip(4);
			} else {
				if (ndial) World.world.gui.dialog(ndial);
				else if (owner) owner.command('tell','dial');
			}
		}
		
		public function pip(n:int) {
			World.world.pip.vendor=vendor;
			World.world.pip.npcId=id;
			World.world.pip.npcInter=npcInter;
			World.world.pip.onoff(n);
			if (owner) owner.command('replicVse');
		}
		
		
		// Check for quest actions, if 'us', perform actions; if not, only set the status
		public function check(us:Boolean=false):Boolean {
			if (xml && xml.dial.length()) {
				for each (var dial in xml.dial) {
					if (trig('dial_'+dial.@id)) continue;
					if (dial.@lvl.length() && dial.@lvl>World.world.pers.level) continue; 
					if (dial.@barter.length() && dial.@barter>World.world.pers.getSkLevel(World.world.pers.skills['barter'])) continue; 
					if (dial.@trigger.length()) {
						if (dial.@n.length()) {
							if (trig(dial.@trigger)!=dial.@n) continue;
						} else {
							if (trig(dial.@trigger)!=1) continue;
						}
					}
					if (dial.@prev.length() && trig('dial_'+dial.@prev)!=1) continue; 
					if (dial.@land.length() && !World.world.game.lands[dial.@land].access) continue; 
					if (dial.@armor.length() && (World.world.gg.currentArmor==null || World.world.gg.currentArmor.id!=dial.@armor)) continue; 
					if (dial.@pet.length() && World.world.gg.currentPet!=dial.@pet) continue; 
					if (dial.@quest.length()) {						 // If a quest is active
						var quest=World.world.game.quests[dial.@quest];
						if (quest==null || quest.state!=1) continue; 
						if (dial.@sub.length()) {					// If there is a visible sub-quest
							if (quest.subsId[dial.@sub]==null || quest.subsId[dial.@sub].invis) continue; 
						}
					}
					if (us) {
						if (dial.scr.length()) {
							var scr:Script=new Script(dial.scr[0],World.world.land,owner,true);
							if (World.world.dialOn) {
								var did:String=dial.@id;
								scr.acts.unshift({act:'dialog', val:did, t:0, n:-1, opt1:0, opt2:0, targ:""});
							}
							scr.acts.push({act:'trigger', val:('dial_'+dial.@id), t:0, n:1, opt1:0, opt2:0, targ:""});
							scr.acts.push({act:'checkall', val:0, t:0, n:1, opt1:0, opt2:0, targ:""});
							//scr.acts.push({act:'check', val:0, t:0, n:1, opt1:0, opt2:0, targ:"this"});
							scr.start();
						} else {
							if (World.world.dialOn) World.world.gui.dialog(dial.@id);
							World.world.game.setTrigger('dial_'+dial.@id);

						}
						if (dial.reward.length()) {
							for each(var rew in dial.reward) {
								if (rew.@id.length()) {
									var item:Item;
									if (rew.@kol.length()) item=new Item('', rew.@id, rew.@kol);
									else item=new Item('', rew.@id);
									World.world.invent.take(item,2);
								}
							}
						}
						if (dial.@music.length()) {
							Snd.playMusic(dial.@music);
						}
						check();
					} else {
						if (dial.@imp.length()) setStatus(2);
						else setStatus(1);
					}
					return true;
				}
			}
			if (!us) setStatus(0);
			return false;
		}
		
		public function setStatus(dial:int=0) {
			if (dial>0) {
				setIco('dial'+dial);
				if (userAction1) inter.userAction=userAction1;
				else inter.userAction='dial';
				owner.command('sign');
			} else {
				if (userAction2) inter.userAction=userAction2;
				else if (npcInter=='doc' || npcInter=='vdoc') {
					inter.userAction='therapy';
				} else if (npcInter=='patient') {
					if (trig('patient_tr2')=='1') {//cured
						inter.t_action=0;
						inter.userAction='dial';
					} else {
						inter.t_action=30;
						inter.userAction='see';
					}
				} else if (npcInter=='adoc') {
					if (rep<=1)	inter.userAction='repair';
					else inter.userAction='therapy';
				} else if (vendor) {
					inter.userAction='trade';
				} else {
					inter.userAction='dial';
				}
				setIco();
			}
			inter.update();
		}
		
		// Set the top icon
		function setIco(n:String=null) {
			try {
				if (n==null) owner['ico'].gotoAndStop(owner['icoFrame']);
				else owner['ico'].gotoAndStop(n);
			} catch (err) {}
		}
		
		public function repair() {
			if (xml && xml.quest.length()) {
				if (World.world.game.quests[xml.quest.@id]==null) {
					World.world.game.addQuest(xml.quest.@id);
					return;
				}
			}
			if (World.world.pers.skills[xml.@needskill]==null) return;
			var sk:int=World.world.pers.getSkLevel(World.world.pers.skills[xml.@needskill]);
			var ok:Boolean=false;
			if (sk<2) {
				World.world.gui.dialog('rblAutoDocR1');
			} else if (sk>=5) {
				World.world.gui.dialog('rblAutoDocR5');
				ok=true;
			} else if (rep==1) {
				ok=true;
				for each(var node in xml.rep) {
					if (World.world.invent.items[node.@id] && World.world.invent.items[node.@id].kol<node.@kol) {
						World.world.gui.infoText('required',World.world.invent.items[node.@id].nazv, node.@kol-World.world.invent.items[node.@id].kol);
						ok=false;
					}
				}
				if (ok) {
					for each(node in xml.rep) {
						if (World.world.invent.items[node.@id]) {
							World.world.invent.minusItem(node.@id, node.@kol);
							World.world.gui.infoText('withdraw',World.world.invent.items[node.@id].nazv, node.@kol);
						}
					}
					World.world.gui.dialog('rblAutoDocR4');
				} else {
					World.world.gui.dialog('rblAutoDocR3');
				}
			} else {
				World.world.gui.dialog('rblAutoDocR2');
				rep=1;
			}
			if (ok) {
				rep=2;
				inter.t_action=0;
				setStatus();
				if (xml && xml.quest.length()) {
					World.world.game.closeQuest(xml.quest.@id,xml.quest.@cid);
				}
			}
		}
		
		public function patient() {
			if (World.world.pers.skills[xml.@needskill]==null) return;
			var sk:int=World.world.pers.getSkLevel(World.world.pers.skills[xml.@needskill]);
			if (rep==2) {	// Cured
				if (trig('patient_tr2')=='1') {// Cured
					if (owner) owner.command('openEyes');
				} else {
					World.world.gui.dialog('dialPatient7');
				}
			} else if (rep==1) {	// After examination
				if (World.world.invent.items[xml.@needitem] && World.world.invent.items[xml.@needitem].kol>0) {	// There's medicine
					World.world.invent.minusItem(xml.@needitem, 1);
					rep=2;
					World.world.gui.dialog('dialPatient5');
					World.world.game.triggers['patient_tr2']='wait';
					World.world.game.closeQuest('patientHeal', '3');
					World.world.game.showQuest('patientHeal', '4');
				} else {	// No medicine
					World.world.gui.dialog('dialPatient8');
				}
			} else if (sk<4) {	// Insufficient medical skill
				World.world.gui.dialog('dialPatient2');
			} else {
				World.world.gui.dialog('dialPatient3');
				rep=1;
				World.world.game.triggers['patient_tr1']=1;
				World.world.game.closeQuest('patientHeal', '1');
				World.world.game.showQuest('patientHeal', '2');
				World.world.game.showQuest('patientHeal', '3');
			}
			refresh();
		}
	}
	
}
