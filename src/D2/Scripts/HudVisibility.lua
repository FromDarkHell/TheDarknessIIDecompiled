hud = Resource()
visible = false
function SetHudVisible()
  local movieInstance = gFlashMgr:FindMovie(hud)
  if not IsNull(movieInstance) then
    movieInstance:SetVisible(visible)
  else
    print("HudVisibility.lua: hud movie not found (may not be playing yet; consider adding a delay before executing this script)")
  end
end
