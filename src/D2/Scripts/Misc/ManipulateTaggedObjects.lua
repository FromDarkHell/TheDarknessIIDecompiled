tag = Symbol()
visible = true
function Start()
  local entArray = gRegion:FindTagged(tag)
  for i = 1, #entArray do
    entArray[i]:SetVisibility(visible)
  end
end
