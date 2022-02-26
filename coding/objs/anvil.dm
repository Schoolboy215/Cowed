obj/anvil
	icon = 'icons/Anvil.dmi'
	anchored = 1
	density = 1
	attack_hand(mob/M)
		if(M.shackled || M.movable || M.restrained() || M.icon_state == "ghost") return
		if(M.chosen != "blacksmith")
			M.show_message("<tt>You can't use this; you must be a blacksmith!</tt>")
			return
		var/list/L = new/list()
		var/item/misc/I = locate(/item/misc/molten_iron) in M.contents
		if(I)
			L += list("Iron Sword", "Shackles", "Leg Shackles", "Iron Helm", "Iron Helm Top", "Iron Plate")
		I = locate(/item/misc/molten_copper) in M.contents
		if(I) L += list("Copper Plate")
		I = locate(/item/misc/molten_gold) in M.contents
		if(I)
			L += list("Gold Sword", "Gold Helm", "Gold Helm Top", "Gold Plate")
		if(!L || !L.len)
			M.show_message("<tt>You need either molten iron, molten copper, or molten gold to use this!</tt>")
			return
		var/choice = input(M, "Select an item to craft.", "Anvil :: Select Item") as null|anything in L
		if(choice == null) return
		if(dd_hasprefix(choice, "Gold ")) I = locate(/item/misc/molten_gold, M)
		else if(dd_hasprefix(choice, "Copper ")) I = locate(/item/misc/molten_copper, M)
		else I = locate(/item/misc/molten_iron, M)
		if(!I)
			M.show_message("<tt>It seems you no longer have the ability to create that!</tt>")
			return

		if(--I.stacked <= 0) I.Move(null, forced = 1)
		for(var/mob/N in hearers(M))
			N.show_message("\blue [M.name] starts to smith \an [lowertext(choice)].")
		spawn(20)
			if(prob(20 + (istype(I, /item/misc/molten_gold) ? 10 : 35)))
				for(var/mob/N in hearers(M))
					N.show_message("\blue [M.name] successfully crafts \an [lowertext(choice)].")
				switch(choice)
					if("Iron Sword") M.contents += new/item/weapon/iron_sword
					if("Shackles") M.contents += new/item/misc/shackles
					if("Leg Shackles") M.contents += new/item/misc/legshackles
					if("Iron Helm") M.contents += new/item/armour/face/iron_helm
					if("Iron Helm Top") M.contents += new/item/armour/hat/iron_helm_top
					if("Iron Plate") M.contents += new/item/armour/body/iron_plate

					if("Copper Plate") M.contents += new/item/armour/body/copper_plate

					if("Gold Sword") M.contents += new/item/weapon/gold_sword
					if("Gold Helm") M.contents += new/item/armour/face/gold_guard_helm
					if("Gold Helm Top") M.contents += new/item/armour/hat/gold_guard_helm_top
					if("Gold Plate") M.contents += new/item/armour/body/gold_guard_plate
			else
				for(var/mob/N in hearers(M))
					N.show_message("\blue [M.name] fails to craft \an [lowertext(choice)].")