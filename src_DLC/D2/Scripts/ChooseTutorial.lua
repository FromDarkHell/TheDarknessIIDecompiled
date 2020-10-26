basicDualWieldTutorial = Instance()
altDualWieldTutorial = Instance()
function ChooseTutorial()
  local profile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
  local alt = false
  alt = profile:Settings():SwapFireButtonsWhenDualWielding()
  if alt and not IsNull(altDualWieldTutorial) then
    altDualWieldTutorial:FirePort("Open")
  elseif not IsNull(basicDualWieldTutorial) then
    basicDualWieldTutorial:FirePort("Open")
  end
end
