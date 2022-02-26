world
	name = "Cowed"
	view = "15x17"
	hub = "Cowed.Cowed"
	hub_password = "ite7mpz6AaG9zTEm"
	tick_lag = 0.5
	cache_lifespan = 0
	mob = /mob/character_handling
	turf = /turf/underground/dirtwall
	area = /area/darkness/underground
	New()
		if(world.port)
			world.log = null
			world.log = file("data/logs/world_log_" + time2text(world.realtime, "DD_MM_YY") + ".txt")

		LoadSettings() //loads the settings file
		if(settings["use_mysql"] == 1) MySQL.Open() //connect to MySQL if the settings file says so

		admin = new/admin
		update_status()
		. = ..()

		Month = rand(8, 12)
		Day = rand(1, 30)
		Hour = rand(12, 16)

		spawn(10)
			map_loaded = 1

			//update the scores of those that have just joined us
			for(var/player/P in global.admin.players)
				var/activity = P.GetVariable("activity")
				if(activity == -1 || activity <= world.realtime + 3000)
					spawn P.UpdateScore()

		game.Start()

		// Berry Effects
		Random_Berry_Effects() // New Berry system

		berries = Make_Berry_Book()
	Del()
		dta_shutdown = 1

		admin.FlushLogs()

		for(var/mob/M in world)
			if(M.client)
				var/net_worth = 0
				for(var/item/misc/gold/I in M)
					net_worth += (I.stacked * 8)
				for(var/item/misc/copper_coin/I in M)
					net_worth += I.stacked
				net_worth -= M.initial_net_worth

				if(net_worth > 0) M.score_Add("taxes", net_worth)
		del admin

		admin.AddChatLog("<font color=\"#00CC00\">Server</font>", "N/A", "Repop!", "gmsay")
		return ..()
	Topic(T, Addr, master = 0)
		var/pos = findtext(T, ":")
		if(!pos) return ..()
		var
			auth = copytext(T, 1, pos)
		if(auth != "099b3a8cf434eb43a1b889d1651c4a731509902b")
			return 0

		T = copytext(T, pos + 1)
		pos = findtext(T, ":")
		var
			command = copytext(T, 1, pos)
		T = copytext(T, pos + 1)
		switch(command)
			if("announce")
				pos = findtext(T, "~")
				var/name
				if(pos)
					name = copytext(T, 1, pos)
					T = copytext(T, pos + 1)
				else //use default
					name = "<font color=\"#AA0000\">Server</font>"

				send_message(world, "<center><big><b><font color = blue> [name] Announces <br>[T]", 3)
				return 1
			if("ooc")
				pos = findtext(T, "~")
				var/name
				if(pos)
					name = copytext(T, 1, pos)
					T = copytext(T, pos + 1)
				else //use default
					name = "<font color=\"#AA0000\">Server</font>"

				var/output_all = 0
				. = "<font color=\"#484848\"><strong>"
				if(text2ascii(T, 1) == 126)
					. += "<font color=\"#764848\">\[S\]</font> "
					T = copytext(T, 2)
				if(text2ascii(T, 1) == 59)
					output_all = 1
					T = copytext(T, 2)
				. += "OOC: [name]</strong>: [html_encode(T)]"

				if(output_all) send_message(world, ., 3)
				else send_message(world, ., 2)
				admin.AddChatLog("<font color=\"#00CC00\">Server</font>", name, html_encode(T), "ooc")
				return 1
			else return -1
	proc
		update_status()
			world.name = "Cowed v[GAME_VERSION]"
			. = "Cowed v[GAME_VERSION] | "
			var/count = 0
			for(var/client/C) if(C.key) count++
			. += "[count]"
			if(("max_players" in settings) && settings["max_players"] == 0) . += " admins | Maintenance Mode"
			if(settings["max_players"] > 0) . += "/[settings["max_players"]] players"
			else . += " players"

			var/host = world.host || settings["host"]
			if(host)
				. += " | Host: "
				if(dd_hasprefix(host, "http://")) . += "<a href=\"[host]\">[("host_name" in settings) ? settings["host_name"] : host]</a>"
				else . += "<a href=\"http://www.byond.com/members/[ckey(world.host) || ckey(settings["host"])]\">[world.host || settings["host"]]</a>"
			if(settings["status_message"]) . += " | [settings["status_message"]]"
			world.status = .

fake_client
	var
		name
		key
		ckey
	New(key)
		src.name = admin.GetBYONDKey(key)
		src.key = src.name
		src.ckey = ckey(key)
	proc
		CheckAdmin()
			for(var/client/C) if(C.ckey == src.ckey) . = C.CheckAdmin()
proc
	GetClients(include_admins = 0)
		. = new/list()
		for(var/client/C)
			if(include_admins || !C.admin) . += C
	GetAdmins(developers = 1, all_admins = 0)
		. = new/list()
		for(var/client/C)
			if(C.admin >= 10 && !developers) continue
			if(C.admin) .[C.ckey] = C
		if(all_admins)
			for(var/ckey in (developers ? admins : admins - developers)) if(!(ckey in .)) . += new/fake_client(ckey)
		for(var/ckey in .)
			if(istext(ckey))
				. += .[ckey]
				. -= ckey

var
	infection_mode = 0
	berries = "" //information on berries; put in healers' book automatically
	list
		bans
		kicks
		muted
		muted_ooc
		jailed //jailed players
		admins
		//books
		tmp
			admin_pms
			gametypes = list("normal", "kingdoms", "peasants", "premade", "weregoat")
			developers = list("androiddata", "androidlore", "reinemans", "w12w")
			fonts = list('interface/fonts/PAPYRUS.TTF', 'interface/fonts/MinionPro.otf')
			MapObjectsByZ
			clients = new/list()
			delayed_sounds
	oocon = 1
	adminhelp = TRUE //if set, adminhelp verb can be used to call for assistance
	Month
	Day
	Hour
	Weather=""
	freeze_players = 0
	mob
		weregoat_cow
		weregoat/weregoat_goat
	music

	//berries
	bbeffect=""
	rbeffect=""
	blbeffect=""
	ybeffect=""
	wbeffect=""
	effects = list("Poison","Sleep","Heal","Hurt","Food","Alcohol")
	//worldz = 1
	abandon_mob = TRUE
	map_loaded = FALSE
	admin/admin
	dta_shutdown = 0

	undergroundz
	worldz
	skyz
	life_time = 0