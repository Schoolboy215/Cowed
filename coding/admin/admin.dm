admin/admin/verb //WARNING: due to the way verbs are being added, "src" does NOT equal the parent /admin object!
	delete_book(var/title in global.admin.GetBooks())
		set category = "Admin"
		set desc = "Deletes a book by name."
		global.admin.DeleteBook(title)
		usr << "The book has been deleted."
		global.admin.AddLog(usr.key, "The book with title \"[title]\" has been deleted.")
	approve_book(var/title in global.admin.GetBooks())
		set category = "Admin"
		set desc = "Deletes a book by name."
		global.admin.ApproveBook(title)
		usr << "The book is now approved (if it wasn't already)."
		global.admin.AddLog(usr.key, "The book with title \"[title]\" has been approved.")

	viewscreen()
		set category = "Admin"
		set desc = "Open up the viewscreen window."
		if(!global.admin.admin_options[usr.ckey]["admin_viewscreen"])
			global.admin.admin_options[usr.ckey]["admin_viewscreen"] = new/admin_viewscreen
		var/admin_viewscreen/V = global.admin.admin_options[usr.ckey]["admin_viewscreen"]
		V.interact(usr)

	map_editor()
		set category = "Admin"
		set desc = "Open up the map editor screen."
		if(!usr.client.map_editor) usr.client.map_editor = new(usr.client)
		else del usr.client.map_editor

	list_bans()
		set category = "Admin"
		set desc = "View a list of banned users."
		var/list/L = global.admin.GetBans(1)
		if(L && L.len)
			usr << "Key - Admin - Reason"
			for(var/key in L)
				usr << "\t [key] - [L[key][1]] - [L[key][2]]"
		else usr << "The ban list is empty!"

	//prevent a player from joining or allow a player to join again
	ban(var/ckey as text, var/reason as text)
		set category = "Admin"
		set desc = "(target,reason) Ban a player from the server."
		if((ckey in global.admin.admins) || (ckey in developers))
			usr << "You can't ban administrators."
			return
		global.admin.AddBan(ckey, reason, usr.key)
	unban(var/ckey in global.admin.GetBans(), var/reason as text)
		set category = "Admin"
		set desc = "(target,reason) Unban a player (and all associates) from the server."
		global.admin.RemoveBan(ckey, reason, usr.key)

	//prevent a player from talking or allow a player to talk again
	mute(var/ckey as text, var/reason as text)
		set category = "Admin"
		set desc = "(target,reason) Mute a player for the duration of the current mode."
		if((ckey in global.admin.admins) || (ckey in developers))
			usr << "You can't mute administrators."
			return
		global.admin.AddMute(ckey, reason, usr.key)
	unmute(var/ckey in global.admin.GetMuted(), var/reason as text)
		set category = "Admin"
		set desc = "(target,reason) Allow a muted player to speak again."
		global.admin.RemoveMute(ckey, reason, usr.key)

	kick(var/client/C in clients, var/reason as text) //force a player to disconnect
		set category = "Admin"
		set desc = "(target,reason) Kick a player from the server."
		if((C.ckey in global.admin.admins) || (C.ckey in developers))
			usr << "You can't kick administrators."
			return
		AddLog(usr.key, "Kicked [C.key] from the server. Reason: [reason]")
		del C

	Reboot() //reboot the server, or abort a reboot in progress
		set name = "reboot"
		set category = "Admin"
		set desc = "Reboot the server or abort a reboot in progress."
		if((global.admin.flags & global.admin.FLAG_REBOOTING) ||\
		   (alert(usr, "Are you sure you wish to reboot the game?", "Reboot", "Yes", "No") == "Yes"))
			if(!(global.admin.flags & global.admin.FLAG_REBOOTING))
				global.admin.AddLog(usr.key, "Initiated a server reboot.")
			else
				global.admin.AddLog(usr.key, "Aborted the reboot in progress.")
			global.admin.reboot(usr.key)

	private_message(client/C in GetClients(1) - usr.client) //converse privately with a player
		set category = "Admin"
		if(C.pm)
			C.pm.addAdmin(src)
		else
			new/admin_pm(C, usr.client)

	toggle_mouse_movement() //toggle the mouse "telekinesis"
		set category = "Admin"
		if(!("mouse_movement" in admin.admin_options[usr.ckey]))
			admin.admin_options[usr.ckey]["mouse_movement"] = 0
		admin.admin_options[usr.ckey]["mouse_movement"] = !admin.admin_options[usr.ckey]["mouse_movement"]
		usr << "You can [admin.admin_options[usr.ckey]["mouse_movement"] ? "now" : "no longer"] move objects with the mouse."

	/*view_game_log()
		set category = "Admin"
		. = file2text(chat_log)
		if(length(.) > 524288)
			. = copytext(., length(.) - 524288)
		usr << browse(., "window=\ref[src]_log;size=500x300")*/

	list_multikeys() //list all players connected from the same IP
		set category = "Admin"
		var/list
			L = new/list()
			skip = new/list()
		for(var/client/C)
			if(C in skip) continue
			var/list/L2 = new/list()
			for(var/client/X)
				if(X == C) continue
				if(X.address == C.address || X.computer_id == C.computer_id)
					L2 += X.key
					skip += X
			if(L2.len) L[C.key] = L2
		if(L.len)
			send_message(usr, "<b>Players:</b>", 3)
			. = 0
			for(var/key in L)
				var/list/L2 = L[key]
				if(L2 && L2.len)
					send_message(usr, "\t [key]: [dd_list2text(L2, "; ")]", 3)
					.++
			send_message(usr, "<b>Total multikeyers:</b> [.]", 3)
		else
			send_message(usr, "Unable to find anyone who is multi-keying.", 3)
	announce(msg as message)
		set category="Admin"
		send_message(world, "<center><big><b><font color = blue>[usr.key] Announces <br>[msg]", 3)
		global.admin.AddLog(usr.key, "Announced \"[msg]\"")
	Color(atom/movable/A in world, c as color|null)
		set name = "color"
		set category = "Admin"
		A.icon = initial(A.icon)
		if (c)
			var/icon/I = icon(A.icon)
			I.Blend(c, ICON_MULTIPLY)
			I.Blend(c)
			A.icon = I
			global.admin.AddLog(usr.key, "Colorized [A] to [c].")
	custom(type in list("body", "face", "hat", "cloak", "hood", "weapon"))
		set category = "Admin"
		switch (type)
			if ("body") new/item/armour/body/custom(usr)
			if ("face") new/item/armour/face/custom(usr)
			if ("hat") new/item/armour/hat/custom(usr)
			if ("cloak") new/item/armour/cloak/custom(usr)
			if ("hood") new/item/armour/hood/custom(usr)
			if ("weapon") new/item/weapon/custom(usr)
		global.admin.AddLog(usr.key, "Created a custom [type].")
	warp(mob/M in world, mob/T in world)
		set category = "Admin"
		M.Move(T.loc, forced = 1)
		global.admin.AddLog(usr.key, "Moved [M.name][M.key ? " ([M.key])":] to [T.name][T.key ? " ([T.key])":].")
	make_vote()
		set category="Admin"
		if(vote_system.vote) return
		var/question = input("What will the question be?", "Question") as text
		var/list/options = list()
		var/option
		var/i = 0
		do
			if(option) options += option
			option = input(usr, "What will option #[++i] be?", "Option [i]") as null|text
		while(option != null && !vote_system.vote)

		if(vote_system.vote) return
		global.admin.AddLog(usr.key, "Initiated a custom vote. The question was \"[question]\"")
		var/vote_data/result = vote_system.Query(question, options)
		if(result.tie)
			var/list/tie_data = new/list()
			for(i in result.tie_list) tie_data += options[i]
			send_message(world, "<b>Tie!</b> between [dd_list2text(tie_data, "; ")]...", 3)
		global.admin.AddLog(usr.key, "The result to the vote was: \"[options[result.winner]]\"")
		send_message(world, "Result: <b>[options[result.winner]]</b>", 3)

	observe(mob/M in world)
		set category="Admin"
		if(M == usr)
			usr.client.eye = usr
			usr.client.perspective = MOB_PERSPECTIVE
		else
			usr.client.eye = M
			usr.client.perspective = EYE_PERSPECTIVE

	gmsay(msg as text)
		set category="Admin"
		if(!msg) return
		for(var/client/C)
			if(C.admin)
				C << "<b><font color=\"#848484\">[usr.key] GMSay: [html_encode(msg)]"
		admin.AddChatLog(usr.key, usr.name, html_encode(msg), "gmsay")
	revive(mob/M in world)
		set category="Admin"
		M.revive()
		global.admin.AddLog(usr.key, "Revived [M.name][M.key ? " ([M.key])":]")
	convert_mob(mob/M in world, var/race in list("Cow", "Zombie", "Skeleton", "Ghost"))
		set category = "Admin"
		if(M.type != /mob)
			send_message(usr, "<tt>You must select an active player!</tt>", 3)
			return

		if(race != "Ghost")
			for(var/spell/ghost/S in M.spells)
				M.remove_spell(S)

		switch(race)
			if("Cow") M.icon = 'icons/Cow.dmi'
			if("Zombie") M.icon = 'icons/Zombie.dmi'
			if("Skeleton") M.icon = 'icons/Skeleton.dmi'
			if("Ghost")
				if(M.state != "ghost")
					M.state = "ghost"
					M.icon = 'icons/GhostCorporeal.dmi'
					M.UpdateClothing()
					M.learn_spell(/spell/ghost, 1)
		global.admin.AddLog(usr.key, "Converted [M.name][M.key ? "([M.key])":] into a [lowertext(race)].")
	player_check()
		set category="Admin"
		set desc="Check player IPs and Keys"
		send_message(usr, "<font color=#105090>Player Information:", 3)
		for(var/mob/M in world)
			if(M.client)
				send_message(usr, "<font color=#105090>  Name: [M.name]. Key: [M.key]. Address: [M.client.address].", 3)
	check_owner(atom/O in range(usr))
		set category = "Admin"
		usr << "<tt>[O] ([O.type] [O.building_owner ? "was created by [O.building_owner]" : "is not player-made"].</tt>"
		if(istype(O, /obj/chest))
			var/obj/chest/C = O
			if(C.opened_by && C.opened_by.len)
				usr.show_message("<tt>The following keys have opened or unlocked this chest:</tt>")
				for(var/key in C.opened_by)
					usr.show_message("\t <tt>[key]</tt>")
				usr.show_message("<tt><b>Note:</b> This is a list of players who have opened or unlocked the chest. It does not necessarily say who did what to the items within. Don't speculate; get the facts!</tt>")
			else
				usr.show_message("<tt>This chest has not been opened by anyone since its creation.</tt>")
	check_denied_scores()
		set category = "Admin"
		var/list/L = ScoreDenied()
		if(L && L.len)
			usr << "<tt>The following ckeys will not have their scores updated:</tt>"
			for(var/X in L)
				usr << "\t <tt>[X]</tt>"
		else
			usr << "<tt>There are no ckeys in the deny_score.txt file.</tt>"
	check_denied_medals()
		set category = "Admin"
		var/list/L = MedalDenied()
		if(L && L.len)
			usr << "<tt>The following ckeys will not be awarded any medals:</tt>"
			for(var/X in L)
				usr << "\t <tt>[X]</tt>"
		else
			usr << "<tt>There are no ckeys in the deny_medal.txt file.</tt>"
	create(var/type in typesof(/atom))
		set category = "Admin"
		new type(usr.loc)
		global.admin.AddLog(usr.key, "Created object of type [type]")
	spawn_in_inventory(var/type in typesof(/item))
		set category = "Admin"
		new type(usr)
		global.admin.AddLog(usr.key, "Spawned object of type [type]")
	delete(obj/O as obj|mob|turf in world)
		set category = null
		var/mob/M = O
		if(istype(M) && M.key)
			if((M.ckey in developers) && !(usr.ckey in developers))
				del usr
				return
		global.admin.AddLog(usr.key, "Deleted object [O.name] at [O.x],[O.y],[O.z]")
		del O
	edit(atom/O in world)
		set category = null
		set name = "Edit"
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

		if(istype(O, /atom/movable) && (variable == "x" || variable == "y" || variable == "z"))
			var
				x = variable == "x" ? new_value : O.x
				y = variable == "y" ? new_value : O.y
				z = variable == "z" ? new_value : O.z
				turf/T = locate(x, y, z)
				atom/movable/A = O
			global.admin.AddLog(usr.key, "Modified [O.name]'s loc from [O.x],[O.y],[O.z] to [x],[y],[z]")
			A.Move(T, forced = 1)
		else
			if(variable == "name" && (!trimAll(new_value) || trimAll(new_value) == " ")) return
			global.admin.AddLog(usr.key, "Modified [O.name]'s [variable] from [O.vars[variable]] to [new_value]")
			O.vars[variable] = new_value
	award_vanity_medal(mob/M in world)
		set category = "Admin"
		M.medal_Award("Vanity Rules")
		global.admin.AddLog(usr.key, "Awarded Vanity Rules medal to [M.name][M.key ? " ([M.key])":].")
	rp_points_add(mob/M in world)
		set category = "Admin"
		M.score_Add("rppoints")
		global.admin.AddLog(usr.key, "Given [M.name][M.key ? " ([M.key])":] an RP point.")
	rp_points_arem(mob/M in world)
		set category = "Admin"
		M.score_Rem("rppoints")
		global.admin.AddLog(usr.key, "Taken an RP point from [M.name][M.key ? " ([M.key])":].")
	make_wizard(mob/M in world, color in list("Red", "Blue", "Orange", "Green", "Purple"))
		set category = "Admin"
		if(M.mage)
			usr << "[M] is already a wizard!"
			return
		global.admin.AddLog(usr.key, "Turned [M.name][M.key ? " ([M.key])":] into a [lowertext(color)] wizard.")
		M.make_wizard(color)
	make_zeth(mob/M in world)
		set category = "Admin"
		if(M.mage)
			usr << "[M] already has magical blood!"
			return
		global.admin.AddLog(usr.key, "Turned [M.name][M.key ? " ([M.key])":] into a zeth.")
		M.chosen = "zeth"

		usr = M

		if(M.fequipped) M.fequipped.unequip(M)
		var/item/armour/I = new/item/armour/face/zeth_mask(M)
		I.Click()
		if(M.bequipped) M.bequipped.unequip(M)
		I = new/item/armour/body/zeth_cloths(M)
		I.Click()

		M.mage = 1
		M.learn_spell(/spell/zeth_teleport, 1)
		M.show_message("<i>You are now one of the Zeth.</i>")
		M.MHP += 25
		M.HP += 25
	teleport(mob/M in world)
		set category = "Admin"
		for(var/mob/N in ohearers(usr))
			N.show_message("\blue [usr.name] touches [usr.gender == FEMALE ? "her":"his"] forehead and disappears...")
		usr.show_message("\blue You touch your forehead and move to a new location!")
		usr.PlaySound('sounds/teleport_u.ogg')
		global.play_sound(usr, ohearers(usr), sound(pick('sounds/teleport_1.ogg', 'sounds/teleport_2.ogg', 'sounds/teleport_3.ogg')))
		usr.Move(M.loc, forced = 1)
		global.play_sound(usr, ohearers(usr), sound(pick('sounds/teleport_1.ogg', 'sounds/teleport_2.ogg', 'sounds/teleport_3.ogg')))
		global.admin.AddLog(usr.key, "Teleported to [M.name][M.key ? " ([M.key])":]")
	summon(mob/M in world)
		set category = "Admin"
		for(var/mob/N in ohearers(M))
			N.show_message("\blue [M.name] suddenly disappears...")
		M.show_message("\blue You suddenly move to a new location!")
		M.PlaySound('sounds/teleport_u.ogg')
		global.play_sound(M, ohearers(M), sound(pick('sounds/teleport_1.ogg', 'sounds/teleport_2.ogg', 'sounds/teleport_3.ogg')))
		M.Move(usr.loc, forced = 1)
		global.play_sound(M, ohearers(M), sound(pick('sounds/teleport_1.ogg', 'sounds/teleport_2.ogg', 'sounds/teleport_3.ogg')))
		global.admin.AddLog(usr.key, "Summoned [M.name][M.key ? " ([M.key])":]")
	summon_all()
		set category = "Admin"
		if(alert(usr, "Are you sure you want to summon everyone?", "Summon All?", "Yes", "No") == "Yes")
			global.admin.AddLog(usr.key, "Summoned everyone in the game.")
			for(var/mob/M in world)
				if(M != usr && M.client) M.Move(usr.loc, forced = 1)
	play_sound(S as sound, channel as num, volume as num)
		set category = "Admin"
		if(!S || !channel) return
		channel = round(channel)
		if(channel == 10) channel = 1023
		if(channel >= 100) channel = 100
		else if(channel <= 1) channel = 1
		world.log << "SOUND: [S] playing on channel [channel] with volume [volume] by [usr.key]"
		global.admin.AddLog(usr.key, "Played sound [S] on channel #[channel] with volume [volume]%.")
		for(var/mob/M in world)
			M << sound(S, channel = channel, volume = volume)
	stop_sounds(channel as num)
		set category = "Admin"
		if(!channel) return
		if(channel == 10) channel = 1023
		global.admin.AddLog(usr.key, "Stopped all sounds on channel [channel].")
		world << sound(null, channel = channel)
	learn_all_spells(mob/M in world)
		set category = "Admin"
		if(!M) return
		for(var/X in typesof(/spell))
			if(X == /spell) continue
			var/spell/S
			for(S in M.spells)
				if(S.type == X) break
			if(!S)
				M.learn_spell(X)
		global.admin.AddLog(usr.key, "Given [M.name][M.key ? " ([M.key])":] all spells.")
		M << "[usr.key] has given you all the spells."
	super_spells(mob/M in world)
		set category = "Admin"
		if(!M) return
		for(var/spell/S in M.spells) S.flags |= S.FLAG_SUPER
		global.admin.AddLog(usr.key, "Removed all spell limitations on [M.name][M.key ? "([M.key])":].")
		M << "[usr.key] has removed any spell limitations you had."
	give_spell(mob/M in world, spell/X in typesof(/spell))
		set category = "Admin"
		if(!M) return
		var/spell/S
		for(S in M.spells) if(S.type == X) break
		if(S)
			send_message(usr, "[M.key] already has this spell.", 3)
		else
			if(!M.spells || !M.spells.len) M.learn_spell(X, 1)
			else M.learn_spell(X, 0)
			S = new X
			M << "[usr.key] has given you the spell [S.name]."
			global.admin.AddLog(usr.key, "Added the spell with type [X] to [M.name][M.key ? " ([M.key])":].")
			S = null
	take_spell(mob/M in world, spell/S in M.spells)
		set category = "Admin"
		if(M && S)
			M.remove_spell(S)
			M << "[usr.key] has taken away your spell [S.name]."
			global.admin.AddLog(usr.key, "Removed spell of type [S.type] from [M.name][M.key ? " ([M.key])":].")
	take_all_spells(mob/M in world)
		set category = "Admin"
		if(!M) return
		for(var/spell/S in M.spells)
			M.remove_spell(S)
		global.admin.AddLog(usr.key, "Removed all spells from [M.name][M.key ? " ([M.key])":].")
	freeze_players()
		set category = "Admin"
		freeze_players = !freeze_players
		send_message(world, "<b>[freeze_players ? "All players have been frozen by [usr.key]!" : "The players have been thawed by [usr.key]."]</b>", 3)
		global.admin.AddLog(usr.key, "[freeze_players ? "Froze all players." : "Unfroze the players."]")

	play_music(F as sound)
		set hidden = 1
		var/sound/S = sound(file = F)
		S.volume = 75
		S.repeat = 1
		S.channel = 10
		music = S
		world << S
		usr << "Now playing [S]"
		global.admin.AddLog(usr.key, "Played sound [S] on channel #10 with volume 75%.")
	stop_music()
		set hidden = 1
		if(music)
			music = null
			world << sound(null, channel = 10)
			usr << "Music stopped."
			global.admin.AddLog(usr.key, "Stopped all sounds on channel 10.")
	play_delayed_sound(S as sound, channel as num, volume as num, delay as num)
		set hidden = 1
		if(!S || !channel) return
		channel = round(channel)
		if(channel == 10) channel = 1023
		if(channel >= 100) channel = 100
		else if(channel <= 1) channel = 1
		world.log << "SOUND: [S] playing on channel [channel] with volume [volume] by [usr.key] (delayed sound, delay = [delay])"
		global.admin.AddLog(usr.key, "Played a delayed sound [S] on channel #[channel] with volume [volume]% and dekay [delay] ticks.")

		if(!delayed_sounds) delayed_sounds = new/list()
		delayed_sounds += channel
		while(delayed_sounds && (channel in delayed_sounds))
			for(var/mob/M in world)
				M << sound(S, channel = channel, volume = volume)
			sleep(delay)
	stop_delayed_sound(channel as num)
		if(delayed_sounds)
			if(channel in delayed_sounds) delayed_sounds -= channel
			if(!delayed_sounds.len) delayed_sounds = null
			global.admin.AddLog(usr.key, "Stopped delayed sound on channel #[channel].")