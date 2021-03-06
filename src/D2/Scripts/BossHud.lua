hudMovie = WeakResource()
nameTag = String()
disableThreshold = 0
local movieInstance
local prevHealthPct = 0
local localizedName = nameTag
npcAvatarType = Type()
local function InitHealthBar(avatar)
  movieInstance = gFlashMgr:FindMovie(hudMovie)
  if not IsNull(movieInstance) then
    localizedName = movieInstance:GetLocalized(nameTag)
  end
end
local function UpdateHealthBar(avatar)
  local healthPct = avatar:GetHealth() / avatar:GetMaxHealth() * 100
  if healthPct ~= prevHealthPct then
    local args = string.format("true,%f,%s", healthPct, localizedName)
    if not IsNull(movieInstance) then
      movieInstance:Execute("SetBossHealthInfo", args)
    end
    prevHealthPct = healthPct
  end
end
local function ShutdownHealthBar(avatar)
  if not IsNull(movieInstance) then
    local args = string.format("false,%f,%s", 0, localizedName)
    movieInstance:Execute("SetBossHealthInfo", args)
  end
  movieInstance = nil
end
function UpdateHud(avatar)
  while IsNull(movieInstance) do
    Sleep(0)
    InitHealthBar(avatar)
  end
  while not IsNull(avatar) and avatar:GetHealth() > disableThreshold do
    UpdateHealthBar(avatar)
    Sleep(0)
  end
  ShutdownHealthBar(avatar)
end
local function UpdateHudLocal(avatar)
  while IsNull(movieInstance) do
    Sleep(0)
    InitHealthBar(avatar)
  end
  while not IsNull(avatar) and avatar:GetHealth() > disableThreshold do
    UpdateHealthBar(avatar)
    Sleep(0)
  end
  ShutdownHealthBar(avatar)
end
function UpdateHudOnAvatar()
  local avatar = gRegion:FindNearest(npcAvatarType, Vector())
  while IsNull(avatar) do
    avatar = gRegion:FindNearest(npcAvatarType, Vector())
    Sleep(0.5)
  end
  UpdateHudLocal(avatar)
end
