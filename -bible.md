====================================================================================================
============================================= DA BIBLE =============================================
====================================================================================================

Schmoovement:
	Basics:
		WASD: run around
		Space: jump
		Shift: crouch
	Jumpy tricks:
		Boomstick can be used to double jump
		Rocket jump with any explosives
	Shifty shit:
		Press crouch while moving to slide
		Jump while sliding to long jump
		Press crouch while airborne and holding jump to vault (crouching hitbox)
		Presh crouch while airborne and NOT holding jump to ground pound
		Jump right after landing from a ground pound to jump back up to that height and then some
		Press jump while holding any direction to dive in that direction, canceling the pound
	Swimming:
		6DOF


Weapons:
	Slot 1 (Melee):
		Axe:
			Primary: Swing
				Deflects projectiles
			Secondary: nothing lol
		Syringe:
			Primary: Stab
			Secondary: Heal
		Sword:
			Primary: Swing
					Fires projectile at 100%+ health
			Secondary: Guard
					Deflects projectiles

	Slot 2 (Shotguns):
		Shotgun:
			Primary: Shot
			Secondary: Impact Grenade
				Maybe allow charging velocity(?)
		Boomstick:
			Primary: Super Shot
			Secondary: Harpoon Gun
				Reel in foes
				Harpoon persists through weapon switch
				Only one harpoon at a time
			Alt Secondary: Sawblade Launcher
				Hold to spin blade w/o launching (a la ultrakill sawed-on)(?)

	Slot 3 (Automatics):
		AKM:
			Primary: Spray
			Secondary: Sights
		Nailgun:
			Primary: Nails
			Secondary: Detonate
		Plasma Cannon:
			Primary: Plasma Bullets
			Secondary: Plasma Rockets

	Slot 4 (Snipers):
		Big Iron:
			Primary: Big Shot
			Secondary: Scope
				Stronger than that of AKM
		Hunting Rifle:
			Primary: Big Dump
				Uses big iron ammo
			Secondary: Charge
				Increases damage, costs 1 ammo
		Crossbow
			Primary: Charge Beam
			Secondary: Prism Grenade
				Shoot with charge beam for big fun

	Slot 5 (Explosives):
		Hand Cannon:
			Stylize as flare gun(?)
			Primary: Bouncy Grenade
				Uses grenade ammo(?)
				Hold "fire" to charge range
				Grenade deals impact damage without exploding
				Bonus damage for double donk?
			Secondary: Detonate
				Maybe have it as pistol - shoot grenade to blow it up
		Howitzer:
			Primary: Shell Shot
				Uses grenade ammo(?)
			Secondary: Scope
		RPG:
			Primary: Guided Missile
			Secondary: Homing Missiles
				Uses grenade ammo
				Fires 5 missiles

	Slot 6 (Misc.):
		Flamethrower:
			Primary: Hot
			Secondary: Hotter
				Uses cell ammo
		Minigun:
			Primary: Spray
			Secondary: Spin


Enemies:
	Locals:
		Infight with: Locals, Military, Machines

		Canary:
			Tough
			Slow
			Dumb
			Melee only (pickaxe)
			Undead miners
			Voice Lines:
				Detecting Player:
					[various forlorn moans] *2
					"Forsaken..." *1
					"Help..." *1
				Dying:
					[various haunted moans] *3
					"Release..." *1
				Voice Effects:
					Reverse
					Flanger

		["zombie"]:
			Weak
			Slow
			Ranged (fireball)
			Melee (claws)
			Voice Lines:
				Detecting Player:
				Dying:
				Voice Effects:
					none

		Tarantula ["vortigaunt"]:
			Tough
			Medium
			Ranged (lightning bolt)
			Long wind-up
			Voice Lines:
				Detecting Player:
					[angry screech]
				Dying:
					[screech]
				Voice Effects:
					Duplicate track
					Pitch new track +8 semitones
					Duplicate original track
					Pitch new track -8 semitones

		Lizard:
			Tough
			Slow
			Dumb
			Eats Spiders
			Ranged (blood bullet *2)
			Melee (bite)

		Eyeball:
			Weak
			Fast
			Flying
			Ranged (blood bullet)

		Wraith:
			Weak
			Medium
			Flying
			Can turn intangible
			Melee Only (claws)

		[name pending]:
			Weak
			Medium
			Ranged (homing orbs)

		Kiwi:
			Tough
			Fast
			Charger
			Melee only (scissor beak)

		Flux Beast:
			Tough
			Medium
			Teleporter
			Melee Only (teeth)

		Wolf Spider:
			Weak
			Fast
			Neutral to player
			Eats Eyeballs
			Ranged (grappling harpoon)
			Melee (lunge, fangs)
	
	
	Military:
		Infight with: Locals
		
		Hound Spider:
			Weak
			Fast
			Ranged (grappling harpoon)
			Melee (lunge, fangs)
		
		Hell Hound Spider:
			Weak
			Fast
			Alert nearby Hell Hound Spiders upon spotting player
			Ranged (grappling harpoon)
			Melee (lunge, fangs)
		
		Pinkerton:
			Weak
			Medium
			Ranged (shotgun)
			Voice Lines:
				Detecting Player:
					"Halt!" *2
					"Get her!" *2
					"Stop her!" *1
					"Kill her!" *3
					"Intruder spotted." *1
					"Tresspasser!" *3
				Dying:
					[pained grunt] *4
				Vocal Effects:
					Amplify (-25)
					Amplify (+50)
					Compressor
					Filter Curve EQ (radio preset)
					Vinyl (1930, lofi)
					Amplify (-25)
					Amplify (+50)
					Bitcrush (4 bits/sample, crush only)
		
		Enforcer:
			Tough
			Medium
			Has a shield
			Melee Only (baton)
			Voice Lines:
				Detecting Player:
					"Stand Down!"
					"Do not resist!"
					"Remain silent!"
					"Stop resisting!"
				Dying:
					[pained moan]
				Vocal Effects:
					Change Pitch (down 5-8 semitones)
					Compressor
					Filter Curve EQ (radio preset)
					Bitcrush (4 bits/sample, crush then resample)
		
		Exterminator:
			Medium
			Medium
			Ranged (flamethrower, gas grenades)
		
		Soldier:
			Tough
			Slow
			Ranged (akm, hand grenades)
			Robo legs(?)
		
		Rocketeer:
			Medium
			Medium
			Ranged (fast rockets, homing rockets, diving rockets)
				Fast rockets travel in a straight line
				Homing rockets track player, half as fast as fast rockets
				Diving rockets go towards above player, then drop once they're above the player
			Voice Lines:
				Detecting Player:
					"Enemy spotted."
					"Target acquired."
					"Intruder detected."
				Dying:
					"Man down!"
					"Help!"
					[various pained screams]
				Vocal Effects:
					Pitch (-12.5%)
					Compression
					Filter Curve EQ (radio preset)
					Vinyl (1930, lofi)
		
		Minigunner:
			Tough
			Slow
			Ranged (Rapid Fire Minigun)
				tracking accuracy and rate of fire increases the longer line of
				sight is maintained
		
		Sniper:
			Weak
			Stationary
			Ranged (Sniper Rifle)
				sweeps w/ laser pointer until player is in line of sight
				fires when laser pointer stays on player for ~1 second
		
		Flux Trooper:
			Medium
			Fast
			Teleporter
			Ranged (boomstick)
			Voice Lines:
				Detecting Player:
				Dying:
				Vocal Effects:
		
		Whaler:
			Tough
			Slow
			Ranged (harpoon cannon)
		
		Hammer:
			Medium
			Fast
			Ranged (akm)
			Melee (hammer)
			Voice Lines:
				Detecting Player:
					"Vermin!"
					"Filth!"
					"Scum!"
					"Maggot!"
					[evil laughter]
					[evil growl]
				Dying:
					"Damn you!"
					"How--"
					[pained scream]
	
	
	Machines:
		Infight with: Locals
		
		Camera:
			Stationary
			Aggros all connected enemies upon spotting player
			Alerts all connected enemies upon death
		
		Survey Quad:
			Aggros all connected enemies upon spotting player
			Alerts all connected enemies upon death
		
		Gun Turret:
			Stationary
			Ranged (rapid fire bullets)
		
		Rocket Turret:
			Stationary
			Ranged (homing rockets)
		
		Plasma Droid:
			Very Tough
			Slow
			Ranged (plasma burst, plasma rocket)
		
		Crossbow Drone:
			Tough
			Medium
			Ranged (crossbow blast)
			Long wind-up
			Deploys third leg when aiming

		Mortar Mech:
			Tough
			Slow
			Ranged (homing mortars *3, landmines)

		Tank:
			Extremely tough
			Slow
			Ranged (cannon, machine gun, homing rocket pods)

		Chopper:
			Very Tough
			Fast
			Flying
			Ranged (machine gun, dual homing rocket pods)
			Can deploy other enemies


	Environment Hazards:
		Airstrikes:
			Come in several flavors
			Dumb Bombs:
				Big explosion
			Gas Bombs:
				Poison gas
			Drop Pods:
				Enemies


	Charge attacker enemy logic:
		Target some distance away from player in random direction, facing target
		Right before winding up, check to make sure that a clear path exists
				toward target (via shapecast)
		Stop tracking player when winding up
		Charge extremely fast in chosen direction


	Teleporter enemy Logic:
		When walking, build up "charge"
		charge spent based on distance when teleporting
		destination must be *empty* to teleport
		cannot teleport to midair (will snap to floor instead)
		Will teleport to:
			5m directly behind target
			random position toward target
			next node in path
			180 degrees about target
			completely random position


	Bosses:
		Tanya:
			Dual Pistols
			C4
			Fast


Level Concepts:
	Abandoned/overrun mining town (E1M3 "16 Tons")
	Network of bridges spanning a chasm (E1M4)
	Floating islands
	Train level


level goals:
	e1:
		m1: escape building
		m2: knock down building to get into condemned district of city
		m3: get access key to enter mines
		m4: navigate mines, find old underground temples/catacombs/whatever
		m5: get elevator key
		m6: navigate secret laboratory, get plasma cannon
		m7: ancient catacombs mixed with evil lab
		m8: kill boss, enter portal
	e2:
		m1: 
		m2: 
		m3: 
		m4: 
		m5: 
		m6: blood sewer™
		m7: 
		m8: 
	e3:
		m1: 
		m2: 
		m3: 
		m4: 
		m5: 
		m6: 
		m7: 
		m8: 
	e4:
		m1: 
		m2: 
		m3: 
		m4: 
		m5: 
		m6: 
		m7: 
		m8: 


Campaign:
	E1:
		Classic familiar world, mostly Locals and Military, Basic-type keys
		E1M1 ("In the Flesh?"):
			Intro level.
				Weapons:
					*Shotgun
				Enemies:
					*Pinkerton
					*Canary
		E1M2 ("The Color out of Space"):
			Weapons:
				*AKM
			Enemies:
				Pinkerton
				Canary
				*Lizard
		E1M3 ("Sixteen Tons"):
			An abandoned mining town, crawling with unfathomable monstrosities
			of pure evil. Also canaries and tarantulas.
			Weapons:
				AKM
				*Boomstick
			Enemies:
				Pinkerton
				Canary
				Lizard
		E1M4 (""):
			Mine tunnel maze.
			Weapons: 
				AKM
				Boomstick
			Enemies:
				Pinkerton
				Canary
				Lizard
				*Camo Lizard
		E1M5 (""):
			An old mine system, composed of a maze of caves and tunnels
			connected by a bridge network spanning the central chasm.
			Weapons:
				AKM
				Boomstick
				BigIron
				*Nailgun
			Enemies:
				Pinkerton
				Canary
				Lizard
				Camo Lizard
				Eyeball
		E1M6 ("Let There Be More Light"):
			A secret laboratory, buried deep within the earth and harboring
			all manner of strange and terrible OSHA violations.
			Weapons:
				AKM
				Boomstick
				BigIron
				Nailgun
				*PlasmaCannon
			Enemies:
				Pinkerton
				Canary
				Lizard
				Eyeball
				Tarantula
				Enforcer
				*PlasmaDroid (as miniboss)
		E1M7 (""):
			Evil Factory Level/Power Plant.
			Weapons:
				AKM
				Boomstick
				BigIron
				Nailgun
				PlasmaCannon
			Enemies:
				Pinkerton
				Canary
				Lizard
				Eyeball
				Tarantula
				Enforcer
				PlasmaDroid
		E1M8 (""):
			Boss level. A mysterious facility, housing some sort of portal.
			Weapons:
				Boomstick
				PlasmaCannon
			Enemies:
				Pinkerton

		E1S1 ("DOOT" [formatted like DOOM's title text]):
			A recreation of DOOM's E1M1.
			Alternate names:
				"Doomed from the Start"


	E2:
		Eldritch otherworld outskirts, lots of Locals
		Gemkey-type keys
		E2M1 ("Brave New World"):
		E2M2 ("Goodbye Blue Sky"):
			Underhang-type platforming across the bottom of a chain of floating
			islands. Introduces choppers.
		E2M3 (""):
		E2M4 (""):
		E2M5 (""):
		E2M6 ("Heart Lungs Liver Nerves"):
			The living interior of some great old one's body.
		E2M7 ("The Nameless City"):
			Self-explanatory.
			Level ends w/ walking towards a portal, which is then cut off by
			the slamming of a steel shutter door, as the player is swarmed by
			Pinkertons. The player must then escape the now Military-infested
			temple.
		E2M8 ("The White Whale"):
			Boss level.
		E2S1 ("SUSK" [formatted like DUSK's title text]):
			Recreation of E1M3 of DUSK.
			Alternate names:
				"Dusk to Dusk"


	E3:
		Eldritch otherworld industrial zone, lots of Locals and Military
		Neuron-type keys
		E3M1 (""):
		E3M2 (""):
		E3M3 (""):
		E3M4 (""):
		E3M5 ("King Rat"):
			Where gods go to die.
		E3M6 ("Whalefall"):
			The interior of some great old one's corpse.
		E3M7 ("The Grapes of Wrath"):
			The hellish bowels of a great one corpse processing facility.
			Featuring blood sewers.
		E3M8 ("Comfortably Numb"):
			Boss level.
		E3S1 ("ULTRAKICK" [formatted like ULTRAKILL's title text]):
			Recreation of 1-1 from ULTRAKILL.
			Alternate names:
				"One UltraHell of a Time"


	E4:
		Military/Industrial wasteland in familiar world, swarming with Military
		and Machines
		Keycard-type keys
		E4M1 ("In the Flesh"):
			Reprise of E1M1, twisted into a nightmarish industrial hellscape
			crawling with far more dangerous foes.
			Weapons:
				*Syringe
			Enemies:
				Pinkerton
				Enforcer
				Soldier
				*Hammer
				*Chopper
		E4M2 ("Silent Spring"):
		E4M3 (""):
		E4M4 (""):
		E4M5 (""):
		E4M6 (""):
		E4M7 ("Spiral of Ants"):
			Make your final approach towards THE MACHINE.
		E4M8 ("WELCOME"):
			Destroy THE MACHINE from within.
		E4S1 ("Echoes"):
			Obscenely long slaughter level.


Juicy Lore Bits:
	Biology:
		*All bone is metal
		Most metal is bone
		Humans:
			Head is skinless, covered by thick exoskeleton made of exposed bone*
			Proboscis instead of mouth
				Proboscis is used for syringes and needles
			Eyes are covered by glass(?) membrane
				Eyelids are metallic and behind said membrane
				Irises are bioluminescent
			Facial plastic surgery involves a lot of welding/metalworking
			Glasses are very rare, only used if the correction needs to be contextual or something
				Generally, sight disorders are corrected by way of surgically
				altering/replacing the above-mentioned glass membranes

		Crows:
			Sapient
			Only fully organic creatures (aside from maybe bones*)


Achievements & Shit:
	tastes like soylent green:
		eat a corpse
	average roguelike pc:
		eat one hundred (100) corpses
	the tubifex monster from carrion gives me gender envy:
		eat ten thousand (10000) corpses


Credits:
	Main Developer:
		Meeee :)

	Assets:
		Textures:
			Meeee :)
			Some normal maps generated uisng Laighter
		Audio:
			Effects:
				Various random stock sounds from FelysianStudios
				Various random stock sounds from Pixabay
				Meeee :)
			Voices:
				Meeee :)
		Code:
			Meeee :)
			Various publicly avaliable code/shader snippets

	Tools:
		Godot
		Qodot
		TrenchBroom
		Aseprite
		Laighter
		Audacity

 {{ 
	ambusher == "camo lizard" -> "path": "models/enemy_lizard.glb", 
	ambusher == "canary" -> "path": "models/enemy_canary.glb", 
	ambusher == "enforcer" -> "path": "models/enemy_enforcer.glb", 
	ambusher == "eyeball" -> "path": "models/enemy_eyeball.glb", 
	ambusher == "lizard" -> "path": "models/enemy_lizard.glb", 
	ambusher == "pinkerton" -> "path": "models/enemy_pinkerton.glb", 
	ambusher == "plasma droid" -> "path": "models/enemy_plasma_droid.glb", 
	ambusher == "rocketeer" -> "path": "models/enemy_rocketeer.glb", 
	ambusher == "sleeping lizard" -> "path": "models/enemy_lizard.glb", 
	ambusher == "soldier" -> "path": "models/enemy_soldier.glb", 
	"path": "models/enemy_pinkerton.glb" 
}}

bleep frequency: 1000hz
tinnitus frequency: 2100hz
