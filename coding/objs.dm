obj
	var
		paintable = 0
		list/paint_list
		paint_icon
		paint_icon_state
	proc
		painted(paint_window/W, mob/M)
	Flower
		icon='icons/Flowers.dmi'
		Red_Flower
			icon_state="red"
		Blue_Flower
			icon_state="blue"
		Yellow_Flower
			icon_state="yellow"
	landmark
		icon = 'icons/landmarks.dmi'
		invisibility = 100
		anchored = 1
		density = 0
		opacity = 0
		var/image/image
		New()
			. = ..()
			src.image = image(icon = src.icon, loc = src, icon_state = src.icon_state)
			src.icon = null
			src.invisibility = 0
			spawn
				for(var/obj/tree/O in loc) O.Move(null, forced = 1)
				for(var/obj/bush/O in loc) O.Move(null, forced = 1)
	bed
		icon = 'icons/bed.dmi'
		icon_state = "2"
		density=1
		New()
			. = ..()
			overlays += image(icon = 'icons/bed.dmi', icon_state = "1", pixel_x = -32)
			overlays += image(icon = 'icons/bed.dmi', icon_state = "3", pixel_x = 32)
			overlays += image(icon = 'icons/bed.dmi', icon_state = "4", layer = MOB_LAYER + 0.5)
		attack_hand(mob/M)
			if(M.icon_state == "ghost") return
			if(M.inHand(/item/weapon/axe))
				if(ActionLock("Destroy", 4)) return
				if(--buildinghealth > 0)
					send_message(hearers(M), "<tt>[M.name] chops the bed with [M.gender == FEMALE ? "her":"his"] axe!</tt>", 1)
				else
					send_message(hearers(M), "<tt>[M.name] cuts the bed down!</tt>", 1)
					Move(null, forced = 1)
			else
				M.Move(src.loc, forced = 1)
				M.toggle_sleep(1)
		var/buildinghealth = 5
	gong
		icon = 'icons/Turfs.dmi'
		icon_state = "town_bell"
		density = 1
		anchored = 1
		attack_hand(mob/M)
			if(ActionLock("gong", 100))
				M.show_message("You may not use the gong yet.")
				return
			if(ActionLock("enchanted"))
				var/map_object
					map = MapObject(loc.z)
					map2
				if(!map) return

				for(var/mob/N in world)
					if(N.z != map.z)
						map2 = MapObject(N.z)
						if(!map2 || map2.kingdom != map.kingdom) continue

					var/t = dir2text(get_dir(locate(N.x, N.y, src.z), src))
					. = "\icon[src] You hear the sound of a gong coming from "
					if(t)
						. += "the [t]"
						if(N.z != src.z) . += " and [MapLayer(N.z) > MapLayer(src.z) ? "above" : "beneath"] you."
					else if(N.z != src.z)
						. += "the ground [MapLayer(N.z) > MapLayer(src.z) ? "above you" : "beneath your feet"]."
					else . += "your own position."
					N << .
					N << sound('sounds/gong.ogg')
			else
				var
					turf
						T = loc
						T2
					map_object
						map = MapObject(T.z)
						map2 = map.NextLayer()
				if(map2) T2 = map2.z
				if(!T || !T2) return

				for(var/mob/N in range(20, T))
					var/t = dir2text(get_dir(N, src))
					N << "\icon[src] You hear the sound of a gong coming from [t ? "the [t]" : "your own position"]."
					N << sound('sounds/gong.ogg')
				for(var/mob/N in range(10, T2))
					var/t = dir2text(get_dir(N, src))
					. = "\icon[src] You hear the sound of a gong coming from "
					if(t)
						. += "the [t] and [MapLayer(T2.z) > MapLayer(T.z) ? "above" : "beneath"] you."
					else
						. += "the ground [MapLayer(T2.z) > MapLayer(T.z) ? "above you" : "beneath your feet"]."
					N << .
					N << sound('sounds/gong.ogg')
		proc
			enchant()
				var/time = rand(900, 2400)
				ActionLock("enchanted", time) //crappy way of doing it, ah well
				icon_state = "town_bell1"
				viewers(src) << "\icon[src] The gong begins to glow a bright blue..."
				spawn(time)
					icon_state = "town_bell"
					viewers(src) << "\icon[src] The gong stops glowing."
	portal
		var
			mob/owner
			turf/target
		density = 1
		anchored = 1
		icon = 'icons/Turfs.dmi'
		icon_state = "portal"
		Bumped(atom/movable/M)
			. = ..()
			if(target)
				hearers() << "<font color=blue>[M] steps into the portal and pops out of view."
				M.Move(src, forced = 1)
				sleep(3)
				M.Move(target, forced = 1)
				target.Entered(M)
			else if(owner)
				var/obj/portal/other_portal = owner.other_portal(src)
				if(other_portal)
					hearers() << "<font color=blue>[M] steps into the portal and pops out of view."
					M.Move(src, forced = 1)
					sleep(3)
					M.Move(other_portal.loc, forced = 1)
					other_portal.loc.Entered(M)
		Del()
			//clear the buffer
			var
				obj/portal/other_portal
				turf/T = target
			if(!T && owner)
				other_portal = owner.other_portal(src)
				if(other_portal) T = other_portal.loc
			if(!T)
				var/list/L = new/list()
				turfloop:
					for(T in block(locate(1, 1, worldz), locate(world.maxx, world.maxy, worldz)))
						if(T.density) continue
						for(var/atom/O in T)
							if(O.density) continue turfloop
						L += T
				if(L.len) T = pick(L)
			if(T)
				for(var/mob/M in contents)
					M.Move(T, forced = 1)
					T.Entered(M)

			//delete the other portal too
			if(target && !istype(src, /obj/portal/school_of_magic))
				for(var/obj/portal/O in world)
					if(O != src && O.target == loc)
						O.target = null
						O.Move(null, forced = 1)
			return ..()
		school_of_magic
			var
				enchanted = 1
			New(loc, timer)
				. = ..()
				if(timer)
					enchanted = 0
					spawn(timer) Move(null, forced = 1)
			proc
				Load()
				enchant()
					var/time = rand(40, 100)
					ActionLock("enchanted", time)
					icon_state = "portal1"
					viewers(src) << "\icon[src] The portal begins to glow a bright blue..."
					spawn(time)
						icon_state = "portal"
						viewers(src) << "\icon[src] The portal stops glowing."
			Bumped(atom/movable/A)
				if(enchanted) //this is the end portal; let's try to teleport back to their old location
					var
						mob/M = A
						turf/T
					if(istype(M)) T = M.old_loc
					if(!T) T = locate(98, 107, 3) //Bovinia peasant village
					src.target = T
					return ..()
				else if(ActionLock("enchanted"))
					//find the real portal
					var/obj/portal/school_of_magic/O
					for(O in world) if(O.enchanted) break
					if(O)
						var/mob/M = A
						if(istype(M)) M.old_loc = src.loc
						target = O.loc
					else
						target = null
				else target = locate(98, 107, 3) //Bovinia peasant village
				return ..()
	falsewall
		density = 1
		opacity = 1
		anchored = 1
		var
			list/known = new/list()
			operating = 0
			buildinghealth = 1
			family_name
		attack_hand(mob/M)
			. = ..()

			if(!density)
				if(!(M.ckey in known)) known += M.ckey
				M.show_message("<tt>The wall slides shut.</tt>")
				close()
			else
				if((M.ckey in known) || M.key == building_owner || prob(5))
					M.show_message("<tt>The wall slides open[(M.ckey in known) ? "." :"!"]</tt>")
					if(!(M.ckey in known)) known += M.ckey
					open()
				else
					M.show_message("<tt>You push the wall but nothing happens!</tt>")
		proc
			open()
			close()
		wood
			name = "wood wall"
			icon = 'icons/wood.dmi'
			icon_state = "wall"
			New()
				. = ..()
				if(buildinghealth == 1)
					buildinghealth = rand(10,15)
			attack_hand(mob/M)
				if(M.inHand(/item/weapon/axe))
					if(ActionLock("Destroy", 4)) return
					if(--buildinghealth > 0)
						send_message(hearers(M), "<tt>[M.name] chops the wood wall with [M.gender == FEMALE ? "her":"his"] axe!</tt>", 1)
					else
						send_message(hearers(M), "<tt>[M.name] cuts the wood wall down!</tt>", 1)
						Move(null, forced = 1)
				else return ..()
			open()
				if(operating) return
				operating = 1
				icon_state = "wall-open"
				flick("wall-opening", src)
				src.sd_SetOpacity(0)
				sleep(7)
				density = 0
				operating = 0
			close()
				if(operating) return
				operating = 1
				icon_state = "wall"
				flick("wall-closing", src)
				density = 1
				sleep(7)
				src.sd_SetOpacity(1)
				operating = 0
		stone
			name = "stone wall"
			icon = 'icons/stone.dmi'
			icon_state = "stone wall"
			New()
				. = ..()
				if(buildinghealth == 1) buildinghealth = rand(10,15)
			attack_hand(mob/M)
				if(M.inHand(/item/weapon/sledgehammer))
					if(ActionLock("Destroy", 4)) return
					if(--buildinghealth > 0)
						send_message(hearers(M), "<tt>[M.name] hits the stone wall with [M.gender == FEMALE ? "her":"his"] sledgehammer!</tt>", 1)
					else
						send_message(hearers(M), "<tt>[M.name] smashes the stone wall down!</tt>", 1)
						Move(null, forced = 1)
				else return ..()
			open()
				if(operating) return
				operating = 1
				icon_state = "stone wall-open"
				flick("stone wall-opening", src)
				src.sd_SetOpacity(0)
				sleep(7)
				density = 0
				operating = 0
			close()
				if(operating) return
				operating = 1
				icon_state = "stone wall"
				flick("stone wall-closing", src)
				density = 1
				sleep(7)
				src.sd_SetOpacity(1)
				operating = 0
	stairs
		icon = 'icons/Turfs.dmi'
		icon_state = "stairs3"
		density = 1
		anchored = 1
		var/buildinghealth = 15
		New()
			. = ..()
			spawn
				if(loc)
					var/map_object/O = MapObject(z)
					if(O.map_layer < 0) return
					var/map_object/B = O.NextLayer()
					if(B) return //layer already exists
					var/new_z = add_layer(O.kingdom) //create the new layer

					var/turf/T = locate(x, y, new_z)
					if(!T) return
					if(istype(T, /turf/sky) || T.type == world.turf)
						new/area/darkness/sky(T)
						T = new/turf/sky/hole(T)
					if(T) T.update_sky()
		Bumped(mob/M)
			var/turf/loc = src.loc
			if(!istype(M) || !istype(loc) || !loc.empty(src)) return
			M.Move(loc, forced = 1)
			M.lastHole = src
			spawn(100) if(M && M.lastHole == src) M.lastHole = null

			var/map_object/O = MapObject(M.z)
			if(O.map_layer < 0) //going up!
				O = O.NextLayer()
				if(!O) return
				var/turf/T = locate(x, y, O.z)

				if(istype(T, /turf/path) || istype(T, /turf/grass) || istype(T, /turf/sand))
					if(istype(T, /turf/sand))
						new/turf/hole{icon_state = "hole_s"}(T)
					else new/turf/hole(T)
				else if(istype(T, /turf/trapdoor))
					var/turf/trapdoor/P = T
					if(P.icon_state == "trapdoor closed")
						if(P.locked)
							M.show_message("<tt>A trap door seems to be blocking the way. You knock...</tt>")
							if(!ActionLock("knock", 5))
								for(var/mob/N in hearers(P) + hearers(src))
									N.show_message("\icon[src] *knock* *knock*", 2)
						else
							P.icon_state = "trapdoor open"
							M.Move(T, forced = 1)
					else
						M.Move(T, forced = 1)
				else if(istype(T, /turf/hole) || locate(/obj/family/edison/grandfather_clock, T))
					M.Move(T, forced = 1)
				else
					M.show_message("<tt>This area is too hard to get through.</tt>")
			else
				O = O.NextLayer()
				if(!O)
					M.show_message("<tt>Whoops! Looks like the game never made the sky! Please report this bug.</tt>")
					return

				var/turf/sky/hole/T = locate(x, y, O.z)
				if(!istype(T))
					M.show_message("<tt>This area is too hard to get through.</tt>")
					return

				if(M.whopull && get_dist(M, M.whopull) <= 1 && !M.whopull.anchored)
					M.whopull.Move(T, forced = 1)
				M.Move(T, forced = 1)
		royal_stairs
			icon_state="royal stairs1"
		attack_hand(mob/M)
			if(M.inHand(/item/weapon/sledgehammer))
				if(ActionLock("Destroy", 4)) return
				if(--buildinghealth > 0)
					send_message(hearers(M), "<tt>[M.name] hits the [lowertext(initial(name))] with [M.gender == FEMALE ? "her":"his"] sledgehammer!</tt>", 1)
				else
					send_message(hearers(M), "<tt>[M.name] smashes the [lowertext(initial(name))] down!</tt>", 1)
					Move(null, forced = 1)
			else return ..()
	fire
		icon_state = "fire"
		anchored = 1
		luminosity = 7
		var/global/list/allowed_types = list(
			/item/misc/wood, /item/misc/stone, /item/misc/ores/gold_ore, /item/misc/gold,
			/item/misc/ores/iron_ore, /item/misc/food, /item/misc/ores/copper_ore, /item/misc/copper_coin,
			/item/misc/molten_copper
		)
		MouseDropped(item/misc/I, src_location, over_location, control, params)
			if(!(usr in range(1, src)) || !(I in usr.contents)) return

			var/type
			for(type in allowed_types)
				if(istype(I, type)) break
			if(!type) return

			if(!istype(I, /item/misc/food/Dough) && I.stacked && I.stacked > 1)
				var/amount = input(usr, "Specify the amount you would like to use. \[1-[I.stacked]\]", "Fire :: Specify Amount") as null|num
				if(amount == null || !(usr in range(1, src)) || !(I in usr.contents)) return
				if(amount <= 0) amount = 1
				if(amount > I.stacked) amount = I.stacked
				I.stacked -= amount
				for(var/i = 1 to amount)
					ProcessItem(I)
			else
				I.stacked--
				ProcessItem(I)

			if(I.stacked <= 0) I.Move(null, forced = 1)
			return 1
		proc/ProcessItem(item/misc/I)
			var
				cooked = 0
			//misc.
			if(istype(I, /item/misc/key_mold) || istype(I, /item/misc/key)) del I
			else if(istype(I, /item/misc/wood))
				usr.contents += new/item/weapon/torch(usr)
			else if(istype(I, /item/misc/stone))
				usr.contents += new/item/misc/molten_stone
			else if(istype(I, /item/misc/ores/gold_ore))
				usr.contents += new/item/misc/gold
			else if(istype(I, /item/misc/gold))
				usr.contents += new/item/misc/molten_gold
			else if(istype(I, /item/misc/ores/iron_ore))
				usr.contents += new/item/misc/molten_iron
			else if(istype(I, /item/misc/ores/copper_ore))
				usr.contents += new/item/misc/copper_coin
			else if(istype(I, /item/misc/copper_coin))
				usr.contents += new/item/misc/molten_copper

			//cooking
			else if(istype(I, /item/misc/food/Meat))
				usr.contents += new/item/misc/food/Cooked_Meat
				cooked = 1
			else if(istype(I, /item/misc/food/Frog_Meat))
				usr.contents += new/item/misc/food/Cooked_Frog_Meat
				cooked = 1
			else if(istype(I, /item/misc/food/Goldfish))
				usr.contents += new/item/misc/food/Cooked_Goldfish
				cooked = 1
			else if(istype(I, /item/misc/food/Shark))
				usr.contents += new/item/misc/food/Cooked_Shark
				cooked = 1
			else if(istype(I, /item/misc/food/Bass))
				usr.contents += new/item/misc/food/Cooked_Bass
				cooked = 1
			else if(istype(I, /item/misc/food/Puffer_Fish))
				usr.contents += new/item/misc/food/Cooked_Puffer_Fish
				cooked = 1
			else if(istype(I, /item/misc/food/Carp))
				usr.contents += new/item/misc/food/Cooked_Carp
				cooked = 1
			else if(istype(I, /item/misc/food/Koi))
				usr.contents += new/item/misc/food/Cooked_Koi
				cooked = 1
			else if(istype(I, /item/misc/food/Tuna))
				usr.contents += new/item/misc/food/Cooked_Tuna
				cooked = 1
			else if(istype(I, /item/misc/food/Swordfish))
				usr.contents += new/item/misc/food/Cooked_Swordfish
				cooked = 1
			else if(istype(I, /item/misc/food/Dough))
				I.stacked++
				var
					list/L = list("Cake", "Pie", "Scone")
					choice = input(usr, "What kind of pastry would you like to make?", "[name] :: Pastry") as null|anything in L
				if(choice == null || !(usr in range(1, src)) || !(I in usr.contents)) return
				switch(choice)
					if("Cake") usr.contents += new/item/misc/food/Cake
					if("Pie") usr.contents += new/item/misc/food/Pie
					if("Scone") usr.contents += new/item/misc/food/Scone{stacked=3}
				I.stacked--
				cooked = 1

			if(cooked)
				usr.medal_Report("chef")
		attack_hand(mob/M)
			if(M.inHand(/item/weapon/shovel))
				for(var/mob/N in ohearers(M))
					N.show_message("\blue [M.name] starts to put out the fire...")
				M.show_message("\blue You start to put out the fire...")
				var/count = M.moveCount
				sleep(20)
				if(!M.CheckAlive() || M.moveCount != count) return 1
				for(var/mob/N in ohearers(M))
					N.show_message("\blue [M.name] puts the fire out with [M.gender == FEMALE ? "her" : "his"] shovel!")
				M.show_message("\blue You put the fire out with your shovel!")
				Move(null, forced = 1)
		stove
			icon_state = "stove0"
			density = 1
			New()
				icon_state = "stove[rand(1, 3)]"
				return ..()
			attack_hand(mob/M)
	bookcase
		name = "bookcase"
		icon = 'icons/Turfs.dmi'
		icon_state = "bookcase"
		density = 1
		anchored = 1
		attack_hand(mob/M)
			var/list/L = admin.GetBooks()
			if(!L || !L.len)
				alert(M, "There are no books!", "Bookcase")
				return
			var/title = input(M, "Select a book to grab. The book will be duplicated in your inventory.", "Bookcase") as null|anything in L
			if((M in range(1, src)) && !M.restrained() && title)
				var/item/misc/book/I = admin.GetBook(title)
				if(I)
					if(!settings["use_mysql"]) I = I.duplicate()
					M.contents += I
		MouseDropped(item/misc/book/I)
			if((usr in range(1, src)) && istype(I) && (I in usr.contents))
				if(admin.GetBook(I.name))
					alert(usr, "There is already a book with that name in the bookcase. If you wish to overwrite it, please request a GM to unlock it.")
					return
				if((usr in range(1, src)) && istype(I) && (I in usr.contents))
					admin.StoreBook(I)
					//if(I.approved) usr.medal_Award("Member Of The Bovinia Book Club")
					//spawn(3) B.Move(null, forced = 1) //the spawn() call here avoids a nasty case where the book is actually NOT destroyed
					//del I
			else return ..()
		large
			icon_state = "bookcasel"
			New()
				. = ..()
				overlays += image(icon = 'icons/Turfs.dmi', icon_state = "bookcasel", dir = NORTH, pixel_y = 32, layer = FLY_LAYER)
	sp_start
		name = ""
		icon = 'icons/Cow.dmi'
		invisibility = 100

	tree
		icon_state = "tree"
		density = 1
		anchored = 1
		var
			wood = 10
		New()
			wood = rand(8, 32)
			return ..()
		proc
			ActionLoop(mob/M)
				if(M.inHand(/item/weapon/axe))
					while(M && M.current_action == src && loc && wood > 0 && M.inHand(/item/weapon/axe))
						icon_state = "cut tree"
						sleep(10)
						icon_state = "tree"

						if(M && M.current_action == src && loc && wood > 0)
							var
								amount = wood >= 2 && M.skills && M.skills.gathering >= 35 && prob(M.skills.gathering) ? 2 : 1
								item/misc/wood/I = locate() in M
							if(prob(1) && M.skills && M.skills.gathering >= 35 && M.skills.gathering < 100) M.skills.gathering++
							if(I) I.stacked += amount
							else
								I = new(M)
								I.stacked += (amount - 1)
							wood -= amount
							if(wood <= 0)
								new/item/misc/seeds/Tree_Seeds(loc)
								Move(null, forced = 1)

							M.medal_Report("woodcutter")
						else break
						sleep(10)
				else
					while(M && M.current_action == src && loc && wood > 0 && M.inHand(/item/weapon/pickaxe))
						icon_state = "cut tree"
						sleep(25)
						icon_state = "tree"

						if(M && M.current_action == src && loc && wood > 0)
							var
								amount = wood >= 2 && M.skills && M.skills.gathering >= 35 && prob(M.skills.gathering) ? 2 : 1
								item/misc/tree_root/I = locate() in M
							if(prob(1) && M.skills && M.skills.gathering >= 35 && M.skills.gathering < 100) M.skills.gathering++
							if(I) I.stacked += amount
							else
								I = new(M)
								I.stacked += (amount + 1)
							wood -= (amount / 2)
							if(wood <= 0)
								new/item/misc/seeds/Tree_Seeds(loc)
								Move(null, forced = 1)

							M.medal_Report("woodcutter")
						else break
						sleep(10)
				if(M.current_action == src) M.AbortAction() //abort the action if we ran out of wood
		attack_hand(mob/M)
			if(!M.current_action && M.inHand(/item/weapon/axe))
				M.SetAction(src)
			else if(!M.current_action && M.inHand(/item/weapon/pickaxe))
				M.SetAction(src)
			/*if(M.inHand(/item/weapon/axe))
				if(usr.ActionLock("cutting", 10)) return
				if(ActionLock("cutting", 10))
					M.show_message("<tt>Someone else is already working on this tree!</tt>")
					return
				M.movable = 1
				icon_state = "cut tree"
				spawn(10)
					M.movable = 0
					if(!src || !src.loc) return
					icon_state = "tree"
					M.show_message("<tt>You cut the tree and get some wood!</tt>")

					var
						amount = M.chosen == "gatherer" && wood >= 2 ? 2 : 1
						item/misc/wood/I = locate() in M
					if(I) I.stacked += amount
					else
						I = new(M)
						I.stacked += (amount - 1)
					wood -= amount
					if(wood <= 0)
						new/item/misc/seeds/Tree_Seeds(loc)
						Move(null, forced = 1)

					M.medal_Report("woodcutter")*/
		void_tree
			icon = 'icons/Void Turfs.dmi'
		dead_tree
			icon = 'icons/deadtree.dmi'
	Palm_tree
		icon_state = "palm tree"
		density = 1
		anchored = 1
		var/wood = 10
		New()
			wood = rand(4, 16)
			return ..()
		proc
			ActionLoop(mob/M)
				while(M.current_action == src && loc && wood > 0 && M.inHand(/item/weapon/axe))
					icon_state = "palm tree"
					sleep(10)
					icon_state = "palm tree"

					if(M.current_action == src && loc && wood > 0)
						var
							amount = wood >= 2 && M.skills && M.skills.gathering >= 35 && prob(M.skills.gathering) ? 2 : 1
							item/misc/wood/I = locate() in M
						if(prob(1) && M.skills && M.skills.gathering >= 35 && M.skills.gathering < 100) M.skills.gathering++
						if(I) I.stacked += amount
						else
							I = new(M)
							I.stacked += (amount - 1)
						wood -= amount
						if(wood <= 0)
							new/item/misc/seeds/Palm_Seeds(loc)
							Move(null, forced = 1)

						M.medal_Report("woodcutter")
					else break
					sleep(10)
				if(M.current_action == src) M.AbortAction() //abort the action if we ran out of wood
		attack_hand(mob/M)
			if(!M.current_action && M.inHand(/item/weapon/axe))
				M.SetAction(src)
		/*attack_hand(mob/M)
			if(M.inHand(/item/weapon/axe))
				if(usr.ActionLock("cutting", 10)) return
				if(ActionLock("cutting", 10))
					M.show_message("<tt>Someone else is already working on this tree!</tt>")
					return
				M.movable = 1
				icon_state = "palm tree"
				spawn(10)
					M.movable = 0
					if(!src || !src.loc) return
					icon_state = "palm tree"
					M.show_message("<tt>You cut the tree and get some wood!</tt>")

					var
						amount = M.chosen == "gatherer" && wood >= 2 ? 2 : 1
						item/misc/wood/I = locate() in M
					if(I) I.stacked += amount
					else
						I = new(M)
						I.stacked += (amount - 1)
					wood -= amount
					if(wood <= 0)
						new/item/misc/seeds/Palm_Seeds(loc)
						Move(null, forced = 1)*/
	sand_clock
		name = "Sand Clock"
		icon = 'icons/sand_clock.dmi'
		density = 1
		anchored = 1
		layer = FLY_LAYER
		var
			count = 0
			minutes
		attack_hand(mob/M)
			icon_state = ""
			flick("rotate", src)
			spawn(8)
				flick("going", src)
				var/count = ++src.count
				for(var/i = 0 to 5)
					minutes = i
					sleep(600)
					if(count != src.count) break
				if(count == src.count) minutes = null
				//var/count = ++src.count
				/*spawn(1500)
					if(count == src.count)*/
		verb
			examine()
				set src in view(usr)
				usr << "\icon[src] <b>Sand Clock</b>"
				if(!isnull(minutes))
					usr << "\t About [usr.chosen == "librarian" ? minutes : rand(minutes - 1, minutes + 1)] minutes have passed."
				else usr << "\t All the sand is at the bottom of the clock."
	statue_top
		icon_state = "statuetop"
		Bovinia
			name = "Bovinia Statue"
	statue
		icon_state = "statue"
		paintable = 1
		Bovinia
			name = "Bovinia Statue"
	glass_plate
		icon = 'icons/Turfs.dmi'
		icon_state = "glass_plate"
		name = "glass plating"
		anchored = 1
	chandlier
		icon = 'icons/Turfs.dmi'
		icon_state = "chandlier"
		layer = FLY_LAYER
		luminosity = 6
		anchored = 1
		mouse_opacity = 0