vinnieCin = Instance()
kneecapModifier = Instance()
removeModifier = Instance()
eyeHeight = 0.28
spawns = {
  Instance()
}
spawnerDelay = Instance()
BarShootOutScript = Instance()
minView = -135
maxView = 45
function Bar()
  BarShootOutScript:FirePort("Execute")
end
function PlayVinnieCin()
  vinnieCin:FirePort("StartPlaying")
end
function GiveKneecapPistol()
  kneecapModifier:FirePort("Activate")
end
function RemoveGuns()
  removeModifier:FirePort("Activate")
end
function SetEyeHeight()
  local avatar = gRegion:GetPlayerAvatar()
  local offset = Vector(0, eyeHeight, 0)
  avatar:SetEyePosition(offset)
  Sleep(0)
end
function SpawnEnemies()
  for i = 1, #spawns do
    spawns[i]:FirePort("Start")
  end
end
function SpawnDelayedEnemy()
  spawnerDelay:FirePort("Start")
end
function SetCameraClamps()
  local avatar = gRegion:GetPlayerAvatar()
  local camCtrl = avatar:CameraControl()
  local minv = Rotation(minView, -50, 0)
  local maxv = Rotation(maxView, 20, 0)
  camCtrl:SetViewClamp(minv, maxv)
end
