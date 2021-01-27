local config = {
  font = "Bitstream Vera Sans Mono",
  fontSize = 14,
  minimum_length_for_percent = 15,
  singleColumn = true,
  health = {
    fillCharacter = "=",
    emptyCharacter = "-",
    fillColor = "DeepPink",
    emptyColor = "grey",
    percentColor = "DeepPink",
    percentSymbolColor = "DeepPink",
  },
  mana = {
    fillCharacter = "#",
    emptyCharacter = "-",
    fillColor = "RoyalBlue",
    emptyColor = "grey",
    percentColor = "RoyalBlue",
    percentSymbolColor = "RoyalBlue",
  },
  ego = {
    fillCharacter = "%",
    emptyCharacter = "-",
    fillColor = "green",
    emptyColor = "grey",
    percentColor = "green",
    percentSymbolColor = "green",
  },
  power = {
    fillCharacter = "+",
    emptyCharacter = "-",
    fillColor = "purple",
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

demonVitalGauges.container = demonVitalGauges.container or Adjustable.Container:new({name = "dvgContainer", x = 0, y = -136, width = 400, height = 136, titleText = "Vitals"})

demonVitalGauges.console = demonVitalGauges.console or Geyser.MiniConsole:new({name = "dvgConsole", x=0, y=0, width = "100%", height = "99%", color = "black"}, demonVitalGauges.container)
demonVitalGauges.console:setFont(config.font)
demonVitalGauges.console:setFontSize(config.fontSize)
function demonVitalGauges.console:reposition()
  Geyser.MiniConsole.reposition(self)
  demonVitalGauges.set_gauge_sizes()
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
function demonVitalGauges.set_gauge_sizes()
  local char_width = get_character_width(demonVitalGauges.console)
  local padding = 5
  if config.singleColumn then padding = 2 end
  char_width = char_width - padding
  local gauge_width = char_width
  if not config.singleColumn then
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

function demonVitalGauges.update_gauges()
  --demonVitalGauges.set_gauge_sizes()
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
  if config.singleColumn then
    spacer = "\n"
  end
  console:cecho(emoji.health .. hgText .. spacer .. emoji.mana .. mgText .. "\n")
  console:cecho(emoji.ego .. egText .. spacer .. emoji.power .. pgText)
end
if demonVitalGauges.handlerID then
  killAnonymousEventHandler(demonVitalGauges.handlerID)
end
demonVitalGauges.handlerID = registerAnonymousEventHandler("gmcp.Char.Vitals", demonVitalGauges.update_gauges)
demonVitalGauges.set_gauge_sizes()
