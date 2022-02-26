proc
	add_layer(character_handling/container/kingdom, up = 1)
		var
			z = ++world.maxz
			map_object/O = new(locate(1, 1, z))
		O.kingdom = kingdom
		O.map_layer = up ? MaxLayer(kingdom) : MinLayer(kingdom)
		up ? O.map_layer++ : O.map_layer--
		O.name = "[kingdom.name]- '[O.map_layer]'"
		return O.z
	layer_distance(top, bottom)
		var
			layer1 = MapLayer(top)
			layer2 = MapLayer(bottom)
		if(layer1 > layer2) return layer1 - layer2
		return layer2 - layer1
	next_layer(z)
		var/map_object/O = MapObject(z)
		if(O)
			return O.NextLayer()
	lower_layer(z)
		var/map_object/O = MapObject(z)
		if(O)
			return O.PrevLayer()
turf
	proc
		lower_turf()
			var/map_object/O = lower_layer(src.z)
			if(O)
				var/turf/T = locate(x, y, O.z)
				if(istype(T, /turf/sky) || T.type == /turf) return T.lower_turf()
				return T
		opaque() // whether this turf is opaque, needed for looking down
			if(opacity)
				return 1
			for(var/atom/A in src) if(A.opacity)
				return 1
			return 0

atom
	proc/update_sky()
		if(MapLayer(z) >= 1)
			for(var/turf/T in view(src, 8))
				if(T.type == /turf || T.type == /turf/underground/dirtwall)
					new/area/darkness/sky(T)
					var/turf/sky/S=new(T)
					S.Update()


turf/sky
	icon = 'icons/grid.dmi'
	var/can_build = 0
	var/updating = 0
	New()
		. = ..()
		Update()
	Entered(atom/movable/A)
		var/turf/fall_to = lower_turf()
		A.Move(fall_to, forced = 1)

		if(istype(A, /mob))
			var/mob/M = A
			if(layer_distance(z, fall_to.z) >= 3) M.medal_Award("Vertigo")

			M.HP -= 4 * (layer_distance(z, fall_to.z) - 1) ** 2
			if(layer_distance(z, fall_to.z) - 1 > 0)
				A << "You take some damage as you fall onto the ground."
				M.last_hurt = "fall"
			if(M.HP <= 0) M.HP = 0
			M.checkdead(M)

			if(M.whopull && get_dist(M, M.whopull) <= 1 && !M.whopull.anchored)
				M.whopull.Move(fall_to, forced = 1)
				M = M.whopull
				if(istype(M))
					if(layer_distance(z, fall_to.z) >= 3) M.medal_Award("Vertigo")
					M.HP -= 4 * (layer_distance(z, fall_to.z) - 1) ** 2
					if(layer_distance(z, fall_to.z) - 1 > 0)
						M << "You take some damage as you fall onto the ground."
						M.last_hurt = "fall"
					if(M.HP <= 0) M.HP = 0
					M.checkdead(M)
	proc
		Update()
			if(!updating)
				if(!istype(src,/turf/sky)) return
				var/turf/T = lower_turf()
				if(!T) return
				if(layer_distance(z, T.z) == 1)
					var/turf/E
					for(E in range(1, T))
						if(istype(E, /turf/stone/stone_wall) || istype(E, /turf/wooden/wood_wall) || istype(E, /turf/sky/hole))
							break
					if(!E && (istype(T, /turf/stone) || istype(T, /turf/wooden) || istype(T, /turf/sky/hole))) E = T
					if(E)
						icon_state = "can_build"
						can_build = 1
					else
						icon_state = ""
						can_build = 0
				else
					icon_state = "damage"
					can_build = 0
	hole
		icon = 'icons/Turfs.dmi'
		icon_state = "hole2sky"
		Update()
			can_build = 0
			var/turf/T = lower_turf()
			if(istype(T, /turf/stone)) icon_state = "hole2sky2"
			else icon_state = "hole2sky"
			return

proc/refresh_sky(atom/A)
	if(map_loaded)
		var/turf/sky/S = locate(A.x,A.y,next_layer(A.z))
		for(var/turf/sky/T in range(S, 4)) T.Update()