beforeTag = Symbol()
afterTag = Symbol()
materialSwapTag = Symbol()
lightType = Type()
setupOnly = false
preloadMaterialArray = {
  Resource()
}
function DinerSwitch()
  if setupOnly then
    beforeTag, afterTag = afterTag, beforeTag
  end
  local beforeTagArray = gRegion:FindTagged(beforeTag)
  for i = 1, #beforeTagArray do
    if beforeTagArray[i]:IsA(lightType) then
      beforeTagArray[i]:TurnOff()
    else
      beforeTagArray[i]:SetVisibility(false)
    end
  end
  local afterTagArray = gRegion:FindTagged(afterTag)
  for i = 1, #afterTagArray do
    if afterTagArray[i]:IsA(lightType) then
      afterTagArray[i]:TurnOn()
    else
      afterTagArray[i]:SetVisibility(true)
    end
  end
  local materialSwapTagArray = gRegion:FindTagged(materialSwapTag)
  for i = 1, #materialSwapTagArray do
    materialSwapTagArray[i]:SetMaterialSwap(not setupOnly)
  end
end
