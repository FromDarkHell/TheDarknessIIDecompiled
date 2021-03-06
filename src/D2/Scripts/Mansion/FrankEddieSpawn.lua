frankSpawner = Instance()
eddieSpawner = Instance()
local frankToken = Symbol("BrothelKilledFrank")
local eddieToken = Symbol("BrothelKilledEddie")
function Start()
  local playerAvatar = gRegion:GetPlayerAvatar()
  local frankTokenState = playerAvatar:GetQuestTokenState(frankToken)
  local eddieTokenState = playerAvatar:GetQuestTokenState(eddieToken)
  if frankTokenState ~= 0 then
    eddieSpawner:FirePort("Start")
  elseif eddieTokenState ~= 0 then
    frankSpawner:FirePort("Start")
  elseif math.random(1, 2) == 1 then
    playerAvatar:SetQuestTokenState(eddieToken, Engine.QTS_ACTIVE)
    frankSpawner:FirePort("Start")
  else
    playerAvatar:SetQuestTokenState(frankToken, Engine.QTS_ACTIVE)
    eddieSpawner:FirePort("Start")
  end
end
