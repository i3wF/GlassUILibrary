local UI = {}
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")

local STEALTH = false
local CHARS = "abcdefghijklmnopqrstuvwxyz0123456789"
local function randName()
	local s = table.create(12)
	for i = 1, 12 do
		local j = math.random(#CHARS)
		s[i] = CHARS:sub(j, j)
	end
	return table.concat(s)
end

local function attachGui(sg, stealth)
	local order = stealth and { "hui", "coregui", "playergui" } or { "playergui", "coregui", "hui" }
	for _, which in ipairs(order) do
		pcall(function()
			if which == "hui" then
				local okH, hui = pcall(function()
					if typeof(gethui) == "function" then
						return gethui()
					end
					return nil
				end)
				if not (okH and hui) then
					error("no gethui")
				end
				sg.Parent = hui
			elseif which == "coregui" then
				sg.Parent = game:GetService("CoreGui")
			else
				local p = Players.LocalPlayer
				local pg = p and p:FindFirstChild("PlayerGui")
				if not pg then
					error("no PlayerGui")
				end
				sg.Parent = pg
			end
		end)
		if sg.Parent then
			return sg.Parent
		end
	end
	return nil
end

local function New(cls, props, par)
	local i = Instance.new(cls)
	for k, v in pairs(props or {}) do
		pcall(function()
			i[k] = v
		end)
	end
	if STEALTH then
		i.Name = randName()
	end
	if par then
		i.Parent = par
	end
	return i
end

local function corner(p, r)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, r)
	c.Parent = p
	return c
end

local function stroke(p, c, t, tr)
	local s = Instance.new("UIStroke")
	s.Color = c
	s.Thickness = t or 1
	s.Transparency = tr or 0.4
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.Parent = p
	return s
end

local function tween(o, pr)
	TweenService:Create(o, TweenInfo.new(0.2, Enum.EasingStyle.Quad), pr):Play()
end
if not game:GetService("Lighting"):FindFirstChild("GlassUI_Blur") then
	local b = Instance.new("BlurEffect")
	b.Name = "GlassUI_Blur"
	b.Size = 22
	b.Parent = game:GetService("Lighting")
end
local THEME = {
	ACCENT = Color3.fromRGB(0, 122, 255),
	ACCENT_HOVER = Color3.fromRGB(20, 135, 255),
	BG_MAIN = Color3.fromRGB(14, 14, 20),
	BG_TOPBAR = Color3.fromRGB(255, 255, 255),
	BG_CONTROL = Color3.fromRGB(255, 255, 255),
	BG_CONTROL_HOVER = Color3.fromRGB(255, 255, 255),
	BG_INPUT = Color3.fromRGB(255, 255, 255),
	BG_LIST = Color3.fromRGB(30, 30, 46),
	TEXT_PRIMARY = Color3.fromRGB(255, 255, 255),
	TEXT_SECONDARY = Color3.fromRGB(210, 210, 225),
	TEXT_TERTIARY = Color3.fromRGB(190, 190, 210),
	TOGGLE_ON = Color3.fromRGB(36, 36, 56),
	STROKE = Color3.fromRGB(255, 255, 255),
}
local ACCENT = THEME.ACCENT
UI.Theme = THEME
function UI.SetTheme(t)
	for k, v in pairs(t) do
		THEME[k] = v
	end
	if t.ACCENT then
		ACCENT = t.ACCENT
	end
end

function UI.New(title, subtitle, opts)
	title = title or "Glass UI"
	subtitle = subtitle or "Dark Liquid • Simple"
	if typeof(opts) == "table" and opts.encrypted then
		STEALTH = true
	end
	local conns = {}
	local function bind(signal, fn)
		local c = signal:Connect(fn)
		table.insert(conns, c)
		return c
	end
	local activeDropdown
	local sg = New("ScreenGui", {
		Name = title .. "_UI",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = 9999,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	})
	attachGui(sg, STEALTH)
	local ddOverlay
	local function getOverlay()
		if not ddOverlay then
			ddOverlay = New("Frame", {
				Name = "DropdownOverlay",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 1, 0),
				Position = UDim2.new(0, 0, 0, 0),
				ZIndex = 10001,
				ClipsDescendants = false,
				Active = false,
				Visible = false,
			}, sg)
		end
		return ddOverlay
	end
	local main = New("CanvasGroup", {
		Name = "MainWindow",
		BackgroundColor3 = THEME.BG_MAIN,
		BackgroundTransparency = 0.42,
		Size = UDim2.new(0, 680, 0, 480),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		AnchorPoint = Vector2.new(0.5, 0.5),
		BorderSizePixel = 0,
	}, sg)
	local mainScale = Instance.new("UIScale")
	mainScale.Scale = 1
	mainScale.Parent = main
	local function applyResponsive()
		local cam = workspace.CurrentCamera
		local vp = cam and cam.ViewportSize or Vector2.new(1920, 1080)
		local w, h = vp.X, vp.Y
		local sx = (w * 0.92) / 680
		local sy = (h * 0.88) / 480
		local s = math.clamp(math.min(sx, sy), 0.48, 1)
		if w >= 900 then
			s = math.max(s, 0.88)
		end
		if w >= 1280 then
			s = 1
		end
		mainScale.Scale = s
	end
	applyResponsive()
	local camConn
	local function bindCamera()
		if camConn then
			camConn:Disconnect()
			camConn = nil
		end
		local cam = workspace.CurrentCamera
		if cam then
			camConn = bind(cam:GetPropertyChangedSignal("ViewportSize"), applyResponsive)
		end
	end
	bindCamera()
	bind(workspace:GetPropertyChangedSignal("CurrentCamera"), function()
		bindCamera()
		applyResponsive()
	end)
	corner(main, 28)
	stroke(main, THEME.STROKE, 1.2, 0.68)
	New("ImageLabel", {
		Name = "Window_Shadow",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, -36, 0, -36),
		Size = UDim2.new(1, 72, 1, 72),
		Image = "rbxassetid://6015897843",
		ImageColor3 = Color3.fromRGB(0, 0, 0),
		ImageTransparency = 0.34,
		ScaleType = Enum.ScaleType.Slice,
		SliceCenter = Rect.new(49, 49, 450, 450),
		ZIndex = -1,
	}, main)
	local body = New(
		"Frame",
		{ Name = "MainBody", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), BorderSizePixel = 0 },
		main
	)
	local topBar = New("Frame", {
		Name = "TopBar",
		BackgroundColor3 = THEME.BG_TOPBAR,
		BackgroundTransparency = 0.82,
		Size = UDim2.new(1, 0, 0, 62),
		BorderSizePixel = 0,
	}, body)
	New("TextLabel", {
		Name = "TopBar_Title",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 16, 0, 12),
		Size = UDim2.new(0.6, 0, 0, 18),
		Font = Enum.Font.GothamBold,
		Text = title,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 19,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, topBar)
	New("TextLabel", {
		Name = "TopBar_Subtitle",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 16, 0, 32),
		Size = UDim2.new(0.6, 0, 0, 14),
		Font = Enum.Font.Gotham,
		Text = subtitle,
		TextColor3 = THEME.TEXT_SECONDARY,
		TextTransparency = 0.08,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, topBar)
	local ctrls = New("Frame", {
		Name = "TopBar_WindowControls_Container",
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -88, 0.5, -16),
		Size = UDim2.new(0, 76, 0, 32),
	}, topBar)
	New("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 8),
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, ctrls)

	local function mkBtn(txt, name)
		local b = New("TextButton", {
			Name = name,
			BackgroundColor3 = THEME.BG_CONTROL,
			BackgroundTransparency = 0.78,
			Size = UDim2.new(0, 32, 0, 32),
			Text = txt,
			Font = Enum.Font.GothamBold,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 17,
			AutoButtonColor = false,
		}, ctrls)
		corner(b, 16)
		stroke(b, Color3.fromRGB(255, 255, 255), 1, 0.42)
		b.LayoutOrder = name == "Minimize" and 1 or 2
		return b
	end
	local minBtn = mkBtn("–", "Minimize")
	local closeBtn = mkBtn("X", "Close")
	local topNav = New("ScrollingFrame", {
		Name = "TopNavigation_Bar",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 14, 0, 72),
		Size = UDim2.new(1, -28, 0, 48),
		BorderSizePixel = 0,
		ClipsDescendants = true,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		AutomaticCanvasSize = Enum.AutomaticSize.X,
		ScrollingDirection = Enum.ScrollingDirection.X,
		ScrollBarThickness = 2,
		ScrollBarImageTransparency = 0.4,
	}, body)
	corner(topNav, 16)
	stroke(topNav, Color3.fromRGB(255, 255, 255), 1, 0.35)
	New("UIPadding", {
		PaddingTop = UDim.new(0, 6),
		PaddingBottom = UDim.new(0, 6),
		PaddingLeft = UDim.new(0, 8),
		PaddingRight = UDim.new(0, 8),
	}, topNav)
	New("UIListLayout", {
		FillDirection = Enum.FillDirection.Horizontal,
		Padding = UDim.new(0, 6),
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		VerticalAlignment = Enum.VerticalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, topNav)
	local contentArea = New("CanvasGroup", {
		Name = "ContentArea_Main",
		BackgroundTransparency = 1,
		Active = false,
		Position = UDim2.new(0, 14, 0, 130),
		Size = UDim2.new(1, -28, 1, -142),
		BorderSizePixel = 0,
	}, body)
	local content = New("ScrollingFrame", {
		Name = "Content_Scroll",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 1, 0),
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarThickness = 6,
		VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
		ScrollingEnabled = true,
		Active = true,
		ScrollBarImageTransparency = 0.65,
		ClipsDescendants = false,
	}, contentArea)
	New("UIListLayout", {
		Padding = UDim.new(0, 10),
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, content)
	New("UIPadding", {
		PaddingTop = UDim.new(0, 6),
		PaddingBottom = UDim.new(0, 6),
		PaddingLeft = UDim.new(0, 6),
		PaddingRight = UDim.new(0, 6),
	}, content)

	local function updCanvas()
		content.CanvasSize =
			UDim2.new(0, 0, 0, content:FindFirstChildOfClass("UIListLayout").AbsoluteContentSize.Y + 12)
	end
	content:FindFirstChildOfClass("UIListLayout"):GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updCanvas)
	local Win = { Gui = sg, Main = main, TopNav = topNav, Content = content, Tabs = {} }

	function Win:Destroy()
		if activeDropdown then
			activeDropdown.Close()
		end
		for _, c in ipairs(conns) do
			pcall(function()
				c:Disconnect()
			end)
		end
		table.clear(conns)
		sg:Destroy()
	end
	local dragging, dragInput, dragStart, startPos

	local function updDrag(inp)
		local d = inp.Position - dragStart
		main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
	end
	topBar.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = i.Position
			startPos = main.Position
			i.Changed:Connect(function()
				if i.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	topBar.InputChanged:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
			dragInput = i
		end
	end)
	bind(UIS.InputChanged, function(i)
		if
			i == dragInput
			and dragging
			and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch)
		then
			updDrag(i)
		end
	end)
	local openBtn = New("TextButton", {
		Name = "OpenButton_FloatingBox",
		BackgroundColor3 = THEME.BG_TOPBAR,
		BackgroundTransparency = 0.82,
		Size = UDim2.new(0, 56, 0, 56),
		Position = UDim2.new(0, 20, 0.5, -28),
		Text = "◈",
		Font = Enum.Font.GothamBold,
		TextColor3 = Color3.fromRGB(255, 255, 255),
		TextSize = 24,
		Visible = false,
		ZIndex = 10002,
	}, sg)
	corner(openBtn, 14)
	stroke(openBtn, Color3.fromRGB(255, 255, 255), 1, 0.48)
	local openBtnHasDragged = false
	do
		local dragging, dragInput, dragStart, startPos
		local DRAG_THRESH = 6
		local function upd(input)
			local delta = input.Position - dragStart
			if delta.Magnitude > DRAG_THRESH then
				openBtnHasDragged = true
			end
			openBtn.Position =
				UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
		openBtn.InputBegan:Connect(function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseButton1
				or input.UserInputType == Enum.UserInputType.Touch
			then
				dragging = true
				openBtnHasDragged = false
				dragStart = input.Position
				startPos = openBtn.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)
		openBtn.InputChanged:Connect(function(input)
			if
				input.UserInputType == Enum.UserInputType.MouseMovement
				or input.UserInputType == Enum.UserInputType.Touch
			then
				dragInput = input
			end
		end)
		bind(UIS.InputChanged, function(input)
			if input == dragInput and dragging then
				upd(input)
			end
		end)
	end
	closeBtn.MouseButton1Click:Connect(function()
		if activeDropdown then
			activeDropdown.Close()
		end
		Win:Destroy()
	end)
	minBtn.MouseButton1Click:Connect(function()
		if activeDropdown then
			activeDropdown.Close()
		end
		main.Visible = false
		openBtn.Visible = true
	end)
	openBtn.MouseButton1Click:Connect(function()
		if openBtnHasDragged then
			openBtnHasDragged = false
			return
		end
		openBtn.Visible = false
		main.Visible = true
		if #Win.Tabs > 1 then
			topNav.Visible = true
		else
			topNav.Visible = false
		end
	end)

	function Win:Tab(name)
		name = name or "Tab"
		local btn = New("TextButton", {
			Name = "Tab_" .. name,
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 92, 0, 32),
			Text = "",
			Font = Enum.Font.GothamBold,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = 17,
			AutoButtonColor = false,
		}, topNav)
		corner(btn, 14)
		stroke(btn, Color3.fromRGB(255, 255, 255), 1, 0.32)
		local lbl = New("TextLabel", {
			Name = "Tab_" .. name .. "_Label",
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 0, 0, 0),
			Size = UDim2.new(1, 0, 1, 0),
			Font = Enum.Font.GothamMedium,
			Text = name,
			TextColor3 = THEME.TEXT_SECONDARY,
			TextTransparency = 0.08,
			TextSize = 15,
			TextXAlignment = Enum.TextXAlignment.Center,
		}, btn)
		local frame = New("ScrollingFrame", {
			Name = name .. "_Content",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			CanvasSize = UDim2.new(0, 0, 0, 0),
			ScrollBarThickness = 2,
			Visible = false,
		}, content)
		local lo = New("UIListLayout", { Padding = UDim.new(0, 12) }, frame)

		local function u2()
			frame.CanvasSize = UDim2.new(0, 0, 0, lo.AbsoluteContentSize.Y + 6)
		end
		lo:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(u2)
		local tab = { Name = name, Button = btn, Frame = frame, Label = lbl }

		local function sel()
			for _, t in ipairs(Win.Tabs) do
				t.Frame.Visible = false
				tween(t.Button, { BackgroundColor3 = THEME.BG_CONTROL })
				t.Label.TextColor3 = THEME.TEXT_SECONDARY
			end
			frame.Visible = true
			tween(btn, { BackgroundColor3 = ACCENT })
			lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
		end
		btn.MouseButton1Click:Connect(sel)
		table.insert(Win.Tabs, tab)
		if #Win.Tabs <= 1 then
			topNav.Visible = false
			contentArea.Position = UDim2.new(0, 14, 0, 72)
			contentArea.Size = UDim2.new(1, -28, 1, -84)
		else
			topNav.Visible = true
			contentArea.Position = UDim2.new(0, 14, 0, 130)
			contentArea.Size = UDim2.new(1, -28, 1, -142)
		end
		if #Win.Tabs == 1 then
			sel()
		end

		function tab:Section(title)
			title = title or "Section"
			local sec = New("Frame", {
				Name = title:gsub("%W", "") .. "Section",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, -4, 0, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				BorderSizePixel = 0,
			}, frame)
			New("UIPadding", {
				PaddingTop = UDim.new(0, 14),
				PaddingBottom = UDim.new(0, 14),
				PaddingLeft = UDim.new(0, 14),
				PaddingRight = UDim.new(0, 14),
			}, sec)
			local sl = New("UIListLayout", { Padding = UDim.new(0, 10) }, sec)
			New("TextLabel", {
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 18),
				Font = Enum.Font.GothamBold,
				Text = title,
				TextColor3 = Color3.fromRGB(255, 255, 255),
				TextSize = 17,
			}, sec)
			sl:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				updCanvas()
				u2()
			end)
			local S = {}

			function S:Button(name, fn)
				fn = fn or function() end
				local b = New("TextButton", {
					BackgroundColor3 = THEME.BG_INPUT,
					BackgroundTransparency = 0.75,
					Size = UDim2.new(1, 0, 0, 42),
					Text = name,
					Font = Enum.Font.GothamBold,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 15,
					AutoButtonColor = false,
				}, sec)
				corner(b, 12)
				stroke(b, Color3.fromRGB(255, 255, 255), 1.2, 0.62)
				b.MouseEnter:Connect(function()
					tween(b, { BackgroundTransparency = 0.68 })
				end)
				b.MouseLeave:Connect(function()
					tween(b, { BackgroundTransparency = 0.75 })
				end)
				b.MouseButton1Down:Connect(function()
					tween(b, { BackgroundTransparency = 0.60 })
				end)
				b.MouseButton1Up:Connect(function()
					tween(b, { BackgroundTransparency = 0.68 })
				end)
				b.MouseButton1Click:Connect(function()
					pcall(fn)
				end)
				return b
			end

			function S:Toggle(name, def, fn)
				def = def or false
				fn = fn or function() end
				local row = New("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 48),
					BorderSizePixel = 0,
				}, sec)
				New("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 12, 0, 0),
					Size = UDim2.new(1, -70, 1, 0),
					Font = Enum.Font.GothamMedium,
					Text = name,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 15,
				}, row)
				local bg = New("Frame", {
					BackgroundColor3 = def and THEME.TOGGLE_ON or THEME.BG_INPUT,
					BackgroundTransparency = def and 0.22 or 0.75,
					Position = UDim2.new(1, -54, 0.5, -13),
					Size = UDim2.new(0, 48, 0, 26),
				}, row)
				corner(bg, 13)
				stroke(bg, Color3.fromRGB(255, 255, 255), 1, 0.32)
				local knob = New("Frame", {
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Position = def and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10),
					Size = UDim2.new(0, 20, 0, 20),
				}, bg)
				corner(knob, 10)
				local v = def

				local function setVal(nv)
					v = nv
					tween(bg, { BackgroundColor3 = nv and THEME.TOGGLE_ON or THEME.BG_INPUT })
					tween(knob, { Position = nv and UDim2.new(1, -22, 0.5, -10) or UDim2.new(0, 2, 0.5, -10) })
					pcall(fn, nv)
				end
				row.InputBegan:Connect(function(i)
					if
						i.UserInputType == Enum.UserInputType.MouseButton1
						or i.UserInputType == Enum.UserInputType.Touch
					then
						setVal(not v)
					end
				end)
				return {
					Set = setVal,
					Get = function()
						return v
					end,
				}
			end

			function S:Slider(name, mn, mx, def, fn)
				mn = mn or 0
				mx = mx or 100
				def = def or 50
				fn = fn or function() end
				def = math.clamp(def, mn, mx)
				local range = (mx - mn > 0) and (mx - mn) or 1
				local fr = New("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 58),
				}, sec)
				New("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 12, 0, 8),
					Size = UDim2.new(0.6, 0, 0, 14),
					Font = Enum.Font.GothamBold,
					Text = name,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 15,
				}, fr)
				local vl = New("TextLabel", {
					BackgroundColor3 = THEME.BG_INPUT,
					BackgroundTransparency = 0.75,
					Position = UDim2.new(1, -54, 0, 8),
					Size = UDim2.new(0, 44, 0, 20),
					Font = Enum.Font.GothamBold,
					Text = tostring(def),
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 14,
				}, fr)
				corner(vl, 8)
				local tr = New("Frame", {
					BackgroundColor3 = THEME.BG_INPUT,
					BackgroundTransparency = 0.75,
					Position = UDim2.new(0, 12, 0, 34),
					Size = UDim2.new(1, -24, 0, 6),
				}, fr)
				corner(tr, 3)
				local fl = New("Frame", {
					BackgroundColor3 = THEME.TOGGLE_ON,
					BackgroundTransparency = 0.06,
					Size = UDim2.new((def - mn) / range, 0, 1, 0),
				}, tr)
				corner(fl, 3)
				local th = New("Frame", {
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Position = UDim2.new((def - mn) / range, -7, 0.5, -8),
					Size = UDim2.new(0, 16, 0, 16),
				}, tr)
				corner(th, 8)
				stroke(th, THEME.TOGGLE_ON, 2, 0.08)
				local dragging = false

				local function upd(x)
					local p = tr.AbsolutePosition.X
					local s = tr.AbsoluteSize.X
					local r = math.clamp((x - p) / s, 0, 1)
					local v = math.floor((mn + (mx - mn) * r) + 0.5)
					local pct = (v - mn) / range
					tween(fl, { Size = UDim2.new(pct, 0, 1, 0) })
					tween(th, { Position = UDim2.new(pct, -7, 0.5, -8) })
					vl.Text = tostring(v)
					pcall(fn, v)
				end
				tr.InputBegan:Connect(function(i)
					if
						i.UserInputType == Enum.UserInputType.MouseButton1
						or i.UserInputType == Enum.UserInputType.Touch
					then
						dragging = true
						upd(i.Position.X)
					end
				end)
				bind(UIS.InputChanged, function(i)
					if
						dragging
						and (
							i.UserInputType == Enum.UserInputType.MouseMovement
							or i.UserInputType == Enum.UserInputType.Touch
						)
					then
						upd(i.Position.X)
					end
				end)
				bind(UIS.InputEnded, function(i)
					if
						i.UserInputType == Enum.UserInputType.MouseButton1
						or i.UserInputType == Enum.UserInputType.Touch
					then
						dragging = false
					end
				end)
			end

			function S:Dropdown(name, list, def, fn)
				list = list or {}
				def = def or list[1]
				fn = fn or function() end
				local fr = New("Frame", {
					Name = "DropdownFrame_" .. name:gsub("%W", ""),
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 48),
					BorderSizePixel = 0,
					ClipsDescendants = false,
					ZIndex = 2,
				}, sec)
				New("TextLabel", {
					Name = "DropdownTitle_" .. name:gsub("%W", ""),
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 12, 0, 0),
					Size = UDim2.new(0.5, 0, 1, 0),
					Font = Enum.Font.GothamMedium,
					Text = name,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 15,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 2,
				}, fr)
				local btn = New("TextButton", {
					Name = "DropdownButton_" .. name:gsub("%W", ""),
					BackgroundColor3 = THEME.BG_INPUT,
					BackgroundTransparency = 0.75,
					Position = UDim2.new(1, -108, 0.5, -14),
					Size = UDim2.new(0, 96, 0, 28),
					Text = "",
					ZIndex = 2,
				}, fr)
				corner(btn, 10)
				stroke(btn, Color3.fromRGB(255, 255, 255), 0.8, 0.48)
				local lbl = New("TextLabel", {
					Name = "DropdownValue_" .. name:gsub("%W", ""),
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 10, 0, 0),
					Size = UDim2.new(1, -20, 1, 0),
					Font = Enum.Font.Gotham,
					Text = def or "Select",
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 14,
					TextXAlignment = Enum.TextXAlignment.Left,
					ZIndex = 3,
				}, btn)
				New("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.new(1, -14, 0.5, -6),
					Size = UDim2.new(0, 12, 0, 12),
					Font = Enum.Font.GothamBold,
					Text = "v",
					TextColor3 = THEME.TEXT_SECONDARY,
					TextSize = 12,
					ZIndex = 3,
				}, btn)

				local overlay = getOverlay()
				local listF = New("Frame", {
					Name = "DropdownList_" .. name:gsub("%W", ""),
					BackgroundColor3 = THEME.BG_LIST,
					BackgroundTransparency = 0.45,
					Position = UDim2.fromOffset(0, 0),
					Size = UDim2.fromOffset(0, 0),
					Visible = false,
					ClipsDescendants = true,
					ZIndex = 1,
					BorderSizePixel = 0,
				}, overlay)
				corner(listF, 12)
				stroke(listF, THEME.STROKE, 1.2, 0.60)
				New("ImageLabel", {
					Name = "DropdownShadow",
					BackgroundTransparency = 1,
					Position = UDim2.new(0, -12, 0, -12),
					Size = UDim2.new(1, 24, 1, 24),
					Image = "rbxassetid://6015897843",
					ImageColor3 = Color3.fromRGB(0, 0, 0),
					ImageTransparency = 0.5,
					ScaleType = Enum.ScaleType.Slice,
					SliceCenter = Rect.new(49, 49, 450, 450),
					ZIndex = 0,
				}, listF)
				local scroll = New("ScrollingFrame", {
					Name = "DropdownScroll_" .. name:gsub("%W", ""),
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 1, 0),
					CanvasSize = UDim2.new(0, 0, 0, 0),
					ScrollBarThickness = 3,
					ScrollBarImageTransparency = 0.3,
					ZIndex = 2,
					ClipsDescendants = true,
				}, listF)
				New("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder }, scroll)
				New("UIPadding", {
					PaddingTop = UDim.new(0, 6),
					PaddingBottom = UDim.new(0, 6),
					PaddingLeft = UDim.new(0, 6),
					PaddingRight = UDim.new(0, 6),
				}, scroll)
				local open = false
				local dd
				local function clearActive()
					if activeDropdown == dd then
						activeDropdown = nil
					end
				end

				local function syncPos()
					if not open then
						return
					end
					local cam = workspace.CurrentCamera
					local vp = cam and cam.ViewportSize or Vector2.new(1920, 1080)
					local pos = fr.AbsolutePosition
					local size = fr.AbsoluteSize
					local h = listF.Size.Y.Offset
					if h == 0 then
						h = math.clamp(#list * 32 + math.max(0, #list - 1) * 6 + 18, 46, 180)
					end
					local targetY = pos.Y + size.Y + 6
					if targetY + h > vp.Y - 10 then
						targetY = pos.Y - h - 6
						if targetY < 10 then
							targetY = 10
						end
					end
					local oPos = overlay.AbsolutePosition
					listF.Position = UDim2.fromOffset(pos.X - oPos.X, targetY - oPos.Y)
					listF.Size = UDim2.fromOffset(size.X, h)
				end

				local function closeNow()
					if not open then
						return
					end
					open = false
					clearActive()
					overlay.Visible = false
					overlay.Active = false
					listF.Visible = false
					listF.Size = UDim2.fromOffset(fr.AbsoluteSize.X, 0)
				end

				local function close()
					if not open then
						return
					end
					open = false
					clearActive()
					overlay.Visible = false
					overlay.Active = false
					tween(listF, { Size = UDim2.fromOffset(fr.AbsoluteSize.X, 0) })
					task.wait(0.18)
					if not open then
						listF.Visible = false
					end
				end

				local function openList()
					if open then
						return
					end
					if activeDropdown and activeDropdown ~= dd then
						activeDropdown.Close()
					end
					activeDropdown = dd
					overlay.Visible = true
					overlay.Active = true
					open = true
					local h = math.clamp(#list * 32 + math.max(0, #list - 1) * 6 + 18, 46, 180)
					local w = fr.AbsoluteSize.X
					local pos = fr.AbsolutePosition
					local cam = workspace.CurrentCamera
					local vp = cam and cam.ViewportSize or Vector2.new(1920, 1080)
					local targetY = pos.Y + fr.AbsoluteSize.Y + 6
					if targetY + h > vp.Y - 10 then
						targetY = pos.Y - h - 6
						if targetY < 10 then
							targetY = 10
						end
					end
					local oPos = overlay.AbsolutePosition
					listF.Position = UDim2.fromOffset(pos.X - oPos.X, targetY - oPos.Y)
					listF.Size = UDim2.fromOffset(w, 0)
					listF.Visible = true
					tween(listF, { Size = UDim2.fromOffset(w, h) })
				end
				dd = { Close = closeNow }

				local function toggle()
					if open then
						close()
					else
						openList()
					end
				end
				btn.MouseButton1Click:Connect(toggle)
				fr:GetPropertyChangedSignal("AbsolutePosition"):Connect(syncPos)
				fr:GetPropertyChangedSignal("AbsoluteSize"):Connect(syncPos)
				bind(UIS.InputBegan, function(inp, gp)
					if
						open
						and (inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch)
						and not gp
					then
						local mp = UIS:GetMouseLocation()
						local inFr = mp.X >= fr.AbsolutePosition.X
							and mp.X <= fr.AbsolutePosition.X + fr.AbsoluteSize.X
							and mp.Y >= fr.AbsolutePosition.Y
							and mp.Y <= fr.AbsolutePosition.Y + fr.AbsoluteSize.Y
						local inList = listF.Visible
							and mp.X >= listF.AbsolutePosition.X
							and mp.X <= listF.AbsolutePosition.X + listF.AbsoluteSize.X
							and mp.Y >= listF.AbsolutePosition.Y
							and mp.Y <= listF.AbsolutePosition.Y + listF.AbsoluteSize.Y
						if not inFr and not inList then
							close()
						end
					end
				end)
				sg:GetPropertyChangedSignal("Enabled"):Connect(function()
					if not sg.Enabled and open then
						open = false
						clearActive()
						listF.Visible = false
						listF.Size = UDim2.fromOffset(fr.AbsoluteSize.X, 0)
					end
				end)
				for i, v in ipairs(list) do
					local opt = New("TextButton", {
						Name = "Opt_" .. tostring(v):gsub("%W", "") .. "_" .. i,
						BackgroundColor3 = THEME.BG_CONTROL,
						BackgroundTransparency = 0.78,
						Size = UDim2.new(1, -4, 0, 34),
						Text = v,
						Font = Enum.Font.GothamMedium,
						TextColor3 = Color3.fromRGB(255, 255, 255),
						TextSize = 15,
						ZIndex = 3,
						AutoButtonColor = false,
						LayoutOrder = i,
					}, scroll)
					corner(opt, 8)
					stroke(opt, Color3.fromRGB(255, 255, 255), 1, 0.32)
					opt.MouseEnter:Connect(function()
						tween(opt, { BackgroundColor3 = THEME.BG_CONTROL_HOVER })
					end)
					opt.MouseLeave:Connect(function()
						tween(opt, { BackgroundColor3 = THEME.BG_CONTROL })
					end)
					opt.MouseButton1Click:Connect(function()
						lbl.Text = v
						close()
						pcall(fn, v)
					end)
				end
				scroll.CanvasSize = UDim2.new(0, 0, 0, #list * 32 + math.max(0, #list - 1) * 6 + 18)
			end

			function S:Box(name, ph, fn)
				ph = ph or ""
				fn = fn or function() end
				local row = New("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 58),
				}, sec)
				New("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 12, 0, 8),
					Size = UDim2.new(1, -24, 0, 14),
					Font = Enum.Font.GothamBold,
					Text = name,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 15,
				}, row)
				local box = New("TextBox", {
					BackgroundColor3 = THEME.BG_INPUT,
					BackgroundTransparency = 0.75,
					Position = UDim2.new(0, 12, 0, 28),
					Size = UDim2.new(1, -24, 0, 26),
					Font = Enum.Font.Gotham,
					Text = "",
					PlaceholderText = ph,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					PlaceholderColor3 = THEME.TEXT_SECONDARY,
					TextSize = 14,
				}, row)
				corner(box, 10)
				box.FocusLost:Connect(function(enterPressed)
					pcall(fn, box.Text, enterPressed)
				end)
			end

			function S:Keybind(name, def, fn)
				def = def or Enum.KeyCode.Q
				fn = fn or function() end
				local row = New("Frame", {
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 0, 48),
				}, sec)
				New("TextLabel", {
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 12, 0, 0),
					Size = UDim2.new(0.6, 0, 1, 0),
					Font = Enum.Font.GothamMedium,
					Text = name,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 15,
				}, row)
				local btn = New("TextButton", {
					BackgroundColor3 = THEME.BG_INPUT,
					BackgroundTransparency = 0.75,
					Position = UDim2.new(1, -80, 0.5, -14),
					Size = UDim2.new(0, 70, 0, 30),
					Text = def.Name,
					Font = Enum.Font.GothamBold,
					TextColor3 = Color3.fromRGB(255, 255, 255),
					TextSize = 14,
				}, row)
				corner(btn, 10)
				local capturing
				btn.MouseButton1Click:Connect(function()
					if capturing then
						capturing:Disconnect()
						capturing = nil
					end
					btn.Text = "..."
					capturing = bind(UIS.InputBegan, function(i, gp)
						if i.UserInputType ~= Enum.UserInputType.Keyboard then
							return
						end
						if gp or UIS:GetFocusedTextBox() then
							return
						end
						capturing:Disconnect()
						capturing = nil
						if i.KeyCode == Enum.KeyCode.Escape then
							btn.Text = def.Name
							return
						end
						btn.Text = i.KeyCode.Name
						pcall(fn, i.KeyCode)
					end)
				end)
			end
			return S
		end
		return tab
	end
	return Win
end

return UI
