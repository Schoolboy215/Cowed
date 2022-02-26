obj
	sign
		name = "sign"
		icon_state = "sign"
		density=1
		anchored=1
		var/Message=""
		var/buildinghealth = 10
		attack_hand(mob/M)
			if(M.inHand(/item/weapon/axe))
				if(ActionLock("Destroy", 4)) return
				if(--buildinghealth > 0)
					send_message(hearers(M), "<tt>[M.name] chops the sign with [M.gender == FEMALE ? "her":"his"] axe!</tt>", 1)
				else
					send_message(hearers(M), "<tt>[M.name] cuts the sign down!</tt>", 1)
					Move(null, forced = 1)
		DblClick()
			if(get_dist(src,usr) <= 1 && usr.inHand(/item/weapon/axe)) return ..()
			usr << output(null, "sign.output")
			winset(usr, "sign", "title=\"[src.name]\"")
			winshow(usr, "sign")
			usr << output(censorText(src.Message), "sign.output")
		verb
			Engrave()
				set src in view(1)
				if(usr.shackled==1) return
				var/newmsg=input(usr,"What do you want to engrave?","Sign","[src.Message]") as message
				Message=newmsg
		Dungeon_Entrence
			name="Dungeon Ahead!"
			Message = "Welcome to the dungeon"
	gravestone
		name = "gravestone"
		icon = 'icons/turfs.dmi'
		icon_state = "gsign"
		density=1
		anchored=1
		var/Message=""
		var/buildinghealth = 10
		attack_hand(mob/M)
			if(M.inHand(/item/weapon/sledgehammer))
				if(ActionLock("Destroy", 4)) return
				if(--buildinghealth > 0)
					send_message(hearers(M), "<tt>[M.name] hits the gravestone with his sledgehammer!</tt>", 1)
				else
					send_message(hearers(M), "<tt>[M.name] smashes the gravestone down!</tt>", 1)
					Move(null, forced = 1)
		DblClick()
			if(get_dist(src,usr) <= 1 && usr.inHand(/item/weapon/sledgehammer)) return ..()
			usr << output(null, "sign.output")
			winset(usr, "sign", "title=\"[src.name]\"")
			winshow(usr, "sign")
			usr << output(censorText(src.Message), "sign.output")
		verb
			Engrave()
				set src in view(1)
				if(usr.shackled==1) return
				var/newmsg=input(usr,"What do you want to engrave?","Gravestone","[src.Message]") as message
				Message=newmsg
turf
	icon = 'icons/Turfs.dmi'
	proc/Destroy()
	table
		name = "table"
		icon_state = "table"
		density = 1
		var/buildinghealth = 5
		Enter(atom/movable/A)
			if(istype(A, /projectile) || istype(A, /obj/cannonball)) return 1
			return ..()
		attack_hand(mob/M)
			if(M.inHand(/item/weapon/axe))
				if(ActionLock("Destroy", 4)) return
				if(--buildinghealth > 0)
					send_message(hearers(M), "<tt>[M.name] chops the [lowertext(initial(name))] with [M.gender == FEMALE ? "her":"his"] axe!</tt>", 1)
				else
					send_message(hearers(M), "<tt>[M.name] smashes the [lowertext(initial(name))] down!</tt>", 1)
					var/turf/T = src
					src.Destroy()

					if(MapLayer(T.z) <= 0) new/turf/path(T)
					else new/turf/sky(T)
			else return ..()
		north
			icon_state = "table"
			dir = NORTH
			density = 1
		east
			icon_state = "table"
			dir = EAST
			density = 1
		south
			icon_state = "table"
			dir = SOUTH
			density = 1
		west
			icon_state = "table"
			dir = WEST
			density = 1
		alone
			icon_state = "tableA"
			density = 1
		northeast
			icon_state = "table"
			dir = NORTHEAST
			density = 1
		northwest
			icon_state = "table"
			dir = NORTHWEST
			density = 1
		southeast
			icon_state = "table"
			dir = SOUTHEAST
			density = 1
		southwest
			icon_state = "table"
			dir = SOUTHWEST
			density = 1
		middle
			icon_state = "tableM"
			density = 1
obj
	table
		anchored=1
		name = "table"
		icon_state = "table"
		density = 1
		var/buildinghealth = 5
		attack_hand(mob/M)
			if(M.inHand(/item/weapon/axe))
				if(ActionLock("Destroy", 4)) return
				if(--buildinghealth > 0)
					send_message(hearers(M), "<tt>[M.name] chops the [lowertext(initial(name))] with [M.gender == FEMALE ? "her":"his"] axe!</tt>", 1)
				else
					send_message(hearers(M), "<tt>[M.name] smashes the [lowertext(initial(name))] down!</tt>", 1)
					Move(null, forced = 1)
			else return ..()
		north
			icon_state = "table"
			dir = NORTH
			density = 1
		east
			icon_state = "table"
			dir = EAST
			density = 1
		south
			icon_state = "table"
			dir = SOUTH
			density = 1
		west
			icon_state = "table"
			dir = WEST
			density = 1
		alone
			icon_state = "tableA"
			density = 1
		northeast
			icon_state = "table"
			dir = NORTHEAST
			density = 1
		northwest
			icon_state = "table"
			dir = NORTHWEST
			density = 1
		southeast
			icon_state = "table"
			dir = SOUTHEAST
			density = 1
		southwest
			icon_state = "table"
			dir = SOUTHWEST
			density = 1
		middle
			icon_state = "tableM"
			density = 1
obj
	icon = 'icons/Turfs.dmi'
	chair
		icon_state = "chair"
		name = "chair"
		anchored = 0
		var/buildinghealth = 5
		attack_hand(mob/M)
			if(M.inHand(/item/weapon/axe))
				if(ActionLock("Destroy", 4)) return
				if(--buildinghealth > 0)
					send_message(hearers(M), "<tt>[M.name] chops the [lowertext(initial(name))] with [M.gender == FEMALE ? "her":"his"] axe!</tt>", 1)
				else
					send_message(hearers(M), "<tt>[M.name] smashes the [lowertext(initial(name))] down!</tt>", 1)
					Move(null, forced = 1)
			else return ..()
		verb/rotate()
			set src in view(1)
			if(usr.restrained()) return
			dir = turn(dir, 90)
			if(dir == SOUTH) layer = OBJ_LAYER
			else layer = MOB_LAYER + 10
		south
			dir = SOUTH
		north
			dir = NORTH
			layer = MOB_LAYER+10
		east
			dir = EAST
			layer = MOB_LAYER+10
		west
			dir = WEST
			layer = MOB_LAYER+10

turf
	wooden
		var/buildinghealth = 1
		New()
			. = ..()
			if(buildinghealth == 1)
				buildinghealth = rand(10,15)
			spawn refresh_sky(src)
		Destroy()
			. = ..()
			refresh_sky(src)
		attack_hand(mob/M)
			if(M.inHand(/item/weapon/axe))
				if(ActionLock("Destroy", 4)) return
				if(--buildinghealth > 0)
					send_message(hearers(M), "<tt>[M.name] chops the [lowertext(initial(name))] with [M.gender == FEMALE ? "her":"his"] axe!</tt>", 1)
				else
					send_message(hearers(M), "<tt>[M.name] smashes the [lowertext(initial(name))] down!</tt>", 1)
					var/turf/T = src
					src.Destroy()

					if(MapLayer(T.z) <= 0) new/turf/path(T)
					else new/turf/sky(T)
			else return ..()

		icon = 'icons/wood.dmi'
/*		staircase
			icon_state = "staircase"
			Entered()
				if(usr.z != worldz)
					usr.descend() */
		wood_window_wall
			icon_state = "none"
			density = 1
			name="windowed wood wall"
		wood_windowed_wall
			name="windowed wood wall"
			icon_state = "sclosed"
			density=1
			opacity=1
			Click()
				if(usr.shackled==1) return
				if(get_dist(src,usr) <= 1)
					if(icon_state == "sopen")
						icon_state = "sclosed"
						sd_SetOpacity(1)
					else
						icon_state = "sopen"
						sd_SetOpacity(0)
				..()
		wood_wall
			icon_state = "wall"
			density=1
			opacity=1
			attack_hand(mob/M)
				. = ..()
				if(!M.inHand(/item/weapon/axe)) usr.show_message("<tt>You push the wall but nothing happens!</tt>")
		wood_door
			var
				keyslot
				locked=0
				gold = 1
				mob/enchanted
			verb
				Knock()
					set src in oview(1)
					if(!(src in oview(1, usr)) || usr.restrained() || usr.CheckGhost()) return
					if(!ActionLock("knock", 5))
						hearers(src) << "\icon[src] *knock* *knock*"

			Inn_Door
				keyslot="inn"
				locked=1
				Inn_Door1
					keyslot="inn1"
				Inn_Door2
					keyslot="inn2"
				Inn_Door3
					keyslot="inn3"
				Inn_Door4
					keyslot="inn4"
				Inn_Door5
					keyslot="inn5"
				Inn_Door6
					keyslot="inn6"
				Inn_Door7
					keyslot="inn7"
				Inn_Door8
					keyslot="inn8"
				Inn_Door9
					keyslot="inn9"
				Inn_Door10
					keyslot="inn10"
				Inn_Door11
					keyslot="inn11"
				Inn_Door12
					keyslot="inn12"
				Inn_Door13
					keyslot="inn13"
				Inn_Door14
					keyslot="inn14"
			icon_state = "closed"
			density=1
			opacity=1
			attack_hand(mob/M)
				if(M.inHand(/item/weapon/axe)) return ..()
				if(locked == 1)
					M.show_message("It's locked!")
					return
				if(icon_state == "open")
					icon_state = "closed"
					sd_SetOpacity(1)
					density=1
				else
					icon_state = "open"
					density=0
					sd_SetOpacity(0)
		wood_floor
			buildinghealth = 2
			icon_state = "floor"
			New()
				var/obj/Weather/O=locate(src.loc)
				if(O)
					del O
		rope_bridge
			buildinghealth=5
			icon_state="bridge"
			attack_hand(mob/M)
				if(M.inHand(/item/weapon/axe))
					if(ActionLock("Destroy", 4)) return
					if(--buildinghealth > 0)
						send_message(hearers(M), "<tt>[M.name] chops the [lowertext(initial(name))] with [M.gender == FEMALE ? "her":"his"] axe!</tt>", 1)
					else
						send_message(hearers(M), "<tt>[M.name] smashes the [lowertext(initial(name))] down!</tt>", 1)
						var/turf/T = src
						src.Destroy()

						if(MapLayer(T.z) <= 0) new/turf/water(T)
						else new/turf/sky(T)
				else return ..()

	stone
		var/buildinghealth = 1
		New()
			. = ..()
			if(buildinghealth == 1)
				buildinghealth = rand(10,15)
			spawn refresh_sky(src)
		Destroy()
			. = ..()
			refresh_sky(src)
		attack_hand(mob/M)
			if(M.inHand(/item/weapon/sledgehammer))
				if(ActionLock("Destroy", 4)) return
				if(--buildinghealth > 0)
					send_message(hearers(M), "<tt>[M.name] hits the [lowertext(initial(name))] with [M.gender == FEMALE ? "her":"his"] sledgehammer!</tt>", 1)
				else
					send_message(hearers(M), "<tt>[M.name] smashes the [lowertext(initial(name))] down!</tt>", 1)
					var/turf/T = src
					src.Destroy()

					if(MapLayer(T.z) <= 0) new/turf/path(T)
					else new/turf/sky(T)
			else return ..()
		icon='icons/stone.dmi'
		stone_wall
			icon_state = "stone wall"
			density = 1
			opacity = 1
			attack_hand(mob/M)
				if(M.inHand(/item/weapon/sledgehammer)) return ..()
				usr.show_message("<tt>You push the wall but nothing happens!</tt>")
		stained_glass_window
			var/hits = 0
			icon_state = "stwindow"
			density = 1
			attack_hand(mob/M)
				if(icon_state != "stwindows" && M.inHand(/item/weapon/sledgehammer))
					if(ActionLock("Destroy", 4)) return
					if(--buildinghealth > 0)
						send_message(hearers(M), "<tt>[M.name] hits the [lowertext(initial(name))] with [M.gender == FEMALE ? "her":"his"] sledgehammer!</tt>", 1)
					else
						send_message(hearers(M), "<tt>[M.name] smashes the [lowertext(initial(name))]!</tt>", 1)
						icon_state = "stwindows"
						name = "shattered window"
				else return ..()
		stone_floor
			buildinghealth = 2
			icon_state = "stone floor8"
		stone_door
			var
				keyslot
				locked=0
				gold = 1
				mob/enchanted
			Guard_Door
				keyslot=1
				locked=1
			Royal_Guard_Door
				keyslot=2
				locked=1
			Royal_Archer_Door
				keyslot=3
				locked=1
			Cook_Door
				keyslot=4
				locked=1
			Cell_Door
				keyslot=5
				locked=0
			Royal_Room_Door
				keyslot=6
				locked=0
			Watchman_Door
				keyslot=7
				locked=1
			Noble_Guard_Door
				keyslot=8
				locked=1
			Noble_Archer_Door
				keyslot=9
				locked=1
			Chef_Door
				keyslot=10
				locked=1
			Dungeon_Door
				keyslot = "cow_jailer"
				locked=0
			Royal_Door
				keyslot=12
				locked=0
			Inn_Door
				locked=1
				Inn_Door1
					keyslot="inn1"
				Inn_Door2
					keyslot="inn2"
				Inn_Door3
					keyslot="inn3"
				Inn_Door4
					keyslot="inn4"
				Inn_Door5
					keyslot="inn5"
				Inn_Door6
					keyslot="inn6"
				Inn_Door7
					keyslot="inn7"
				Inn_Door8
					keyslot="inn8"
				Inn_Door9
					keyslot="inn9"
				Inn_Door10
					keyslot="inn10"
				Inn_Door11
					keyslot="inn11"
				Inn_Door12
					keyslot="inn12"
				Inn_Door13
					keyslot="inn13"
				Inn_Door14
					keyslot="inn14"
			Necromancer
				keyslot = "necromancer"

			icon_state = "closed"
			density=1
			opacity=1
			attack_hand(mob/M)
				if(M.inHand(/item/weapon/sledgehammer)) return ..()
				if(locked == 1)
					M.show_message("It's locked!")
					return
				if(icon_state == "open")
					icon_state = "closed"
					sd_SetOpacity(1)
					density=1
				else
					icon_state = "open"
					density=0
					sd_SetOpacity(0)
			verb
				Knock()
					set src in oview(1)
					if(!(src in oview(1, usr)) || usr.CheckGhost()) return
					if(!ActionLock("knock", 5))
						hearers(src) << "\icon[src] *knock* *knock*"
		stone_window_wall
			icon_state = "none"
			density = 1
			name="windowed stone wall"
		stone_windowed_wall
			name="windowed stone wall"
			icon_state = "sclosed"
			density=1
			opacity=1
			Click()
				if(usr.shackled==1) return
				if(get_dist(src,usr) <= 1)
					if(icon_state == "sopen")
						icon_state = "sclosed"
						sd_SetOpacity(1)
					else
						icon_state = "sopen"
						sd_SetOpacity(0)
				..()



obj
	wooden
		anchored=1
		fence
			name="Fence"
			icon_state = "fence"
			density=1
			buildinghealth=4
		gate
			name="Gate"
			icon_state = "fence close"
			density=1
			buildinghealth=4
			attack_hand(mob/M)
				if(M.inHand(/item/weapon/axe)) return ..()
				if(icon_state == "fence open")
					icon_state = "fence close"
					density=1
				else
					icon_state = "fence open"
					density=0
		var/buildinghealth = 1
		New()
			..()
			if(buildinghealth == 1)
				buildinghealth = rand(10,15)
		attack_hand(mob/M)
			if(M.inHand(/item/weapon/axe))
				if(ActionLock("Destroy", 4)) return
				if(--buildinghealth > 0)
					send_message(hearers(M), "<tt>[M.name] cuts the [lowertext(initial(name))] with [M.gender == FEMALE ? "her":"his"] axe!</tt>", 1)
				else
					send_message(hearers(M), "<tt>[M.name] chops the [lowertext(initial(name))] down!</tt>", 1)
					Move(null, forced = 1)
			else return ..()
		icon = 'icons/wood.dmi'
		wood_window_wall
			icon_state = "none"
			density = 1
			name="windowed wood wall"
		wood_windowed_wall
			name="windowed wood wall"
			icon_state = "sclosed"
			density = 1
			opacity=1
			Click()
				if(usr.shackled==1) return
				if(get_dist(src,usr) <= 1)
					if(icon_state == "sopen")
						icon_state = "sclosed"
						density = 1
						sd_SetOpacity(1)
					else
						icon_state = "sopen"
						density = 1
						sd_SetOpacity(0)
				..()
		wood_wall
			icon_state = "wall"
			density = 1
			opacity=1
			attack_hand(mob/M)
				if(M.inHand(/item/weapon/axe)) return ..()
				usr.show_message("<tt>You push the wall but nothing happens!</tt>")
		wood_door
			var
				keyslot
				locked=0
				gold = 1
				mob/enchanted
			icon_state = "closed"
			density = 1
			opacity=1
			attack_hand(mob/M)
				if(M.inHand(/item/weapon/axe)) return ..()
				if(locked == 1)
					M.show_message("It's locked!")
					return
				if(icon_state == "open")
					icon_state = "closed"
					sd_SetOpacity(1)
					density=1
				else
					icon_state = "open"
					density=0
					sd_SetOpacity(0)
			verb
				Knock()
					set src in oview(1)
					if(!(src in oview(1, usr)) || usr.CheckGhost()) return
					if(!ActionLock("knock", 5))
						hearers(src) << "\icon[src] *knock* *knock*"
		wood_floor
			buildinghealth = 2
			icon_state = "floor"

	stone
		anchored=1
		var/buildinghealth = 1
		New()
			if(buildinghealth == 1)
				buildinghealth = rand(10,15)
		attack_hand(mob/M)
			if(M.inHand(/item/weapon/sledgehammer))
				if(ActionLock("Destroy", 4)) return
				if(--buildinghealth > 0)
					send_message(hearers(M), "<tt>[M.name] hits the [lowertext(initial(name))] with [M.gender == FEMALE ? "her":"his"] sledgehammer!</tt>", 1)
				else
					send_message(hearers(M), "<tt>[M.name] smashes the [lowertext(initial(name))] down!</tt>", 1)
					Move(null, forced = 1)
			else return ..()
		icon='icons/stone.dmi'
		stone_wall
			icon_state = "stone wall"
			density = 1
			opacity = 1
			attack_hand(mob/M)
				if(M.inHand(/item/weapon/sledgehammer)) return ..()
				usr.show_message("<tt>You push the wall but nothing happens!</tt>")
		stained_glass_window
			var/hits = 0
			icon_state = "stwindow"
			density = 1
			attack_hand(mob/M)
				if(icon_state != "stwindows" && M.inHand(/item/weapon/sledgehammer))
					if(ActionLock("Destroy", 4)) return
					if(--buildinghealth > 0)
						send_message(hearers(M), "<tt>[M.name] hits the [lowertext(initial(name))] with [M.gender == FEMALE ? "her":"his"] sledgehammer!</tt>", 1)
					else
						send_message(hearers(M), "<tt>[M.name] smashes the [lowertext(initial(name))] down!</tt>", 1)
						icon_state = "stwindows"
						name = "shattered window"
				else return ..()
		stone_floor
			buildinghealth = 2
			icon_state = "stone floor8"
		stone_door
			var
				keyslot
				locked=0
				gold = 1
				mob/enchanted

			icon_state = "closed"
			density=1
			opacity=1
			attack_hand(mob/M)
				if(M.inHand(/item/weapon/sledgehammer)) return ..()
				if(locked == 1)
					M.show_message("It's locked!")
					return
				if(icon_state == "open")
					icon_state = "closed"
					sd_SetOpacity(1)
					density=1
				else
					icon_state = "open"
					density=0
					sd_SetOpacity(0)
			verb
				Knock()
					set src in oview(1)
					if(!(src in oview(1, usr)) || usr.CheckGhost()) return
					if(!ActionLock("knock", 5))
						hearers(src) << "\icon[src] *knock* *knock*"
		stone_window_wall
			icon_state = "none"
			density = 1
			name="windowed stone wall"
		stone_windowed_wall
			name="windowed stone wall"
			icon_state = "sclosed"
			density = 1
			opacity=1
			Click()
				if(usr.shackled==1) return
				if(get_dist(src,usr) <= 1)
					if(icon_state == "sopen")
						icon_state = "sclosed"
						sd_SetOpacity(1)
					else
						icon_state = "sopen"
						sd_SetOpacity(0)
				..()
turf
	Misc
		Void_Wall
			name = ""
			icon = 'Void Wall.dmi'
			icon_state = "stone floor8"
			density = 1
			opacity = 1