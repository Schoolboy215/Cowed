obj/vein
	icon = 'icons/ores_and_veins.dmi'
	icon_state = "empty"
	anchored = 1
	density = 1
	var
		consist
		amountleft
		orename
		hp = 5
	New()
		. =..()
		if(type == /obj/vein)
			var/typechosen = rand(1,11)
			switch(typechosen)
				if(1 to 5)
					new/obj/vein/Copper_Vein(src.loc)
				if(6 to 8)
					new/obj/vein/Tin_Vein(src.loc)
				if(9 to 10)
					new/obj/vein/Iron_Vein(src.loc)
				if(11)
					new/obj/vein/Gold_Vein(src.loc)
			loc = null
		else if(!amountleft) amountleft = rand(20, 30)
	proc
		ActionLoop(mob/M)
			while(M && M.current_action == src && loc && amountleft > 0 && M.inHand(/item/weapon/pickaxe))
				for(var/mob/N in hearers(M))
					N.show_message("<b>[M.name]</b> swings [M.gender == FEMALE ? "her" : "his"] pickaxe at the [src]...")
				sleep(10)
				if(M && M.current_action == src && loc && amountleft > 0)
					amountleft--
					if(prob(60))
						if((M.skills && M.skills.mining >= 35 && prob(M.skills.mining) && prob(40)) || prob(3))
							M.show_message("<tt>You have found a <b>fire stone</b>!</tt>")
							M.contents += new/item/misc/fire_stone(M)
						else
							M.show_message("<tt>You have found some <b>stone</b>!</tt>")
							M.contents += new/item/misc/stone(M)
							if(M.skills && M.skills.gathering >= 35 && prob(M.skills.gathering - 5))
								M.contents += new/item/misc/stone(M)
							if(prob(1) && M.skills && M.skills.gathering >= 35 && M.skills.gathering < 100) M.skills.gathering++
						if(prob(1) && M.skills && M.skills.mining >= 35 && M.skills.mining < 100) M.skills.mining++
					else
						if(prob(1) && M.skills && M.skills.mining >= 35 && M.skills.mining < 100) M.skills.mining++
						M.show_message("<tt>You have found <b>[orename]</b>!</tt>")
						if(M.chosen == "gatherer") M.contents += new src.consist
						M.contents += new src.consist
					M.movable = 0
					if(amountleft <= 0) loc = null
				else break
				sleep(10)
			if(M && M.current_action == src) M.AbortAction() //abort the action if we ran out of wood
	attack_hand(mob/M)
		if(M.inHand(/item/weapon/pickaxe))
			if(!M.current_action) M.SetAction(src)
		/*if(M.inHand(/item/weapon/pickaxe))
			M.movable = 1
			for(var/mob/N in hearers(M))
				N.show_message("<b>[M.name]</b> swings [M.gender == FEMALE ? "her" : "his"] pickaxe at the [src]...")
			spawn(10)
				amountleft--
				if(prob(60))
					if((M.chosen == "gatherer" && prob(12)) || prob(3))
						M.show_message("<tt>You have found a <b>fire stone</b>!</tt>")
						M.contents += new/item/misc/fire_stone(M)
					else
						M.show_message("<tt>You have found some <b>stone</b>!</tt>")
						M.contents += new/item/misc/stone(M)
				else
					M.show_message("<tt>You have found <b>[orename]</b>!</tt>")
					if(M.chosen == "gatherer") M.contents += new src.consist
					M.contents += new src.consist
				M.movable = 0
				if(amountleft <= 0) loc = null*/
		else if(M.inHand(/item/weapon/sledgehammer))
			if(--hp <= 0)
				for(var/mob/N in hearers(src))
					N.show_message("<tt>[M.name] smashes the vein to pieces!</tt>")
					Move(null, forced = 1)
			else
				for(var/mob/N in hearers(src))
					N.show_message("<tt>[M.name] hits the vein with [M.gender == FEMALE ? "her" : "his"] sledgehammer!</tt>")
		else
			M.show_message("<tt>You need to equip a pickaxe to mine for ore!</tt>")
	Gold_Vein
		icon_state="Golden Rocks"
		orename="Gold"
		consist=/item/misc/ores/gold_ore
	Iron_Vein
		icon_state="Iron Rocks"
		orename="Iron"
		consist=/item/misc/ores/iron_ore
	Copper_Vein
		icon_state="Copper Rocks"
		orename="Copper Rock"
		consist=/item/misc/ores/copper_ore
	Tin_Vein
		icon_state="Tin Rocks"
		orename="Tin"
		consist=/item/misc/ores/tin_ore