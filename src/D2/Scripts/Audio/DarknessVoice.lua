initialDelay = 0
soundList = {
  Resource()
}
endPost = Resource()
ghostBlurValue = 0.25
forceFeedbackMultiplier = 0.5
radialBlurMultipler = 0
viewShakeMultiplier = 3
randomDelays = true
replicate = true
resetPostAfterDialog = true
local LerpColour = function(startColour, endColour, t)
  local sc = startColour
  local ec = endColour
  local sr = startColour.red
  local sg = startColour.green
  local sb = startColour.blue
  local sa = startColour.alpha
  local er = endColour.red
  local eg = endColour.green
  local eb = endColour.blue
  local ea = endColour.alpha
  local mr = Lerp(sr, er, t)
  local mg = Lerp(sg, eg, t)
  local mb = Lerp(sb, eb, t)
  local ma = Lerp(sa, ea, t)
  return Color(mr, mg, mb, ma)
end
local LocalDarknessVoice = function(sound)
  local levelInfo = gRegion:GetLevelInfo()
  local postProcessInfo = levelInfo.postProcess
  local startGhostBlur = postProcessInfo.ghostBlur
  local humanPlayers = gRegion:GetHumanPlayers()
  local playerAvatar = gRegion:GetLocalPlayer()
  local soundInstance, cameraController
  local backupFadePerUpdate = 0.05
  while IsNull(playerAvatar) or IsNull(cameraController) do
    Sleep(0.1)
    playerAvatar = gRegion:GetLocalPlayer()
    if not IsNull(playerAvatar) then
      cameraController = playerAvatar:CameraControl()
    end
  end
  if IsNull(playerAvatar) == false then
    soundInstance = playerAvatar:PlaySound(sound, false, 1, replicate)
  else
    soundInstance = gRegion:PlaySound(sound, Vector(), false, replicate)
  end
  cameraController:PushColorCorrection(endPost, 0, -1, 0)
  local opacity = 0
  local amplitude = 0
  while amplitude ~= 0 or not IsNull(soundInstance) do
    for i = 1, #humanPlayers do
      local player = humanPlayers[i]
      if IsNull(player) or not player:IsLocal() then
      else
        playerAvatar = humanPlayers[i]:GetAvatar()
        local cameraController = playerAvatar:CameraControl()
        if not IsNull(soundInstance) then
          amplitude = soundInstance:GetCurAmplitude()
        else
          amplitude = math.max(0, amplitude - backupFadePerUpdate)
        end
        opacity = Converge(opacity, Abs(amplitude), 2 * DeltaTime())
        cameraController:SetColorCorrectionOpacity(endPost, opacity)
        postProcessInfo.viewShake.mShakeAmbient = Abs(Sin(amplitude * 2)) * viewShakeMultiplier
        postProcessInfo.radialBlurStrength = amplitude * radialBlurMultipler
        player:PlayForceFeedback(amplitude * forceFeedbackMultiplier, amplitude * forceFeedbackMultiplier, 0.1)
        postProcessInfo.ghostBlur = ghostBlurValue * amplitude
      end
    end
    Sleep(0)
  end
  playerAvatar = gRegion:GetLocalPlayer()
  if not IsNull(playerAvatar) then
    local cameraController = playerAvatar:CameraControl()
    cameraController:RemoveColorCorrection(endPost)
  end
end
local JackieVoice = function(sound)
  local playerAvatar = gRegion:GetPlayerAvatar()
  local player = playerAvatar:GetPlayer()
  local soundInstance = playerAvatar:PlaySound(sound, false)
  while IsNull(soundInstance) == false do
    Sleep(0)
  end
end
local JennyVoice = function(sound)
  local playerAvatar = gRegion:GetPlayerAvatar()
  local player = playerAvatar:GetPlayer()
  local soundInstance = playerAvatar:PlaySound(sound, false)
  while IsNull(soundInstance) == false do
    Sleep(0)
  end
end
function DarknessVoice()
  local initialPostProcessInfo = gRegion:GetLevelInfo().postProcess
  Sleep(initialDelay)
  for i = 1, #soundList do
    if randomDelays == true then
      if i ~= 1 then
        Sleep(0.25 + Random(0.15, 0.25))
      end
    else
      Sleep(0.1)
    end
    local s = soundList[i]:GetFullName()
    if string.find(s, "Jenny") ~= nil then
      JennyVoice(soundList[i])
    elseif string.find(s, "Jackie") ~= nil then
      JackieVoice(soundList[i])
    elseif string.find(s, "Darkness") ~= nil or string.find(s, "Cedro") ~= nil then
      LocalDarknessVoice(soundList[i])
    end
  end
  Sleep(1)
  if resetPostAfterDialog then
    gRegion:GetLevelInfo().postProcess = initialPostProcessInfo
  end
end
