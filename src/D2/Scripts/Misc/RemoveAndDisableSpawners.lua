spawnerArray = {
  Instance()
}
function Start()
  for i = 1, #spawnerArray do
    spawnerArray[i]:FirePort("Disable")
    spawnerArray[i]:FirePort("RemoveAgents")
  end
end
