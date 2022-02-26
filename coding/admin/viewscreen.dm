admin_viewpoint
	var
		atom/loc
		list/mobs
	proc
		receive(txt)
			if(ActionLock(txt, 10)) return
			send_message(mobs, txt, 1)

admin_viewscreen
	var
		list
			viewers
			viewports
		mob/master
	proc
		interact(mob/M)
			if(!M || !M.client || !M.client.eye) return
			if(!viewers) viewers = new()
			src.master = M
			M.using = src
			M.moveRelay = src
			viewers[M] = 0
			M.client.perspective = EYE_PERSPECTIVE
			winshow(M, "admin/viewscreen")
			refresh(M, 1)

		AdjustViewPort(id, turf/T)
			if(!viewports) viewports = new()
			var/mob/eavesdropper/M = viewports[id]
			if(!M) viewports[id] = new/mob/eavesdropper(T)
			else M.Move(T, forced = 1)
		Select(mob/T, mob/M)
			if(!M || !M.client) return
			M.client.eye = T
			if(viewers[M] > 0) AdjustViewPort(viewers[M], T)
			if(master) refresh(master)
		moveRelay(mob/M, newloc, newdir)
			if(!M || !M.client || !istype(M.client.eye, /atom)) return
			if(!newdir)
				if(!newloc) return
				newdir = get_dir(M, newloc)
			if(!newdir) return
			var/atom/A = M.client.eye
			A = get_step(A, newdir)
			if(A)
				M.client.eye = A
				if(viewers[M] > 0) AdjustViewPort(viewers[M], A)

				for(var/mob/N in range(1, src)) if(N.using == src) refresh(N)
		refresh(mob/M, refresh_mobs = 0)
			if(!M || !M.client) return
			var/list/L = list(
				"admin/viewscreen.on-close" = "byond://?src=\ref[src];cmd=close",
				"admin/viewscreen.lblViewPort.text" = viewers[M],
				"admin/viewscreen.lblZ.text" = istype(M.client.eye, /atom) ? M.client.eye:z : "N/A",
				"admin/viewscreen.btnVL.command" = "byond://?src=\ref[src];cmd=vl",
				"admin/viewscreen.btnVR.command" = "byond://?src=\ref[src];cmd=vr",
				"admin/viewscreen.btnZL.command" = "byond://?src=\ref[src];cmd=zl",
				"admin/viewscreen.btnZR.command" = "byond://?src=\ref[src];cmd=zr",
				"admin/viewscreen.btnRefresh.command" = "byond://?src=\ref[src];cmd=refresh",
				"admin/viewscreen.lblLoc.text" = istype(M.client.eye, /atom) && !ismob(M.client.eye) ? "[M.client.eye:x],[M.client.eye:y],[M.client.eye:z]" : "N/A"
			)
			if(refresh_mobs) L["admin/viewscreen.lstPlayers.cells"] = 0
			winset(M, null, list2params(L))

			if(refresh_mobs)
				var/i = 0
				for(var/mob/N in world)
					if(!N.key) continue
					M << output(N, "admin/viewscreen.lstPlayers:[++i]")

			if(viewers[M] > 0 && (viewports && viewports.len >= viewers[M]))
				var/atom/A = viewports[viewers[M]]
				M.client.eye = A
	Topic(href, href_list[])
		if(!usr || !usr.client || usr != master) return
		switch(href_list["cmd"])
			if("close")
				usr.client.eye = usr
				usr.client.perspective = MOB_PERSPECTIVE
				usr.using = null
				usr.moveRelay = null
				viewers -= usr
				if(viewers.len <= 0)
					viewers = null
				winshow(usr, "admin/viewscreen", 0)
				return
			if("vl")
				var/viewport = viewers[usr]
				viewport--
				if(viewport <= 0) viewport = 0
				viewers[usr] = viewport
			if("vr")
				var/viewport = viewers[usr]
				viewport++
				if(viewport > 9) viewport = 9
				if(!viewports) viewports = new()
				if(viewports.len < viewport) viewports += new/mob/eavesdropper(usr.client.eye)

				viewers[usr] = viewport
			if("zl", "zr")
				var/atom/A = usr.client.eye
				if(!A) return
				A = locate(A.x, A.y, A.z - (href_list["cmd"] == "zl" ? 1 : -1))
				if(A)
					usr.client.eye = A
					if(viewers[usr] > 0) AdjustViewPort(viewers[usr], A)
			if("refresh")
				for(var/mob/M in range(1, src)) if(M.using == src) refresh(M, 1)
				return
		if(master) refresh(master)