vinnieAvatar = Instance()
vinniePistol = Type()
item = Type()
modifier = Instance()
fadespeed = 1
darknessVO = Resource()
function GiveVinniePistol()
  local handBone = Symbol("GAME_R1_WEAPON1")
  vinnieAvatar:Attach(vinniePistol, handBone)
end
function RemoveVinniePistol()
  local pistol = vinnieAvatar:GetAttachment(vinniePistol)
  pistol:FirePort("Hide")
end
function GivePistol()
  modifier:FirePort("Activate")
  local player = gRegion:GetPlayerAvatar()
  player:SetReticuleVisibility(true)
end
function FadeUpScreen()
  local playerAvatar = gRegion:GetPlayerAvatar()
  Sleep(0)
  local postProcess = gRegion:GetLevelInfo().postProcess
  postProcess.fade = 0
end
function StopSlomo()
  local gameRules = gRegion:GetGameRules()
  local player = gRegion:GetPlayerAvatar()
  gameRules:CancelSlomo()
  player:PlaySound(darknessVO, false)
end
function PlayVinnie()
  vinnieAvatar:FirePort("PlayTriggeredAnim")
end
