pieces = {
  Instance()
}
dynamicObject = Instance()
function collapse()
  for i = 1, #pieces do
    pieces[i]:FirePort("Destroy")
  end
end
function collapseFromGrab(entity)
  for i = 1, #pieces do
    if pieces[i]:GetFullName() ~= dynamicObject:GetFullName() then
      pieces[i]:FirePort("Destroy")
    end
  end
end
