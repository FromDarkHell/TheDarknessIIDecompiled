friendlyMobsterA = Instance()
mobsterB = Instance()
coverMobsterA = Instance()
surprisedMobster = Instance()
fatLady = Instance()
ExecutionMobster = Instance()
WindowMobster = Instance()
spawnA = Instance()
particleHose = Type()
eyeHeight = 0.32
minView = -135
maxView = 45
function KillFriendlyMobsterA()
  friendlyMobsterA:FirePort("PlayTriggeredAnim")
end
function KillMobsterB()
  mobsterB:FirePort("Execute")
end
function KillCoverMobsterA()
  coverMobsterA:FirePort("Execute")
end
function KillFatLady()
  fatLady:FirePort("PlayTriggeredAnim")
end
function StartSpawns()
  spawnA:FirePort("Start")
end
function StartHose()
  local avatar = gRegion:GetPlayerAvatar()
  local po = Vector(0, 2, 5)
  local ro = Rotation(180, 30, 180)
  avatar:Attach(particleHose, Symbol(), po, ro)
end
function SetCameraClamps()
  local avatar = gRegion:GetPlayerAvatar()
  local camCtrl = avatar:CameraControl()
  local minv = Rotation(minView, -50, 0)
  local maxv = Rotation(maxView, 20, 0)
  camCtrl:SetViewClamp(minv, maxv)
end
function StartFight()
  ExecutionMobster:FirePort("Start")
end
function SetEyeHeight()
  local avatar = gRegion:GetPlayerAvatar()
  local offset = Vector(0, eyeHeight, 0)
  avatar:SetEyePosition(offset)
  Sleep(0)
end
