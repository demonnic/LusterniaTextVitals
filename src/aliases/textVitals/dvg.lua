if not matches[2] then
  display(demonVitalGauges.config)
else
  local command = matches[2]
  local params = matches[3]
  if command == "save" then
    demonVitalGauges.save()
  elseif command == "load" then
    demonVitalGauges.load()
  elseif command == "cfg" or command == "config" then
    demonVitalGauges.set(params)
  end
end
