mob/character_handling
	var
		character_handling/container
			old_kingdom
			old_branch
			branch
		character_handling/class/class
		image
			selector_kingdom
			selector_branch
			selector_class
	New()
		. = ..()
		selector_kingdom = image(icon = 'icons/Classes.dmi', loc = null, icon_state = "selector")
		selector_branch = image(icon = 'icons/Classes.dmi', loc = null, icon_state = "selector")
		selector_class = image(icon = 'icons/Classes.dmi', loc = null, icon_state = "selector")
	proc
		Display()
			selector_kingdom.loc = kingdom
			selector_branch.loc = branch
			selector_class.loc = class
			var
				player/P = client.player
				list
					recent_names = P.GetRecentNames()
					L = list(
					"character_handling.txtName.text" = src.name,
					"character_handling.radGenderM.is-checked" = (gender == MALE ? "true":"false"),
					"character_handling.radGenderF.is-checked" = (gender == FEMALE ? "true":"false"),
					"character_handling.grdKingdoms.cells" = "[game.kingdoms.len]",
					"character_handling.grdKingdoms.size" = "[(game.kingdoms.len * 36) + 48]x36",
					"character_handling.grdNames.cells" = "[recent_names ? "1x[recent_names.len]" : "0x0"]",
					"character_handling.grdBranches.is-visible" = (kingdom ? "true" : "false"),
					"character_handling.lblBranch.is-visible" = (kingdom ? "true" : "false"),
					"character_handling.lblBranch1.is-visible" = (kingdom ? "true" : "false"),
					"character_handling.grdClasses.is-visible" = (branch ? "true" : "false"),
					"character_handling.lblClass.is-visible" = (branch ? "true" : "false"),
					"character_handling.lblClass1.is-visible" = (branch ? "true" : "false"),
					"character_handling.btnCreate.is-disabled" = (!kingdom || !branch || !class ? "true" : "false"),
					"character_handling.btnSpectate.is-disabled" = (!kingdom ? "true" : "false"),
					"character_handling.btnCreate.command" = "byond://?src=\ref[src];cmd=create",
					"character_handling.btnSpectate.command" = "byond://?src=\ref[src];cmd=spectate",
					"character_handling.radGenderM.command" = "byond://?src=\ref[src];cmd=genderM",
					"character_handling.radGenderF.command" = "byond://?src=\ref[src];cmd=genderF",
				)
			if(src.kingdom != src.old_kingdom)
				L["character_handling.grdBranches.cells"] = "[kingdom ? kingdom.children.len : 0]"
				L["character_handling.grdClasses.cells"] = "0"
				branch = null
				class = null
				selector_branch.loc = null
				selector_class.loc = null
			if(src.branch != src.old_branch)
				L["character_handling.grdClasses.cells"] = "[branch ? branch.children.len : 0]"
				class = null
				selector_class.loc = null
			winset(src, null, list2params(L))

			if(!kingdom && game.kingdoms.len)
				var/i = 0
				for(var/character_handling/container/kingdom in game.kingdoms)
					client.images -= kingdom.bluex
					if(!kingdom.CanSelect(src)) client.images += kingdom.bluex
					src << output(kingdom, "character_handling.grdKingdoms:[++i]")

			if(src.kingdom != src.old_kingdom)
				if(kingdom)
					var/i = 0
					for(var/character_handling/container/branch in src.kingdom.children)
						client.images -= branch.bluex
						if(!branch.CanSelect(src)) client.images += branch.bluex
						src << output(branch, "character_handling.grdBranches:[++i]")

			if(src.branch != src.old_branch)
				if(branch)
					var/i = 0
					for(var/character_handling/class/C in src.branch.children)
						if(C.img_amount)
							client.images -= C.img_amount
							client.images += C.img_amount

						client.images -= C.redx
						if(!C.amount) client.images += C.redx

						client.images -= kingdom.bluex
						if(!C.CanSelect(src)) client.images += C.bluex
						src << output(C, "character_handling.grdClasses:[++i]")

			src.old_kingdom = src.kingdom
			src.old_branch = src.branch

			if(recent_names && recent_names.len)
				var/i = 0
				for(var/name in recent_names)
					src << output("<a href=\"byond://?src=\ref[src];cmd=name;name=[++i]\">[name]</a>", "character_handling.grdNames:1,[i]")
		/*Kingdom2Text(kingdom)
			switch(kingdom)
				if("bovinia")
					return "The Bovinia Kingdom is to the left of the map and has a strict hierachy and levels of control.\
					You are not free to do what you please and everyone is expected to respect their church duty.\
					The King is in charge and his or her word is final.\
					However because the law is so strictly upheld executions are a dime a dozen in this kingdom."
				if("cowmalot")
					return "The Cowmalot Kingdom is a partially democratic kingdom after an uprising changed the law.\
					Although the king/queen sits on the throne they act on behalf of the public and often hold votes on \
					critical decisions. You are free to persue your own religion here however the law is not set in stone \
					and you may be sued for pretty much any reason."
				if("peasants")
					return "As a peasant you are free to do whatever you please; build your own house, start mining for rocks \
					or join a cult! You make your own story and set your own destiny. Just be sure to listen to the GM's though!"
				if("family")
					return "As a member of a family you have a special spawn location and some unique items. Don't get too \
					excited though... this luxury will change."
				else
					return "Uh-oh! I was supposed to show a little description in this tooltip here, but nobody told me what to put here!"*/
	Login()
		if(!client) return
		winset(src, "default/game.child", "left=character_handling")

		/*gender = PLURAL
		Display()*/

		var/player/P = client.player
		if(P)
			src.gender = P.GetVariable("gender") || MALE
			src.name = P.GetVariable("name") || src.key
			//if(!(name in names)) names += name

			client.images += selector_kingdom
			client.images += selector_branch
			client.images += selector_class
			Display()
	Logout()
		del src
	Topic(href, href_list[])
		if(href_list["cmd"] == "spectate" && kingdom)
			. = CheckName()
			if(. == 1)
				alert(src, "Please specify a name for your character!")
				return
			if(. == 2)
				alert(src, "Sorry; this name has already been taken!")
				return
			if(. == 3)
				alert(src, "Your name must consist of a first and last name.")
				return
			if(!.)
				var/mob/observer/N = new(Locate(kingdom._x, kingdom._y, kingdom, kingdom._z), force_am = 1)
				N.name = src.name
				N.gender = src.gender

				RemoveImages()
				src.client.mob = N
		else if(href_list["cmd"] == "create" && kingdom && branch && class)
			. = CheckName()
			if(. == 1)
				alert(src, "Please specify a name for your character!")
				return
			if(. == 2)
				alert(src, "Sorry; this name has already been taken!")
				return
			if(. == 3)
				alert(src, "Your name must consist of a first and last name.")
				return
			if(!.)
				RemoveImages()
				if(class) class.Invoke(src)
		else if(href_list["cmd"] == "name")
			var
				name = text2num(href_list["name"])
				player/P = client.player
				list/recent_names = P ? P.GetRecentNames() : null
			if(name > 0 && P && recent_names && recent_names.len >= name)
				winset(src, null, list2params(list("character_handling.txtName.text" = recent_names[name])))
				src.name = recent_names[name]
		else if(href_list["cmd"] == "genderF")
			src.gender = FEMALE
		else if(href_list["cmd"] == "genderM")
			src.gender = MALE
	proc
		CheckName()
			var
				name = trimAll(winget(src, "character_handling.txtName", "text"))
			if(!name || name == " ") return 1
			if((name in names)) return 2
			if(!findtext(name, " ")) return 3

			src.name = name

			var/player/P = client.player
			if(P)
				P.SetVariable("name", name)
				P.SetVariable("gender", src.gender)

				P.AddRecentName(name)
			return 0
		RemoveImages()
			client.images -= selector_kingdom
			client.images -= selector_branch
			client.images -= selector_class
			RemoveClassImages()
			for(var/I in client.images) client.images -= I
	/*Topic(href, href_list[])
		if(!chosen)
			if("name" in href_list)
				var
					name = href_list["name"] || "Ben Dover"
					old_name = src.name

				if(!trimAll(name) || trimAll(name) == " ")
					alert(usr, "No name entered! Please specify a valid name!")
					return
				if((name in names) && name != old_name)
					alert(usr, "Sorry; this name has already been taken! Please specify a valid name!")
					return

				src.name = name
				names -= old_name
				names += name
				chosen = 1
				if(href_list["gender"] == "female") gender = FEMALE
				else gender = MALE
				client.Save()
				Display2()
		else
			if(vote_system.vote && href_list["cmd"] == "vote")
				src << link("byond://?src=\ref[vote_system];cmd=vote;choice=[href_list["choice"]];verbose=1")
			else if(href_list["kingdom"])
				kingdom = href_list["kingdom"]
				Display2()
			else if(href_list["class"])
				var/class/C = locate(href_list["class"])
				if(!(C in game.classes)) return
				if(C.amount <= 0 && C.amount != -2)
					alert(src, "This class has already been taken!")
					return
				C.Invoke(src)*/
	Life() return