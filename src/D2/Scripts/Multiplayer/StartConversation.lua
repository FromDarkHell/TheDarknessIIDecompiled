conversation = Instance()
delay = 0
conversationGroup = {
  Instance()
}
function StartConversation()
  if delay > 0 then
    Sleep(delay)
  end
  if not IsNull(conversation) then
    conversation:FirePort("Enable")
  else
    print("StartConversation.lua: conversation instance was nil! This conversation will never, ever start. Ever.")
  end
end
function StartMatchingConversation(avatar)
  if not IsNull(conversationGroup) and #conversationGroup > 0 then
    for i = 1, #conversationGroup do
      if not IsNull(conversationGroup[i]) and not conversationGroup[i]:StartIfPlayerTypeMatches(avatar) then
        conversationGroup[i]:Disable()
      end
    end
  end
end
