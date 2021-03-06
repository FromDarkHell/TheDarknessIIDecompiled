talents = {
  WeakResource()
}
hud = WeakResource()
delay = 0
function GiveInventory()
  Sleep(delay)
  local player = gRegion:GetPlayerAvatar()
  local inventory = player:ScriptInventoryControl()
  local movieInstance = gFlashMgr:FindMovie(hud)
  local realTalent
  if not IsNull(movieInstance) then
    movieInstance:Execute("SetAdaptiveTrainingEnabled", 0)
  end
  if not IsNull(player) then
    if not IsNull(talents) then
      for i = 1, #talents do
        realTalent = inventory:GetTalentByResName(talents[i]:GetResourceName())
        if not IsNull(realTalent) then
          inventory:BuyTalent(realTalent)
        end
      end
    end
    local finisherAction = player:GetFinisherAction()
    if not IsNull(finisherAction) then
    end
  end
end
function ClearTalents()
  local player = gRegion:GetPlayerAvatar()
  local inventory = player:ScriptInventoryControl()
  inventory:RespecTalents()
end
