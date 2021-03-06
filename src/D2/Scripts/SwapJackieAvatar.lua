newAvatarType = Type()
waypoint = Instance()
spawnAtNearestHintOfType = Type()
keepOldAvatar = false
teleportOldAvatar = false
teleportWaypoint = Instance()
newAvatarReticuleVisible = true
newAvatarAmmoCountersVisible = true
newAvatarHealthBarVisible = true
destroyOnSpawnTypes = {
  Type()
}
usePostProcessTransition = true
postProcessTransitionDelay = 0
saveOldAvatarToSaveGame = false
clearOldAvatarFromSaveGame = false
npcSpawnControlType = Type()
newAvatarEyeHeight = 0
forcePowersOff = false
postProcessVolumeType = Type()
setPost = Resource()
setFade = 0
changeColorGrading = false
local DestroyObjects = function()
  for i = 1, #destroyOnSpawnTypes do
    if not IsNull(destroyOnSpawnTypes[i]) then
      local entities = gRegion:FindAll(destroyOnSpawnTypes[i], Vector(0, 0, 0), 0, INF)
      if not IsNull(entities) then
        for j = 1, #entities do
          entities[j]:Destroy()
        end
      end
    end
  end
end
local PostProcessFade = function(startFade, finalValue, changeTime)
  Sleep(postProcessTransitionDelay)
  local postProcessArray = {
    gRegion:GetLevelInfo().postProcess
  }
  if not IsNull(postProcessVolumeType) then
    local postProcessVolume = gRegion:FindNearest(postProcessVolumeType, Vector(), INF)
    if not IsNull(postProcessVolume) then
      postProcessArray[#postProcessArray + 1] = postProcessVolume:GetPostProcessInfo()
    end
  end
  local startFade = postProcessArray[#postProcessArray].fade
  if changeTime == 0 then
    for i = 1, #postProcessArray do
      postProcessArray[i].fade = finalValue
    end
    return
  end
  local t = 0
  local val
  while changeTime > t do
    val = Lerp(startFade, finalValue, t / changeTime)
    for i = 1, #postProcessArray do
      postProcessArray[i].fade = val
    end
    t = t + DeltaTime()
    Sleep(0)
  end
  for i = 1, #postProcessArray do
    postProcessArray[i].fade = finalValue
  end
end
local SetHudVisible = function(visible)
  local players = gRegion:ScriptGetLocalPlayers()
  local hudStatus = players[1]:GetHudStatus()
  hudStatus:SetVisible(visible)
end
local SetColorCorrection = function()
  local levelInfo = gRegion:GetLevelInfo()
  local playerAvatar = gRegion:GetPlayerAvatar()
  local gameCamera = playerAvatar:CameraControl()
  local postProcess = levelInfo.postProcess
  gameCamera:PushColorCorrection(setPost, 0, -1, 0)
  postProcess.fade = setFade
end
function ChangeJackie()
  local humanPlayer = gRegion:GetPlayerAvatar():GetPlayer()
  local oldAvatar = humanPlayer:GetAvatar()
  if not IsNull(spawnAtNearestHintOfType) and not oldAvatar:RespawnsOnDeath() then
    return
  end
  if usePostProcessTransition then
    SetHudVisible(false)
    PostProcessFade(0, -1, 1)
  end
  if not IsNull(spawnAtNearestHintOfType) then
    local newSpawnPoint = gRegion:GetGameRules():FindNearestEnabledRespawnPoint(spawnAtNearestHintOfType, oldAvatar:GetSimPosition())
    if not IsNull(newSpawnPoint) then
      waypoint = newSpawnPoint
      newAvatarType = Type(oldAvatar:GetType())
      if not IsNull(npcSpawnControlType) then
        local npcSpawns = gRegion:FindAll(npcSpawnControlType, Vector(0, 0, 0), 0, INF)
        if not IsNull(npcSpawns) then
          for j = 1, #npcSpawns do
            npcSpawns[j]:ReturnAgentsToIdle()
          end
        end
      end
    else
      print([[


___Could not find any enabled respawn points for avatar! Ensure that there is always at least one enabled respawn point!___

]])
      return
    end
  end
  local pos = waypoint:GetPosition()
  local rot = waypoint:GetRotation()
  gRegion:CreateEntity(newAvatarType, pos, rot)
  Sleep(0)
  local newAvatar = gRegion:FindNearest(newAvatarType, pos, INF)
  if newAvatarEyeHeight ~= 0 then
    newAvatar:SetEyePosition(Vector(0, newAvatarEyeHeight, 0))
  end
  if forcePowersOff then
    newAvatar:ForcePowersOff(true)
  end
  newAvatar:SetReticuleVisibility(newAvatarReticuleVisible)
  newAvatar:SetAmmoCountersVisibility(newAvatarAmmoCountersVisible)
  newAvatar:SetHealthBarVisibility(newAvatarHealthBarVisible)
  humanPlayer:ControlAvatar(newAvatar)
  if changeColorGrading then
    SetColorCorrection()
  end
  if usePostProcessTransition then
    PostProcessFade(-1, -1, 0)
  end
  if not keepOldAvatar then
    oldAvatar:SetVisibility(false, true)
  end
  local player = gRegion:GetPlayerAvatar()
  player:SetView(rot)
  player:SetViewOffset(Rotation(), true)
  if teleportOldAvatar then
    oldAvatar:Teleport(teleportWaypoint:GetPosition())
  end
  newAvatar:ScriptInventoryControl():TransferDataFromOldInventoryController(oldAvatar:ScriptInventoryControl())
  if not IsNull(destroyOnSpawnTypes) and 0 < #destroyOnSpawnTypes then
    DestroyObjects()
  end
  if usePostProcessTransition then
    PostProcessFade(-1, 0, 1)
    SetHudVisible(true)
  end
  if saveOldAvatarToSaveGame then
    local jackieReloadPoint = gRegion:FindNearest(Type("/D2/Types/Game/JackieReloadPoint"), pos, INF)
    if not IsNull(jackieReloadPoint) then
      jackieReloadPoint:SetJackieToReload(oldAvatar)
    end
  end
  if not keepOldAvatar then
    oldAvatar:Destroy()
  else
    _T.gOldAvatar = oldAvatar
  end
end
function ChangeBackToOldAvatar()
  local avatar = gRegion:GetPlayerAvatar()
  local player = avatar:GetPlayer()
  local oldAvatar = _T.gOldAvatar
  if usePostProcessTransition then
    SetHudVisible(false)
    PostProcessFade(0, -1, 1)
    Sleep(1.3)
  end
  if not IsNull(oldAvatar) then
    if teleportOldAvatar then
      oldAvatar:Teleport(teleportWaypoint:GetPosition())
    end
    if newAvatarEyeHeight ~= 0 then
      oldAvatar:SetEyePosition(Vector(0, newAvatarEyeHeight, 0))
    end
    player:ControlAvatar(oldAvatar, false)
    oldAvatar:ScriptInventoryControl():TransferDataFromOldInventoryController(avatar:ScriptInventoryControl())
    if usePostProcessTransition then
      PostProcessFade(-1, -1, 0)
    end
    avatar:SetVisibility(false, true)
    _T.gOldAvatar = nil
  end
  if not IsNull(destroyOnSpawnTypes) and 0 < #destroyOnSpawnTypes then
    DestroyObjects()
  end
  if usePostProcessTransition then
    PostProcessFade(-1, 0, 1)
    SetHudVisible(true)
  end
  if clearOldAvatarFromSaveGame then
    local jackieReloadPoint = gRegion:FindNearest(Type("/D2/Types/Game/JackieReloadPoint"), avatar:GetPosition(), INF)
    if not IsNull(jackieReloadPoint) then
      jackieReloadPoint:ClearJackieToReload()
    end
  end
  if not IsNull(oldAvatar) then
    avatar:Destroy()
  end
end
function SetOldAvatarOnReload(oldAvatar)
  _T.gOldAvatar = oldAvatar
end
