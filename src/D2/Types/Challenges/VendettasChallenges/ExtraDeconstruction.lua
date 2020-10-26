acceptedTypes = {
  WeakResource()
}
acceptedTags = {
  Symbol()
}
function Initialize()
end
function MatchDecorationDestructionEvent(player, entity)
  for i = 1, #acceptedTypes do
    if entity:IsA(acceptedTypes[i]) then
      return true
    end
  end
  for i = 1, #acceptedTags do
    if entity:GetTag() == acceptedTags[i] then
      return true
    end
  end
  return false
end
