player
	var
		name
		key
		ckey
		list
			punishments
			associates
			alt_records
			watchers //list of ckeys of admins who are watching this player
		activity = null
		tmp
			client/client

		list
			paintings
			medals
			//_medals //medals that still need to be awarded (but were given while the hub was down)
			//recentNames
			class_id_ban
			recent_names

			jobban
		score_deaths = 0
		score_royalblood = 0
		score_taxes = 0
		score_rppoints = 0

		tmp
			medal_apprentice = 0 //amount of spell books learnt from
			list/medal_king
		medal_woodcutter = 0 //amount of trees cut
		medal_chef = 0 //amount of food made
		medal_painter = 0 //amount of paintings produced
		medal_saint = 0 //amount of revivals for priest/bishop
		music = 100 //play background music where applicable (volume)
		sounds = 100 //play sounds where applicable (volume)
		gender

		tmp
			variable_update_count = 0
			variable_update_sql
			list/variable_cache
	New(client/C)
		. = ..()
		if(istext(C)) //from database
			ckey = ckey(C)
			key = C
		else if(istype(C)) //new
			ckey = C.ckey
			SetVariable("key", C.key)
	proc
		GetMedals(x)
			if(!settings["use_mysql"])
				if(medals && medals.len)
					if(x != -1 && x != 1) return medals

					var/list/L = new/list()
					for(var/medal in medals)
						if(x == 1 && medals[medal] == "Y") continue
						if(x == -1 && medals[medal] != "Y") continue
						L[medal] = medals[medal]
					return L
			else
				var/sql = "SELECT `medal`,`sync` FROM `c_medals` WHERE `ckey`='[ckey]'"
				if(x == -1) sql += " AND `sync`!='Y'"
				else if(x == 1) sql += " AND `sync`='Y'"
				sql += ";"

				var/DBQuery/qry = MySQL.Query(sql)
				if(qry && qry.RowCount())
					var/list/L = new/list()
					while(qry.NextRow()) L[qry.item[1]] = qry.item[2]
					return L
		SetVariable(variable, value)
			vars[variable] = value

			var/list/L = list("medal_apprentice", "medal_king", "client", "variable_update_count", "variable_update_sql")
			/*var/issaved = issaved(variable)
			if(issaved && (variable in L))
				world.log << "ERROR: Variable [variable] is marked as tmp, but is not recognised by the game."
			if(!issaved && !(variable in L))
				world.log << "ERROR: Variable [variable] is marked as tmp, but is not recognised as tmp."*/

			if(settings["use_mysql"] && !(variable in L))
				if(!variable_cache) variable_cache = new/list()
				variable_cache[variable] = value
				/*switch(variable)
					if("character_name") variable = "name"
					if("name") variable = "key"*/

				var/count = ++variable_update_count
				if(!variable_update_sql)
					variable_update_sql = "UPDATE `c_players` SET "
				variable_update_sql += "`[variable]`=[MySQL.Escape(value)],"
				spawn(10)
					if(count != variable_update_count || !variable_update_sql) return
					var/sql = variable_update_sql
					variable_update_sql = null
					sql = copytext(sql, 1, length(sql))
					sql += " WHERE `ckey`='[ckey]'"
					MySQL.Query(sql)
		GetVariable(variable, overwrite = 0)
			if(!(variable in vars)) return null
			if(settings["use_mysql"])
				if(!variable_cache) variable_cache = new/list()
				if(!overwrite && variable_cache[variable]) return variable_cache[variable]

				var/DBQuery/qry = MySQL.Query("SELECT `[variable]` FROM `c_players` WHERE `ckey`='[ckey]';")
				if(qry && qry.NextRow())
					vars[variable] = IsNum(qry.item[1]) ? text2num(qry.item[1]) : qry.item[1]
					if(IsNum(qry.item[1])) qry.item[1] = text2num(qry.item[1])
					variable_cache[variable] = qry.item[1]
					return qry.item[1]
			else return vars[variable]

		IsJobBanned(job)
			if(!settings["use_mysql"])
				return (job in jobban)
			else
				var/DBQuery/qry = MySQL.Query("SELECT `job` FROM `c_jobbans` WHERE `ckey`='[ckey]' AND `job`=[MySQL.Escape(job)];")
				return (qry && qry.RowCount())
		ToggleJobBan(job)
			if(!settings["use_mysql"])
				if(!jobban) jobban = new/list()
				if(job in jobban)
					jobban -= job
					if(!jobban.len) jobban = null
				else
					jobban += job
			else
				if(IsJobBanned())
					MySQL.Query("DELETE FROM `c_jobbans` WHERE `ckey`='[ckey]' AND `job`=[MySQL.Escape(job)];")
				else
					MySQL.Query("INSERT INTO `c_jobbans` (`ckey`,`job`) VALUES('[ckey]', `job`=[MySQL.Escape(job)]);")

		AddRecentName(name)
			if(name in GetRecentNames()) return //already added!
			if(!settings["use_mysql"])
				if(!recent_names) recent_names = new/list()
				recent_names.Insert(1, name)
				if(recent_names.len > 10)
					recent_names -= recent_names[recent_names.len]
			else
				MySQL.Query("DELETE IGNORE FROM `c_player_names` WHERE `ckey`='[ckey]' AND `name`=[MySQL.Escape(name)];")
				MySQL.Query("INSERT INTO `c_player_names` (`ckey`,`name`) VALUES('[ckey]',[MySQL.Escape(name)]);")
				if(!recent_names) recent_names = new/list()
				recent_names.Insert(1, name)
				if(recent_names.len > 10)
					MySQL.Query("DELETE FROM `c_player_names` WHERE `ckey`='[ckey]' ORDER BY `id` DESC LIMIT 1;")
		GetRecentNames()
			if(recent_names && recent_names.len) return recent_names

			if(!settings["use_mysql"])
				return recent_names
			else
				var
					list/L
					DBQuery/qry = MySQL.Query("SELECT `name` FROM `c_player_names` WHERE `ckey`='[ckey]' ORDER BY `id` ASC;")
				if(qry && qry.RowCount())
					L = new/list()
					while(qry.NextRow()) L += qry.item[1]
				return L
		LoadRecentNames()
			var/savefile/F = new("Players.sav")
			F.cd = "/players/[ckey]/names"
			var/list/L = new()
			L += F.dir
			/***var/k = 1
			for (k=1,L.len-1,k++)
				world << L[k]
				***/
			return L

		NewRecentName(name as text)
			var/savefile/F = new("Players.sav")
			F.cd = "/players/[ckey]/names"
			var/list/L = new()
			L += F.dir
			if (name in L)
				return()
			if (L.len == 4)
				F.dir.Remove("[L[4]]")
				L[4] = name
			else
				L += name
			for (var/k=1,L.len,k++)
				if (k > L.len)
					return()
				F["[L[k]]"] << "name"
			if (L.len == 4)
				recent_names = LoadRecentNames()

		Login(client/C)
			SetVariable("activity", 0)
			client = C

			Reassociate()

			if(global.admin.IsBanned(C))
				C.verbose_logout = 0
				del C

			spawn
				var/list/L = GetMedals(-1)
				for(var/medal in L)
					if(L[medal] == "D")
						if(!isnull(world.ClearMedal(medal, key)))
							if(settings["use_mysql"])
								MySQL.Query("DELETE FROM `c_medals` WHERE `ckey`='[ckey]' AND `medal`=[MySQL.Escape(medal)];")
					else
						if(!isnull(world.SetMedal(medal, key)))
							if(settings["use_mysql"])
								MySQL.Query("DELETE FROM `c_medals` WHERE `ckey`='[ckey]' AND `medal`=[MySQL.Escape(medal)];")
								MySQL.Query("INSERT INTO `c_medals` (`ckey`,`medal`,`sync`) VALUES('[ckey]',[MySQL.Escape(medal)],'Y');")

				if((ckey in developers) || (ckey in ScoreDenied()))
					world.SetScores(key, "")
		Logout()
			SetVariable("activity", world.realtime)
			client = null

		Reassociate()
			set background = 1
			if(!client) return

			if(!settings["use_mysql"])
				for(var/player/P in global.admin.players)
					if((client.address in P.associates) || (client.computer_id in P.associates))
						if(!(client.address in P.associates)) P.associates += client.address
						if(!(client.computer_id in P.associates)) P.associates += client.computer_id
			else
				if(client.address && client.address != world.address)
					MySQL.Query("INSERT IGNORE INTO `c_player_associates` (`id`,`id_type`,`ckey`) VALUES('[client.address]','ip','[ckey]');")
				if(client.computer_id)
					MySQL.Query("INSERT IGNORE INTO `c_player_associates` (`id`,`id_type`,`ckey`) VALUES('[client.computer_id]','id','[ckey]');")
		GetAssociates()
			if((ckey in developers) || (ckey in global.admin.admins)) return list(src.ckey)
			if(!src.associates || !src.associates.len) return list(src.ckey)

			var/list/L = new/list(src.ckey)
			if(!settings["use_mysql"])
				for(var/player/P in global.admin.players)
					if(P != src)
						for(var/assoc in src.associates)
							if(assoc in P.associates)
								L += P.ckey
								break
			else
				var/sql = "SELECT DISTINCT `ckey` FROM `c_player_associates` WHERE `id` IN ("
				for(var/assoc in src.associates) sql += "[MySQL.Escape(assoc)], "
				sql = copytext(sql, 1, length(sql) - 1)
				sql += ");"
				var/DBQuery/qry = MySQL.Query(sql)
				if(qry && qry.RowCount())
					while(qry.NextRow())
						L += qry.item[1]

			return L

		UpdateScore()
			//update scores
			//don't update if the world is shutting down, we're a developer or on the data/deny_score.txt list
			if(dta_shutdown) return

			if(!score_deaths) score_deaths = GetVariable("score_deaths")
			if(!score_royalblood) score_royalblood = GetVariable("score_royalblood")
			if(!score_taxes) score_taxes = GetVariable("score_taxes")
			if(!score_rppoints) score_rppoints = GetVariable("score_rppoints")

			if(score_deaths > 9999) SetVariable("score_deaths", 9999)
			if(score_royalblood > 9999) SetVariable("score_royalblood", 9999)
			if(score_taxes > 9999999) SetVariable("score_taxes", 9999999)
			if(score_rppoints > 99) SetVariable("score_rppoints", 99)

			if(!(ckey in developers) && !(ckey in ScoreDenied()))
				var/list/L = list(
					"Deaths" = GetVariable("score_deaths"),
					"Royal Blood" = GetVariable("score_royalblood"),
					"Taxes" = GetVariable("score_taxes"),
					"RP Points" = GetVariable("score_rppoints")
				)
				if(L["Deaths"] > 10 || L["Royal Blood"] > 2 || L["Taxes"] > 100 || L["RP Points"] > 0)
					world.SetScores(key, list2params(L))

			if(client)
				var/mob/M = client.mob
				if(M) hud_main.UpdateHUD(M)

		AwardMedal(medal)
			if((ckey in MedalDenied()) || (medal in GetMedals())) return 0 //already awarded

			//award it locally
			if(!settings["use_mysql"])
				if(!medals) medals = new()
				medals += medal

			var/type = medal2type(medal)
			send_message(client, "\icon[icon('icons/icons.dmi', "medal")] <tt><font color=\"#4545CC\">Achievement unlocked! You have been awarded the <strong>[medal2text(medal)]</strong> medal.</font></tt>", 3)
			if(type == 1 || type >= 3) //a special medal or above medium level
				for(var/client/C)
					if(C == client) continue
					send_message(C, "\icon[icon('icons/icons.dmi', "medal")] <tt><font color=\"#4545CC\">Achievement unlocked! [key] has been awarded the <strong>[medal2text(medal)]</strong> medal.</font></tt>", 3)

			var/sync = "Y"
			if(isnull(world.SetMedal(medal, key))) sync = "N"

			if(settings["use_mysql"])
				MySQL.Query("DELETE IGNORE FROM `c_medals` WHERE `ckey`='[ckey]' AND `medal`=[MySQL.Escape(medal)];")
				MySQL.Query("INSERT INTO `c_medals` (`ckey`,`medal`,`sync`) VALUES('[ckey]',[MySQL.Escape(medal)],'[sync]');")
		RemoveMedal(medal)
			if(!medal || !(medal in GetMedals())) return 0 //not awarded

			if(!settings["use_mysql"])
				medals -= medal
				if(!medals.len) medals = null
			world << "\icon[icon('icons/icons.dmi', "medal")] <tt><font color=\"#4545CC\">Achievement lost! [key]'s <strong>[medal2text(medal)]</strong> medal has been recinded!</font></tt>"

			if(isnull(world.ClearMedal(medal, key))) . = 1

			if(settings["use_mysql"])
				MySQL.Query("DELETE IGNORE FROM `c_medals` WHERE `ckey`='[ckey]' AND `medal`=[MySQL.Escape(medal)];")
				if(.)
					MySQL.Query("INSERT INTO `c_medals` (`ckey`,`medal`,`sync`) VALUES('[ckey]',[MySQL.Escape(medal)],'D');")

		ReportMedal(medal, additional) //called by game procs to report different actions happening
			switch(medal)
				if("apprentice")
					. = GetVariable("medal_apprentice")
					if(++. >= 5)
						AwardMedal("Apprentice")
					SetVariable("medal_apprentice", .)
				if("woodcutter")
					. = GetVariable("medal_woodcutter")
					if(++. >= 50000)
						AwardMedal("Woodcutter")
					SetVariable("medal_woodcutter", .)
				if("chef")
					. = GetVariable("medal_chef")
					if(++. >= 20000)
						AwardMedal("Chef de cuisine")
					SetVariable("medal_chef", .)
				if("paint")
					. = GetVariable("medal_painter")
					if(++. >= 200)
						AwardMedal("Painter")
					SetVariable("medal_painter", .)
				if("king")
					if("Overthrown" in GetMedals()) return
					var
						item/I = additional
						list/types = list(
							/item/armour/hat/Royal_crown, /item/armour/hat/noble_crown,
							/item/armour/body/royal_armour, /item/armour/body/noble_armour,
							/item/armour/face/royal_mask, /item/armour/face/noble_mask
						)
					if(I && (I.type in types))
						if(!medal_king) medal_king = new()
						if(!(I.type in medal_king)) medal_king += I.type

					if(medal_king && medal_king.len >= 3)
						AwardMedal("Overthrown")
				if("saint")
					. = GetVariable("medal_saint")
					if(++. >= 100)
						AwardMedal("Saint")
					SetVariable("medal_saint", .)