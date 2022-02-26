var/list/spincache = list()
/*mob/proc/breakdance(var/speed = 3)
	var/icon/I = new(icon)
	for(var/item/E in my_overlays)
		spawn()
			if(usr.rhand == E)
				E.icon=E.L_ICON
			var/list/L = getspins(E.icon)
			overlays -= E
			var/image/newoverlay = image(icon = E.icon, icon_state = E.icon_state, layer = E.layer, dir = E.dir)
			for(var/v = 1, v <= 3, v++)
				newoverlay.icon = L[v]
				overlays += newoverlay
				sleep(speed)
				overlays -= newoverlay
			overlays += E
			if(usr.rhand == E)
				E.icon=E.R_ICON
	I.Turn(90)
	usr.icon = I
	step(usr,usr.dir)
	sleep(3)
	I.Turn(90)
	usr.icon = I
	step(usr,usr.dir)
	sleep(3)
	I.Turn(90)
	usr.icon = I
	step(usr,usr.dir)
	sleep(3)
	I.Turn(90)
	usr.icon = I
	step(usr,usr.dir)
	rolling = 0
	return*/
obj/Fireball
	icon='icons/Turfs.dmi'
	icon_state="Fireball"
	density=1
	var/stepleft=5
	New()
		spawn for()
			step(src,src.dir)
			sleep(2)
			src.stepleft-=1
			if(src.stepleft==0)
				del src
	Bump(mob/M)
		if(istype(M))
			M.HP-=30
			M.last_hurt = "fire"
			M.checkdead(M)
			hud_main.UpdateHUD(M)
			M<<"<font color=red><b>Ouch! Fireballs!"
			admin.AddChatLog(M.key, M.name, "Hit by a fireball.", "event")
			del src
obj/Iceball
	icon='icons/Turfs.dmi'
	icon_state="Iceball"
	density=1
	var/stepleft=5
	New()
		spawn for()
			step(src,src.dir)
			sleep(2)
			src.stepleft-=1
			if(src.stepleft==0)
				del src
	Bump(mob/M)
		if(istype(M))
			M.HP-=30
			M.last_hurt = "ice"
			M.checkdead(M)
			hud_main.UpdateHUD(M)
			M<<"<font color=red><b>Ouch! Iceballs!"
			admin.AddChatLog(M.key, M.name, "Hit by an iceball.", "event")
			del src
obj/Electrozap
	icon='icons/Turfs.dmi'
	icon_state="Electrozap"
	density=1
	var/stepleft=5
	New()
		spawn for()
			step(src,src.dir)
			sleep(2)
			src.stepleft-=1
			if(src.stepleft==0)
				del src
	Bump(mob/M)
		if(istype(M))
			M.HP-=5
			M.last_hurt = "zap"
			M.checkdead(M)
			M.stunned = max(M.stunned, 10)
			hud_main.UpdateHUD(M)
			M<<"<font color=red><b>Ouch! Electricity!"
			admin.AddChatLog(M.key, M.name, "Hit by a zap blast.", "event")
			del src

proc/getspins(var/icon/i)
	if( !(i in spincache) )
		var/list/L = list()
		for(var/v = 90, v <= 270, v += 90)
			L += turn(i, v)
		spincache[i] = L
	return spincache[i]
mob
	var/list/my_overlays = list()
	proc/UpdateOverlays()
		overlays = list() // Clear out the overlays list.
		for(var/obj/O in my_overlays)
			overlays += O
	proc/TurnOverlays(angle)
		for(var/obj/E in my_overlays)
			E.icon = turn(E.icon,90)
mob
	var
		last_x
		last_y
		last_z
		atom/movable/whopull

mob/var/rolling = 0
obj
	seeded_soil
		icon_state="seeded soil"
		anchored = 1
		attack_hand(mob/M)
			if(M.inHand(/item/weapon/shovel))
				var/count = M.moveCount
				send_message(hearers(M), "<small>[M.name] starts to dig up the soil.</small>", 1)
				spawn(20)
					if(M.moveCount != count) return
					send_message(hearers(M), "<small>[M.name] digs up the soil.</small>", 1)
					new/turf/path(loc)
					Move(null, forced = 1)
			else return ..()