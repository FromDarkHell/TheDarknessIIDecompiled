stallTime = 0
initialFade = 0
finalFade = 0
transitionTime = 2
playerInvulnerableDuringTransition = false
resetPlayerInvulnerability = false
fadeSound = Resource()
soundPosition = Instance()
loadTrigger = Instance()
postProcessVolume = Instance()
hudMovie = WeakResource()
function Transition()
  local levelInfo = gRegion:GetLevelInfo()
  local postProcess = levelInfo.postProcess
  if not IsNull(postProcessVolume) then
    postProcess = postProcessVolume:GetPostProcessInfo()
  end
  local t = 0
  local fadeVal, snd
  postProcess.fade = initialFade
  local playerAvatar = gRegion:GetPlayerAvatar()
  if IsNull(playerAvatar) == false then
    snd = gRegion:PlaySound(fadeSound, playerAvatar:GetPosition(), false)
    if playerInvulnerableDuringTransition then
      _T.gOldDamageMultiplier = playerAvatar:DamageControl():GetDamageMultiplier()
      playerAvatar:DamageControl():SetDamageMultiplier(0)
    end
  elseif IsNull(soundPosition) == false then
    snd = gRegion:PlaySound(fadeSound, soundPosition:GetPosition(), false)
  end
  Sleep(stallTime)
  local hudMovieInstance = gFlashMgr:FindMovie(hudMovie)
  if IsNull(hudMovieInstance) == false then
    local args
    if finalFade == -1 or finalFade == 1 then
      args = tostring(transitionTime / 2 .. ", " .. 0)
    elseif finalFade == 0 then
      args = tostring(transitionTime .. ", " .. 1)
    end
    hudMovieInstance:Execute("SetGlobalFade", args)
  end
  while t < 1 do
    fadeVal = Lerp(initialFade, finalFade, t)
    postProcess.fade = fadeVal
    t = t + RealDeltaTime() / transitionTime
    Sleep(0)
  end
  postProcess.fade = finalFade
  local currentCinematic = gRegion:GetPlayingCinematic()
  while IsNull(snd) == false do
    Sleep(0)
  end
  if IsNull(loadTrigger) == false then
    loadTrigger:FirePort("LoadImmediate")
  end
  if not IsNull(playerAvatar) and resetPlayerInvulnerability then
    local oldMultiplier = 1
    if _T.gOldDamageMultiplier ~= nil then
      oldMultiplier = _T.gOldDamageMultiplier
    end
    playerAvatar:DamageControl():SetDamageMultiplier(oldMultiplier)
  end
end
