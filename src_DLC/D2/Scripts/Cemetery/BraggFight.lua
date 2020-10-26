startingHealth = 1000
desiredHealth = 0
speechWaypoint = String()
combatWaypoint = String()
nameTag = String()
escapeDelay = 2
timeBetweenEscape = 1
escapeDistance = 5
pauseIndex = 1
conversation = Instance()
dummySpawner = Instance()
escapeWaypoints = {
  Instance()
}
combatWaypoints = {
  Instance()
}
objectOfInterestScript = Instance()
lookTrigger = Instance()
spawnPoint = Instance()
faceToObject = Instance()
deathWaypoint = Instance()
appearWaypoint = Instance()
speechTillAppearTime = 1
appearSpeech = Resource()
npcAvatarType = Type()
braggDeathAgentType = Type()
braggProjectileType = Type()
teleportWaypointType = Type()
chargeEscapePointType = Type()
braggDeathEffect = Type()
spawnControl = Instance()
deathWaypoint = Instance()
fallDownAnim = Resource()
idleAnim = Resource()
hudMovie = WeakResource()
escapeIdleAnim = Resource()
lastStandDamage = 100
destroyAtEnd = false
destroyAfterFlee = true
destoryHUD = true
local movieInstance
local prevHealthPct = 0
local destroyAfterMove = true
local localizedName = nameTag
local function InitHealthBar(avatar)
  movieInstance = gFlashMgr:FindMovie(hudMovie)
end
local function UpdateHealthBar(avatar)
  local healthPct = avatar:GetHealth() / avatar:GetMaxHealth() * 100
  localizedName = movieInstance:GetLocalized(nameTag)
  if healthPct ~= prevHealthPct then
    local args = string.format("true,%f,%s", healthPct, localizedName)
    movieInstance:Execute("SetBossHealthInfo", args)
    prevHealthPct = healthPct
  end
end
local function ShutdownHealthBar(avatar)
  if IsNull(movieInstance) then
    movieInstance = gFlashMgr:FindMovie(hudMovie)
  end
  if not IsNull(movieInstance) then
    localizedName = movieInstance:GetLocalized(nameTag)
    local args = string.format("false,%f,%s", 0, localizedName)
    movieInstance:Execute("SetBossHealthInfo", args)
    movieInstance = nil
  end
end
local EnableWaypoints = function(waypointArray)
  for i = 1, #waypointArray do
    waypointArray[i]:FirePort("Enable")
  end
end
local DisableWaypoints = function(waypointArray)
  for i = 1, #waypointArray do
    waypointArray[i]:FirePort("Disable")
  end
end
function Appear()
  local player = gRegion:GetPlayerAvatar()
  local avatar = gRegion:FindNearest(npcAvatarType, Vector())
  while IsNull(avatar) do
    avatar = gRegion:FindNearest(npcAvatarType, Vector())
    Sleep(0.5)
  end
  local agent = avatar:GetAgent()
  avatar:PlaySpeech(appearSpeech, false)
  Sleep(speechTillAppearTime)
  agent:MoveTo(appearWaypoint, false, false, true)
  agent:StopScriptedMode()
end
local HealthThreshold = function(desiredHealth, avatar)
  local currentHealth = avatar:GetHealth()
  while desiredHealth < currentHealth do
    Sleep(0)
    currentHealth = avatar:GetHealth()
  end
end
local function Escape(avatar, waypointList, chargeWayPointType)
  local agent = avatar:GetAgent()
  agent:SetAllExits(false)
  for i = 1, #waypointList do
    local waypoint = waypointList[i]
    local run = false
    if not IsNull(waypoint) and not IsNull(chargeWayPointType) and waypoint:IsA(chargeWayPointType) then
      run = true
    end
    local direction = waypoint:GetPosition() - avatar:GetPosition()
    local distance = Length(direction)
    while 2 < distance do
      agent:MoveTo(waypoint, run, false, true)
      direction = waypoint:GetPosition() - avatar:GetPosition()
      distance = Length(direction)
      Sleep(0)
    end
  end
  if destroyAfterMove then
    avatar:Destroy()
  end
end
function Activated(entity)
  _T.gLookTriggerEnabled = true
end
local function BraggMove(agent, avatar)
  local k = 1
  agent:LoopAnimation(escapeIdleAnim)
  local health = avatar:GetHealth()
  local player = gRegion:GetPlayerAvatar()
  _T.gLookTriggerEnabled = false
  if not IsNull(lookTrigger) then
    lookTrigger:FirePort("Enable")
    ObjectPortHandler(lookTrigger, "Activated")
  end
  Escape(avatar, escapeWaypoints, chargeEscapePointType)
end
function BraggPhase1()
  local player = gRegion:GetPlayerAvatar()
  local avatar = gRegion:FindNearest(npcAvatarType, Vector())
  local agent = avatar:GetAgent()
  local carriedEntity, health
  local startPos = avatar:GetPosition()
  _T.gEndPhase = false
  InitHealthBar(avatar)
  EnableWaypoints(combatWaypoints)
  avatar:SetMaxHealth(startingHealth)
  avatar:SetHealth(startingHealth)
  health = avatar:GetHealth()
  local run = true
  while health > desiredHealth and run do
    UpdateHealthBar(avatar)
    health = avatar:GetHealth()
    local height = Abs(avatar:GetPosition().y - startPos.y)
    if 0.1 < height then
      run = false
    end
    if _T.gEndPhase then
      break
    end
    Sleep(0)
  end
  Sleep(escapeDelay)
  DisableWaypoints(combatWaypoints)
  ShutdownHealthBar(avatar)
  BraggMove(agent, avatar)
  Sleep(1)
  if not IsNull(avatar) then
    avatar:Destroy()
  end
end
function BraggPhase2()
  local player = gRegion:GetPlayerAvatar()
  local avatar = gRegion:FindNearest(npcAvatarType, Vector())
  local agent = avatar:GetAgent()
  local carriedEntity, health
  _T.gEndPhase = false
  InitHealthBar(avatar)
  EnableWaypoints(combatWaypoints)
  avatar:SetHealth(startingHealth)
  health = avatar:GetHealth()
  while health > desiredHealth do
    UpdateHealthBar(avatar)
    health = avatar:GetHealth()
    if _T.gEndPhase then
      break
    end
    Sleep(0)
  end
  Sleep(escapeDelay)
  DisableWaypoints(combatWaypoints)
  BraggMove(agent, avatar)
  ShutdownHealthBar(avatar)
end
function BraggPhase3()
  local player = gRegion:GetPlayerAvatar()
  local avatar = gRegion:FindNearest(npcAvatarType, Vector())
  local agent = avatar:GetAgent()
  local carriedEntity, health
  _T.gEndPhase = false
  InitHealthBar(avatar)
  EnableWaypoints(combatWaypoints)
  avatar:SetHealth(startingHealth)
  health = avatar:GetHealth()
  while health > desiredHealth do
    UpdateHealthBar(avatar)
    health = avatar:GetHealth()
    if _T.gEndPhase then
      break
    end
    Sleep(0)
  end
  Sleep(escapeDelay)
  DisableWaypoints(combatWaypoints)
  ShutdownHealthBar(avatar)
  BraggMove(agent, avatar)
end
function BraggFinalPhase()
  local player = gRegion:GetPlayerAvatar()
  local avatar = gRegion:FindNearest(npcAvatarType, Vector())
  local agent = avatar:GetAgent()
  local carriedEntity
  InitHealthBar(avatar)
  EnableWaypoints(combatWaypoints)
  while not IsNull(avatar) and avatar:GetHealth() > 0 do
    UpdateHealthBar(avatar)
    Sleep(0.1)
  end
  ShutdownHealthBar(avatar)
end
function BraggPhaseCheckPointOnHealth()
  local avatar = gRegion:FindNearest(npcAvatarType, Vector())
  while IsNull(avatar) do
    avatar = gRegion:FindNearest(npcAvatarType, Vector())
    Sleep(0.5)
  end
  local agent = avatar:GetAgent()
  avatar:SetHealth(startingHealth)
  local health = avatar:GetHealth()
  InitHealthBar(avatar)
  EnableWaypoints(combatWaypoints)
  local startPos = avatar:GetPosition()
  while health > desiredHealth do
    UpdateHealthBar(avatar)
    health = avatar:GetHealth()
    if not IsNull(spawnPoint) then
      spawnPoint:SetPosition(avatar:GetSimPosition())
      spawnPoint:SetRotation(avatar:GetRotation())
    end
    Sleep(0)
  end
  if destoryHUD then
    ShutdownHealthBar(avatar)
  end
  if destroyAtEnd and not IsNull(avatar) then
    avatar:Destroy()
  end
end
function BraggFlee()
  local avatar = gRegion:FindNearest(npcAvatarType, Vector())
  while IsNull(avatar) do
    avatar = gRegion:FindNearest(npcAvatarType, Vector())
    Sleep(0.5)
  end
  avatar:SetHealth(desiredHealth)
  local agent = avatar:GetAgent()
  DisableWaypoints(combatWaypoints)
  if destoryHUD then
    ShutdownHealthBar(avatar)
  end
  destroyAfterMove = destroyAfterFlee
  BraggMove(agent, avatar)
end
function BraggSetHealth()
  local avatar = gRegion:FindNearest(npcAvatarType, Vector())
  while IsNull(avatar) do
    avatar = gRegion:FindNearest(npcAvatarType, Vector())
    Sleep(0.5)
  end
  avatar:SetHealth(desiredHealth)
end
function TeleportToFinalPosition()
  local avatar = gRegion:FindNearest(npcAvatarType, Vector())
  while IsNull(avatar) do
    avatar = gRegion:FindNearest(npcAvatarType, Vector())
    Sleep(0)
  end
  avatar:GetAgent():MoveTo(deathWaypoint, false, false, true)
  avatar:GetAgent():ReturnToAiControl()
  local damageTaken = 0
  local previousHealth = avatar:GetHealth()
  local finished = false
  while not IsNull(avatar) and not finished do
    Sleep(0)
    local currentHealth = avatar:GetHealth()
    if currentHealth ~= previousHealth then
      damageTaken = damageTaken + previousHealth - currentHealth
      previousHealth = currentHealth
      if damageTaken > lastStandDamage then
        finished = true
      end
    end
  end
end
function FallAndWait()
  local avatar = gRegion:FindNearest(npcAvatarType, Vector(), INF)
  local agent = avatar:GetAgent()
  while IsNull(avatar) do
    avatar = gRegion:FindNearest(npcAvatarType, Vector())
    Sleep(0)
  end
  gRegion:CreateEntity(braggDeathEffect, avatar:GetPosition(), avatar:GetRotation())
  Sleep(0.1)
  agent:StopCurrentBehavior()
  agent:ReturnToScriptControl()
  avatar:Teleport(deathWaypoint:GetPosition())
  avatar:PlayAnimation(fallDownAnim, true)
  while not IsNull(avatar) do
    avatar:LoopAnimation(idleAnim)
    avatar:SetHealth(200)
    Sleep(0)
  end
end
