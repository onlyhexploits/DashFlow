local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local CoreGui = game:GetService("CoreGui")

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

function DashFlow:_connect(signal, handler)
	local connection = signal:Connect(handler)
	table.insert(self.Connections, connection)
	return connection
end

function DashFlow.new(config)
	config = config or {}

	for key, value in pairs(config.Theme or {}) do
		Theme[key] = value
	end

	local self = setmetatable({}, DashFlow)
	self.Name = config.Name or "DashFlow"
	self.Tabs = {}
	self.ActiveTab = nil
	self.Connections = {}
	self.Alive = true
	self.Visible = true
	self.ToggleToken = 0
	self.NotifyOrder = 0
	self.ToggleKey = config.ToggleKey or Enum.KeyCode.RightShift
	self.StartClock = os.clock()

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

	self.TabHolder = create("Frame", {
		Name = "Tabs",
		Position = UDim2.fromOffset(0, 10),
		Size = UDim2.new(1, 0, 1, -20),
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
	self.IslandAmplitude = 1

	local island = create("TextButton", {
		Name = "Island",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 8),
		Size = UDim2.fromOffset(0, 36),
		AutomaticSize = Auto.X,
		BackgroundColor3 = Color3.new(0, 0, 0),
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Text = "",
		ZIndex = 60,
		Parent = gui,
	}, {
		corner(18),
		stroke(Color3.fromRGB(38, 38, 52), 1, 0.2),
		padding(0, 0, 16, 16),
		listLayout(14, Direction.Horizontal, HAlign.Left, VAlign.Center),
		islandScale,
	})
	self.Island = island

	self.IslandTitle = label({
		Text = self.Name,
		Font = Font.GothamBold,
		TextSize = 12,
		AutomaticSize = Auto.X,
		Size = UDim2.fromOffset(0, 36),
		LayoutOrder = 1,
		ZIndex = 61,
		Parent = island,
	})

	local visualizer = create("Frame", {
		Size = UDim2.fromOffset(27, 20),
		BackgroundTransparency = 1,
		LayoutOrder = 2,
		ZIndex = 61,
		Parent = island,
	})

	local islandBars = {}
	for index = 1, 5 do
		islandBars[index] = create("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, (index - 1) * 6, 0.5, 0),
			Size = UDim2.fromOffset(3, 4),
			BackgroundColor3 = Theme.Purple:Lerp(Theme.Pink, (index - 1) / 4),
			BorderSizePixel = 0,
			ZIndex = 62,
			Parent = visualizer,
		}, { corner(2) })
	end

	task.spawn(function()
		local rng = Random.new()
		while self.Alive do
			for _, bar in ipairs(islandBars) do
				local barHeight = math.floor(4 + rng:NextNumber() * 14 * self.IslandAmplitude)
				tween(bar, { Size = UDim2.fromOffset(3, barHeight) }, 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
			end
			task.wait(0.22)
		end
	end)

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

	self.IslandAmplitude = state and 1 or 0.35
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
	self.Alive = false
	for _, connection in ipairs(self.Connections) do
		connection:Disconnect()
	end
	self.Connections = {}
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
	local duration = config.Duration or 4
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

	function api:Refresh(newOptions, newDefault)
		options = newOptions or {}
		if newDefault ~= nil then
			selected = newDefault
			current.Text = tostring(newDefault)
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

return DashFlow
