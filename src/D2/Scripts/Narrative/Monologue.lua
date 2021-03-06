movieRes = WeakResource()
skipCinematicAction = Instance()
cinematic = Instance()
function Start()
  local flashInstance = gFlashMgr:FindMovie(movieRes)
  local actionItem = 6
  if IsNull(flashInstance) == false then
    flashInstance:SetVariable("ContextActionPane._x", 85)
    flashInstance:SetVariable(string.format("ContextActionPane.Action%i.Container.Text.text", actionItem), " ")
    flashInstance:SetVariable(string.format("ContextActionPane.Action%i.Container.Text.textAlign", actionItem), "left")
  end
  if IsNull(cinematic) then
    local cinematicType = Type("/EE/Types/Game/Cinematic")
    cinematic = gRegion:FindNearest(cinematicType, Vector(), INF)
  end
  if IsNull(skipCinematicAction) then
    local skipCinematicActionType = Type("/D2/Types/Actions/SkipMonologueCinematicAction")
    skipCinematicAction = gRegion:FindNearest(skipCinematicActionType, Vector(), INF)
  end
  ObjectPortHandler(cinematic, "OnStopped")
  ObjectPortHandler(cinematic, "OnSkipPopupDisplayed")
  local gameRules = gRegion:GetGameRules()
  local levelInfo = gRegion:GetLevelInfo()
  if not IsNull(gameRules) then
    gameRules:SetPauseDisabled(true)
  end
  Sleep(1)
  local playerAvatar = gRegion:GetPlayerAvatar()
  local playerDamageControl = playerAvatar:DamageControl()
  playerDamageControl:SetDamageMultiplier(0)
  local loadTriggerType = Type("/EE/Types/Game/LoadTrigger")
  local loadTriggerInstance = gRegion:FindNearest(loadTriggerType, Vector(), INF)
  loadTriggerInstance:FirePort("Stream")
  _T.monologueLoadTrigger = loadTriggerInstance
  ObjectPortHandler(loadTriggerInstance, "StreamingFinished")
end
function StreamingFinished()
  skipCinematicAction:Enable()
  cinematic:ToggleSkipable()
end
function OnStopped()
  skipCinematicAction:Disable()
end
function OnSkipPopupDisplayed()
  skipCinematicAction:Disable()
end
