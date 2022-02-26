obj/mage_containment
	name = "Magic Containment Unit"
	icon = 'icons/mage_containment.dmi'
	icon_state = "neutral"
	density = 1
	anchored = 1
	var
		capacity = 30000
		charge = 15000

		obj
			objS2
			objS3
			objS4
			objS5
			objN1
			objN2
			objN3
			objN4
			objN5
	New()
		. = ..()
		RelocateObjs()
		UpdateIcon()
	Move(turf/newloc, newdir, forced = 0)
		. = ..()
		RelocateObjs()
	proc
		UpdateIcon()
			overlays = list()
			var/perc = charge / (capacity / 100)
			if(perc > 100) overlays += image(icon = 'icons/mage_containment.dmi', icon_state = "stat4")
			else if(perc > 75) overlays += image(icon = 'icons/mage_containment.dmi', icon_state = "stat3")
			else if(perc > 50) overlays += image(icon = 'icons/mage_containment.dmi', icon_state = "stat2")
			else if(perc > 25) overlays += image(icon = 'icons/mage_containment.dmi', icon_state = "stat1")
			else overlays += image(icon = 'icons/mage_containment.dmi', icon_state = "stat0")

			overlays += image(icon = 'icons/mage_containment.dmi', icon_state = "lever-in")
			overlays += image(icon = 'icons/mage_containment.dmi', icon_state = "lever-out")
		RelocateObjs()
			for(var/V in list("objS2", "objS3", "objS4", "objS5", "objN1", "objN2", "objN3", "objN4", "objN5"))
				if(!vars[V])
					var/obj/O = new
					O.density = 1
					O.anchored = 1
					O.name = " "
					vars[V] = O

			objS2.Move(locate(src.x + 1, src.y, src.z), forced = 1)
			objS3.Move(locate(src.x + 2, src.y, src.z), forced = 1)
			objS4.Move(locate(src.x + 3, src.y, src.z), forced = 1)
			objS5.Move(locate(src.x + 4, src.y, src.z), forced = 1)
			objN1.Move(locate(src.x, src.y + 1, src.z), forced = 1)
			objN2.Move(locate(src.x + 1, src.y + 1, src.z), forced = 1)
			objN3.Move(locate(src.x + 2, src.y + 1, src.z), forced = 1)
			objN4.Move(locate(src.x + 3, src.y + 1, src.z), forced = 1)
			objN5.Move(locate(src.x + 4, src.y + 1, src.z), forced = 1)