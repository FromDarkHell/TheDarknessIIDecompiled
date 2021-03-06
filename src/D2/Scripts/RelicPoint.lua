relicLight = Instance()
candleLight = Instance()
relicGlyph = Instance()
relicMist = Instance()
candleFlameArray = {
  Instance()
}
candleFlareArray = {
  Instance()
}
candleFlameDeathFX = Type()
relicPickup = Type()
relicPickupFxSpawn = Instance()
function Start()
  if not IsNull(relicPickup) then
    local pickup = gRegion:FindNearest(relicPickup, relicGlyph:GetPosition(), 5)
    local collectibleId
    if IsNull(pickup) then
      return
    else
      collectibleId = pickup:GetCollectibleId()
    end
    local playerAvatar
    while IsNull(playerAvatar) do
      Sleep(0.3)
      playerAvatar = gRegion:GetLocalPlayer()
    end
    local inventoryController = playerAvatar:ScriptInventoryControl()
    if not inventoryController:HasFoundRelic(collectibleId) then
      return
    end
  end
  local t = 0
  local relicLightBrightness = relicLight:GetBrightness()
  local candleLightBrightness = candleLight:GetBrightness()
  if IsNull(relicPickupFxSpawn) == false then
    relicPickupFxSpawn:FirePort("Enable")
  end
  for i = 1, #candleFlameArray do
    if not IsNull(candleFlameDeathFX) then
      local tempPos = candleFlameArray[i]:GetPosition()
      gRegion:CreateEntity(candleFlameDeathFX, tempPos, Rotation())
    end
    candleFlameArray[i]:FirePort("Destroy")
  end
  while t < 1 do
    local vr = Lerp(relicLightBrightness, 0, t)
    local vc = Lerp(candleLightBrightness, 0, t)
    relicLight:SetBrightness(vr)
    candleLight:SetBrightness(vc)
    t = t + DeltaTime()
    Sleep(0)
  end
  relicLight:FirePort("TurnOff")
  candleLight:FirePort("TurnOff")
  for i = 1, #candleFlareArray do
    candleFlareArray[i]:FirePort("Disable")
  end
  if IsNull(relicGlyph) == false then
    relicGlyph:SetVisibility(false)
    relicGlyph:FirePort("Hide")
  end
  if IsNull(relicMist) == false then
    relicMist:FirePort("Disable")
  end
end
function CheckExtinguishOnLevelStart(relicPickup)
  local playerAvatar, relicItem
  while IsNull(playerAvatar) or IsNull(relicItem) do
    Sleep(0.3)
    playerAvatar = gRegion:GetPlayerAvatar()
    relicItem = relicPickup:GetPickUpItem()
  end
  relicPickup:OnItemTaken()
end
