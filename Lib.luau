local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService") -- JSON encode/decode for saved settings
local SoundService = game:GetService("SoundService") -- parent of the music Sound

local LocalPlayer = Players.LocalPlayer

local IconsV2
pcall(function()
	IconsV2 = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Footagesus/Icons/main/Main-v2.lua"))()
	IconsV2.SetIconsType("lucide")
end)

local Font = Enum.Font
local TextAlign = Enum.TextXAlignment
local Auto = Enum.AutomaticSize
local Direction = Enum.FillDirection
local HAlign = Enum.HorizontalAlignment
local VAlign = Enum.VerticalAlignment
local WHITE = Color3.new(1, 1, 1)
local INK = Color3.fromRGB(24, 18, 48)

local DashFlow = {}
DashFlow.__index = DashFlow

local Tab = {}
Tab.__index = Tab

local Section = {}
Section.__index = Section

local Theme = {
	Background = Color3.fromRGB(9, 9, 14),
	Sidebar = Color3.fromRGB(14, 14, 20),
	Card = Color3.fromRGB(17, 17, 25),
	Element = Color3.fromRGB(24, 24, 34),
	ElementHover = Color3.fromRGB(32, 32, 46),
	Active = Color3.fromRGB(40, 32, 70),
	Track = Color3.fromRGB(36, 36, 52),
	Ghost = Color3.fromRGB(58, 58, 82),
	Stroke = Color3.fromRGB(35, 35, 50),
	Text = Color3.fromRGB(246, 246, 252),
	SubText = Color3.fromRGB(145, 145, 170),
	Accent = Color3.fromRGB(178, 150, 255),
	Purple = Color3.fromRGB(139, 92, 246),
	Pink = Color3.fromRGB(255, 110, 199),
	Orange = Color3.fromRGB(251, 146, 60),
	Red = Color3.fromRGB(244, 63, 94),
	Success = Color3.fromRGB(74, 222, 128),
	Warning = Color3.fromRGB(250, 204, 21),
	Danger = Color3.fromRGB(248, 113, 113),
}

DashFlow.Theme = Theme

DashFlow.Icons = {
	Logo = "sparkles",
	Action = "layout-dashboard",
	Spark = "sparkles",
	Home = "house",
	Settings = "settings",
	Player = "user",
	Players = "users",
	Server = "server",
	Chart = "activity",
	Combat = "swords",
	Visuals = "eye",
	Misc = "menu",
	Info = "info",
	Bolt = "zap",
	Star = "star",
	Latency = "wifi",
}

local function create(className, properties, children)
	local instance = Instance.new(className)
	local parent
	for key, value in pairs(properties or {}) do
		if key == "Parent" then
			parent = value
		else
			instance[key] = value
		end
	end
	for _, child in ipairs(children or {}) do
		child.Parent = instance
	end
	instance.Parent = parent
	return instance
end

local function tween(instance, properties, duration, style, direction)
	local info = TweenInfo.new(duration or 0.2, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out)
	local playing = TweenService:Create(instance, info, properties)
	playing:Play()
	return playing
end

local function apply(instance, properties, animate, duration, style, direction)
	if animate then
		return tween(instance, properties, duration, style, direction)
	end
	for property, value in pairs(properties) do
		instance[property] = value
	end
	return nil
end

local function fire(callback, ...)
	if type(callback) == "function" then
		task.spawn(callback, ...)
	end
end

local function corner(radius)
	return create("UICorner", { CornerRadius = UDim.new(0, radius) })
end

local function stroke(color, thickness, transparency)
	return create("UIStroke", {
		Color = color,
		Thickness = thickness or 1,
		Transparency = transparency or 0,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
	})
end

local function padding(top, bottom, left, right)
	bottom = bottom or top
	left = left or top
	right = right or left
	return create("UIPadding", {
		PaddingTop = UDim.new(0, top),
		PaddingBottom = UDim.new(0, bottom),
		PaddingLeft = UDim.new(0, left),
		PaddingRight = UDim.new(0, right),
	})
end

local function listLayout(gap, direction, horizontal, vertical)
	return create("UIListLayout", {
		Padding = UDim.new(0, gap or 0),
		FillDirection = direction or Direction.Vertical,
		SortOrder = Enum.SortOrder.LayoutOrder,
		HorizontalAlignment = horizontal or HAlign.Left,
		VerticalAlignment = vertical or VAlign.Top,
	})
end

local function gradient(colorA, colorB, rotation)
	return create("UIGradient", {
		Color = ColorSequence.new(colorA, colorB),
		Rotation = rotation or 0,
	})
end

local function label(properties)
	local base = {
		BackgroundTransparency = 1,
		Font = Font.GothamMedium,
		TextColor3 = Theme.Text,
		TextSize = 13,
		TextXAlignment = TextAlign.Left,
		Text = "",
	}
	for key, value in pairs(properties) do
		base[key] = value
	end
	return create("TextLabel", base)
end

local GlyphFallback = {
	["sparkles"] = "◈",
	["layout-dashboard"] = "◈",
	["house"] = "⌂",
	["settings"] = "⚙",
	["user"] = "☻",
	["users"] = "☺",
	["server"] = "☁",
	["activity"] = "▥",
	["swords"] = "⚔",
	["eye"] = "◉",
	["menu"] = "☰",
	["info"] = "ⓘ",
	["zap"] = "⚡",
	["star"] = "★",
	["wifi"] = "⇅",
	["chevron-right"] = "›",
	["chevron-down"] = "▾",
	["music"] = "♪",
	["play"] = "▶",
	["pause"] = "‖",
	["skip-back"] = "«",
	["skip-forward"] = "»",
	["palette"] = "◐",
	["bell"] = "◔",
	["save"] = "▣",
}

local function resolveImage(name)
	if not IconsV2 or type(name) ~= "string" then
		return nil
	end
	local ok, result = pcall(function()
		return IconsV2.GetIcon(name)
	end)
	if ok and result then
		return result
	end
	return nil
end

local function makeIcon(parent, icon, size, color)
	if type(icon) == "number" then
		icon = "rbxassetid://" .. icon
	end

	local image = icon
	if type(icon) == "string" and icon:sub(1, 6) ~= "rbxass" then
		image = resolveImage(icon)
	end

	if type(image) == "table" or (type(image) == "string" and image ~= "") then
		local properties = {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.5, 0.5),
			Size = UDim2.fromOffset(size, size),
			BackgroundTransparency = 1,
			ImageColor3 = color,
			Parent = parent,
		}
		if type(image) == "table" then
			properties.Image = image.Image or image[1] or ""
			properties.ImageRectSize = image.ImageRectSize or Vector2.new()
			properties.ImageRectOffset = image.ImageRectPosition or image.ImageRectOffset or Vector2.new()
		else
			properties.Image = image
		end
		return create("ImageLabel", properties)
	end

	local text = GlyphFallback[icon]
	if not text then
		text = (type(icon) == "string" and (utf8.len(icon) or 99) <= 2) and icon or "•"
	end

	return create("TextLabel", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Font = Font.GothamBold,
		Text = text,
		TextColor3 = color,
		TextSize = size,
		Parent = parent,
	})
end

local function badge(parent, icon, colorA, colorB, size, position)
	local frame = create("Frame", {
		Size = UDim2.fromOffset(size, size),
		Position = position or UDim2.new(),
		BackgroundColor3 = WHITE,
		BorderSizePixel = 0,
		Parent = parent,
	}, { corner(math.floor(size * 0.32)), gradient(colorA, colorB, 45) })
	makeIcon(frame, icon, math.floor(size * 0.52), WHITE)
	return frame
end

local function resolveParent(custom)
	if custom then
		return custom
	end
	local probe = Instance.new("ScreenGui")
	local ok = pcall(function()
		probe.Parent = CoreGui
	end)
	local inCore = ok and probe.Parent == CoreGui
	probe:Destroy()
	if inCore then
		return CoreGui
	end
	return LocalPlayer:WaitForChild("PlayerGui")
end

local function loadAvatar(imageLabel)
	task.spawn(function()
		local ok, content = pcall(function()
			return Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
		end)
		if ok and imageLabel.Parent then
			imageLabel.Image = content
		end
	end)
end

local function formatTime(seconds)
	seconds = math.floor(seconds)
	return string.format("%02d:%02d:%02d", math.floor(seconds / 3600), math.floor((seconds % 3600) / 60), seconds % 60)
end

local function getPing()
	local ok, value = pcall(function()
		return Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
	end)
	if ok and type(value) == "number" then
		return value
	end
	local okPlayer, seconds = pcall(function()
		return LocalPlayer:GetNetworkPing() * 1000
	end)
	if okPlayer and type(seconds) == "number" then
		return seconds
	end
	return 0
end

-- ============================================================================
-- THEMES
-- A palette only contains the colors that change between themes. `Purple` is the
-- primary accent and `Pink` is the secondary accent (the key names are kept for
-- backwards compatibility). Text, SubText and the status colors never change.
-- Every color inside one palette must be unique, because live recoloring finds
-- the elements to change by matching their current color against the old palette.
-- ============================================================================
local THEME_KEYS = {
	"Background", "Sidebar", "Card", "Element", "ElementHover", "Active",
	"Track", "Ghost", "Stroke", "Accent", "Purple", "Pink",
}

local Themes = {} -- name -> full palette
local ThemeOrder = {} -- names in registration order (first one is the default)
local ActiveThemeName -- palette currently written into the shared Theme table

-- Registers (or replaces) a palette. Missing keys fall back to the default palette.
local function registerPalette(name, palette)
	local base = Themes[ThemeOrder[1]]
	local full = {}
	local seen = {}
	for _, key in ipairs(THEME_KEYS) do
		local color = palette[key] or (base and base[key]) or Theme[key]
		full[key] = color
		local hex = color:ToHex()
		if seen[hex] then
			warn(("DashFlow: theme '%s' uses the same color for %s and %s; live recoloring may be inaccurate."):format(name, seen[hex], key))
		end
		seen[hex] = key
	end
	if not Themes[name] then
		table.insert(ThemeOrder, name)
	end
	Themes[name] = full
end

-- Writes a palette into the shared Theme table so newly created elements use it.
local function setPalette(name)
	local palette = Themes[name]
	if not palette then
		return false
	end
	for _, key in ipairs(THEME_KEYS) do
		Theme[key] = palette[key]
	end
	ActiveThemeName = name
	return true
end

-- Built-in themes. The first one is a snapshot of the original Theme values.
do
	local original = {}
	for _, key in ipairs(THEME_KEYS) do
		original[key] = Theme[key]
	end
	registerPalette("Dash Purple / Pink", original)
	ActiveThemeName = "Dash Purple / Pink"
end

registerPalette("Neon Purple / Electric Blue", {
	Background = Color3.fromRGB(8, 9, 18),
	Sidebar = Color3.fromRGB(12, 14, 26),
	Card = Color3.fromRGB(15, 17, 30),
	Element = Color3.fromRGB(21, 24, 41),
	ElementHover = Color3.fromRGB(29, 33, 56),
	Active = Color3.fromRGB(30, 36, 78),
	Track = Color3.fromRGB(32, 37, 62),
	Ghost = Color3.fromRGB(54, 64, 100),
	Stroke = Color3.fromRGB(31, 36, 62),
	Accent = Color3.fromRGB(120, 190, 255),
	Purple = Color3.fromRGB(160, 80, 255),
	Pink = Color3.fromRGB(40, 160, 255),
})

registerPalette("Cyberpunk Red / Gold", {
	Background = Color3.fromRGB(14, 8, 9),
	Sidebar = Color3.fromRGB(20, 12, 13),
	Card = Color3.fromRGB(25, 15, 16),
	Element = Color3.fromRGB(35, 21, 23),
	ElementHover = Color3.fromRGB(48, 29, 32),
	Active = Color3.fromRGB(78, 30, 36),
	Track = Color3.fromRGB(54, 34, 37),
	Ghost = Color3.fromRGB(92, 56, 60),
	Stroke = Color3.fromRGB(52, 32, 35),
	Accent = Color3.fromRGB(255, 120, 110),
	Purple = Color3.fromRGB(255, 59, 70),
	Pink = Color3.fromRGB(255, 196, 45),
})

registerPalette("Matrix Green / Cyan", {
	Background = Color3.fromRGB(6, 12, 10),
	Sidebar = Color3.fromRGB(10, 18, 15),
	Card = Color3.fromRGB(12, 22, 18),
	Element = Color3.fromRGB(17, 31, 26),
	ElementHover = Color3.fromRGB(24, 44, 36),
	Active = Color3.fromRGB(22, 66, 50),
	Track = Color3.fromRGB(28, 50, 42),
	Ghost = Color3.fromRGB(46, 86, 72),
	Stroke = Color3.fromRGB(26, 46, 38),
	Accent = Color3.fromRGB(110, 255, 170),
	Purple = Color3.fromRGB(30, 220, 120),
	Pink = Color3.fromRGB(30, 210, 230),
})

local DEFAULT_THEME = ThemeOrder[1]

-- Builds a lookup of "old color hex" -> "new color" for every key that differs.
local function buildColorMap(fromPalette, toPalette)
	local map = {}
	for _, key in ipairs(THEME_KEYS) do
		local from, to = fromPalette[key], toPalette[key]
		if from and to and from ~= to then
			map[from:ToHex()] = to
		end
	end
	return map
end

-- Walks every descendant of `root` and swaps any themed color for its new value.
-- With `animate`, all colors fade through a single NumberValue instead of
-- creating one tween per property, which keeps big windows smooth.
local function recolorTree(root, map, animate)
	local propertyJobs = {} -- { instance, property, fromColor, toColor }
	local gradientJobs = {} -- { Gradient, From = keypoints, To = colors }

	local function consider(instance, property)
		local current = instance[property]
		local target = map[current:ToHex()]
		if target then
			table.insert(propertyJobs, { instance, property, current, target })
		end
	end

	for _, item in ipairs(root:GetDescendants()) do
		if item:IsA("GuiObject") then
			consider(item, "BackgroundColor3")
		end
		if item:IsA("TextLabel") or item:IsA("TextButton") or item:IsA("TextBox") then
			consider(item, "TextColor3")
		end
		if item:IsA("ImageLabel") or item:IsA("ImageButton") then
			consider(item, "ImageColor3")
		end
		if item:IsA("ScrollingFrame") then
			consider(item, "ScrollBarImageColor3")
		end
		if item:IsA("UIStroke") then
			consider(item, "Color")
		end
		if item:IsA("UIGradient") then
			local keypoints = item.Color.Keypoints
			local targets = {}
			local changed = false
			for index, keypoint in ipairs(keypoints) do
				local target = map[keypoint.Value:ToHex()]
				targets[index] = target or keypoint.Value
				changed = changed or target ~= nil
			end
			if changed then
				table.insert(gradientJobs, { Gradient = item, From = keypoints, To = targets })
			end
		end
	end

	local function render(alpha)
		for _, job in ipairs(propertyJobs) do
			job[1][job[2]] = alpha >= 1 and job[4] or job[3]:Lerp(job[4], alpha)
		end
		for _, job in ipairs(gradientJobs) do
			local keys = {}
			for index, keypoint in ipairs(job.From) do
				local value = alpha >= 1 and job.To[index] or keypoint.Value:Lerp(job.To[index], alpha)
				keys[index] = ColorSequenceKeypoint.new(keypoint.Time, value)
			end
			job.Gradient.Color = ColorSequence.new(keys)
		end
	end

	if not animate then
		render(1)
		return
	end

	local driver = Instance.new("NumberValue")
	driver.Changed:Connect(render)
	local playing = tween(driver, { Value = 1 }, 0.45, Enum.EasingStyle.Quad)
	playing.Completed:Connect(function()
		render(1)
		driver:Destroy()
	end)
end

-- ============================================================================
-- STORAGE
-- Uses the executor file API when it exists. Everywhere else (a normal Roblox
-- client has no local file access) settings live in `shared` for the session.
-- ============================================================================
local Storage = {}

function Storage.Mode()
	if type(writefile) == "function" and type(readfile) == "function" and type(isfile) == "function" then
		return "File"
	end
	return "Session"
end

-- Returns the stored text, or nil when nothing was saved yet.
function Storage.Read(folder, file)
	local path = folder .. "/" .. file
	if Storage.Mode() == "File" then
		local ok, content = pcall(function()
			if isfile(path) then
				return readfile(path)
			end
			return nil
		end)
		return ok and content or nil
	end
	local store = shared.DashFlowSessionStore
	return store and store[path] or nil
end

-- Returns true when the text was stored successfully.
function Storage.Write(folder, file, text)
	local path = folder .. "/" .. file
	if Storage.Mode() == "File" then
		return (pcall(function()
			if type(isfolder) == "function" and type(makefolder) == "function" and not isfolder(folder) then
				makefolder(folder)
			end
			writefile(path, text)
		end))
	end
	shared.DashFlowSessionStore = shared.DashFlowSessionStore or {}
	shared.DashFlowSessionStore[path] = text
	return true
end

-- ============================================================================
-- CONFIG SCHEMA
-- Every saved value is validated before use, so a damaged or hand-edited save
-- file can never put the UI into an invalid state.
-- ============================================================================
local ConfigDefaults = {
	Theme = DEFAULT_THEME,
	Volume = 0.5, -- 0..1
	Loop = true,
	Track = "", -- name of the last selected track
	Sensitivity = 1, -- visualizer loudness multiplier
	IslandVisualizer = true,
	Notifications = true,
	NotificationDuration = 4,
	ToggleKey = "RightShift",
	UserInfo = true,
	AutoSave = true,
}

local NumberRanges = {
	Volume = { 0, 1 },
	Sensitivity = { 0.5, 2.5 },
	NotificationDuration = { 1, 10 },
}

-- Returns a cleaned value, or nil when the value is not acceptable for `key`.
local function sanitize(key, value)
	local default = ConfigDefaults[key]
	if default == nil then
		return nil
	end
	if type(default) == "boolean" then
		return type(value) == "boolean" and value or nil
	end
	if type(default) == "number" then
		if type(value) ~= "number" or value ~= value then
			return nil
		end
		local range = NumberRanges[key]
		return math.clamp(value, range[1], range[2])
	end
	if type(value) ~= "string" then
		return nil
	end
	if key == "Theme" then
		return Themes[value] and value or nil
	end
	if key == "ToggleKey" then
		local ok = pcall(function()
			return Enum.KeyCode[value]
		end)
		return ok and value or nil
	end
	return value
end

-- ============================================================================
-- MUSIC LIBRARY (shared by every window)
-- ============================================================================
local MusicLibrary = {} -- ordered list of { Name, Id, Artist }
local Windows = {} -- live windows, so registering a track updates all of them

-- Accepts 1234, "1234", "rbxassetid://1234" or a full asset URL.
local function normalizeSoundId(id)
	if type(id) == "number" and id > 0 then
		return "rbxassetid://" .. math.floor(id)
	end
	if type(id) == "string" then
		if id:match("^%d+$") then
			return "rbxassetid://" .. id
		end
		if id:match("^rbxassetid://%d+$") or id:match("^rbxasset://") or id:match("^https?://") then
			return id
		end
	end
	return nil
end

local function findTrack(name)
	for _, track in ipairs(MusicLibrary) do
		if track.Name == name then
			return track
		end
	end
	return nil
end

local function trackNames()
	local names = {}
	for _, track in ipairs(MusicLibrary) do
		table.insert(names, track.Name)
	end
	return names
end

-- The waveform shared by the main visualizer and the island. `position` is 0..1
-- along the bar row, `level` is the smoothed loudness. Idle motion keeps the
-- bars alive during silence; loudness makes them taller.
local function waveHeight(position, clock, level)
	local wave1 = math.sin(position * 15 + clock * 3)
	local wave2 = math.sin(position * 29 - clock * 2)
	local wave3 = math.cos(position * 9 + clock * 4)
	local wave = math.abs(wave1 * 0.45 + wave2 * 0.30 + wave3 * 0.25)
	local audioEffect = level * 0.75
	return math.clamp(0.025 + wave * (0.10 + audioEffect * 0.70), 0.025, 0.92)
end

local function formatClock(seconds)
	seconds = math.max(0, math.floor(seconds or 0))
	return string.format("%d:%02d", math.floor(seconds / 60), seconds % 60)
end

function DashFlow:_connect(signal, handler)
	local connection = signal:Connect(handler)
	table.insert(self.Connections, connection)
	return connection
end

function DashFlow.new(config)
	config = config or {}

	local self = setmetatable({}, DashFlow)
	self.Name = config.Name or "DashFlow"
	self.Tabs = {}
	self.ActiveTab = nil
	self.Connections = {}
	self.Alive = true
	self.Visible = true
	self.ToggleToken = 0
	self.NotifyOrder = 0
	self.StartClock = os.clock()
	self.ThemedBars = {} -- { Instance, Ratio } entries recolored on theme change
	self.Syncers = {} -- key -> function that pushes Config[key] into its control
	self.SaveToken = 0
	self.ThemeBusy = false
	self.PendingTheme = nil

	-- Settings priority: built-in defaults < window options < saved file.
	self.Config = {}
	for key, value in pairs(ConfigDefaults) do
		self.Config[key] = value
	end
	if config.ToggleKey then
		self.Config.ToggleKey = config.ToggleKey.Name
	end
	if config.UserInfoEnabled ~= nil then
		self.Config.UserInfo = config.UserInfoEnabled and true or false
	end
	if type(config.DefaultTheme) == "string" and Themes[config.DefaultTheme] then
		self.Config.Theme = config.DefaultTheme
	end
	self.Defaults = table.clone(self.Config)

	local safeName = (tostring(self.Name):gsub("[^%w_%-]", "_"))
	self.ConfigFolder = config.ConfigFolder or "DashFlow"
	self.ConfigFile = (config.ConfigName or safeName) .. ".json"
	self:_mergeStoredConfig()

	-- The theme must be active before any element is created.
	setPalette(self.Config.Theme)
	self.ThemeName = self.Config.Theme
	self.ToggleKey = Enum.KeyCode[self.Config.ToggleKey]
	table.insert(Windows, self)

	local parent = resolveParent(config.Parent)
	local guiName = "DashFlow_" .. self.Name
	local existing = parent:FindFirstChild(guiName)
	if existing then
		existing:Destroy()
	end

	local camera = workspace.CurrentCamera
	local requested = config.Size or Vector2.new(820, 520)
	local minScale = config.MinScale or 0.7

	local function measure()
		local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
		local fitScale = math.min(1, (viewport.X - 24) / requested.X, (viewport.Y - 24) / requested.Y)
		local scale = math.clamp(fitScale, minScale, 1)
		local fittedWidth = math.min(requested.X, (viewport.X - 24) / scale)
		local fittedHeight = math.min(requested.Y, (viewport.Y - 24) / scale)
		return scale, fittedWidth, fittedHeight
	end

	local baseScale, width, height = measure()
	self.BaseScale = baseScale

	local gui = create("ScreenGui", {
		Name = guiName,
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 999,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		Parent = parent,
	})
	self.Gui = gui

	local uiScale = create("UIScale", { Scale = baseScale })
	self.UIScale = uiScale

	local main = create("Frame", {
		Name = "Main",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(width, height),
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
		Parent = gui,
	}, { corner(20), stroke(Theme.Stroke), uiScale })
	self.Main = main

	local sidebar = create("Frame", {
		Name = "Sidebar",
		Position = UDim2.fromOffset(10, 10),
		Size = UDim2.new(0, 64, 1, -20),
		BackgroundColor3 = Theme.Sidebar,
		BorderSizePixel = 0,
		ZIndex = 5,
		Parent = main,
	}, { corner(16), stroke(Theme.Stroke) })

	local logo = create("Frame", {
		Name = "Logo",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 10),
		Size = UDim2.fromOffset(44, 44),
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
		Parent = sidebar,
	}, { corner(14) })
	makeIcon(logo, config.Logo or DashFlow.Icons.Logo, 20, INK)

	create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 64),
		Size = UDim2.fromOffset(28, 1),
		BackgroundColor3 = Theme.Stroke,
		BorderSizePixel = 0,
		Parent = sidebar,
	})

	self.TabHolder = create("Frame", {
		Name = "Tabs",
		Position = UDim2.fromOffset(0, 76),
		Size = UDim2.new(1, 0, 1, -86),
		BackgroundTransparency = 1,
		Parent = sidebar,
	}, { listLayout(8, Direction.Vertical, HAlign.Center) })

	local header = create("Frame", {
		Name = "Header",
		Position = UDim2.fromOffset(84, 10),
		Size = UDim2.new(1, -94, 0, 50),
		BackgroundTransparency = 1,
		Active = true,
		Parent = main,
	})

	self.HeaderToken = 0

	self.HeaderTitle = label({
		Font = Font.GothamBold,
		TextSize = 18,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextTransparency = 1,
		Position = UDim2.fromOffset(2, 6),
		Size = UDim2.new(0.5, -150, 0, 22),
		Parent = header,
	})

	self.HeaderDesc = label({
		TextSize = 11,
		TextColor3 = Theme.SubText,
		TextTruncate = Enum.TextTruncate.AtEnd,
		TextTransparency = 1,
		Position = UDim2.fromOffset(2, 28),
		Size = UDim2.new(0.5, -150, 0, 16),
		Parent = header,
	})

	local chip = create("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -2, 0.5, 0),
		Size = UDim2.fromOffset(176, 40),
		BackgroundColor3 = Theme.Card,
		BorderSizePixel = 0,
		Parent = header,
	}, { corner(20), stroke(Theme.Stroke) })

	self.UserChip = chip
	self.UserInfoEnabled = self.Config.UserInfo
	chip.Visible = self.UserInfoEnabled

	local chipAvatar = create("ImageLabel", {
		Position = UDim2.fromOffset(4, 3),
		Size = UDim2.fromOffset(34, 34),
		BackgroundColor3 = Theme.Element,
		Image = "",
		Parent = chip,
	}, { corner(17) })
	loadAvatar(chipAvatar)

	label({
		Text = LocalPlayer.DisplayName,
		Font = Font.GothamBold,
		TextSize = 12,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Position = UDim2.fromOffset(46, 5),
		Size = UDim2.new(1, -54, 0, 16),
		Parent = chip,
	})
	label({
		Text = config.Role or "Player",
		TextSize = 10,
		TextColor3 = Theme.SubText,
		Position = UDim2.fromOffset(46, 20),
		Size = UDim2.new(1, -54, 0, 14),
		Parent = chip,
	})

	self.Content = create("Frame", {
		Name = "Content",
		Position = UDim2.fromOffset(84, 66),
		Size = UDim2.new(1, -94, 1, -76),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Parent = main,
	})

	local islandScale = create("UIScale", { Scale = 1 })
	self.IslandScale = islandScale

	local island = create("TextButton", {
		Name = "Island",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 6),
		Size = UDim2.fromOffset(0, 28),
		AutomaticSize = Auto.X,
		BackgroundColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Text = "",
		ZIndex = 60,
		Parent = gui,
	}, {
		corner(14),
		stroke(Color3.fromRGB(38, 38, 52), 1, 0.2),
		padding(0, 0, 12, 12),
		listLayout(10, Direction.Horizontal, HAlign.Left, VAlign.Center),
		islandScale,
	})
	self.Island = island

	self.IslandTitle = label({
		Text = self.Name,
		Font = Font.GothamBold,
		TextSize = 11,
		AutomaticSize = Auto.X,
		Size = UDim2.fromOffset(0, 28),
		LayoutOrder = 1,
		ZIndex = 61,
		Parent = island,
	})

	local visualizer = create("Frame", {
		Size = UDim2.fromOffset(22, 14),
		BackgroundTransparency = 1,
		LayoutOrder = 2,
		ZIndex = 61,
		Parent = island,
	})

	local islandBars = {}
	for index = 1, 5 do
		islandBars[index] = create("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, (index - 1) * 5, 0.5, 0),
			Size = UDim2.fromOffset(2, 3),
			BackgroundColor3 = Theme.Purple:Lerp(Theme.Pink, (index - 1) / 4),
			BorderSizePixel = 0,
			ZIndex = 62,
			Parent = visualizer,
		}, { corner(2) })

		-- Bar colors are a blend of the two accents, so the theme switcher
		-- recolors them explicitly instead of by exact color matching.
		table.insert(self.ThemedBars, { Instance = islandBars[index], Ratio = (index - 1) / 4 })
	end

	-- Heights are driven every frame by DashFlow:_stepAudio (see the audio engine).
	self.IslandBars = islandBars

	island.MouseButton1Down:Connect(function()
		tween(islandScale, { Scale = 0.92 }, 0.1)
	end)
	island.MouseButton1Up:Connect(function()
		tween(islandScale, { Scale = 1 }, 0.35, Enum.EasingStyle.Back)
	end)
	island.MouseLeave:Connect(function()
		tween(islandScale, { Scale = 1 }, 0.35, Enum.EasingStyle.Back)
	end)
	island.MouseButton1Click:Connect(function()
		self:Toggle()
	end)

	self.NotifyHolder = create("Frame", {
		Name = "Notifications",
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -18, 1, -18),
		Size = UDim2.new(0, 290, 1, -36),
		BackgroundTransparency = 1,
		ZIndex = 50,
		Parent = gui,
	}, { listLayout(8, Direction.Vertical, HAlign.Right, VAlign.Bottom) })

	local dragging = false
	local dragStart
	local startPosition

	header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPosition = main.Position
		end
	end)

	self:_connect(UserInputService.InputChanged, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = (input.Position - dragStart) / uiScale.Scale
			main.Position = UDim2.new(
				startPosition.X.Scale,
				startPosition.X.Offset + delta.X,
				startPosition.Y.Scale,
				startPosition.Y.Offset + delta.Y
			)
		end
	end)

	self:_connect(UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	self:_connect(UserInputService.InputBegan, function(input, processed)
		if not processed and input.KeyCode == self.ToggleKey then
			self:Toggle()
		end
	end)

	if camera then
		self:_connect(camera:GetPropertyChangedSignal("ViewportSize"), function()
			local scale, fittedWidth, fittedHeight = measure()
			self.BaseScale = scale
			main.Size = UDim2.fromOffset(fittedWidth, fittedHeight)
			if self.Visible then
				uiScale.Scale = scale
			end
		end)
	end

	-- One audio engine per window; the same smoothed loudness feeds the island
	-- bars and the main visualizer so both always move together.
	self:_initAudio()
	self:_connect(RunService.RenderStepped, function(deltaTime)
		self:_stepAudio(deltaTime)
	end)

	main.Visible = true
	uiScale.Scale = baseScale * 0.6
	tween(uiScale, { Scale = baseScale }, 0.5, Enum.EasingStyle.Back)

	return self
end

function DashFlow:CreateWindow(config)
	return DashFlow.new(config)
end

function DashFlow:Toggle(state)
	if state == nil then
		state = not self.Visible
	end
	if state == self.Visible then
		return
	end
	self.Visible = state
	self.ToggleToken += 1
	local token = self.ToggleToken

	tween(self.IslandTitle, { TextTransparency = state and 0 or 0.45 }, 0.3)
	self.IslandScale.Scale = 1.1
	tween(self.IslandScale, { Scale = 1 }, 0.5, Enum.EasingStyle.Back)

	if state then
		if not self.Main.Visible then
			self.UIScale.Scale = self.BaseScale * 0.6
		end
		self.Main.Visible = true
		tween(self.UIScale, { Scale = self.BaseScale }, 0.4, Enum.EasingStyle.Back)
	else
		local closing = tween(self.UIScale, { Scale = 0.05 }, 0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		closing.Completed:Connect(function()
			if self.ToggleToken ~= token then
				return
			end
			self.Main.Visible = false
		end)
	end
end

-- Public toggle for the topbar profile chip. The value is saved like any setting.
function DashFlow:SetUserInfoEnabled(state)
	self:SetSetting("UserInfo", state and true or false)
end

-- Plays the slide animation; called by SetSetting("UserInfo", ...).
function DashFlow:_applyUserInfo(state)
	if self.UserInfoEnabled == state then
		return
	end
	self.UserInfoEnabled = state
	local chip = self.UserChip
	if state then
		chip.Position = UDim2.new(1, 24, 0.5, 0)
		chip.Visible = true
		tween(chip, { Position = UDim2.new(1, -2, 0.5, 0) }, 0.4, Enum.EasingStyle.Back)
	else
		local leaving = tween(chip, { Position = UDim2.new(1, 24, 0.5, 0) }, 0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		leaving.Completed:Connect(function()
			if not self.UserInfoEnabled then
				chip.Visible = false
			end
		end)
	end
end

function DashFlow:_setHeader(title, desc)
	self.HeaderToken += 1
	local token = self.HeaderToken
	local titleLabel = self.HeaderTitle
	local descLabel = self.HeaderDesc
	local hasDesc = desc ~= nil and desc ~= ""
	local titleY = hasDesc and 6 or 14

	local leaving = tween(titleLabel, { TextTransparency = 1, Position = UDim2.fromOffset(-10, titleY) }, 0.12)
	tween(descLabel, { TextTransparency = 1, Position = UDim2.fromOffset(-10, 28) }, 0.12)

	leaving.Completed:Connect(function()
		if self.HeaderToken ~= token then
			return
		end
		titleLabel.Text = title
		descLabel.Text = hasDesc and desc or ""
		titleLabel.Position = UDim2.fromOffset(16, titleY)
		descLabel.Position = UDim2.fromOffset(16, 28)
		tween(titleLabel, { TextTransparency = 0, Position = UDim2.fromOffset(2, titleY) }, 0.4)
		tween(descLabel, { TextTransparency = hasDesc and 0 or 1, Position = UDim2.fromOffset(2, 28) }, 0.4)
	end)
end

function DashFlow:Destroy()
	if not self.Alive then
		return
	end

	-- Flush pending settings so the last change is never lost.
	if self.Config.AutoSave then
		self:SaveConfig(true)
	end

	self.Alive = false
	for _, connection in ipairs(self.Connections) do
		connection:Disconnect()
	end
	self.Connections = {}

	if self.Sound then
		self.Sound:Destroy()
		self.Sound = nil
	end

	for index, window in ipairs(Windows) do
		if window == self then
			table.remove(Windows, index)
			break
		end
	end

	self.Gui:Destroy()
end

function DashFlow:SelectTab(target)
	local tab = target
	if type(target) == "string" then
		tab = nil
		for _, candidate in ipairs(self.Tabs) do
			if candidate.Name == target then
				tab = candidate
				break
			end
		end
	end
	if not tab or self.ActiveTab == tab then
		return
	end
	local previous = self.ActiveTab
	self.ActiveTab = tab
	if previous then
		previous:_setActive(false)
	end
	tab:_setActive(true)
end

function DashFlow:Notify(config)
	if type(config) == "string" then
		config = { Content = config }
	end
	config = config or {}

	-- `Force = true` shows the toast even when notifications are switched off.
	if config.Force ~= true and self.Config.Notifications == false then
		return
	end

	local duration = config.Duration or self.Config.NotificationDuration or 4
	self.NotifyOrder += 1

	local wrapper = create("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Auto.Y,
		BackgroundTransparency = 1,
		LayoutOrder = self.NotifyOrder,
		Parent = self.NotifyHolder,
	})

	local card = create("Frame", {
		Position = UDim2.new(1, 60, 0, 0),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Auto.Y,
		BackgroundColor3 = Theme.Card,
		BorderSizePixel = 0,
		Parent = wrapper,
	}, { corner(14), stroke(Theme.Stroke), padding(12), listLayout(6) })

	label({
		Text = config.Title or self.Name,
		Font = Font.GothamBold,
		TextSize = 13,
		Size = UDim2.new(1, 0, 0, 16),
		LayoutOrder = 1,
		Parent = card,
	})

	if config.Content then
		label({
			Text = config.Content,
			TextSize = 12,
			TextColor3 = Theme.SubText,
			TextWrapped = true,
			AutomaticSize = Auto.Y,
			Size = UDim2.new(1, 0, 0, 0),
			LayoutOrder = 2,
			Parent = card,
		})
	end

	local bar = create("Frame", {
		Size = UDim2.new(1, 0, 0, 3),
		BackgroundColor3 = Theme.Track,
		BorderSizePixel = 0,
		LayoutOrder = 3,
		Parent = card,
	}, { corner(2) })

	local barFill = create("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = WHITE,
		BorderSizePixel = 0,
		Parent = bar,
	}, { corner(2), gradient(Theme.Purple, Theme.Pink, 0) })

	tween(card, { Position = UDim2.new(0, 0, 0, 0) }, 0.5, Enum.EasingStyle.Back)
	tween(barFill, { Size = UDim2.fromScale(0, 1) }, duration, Enum.EasingStyle.Linear)

	task.delay(duration, function()
		if not wrapper.Parent then
			return
		end
		local leaving = tween(card, { Position = UDim2.new(1, 60, 0, 0) }, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		leaving.Completed:Connect(function()
			wrapper:Destroy()
		end)
	end)
end

function DashFlow:AddTab(config)
	if type(config) == "string" then
		config = { Name = config }
	end
	config = config or {}

	local tab = setmetatable({}, Tab)
	tab.Window = self
	tab.Name = config.Name or ("Tab " .. (#self.Tabs + 1))
	tab.Orders = { Left = 0, Right = 0 }
	tab.Desc = config.Desc or config.Description

	local button = create("TextButton", {
		Name = tab.Name,
		Size = UDim2.fromOffset(44, 44),
		BackgroundColor3 = Theme.Element,
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		Text = "",
		LayoutOrder = #self.Tabs + 1,
		Parent = self.TabHolder,
	}, { corner(14) })

	local buttonStroke = stroke(Theme.Accent, 1, 1)
	buttonStroke.Parent = button

	local icon = makeIcon(button, config.Icon or DashFlow.Icons.Spark, 20, Theme.SubText)

	local tipStroke = stroke(Theme.Stroke, 1, 1)

	local tipLabel = label({
		Text = tab.Name,
		TextSize = 12,
		TextTransparency = 1,
		AutomaticSize = Auto.XY,
		Size = UDim2.fromOffset(0, 0),
		ZIndex = 21,
	})

	local tooltip = create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(1, 10, 0.5, 0),
		Size = UDim2.fromOffset(0, 0),
		AutomaticSize = Auto.XY,
		BackgroundColor3 = Theme.Element,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 20,
		Parent = button,
	}, { corner(8), tipStroke, padding(6, 6, 10, 10), tipLabel })

	local tipToken = 0

	local function showTip(show)
		tipToken += 1
		local token = tipToken
		if show then
			if not UserInputService.MouseEnabled then
				return
			end
			tooltip.Visible = true
			tween(tooltip, { BackgroundTransparency = 0, Position = UDim2.new(1, 18, 0.5, 0) }, 0.2)
			tween(tipLabel, { TextTransparency = 0 }, 0.2)
			tween(tipStroke, { Transparency = 0 }, 0.2)
		else
			local hiding = tween(tooltip, { BackgroundTransparency = 1, Position = UDim2.new(1, 10, 0.5, 0) }, 0.15)
			tween(tipLabel, { TextTransparency = 1 }, 0.15)
			tween(tipStroke, { Transparency = 1 }, 0.15)
			hiding.Completed:Connect(function()
				if tipToken == token then
					tooltip.Visible = false
				end
			end)
		end
	end

	tab.Button = button
	tab.ButtonStroke = buttonStroke
	tab.Icon = icon

	button.MouseEnter:Connect(function()
		showTip(true)
		if self.ActiveTab ~= tab then
			tween(button, { BackgroundTransparency = 0.45 }, 0.15)
		end
	end)

	button.MouseLeave:Connect(function()
		showTip(false)
		if self.ActiveTab ~= tab then
			tween(button, { BackgroundTransparency = 1 }, 0.2)
		end
	end)

	button.MouseButton1Click:Connect(function()
		self:SelectTab(tab)
	end)

	local page = create("Frame", {
		Name = tab.Name,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Visible = false,
		Parent = self.Content,
	})
	tab.Page = page

	local scroll = create("ScrollingFrame", {
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Theme.Accent,
		ScrollBarImageTransparency = 0.4,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Auto.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		Parent = page,
	}, { listLayout(12), padding(2, 12, 2, 10) })
	tab.Scroll = scroll

	tab.Top = create("Frame", {
		Name = "Top",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Auto.Y,
		BackgroundTransparency = 1,
		Visible = false,
		LayoutOrder = 1,
		Parent = scroll,
	}, { listLayout(12) })

	local columns = create("Frame", {
		Name = "Columns",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Auto.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 2,
		Parent = scroll,
	}, { listLayout(12, Direction.Horizontal) })

	tab.LeftColumn = create("Frame", {
		Name = "Left",
		Size = UDim2.new(0.5, -6, 0, 0),
		AutomaticSize = Auto.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 1,
		Parent = columns,
	}, { listLayout(12) })

	tab.RightColumn = create("Frame", {
		Name = "Right",
		Size = UDim2.new(0.5, -6, 0, 0),
		AutomaticSize = Auto.Y,
		BackgroundTransparency = 1,
		LayoutOrder = 2,
		Parent = columns,
	}, { listLayout(12) })

	table.insert(self.Tabs, tab)
	if not self.ActiveTab then
		self:SelectTab(tab)
	end
	return tab
end

function Tab:_setActive(active)
	local colorProperty = self.Icon:IsA("ImageLabel") and "ImageColor3" or "TextColor3"
	tween(self.Button, {
		BackgroundTransparency = active and 0 or 1,
		BackgroundColor3 = active and Theme.Active or Theme.Element,
	}, 0.25)
	tween(self.ButtonStroke, { Transparency = active and 0.55 or 1 }, 0.25)
	tween(self.Icon, { [colorProperty] = active and Theme.Accent or Theme.SubText }, 0.25)
	self.Page.Visible = active
	if active then
		self.Window:_setHeader(self.Name, self.Desc)
		self.Page.Position = UDim2.fromOffset(0, 16)
		tween(self.Page, { Position = UDim2.fromOffset(0, 0) }, 0.45, Enum.EasingStyle.Quint)
	end
end

function Tab:GetTop()
	self.Top.Visible = true
	return self.Top
end

function Tab:AddSection(config, side)
	if type(config) ~= "table" then
		config = { Name = config, Side = side }
	end

	local sideValue = tostring(config.Side or config.side or side or "Left"):lower() == "right" and "Right" or "Left"
	local column = sideValue == "Right" and self.RightColumn or self.LeftColumn
	self.Orders[sideValue] += 1

	local section = setmetatable({}, Section)
	section.Tab = self
	section.Window = self.Window
	section.Side = sideValue
	section.Order = 0

	local title = tostring(config.Name or config.Title or "Section")

	section.Card = create("Frame", {
		Name = title,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Auto.Y,
		BackgroundColor3 = Theme.Card,
		BorderSizePixel = 0,
		LayoutOrder = self.Orders[sideValue],
		Parent = column,
	}, { corner(16), stroke(Theme.Stroke), padding(12), listLayout(8) })

	local head = create("Frame", {
		Size = UDim2.new(1, 0, 0, 28),
		BackgroundTransparency = 1,
		LayoutOrder = 0,
		Parent = section.Card,
	})

	badge(head, config.Icon or DashFlow.Icons.Spark, Theme.Purple, Theme.Pink, 26, UDim2.fromOffset(0, 1))

	label({
		Text = title,
		Font = Font.GothamBold,
		TextSize = 14,
		Position = UDim2.fromOffset(36, 0),
		Size = UDim2.new(1, -36, 1, 0),
		Parent = head,
	})

	return section
end

local function newElement(section, height)
	section.Order += 1
	return create("Frame", {
		Size = UDim2.new(1, 0, 0, height),
		BackgroundColor3 = Theme.Element,
		BorderSizePixel = 0,
		LayoutOrder = section.Order,
		Parent = section.Card,
	}, { corner(10), stroke(Theme.Stroke, 1, 0.2) })
end

function Section:AddLabel(text, value)
	local hasValue = value ~= nil
	local frame = newElement(self, 32)

	local title = label({
		Text = text,
		TextColor3 = hasValue and Theme.SubText or Theme.Text,
		Size = hasValue and UDim2.new(0.4, -12, 1, 0) or UDim2.new(1, -24, 1, 0),
		Position = UDim2.fromOffset(12, 0),
		Parent = frame,
	})

	local content = label({
		Text = hasValue and tostring(value) or "",
		TextXAlignment = TextAlign.Right,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Size = UDim2.new(0.6, -12, 1, 0),
		Position = UDim2.new(0.4, 0, 0, 0),
		Parent = frame,
	})

	local api = { Instance = frame }

	function api:SetText(newText)
		title.Text = newText
	end

	function api:SetValue(newValue)
		content.Text = tostring(newValue)
	end

	return api
end

function Section:AddButton(text, callback)
	local frame = newElement(self, 38)

	local title = label({
		Text = text,
		Size = UDim2.new(1, -48, 1, 0),
		Position = UDim2.fromOffset(12, 0),
		Parent = frame,
	})

	local arrowHolder = create("Frame", {
		BackgroundTransparency = 1,
		Size = UDim2.fromOffset(24, 38),
		Position = UDim2.new(1, -32, 0, 0),
		Parent = frame,
	})
	local arrow = makeIcon(arrowHolder, "chevron-right", 16, Theme.SubText)
	local arrowColor = arrow:IsA("ImageLabel") and "ImageColor3" or "TextColor3"

	local button = create("TextButton", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		Text = "",
		Parent = frame,
	})

	button.MouseEnter:Connect(function()
		tween(frame, { BackgroundColor3 = Theme.ElementHover }, 0.15)
		tween(arrow, { [arrowColor] = Theme.Accent }, 0.2)
		tween(arrowHolder, { Position = UDim2.new(1, -28, 0, 0) }, 0.2)
	end)

	button.MouseLeave:Connect(function()
		tween(frame, { BackgroundColor3 = Theme.Element }, 0.2)
		tween(arrow, { [arrowColor] = Theme.SubText }, 0.2)
		tween(arrowHolder, { Position = UDim2.new(1, -32, 0, 0) }, 0.2)
	end)

	button.MouseButton1Down:Connect(function()
		tween(frame, { BackgroundColor3 = Theme.Active }, 0.08)
	end)

	button.MouseButton1Up:Connect(function()
		tween(frame, { BackgroundColor3 = Theme.ElementHover }, 0.2)
	end)

	button.MouseButton1Click:Connect(function()
		fire(callback)
	end)

	local api = { Instance = frame }

	function api:SetText(newText)
		title.Text = newText
	end

	function api:Fire()
		fire(callback)
	end

	return api
end

function Section:AddToggle(text, default, callback)
	local state = default == true
	local frame = newElement(self, 38)

	label({
		Text = text,
		Size = UDim2.new(1, -72, 1, 0),
		Position = UDim2.fromOffset(12, 0),
		Parent = frame,
	})

	local track = create("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.fromOffset(40, 22),
		BackgroundColor3 = Theme.Track,
		BorderSizePixel = 0,
		Parent = frame,
	}, { corner(11) })

	local fill = create("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = WHITE,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Parent = track,
	}, { corner(11), gradient(Theme.Purple, Theme.Pink, 0) })

	local knob = create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 3, 0.5, 0),
		Size = UDim2.fromOffset(16, 16),
		BackgroundColor3 = Color3.fromRGB(165, 165, 185),
		BorderSizePixel = 0,
		Parent = track,
	}, { corner(8) })

	local button = create("TextButton", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		Text = "",
		Parent = frame,
	})

	local function update(animate)
		apply(fill, { BackgroundTransparency = state and 0 or 1 }, animate, 0.25)
		apply(knob, {
			Position = state and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
			BackgroundColor3 = state and WHITE or Color3.fromRGB(165, 165, 185),
		}, animate, 0.3, Enum.EasingStyle.Back)
	end

	update(false)

	button.MouseEnter:Connect(function()
		tween(frame, { BackgroundColor3 = Theme.ElementHover }, 0.15)
	end)

	button.MouseLeave:Connect(function()
		tween(frame, { BackgroundColor3 = Theme.Element }, 0.2)
	end)

	button.MouseButton1Click:Connect(function()
		state = not state
		update(true)
		fire(callback, state)
	end)

	local api = { Instance = frame }

	function api:Set(value, silent)
		state = value and true or false
		update(true)
		if not silent then
			fire(callback, state)
		end
	end

	function api:Get()
		return state
	end

	return api
end

function Section:AddSlider(text, min, max, default, callback, increment)
	min = min or 0
	max = max or 100
	increment = increment or 1

	local function snap(raw)
		raw = math.clamp(raw, min, max)
		raw = min + math.floor((raw - min) / increment + 0.5) * increment
		raw = math.clamp(raw, min, max)
		return math.floor(raw * 10000 + 0.5) / 10000
	end

	local value = snap(default or min)
	local range = math.max(max - min, 1e-9)
	local frame = newElement(self, 58)

	label({
		Text = text,
		Size = UDim2.new(1, -84, 0, 20),
		Position = UDim2.fromOffset(12, 8),
		Parent = frame,
	})

	local valueLabel = label({
		Font = Font.GothamBold,
		TextSize = 12,
		TextColor3 = Theme.Accent,
		TextXAlignment = TextAlign.Right,
		Size = UDim2.fromOffset(64, 20),
		Position = UDim2.new(1, -76, 0, 8),
		Parent = frame,
	})

	local hit = create("TextButton", {
		Position = UDim2.new(0, 0, 1, -30),
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		Text = "",
		Parent = frame,
	})

	local track = create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 12, 0.5, -2),
		Size = UDim2.new(1, -24, 0, 6),
		BackgroundColor3 = Theme.Track,
		BorderSizePixel = 0,
		Parent = hit,
	}, { corner(3) })

	local fill = create("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = WHITE,
		BorderSizePixel = 0,
		Parent = track,
	}, { corner(3), gradient(Theme.Purple, Theme.Pink, 0) })

	local knob = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.fromOffset(14, 14),
		BackgroundColor3 = WHITE,
		BorderSizePixel = 0,
		Parent = track,
	}, { corner(7), stroke(Theme.Pink, 1, 0.3) })

	local function render(animate)
		local ratio = (value - min) / range
		apply(fill, { Size = UDim2.fromScale(ratio, 1) }, animate, 0.12)
		apply(knob, { Position = UDim2.new(ratio, 0, 0.5, 0) }, animate, 0.12)
		valueLabel.Text = tostring(value)
	end

	render(false)

	local dragging = false

	local function updateFromX(x)
		local ratio = math.clamp((x - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
		local newValue = snap(min + (max - min) * ratio)
		if newValue ~= value then
			value = newValue
			render(true)
			fire(callback, value)
		end
	end

	hit.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			self.Tab.Scroll.ScrollingEnabled = false
			tween(knob, { Size = UDim2.fromOffset(18, 18) }, 0.15)
			updateFromX(input.Position.X)
		end
	end)

	self.Window:_connect(UserInputService.InputChanged, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			updateFromX(input.Position.X)
		end
	end)

	self.Window:_connect(UserInputService.InputEnded, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
			dragging = false
			self.Tab.Scroll.ScrollingEnabled = true
			tween(knob, { Size = UDim2.fromOffset(14, 14) }, 0.15)
		end
	end)

	local api = { Instance = frame }

	function api:Set(newValue, silent)
		value = snap(newValue)
		render(true)
		if not silent then
			fire(callback, value)
		end
	end

	function api:Get()
		return value
	end

	return api
end

function Section:AddDropdown(text, options, default, callback)
	options = options or {}
	local selected = default
	local isOpen = false
	local entries = {}

	local frame = newElement(self, 38)
	frame.ClipsDescendants = true

	label({
		Text = text,
		Size = UDim2.new(0.5, -12, 0, 38),
		Position = UDim2.fromOffset(12, 0),
		Parent = frame,
	})

	local current = label({
		Text = selected ~= nil and tostring(selected) or "Select",
		TextColor3 = Theme.Accent,
		TextXAlignment = TextAlign.Right,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Size = UDim2.new(0.5, -40, 0, 38),
		Position = UDim2.new(0.5, 0, 0, 0),
		Parent = frame,
	})

	local arrow = create("Frame", {
		BackgroundTransparency = 1,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(1, -20, 0, 19),
		Size = UDim2.fromOffset(20, 20),
		Parent = frame,
	})
	makeIcon(arrow, "chevron-down", 16, Theme.SubText)

	local list = create("ScrollingFrame", {
		Position = UDim2.fromOffset(8, 44),
		Size = UDim2.new(1, -16, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = Theme.Accent,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Auto.Y,
		Parent = frame,
	}, { listLayout(2) })

	local header = create("TextButton", {
		Size = UDim2.new(1, 0, 0, 38),
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		Text = "",
		Parent = frame,
	})

	local function paint(entry, animate)
		local active = entry.Value == selected
		apply(entry.Button, {
			BackgroundTransparency = active and 0 or 1,
			BackgroundColor3 = active and Theme.Active or Theme.ElementHover,
		}, animate, 0.15)
		apply(entry.Label, { TextColor3 = active and Theme.Accent or Theme.Text }, animate, 0.15)
	end

	local function render(animate)
		local visibleCount = math.min(#options, 5)
		local height = isOpen and (44 + visibleCount * 30 + 6) or 38
		apply(frame, { Size = UDim2.new(1, 0, 0, height) }, animate, 0.3)
		apply(arrow, { Rotation = isOpen and 180 or 0 }, animate, 0.3)
	end

	local function choose(value, silent)
		selected = value
		current.Text = value ~= nil and tostring(value) or "Select"
		for _, entry in ipairs(entries) do
			paint(entry, true)
		end
		if not silent then
			fire(callback, value)
		end
	end

	local function rebuild()
		for _, entry in ipairs(entries) do
			entry.Button:Destroy()
		end
		entries = {}
		for index, option in ipairs(options) do
			local button = create("TextButton", {
				Size = UDim2.new(1, -6, 0, 28),
				BackgroundColor3 = Theme.ElementHover,
				BackgroundTransparency = 1,
				AutoButtonColor = false,
				Text = "",
				LayoutOrder = index,
				Parent = list,
			}, { corner(8) })

			local optionLabel = label({
				Text = tostring(option),
				TextSize = 12,
				Size = UDim2.new(1, -20, 1, 0),
				Position = UDim2.fromOffset(10, 0),
				Parent = button,
			})

			local entry = { Button = button, Label = optionLabel, Value = option }
			entries[index] = entry
			paint(entry, false)

			button.MouseEnter:Connect(function()
				if entry.Value ~= selected then
					tween(button, { BackgroundTransparency = 0 }, 0.12)
				end
			end)

			button.MouseLeave:Connect(function()
				paint(entry, true)
			end)

			button.MouseButton1Click:Connect(function()
				choose(entry.Value)
				isOpen = false
				render(true)
			end)
		end
		list.Size = UDim2.new(1, -16, 0, math.min(#options, 5) * 30)
	end

	rebuild()
	render(false)

	header.MouseEnter:Connect(function()
		tween(frame, { BackgroundColor3 = Theme.ElementHover }, 0.15)
	end)

	header.MouseLeave:Connect(function()
		tween(frame, { BackgroundColor3 = Theme.Element }, 0.2)
	end)

	header.MouseButton1Click:Connect(function()
		isOpen = not isOpen
		render(true)
	end)

	local api = { Instance = frame }

	function api:Set(value, silent)
		choose(value, silent)
	end

	function api:Get()
		return selected
	end

	function api:Refresh(newOptions, ...)
		options = newOptions or {}
		-- Passing a second argument (even nil) replaces the selection.
		if select("#", ...) > 0 then
			selected = (...)
			current.Text = selected ~= nil and tostring(selected) or "Select"
		end
		rebuild()
		render(true)
	end

	function api:Open()
		isOpen = true
		render(true)
	end

	function api:Close()
		isOpen = false
		render(true)
	end

	return api
end

function Section:AddTextbox(text, placeholder, callback)
	local frame = newElement(self, 42)

	label({
		Text = text,
		Size = UDim2.new(0.45, -12, 1, 0),
		Position = UDim2.fromOffset(12, 0),
		Parent = frame,
	})

	local boxStroke = stroke(Theme.Stroke, 1, 0)

	local box = create("TextBox", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.new(0.55, -14, 0, 28),
		BackgroundColor3 = Theme.Background,
		BorderSizePixel = 0,
		Text = "",
		PlaceholderText = placeholder or "",
		PlaceholderColor3 = Color3.fromRGB(95, 95, 120),
		TextColor3 = Theme.Text,
		Font = Font.GothamMedium,
		TextSize = 12,
		TextXAlignment = TextAlign.Left,
		ClearTextOnFocus = false,
		Parent = frame,
	}, { corner(8), padding(0, 0, 10, 10) })
	boxStroke.Parent = box

	box.Focused:Connect(function()
		tween(boxStroke, { Color = Theme.Accent }, 0.2)
	end)

	box.FocusLost:Connect(function(enterPressed)
		tween(boxStroke, { Color = Theme.Stroke }, 0.2)
		fire(callback, box.Text, enterPressed)
	end)

	local api = { Instance = frame }

	function api:Set(value)
		box.Text = tostring(value)
	end

	function api:Get()
		return box.Text
	end

	return api
end

function DashFlow:AddDashboard(config)
	config = config or {}

	local tab = self:AddTab({
		Name = config.Name or "Dashboard",
		Icon = config.Icon or DashFlow.Icons.Home,
		Desc = config.Desc or "Live overview of your session, server and performance",
	})

	local top = tab:GetTop()

	local row = create("Frame", {
		Name = "Stats",
		Size = UDim2.new(1, 0, 0, 124),
		BackgroundTransparency = 1,
		LayoutOrder = 1,
		Parent = top,
	}, { listLayout(12, Direction.Horizontal) })

	local function statCard(caption, icon, colorA, colorB, suffixText)
		local card = create("Frame", {
			Size = UDim2.new(1 / 3, -8, 1, 0),
			BackgroundColor3 = Theme.Card,
			BorderSizePixel = 0,
			Parent = row,
		}, { corner(16), stroke(Theme.Stroke) })

		badge(card, icon, colorA, colorB, 30, UDim2.fromOffset(14, 14))

		label({
			Text = caption,
			Font = Font.GothamBold,
			TextSize = 11,
			TextColor3 = Theme.SubText,
			TextXAlignment = TextAlign.Right,
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -14, 0, 22),
			Size = UDim2.fromOffset(100, 14),
			Parent = card,
		})

		local valueRow = create("Frame", {
			Position = UDim2.fromOffset(14, 54),
			Size = UDim2.new(1, -28, 0, 36),
			BackgroundTransparency = 1,
			Parent = card,
		}, { listLayout(6, Direction.Horizontal, HAlign.Left, VAlign.Bottom) })

		local value = label({
			Text = "0",
			Font = Font.GothamBold,
			TextSize = 32,
			AutomaticSize = Auto.X,
			Size = UDim2.fromOffset(0, 36),
			LayoutOrder = 1,
			Parent = valueRow,
		})

		local suffix = label({
			Text = suffixText,
			TextSize = 14,
			TextColor3 = Theme.SubText,
			AutomaticSize = Auto.X,
			Size = UDim2.fromOffset(0, 24),
			LayoutOrder = 2,
			Parent = valueRow,
		})

		local pill = create("Frame", {
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, -14, 0, 62),
			Size = UDim2.fromOffset(0, 20),
			AutomaticSize = Auto.X,
			BackgroundColor3 = Theme.Element,
			BorderSizePixel = 0,
			Parent = card,
		}, { corner(10), padding(0, 0, 9, 9) })

		local pillLabel = label({
			Font = Font.GothamBold,
			TextSize = 11,
			AutomaticSize = Auto.X,
			Size = UDim2.fromOffset(0, 20),
			Parent = pill,
		})

		local bar = create("Frame", {
			Position = UDim2.new(0, 14, 1, -22),
			Size = UDim2.new(1, -28, 0, 6),
			BackgroundColor3 = Theme.Track,
			BorderSizePixel = 0,
			Parent = card,
		}, { corner(3) })

		local fill = create("Frame", {
			Size = UDim2.fromScale(0, 1),
			BackgroundColor3 = WHITE,
			BorderSizePixel = 0,
			Parent = bar,
		}, { corner(3), gradient(colorA, colorB, 0) })

		return { Value = value, Suffix = suffix, Pill = pill, PillLabel = pillLabel, Fill = fill }
	end

	local playersCard = statCard("PLAYERS", DashFlow.Icons.Players, Theme.Purple, Theme.Accent, "/ 0")
	local latencyCard = statCard("LATENCY", DashFlow.Icons.Latency, Theme.Orange, Theme.Red, "ms")

	local session = create("Frame", {
		Size = UDim2.new(1 / 3, -8, 1, 0),
		BackgroundColor3 = Theme.Card,
		BorderSizePixel = 0,
		Parent = row,
	}, { corner(16), stroke(Theme.Stroke) })

	create("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = WHITE,
		BorderSizePixel = 0,
		Parent = session,
	}, {
		corner(16),
		create("UIGradient", {
			Rotation = 45,
			Color = ColorSequence.new(Theme.Purple, Theme.Pink),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(0.55, 0.93),
				NumberSequenceKeypoint.new(1, 0.45),
			}),
		}),
	})

	local tag = create("Frame", {
		Position = UDim2.fromOffset(14, 14),
		Size = UDim2.fromOffset(0, 18),
		AutomaticSize = Auto.X,
		BackgroundColor3 = Color3.fromRGB(18, 46, 36),
		BorderSizePixel = 0,
		Parent = session,
	}, { corner(6), padding(0, 0, 7, 7) })

	label({
		Text = "LIVE SESSION",
		Font = Font.GothamBold,
		TextSize = 9,
		TextColor3 = Theme.Success,
		AutomaticSize = Auto.X,
		Size = UDim2.fromOffset(0, 18),
		Parent = tag,
	})

	local avatar = create("ImageLabel", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -14, 0, 12),
		Size = UDim2.fromOffset(34, 34),
		BackgroundColor3 = Theme.Element,
		Image = "",
		Parent = session,
	}, { corner(17), stroke(Theme.Accent, 1, 0.4) })
	loadAvatar(avatar)

	label({
		Text = "Playing as",
		Font = Font.GothamBold,
		TextSize = 15,
		Position = UDim2.fromOffset(14, 44),
		Size = UDim2.new(1, -28, 0, 18),
		Parent = session,
	})

	label({
		Text = LocalPlayer.DisplayName,
		Font = Font.GothamBold,
		TextSize = 15,
		TextColor3 = Theme.Accent,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Position = UDim2.fromOffset(14, 62),
		Size = UDim2.new(1, -28, 0, 18),
		Parent = session,
	})

	local uptimePill = create("Frame", {
		Position = UDim2.new(0, 14, 1, -38),
		Size = UDim2.fromOffset(0, 26),
		AutomaticSize = Auto.X,
		BackgroundColor3 = Theme.Accent,
		BorderSizePixel = 0,
		Parent = session,
	}, { corner(8), padding(0, 0, 10, 10) })

	local uptimeLabel = label({
		Text = "Uptime  00:00:00",
		Font = Font.GothamBold,
		TextSize = 12,
		TextColor3 = INK,
		AutomaticSize = Auto.X,
		Size = UDim2.fromOffset(0, 26),
		Parent = uptimePill,
	})

	local chartCard = create("Frame", {
		Name = "Performance",
		Size = UDim2.new(1, 0, 0, 236),
		BackgroundColor3 = Theme.Card,
		BorderSizePixel = 0,
		LayoutOrder = 2,
		Parent = top,
	}, { corner(16), stroke(Theme.Stroke) })

	badge(chartCard, DashFlow.Icons.Chart, Theme.Purple, Theme.Accent, 32, UDim2.fromOffset(14, 14))

	label({
		Text = "Performance Analytics",
		Font = Font.GothamBold,
		TextSize = 14,
		Position = UDim2.fromOffset(54, 13),
		Size = UDim2.new(0.5, 0, 0, 18),
		Parent = chartCard,
	})

	local legend = create("Frame", {
		Position = UDim2.fromOffset(54, 32),
		Size = UDim2.new(0.5, 0, 0, 14),
		BackgroundTransparency = 1,
		Parent = chartCard,
	}, { listLayout(14, Direction.Horizontal, HAlign.Left, VAlign.Center) })

	local function legendItem(text, color, order)
		local item = create("Frame", {
			Size = UDim2.fromOffset(0, 14),
			AutomaticSize = Auto.X,
			BackgroundTransparency = 1,
			LayoutOrder = order,
			Parent = legend,
		}, { listLayout(5, Direction.Horizontal, HAlign.Left, VAlign.Center) })
		create("Frame", {
			Size = UDim2.fromOffset(6, 6),
			BackgroundColor3 = color,
			BorderSizePixel = 0,
			LayoutOrder = 1,
			Parent = item,
		}, { corner(3) })
		label({
			Text = text,
			TextSize = 10,
			TextColor3 = Theme.SubText,
			AutomaticSize = Auto.X,
			Size = UDim2.fromOffset(0, 14),
			LayoutOrder = 2,
			Parent = item,
		})
	end

	legendItem("Samples", Theme.Accent, 1)
	legendItem("Latest", Theme.Pink, 2)

	local switch = create("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -14, 0, 16),
		Size = UDim2.fromOffset(124, 28),
		BackgroundColor3 = Theme.Element,
		BorderSizePixel = 0,
		Parent = chartCard,
	}, { corner(10), stroke(Theme.Stroke) })

	local indicator = create("Frame", {
		Position = UDim2.fromOffset(3, 3),
		Size = UDim2.new(0.5, -4, 1, -6),
		BackgroundColor3 = Theme.Active,
		BorderSizePixel = 0,
		Parent = switch,
	}, { corner(8) })

	local function switchButton(text, xScale)
		return create("TextButton", {
			Position = UDim2.fromScale(xScale, 0),
			Size = UDim2.fromScale(0.5, 1),
			BackgroundTransparency = 1,
			AutoButtonColor = false,
			Text = text,
			Font = Font.GothamBold,
			TextSize = 11,
			TextColor3 = Theme.SubText,
			Parent = switch,
		})
	end

	local fpsButton = switchButton("FPS", 0)
	local pingButton = switchButton("Ping", 0.5)

	local plot = create("Frame", {
		Position = UDim2.fromOffset(14, 60),
		Size = UDim2.new(1, -28, 1, -72),
		BackgroundTransparency = 1,
		Parent = chartCard,
	})

	local gridArea = create("Frame", {
		Size = UDim2.new(1, 0, 1, -22),
		BackgroundTransparency = 1,
		Parent = plot,
	})

	for index = 1, 4 do
		create("Frame", {
			Position = UDim2.new(0, 0, index / 5, 0),
			Size = UDim2.new(1, 0, 0, 1),
			BackgroundColor3 = Theme.Stroke,
			BackgroundTransparency = 0.35,
			BorderSizePixel = 0,
			Parent = gridArea,
		})
	end

	local columnsFrame = create("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		Parent = plot,
	}, { listLayout(7, Direction.Horizontal) })

	local columns = {}

	for index = 1, 7 do
		local column = create("Frame", {
			Size = UDim2.new(1 / 7, -6, 1, 0),
			BackgroundTransparency = 1,
			LayoutOrder = index,
			Parent = columnsFrame,
		})

		local trackStroke = stroke(Theme.Ghost, 1, 0)

		local track = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 20),
			Size = UDim2.new(0, 30, 1, -42),
			BackgroundColor3 = Theme.Track,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Parent = column,
		}, { corner(9) })
		trackStroke.Parent = track

		local fill = create("Frame", {
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.fromScale(0, 1),
			Size = UDim2.fromScale(1, 0),
			BackgroundColor3 = Theme.Accent,
			BorderSizePixel = 0,
			Parent = track,
		}, { corner(9), gradient(WHITE, Color3.fromRGB(190, 185, 215), 90) })

		local pill = create("TextLabel", {
			AnchorPoint = Vector2.new(0.5, 1),
			Position = UDim2.new(0.5, 0, 0, -4),
			Size = UDim2.fromOffset(38, 16),
			BackgroundColor3 = Theme.Pink,
			BorderSizePixel = 0,
			Text = "",
			TextColor3 = Color3.fromRGB(34, 12, 40),
			Font = Font.GothamBold,
			TextSize = 10,
			Visible = false,
			Parent = fill,
		}, { corner(8) })

		local axis = label({
			Text = "--",
			TextSize = 11,
			TextColor3 = Theme.SubText,
			TextXAlignment = TextAlign.Center,
			Position = UDim2.new(0, 0, 1, -18),
			Size = UDim2.new(1, 0, 0, 18),
			Parent = column,
		})

		columns[index] = { Track = track, TrackStroke = trackStroke, Fill = fill, Pill = pill, Axis = axis }
	end

	local history = { FPS = {}, Ping = {} }
	local limits = { FPS = 120, Ping = 300 }
	local mode = "FPS"
	local fps = 60
	local ping = 0

	local function renderChart(animate)
		local data = history[mode]
		local count = #data
		for index = 1, 7 do
			local column = columns[index]
			local value = data[index]
			if value then
				local ratio = math.clamp(value / limits[mode], 0.05, 1)
				local latest = index == count
				apply(column.Fill, {
					Size = UDim2.fromScale(1, ratio),
					BackgroundColor3 = latest and Theme.Pink or Theme.Accent,
				}, animate, 0.5)
				apply(column.Track, { BackgroundTransparency = 0 }, animate, 0.3)
				apply(column.TrackStroke, {
					Transparency = latest and 0.35 or 1,
					Color = latest and Theme.Pink or Theme.Ghost,
				}, animate, 0.3)
				column.Pill.Visible = latest
				column.Pill.Text = tostring(math.floor(value + 0.5))
				column.Axis.Text = latest and "now" or ("-" .. ((count - index) * 2) .. "s")
			else
				apply(column.Fill, { Size = UDim2.fromScale(1, 0) }, animate, 0.4)
				apply(column.Track, { BackgroundTransparency = 1 }, animate, 0.3)
				apply(column.TrackStroke, { Transparency = 0, Color = Theme.Ghost }, animate, 0.3)
				column.Pill.Visible = false
				column.Axis.Text = "--"
			end
		end
	end

	local function setMode(newMode)
		mode = newMode
		tween(indicator, {
			Position = newMode == "FPS" and UDim2.fromOffset(3, 3) or UDim2.new(0.5, 1, 0, 3),
		}, 0.3, Enum.EasingStyle.Quint)
		tween(fpsButton, { TextColor3 = newMode == "FPS" and Theme.Text or Theme.SubText }, 0.2)
		tween(pingButton, { TextColor3 = newMode == "Ping" and Theme.Text or Theme.SubText }, 0.2)
		renderChart(true)
	end

	fpsButton.TextColor3 = Theme.Text
	fpsButton.MouseButton1Click:Connect(function()
		setMode("FPS")
	end)
	pingButton.MouseButton1Click:Connect(function()
		setMode("Ping")
	end)

	renderChart(false)

	local function push(list, value)
		table.insert(list, value)
		if #list > 7 then
			table.remove(list, 1)
		end
	end

	local function sample()
		push(history.FPS, math.min(fps, limits.FPS))
		push(history.Ping, math.min(ping, limits.Ping))
		renderChart(true)
	end

	local function setPill(card, text, color)
		card.PillLabel.Text = text
		tween(card.PillLabel, { TextColor3 = color }, 0.3)
		tween(card.Pill, { BackgroundColor3 = color:Lerp(Theme.Card, 0.82) }, 0.3)
	end

	local function refresh()
		local count = #Players:GetPlayers()
		local maximum = math.max(Players.MaxPlayers, 1)
		local playerRatio = math.clamp(count / maximum, 0, 1)
		playersCard.Value.Text = tostring(count)
		playersCard.Suffix.Text = "/ " .. maximum
		tween(playersCard.Fill, { Size = UDim2.fromScale(math.max(playerRatio, 0.02), 1) }, 0.5)
		if playerRatio >= 0.9 then
			setPill(playersCard, "Full", Theme.Warning)
		else
			setPill(playersCard, "Online", Theme.Success)
		end

		ping = getPing()
		latencyCard.Value.Text = tostring(math.floor(ping + 0.5))
		tween(latencyCard.Fill, { Size = UDim2.fromScale(math.clamp(ping / 300, 0.02, 1), 1) }, 0.5)
		if ping < 80 then
			setPill(latencyCard, "Stable", Theme.Success)
		elseif ping < 150 then
			setPill(latencyCard, "Fair", Theme.Warning)
		else
			setPill(latencyCard, "High", Theme.Danger)
		end

		uptimeLabel.Text = "Uptime  " .. formatTime(os.clock() - self.StartClock)
	end

	local frames = 0
	local lastFrame = os.clock()

	self:_connect(RunService.RenderStepped, function()
		frames += 1
		local now = os.clock()
		if now - lastFrame >= 0.5 then
			fps = frames / (now - lastFrame)
			frames = 0
			lastFrame = now
		end
	end)

	task.spawn(function()
		task.wait(0.6)
		local ticks = 0
		while self.Alive do
			ticks += 1
			refresh()
			if ticks % 2 == 1 then
				sample()
			end
			task.wait(1)
		end
	end)

	return tab
end

-- ============================================================================
-- SETTINGS: load / save / apply
-- ============================================================================

-- Reads the saved file (if any) and merges every valid value into self.Config.
-- Returns true when a save file was found and decoded.
function DashFlow:_mergeStoredConfig()
	local text = Storage.Read(self.ConfigFolder, self.ConfigFile)
	if not text then
		return false
	end

	local ok, decoded = pcall(HttpService.JSONDecode, HttpService, text)
	if not ok or type(decoded) ~= "table" or type(decoded.Settings) ~= "table" then
		warn("DashFlow: ignoring unreadable settings file " .. self.ConfigFile)
		return false
	end

	for key in pairs(ConfigDefaults) do
		local clean = sanitize(key, decoded.Settings[key])
		if clean ~= nil then
			self.Config[key] = clean
		end
	end
	return true
end

-- Debounced save: rapid changes (slider drags) collapse into a single write.
function DashFlow:_scheduleSave()
	if not self.Config.AutoSave then
		return
	end
	self.SaveToken += 1
	local token = self.SaveToken
	task.delay(0.6, function()
		if self.Alive and token == self.SaveToken then
			self:SaveConfig(true)
		end
	end)
end

-- Writes the current settings. `silent` suppresses the confirmation toast.
function DashFlow:SaveConfig(silent)
	local ok, encoded = pcall(HttpService.JSONEncode, HttpService, {
		Version = 1,
		Settings = self.Config,
	})
	if not ok then
		warn("DashFlow: could not encode settings: " .. tostring(encoded))
		return false
	end

	local saved = Storage.Write(self.ConfigFolder, self.ConfigFile, encoded)

	if not silent and self.Alive then
		local message
		if not saved then
			message = "Could not save your settings."
		elseif Storage.Mode() == "File" then
			message = "Saved to " .. self.ConfigFolder .. "/" .. self.ConfigFile
		else
			message = "Saved for this session (file access is not available here)."
		end
		self:Notify({ Title = "Settings", Content = message })
	end
	return saved
end

-- Loads the saved settings and applies them to the running UI.
function DashFlow:LoadConfig(silent)
	local found = self:_mergeStoredConfig()
	if found then
		self:_applyAll()
		self:_syncControls()
	end
	if not silent then
		self:Notify({
			Title = "Settings",
			Content = found and "Saved settings loaded." or "No saved settings were found.",
		})
	end
	return found
end

-- Restores the window defaults and applies them.
function DashFlow:ResetConfig()
	for key, value in pairs(self.Defaults) do
		self.Config[key] = value
	end
	-- Keep whatever track is selected right now.
	self.Config.Track = self.Audio and self.Audio.Track and self.Audio.Track.Name or ""
	self:_applyAll()
	self:_syncControls()
	self:_scheduleSave()
	self:Notify({ Title = "Settings", Content = "Settings were reset to their defaults." })
end

function DashFlow:GetSetting(key)
	return self.Config[key]
end

-- Validates, stores, applies and (if AutoSave is on) saves one setting.
-- Returns false when the value is not valid for that key.
function DashFlow:SetSetting(key, value)
	local clean = sanitize(key, value)
	if clean == nil then
		warn(("DashFlow: invalid value for setting '%s'"):format(tostring(key)))
		return false
	end
	if self.Config[key] == clean then
		return true
	end

	self.Config[key] = clean
	self:_applySetting(key, clean)

	if key == "AutoSave" then
		-- Always persist the preference itself, even when turning saving off.
		self:SaveConfig(true)
	else
		self:_scheduleSave()
	end
	return true
end

-- Pushes one setting into the part of the UI that uses it.
function DashFlow:_applySetting(key, value)
	if key == "Theme" then
		self:_applyTheme(value, true)
	elseif key == "Volume" then
		if self.Sound then
			self.Sound.Volume = value
		end
	elseif key == "Loop" then
		if self.Sound then
			self.Sound.Looped = value
		end
	elseif key == "ToggleKey" then
		self.ToggleKey = Enum.KeyCode[value]
	elseif key == "UserInfo" then
		self:_applyUserInfo(value)
	end
end

function DashFlow:_applyAll()
	for key in pairs(ConfigDefaults) do
		self:_applySetting(key, self.Config[key])
	end
	if self.Config.Track ~= "" and findTrack(self.Config.Track) then
		self:SelectTrack(self.Config.Track, false)
	end
end

-- Controls register a function here so loading or resetting settings can move
-- their widgets without firing their callbacks.
function DashFlow:_bind(key, syncer)
	self.Syncers[key] = syncer
end

function DashFlow:_syncControls()
	for _, syncer in pairs(self.Syncers) do
		local ok, err = pcall(syncer)
		if not ok then
			warn("DashFlow: could not sync a control: " .. tostring(err))
		end
	end
end

-- ============================================================================
-- THEME SWITCHING
-- ============================================================================

-- Public: switch theme by name (saved automatically).
function DashFlow:SetTheme(name)
	return self:SetSetting("Theme", name)
end

function DashFlow:GetThemes()
	return table.clone(ThemeOrder)
end

-- Fades every themed color in this window to the new palette.
function DashFlow:_applyTheme(name, animate)
	local palette = Themes[name]
	if not palette or self.ThemeName == name then
		return
	end

	-- While a fade is running only the latest request is remembered, so quick
	-- successive switches can never leave half-recolored elements behind.
	if self.ThemeBusy then
		self.PendingTheme = name
		return
	end

	local map = buildColorMap(Themes[self.ThemeName], palette)
	setPalette(name)
	self.ThemeName = name
	recolorTree(self.Gui, map, animate)

	-- Visualizer bars use blended colors, so they are recolored explicitly.
	for _, entry in ipairs(self.ThemedBars) do
		local color = Theme.Purple:Lerp(Theme.Pink, entry.Ratio)
		if animate then
			tween(entry.Instance, { BackgroundColor3 = color }, 0.45, Enum.EasingStyle.Quad)
		else
			entry.Instance.BackgroundColor3 = color
		end
	end

	if animate then
		self.ThemeBusy = true
		task.delay(0.5, function()
			self.ThemeBusy = false
			local pending = self.PendingTheme
			self.PendingTheme = nil
			if self.Alive and pending and pending ~= self.ThemeName then
				self:_applyTheme(pending, true)
			end
		end)
	end
end

-- Adds a custom theme. Missing keys fall back to the default palette.
-- Keep every color in the palette unique (see the THEMES section).
function DashFlow:RegisterTheme(name, palette)
	if type(name) ~= "string" or name == "" or type(palette) ~= "table" then
		warn("DashFlow:RegisterTheme expects (name: string, palette: table)")
		return false
	end
	registerPalette(name, palette)
	for _, window in ipairs(Windows) do
		window:_refreshThemeList()
	end
	return true
end

function DashFlow:_refreshThemeList()
	if self.ThemeDropdown then
		self.ThemeDropdown:Refresh(table.clone(ThemeOrder), self.Config.Theme)
	end
end

-- ============================================================================
-- MUSIC LIBRARY API
-- ============================================================================

-- DashFlow:RegisterMusic("Song Name", 1234567890, "Artist")
-- `id` may be a number, a numeric string, "rbxassetid://..." or an asset URL.
function DashFlow:RegisterMusic(name, id, artist)
	if type(name) ~= "string" or name == "" then
		warn("DashFlow:RegisterMusic expects a non-empty track name")
		return false
	end

	local soundId = normalizeSoundId(id)
	if not soundId then
		warn(("DashFlow:RegisterMusic - '%s' has an invalid sound ID"):format(name))
		return false
	end

	local existing = findTrack(name)
	if existing then
		existing.Id = soundId
		existing.Artist = artist or existing.Artist
	else
		table.insert(MusicLibrary, {
			Name = name,
			Id = soundId,
			Artist = artist or "Unknown Artist",
		})
	end

	for _, window in ipairs(Windows) do
		window:_refreshMusicList()
	end
	return true
end

function DashFlow:UnregisterMusic(name)
	for index, track in ipairs(MusicLibrary) do
		if track.Name == name then
			table.remove(MusicLibrary, index)
			for _, window in ipairs(Windows) do
				window:_refreshMusicList()
			end
			return true
		end
	end
	return false
end

-- Returns a copy of the registered tracks: { { Name, Id, Artist }, ... }
function DashFlow:GetMusic()
	local copy = {}
	for _, track in ipairs(MusicLibrary) do
		table.insert(copy, { Name = track.Name, Id = track.Id, Artist = track.Artist })
	end
	return copy
end

-- ============================================================================
-- AUDIO ENGINE
-- One Sound per window. The smoothed loudness it produces drives the island
-- bars and the main visualizer, so they always match.
-- ============================================================================

function DashFlow:_initAudio()
	local sound = Instance.new("Sound")
	sound.Name = "DashFlowMusic"
	sound.Volume = self.Config.Volume
	sound.Looped = self.Config.Loop
	sound.Parent = SoundService
	self.Sound = sound

	self.Audio = {
		Level = 0, -- smoothed loudness (0..1.5)
		Clock = 0, -- animation time
		UiTimer = 0, -- throttles text updates
		Playing = false,
		Paused = false,
		Track = nil,
		Status = "NO TRACK",
		LoadToken = 0, -- cancels stale load watchers
	}

	-- A non-looping track stops at the end; bring the UI back to "ready".
	sound.Ended:Connect(function()
		if self.Alive and not sound.Looped then
			self.Audio.Playing = false
			self.Audio.Paused = false
			self:_setStatus("FINISHED")
			self:_syncPlayIcon()
		end
	end)
end

-- Runs every rendered frame.
function DashFlow:_stepAudio(deltaTime)
	local audio = self.Audio
	local sound = self.Sound
	if not audio or not sound then
		return
	end

	audio.Clock += deltaTime

	-- Real loudness while playing, silence otherwise. The smoothing means bars
	-- ease toward the new value instead of flickering.
	local loudness = 0
	if sound.IsPlaying then
		loudness = sound.PlaybackLoudness / 350 * self.Config.Sensitivity
	end
	loudness = math.clamp(loudness, 0, 1.5)
	audio.Level += (loudness - audio.Level) * math.min(deltaTime * 12, 1)

	-- Island bars (always visible).
	local islandBars = self.IslandBars
	local islandEnabled = self.Config.IslandVisualizer
	for index, bar in ipairs(islandBars) do
		local height = islandEnabled and waveHeight(index / #islandBars, audio.Clock, audio.Level) or 0.025
		bar.Size = UDim2.fromOffset(2, math.max(2, 2 + height * 13))
	end

	-- Main visualizer: only updated while the Music tab is actually on screen.
	local ui = self.MusicUI
	if ui and self.Visible and self.ActiveTab == ui.Tab then
		local count = #ui.Bars
		for index, bar in ipairs(ui.Bars) do
			local height = waveHeight(index / count, audio.Clock, audio.Level)
			bar.Size = UDim2.fromScale(ui.BarWidth, height)
			bar.BackgroundTransparency = 0.15 + (1 - height) * 0.35
		end

		audio.UiTimer += deltaTime
		if audio.UiTimer >= 0.25 then
			audio.UiTimer = 0
			local length = sound.TimeLength
			ui.Elapsed.Text = formatClock(sound.TimePosition)
			ui.Duration.Text = formatClock(length)
			ui.ProgressFill.Size = UDim2.fromScale(length > 0 and math.clamp(sound.TimePosition / length, 0, 1) or 0, 1)
		end
	end
end

function DashFlow:_setStatus(text)
	self.Audio.Status = text
	local ui = self.MusicUI
	if not ui then
		return
	end
	ui.Status.Text = "● " .. text

	local color = Theme.SubText
	if text == "PLAYING" then
		color = Theme.Success
	elseif text == "PAUSED" or text == "LOADING" then
		color = Theme.Warning
	elseif text == "LOAD FAILED" then
		color = Theme.Danger
	elseif text == "READY" then
		color = Theme.Accent
	end
	ui.Status.TextColor3 = color
end

-- Swaps the play/pause icon to match the playback state.
function DashFlow:_syncPlayIcon()
	local ui = self.MusicUI
	if not ui then
		return
	end
	if ui.PlayIcon then
		ui.PlayIcon:Destroy()
	end
	ui.PlayIcon = makeIcon(ui.PlayButton, self.Audio.Playing and "pause" or "play", 18, INK)
end

function DashFlow:_renderTrackInfo()
	local ui = self.MusicUI
	if not ui then
		return
	end
	local track = self.Audio.Track
	ui.Title.Text = track and track.Name or "No track selected"
	ui.Artist.Text = track and track.Artist or "Register tracks with DashFlow:RegisterMusic(name, id)"
end

-- Rebuilds the track dropdown and keeps the selection valid after the library
-- changed (track added, replaced or removed).
function DashFlow:_refreshMusicList()
	local ui = self.MusicUI
	if not ui or not self.Alive then
		return
	end

	local audio = self.Audio
	local current = audio.Track

	if current and not findTrack(current.Name) then
		self:Stop()
		audio.Track = nil
		current = nil
	end

	if current and self.Sound.SoundId ~= current.Id then
		-- The ID of the selected track was replaced; reload it.
		self:SelectTrack(current.Name, audio.Playing)
	end

	if not current then
		local wanted = self.Config.Track ~= "" and findTrack(self.Config.Track) or nil
		local pick = wanted or MusicLibrary[1]
		if pick then
			self:SelectTrack(pick.Name, false)
		else
			self:_setStatus("NO TRACK")
		end
	end

	ui.TrackDropdown:Refresh(trackNames(), audio.Track and audio.Track.Name or nil)
	ui.LibraryLabel:SetValue(#MusicLibrary .. (#MusicLibrary == 1 and " track" or " tracks"))
	self:_renderTrackInfo()
end

function DashFlow:SelectTrack(name, autoplay)
	local track = findTrack(name)
	if not track then
		return false
	end

	local audio = self.Audio
	if audio.Track ~= track or self.Sound.SoundId ~= track.Id then
		self.Sound:Stop()
		self.Sound.SoundId = track.Id
		self.Sound.TimePosition = 0
		audio.Playing = false
		audio.Paused = false
		audio.LoadToken += 1
	end
	audio.Track = track

	if self.Config.Track ~= track.Name then
		self.Config.Track = track.Name
		self:_scheduleSave()
	end

	if self.MusicUI then
		self.MusicUI.TrackDropdown:Set(track.Name, true)
	end
	self:_renderTrackInfo()
	self:_setStatus("READY")
	self:_syncPlayIcon()

	if autoplay then
		self:Play()
	end
	return true
end

-- step = 1 for the next track, -1 for the previous one (wraps around).
function DashFlow:NextTrack(step)
	local count = #MusicLibrary
	if count == 0 then
		return false
	end
	local index = 0
	for position, track in ipairs(MusicLibrary) do
		if track == self.Audio.Track then
			index = position
			break
		end
	end
	local target = ((index - 1 + step) % count) + 1
	return self:SelectTrack(MusicLibrary[target].Name, self.Audio.Playing)
end

function DashFlow:Play(trackName)
	if trackName and not self:SelectTrack(trackName, false) then
		return false
	end

	local audio = self.Audio
	if not audio.Track then
		self:_setStatus("NO TRACK")
		self:Notify({ Title = "Music", Content = "No track registered. Use DashFlow:RegisterMusic(name, id)." })
		return false
	end

	if audio.Paused then
		self.Sound:Resume()
	else
		self.Sound:Play()
	end
	audio.Playing = true
	audio.Paused = false
	self:_setStatus("PLAYING")
	self:_syncPlayIcon()
	self:_watchLoad()
	return true
end

function DashFlow:Pause()
	local audio = self.Audio
	if not audio.Playing then
		return
	end
	self.Sound:Pause()
	audio.Playing = false
	audio.Paused = true
	self:_setStatus("PAUSED")
	self:_syncPlayIcon()
end

function DashFlow:Stop()
	local audio = self.Audio
	self.Sound:Stop()
	audio.Playing = false
	audio.Paused = false
	audio.LoadToken += 1
	self:_setStatus(audio.Track and "READY" or "NO TRACK")
	self:_syncPlayIcon()
end

function DashFlow:TogglePlay()
	if self.Audio.Playing then
		self:Pause()
	else
		self:Play()
	end
end

-- Roblox has no "load failed" event, so wait for IsLoaded and give up after a
-- timeout. This catches bad IDs and audio the game is not allowed to use.
function DashFlow:_watchLoad()
	local audio = self.Audio
	if self.Sound.IsLoaded then
		return
	end

	audio.LoadToken += 1
	local token = audio.LoadToken
	self:_setStatus("LOADING")

	task.spawn(function()
		local waited = 0
		while self.Alive and token == audio.LoadToken and not self.Sound.IsLoaded and waited < 10 do
			task.wait(0.25)
			waited += 0.25
		end

		if not self.Alive or token ~= audio.LoadToken then
			return
		end

		if self.Sound.IsLoaded then
			self:_setStatus(audio.Playing and "PLAYING" or "READY")
		else
			local name = audio.Track and audio.Track.Name or "track"
			self.Sound:Stop()
			audio.Playing = false
			audio.Paused = false
			self:_setStatus("LOAD FAILED")
			self:_syncPlayIcon()
			self:Notify({
				Title = "Music",
				Content = ('Could not load "%s". Check the asset ID and that the audio is allowed in this game.'):format(name),
			})
		end
	end)
end

-- ============================================================================
-- BUILT-IN TABS
-- ============================================================================

-- Music player with the main visualizer. Build it once per window.
function DashFlow:AddMusicTab(config)
	config = config or {}

	local tab = self:AddTab({
		Name = config.Name or "Music",
		Icon = config.Icon or "music",
		Desc = config.Desc or "Play your tracks and watch the visualizer react in real time",
	})

	local BAR_COUNT = config.BarCount or 60
	local BAR_WIDTH = 0.58 / BAR_COUNT -- as a fraction of the wave width, so it scales with the window

	-- "Now playing" card (full width, above the sections).
	local card = create("Frame", {
		Name = "NowPlaying",
		Size = UDim2.new(1, 0, 0, 236),
		BackgroundColor3 = Theme.Card,
		BorderSizePixel = 0,
		Parent = tab:GetTop(),
	}, { corner(16), stroke(Theme.Stroke) })

	local title = label({
		Text = "No track selected",
		Font = Font.GothamBold,
		TextSize = 16,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Position = UDim2.fromOffset(16, 12),
		Size = UDim2.new(1, -150, 0, 22),
		Parent = card,
	})

	local artist = label({
		Text = "",
		TextSize = 11,
		TextColor3 = Theme.Accent,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Position = UDim2.fromOffset(16, 34),
		Size = UDim2.new(1, -150, 0, 14),
		Parent = card,
	})

	local status = label({
		Text = "● NO TRACK",
		Font = Font.GothamBold,
		TextSize = 11,
		TextColor3 = Theme.SubText,
		TextXAlignment = TextAlign.Right,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -16, 0, 18),
		Size = UDim2.fromOffset(120, 16),
		Parent = card,
	})

	-- Waveform area.
	local wave = create("Frame", {
		Name = "Wave",
		Position = UDim2.fromOffset(14, 60),
		Size = UDim2.new(1, -28, 0, 100),
		BackgroundColor3 = Theme.Sidebar,
		BorderSizePixel = 0,
		ClipsDescendants = true,
		Parent = card,
	}, { corner(12), stroke(Theme.Stroke) })

	create("Frame", {
		Name = "CenterLine",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.new(1, 0, 0, 1),
		BackgroundColor3 = Theme.Accent,
		BackgroundTransparency = 0.7,
		BorderSizePixel = 0,
		Parent = wave,
	})

	local bars = {}
	for index = 1, BAR_COUNT do
		local ratio = (index - 1) / math.max(BAR_COUNT - 1, 1)
		local bar = create("Frame", {
			Name = "Bar" .. index,
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.fromScale(0.015 + ratio * 0.97, 0.5),
			Size = UDim2.fromScale(BAR_WIDTH, 0.025),
			BackgroundColor3 = Theme.Purple:Lerp(Theme.Pink, ratio),
			BorderSizePixel = 0,
			Parent = wave,
		}, { corner(3) })
		bars[index] = bar
		table.insert(self.ThemedBars, { Instance = bar, Ratio = ratio })
	end

	-- Progress (display only).
	local elapsed = label({
		Text = "0:00",
		TextSize = 11,
		TextColor3 = Theme.SubText,
		Position = UDim2.fromOffset(16, 166),
		Size = UDim2.fromOffset(44, 16),
		Parent = card,
	})

	local progress = create("Frame", {
		Position = UDim2.new(0, 64, 0, 172),
		Size = UDim2.new(1, -128, 0, 4),
		BackgroundColor3 = Theme.Track,
		BorderSizePixel = 0,
		Parent = card,
	}, { corner(2) })

	local progressFill = create("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = WHITE,
		BorderSizePixel = 0,
		Parent = progress,
	}, { corner(2), gradient(Theme.Purple, Theme.Pink, 0) })

	local duration = label({
		Text = "0:00",
		TextSize = 11,
		TextColor3 = Theme.SubText,
		TextXAlignment = TextAlign.Right,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -16, 0, 166),
		Size = UDim2.fromOffset(44, 16),
		Parent = card,
	})

	-- Transport controls.
	local controls = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 190),
		Size = UDim2.fromOffset(170, 38),
		BackgroundTransparency = 1,
		Parent = card,
	}, { listLayout(10, Direction.Horizontal, HAlign.Center, VAlign.Center) })

	local function controlButton(iconName, width, primary, order, onClick)
		local button = create("TextButton", {
			Size = UDim2.fromOffset(width, 36),
			BackgroundColor3 = primary and Theme.Accent or Theme.Element,
			AutoButtonColor = false,
			Text = "",
			LayoutOrder = order,
			Parent = controls,
		}, { corner(12) })

		if not primary then
			stroke(Theme.Stroke, 1, 0.2).Parent = button
		end

		local icon = makeIcon(button, iconName, 18, primary and INK or Theme.Text)

		button.MouseEnter:Connect(function()
			tween(button, { BackgroundColor3 = primary and Theme.Accent:Lerp(WHITE, 0.2) or Theme.ElementHover }, 0.15)
		end)
		button.MouseLeave:Connect(function()
			tween(button, { BackgroundColor3 = primary and Theme.Accent or Theme.Element }, 0.2)
		end)
		button.MouseButton1Click:Connect(onClick)

		return button, icon
	end

	controlButton("skip-back", 40, false, 1, function()
		self:NextTrack(-1)
	end)
	local playButton, playIcon = controlButton("play", 60, true, 2, function()
		self:TogglePlay()
	end)
	controlButton("skip-forward", 40, false, 3, function()
		self:NextTrack(1)
	end)

	self.MusicUI = {
		Tab = tab,
		Title = title,
		Artist = artist,
		Status = status,
		Bars = bars,
		BarWidth = BAR_WIDTH,
		Elapsed = elapsed,
		Duration = duration,
		ProgressFill = progressFill,
		PlayButton = playButton,
		PlayIcon = playIcon,
	}

	-- Sections under the card.
	local player = tab:AddSection({ Name = "Player", Side = "Left", Icon = "music" })

	self.MusicUI.TrackDropdown = player:AddDropdown("Track", trackNames(), nil, function(value)
		self:SelectTrack(value, self.Audio.Playing)
	end)

	local volume = player:AddSlider("Volume", 0, 100, math.floor(self.Config.Volume * 100 + 0.5), function(value)
		self:SetSetting("Volume", value / 100)
	end)
	self:_bind("Volume", function()
		volume:Set(self.Config.Volume * 100, true)
	end)

	local loop = player:AddToggle("Loop", self.Config.Loop, function(state)
		self:SetSetting("Loop", state)
	end)
	self:_bind("Loop", function()
		loop:Set(self.Config.Loop, true)
	end)

	local visual = tab:AddSection({ Name = "Visualizer", Side = "Right", Icon = "activity" })

	local sensitivity = visual:AddSlider("Sensitivity", 0.5, 2.5, self.Config.Sensitivity, function(value)
		self:SetSetting("Sensitivity", value)
	end, 0.1)
	self:_bind("Sensitivity", function()
		sensitivity:Set(self.Config.Sensitivity, true)
	end)

	local island = visual:AddToggle("Island Visualizer", self.Config.IslandVisualizer, function(state)
		self:SetSetting("IslandVisualizer", state)
	end)
	self:_bind("IslandVisualizer", function()
		island:Set(self.Config.IslandVisualizer, true)
	end)

	self.MusicUI.LibraryLabel = visual:AddLabel("Library", "0 tracks")

	visual:AddButton("Stop", function()
		self:Stop()
	end)

	self:_refreshMusicList()
	self:_syncPlayIcon()
	return tab
end

-- Built-in settings panel: theme, notifications, interface and saved config.
function DashFlow:AddSettingsTab(config)
	config = config or {}

	local tab = self:AddTab({
		Name = config.Name or "Settings",
		Icon = config.Icon or DashFlow.Icons.Settings,
		Desc = config.Desc or "Appearance, notifications and saved configuration",
	})

	-- Appearance ---------------------------------------------------------------
	local appearance = tab:AddSection({ Name = "Appearance", Side = "Left", Icon = "palette" })

	self.ThemeDropdown = appearance:AddDropdown("Theme", table.clone(ThemeOrder), self.Config.Theme, function(value)
		self:SetSetting("Theme", value)
	end)
	self:_bind("Theme", function()
		self.ThemeDropdown:Set(self.Config.Theme, true)
	end)

	local userInfo = appearance:AddToggle("Show User Info", self.Config.UserInfo, function(state)
		self:SetSetting("UserInfo", state)
	end)
	self:_bind("UserInfo", function()
		userInfo:Set(self.Config.UserInfo, true)
	end)

	-- Saved configuration --------------------------------------------------------
	local storage = tab:AddSection({ Name = "Configuration", Side = "Left", Icon = "save" })

	local autoSave = storage:AddToggle("Auto Save", self.Config.AutoSave, function(state)
		self:SetSetting("AutoSave", state)
	end)
	self:_bind("AutoSave", function()
		autoSave:Set(self.Config.AutoSave, true)
	end)

	storage:AddButton("Save Now", function()
		self:SaveConfig()
	end)
	storage:AddButton("Load Saved Settings", function()
		self:LoadConfig()
	end)
	storage:AddButton("Reset To Defaults", function()
		self:ResetConfig()
	end)
	storage:AddLabel("Storage", Storage.Mode() == "File" and (self.ConfigFolder .. "/" .. self.ConfigFile) or "Session only")

	-- Notifications ----------------------------------------------------------------
	local notifications = tab:AddSection({ Name = "Notifications", Side = "Right", Icon = "bell" })

	local showNotifications = notifications:AddToggle("Show Notifications", self.Config.Notifications, function(state)
		self:SetSetting("Notifications", state)
	end)
	self:_bind("Notifications", function()
		showNotifications:Set(self.Config.Notifications, true)
	end)

	local notifyDuration = notifications:AddSlider("Duration (seconds)", 1, 10, self.Config.NotificationDuration, function(value)
		self:SetSetting("NotificationDuration", value)
	end)
	self:_bind("NotificationDuration", function()
		notifyDuration:Set(self.Config.NotificationDuration, true)
	end)

	notifications:AddButton("Send Test Notification", function()
		self:Notify({ Title = self.Name, Content = "Notifications are working.", Force = true })
	end)

	-- Interface ------------------------------------------------------------------------
	local interface = tab:AddSection({ Name = "Interface", Side = "Right", Icon = DashFlow.Icons.Settings })

	local toggleKey = interface:AddDropdown(
		"Toggle Key",
		{ "RightShift", "RightControl", "LeftAlt", "Insert", "Delete", "Home" },
		self.Config.ToggleKey,
		function(value)
			self:SetSetting("ToggleKey", value)
		end
	)
	self:_bind("ToggleKey", function()
		toggleKey:Set(self.Config.ToggleKey, true)
	end)

	interface:AddButton("Hide Interface", function()
		self:Toggle(false)
	end)
	interface:AddButton("Destroy Interface", function()
		self:Destroy()
	end)

	return tab
end

return DashFlow
