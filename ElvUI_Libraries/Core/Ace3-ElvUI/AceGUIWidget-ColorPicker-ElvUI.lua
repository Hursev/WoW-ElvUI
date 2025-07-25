--[[-----------------------------------------------------------------------------
ColorPicker Widget
-------------------------------------------------------------------------------]]
local Type, Version = "ColorPicker-ElvUI", 31
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

local isRetail = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE

local pairs = pairs
local CreateFrame, UIParent = CreateFrame, UIParent
local OpacitySliderFrame = OpacitySliderFrame
local ColorPickerFrame = ColorPickerFrame

-- GLOBALS: ColorPPDefault

--[[-----------------------------------------------------------------------------
Support functions
-------------------------------------------------------------------------------]]
local function ColorCallback(self, r, g, b, a, isAlpha)
	-- this will block an infinite loop from `E.GrabColorPickerValues`
	-- which is caused when we set values into the color picker again on `OnValueChanged`
	if ColorPickerFrame.noColorCallback then return end

	-- no change, skip update
	if r == self.r and g == self.g and b == self.b and a == self.a then
		return
	end

	-- no alpha option
	if not self.HasAlpha then
		a = 1
	end

	self:SetColor(r, g, b, a)

	if ColorPickerFrame:IsVisible() then
		--colorpicker is still open
		self:Fire("OnValueChanged", r, g, b, a)
	else
		--colorpicker is closed, color callback is first, ignore it,
		--alpha callback is the final call after it closes so confirm now
		if isAlpha then
			self:Fire("OnValueConfirmed", r, g, b, a)
		end
	end
end

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]
local function Control_OnEnter(frame)
	frame.obj:Fire("OnEnter")
end

local function Control_OnLeave(frame)
	frame.obj:Fire("OnLeave")
end

local function ColorSwatch_OnClick(frame)
	ColorPickerFrame:Hide()
	local self = frame.obj
	if not self.disabled then
		ColorPickerFrame:SetFrameStrata("FULLSCREEN_DIALOG")
		ColorPickerFrame:SetFrameLevel(frame:GetFrameLevel() + 10)
		ColorPickerFrame:SetClampedToScreen(true)

		ColorPickerFrame.swatchFunc = function()
			local r, g, b = ColorPickerFrame:GetColorRGB()
			local alpha

			if isRetail then
				alpha = ColorPickerFrame:GetColorAlpha()
			else
				alpha = 1 - OpacitySliderFrame:GetValue()
			end

			ColorCallback(self, r, g, b, alpha)
		end

		ColorPickerFrame.hasOpacity = self.HasAlpha
		ColorPickerFrame.opacityFunc = function()
			local r, g, b = ColorPickerFrame:GetColorRGB()
			local alpha

			if isRetail then
				alpha = ColorPickerFrame:GetColorAlpha()
			else
				alpha = 1 - OpacitySliderFrame:GetValue()
			end

			ColorCallback(self, r, g, b, alpha, true)
		end

		local r, g, b, a = self.r, self.g, self.b, self.a
		if self.HasAlpha then
			ColorPickerFrame.opacity = (isRetail and (a or 0)) or (1 - (a or 0))
		end

		if ColorPickerFrame.Content and ColorPickerFrame.Content.ColorPicker then
			ColorPickerFrame.Content.ColorPicker:SetColorRGB(r, g, b)
		else
			ColorPickerFrame:SetColorRGB(r, g, b)
		end

		-- ElvUI
		if ColorPPDefault and self.dR and self.dG and self.dB then
			local alpha = 1
			if self.dA then
				alpha = (isRetail and self.dA) or (1 - self.dA)
			end

			if not ColorPPDefault.colors then
				ColorPPDefault.colors = {}
			end

			ColorPPDefault.colors.r, ColorPPDefault.colors.g, ColorPPDefault.colors.b, ColorPPDefault.colors.a = self.dR, self.dG, self.dB, alpha
		end

		ColorPickerFrame.cancelFunc = function()
			ColorPickerFrame.swatchFunc = nil
			ColorPickerFrame.opacityFunc = nil

			ColorCallback(self, r, g, b, a, true)
		end

		ColorPickerFrame:Show()
	end
	AceGUI:ClearFocus()
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
	["OnAcquire"] = function(self)
		self:SetHeight(24)
		self:SetWidth(200)
		self:SetHasAlpha(false)
		self:SetColor(0, 0, 0, 1)
		self:SetDisabled(nil)
		self:SetLabel(nil)
	end,

	-- ["OnRelease"] = nil,

	["SetLabel"] = function(self, text)
		self.text:SetText(text)
	end,

	["SetColor"] = function(self, r, g, b, a, defaultR, defaultG, defaultB, defaultA)
		self.r = r
		self.g = g
		self.b = b
		self.a = a or 1
		self.dR = defaultR or self.dR
		self.dG = defaultG or self.dG
		self.dB = defaultB or self.dB
		self.dA = defaultA or self.dA
		self.colorSwatch:SetVertexColor(r, g, b, a)
	end,

	["SetHasAlpha"] = function(self, HasAlpha)
		self.HasAlpha = HasAlpha
	end,

	["SetDisabled"] = function(self, disabled)
		self.disabled = disabled
		if self.disabled then
			self.frame:Disable()
			self.text:SetTextColor(0.5, 0.5, 0.5)
		else
			self.frame:Enable()
			self.text:SetTextColor(1, 1, 1)
		end
	end
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor()
	local frame = CreateFrame("Button", nil, UIParent)
	frame:Hide()

	frame:EnableMouse(true)
	frame:SetScript("OnEnter", Control_OnEnter)
	frame:SetScript("OnLeave", Control_OnLeave)
	frame:SetScript("OnClick", ColorSwatch_OnClick)

	local colorSwatch = frame:CreateTexture(nil, "OVERLAY")
	colorSwatch:SetWidth(19)
	colorSwatch:SetHeight(19)
	colorSwatch:SetTexture(130939) -- Interface\\ChatFrame\\ChatFrameColorSwatch
	colorSwatch:SetPoint("LEFT")

	local texture = frame:CreateTexture(nil, "BACKGROUND")
	colorSwatch.background = texture
	texture:SetWidth(16)
	texture:SetHeight(16)
	texture:SetColorTexture(1, 1, 1)
	texture:SetPoint("CENTER", colorSwatch)
	texture:Show()

	local checkers = frame:CreateTexture(nil, "BACKGROUND")
	colorSwatch.checkers = checkers
	checkers:SetWidth(14)
	checkers:SetHeight(14)
	checkers:SetTexture(188523) -- Tileset\\Generic\\Checkers
	checkers:SetTexCoord(.25, 0, 0.5, .25)
	checkers:SetDesaturated(true)
	checkers:SetVertexColor(1, 1, 1, 0.75)
	checkers:SetPoint("CENTER", colorSwatch)
	checkers:Show()

	local text = frame:CreateFontString(nil,"OVERLAY","GameFontHighlight")
	text:SetHeight(24)
	text:SetJustifyH("LEFT")
	text:SetTextColor(1, 1, 1)
	text:SetPoint("LEFT", colorSwatch, "RIGHT", 2, 0)
	text:SetPoint("RIGHT")

	--local highlight = frame:CreateTexture(nil, "HIGHLIGHT")
	--highlight:SetTexture(136810) -- Interface\\QuestFrame\\UI-QuestTitleHighlight
	--highlight:SetBlendMode("ADD")
	--highlight:SetAllPoints(frame)

	local widget = {
		colorSwatch = colorSwatch,
		text        = text,
		frame       = frame,
		type        = Type
	}
	for method, func in pairs(methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
