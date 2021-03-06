OriginalValue = 0
NewValue = 1
TimeLength = 1
function DarkArmourFade(deco)
  local avatar = gRegion:GetPlayerAvatar()
  local InventoryController = avatar:ScriptInventoryControl()
  local Talent = InventoryController:GetTalentByResName("DarkLife")
  if not IsNull(Talent) then
    local talentLevelPurchased = InventoryController:GetTalentLevel(Talent)
    if 0 < talentLevelPurchased then
      local t = 0
      local val
      while t < TimeLength do
        val = Lerp(OriginalValue, NewValue, t / TimeLength)
        deco:SetDissolve(val)
        t = t + DeltaTime()
        Sleep(0)
      end
      deco:SetDissolve(NewValue)
    end
  end
end
