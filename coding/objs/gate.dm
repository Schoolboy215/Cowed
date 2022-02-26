obj/gate
	icon = 'icons/Turfs.dmi'
	anchored = 1
	var
		id
	gate
		name = "Gate"
		density = 1
		var
			buildinghealth = 120
		gate_l
			icon_state = "gate-l"
		gate_m
			icon_state = "gate-m"
			layer = FLY_LAYER
		gate_r
			icon_state = "gate-r"

		attack_hand(mob/M)
			if(M.inHand(/item/weapon/sledgehammer))
				if(ActionLock("Destroy", 4)) return
				if(--buildinghealth > 0)
					send_message(hearers(M), "<tt>[M.name] hits the gate with his sledgehammer!</tt>", 1)
				else
					send_message(hearers(M), "<tt>[M.name] smashes the gate down!</tt>", 1)
					for(var/obj/gate/gate/O in range(2, src))
						if(O.id == src.id)
							O.Move(null, forced = 1)
	lever
		icon_state = "lever0"
		attack_hand(mob/M)
			src.icon_state = src.icon_state == "lever0" ? "lever1" : "lever0"
			for(var/obj/gate/lever/O in world)
				if(O.z != src.z && O.z != undergroundz && O.z != worldz && O.z != skyz) continue
				if(O.id == src.id && O != src) O.icon_state = src.icon_state

			for(var/obj/gate/gate/O in world)
				if(O.z != src.z && O.z != undergroundz && O.z != worldz && O.z != skyz) continue
				if(O.id == src.id)
					O.icon_state = initial(O.icon_state)
					O.density = 1

					if(icon_state == "lever1") //open
						O.icon_state = "[O.icon_state]1"
						if(istype(O, /obj/gate/gate/gate_m)) O.density = 0