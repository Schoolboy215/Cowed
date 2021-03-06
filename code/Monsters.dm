mob
	var/isMonster=0
	var/OLDICON
	var/infection=0
mob/Zombie
	icon='icons/Zombie.dmi'
	icon_state="alive"
	HP=30
	defence=1
	isMonster=1
	New()
		..()
		src.Zombie()
mob/Frogman
	icon='icons/Frogman.dmi'
	icon_state="alive"
	HP=100
	defence=2
	isMonster=1
	New()
		..()
		src.Frog()

mob/proc/Zombie()
	usr=src
	spawn(30) Zombie()
	var/mob/m
	for(var/mob/M in oview(10))
		if(M.name!="Zombie"&&M.isMonster==0)
			m=M
	if(m&&src.legshackled==0)
		step_towards(src,m)
	else if(src.legshackled==0)
		step_rand(src)
	for(var/turf/T in oview(1))
		if(T.density == 1&&istype(T,/turf/wooden/))
			for(var/mob/N in ohearers(src))
				N.show_message("[src] attacks [T].")
			var/turf/wooden/t=T
			t.buildinghealth-=1
			if(t.buildinghealth==0)
				new/turf/path(locate(t.x,t.y,t.z))
			break
	for(var/mob/M in oview(1))
		if(M.name!="Zombie"&&!findtext(M.name,"corpse"))
			if(src.shackled==0&&M.isMonster==0)
				for(var/mob/N in ohearers(src))
					N.show_message("[src] attacks [M].")
				M.HP-=3
				M.last_hurt = "zombie"
				if(prob(100-usr.HP)&&infection_mode)
					M.infection+=1
					if(M.infection==1)
						world<<"<b>[M] has been infected!"
				M.checkdead(M)
				hud_main.UpdateHUD(M)
				break
mob/proc/Frog()
	usr=src
	spawn(20) Frog()
	if (HP <= 0) return
	var/mob/m
	for(var/mob/M in oview(10))
		if(M.name!="Frogman"&&M.isMonster==0)
			m=M
	if(m&&src.legshackled==0)
		step_towards(src,m)
	else if(src.legshackled==0)
		step_rand(src)
	for(var/mob/M in oview(1))
		if(M.name!="Frogman"&&!findtext(M.name,"corpse"))
			if(src.shackled==0&&M.isMonster==0)
				for(var/mob/N in ohearers(src))
					N.show_message("[src] attacks [M].")
				M.HP-=7
				M.last_hurt = "frog"
				M.checkdead(M)
				hud_main.UpdateHUD(M)
				break
	if(prob(1) && HP > 0)
		var/A=pick("Crooooooooak...","I will get you!","Viva la Frogs!","FROG NATION!")
		hearers(src)<<"<font color=green>Frogman says: [A]"
mob/proc/msntr()
	usr=src
	spawn(10) msntr()
	var/mob/m
	for(var/mob/M in oview(5))
		if(M.name!="[src.name]"&&M.isMonster==0)
			m=M
	if(m&&src.legshackled==0)
		src.icon=src.OLDICON
		step_towards(src,m)
	else if(src.legshackled==0)
		src.icon='icons/Void Turfs.dmi'
	for(var/mob/M in oview(1))
		if(M.name!="[src.name]"&&!findtext(M.name,"corpse"))
			if(src.shackled==0&&M.isMonster==0)
				for(var/mob/N in ohearers(src))
					N.show_message("[src] attacks [M].")
				M.HP-=src.strength
				M.checkdead(M)
				hud_main.UpdateHUD(M)
				break
mob/Shroom
	icon='icons/shroom.dmi'
	icon_state="alive"
	HP=100
	defence=2
	isMonster=1
	New()
		..()
		src.Shroom()
mob/proc/Shroom()
	if(HP <= 0) return
	spawn(20) Shroom()
	var/mob/m
	for(var/mob/M in oview(10))
		if(M.name!="Shroom"&&M.isMonster==0)
			m=M
	if(m&&src.legshackled==0)
		step_towards(src,m)
	else if(src.legshackled==0)
		step_rand(src)
	for(var/mob/M in oview(1))
		if(M.name!="Shroom"&&!findtext(M.name,"corpse"))
			if(src.shackled==0&&M.isMonster==0)
				for(var/mob/N in ohearers(src))
					N.show_message("[src] attacks [M].")
				M.HP-=7
				checkdead(M)
				hud_main.UpdateHUD(src)
				break
