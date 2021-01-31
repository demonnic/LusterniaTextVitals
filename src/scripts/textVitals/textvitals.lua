-- do not change the gauge names, everything else is configurable
local config = {
  font = "Bitstream Vera Sans Mono",
  fontSize = 14,
  minimum_length_for_percent = 15,
  singleColumn = true,
  health = {
    name = "health",
    fillCharacter = "=",
    emptyCharacter = "-",
    fillColor = "DeepPink",
    overflowColor = "OrangeRed",
    emptyColor = "grey",
    percentColor = "DeepPink",
    percentSymbolColor = "DeepPink",
  },
  mana = {
    name = "mana",
    fillCharacter = "#",
    emptyCharacter = "-",
    fillColor = "RoyalBlue",
    overflowColor = "cyan",
    emptyColor = "grey",
    percentColor = "RoyalBlue",
    percentSymbolColor = "RoyalBlue",
  },
  ego = {
    name = "ego",
    fillCharacter = "%",
    emptyCharacter = "-",
    fillColor = "green",
    overflowColor = "ForestGreen",
    emptyColor = "grey",
    percentColor = "green",
    percentSymbolColor = "green",
  },
  power = {
    name = "power",
    fillCharacter = "+",
    emptyCharacter = "-",
    fillColor = "purple",
    overflowColor = "violet",
    emptyColor = "grey",
    percentColor = "purple",
    percentSymbolColor = "purple",
  }
}
local emoji = {
  health = "💗",
  mana = "🔮",
  ego = "💬",
  power = "⚡",
}
local filename = getMudletHomeDir() .. "/demonVitalGauges.lua"
-- Stuff below here I wouldn't recommend messing with
-- unless you're confident you know what you're doing
-- or don't mind breaking it =)
local tg = require("TextVitals.TextGauges")
local health_gauge = tg:new(config.health)
local mana_gauge = tg:new(config.mana)
local ego_gauge = tg:new(config.ego)
local power_gauge = tg:new(config.power)
local gauges = {
  health_gauge,
  mana_gauge,
  ego_gauge,
  power_gauge
}

demonVitalGauges = demonVitalGauges or {}
demonVitalGauges.config = config
demonVitalGauges.gauges = gauges

demonVitalGauges.container = demonVitalGauges.container or Adjustable.Container:new({name = "dvgContainer", x = 0, y = -136, width = 400, height = 136, titleText = "Vitals"})

demonVitalGauges.console = demonVitalGauges.console or Geyser.MiniConsole:new({name = "dvgConsole", x=0, y=0, width = "100%", height = "99%", color = "black"}, demonVitalGauges.container)
demonVitalGauges.console:setFont(config.font)
demonVitalGauges.console:setFontSize(config.fontSize)
function demonVitalGauges.console:reposition()
  Geyser.MiniConsole.reposition(self)
  demonVitalGauges.set_gauge_sizes()
end

local function tobool(item)
  if item == "true" then
    return true
  elseif item == "false" then
    return false
  end
  return nil
end

local function get_character_width(console)
  local width = console:get_width()
  local font_width = console:calcFontSize()
  local char_width = math.floor(width / font_width)
  return char_width
end

function demonVitalGauges.gcw()
  return get_character_width(demonVitalGauges.console)
end

function demonVitalGauges.echo(msg)
  local header = "<green>(<purple>DemonVitalGauges<green>)<reset> "
  cecho(header .. msg .. "\n")
end

function demonVitalGauges.set_gauge_sizes()
  local char_width = get_character_width(demonVitalGauges.console)
  local padding = 5
  if config.singleColumn then padding = 2 end
  char_width = char_width - padding
  local gauge_width = char_width
  if not demonVitalGauges.config.singleColumn then
    gauge_width = math.floor(gauge_width / 2)
  end
  local showPercent = true
  if gauge_width < config.minimum_length_for_percent then
    showPercent = false
  end
  for _,gauge in ipairs(gauges) do
    gauge:setWidth(gauge_width)
    if showPercent then
      gauge:enableShowPercent()
      gauge:enableShowPercentSymbol()
    else
      gauge:disableShowPercent()
      gauge:disableShowPercentSymbol()
    end
  end
  demonVitalGauges.update_gauges()
end

function demonVitalGauges.save()
  table.save(filename, demonVitalGauges.config)
end

function demonVitalGauges.load()
  local cfg = {}
  local conf = demonVitalGauges.config
  if io.exists(filename) then
    table.load(filename, cfg)
  else
    return false
  end
  conf.font = cfg.font or conf.font
  conf.fontSize = cfg.fontSize or conf.fontSize
  conf.minimum_length_for_percent = cfg.minimum_length_for_percent or conf.minimum_length_for_percent
  if cfg.singleColumn ~= nil then
    conf.singleColumn = cfg.singleColumn
  end
  for _,gtype in ipairs({"health", "mana", "ego", "power"}) do
    for key,value in pairs(cfg[gtype]) do
      conf[gtype][key] = value
    end
  end
  demonVitalGauges.reconfigure()
  return true
end

function demonVitalGauges.reconfigure()
  for _,gauge in ipairs(gauges) do
    local name = gauge.name
    local cfg = demonVitalGauges.config[name]
    for key,value in pairs(cfg) do
      if key ~= "name" then
        gauge[key] = value
      end
    end
  end
  demonVitalGauges.console:setFont(config.font)
  demonVitalGauges.console:setFontSize(config.fontSize)
  demonVitalGauges.set_gauge_sizes()
end

function demonVitalGauges.set(configString)
  local fields = configString:split(" ")
  local gaugeNames = {"health", "mana", "ego", "power"}
  local cfg = demonVitalGauges.config
  if #fields == 2 then
    local key = fields[1]
    local value = fields[2]
    if not table.contains(gaugeNames, key) then
      if cfg[key] ~= nil then
        if tonumber(value) then value = tonumber(value) end
        if tobool(value) ~= nil then value = tobool(value) end
        cfg[key] = value
      end
    end
    demonVitalGauges.reconfigure()
    return
  elseif #fields == 3 then
    local gauge = fields[1]
    local key = fields[2]
    local value = fields[3]
    if table.contains(gaugeNames,gauge) then
      if cfg[gauge][key] ~= nil then
        if tonumber(value) then value = tonumber(value) end
        if tobool(value) ~= nil then value = tobool(value) end
        cfg[gauge][key] = value
      end
    elseif #fields > 3 and fields[1] == "font" then
      local key = table.remove(fields, 1)
      local value = table.concat(fields, " ")
      cfg[key] = value
    end
    demonVitalGauges.reconfigure()
    return
  end
  demonVitalGauges.echo("You tried to set a config value incorrectly. you tried 'dvg config " .. configString .. "' Valid options are things like 'dvg config health fillCharacter $' or 'dvg config fontSize 10'")
end

function demonVitalGauges.update_gauges()
  if not (gmcp and gmcp.Char and gmcp.Char.Vitals) then return end
  local console = demonVitalGauges.console
  local hp = tonumber(gmcp.Char.Vitals.hp)
  local maxhp = tonumber(gmcp.Char.Vitals.maxhp)
  local mp = tonumber(gmcp.Char.Vitals.mp)
  local maxmp = tonumber(gmcp.Char.Vitals.maxmp)
  local ego = tonumber(gmcp.Char.Vitals.ego)
  local maxego = tonumber(gmcp.Char.Vitals.maxego)
  local pow = tonumber(gmcp.Char.Vitals.pow)
  local maxpow = tonumber(gmcp.Char.Vitals.maxpow)
  hgText = health_gauge:setValue(hp, maxhp)
  mgText = mana_gauge:setValue(mp, maxmp)
  egText = ego_gauge:setValue(ego, maxego)
  pgText = power_gauge:setValue(pow, maxpow)
  console:clear()
  console:cecho("\n")
  local spacer = " "
  if demonVitalGauges.config.singleColumn then
    spacer = "\n"
  end
  console:cecho(emoji.health .. hgText .. spacer .. emoji.mana .. mgText .. "\n")
  console:cecho(emoji.ego .. egText .. spacer .. emoji.power .. pgText)
end
if demonVitalGauges.handlerID then
  killAnonymousEventHandler(demonVitalGauges.handlerID)
end
demonVitalGauges.handlerID = registerAnonymousEventHandler("gmcp.Char.Vitals", demonVitalGauges.update_gauges)
if not demonVitalGauges.load() then
  demonVitalGauges.reconfigure()
end
