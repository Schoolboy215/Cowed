admin
	var
		list
			bans
			mutes

			players
			admins
			families
			key_cache
			books
		const
			FLAG_REBOOTING = 1
			FLAG_SHUTDOWN = 2
			FLAG_VOTE_REBOOT = 4 //allows a vote-to-reboot by non-admins
		tmp
			flags = FLAG_VOTE_REBOOT
			list
				reboot_votes
				admin_options
				admin_log
				chat_log
	New()
		. = ..()
		if(settings["use_mysql"])
			//purge older chat log entries automatically (2 months)
			MySQL.Query("DELETE IGNORE FROM `c_chat_log` WHERE `date` < '[world.realtime - 5259488]';")
	proc
		GetBooks(title)
			if(!settings["use_mysql"])
				return books
			else
				var
					list/L = new/list()
					DBQuery/qry = MySQL.Query("SELECT `title` FROM `c_books` ORDER BY `title` ASC;")
				if(qry && qry.RowCount())
					while(qry.NextRow()) L += qry.item[1]
				return L
		GetBook(title)
			if(!settings["use_mysql"])
				if(title in books) return books[title]
			else
				var
					item/misc/book/I
					DBQuery/qry = MySQL.Query("SELECT * FROM `c_books` WHERE `title`=[MySQL.Escape(title)];")
				if(qry && qry.NextRow())
					var/data = qry.GetRowData()
					I = new
					I.name = "book- '[data["title"]]'"
					I.updated = data["updated"]
					I.approved = data["approved"]
					I.author = data["author"]

					qry = MySQL.Query("SELECT * FROM `books_int` WHERE `book`=[MySQL.Escape(title)] ORDER BY `id` ASC;")
					if(qry && qry.RowCount())
						while(qry.NextRow())
							var/row = qry.GetRowData()
							var/item/misc/paper/P = new
							P.name = row["title"]
							P.content = row["content"]
							I.contents += P
					return I
		StoreBook(item/misc/book/I, mob/author)
			if(!settings["use_mysql"])
				if(!books) books = new/list()
				var/item/misc/book/B = I.duplicate()
				B.updated = world.realtime
				B.approved = usr && usr.client && usr.client.admin ? 1 : 0
				B.author = usr.key
				books[B.name] = B
			else
				MySQL.Query("REPLACE INTO `c_books` (`title`,`author`,`updated`) VALUES([MySQL.Escape(I.name)], [MySQL.Escape(author.key)], '[world.realtime]');")
				for(var/item/misc/paper/P in I.contents)
					MySQL.Query("INSERT INTO `c_books_int` (`book`,`title`,`body`) VALUES([MySQL.Escape(I.name)], [MySQL.Escape(P.name)], [MySQL.Escape(P.content)]);")
		ApproveBook(title)
			var/item/misc/book/I = GetBook(title)
			if(!I && !I.approved) return 0

			if(!settings["use_mysql"])
				if(!I.approved)
					I.approved = 1
			else
				MySQL.Query("UPDATE `c_books` SET `approved`='1' WHERE `title`=[MySQL.Escape(title)]")

			var/player/P = GetPlayer(I.author)
			if(P)
				P.AwardMedal("Member Of The Bovinia Book Club")
		DeleteBook(title)
			var/item/misc/book/I = GetBook(title)
			if(!I) return 0

			if(!settings["use_mysql"])
				books -= title
			else
				title = MySQL.Escape(title)
				MySQL.Query("DELETE IGNORE FROM `c_books` WHERE `title`=[title]")
				MySQL.Query("DELETE IGNORE FROM `c_books_int` WHERE `book`=[title]")

		IsBanned(client/C)
			if(C.key in bans)
				. = 1
				if(C.address && C.address != world.address && !(C.address in bans[C.key])) bans[C.key] += C.address
				if(C.computer_id && !(C.computer_id in bans[C.key])) bans[C.key] += C.computer_id
			for(var/key in bans) if((C.ckey in bans[key]) || (C.address in bans[key]) || (C.computer_id in bans[key]))
				if(!(C.ckey in bans[key])) bans[key] += C.ckey
				if(C.address && C.address != world.address && !(C.address in bans[key])) bans[key] += C.address
				if(C.computer_id && !(C.computer_id in bans[key])) bans[key] += C.computer_id
				. = 1

			if(settings["use_mysql"])
				var/main_key
				if(!.)
					var/DBQuery/qry = MySQL.Query("SELECT `key` FROM `c_bans` WHERE `id` IN ('[C.ckey]'[C.address ? ", [MySQL.Escape(C.address)]":][C.computer_id ? ", [MySQL.Escape(C.computer_id)]":]);")
					if(qry && qry.NextRow())
						main_key = qry.item[1]
						. = 1

				if(!.) return
				MySQL.Query("INSERT IGNORE INTO `c_bans` (`key`,`id`) VALUES([MySQL.Escape(main_key)],[MySQL.Escape(C.ckey)]);")
				if(C.address && C.address != world.address)
					MySQL.Query("DELETE IGNORE FROM `c_bans` WHERE `key`=[MySQL.Escape(main_key)] AND `id`=[MySQL.Escape(C.address)];")
					MySQL.Query("INSERT INTO `c_bans` (`key`,`id`) VALUES([MySQL.Escape(main_key)],[MySQL.Escape(C.address)]);")
				if(C.computer_id)
					MySQL.Query("DELETE IGNORE FROM `c_bans` WHERE `key`=[MySQL.Escape(main_key)] AND `id`=[MySQL.Escape(C.computer_id)];")
					MySQL.Query("INSERT INTO `c_bans` (`key`,`id`) VALUES([MySQL.Escape(main_key)],[MySQL.Escape(C.computer_id)]);")
		AddBan(ckey, reason, admin)
			ckey = ckey(ckey)
			var/key = GetBYONDKey(ckey)

			if(!bans) bans = new/list()
			bans[key] = list(ckey)
			for(var/client/C)
				if(C.ckey == ckey)
					if(C.address && C.address != world.address) bans[key] += C.address
					if(C.computer_id) bans[key] += C.computer_id
					del C

			if(settings["use_mysql"])
				MySQL.Query("INSERT IGNORE INTO `c_bans` (`key`,`id`,`admin`,`reason`) VALUES([MySQL.Escape(key)],'[ckey]',[MySQL.Escape(admin)],[MySQL.Escape(reason)]);")
				for(var/assoc in bans[ckey])
					if(assoc == ckey) continue
					MySQL.Query("INSERT IGNORE INTO `c_bans` (`key`,`id`) VALUES([MySQL.Escape(key)],'[assoc]');")
			AddLog(admin, "Banned [key]. Reason: [html_encode(reason)]")
		RemoveBan(ckey, reason, admin)
			ckey = ckey(ckey)
			var/key = GetBYONDKey(ckey)

			if(bans && (key in bans)) bans -= key

			if(settings["use_mysql"])
				MySQL.Query("DELETE FROM `c_bans` WHERE `key`=[MySQL.Escape(key)];")

			AddLog(admin, "Unbanned [key]. Reason: [html_encode(reason)]")
		GetBans(details = 0)
			if(!settings["use_mysql"]) return bans ? bans : list()
			var
				list/L = new/list()
				DBQuery/qry = MySQL.Query("SELECT DISTINCT `key`[details ? ",`admin`,`reason`":] FROM `c_bans`[details ? " WHERE `admin`!=''":]")
			if(qry && qry.RowCount())
				while(qry.NextRow())
					if(details) L[qry.item[1]] = list(qry.item[2], qry.item[3])
					else L += qry.item[1]
			return L

		IsMuted(client/C) return (C.key in mutes)
		AddMute(ckey, reason, admin)
			ckey = ckey(ckey)
			var/key = GetBYONDKey(ckey)

			if(!mutes) mutes = new/list()
			if(!(key in mutes)) mutes += key
			for(var/client/C)
				if(C.ckey == ckey)
					send_message(C, "<tt>You have been muted.</tt>", 3)

			AddLog(admin, "Muted [key]. Reason: [html_encode(reason)]")
		RemoveMute(ckey, reason, admin)
			ckey = ckey(ckey)
			var/key = GetBYONDKey(ckey)

			if(mutes && (key in mutes)) mutes -= key

			AddLog(admin, "Unmuted [key]. Reason: [html_encode(reason)]")
		GetMuted() return mutes ? mutes : list()

		AddAdmin(ckey, rank)
			if(!isnum(rank)) return
			ckey = ckey(ckey)

			if(!admins) admins = new/list()
			admins[ckey] = rank

			if(settings["use_mysql"])
				MySQL.Query("REPLACE INTO `c_admins` (`ckey`,`rank`) VALUES('[ckey]', '[rank]');")
		RemoveAdmin(ckey)
			ckey = ckey(ckey)
			if(admins) admins -= ckey

			if(settings["use_mysql"])
				MySQL.Query("DELETE FROM `c_admins` WHERE `ckey`='[ckey]';")
		GetAdmin(ckey)
			ckey = ckey(ckey)
			if(ckey in developers) return 9

			if(!settings["use_mysql"])
				return admins && admins.len ? admins[ckey] : null
			else
				var/DBQuery/qry = MySQL.Query("SELECT `rank` FROM `c_admins` WHERE `ckey`='[ckey]';")
				if(qry && qry.NextRow()) return text2num(qry.item[1])
		GetPlayer(ckey)
			ckey = ckey(ckey)

			for(var/player/P in players)
				if(P.ckey == ckey) return P

			if(settings["use_mysql"])
				var/DBQuery/qry = MySQL.Query("SELECT `key` FROM `c_players` WHERE `ckey`='[ckey]';")
				if(qry && qry.NextRow())
					if(!players) players = new/list()
					var/player/P = new(qry.item[1])
					players += P
					return P
		CreatePlayer(client/C)
			if(!istype(C)) return
			if(settings["use_mysql"])
				MySQL.Query("INSERT IGNORE INTO `c_players` (`ckey`,`key`) VALUES('[C.ckey]',[MySQL.Escape(C.key)]);")
			var/player/P = new/player(C)
			if(!players) players = new/list()
			players += P
			return P

		AddLog(admin, body, date = world.realtime, time = world.timeofday)
			if(settings["use_mysql"])
				if(!admin_log) admin_log = new/list()
				admin_log += new/admin_log(admin, body, date, time)
				/*admin = MySQL.Escape(admin)
				body = MySQL.Escape(body)

				MySQL.Query("INSERT INTO `c_admin_log` (`admin`,`body`,`date`,`time`) VALUES([admin],[body],'[date]','[time]');")*/
		AddChatLog(key, name, message, type = "say", date = world.realtime, time = world.timeofday)
			if(settings["use_mysql"])
				if(!chat_log) chat_log = new/list()
				chat_log += new/chat_log(key, name, message, type, date, time)
				/*key = MySQL.Escape(key)
				name = MySQL.Escape(name)
				message = MySQL.Escape(message)
				type = MySQL.Escape(type)

				MySQL.Query("INSERT INTO `c_chat_log` (`key`,`name`,`message`,`m_type`,`date`,`time`) VALUES([key],[name],[message],[type],'[date]','[time]');")*/

		FlushLogs()
			if(!settings["use_mysql"]) return
			if(admin_log && admin_log.len)
				var/sql = "INSERT INTO `c_admin_log` (`admin`,`body`,`date`,`time`) VALUES "
				for(var/admin_log/L in admin_log)
					sql += "([MySQL.Escape(L.admin)], [MySQL.Escape(L.body)], '[L.date]', '[L.time]'),"
				admin_log = null
				sql = copytext(sql, 1, length(sql))
				MySQL.Query(sql)

			if(chat_log && chat_log.len)
				var/sql = "INSERT INTO `c_chat_log` (`key`,`name`,`message`,`m_type`,`date`,`time`) VALUES "
				for(var/chat_log/L in chat_log)
					sql += "([MySQL.Escape(L.key)], [MySQL.Escape(L.name)], [MySQL.Escape(L.message)], [MySQL.Escape(L.m_type)], '[L.date]', '[L.time]'),"
				chat_log = null
				sql = copytext(sql, 1, length(sql))
				MySQL.Query(sql)

		GetRecentLog(start = 0, limit = 8, type, target)
			var/list/L = new/list()

			if(settings["use_mysql"])
				var/sql = "SELECT * FROM `c_admin_log`"
				if(type || target)
					sql += " WHERE "
					if(type) sql += "`type`=[MySQL.Escape(type)]"
					if(type && target) sql += " AND "
					if(target) sql += "`target`=[MySQL.Escape(target)]"
				sql += " ORDER BY `id` ASC[limit ? " LIMIT [start],[limit]":]"

				var/DBQuery/qry = MySQL.Query(sql)
				if(qry && qry.RowCount())
					while(qry.NextRow())
						var/list/data = qry.GetRowData()
						L += new/admin_log(data["admin"], data["body"], data["date"], data["time"])
					return L

		GetBYONDKey(ckey)
			. = ckey(ckey)
			if(!key_cache) key_cache = new/list()
			if(. in key_cache) return key_cache[.] //if it's in the memory cache, go get it
			if(settings["use_mysql"]) //there's a possibility it's in the MySQL database
				var/DBQuery/qry = MySQL.Query("SELECT `key` FROM `c_key_cache` WHERE `ckey`='[.]';")
				if(qry && qry.NextRow())
					//got it! now just output this
					key_cache[.] = qry.item[1]
					return key_cache[.]

			//wasn't in there, so query BYOND
			var/http[] = world.Export("http://www.byond.com/members/[.]?format=text")
			if(http && ("CONTENT" in http))
				var
					savefile/F = new()
					content = file2text(http["CONTENT"])
				F.ImportText("/", content)
				if(!F || !F.dir || !F.dir.len) return 0
				if(!key_cache) key_cache = new/list()
				key_cache[.] = F["/general/key"]
				if(settings["use_mysql"])
					MySQL.Query("INSERT INTO `c_key_cache` (`ckey`,`key`) VALUES('[.]',[MySQL.Escape(key_cache[.])]);")
				return key_cache[.]
			return null

		reboot(cause)
			if(flags & FLAG_REBOOTING)
				ActionLock("reboot", 100)
				flags &= ~FLAG_REBOOTING
				send_message(world, "<b>Reboot aborted[cause ? " by [cause]" :].</b>", 3)
			else
				if(ActionLock("reboot")) return
				flags |= FLAG_REBOOTING
				send_message(world, "<b>Rebooting server in 10 seconds![cause ? " Initiated by [cause].":]</b>", 3)
				spawn(70)
					if(!(flags & FLAG_REBOOTING)) return
					send_message(world, "<b>Rebooting server in 3...", 3)
					sleep(10)
					if(!(flags & FLAG_REBOOTING)) return
					send_message(world, "<b>Rebooting server in 2...", 3)
					sleep(10)
					if(!(flags & FLAG_REBOOTING)) return
					send_message(world, "<b>Rebooting server in 1...", 3)
					sleep(10)
					if(!(flags & FLAG_REBOOTING)) return
					send_message(world, "<b>Rebooting server!", 3)
					world.Reboot()
		shutdown2(cause)
			if(flags & FLAG_SHUTDOWN)
				ActionLock("shutdown", 100)
				flags &= ~FLAG_SHUTDOWN
				send_message(world, "<b>Server shutdown aborted[cause ? " by [cause]" :].</b>", 3)
			else
				if(ActionLock("shutdown")) return
				flags |= FLAG_SHUTDOWN
				send_message(world, "<b>Closing server in 10 seconds![cause ? " Initiated by [cause].":]</b>", 3)
				spawn(70)
					if(!(flags & FLAG_SHUTDOWN)) return
					send_message(world, "<b>Closing server in 3...", 3)
					sleep(10)
					if(!(flags & FLAG_SHUTDOWN)) return
					send_message(world, "<b>Closing server in 2...", 3)
					sleep(10)
					if(!(flags & FLAG_SHUTDOWN)) return
					send_message(world, "<b>Closing server in 1...", 3)
					sleep(10)
					if(!(flags & FLAG_SHUTDOWN)) return
					send_message(world, "<b>Closing server!", 3)
					del world
		UpdateClassBanList(mob/M)
			if(!M || !M.client) return

			if(!("selector_kingdom" in admin_options[M.ckey]))
				admin_options[M.ckey]["selector_kingdom"] = image(icon = 'icons/Classes.dmi', loc = null, icon_state = "selector")
			if(!("selector_branch" in admin_options[M.ckey]))
				admin_options[M.ckey]["selector_branch"] = image(icon = 'icons/Classes.dmi', loc = null, icon_state = "selector")

			var/image
				selector_kingdom = admin_options[M.ckey]["selector_kingdom"]
				selector_branch = admin_options[M.ckey]["selector_branch"]
			selector_kingdom.loc = admin_options[M.ckey]["jobban_kingdom"]
			selector_branch.loc = admin_options[M.ckey]["jobban_branch"]

			if(!(selector_kingdom in M.client.images))
				M.client.images += selector_kingdom
			if(!(selector_branch in M.client.images))
				M.client.images += selector_branch

			var
				character_handling/container
					classban_kingdom = admin_options[M.ckey]["jobban_kingdom"]
					classban_branch = admin_options[M.ckey]["jobban_branch"]
				player/P = admin_options[M.ckey]["jobban_player"]
				list/L = list(
				"admin/classban.grdKingdoms.cells" = "[game.kingdoms.len]",
				"admin/classban.grdKingdoms.size" = "[(game.kingdoms.len * 36) + 48]x36",
				"admin/classban.grdBranches.is-visible" = (classban_kingdom ? "true" : "false"),
				"admin/classban.lblBranch.is-visible" = (classban_kingdom ? "true" : "false"),
				"admin/classban.grdClasses.is-visible" = (classban_branch ? "true" : "false"),
				"admin/classban.lblClass.is-visible" = (classban_branch ? "true" : "false"),
				"admin/classban.on-close" = "byond://?src=\ref[src];cmd=close_classban",
			)
			if(classban_kingdom != admin_options[M.ckey]["jobban_old_kingdom"])
				L["admin/classban.grdBranches.cells"] = "[classban_kingdom ? classban_kingdom.children.len : 0]"
				L["admin/classban.grdClasses.cells"] = "0"
				classban_branch = null
				selector_branch.loc = null
			if(classban_branch != admin_options[M.ckey]["jobban_old_branch"])
				L["admin/classban.grdClasses.cells"] = "] ? classban_branch.children.len : 0]"
			winset(M.client, null, list2params(L))

			if(!classban_kingdom && game.kingdoms.len)
				var/i = 0
				for(var/character_handling/container/kingdom in game.kingdoms)
					M.client.images -= kingdom.bluex
					if(P && P.class_id_ban && (kingdom.class_id in P.class_id_ban)) M.client.images += kingdom.bluex
					M.client << output(kingdom, "admin/classban.grdKingdoms:[++i]")

			if(classban_kingdom)
				var/i = 0
				for(var/character_handling/container/branch in classban_kingdom.children)
					M.client.images -= branch.bluex
					if(P && P.class_id_ban && (branch.class_id in P.class_id_ban)) M.client.images += branch.bluex
					if(classban_kingdom != admin_options[M.ckey]["jobban_old_kingdom"])
						M.client << output(branch, "admin/classban.grdBranches:[++i]")

			if(classban_branch)
				var/i = 0
				for(var/character_handling/class/C in classban_branch.children)
					M.client.images -= C.redx
					if(!C.amount) M.client.images += C.redx

					M.client.images -= C.bluex
					if(P && P.class_id_ban && (C.class_id in P.class_id_ban)) M.client.images += C.bluex
					if(classban_branch != admin_options[M.ckey]["jobban_old_branch"])
						M.client << output(C, "admin/classban.grdClasses:[++i]")

			admin_options[M.ckey]["jobban_old_kingdom"] = admin_options[M.ckey]["jobban_kingdom"]
			admin_options[M.ckey]["jobban_old_branch"] = admin_options[M.ckey]["jobban_branch"]