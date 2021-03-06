relicDecorations = {
  Instance()
}
pickupGlowMaterial = Resource()
asianBellGlowMaterial = Resource()
christsBloodGlowMaterial = Resource()
fistReliquaryGlowMaterial = Resource()
enableRelics = true
local SetOverrideMaterial = function(entity, material)
  for i = 0, 3 do
    entity:SetOverrideMaterial(i, material)
  end
end
function CheckRelicsViaTag()
  Sleep(1)
  local relicTag = Symbol("Relic")
  local unusedRelicTag = Symbol("UnusedRelic")
  local playerAvatar = gRegion:GetPlayerAvatar()
  local relicList = gRegion:FindTagged(relicTag)
  local unusedRelicList = gRegion:FindTagged(unusedRelicTag)
  local pickupAction
  for i = 1, #unusedRelicList do
    unusedRelicList[i]:SetVisibility(false)
    pickupAction = unusedRelicList[i]:GetPickUpAction()
    pickupAction:FirePort("Disable")
  end
  if IsNull(playerAvatar) == false then
    local d2inventoryController = playerAvatar:ScriptInventoryControl()
    if IsNull(d2inventoryController) == false then
      for i = 1, #relicList do
        if not IsNull(relicList[i]) then
          local relicId = relicList[i]:GetCollectibleId()
          local relicFound = d2inventoryController:HasFoundRelic(relicId)
          if relicFound then
            relicList[i]:SetVisibility(true)
            SetOverrideMaterial(relicList[i], nil)
          elseif IsNull(asianBellGlowMaterial) == false and relicId == 1 then
            SetOverrideMaterial(relicList[i], asianBellGlowMaterial)
          elseif IsNull(christsBloodGlowMaterial) == false and relicId == 11 then
            SetOverrideMaterial(relicList[i], christsBloodGlowMaterial)
          elseif IsNull(fistReliquaryGlowMaterial) == false and relicId == 19 then
            SetOverrideMaterial(relicList[i], fistReliquaryGlowMaterial)
          elseif IsNull(pickupGlowMaterial) == false then
            SetOverrideMaterial(relicList[i], pickupGlowMaterial)
          else
            relicList[i]:SetVisibility(false)
          end
        end
      end
    end
  end
end
function SetEnableRelics()
  local relicTag = Symbol("Relic")
  local playerAvatar = gRegion:GetPlayerAvatar()
  local relicList = gRegion:FindTagged(relicTag)
  local pickupAction
  if IsNull(playerAvatar) == false then
    local d2inventoryController = playerAvatar:ScriptInventoryControl()
    if IsNull(d2inventoryController) == false then
      for i = 1, #relicList do
        if not IsNull(relicList[i]) then
          local relicId = relicList[i]:GetCollectibleId()
          local relicFound = d2inventoryController:HasFoundRelic(relicId)
          if relicFound then
            if enableRelics then
              pickupAction = relicList[i]:GetPickUpAction()
              pickupAction:FirePort("Enable")
            else
              pickupAction = relicList[i]:GetPickUpAction()
              pickupAction:FirePort("Disable")
            end
          end
        end
      end
    end
  end
end
local Start = function()
  Sleep(1)
  local playerAvatar = gRegion:GetPlayerAvatar()
  if IsNull(playerAvatar) == false then
    local d2inventoryController = playerAvatar:ScriptInventoryControl()
    if IsNull(d2inventoryController) == false then
      for i = 1, #relicDecorations do
        if not IsNull(relicDecorations[i]) then
          local relicId = relicDecorations[i]:GetCollectibleId()
          local relicFound = d2inventoryController:HasFoundRelic(relicId)
          if relicFound then
            relicDecorations[i]:SetVisibility(true)
          elseif IsNull(pickupGlowMaterial) == false then
            relicDecorations[i]:SetOverrideMaterial(0, pickupGlowMaterial)
          else
            relicDecorations[i]:SetVisibility(false)
          end
        end
      end
    end
  end
end
