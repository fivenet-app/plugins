-- GTA V / FiveM SetBlipColour IDs mapped to approximate RGB hex colors.
local blipColorHex = {
	[0] = "#fefefe", -- White
	[1] = "#e03232", -- Red
	[2] = "#71cb71", -- Green
	[3] = "#5db6e5", -- Blue
	[4] = "#fefefe", -- White
	[5] = "#eec64e", -- Yellow
	[6] = "#c25050", -- Light red
	[7] = "#9c6eaf", -- Violet
	[8] = "#fe7ac3", -- Pink
	[9] = "#f59d79", -- Light orange
	[10] = "#b18f83", -- Light brown
	[11] = "#8dcea7", -- Light green
	[12] = "#70a8ae", -- Light blue
	[13] = "#d3d1e7", -- Light purple
	[14] = "#8f7e98", -- Dark purple
	[15] = "#6ac4bf", -- Cyan
	[16] = "#d5c398", -- Light yellow
	[17] = "#ea8e50", -- Orange
	[18] = "#97cae9", -- Light blue
	[19] = "#b26287", -- Dark pink
	[20] = "#8f8d79", -- Dark yellow
	[21] = "#a6755e", -- Dark orange
	[22] = "#afa8a8", -- Light gray
	[23] = "#e78d9a", -- Light pink
	[24] = "#bbd65b", -- Lemon green
	[25] = "#0c7b56", -- Forest green
	[26] = "#7ac3fe", -- Electric blue
	[27] = "#ab3ce6", -- Bright purple
	[28] = "#cda80c", -- Dark yellow
	[29] = "#4561ab", -- Dark blue
	[30] = "#29a5b8", -- Dark cyan
	[31] = "#b89b7b", -- Light brown
	[32] = "#c8e0fe", -- Light blue
	[33] = "#f0f096", -- Light yellow
	[34] = "#ed8ca1", -- Light pink
	[35] = "#f98a8a", -- Light red
	[36] = "#fbeea5", -- Beige
	[37] = "#fefefe", -- White
	[38] = "#2c6db8", -- Blue
	[39] = "#9a9a9a", -- Light gray
	[40] = "#4c4c4c", -- Dark gray
	[41] = "#f29d9d", -- Pink-red
	[42] = "#6cb7d6", -- Blue
	[43] = "#afedae", -- Light green
	[44] = "#ffa75f", -- Light orange
	[45] = "#f1f1f1", -- White
	[46] = "#ecf029", -- Gold
	[47] = "#ff9a18", -- Orange
	[48] = "#f644a5", -- Brilliant rose
	[49] = "#e03a3a", -- Red
	[50] = "#8a6de3", -- Medium purple
	[51] = "#ff8b5c", -- Salmon
	[52] = "#416c41", -- Dark green
	[53] = "#b3ddf3", -- Blizzard blue
	[54] = "#3a6479", -- Oracle blue
	[55] = "#a0a0a0", -- Silver
	[56] = "#847232", -- Brown
	[57] = "#65b9e7", -- Blue
	[58] = "#4b4175", -- East Bay
	[59] = "#e13b3b", -- Red
	[60] = "#f0cb58", -- Yellow-orange
	[61] = "#cd3f98", -- Mulberry pink
	[62] = "#cfcfcf", -- Alto gray
	[63] = "#276a9f", -- Jelly Bean blue
	[64] = "#d87b1b", -- Dark orange
	[65] = "#8e8393", -- Mamba
	[66] = "#f0cb57", -- Yellow-orange
	[67] = "#65b9e7", -- Blue
	[68] = "#65b9e7", -- Blue
	[69] = "#79cd79", -- Green
	[70] = "#efca57", -- Yellow-orange
	[71] = "#efca57", -- Yellow-orange
	[72] = "#3d3d3d", -- Transparent black, RGB approximation
	[73] = "#efca57", -- Yellow-orange
	[74] = "#65b9e7", -- Blue
	[75] = "#e03232", -- Red
	[76] = "#782323", -- Deep red
	[77] = "#65b9e7", -- Blue
	[78] = "#3a6479", -- Oracle blue
	[79] = "#e03232", -- Transparent red, RGB approximation
	[80] = "#65b9e7", -- Transparent blue, RGB approximation
	[81] = "#f2a40c", -- Orange
	[82] = "#a4ccaa", -- Light green
	[83] = "#a854f2", -- Purple
	[84] = "#65b9e7", -- Blue
	[85] = "#3d3d3d", -- Transparent black, RGB approximation
}

local DEFAULT_BLIP_COLOR_HEX = "#0099ff"

function GetHexColorFromBlipColor(color --[[number|string|nil]])
	color = tonumber(color)

	if color == nil then
		return DEFAULT_BLIP_COLOR_HEX
	end

	return blipColorHex[color] or DEFAULT_BLIP_COLOR_HEX
end
exports('GetHexColorFromBlipColor', GetHexColorFromBlipColor)
