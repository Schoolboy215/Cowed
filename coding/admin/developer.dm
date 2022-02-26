admin/dev/verb
	gedit(var/player/O in global.admin.players)
		set category = null
		set name = "gEdit"
		set desc="(target) Edit a target item's variables"
		var/variable = input("Which variable?","Var") in O.vars
		var/default
		var/typeof = O.vars[variable]
		var/dir
		if(isnull(typeof))
			send_message(usr, "<font size=1>Unable to determine variable type.", 3)
		else if(isnum(typeof))
			send_message(usr, "<font size=1>Variable appears to be <b>NUM</b>.", 3)
			default = "num"
			dir = 1
		else if(istext(typeof))
			send_message(usr, "<font size=1>Variable appears to be <b>TEXT</b>.", 3)
			default = "text"
		else if(isloc(typeof))
			send_message(usr, "<font size=1>Variable appears to be <b>REFERENCE</b>.", 3)
			default = "reference"
		else if(isicon(typeof))
			send_message(usr, "<font size=1>Variable appears to be <b>ICON</b>.", 3)
			typeof = "\icon[typeof]"
			default = "icon"
		else if(istype(typeof,/atom) || istype(typeof,/datum))
			send_message(usr, "<font size=1>Variable appears to be <b>TYPE</b>.", 3)
			default = "type"
		else if(istype(typeof,/list))
			send_message(usr, "<font size=1>Variable appears to be <b>LIST</b>.", 3)
			send_message(usr, "<font size=1>*** This function is not possible ***", 3)
			default = "cancel"
		else if(istype(typeof,/client))
			send_message(usr, "<font size=1>Variable appears to be <b>CLIENT</b>.", 3)
			send_message(usr, "<font size=1>*** This function is not possible ***", 3)
			default = "cancel"
		else
			send_message(usr, "<font size=1>Variable appears to be <b>FILE</b>.", 3)
			default = "file"
		send_message(usr, "<font size=1>Variable contains: [typeof]", 3)
		if(dir)
			switch(typeof)
				if(1)
					dir = "NORTH"
				if(2)
					dir = "SOUTH"
				if(4)
					dir = "EAST"
				if(8)
					dir = "WEST"
				if(5)
					dir = "NORTHEAST"
				if(6)
					dir = "SOUTHEAST"
				if(9)
					dir = "NORTHWEST"
				if(10)
					dir = "SOUTHWEST"
				else
					dir = null
			if(dir)
				send_message(usr, "<font size=1>If a direction, direction is: [dir]", 3)
		var/class = input("What kind of variable?","Variable Type",default) in list("text",
			"num","type","reference","icon","file","restore to default","cancel")
		var/new_value
		switch(class)
			if("cancel")
				return
			if("restore to default")
				new_value = initial(O.vars[variable])
			if("text")
				new_value = input("Enter new text:","Text",\
					O.vars[variable]) as text
			if("num")
				new_value = input("Enter new number:","Num",\
					O.vars[variable]) as num
			if("type")
				new_value = input("Enter type:","Type") \
					in typesof(/obj,/mob,/area,/turf)
			if("reference")
				new_value = input("Select reference:","Reference",\
					O.vars[variable]) as mob|obj|turf|area in world
			if("file")
				new_value = input("Pick file:","File") \
					as file
			if("icon")
				new_value = input("Pick icon:","Icon") \
					as icon

		if(variable == "name" && (!trimAll(new_value) || trimAll(new_value) == " ")) return
		global.admin.AddLog(usr.key, "Modified [O.name]'s [variable] from [O.vars[variable]] to [new_value]")
		O.vars[variable] = new_value

	Shutdown()
		set name = "shutdown"
		set category = "Admin"
		set desc = "Shut the server down or abort a server shutdown in progress."
		if((global.admin.flags & global.admin.FLAG_SHUTDOWN) ||\
		   (alert(usr, "Are you sure you wish to shut the server down?", "Shutdown", "Yes", "No") == "Yes"))
			global.admin.shutdown2(usr.key)

	award_datas_brow(mob/M in world)
		set category = "Admin"
		M.medal_Award("The Data's Brow Award")
	take_datas_brow(mob/M in world)
		set category = "Admin"
		M.medal_Remove("The Data's Brow Award")
	award_vigilante(mob/M in world)
		set category = "Admin"
		M.medal_Award("Vigilante")
	take_vigilante(mob/M in world)
		set category = "Admin"
		M.medal_Remove("Vigilante")
	take_vanity_medal(mob/M in world)
		set category = "Admin"
		M.medal_Remove("Vanity Rules")
	give_medal(mob/M in world, medal as text)
		set category = "Admin"
		M.medal_Award(medal)
	take_medal(mob/M in world, medal as text)
		set category = "Admin"
		M.medal_Remove(medal)
	data_mage()
		set hidden = 1
		new/item/armour/body/rmage_cloths(usr)
		new/item/armour/hat/rmage_hat(usr)
		new/item/weapon/staff(usr, usr, "Purple")
		new/item/armour/body/mage_cloths(usr)
		new/item/armour/hat/mage_hat(usr)
		new/item/weapon/bstaff/portal_staff(usr)
	sight_override()
		set category=null
		usr.sight_override = !usr.sight_override
		if(usr.sight_override) usr.sight = 60
	grand_spells(mob/M in world)
		set category = "Admin"
		if(!M) return
		if(M.mage) usr << "[M] is already a wizard!"
		else M.make_wizard("purple")
		for(var/X in list(/spell/building, /spell/lockpick, /spell/zap, /spell/teleport))
			var/spell/S
			for(S in M.spells)
				if(S.type == X) break
			if(!S)
				M.learn_spell(X)