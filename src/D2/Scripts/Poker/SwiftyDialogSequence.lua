dialogScriptTriggers = {
  Instance()
}
dialogLength = {0}
dialogTriggers = {
  Instance()
}
triggerDialogOnStart = Instance()
dialogOnStartLength = 0
altTriggers = {
  Instance()
}
portCounterType = Type()
portTimerType = Type()
local dialogTriggered = {false}
local enemiesKilled = {0}
_T.gDialogPlaying = false
function OnTouched(entity)
  for i = 0, #dialogTriggers do
    if entity == dialogTriggers[i] then
      dialogTriggered[i] = true
    end
  end
end
function CountReached(entity)
  for i = 0, #altTriggers do
    if entity == altTriggers[i] then
      dialogTriggered[i] = true
    end
  end
end
function OnTimerExpired(entity)
  for i = 0, #altTriggers do
    if entity == altTriggers[i] then
      dialogTriggered[i] = true
    end
  end
end
function LoadingDocksAudio()
  dialogTriggered = {false}
  enemiesKilled = {0}
  _T.gDialogPlaying = false
  if not IsNull(triggerDialogOnStart) then
    triggerDialogOnStart:FirePort("Execute")
    Sleep(dialogOnStartLength)
  end
  for i = 0, #dialogTriggers do
    if not IsNull(dialogTriggers[i]) then
      ObjectPortHandler(dialogTriggers[i], "OnTouched")
    end
  end
  for i = 0, #altTriggers do
    if not IsNull(altTriggers[i]) then
      if altTriggers[i]:IsA(portCounterType) then
        ObjectPortHandler(altTriggers[i], "CountReached")
      elseif altTriggers[i]:IsA(portTimerType) then
        ObjectPortHandler(altTriggers[i], "OnTimerExpired")
      end
    end
  end
  local d = 1
  while d <= #dialogScriptTriggers do
    if not IsNull(dialogScriptTriggers[d]) and dialogTriggered[d] == true then
      dialogScriptTriggers[d]:FirePort("Execute")
      Sleep(dialogLength[d])
      d = d + 1
    end
    Sleep(0)
  end
  local t = altTriggers
end
