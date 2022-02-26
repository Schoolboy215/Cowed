admin/council/verb
	set_admin(var/ckey as text, var/level as num)
		set category = "Admin"
		ckey = ckey(ckey)
		if(!(usr.ckey in developers) && level > 1)
			usr << "Council members may not add above level 1."
			return
		if(!(usr.ckey in developers) && global.admin.admins[ckey] > 1)
			usr << "Council members may not change the level of above above level 1."
			return
		if(!level && !(ckey in global.admin.admins)) return
		var/key = admin.GetBYONDKey(ckey)
		if(!key)
			usr << "That key does not exist!"
			return

		if(!level)
			global.admin.RemoveAdmin(ckey)
		else
			global.admin.AddAdmin(ckey, level)

		usr << "[key] is now a level [level] administrator. (0 = deleted, 1 = normal, 2 = council)"
		global.admin.AddLog(usr.key, "[key] is [level ? "now a level [level] administrator." : "no longer an administrator."]")

		for(var/client/C)
			if(C.ckey == ckey) C.CheckAdmin()