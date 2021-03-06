mobsterDeco = Instance()
animSequence = {
  Resource()
}
soundSequence = {
  Resource()
}
releaseDarknessContextAction = Instance()
failTime = 8.5
local darknessActivated = false
function OnActivated()
  darknessActivated = true
end
function PlaySequenceOnDeco()
  local mobsterAgent = mobsterDeco
  local t = 0
  local playerAvatar = gRegion:GetPlayerAvatar()
  Sleep(0)
  local postProcess = gRegion:GetLevelInfo().postProcess
  if IsNull(releaseDarknessContextAction) == false then
    ObjectPortHandler(releaseDarknessContextAction, "OnActivated")
  end
  mobsterAgent:PlayAnimation(animSequence[1], false)
  Sleep(7)
  mobsterAgent:PlaySpeech(soundSequence[2], false)
  Sleep(4)
  mobsterAgent:PlaySpeech(soundSequence[1], false)
  Sleep(2.26)
  mobsterAgent:LoopAnimation(animSequence[2])
  while t < failTime do
    if darknessActivated then
      return
    end
    t = t + DeltaTime()
    Sleep(0)
  end
  releaseDarknessContextAction:Destroy()
  Sleep(0.5)
  mobsterAgent:PlayAnimation(animSequence[3], false)
  Sleep(0.8)
  mobsterAgent:PlaySound(soundSequence[3], false)
  postProcess.fade = 2
  playerAvatar:SetQuickDeathFade(true)
  playerAvatar:SetQuickDeathFadeTime(0.5)
  playerAvatar:Damage(500)
end
local PlaySequenceOnAgent = function(agent)
  local t = 0
  local playerAvatar = gRegion:GetPlayerAvatar()
  Sleep(0)
  local postProcess = gRegion:GetLevelInfo().postProcess
  agent:SetAllExits(false)
  agent:PlayAnimation(animSequence[1], false)
  Sleep(7)
  agent:GetAvatar():PlaySpeech(soundSequence[2], false)
  Sleep(4)
  agent:GetAvatar():PlaySpeech(soundSequence[1], false)
  Sleep(4.4)
  while t < failTime do
    if agent:HasActions() == false then
      agent:PlayAnimation(animSequence[2], false)
    end
    t = t + DeltaTime()
    Sleep(0)
  end
  releaseDarknessContextAction:FirePort("Disable")
  Sleep(0.5)
  agent:PlayAnimation(animSequence[3], false)
  Sleep(0.8)
  agent:GetAvatar():PlaySound(soundSequence[3], false)
  postProcess.fade = 2
  playerAvatar:SetQuickDeathFade(true)
  playerAvatar:SetQuickDeathFadeTime(1)
  playerAvatar:Damage(500)
end
