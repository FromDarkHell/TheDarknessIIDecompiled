dualiesModifier = Instance()
lowerGunsModifier = Instance()
loadtrigger = Instance()
streamTime = 10
VinnieScript = Instance()
KitchenShootout = Instance()
friendlyMobster = Instance()
lastLeftSpawner = Instance()
lastRightSpawner = Instance()
hoseScript = Instance()
FireTime = 4
doorLeft = Instance()
doorRight = Instance()
removeAgentsScript = Instance()
cinematicRate = 0.5
currentCinematic = Instance()
function GiveDualies()
  dualiesModifier:FirePort("Activate")
end
function StreamNext()
  loadtrigger:FirePort("Stream")
end
function FireVinnie()
  VinnieScript:FirePort("Execute")
  KitchenShootout:FirePort("Execute")
end
function KillFriendlyMobster()
  friendlyMobster:FirePort("PlayTriggeredAnim")
end
function FakeFireHose()
  hoseScript:FirePort("Execute")
end
function KitchenDoors()
  doorLeft:FirePort("Start")
  doorRight:FirePort("Start")
end
function SpawnLastLeftMobster()
  lastLeftSpawner:FirePort("Start")
end
function SpawnLastRightMobster()
  lastRightSpawner:FirePort("Start")
end
function RemoveAgents()
  removeAgentsScript:FirePort("Execute")
end
function PutAwayGuns()
  lowerGunsModifier:FirePort("Activate")
  local avatar = gRegion:GetPlayerAvatar()
  if not IsNull(avatar) then
    avatar:StopAllWeaponAnims()
  end
end
function SetCinematicRate()
  local rate = currentCinematic:GetPlayRate()
  rate = rate * cinematicRate
  currentCinematic:SetPlayRate(rate)
end
