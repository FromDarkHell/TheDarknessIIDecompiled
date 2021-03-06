sloMoTime = 1
fadespeed = 1
TwinA = Instance()
ShotMesh = Resource()
TwinB = Instance()
BloodyHead = Resource()
BloodyBody = Resource()
Mobster = {
  Instance()
}
gunShot = Instance()
vanMover = Instance()
vanLightAttachmentType = Type()
tableObjects = {
  Instance()
}
twinsTable = Instance()
function SloMoTable()
  local gameRules = gRegion:GetGameRules()
  gameRules:RequestSlomo()
  Sleep(sloMoTime)
  gameRules:CancelSlomo()
end
function SwapTwins()
  gunShot:FirePort("Start")
  TwinA:SetMesh(ShotMesh, true, true)
  TwinB:SetOverrideMaterial(1, BloodyHead)
  TwinB:SetOverrideMaterial(0, BloodyBody)
end
function HideMobster()
  for e = 1, #Mobster do
    Mobster[e]:FirePort("Hide")
  end
end
function ClampView()
  local player = gRegion:GetPlayerAvatar()
  local camCtrl = player:CameraControl()
  local minv = Rotation(-10, -5, 0)
  local maxv = Rotation(10, 5, 0)
  camCtrl:SetViewClamp(minv, maxv)
end
function StartVan()
  vanMover:Attach(vanLightAttachmentType, Symbol("GAME_R1_FRONTLIGHT"), Vector(0.15, 0, 0.25), Rotation())
  vanMover:Attach(vanLightAttachmentType, Symbol("GAME_L1_FRONTLIGHT"), Vector(0.15, 0, 0.25), Rotation())
  vanMover:FirePort("PlayTriggeredAnim")
end
function DestroyTableObjects()
  for i = 1, #tableObjects do
    tableObjects[i]:FirePort("Hide")
    tableObjects[i]:FirePort("Destroy")
  end
end
function SwapTableMaterial()
  twinsTable:FirePort("MaterialSwitch")
end
