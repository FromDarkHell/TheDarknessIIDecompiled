mobsterA = Instance()
mobsterB = Instance()
chandelierCin = Instance()
wallSpawn = Instance()
minView = -135
maxView = 45
eyeHeight = 0.75
fakeFireScript = Instance()
secondFightTimer = Instance()
stairsGuy = Instance()
function KillMobsterA()
  mobsterA:FirePort("Execute")
end
function KillMobsterB()
  mobsterB:FirePort("Execute")
end
function WallSpawn()
  wallSpawn:FirePort("Start")
end
function StartChandelier()
  chandelierCin:FirePort("StartPlaying")
end
function SetCameraClamps()
  local avatar = gRegion:GetPlayerAvatar()
  local camCtrl = avatar:CameraControl()
  local minv = Rotation(minView, -50, 0)
  local maxv = Rotation(maxView, 20, 0)
  camCtrl:SetViewClamp(minv, maxv)
end
function SetEyeHeight()
  local avatar = gRegion:GetPlayerAvatar()
  local offset = Vector(0, eyeHeight, 0)
  avatar:SetEyePosition(offset)
  Sleep(0)
end
function FakeFire()
  fakeFireScript:FirePort("Execute")
end
function SecondFight()
  secondFightTimer:FirePort("Start")
end
function SpawnGuyStairs()
  stairsGuy:FirePort("Start")
end
