client
	var
		map_editor/map_editor
	proc
		CheckAdmin()
			while(!global.admin) sleep(2)
			verbs -= typesof(/admin/dev/verb)
			verbs -= typesof(/admin/council/verb)
			verbs -= typesof(/admin/admin/verb)

			if(ckey in developers) verbs += typesof(/admin/dev/verb)

			admin = global.admin.GetAdmin(ckey)
			if(admin >= 1)
				verbs += typesof(/admin/admin/verb)
			if(admin >= 2)
				verbs += typesof(/admin/council/verb)

			if(!global.admin.admin_options) global.admin.admin_options = new/list()
			global.admin.admin_options[ckey] = list()

			if(pm) pm.showWindow(src)
	verb
		list_admins()
			send_message(src, "<b>Current Adminstrators:</b>", 3)
			. = 0
			//for(var/rank in list("Developer", "Council", "Head Moderator", "GM", "Support", "Spy"))
			for(var/client/C)
				if(C.admin)
					.++
					send_message(src, "\t [C.key]", 3)
			send_message(src, "<b>Total Online:</b> [.]", 3)
		admin_help(t as text)
			if(!mob || !t) return
			if(!adminhelp)
				send_message(src, "Admin help has been turned off. Your message was NOT sent.", 3)
				return
			if(usr.ActionLock("adminhelp", 50))
				send_message(src, "You can't send another request yet. Please wait.")
				return
			if(usr && usr.client && usr.client.muted)
				send_message(src, "You don't have permission to invoke this command.")
				return
			if(length(t) > 1200) t = copytext(t, 1, 1201)
			t = html_encode(t)
			for(var/client/C)
				if(C.admin)
					send_message(C, "\blue Admin Help- [key] ([mob.name]): [t]", 3)
					. = 1
			if(.)
				send_message(src, "Your request was sent to the administrators.", 3)
				global.admin.AddChatLog(src.key, src.mob ? src.mob.name : "N/A", t, "adminhelp")
			else send_message(src, "No administrators are presently online to serve your request.", 3)