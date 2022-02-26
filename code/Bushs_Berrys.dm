mob/var/poisoned=0
obj
	bush
		name = "Berry Bush"
		icon = 'icons/Bushs.dmi'
		icon_state = "empty"
		anchored=1
		var/berrytype
		var/buildinghealth = 3
		attack_hand(mob/M)
			if(M.inHand(/item/weapon/axe))
				if(ActionLock("Destroy", 4)) return
				if(--buildinghealth > 0)
					send_message(hearers(M), "<tt>[M.name] cuts the [lowertext(initial(name))] with [M.gender == FEMALE ? "her":"his"] axe!</tt>", 1)
				else
					send_message(hearers(M), "<tt>[M.name] chops the [lowertext(initial(name))] down!</tt>", 1)
					Move(null, forced = 1)
			else return ..()
		New()
			. = ..()
			spawn
				var/berrymush=rand(0,5)
				if(berrymush==0)
					new/obj/bush/redbb(src.loc)
					del src
					return
				if(berrymush==1)
					new/obj/bush/bluebb(src.loc)
					del src
					return
				if(berrymush==2)
					new/obj/bush/yellowbb(src.loc)
					del src
					return
				if(berrymush==3)
					new/obj/bush/whitebb(src.loc)
					del src
					return
				if(berrymush==4)
					new/obj/bush/greenbb(src.loc)
					del src
					return
				if(prob(20))
					new/obj/bush/blackbb(src.loc)
					del src
					return

		var/berrys = 5
		verb/Get_Berry()
			set src in view(1)
			if(usr.CheckGhost() || usr.corpse || !berrytype) return
			if(get_dist(src,usr)<=1)
				if(src.berrys < 1)
					usr.show_message("There are no more berries")
					return
				else
					usr.show_message("You pick a berry")
					src.berrys -= 1
					usr.contents+=new src.berrytype
					if(src.berrys < 1) src.icon_state = "empty"
		redbb
			berrytype=/item/misc/new_berries/red
			icon_state = "redbb"
			New()
				name = "Red Berry Bush"
				return
		bluebb
			berrytype=/item/misc/new_berries/blue
			icon_state = "bluebb"
			New()
				name = "Blue Berry Bush"
				return
		yellowbb
			berrytype=/item/misc/new_berries/yellow
			icon_state = "yellowbb"
			New()
				name="Yellow Berry Bush"
				return
		whitebb
			berrytype=/item/misc/new_berries/white
			icon_state = "whitebb"
			New()
				name="White Berry Bush"
				return
		blackbb
			berrytype=/item/misc/new_berries/black
			icon_state = "blackbb"
			New()
				name="Black Berry Bush"
				return
		greenbb
			berrytype=/item/misc/new_berries/green
			icon_state = "greenbb"
			New()
				name="Green Berry Bush"
				return