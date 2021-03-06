npcAvatarType = Type()
chargePointType = Type()
waypoints = {
  Instance()
}
hideWaypoint = Instance()
appearWaypoint = Instance()
throwWaypoint = Instance()
checkpoint = Instance()
braggCheckpointSpawn = Instance()
timeDelayBetweenEscapePoints = 1
hideDelay = 3
healthThreshold = 2795
escapeSpawn = Instance()
escapeSpawnDelay = 5
vanWaypoint = Instance()
vanSpawnPoint = Instance()
phaseEndSpeech = Resource()
phaseStartSpeech = Resource()
hudMovie = WeakResource()
local movieInstance
local prevHealthPct = 0
local function InitHealthBar(avatar)
  movieInstance = gFlashMgr:FindMovie(hudMovie)
end
local function UpdateHealthBar(avatar)
  local healthPct = avatar:GetHealth() / avatar:GetMaxHealth() * 100
  if healthPct ~= prevHealthPct then
    local args = string.format("true,%f,%s", healthPct, "Bragg")
    movieInstance:Execute("SetBossHealthInfo", args)
    prevHealthPct = healthPct
  end
end
local function ShutdownHealthBar(avatar)
  local args = string.format("false,%f,%s", 0, "Bragg")
  if IsNull(movieInstance) then
    movieInstance = gFlashMgr:FindMovie(hudMovie)
  end
  if not IsNull(movieInstance) then
    movieInstance:Execute("SetBossHealthInfo", args)
    movieInstance = nil
  end
end
function EscapeAgent(agent)
  for i = 1, #waypoints do
    local waypoint = waypoints[i]
    local run = false
    agent:MoveTo(waypoint, run, false, true)
    Sleep(timeDelayBetweenEscapePoints)
  end
end
function Escape()
  local avatar = gRegion:FindNearest(npcAvatarType, Vector())
  local agent = avatar:GetAgent()
  for i = 1, #waypoints do
    local waypoint = waypoints[i]
    local run = false
    if waypoint:IsA(chargePointType) then
      run = true
    end
    agent:MoveTo(waypoint, run, false, true)
    Sleep(1)
  end
  avatar:Destroy()
end
function Escape(avatar, waypointList, chargeWayPointType)
  local agent = avatar:GetAgent()
  for i = 1, #waypointList do
    local waypoint = waypointList[i]
    local run = false
    if waypoint:IsA(chargeWayPointType) then
      run = true
    end
    agent:MoveTo(waypoint, run, false, true)
    Sleep(1)
  end
end
function TeleportHide()
  vanWaypoint:FirePort("Disable")
  local avatar = gRegion:FindNearest(npcAvatarType, Vector())
  while IsNull(avatar) do
    avatar = gRegion:FindNearest(npcAvatarType, Vector())
    Sleep(0.5)
  end
  local agent = avatar:GetAgent()
  hideWaypoint:FirePort("Disable")
  avatar:PlaySpeech(phaseEndSpeech, false)
  agent:MoveTo(hideWaypoint, false, true, true)
  avatar:SetVisibility(false)
end
function TeleportAppear()
  local avatar = gRegion:FindNearest(npcAvatarType, Vector())
  while IsNull(avatar) do
    avatar = gRegion:FindNearest(npcAvatarType, Vector())
    Sleep(0.5)
  end
  local agent = avatar:GetAgent()
  hideWaypoint:FirePort("Disable")
  vanWaypoint:FirePort("Enable")
  agent:MoveTo(vanWaypoint, false, true, true)
  agent:StopScriptedMode()
end
