--[[
    ╔══════════════════════════════════════════════════════════╗
    ║           JOBWARE LIBRARY V5 - NEVERLOSE STYLE          ║
    ║         Mobile-Optimized · Premium UI · Advanced        ║
    ║              Made by Jobware Development Team            ║
    ╚══════════════════════════════════════════════════════════╝
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local JobwareLib = {}

-- ══════════════════════════════════════════════════════════
-- THEME SETTINGS (Neverlose Inspired)
-- ══════════════════════════════════════════════════════════
local Theme = {
	-- Core Colors
	MainBg       = Color3.fromRGB(12, 12, 16),      -- Sehr dunkel
	SidebarBg    = Color3.fromRGB(16, 16, 20),      -- Sidebar
	SectionBg    = Color3.fromRGB(20, 20, 26),      -- Sektionen
	ElementBg    = Color3.fromRGB(28, 28, 34),      -- Buttons/Inputs
	
	-- Accent & Highlights
	Accent       = Color3.fromRGB(88, 166, 255),    -- Helles Blau
	AccentDark   = Color3.fromRGB(60, 130, 200),    -- Dunkleres Blau
	AccentHover  = Color3.fromRGB(110, 180, 255),   -- Hover State
	
	-- Text Colors
	Text         = Color3.fromRGB(255, 255, 255),   -- Weißer Text
	TextDim      = Color3.fromRGB(150, 150, 160),   -- Grauer Text
	TextDark     = Color3.fromRGB(100, 100, 110),   -- Dunkelgrau
	
	-- Outline & Borders
	Outline      = Color3.fromRGB(40, 40, 50),      -- Ränder
	OutlineLight = Color3.fromRGB(60, 60, 70),      -- Hellere Ränder
	
	-- UI Settings
	Font         = Enum.Font.GothamBold,
	FontSemibold = Enum.Font.GothamSemibold,
	TextSize     = 14,
	TitleSize    = 18,
	
	-- Animation
	AnimSpeed    = 0.2,
	HoverSpeed   = 0.15
}

-- ══════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ══════════════════════════════════════════════════════════

local function AddCorner(instance, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 6)
	corner.Parent = instance
	return corner
end

local function AddStroke(instance, color, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or Theme.Outline
	stroke.Thickness = thickness or 1
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = instance
	return stroke
end

local function AddPadding(instance, padding)
	local pad = Instance.new("UIPadding")
	if type(padding) == "number" then
		pad.PaddingTop = UDim.new(0, padding)
		pad.PaddingBottom = UDim.new(0, padding)
		pad.PaddingLeft = UDim.new(0, padding)
		pad.PaddingRight = UDim.new(0, padding)
	else
		pad.PaddingTop = UDim.new(0, padding.Top or 0)
		pad.PaddingBottom = UDim.new(0, padding.Bottom or 0)
		pad.PaddingLeft = UDim.new(0, padding.Left or 0)
		pad.PaddingRight = UDim.new(0, padding.Right or 0)
	end
	pad.Parent = instance
	return pad
end

-- Smooth Dragging mit Tween
local function MakeDraggable(trigger, object)
	local dragging = false
	local dragInput, dragStart, startPos
	
	trigger.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or 
		   input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = object.Position
			
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	
	trigger.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or 
		   input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			local newPos = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
			TweenService:Create(object, TweenInfo.new(0.1), {Position = newPos}):Play()
		end
	end)
end

-- Hover Effect (NeverLose Style)
local function AddHoverEffect(button, stroke)
	if not stroke then return end
	
	local originalColor = stroke.Color
	local hoverColor = Theme.AccentHover
	
	button.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or 
		   input.UserInputType == Enum.UserInputType.Touch then
			TweenService:Create(stroke, TweenInfo.new(Theme.HoverSpeed), {
				Color = hoverColor
			}):Play()
		end
	end)
	
	button.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or 
		   input.UserInputType == Enum.UserInputType.Touch then
			TweenService:Create(stroke, TweenInfo.new(Theme.HoverSpeed), {
				Color = originalColor
			}):Play()
		end
	end)
end

-- Ripple Effect (Click Feedback)
local function CreateRipple(parent, position)
	local ripple = Instance.new("Frame")
	ripple.Name = "Ripple"
	ripple.Size = UDim2.new(0, 0, 0, 0)
	ripple.Position = UDim2.new(0, position.X - parent.AbsolutePosition.X, 0, position.Y - parent.AbsolutePosition.Y)
	ripple.AnchorPoint = Vector2.new(0.5, 0.5)
	ripple.BackgroundColor3 = Theme.Accent
	ripple.BackgroundTransparency = 0.5
	ripple.BorderSizePixel = 0
	ripple.ZIndex = 100
	ripple.Parent = parent
	AddCorner(ripple, 999)
	
	local maxSize = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 2
	
	local tween1 = TweenService:Create(ripple, TweenInfo.new(0.4), {
		Size = UDim2.new(0, maxSize, 0, maxSize),
		BackgroundTransparency = 1
	})
	
	tween1:Play()
	tween1.Completed:Connect(function()
		ripple:Destroy()
	end)
end

-- ══════════════════════════════════════════════════════════
-- MAIN WINDOW CREATION
-- ══════════════════════════════════════════════════════════

function JobwareLib:CreateWindow(config)
	local Window = {}
	local hubName = config.Name or "JOBWARE"
	local prefix = config.Prefix or "[JW]"
	
	-- Cleanup old GUI
	if CoreGui:FindFirstChild("JobwareV5") then 
		CoreGui:FindFirstChild("JobwareV5"):Destroy() 
	end
	
	-- ScreenGui Setup
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "JobwareV5"
	ScreenGui.Parent = CoreGui
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.ResetOnSpawn = false
	ScreenGui.IgnoreGuiInset = true
	
	-- ══════════════════════════════════════════════════════════
	-- MOBILE TOGGLE BUTTON
	-- ══════════════════════════════════════════════════════════
	
	local ToggleFrame = Instance.new("Frame")
	ToggleFrame.Name = "MobileToggle"
	ToggleFrame.Size = UDim2.new(0, 65, 0, 65)
	ToggleFrame.Position = UDim2.new(0.05, 0, 0.15, 0)
	ToggleFrame.BackgroundColor3 = Theme.MainBg
	ToggleFrame.Parent = ScreenGui
	AddCorner(ToggleFrame, 32)
	
	local toggleStroke = AddStroke(ToggleFrame, Theme.Accent, 2.5)
	MakeDraggable(ToggleFrame, ToggleFrame)
	
	local ToggleIcon = Instance.new("TextLabel")
	ToggleIcon.Size = UDim2.new(1, 0, 1, 0)
	ToggleIcon.BackgroundTransparency = 1
	ToggleIcon.Text = "JW"
	ToggleIcon.Font = Theme.Font
	ToggleIcon.TextSize = 22
	ToggleIcon.TextColor3 = Theme.Accent
	ToggleIcon.Parent = ToggleFrame
	
	local ToggleBtn = Instance.new("TextButton")
	ToggleBtn.Size = UDim2.new(1, 0, 1, 0)
	ToggleBtn.BackgroundTransparency = 1
	ToggleBtn.Text = ""
	ToggleBtn.Parent = ToggleFrame
	
	-- Pulse Animation für Toggle Button
	local pulseActive = true
	task.spawn(function()
		while pulseActive and ToggleFrame.Parent do
			TweenService:Create(toggleStroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {
				Thickness = 3.5
			}):Play()
			wait(1.5)
			if not pulseActive then break end
			TweenService:Create(toggleStroke, TweenInfo.new(1.5, Enum.EasingStyle.Sine), {
				Thickness = 2.5
			}):Play()
			wait(1.5)
		end
	end)
	
	-- ══════════════════════════════════════════════════════════
	-- MAIN FRAME
	-- ══════════════════════════════════════════════════════════
	
	local MainFrame = Instance.new("Frame")
	MainFrame.Name = "MainFrame"
	MainFrame.Size = UDim2.new(0.8, 0, 0.75, 0)
	MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	MainFrame.BackgroundColor3 = Theme.MainBg
	MainFrame.Visible = false
	MainFrame.ClipsDescendants = true
	MainFrame.Parent = ScreenGui
	AddCorner(MainFrame, 8)
	AddStroke(MainFrame, Theme.Outline, 2)
	
	-- Open/Close Toggle
	ToggleBtn.MouseButton1Click:Connect(function()
		MainFrame.Visible = not MainFrame.Visible
		pulseActive = not MainFrame.Visible
		
		if MainFrame.Visible then
			MainFrame.Size = UDim2.new(0, 0, 0, 0)
			TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
				Size = UDim2.new(0.8, 0, 0.75, 0)
			}):Play()
		end
	end)
	
	-- ══════════════════════════════════════════════════════════
	-- TOP BAR
	-- ══════════════════════════════════════════════════════════
	
	local TopBar = Instance.new("Frame")
	TopBar.Name = "TopBar"
	TopBar.Size = UDim2.new(1, 0, 0, 50)
	TopBar.BackgroundColor3 = Theme.SidebarBg
	TopBar.BorderSizePixel = 0
	TopBar.Parent = MainFrame
	AddCorner(TopBar, 8)
	
	-- Fill bottom corners
	local TopBarFill = Instance.new("Frame")
	TopBarFill.Size = UDim2.new(1, 0, 0.5, 0)
	TopBarFill.Position = UDim2.new(0, 0, 0.5, 0)
	TopBarFill.BackgroundColor3 = Theme.SidebarBg
	TopBarFill.BorderSizePixel = 0
	TopBarFill.Parent = TopBar
	
	-- Accent Line (Neverlose Style)
	local AccentLine = Instance.new("Frame")
	AccentLine.Size = UDim2.new(1, 0, 0, 3)
	AccentLine.BackgroundColor3 = Theme.Accent
	AccentLine.BorderSizePixel = 0
	AccentLine.Parent = TopBar
	
	-- Gradient Effect
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Theme.Accent),
		ColorSequenceKeypoint.new(0.5, Theme.AccentHover),
		ColorSequenceKeypoint.new(1, Theme.Accent)
	}
	gradient.Parent = AccentLine
	
	-- Animated Gradient
	task.spawn(function()
		while AccentLine.Parent do
			TweenService:Create(gradient, TweenInfo.new(3, Enum.EasingStyle.Linear), {
				Offset = Vector2.new(1, 0)
			}):Play()
			wait(3)
			gradient.Offset = Vector2.new(-1, 0)
		end
	end)
	
	-- Title
	local Title = Instance.new("TextLabel")
	Title.Text = hubName:upper()
	Title.Size = UDim2.new(0.6, 0, 1, 0)
	Title.Position = UDim2.new(0.03, 0, 0, 0)
	Title.BackgroundTransparency = 1
	Title.Font = Theme.Font
	Title.TextSize = Theme.TitleSize
	Title.TextColor3 = Theme.Text
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Parent = TopBar
	
	-- Subtitle/Prefix
	local Subtitle = Instance.new("TextLabel")
	Subtitle.Text = prefix
	Subtitle.Size = UDim2.new(0.3, 0, 0.5, 0)
	Subtitle.Position = UDim2.new(0.03, 0, 0.5, 0)
	Subtitle.BackgroundTransparency = 1
	Subtitle.Font = Theme.FontSemibold
	Subtitle.TextSize = 11
	Subtitle.TextColor3 = Theme.TextDim
	Subtitle.TextXAlignment = Enum.TextXAlignment.Left
	Subtitle.Parent = TopBar
	
	-- Close Button
	local CloseBtn = Instance.new("TextButton")
	CloseBtn.Size = UDim2.new(0, 40, 0, 40)
	CloseBtn.Position = UDim2.new(1, -45, 0.5, -20)
	CloseBtn.BackgroundTransparency = 1
	CloseBtn.Text = "×"
	CloseBtn.Font = Theme.Font
	CloseBtn.TextSize = 28
	CloseBtn.TextColor3 = Theme.TextDim
	CloseBtn.Parent = TopBar
	
	CloseBtn.MouseButton1Click:Connect(function()
		TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
			Size = UDim2.new(0, 0, 0, 0)
		}):Play()
		wait(0.2)
		MainFrame.Visible = false
		pulseActive = true
	end)
	
	CloseBtn.MouseEnter:Connect(function()
		TweenService:Create(CloseBtn, TweenInfo.new(0.1), {TextColor3 = Color3.fromRGB(255, 80, 80)}):Play()
	end)
	
	CloseBtn.MouseLeave:Connect(function()
		TweenService:Create(CloseBtn, TweenInfo.new(0.1), {TextColor3 = Theme.TextDim}):Play()
	end)
	
	MakeDraggable(TopBar, MainFrame)
	
	-- ══════════════════════════════════════════════════════════
	-- SIDEBAR
	-- ══════════════════════════════════════════════════════════
	
	local Sidebar = Instance.new("ScrollingFrame")
	Sidebar.Name = "Sidebar"
	Sidebar.Size = UDim2.new(0.28, 0, 1, -50)
	Sidebar.Position = UDim2.new(0, 0, 0, 50)
	Sidebar.BackgroundColor3 = Theme.SidebarBg
	Sidebar.BorderSizePixel = 0
	Sidebar.ScrollBarThickness = 0
	Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
	Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
	Sidebar.Parent = MainFrame
	
	local SidebarLayout = Instance.new("UIListLayout")
	SidebarLayout.Padding = UDim.new(0, 8)
	SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
	SidebarLayout.Parent = Sidebar
	
	AddPadding(Sidebar, {Top = 15, Bottom = 15})
	
	-- Sidebar Divider
	local SidebarDivider = Instance.new("Frame")
	SidebarDivider.Size = UDim2.new(0, 2, 1, 0)
	SidebarDivider.Position = UDim2.new(1, 0, 0, 0)
	SidebarDivider.BackgroundColor3 = Theme.Outline
	SidebarDivider.BorderSizePixel = 0
	SidebarDivider.Parent = Sidebar
	
	-- ══════════════════════════════════════════════════════════
	-- CONTENT AREA
	-- ══════════════════════════════════════════════════════════
	
	local Content = Instance.new("Frame")
	Content.Name = "Content"
	Content.Size = UDim2.new(0.72, 0, 1, -50)
	Content.Position = UDim2.new(0.28, 0, 0, 50)
	Content.BackgroundTransparency = 1
	Content.Parent = MainFrame
	
	local Tabs = {}
	
	-- ══════════════════════════════════════════════════════════
	-- TAB CREATION
	-- ══════════════════════════════════════════════════════════
	
	function Window:CreateTab(name, icon)
		local Tab = {}
		
		-- Tab Button
		local TabBtn = Instance.new("TextButton")
		TabBtn.Name = name.."Tab"
		TabBtn.Size = UDim2.new(0.92, 0, 0, 50)
		TabBtn.BackgroundColor3 = Theme.SectionBg
		TabBtn.BackgroundTransparency = 1
		TabBtn.Text = ""
		TabBtn.AutoButtonColor = false
		TabBtn.Parent = Sidebar
		AddCorner(TabBtn, 6)
		
		local tabStroke = AddStroke(TabBtn, Theme.Outline, 1.5)
		
		-- Icon (Optional)
		local Icon
		if icon then
			Icon = Instance.new("ImageLabel")
			Icon.Size = UDim2.new(0, 24, 0, 24)
			Icon.Position = UDim2.new(0, 12, 0.5, -12)
			Icon.BackgroundTransparency = 1
			Icon.Image = icon
			Icon.ImageColor3 = Theme.TextDim
			Icon.Parent = TabBtn
		end
		
		-- Tab Label
		local TabLabel = Instance.new("TextLabel")
		TabLabel.Text = name
		TabLabel.Size = UDim2.new(1, icon and -50 or -24, 1, 0)
		TabLabel.Position = UDim2.new(0, icon and 44 or 12, 0, 0)
		TabLabel.BackgroundTransparency = 1
		TabLabel.Font = Theme.FontSemibold
		TabLabel.TextSize = Theme.TextSize
		TabLabel.TextColor3 = Theme.TextDim
		TabLabel.TextXAlignment = Enum.TextXAlignment.Left
		TabLabel.Parent = TabBtn
		
		-- Active Indicator
		local ActiveIndicator = Instance.new("Frame")
		ActiveIndicator.Size = UDim2.new(0, 3, 0.7, 0)
		ActiveIndicator.Position = UDim2.new(0, 0, 0.15, 0)
		ActiveIndicator.BackgroundColor3 = Theme.Accent
		ActiveIndicator.BackgroundTransparency = 1
		ActiveIndicator.BorderSizePixel = 0
		ActiveIndicator.Parent = TabBtn
		AddCorner(ActiveIndicator, 2)
		
		-- Page
		local Page = Instance.new("ScrollingFrame")
		Page.Name = name.."Page"
		Page.Size = UDim2.new(1, 0, 1, 0)
		Page.BackgroundTransparency = 1
		Page.Visible = false
		Page.ScrollBarThickness = 4
		Page.ScrollBarImageColor3 = Theme.Accent
		Page.CanvasSize = UDim2.new(0, 0, 0, 0)
		Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
		Page.Parent = Content
		
		local PageLayout = Instance.new("UIListLayout")
		PageLayout.Padding = UDim.new(0, 15)
		PageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
		PageLayout.Parent = Page
		
		AddPadding(Page, {Top = 15, Bottom = 15})
		
		-- Tab Click Logic
		TabBtn.MouseButton1Click:Connect(function()
			-- Ripple Effect
			CreateRipple(TabBtn, UserInputService:GetMouseLocation())
			
			-- Deactivate all tabs
			for _, tab in pairs(Tabs) do
				tab.Page.Visible = false
				TweenService:Create(tab.Label, TweenInfo.new(Theme.AnimSpeed), {
					TextColor3 = Theme.TextDim
				}):Play()
				TweenService:Create(tab.Indicator, TweenInfo.new(Theme.AnimSpeed), {
					BackgroundTransparency = 1
				}):Play()
				TweenService:Create(tab.Btn, TweenInfo.new(Theme.AnimSpeed), {
					BackgroundTransparency = 1
				}):Play()
				TweenService:Create(tab.Stroke, TweenInfo.new(Theme.AnimSpeed), {
					Color = Theme.Outline
				}):Play()
				if tab.Icon then
					TweenService:Create(tab.Icon, TweenInfo.new(Theme.AnimSpeed), {
						ImageColor3 = Theme.TextDim
					}):Play()
				end
			end
			
			-- Activate this tab
			Page.Visible = true
			TweenService:Create(TabLabel, TweenInfo.new(Theme.AnimSpeed), {
				TextColor3 = Theme.Text
			}):Play()
			TweenService:Create(ActiveIndicator, TweenInfo.new(Theme.AnimSpeed), {
				BackgroundTransparency = 0
			}):Play()
			TweenService:Create(TabBtn, TweenInfo.new(Theme.AnimSpeed), {
				BackgroundTransparency = 0
			}):Play()
			TweenService:Create(tabStroke, TweenInfo.new(Theme.AnimSpeed), {
				Color = Theme.Accent
			}):Play()
			if Icon then
				TweenService:Create(Icon, TweenInfo.new(Theme.AnimSpeed), {
					ImageColor3 = Theme.Accent
				}):Play()
			end
		end)
		
		-- Hover Effect
		AddHoverEffect(TabBtn, tabStroke)
		
		-- Store tab data
		table.insert(Tabs, {
			Btn = TabBtn,
			Page = Page,
			Label = TabLabel,
			Indicator = ActiveIndicator,
			Stroke = tabStroke,
			Icon = Icon
		})
		
		-- Auto-activate first tab
		if #Tabs == 1 then
			Page.Visible = true
			TabLabel.TextColor3 = Theme.Text
			ActiveIndicator.BackgroundTransparency = 0
			TabBtn.BackgroundTransparency = 0
			tabStroke.Color = Theme.Accent
			if Icon then Icon.ImageColor3 = Theme.Accent end
		end
		
		-- ══════════════════════════════════════════════════════════
		-- SECTION CREATION
		-- ══════════════════════════════════════════════════════════
		
		function Tab:CreateSection(sectionName)
			local Section = {}
			
			local SectionFrame = Instance.new("Frame")
			SectionFrame.Name = sectionName.."Section"
			SectionFrame.Size = UDim2.new(0.96, 0, 0, 0)
			SectionFrame.BackgroundColor3 = Theme.SectionBg
			SectionFrame.AutomaticSize = Enum.AutomaticSize.Y
			SectionFrame.Parent = Page
			AddCorner(SectionFrame, 6)
			AddStroke(SectionFrame, Theme.Outline, 1.5)
			
			-- Section Header
			local SectionHeader = Instance.new("Frame")
			SectionHeader.Size = UDim2.new(1, 0, 0, 40)
			SectionHeader.BackgroundTransparency = 1
			SectionHeader.Parent = SectionFrame
			
			local SectionTitle = Instance.new("TextLabel")
			SectionTitle.Text = sectionName
			SectionTitle.Size = UDim2.new(1, -30, 1, 0)
			SectionTitle.Position = UDim2.new(0, 15, 0, 0)
			SectionTitle.BackgroundTransparency = 1
			SectionTitle.Font = Theme.FontSemibold
			SectionTitle.TextSize = 15
			SectionTitle.TextColor3 = Theme.Accent
			SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
			SectionTitle.Parent = SectionHeader
			
			-- Divider
			local Divider = Instance.new("Frame")
			Divider.Size = UDim2.new(1, 0, 0, 1)
			Divider.Position = UDim2.new(0, 0, 1, -1)
			Divider.BackgroundColor3 = Theme.Outline
			Divider.BorderSizePixel = 0
			Divider.Parent = SectionHeader
			
			-- Items Container
			local Items = Instance.new("Frame")
			Items.Size = UDim2.new(1, 0, 0, 0)
			Items.Position = UDim2.new(0, 0, 0, 40)
			Items.BackgroundTransparency = 1
			Items.AutomaticSize = Enum.AutomaticSize.Y
			Items.Parent = SectionFrame
			
			local ItemLayout = Instance.new("UIListLayout")
			ItemLayout.Padding = UDim.new(0, 10)
			ItemLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			ItemLayout.SortOrder = Enum.SortOrder.LayoutOrder
			ItemLayout.Parent = Items
			
			AddPadding(Items, {Top = 12, Bottom = 15})
			
			-- ══════════════════════════════════════════════════════════
			-- BUTTON ELEMENT
			-- ══════════════════════════════════════════════════════════
			
			function Section:AddButton(text, callback)
				local Button = Instance.new("TextButton")
				Button.Size = UDim2.new(0.94, 0, 0, 45)
				Button.BackgroundColor3 = Theme.ElementBg
				Button.Text = text
				Button.Font = Theme.FontSemibold
				Button.TextSize = Theme.TextSize
				Button.TextColor3 = Theme.Text
				Button.AutoButtonColor = false
				Button.Parent = Items
				AddCorner(Button, 5)
				
				local btnStroke = AddStroke(Button, Theme.Outline, 1.5)
				AddHoverEffect(Button, btnStroke)
				
				Button.MouseButton1Click:Connect(function()
					CreateRipple(Button, UserInputService:GetMouseLocation())
					
					TweenService:Create(Button, TweenInfo.new(0.1), {
						BackgroundColor3 = Theme.Accent
					}):Play()
					
					task.wait(0.15)
					
					TweenService:Create(Button, TweenInfo.new(0.2), {
						BackgroundColor3 = Theme.ElementBg
					}):Play()
					
					pcall(callback)
				end)
				
				return Button
			end
			
			-- ══════════════════════════════════════════════════════════
			-- TOGGLE ELEMENT
			-- ══════════════════════════════════════════════════════════
			
			function Section:AddToggle(text, default, callback)
				local toggled = default or false
				
				local Container = Instance.new("TextButton")
				Container.Size = UDim2.new(0.94, 0, 0, 45)
				Container.BackgroundColor3 = Theme.ElementBg
				Container.Text = ""
				Container.AutoButtonColor = false
				Container.Parent = Items
				AddCorner(Container, 5)
				
				local containerStroke = AddStroke(Container, Theme.Outline, 1.5)
				AddHoverEffect(Container, containerStroke)
				
				local Label = Instance.new("TextLabel")
				Label.Text = text
				Label.Size = UDim2.new(0.7, 0, 1, 0)
				Label.Position = UDim2.new(0, 15, 0, 0)
				Label.BackgroundTransparency = 1
				Label.Font = Theme.FontSemibold
				Label.TextSize = Theme.TextSize
				Label.TextColor3 = Theme.Text
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Parent = Container
				
				-- Switch Background
				local Switch = Instance.new("Frame")
				Switch.Size = UDim2.new(0, 50, 0, 26)
				Switch.Position = UDim2.new(1, -60, 0.5, -13)
				Switch.BackgroundColor3 = toggled and Theme.Accent or Color3.fromRGB(40, 40, 48)
				Switch.Parent = Container
				AddCorner(Switch, 13)
				
				-- Switch Dot
				local Dot = Instance.new("Frame")
				Dot.Size = UDim2.new(0, 20, 0, 20)
				Dot.Position = toggled and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
				Dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Dot.Parent = Switch
				AddCorner(Dot, 10)
				
				Container.MouseButton1Click:Connect(function()
					toggled = not toggled
					
					local goalPos = toggled and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
					local goalColor = toggled and Theme.Accent or Color3.fromRGB(40, 40, 48)
					
					TweenService:Create(Dot, TweenInfo.new(Theme.AnimSpeed, Enum.EasingStyle.Quad), {
						Position = goalPos
					}):Play()
					
					TweenService:Create(Switch, TweenInfo.new(Theme.AnimSpeed), {
						BackgroundColor3 = goalColor
					}):Play()
					
					pcall(callback, toggled)
				end)
				
				return {
					SetValue = function(value)
						toggled = value
						local goalPos = toggled and UDim2.new(1, -23, 0.5, -10) or UDim2.new(0, 3, 0.5, -10)
						local goalColor = toggled and Theme.Accent or Color3.fromRGB(40, 40, 48)
						Dot.Position = goalPos
						Switch.BackgroundColor3 = goalColor
					end
				}
			end
			
			-- ══════════════════════════════════════════════════════════
			-- SLIDER ELEMENT
			-- ══════════════════════════════════════════════════════════
			
			function Section:AddSlider(text, min, max, default, callback)
				local value = default or min
				local dragging = false
				
				local Container = Instance.new("Frame")
				Container.Size = UDim2.new(0.94, 0, 0, 65)
				Container.BackgroundColor3 = Theme.ElementBg
				Container.Parent = Items
				AddCorner(Container, 5)
				AddStroke(Container, Theme.Outline, 1.5)
				
				local Label = Instance.new("TextLabel")
				Label.Text = text
				Label.Size = UDim2.new(1, -30, 0, 25)
				Label.Position = UDim2.new(0, 15, 0, 5)
				Label.BackgroundTransparency = 1
				Label.Font = Theme.FontSemibold
				Label.TextSize = Theme.TextSize
				Label.TextColor3 = Theme.Text
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Parent = Container
				
				local ValueLabel = Instance.new("TextLabel")
				ValueLabel.Text = tostring(value)
				ValueLabel.Size = UDim2.new(0, 60, 0, 25)
				ValueLabel.Position = UDim2.new(1, -70, 0, 5)
				ValueLabel.BackgroundTransparency = 1
				ValueLabel.Font = Theme.FontSemibold
				ValueLabel.TextSize = Theme.TextSize
				ValueLabel.TextColor3 = Theme.Accent
				ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
				ValueLabel.Parent = Container
				
				-- Slider Track
				local Track = Instance.new("TextButton")
				Track.Size = UDim2.new(0.9, 0, 0, 10)
				Track.Position = UDim2.new(0.05, 0, 1, -20)
				Track.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
				Track.Text = ""
				Track.AutoButtonColor = false
				Track.Parent = Container
				AddCorner(Track, 5)
				
				-- Slider Fill
				local Fill = Instance.new("Frame")
				Fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
				Fill.BackgroundColor3 = Theme.Accent
				Fill.BorderSizePixel = 0
				Fill.Parent = Track
				AddCorner(Fill, 5)
				
				-- Slider Thumb
				local Thumb = Instance.new("Frame")
				Thumb.Size = UDim2.new(0, 18, 0, 18)
				Thumb.Position = UDim2.new((value - min) / (max - min), -9, 0.5, -9)
				Thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Thumb.Parent = Track
				AddCorner(Thumb, 9)
				
				local thumbShadow = AddStroke(Thumb, Theme.Accent, 2)
				
				local function Update(input)
					local relativeX = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
					local newValue = math.floor(min + ((max - min) * relativeX))
					
					value = newValue
					ValueLabel.Text = tostring(value)
					
					TweenService:Create(Fill, TweenInfo.new(0.05), {
						Size = UDim2.new(relativeX, 0, 1, 0)
					}):Play()
					
					TweenService:Create(Thumb, TweenInfo.new(0.05), {
						Position = UDim2.new(relativeX, -9, 0.5, -9)
					}):Play()
					
					pcall(callback, value)
				end
				
				Track.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or 
					   input.UserInputType == Enum.UserInputType.Touch then
						dragging = true
						Update(input)
						
						TweenService:Create(Thumb, TweenInfo.new(0.1), {
							Size = UDim2.new(0, 22, 0, 22)
						}):Play()
					end
				end)
				
				UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or 
					   input.UserInputType == Enum.UserInputType.Touch then
						dragging = false
						
						TweenService:Create(Thumb, TweenInfo.new(0.1), {
							Size = UDim2.new(0, 18, 0, 18)
						}):Play()
					end
				end)
				
				UserInputService.InputChanged:Connect(function(input)
					if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or 
					   input.UserInputType == Enum.UserInputType.Touch) then
						Update(input)
					end
				end)
				
				return {
					SetValue = function(val)
						value = math.clamp(val, min, max)
						ValueLabel.Text = tostring(value)
						local relativeX = (value - min) / (max - min)
						Fill.Size = UDim2.new(relativeX, 0, 1, 0)
						Thumb.Position = UDim2.new(relativeX, -9, 0.5, -9)
					end
				}
			end
			
			-- ══════════════════════════════════════════════════════════
			-- DROPDOWN ELEMENT
			-- ══════════════════════════════════════════════════════════
			
			function Section:AddDropdown(text, options, default, callback)
				local selected = default or options[1]
				local open = false
				
				local Container = Instance.new("Frame")
				Container.Size = UDim2.new(0.94, 0, 0, 45)
				Container.BackgroundColor3 = Theme.ElementBg
				Container.ClipsDescendants = false
				Container.ZIndex = 2
				Container.Parent = Items
				AddCorner(Container, 5)
				AddStroke(Container, Theme.Outline, 1.5)
				
				local Header = Instance.new("TextButton")
				Header.Size = UDim2.new(1, 0, 0, 45)
				Header.BackgroundTransparency = 1
				Header.Text = ""
				Header.AutoButtonColor = false
				Header.ZIndex = 3
				Header.Parent = Container
				
				local Label = Instance.new("TextLabel")
				Label.Text = text
				Label.Size = UDim2.new(0.6, 0, 1, 0)
				Label.Position = UDim2.new(0, 15, 0, 0)
				Label.BackgroundTransparency = 1
				Label.Font = Theme.FontSemibold
				Label.TextSize = Theme.TextSize
				Label.TextColor3 = Theme.Text
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.ZIndex = 3
				Label.Parent = Header
				
				local SelectedLabel = Instance.new("TextLabel")
				SelectedLabel.Text = selected
				SelectedLabel.Size = UDim2.new(0.35, 0, 1, 0)
				SelectedLabel.Position = UDim2.new(0.65, -30, 0, 0)
				SelectedLabel.BackgroundTransparency = 1
				SelectedLabel.Font = Theme.FontSemibold
				SelectedLabel.TextSize = Theme.TextSize - 1
				SelectedLabel.TextColor3 = Theme.Accent
				SelectedLabel.TextXAlignment = Enum.TextXAlignment.Right
				SelectedLabel.ZIndex = 3
				SelectedLabel.Parent = Header
				
				local Arrow = Instance.new("TextLabel")
				Arrow.Text = "▼"
				Arrow.Size = UDim2.new(0, 20, 1, 0)
				Arrow.Position = UDim2.new(1, -30, 0, 0)
				Arrow.BackgroundTransparency = 1
				Arrow.Font = Theme.Font
				Arrow.TextSize = 12
				Arrow.TextColor3 = Theme.TextDim
				Arrow.ZIndex = 3
				Arrow.Parent = Header
				
				local OptionsFrame = Instance.new("Frame")
				OptionsFrame.Size = UDim2.new(1, 0, 0, 0)
				OptionsFrame.Position = UDim2.new(0, 0, 0, 45)
				OptionsFrame.BackgroundColor3 = Theme.SectionBg
				OptionsFrame.ClipsDescendants = true
				OptionsFrame.ZIndex = 5
				OptionsFrame.Parent = Container
				AddCorner(OptionsFrame, 5)
				AddStroke(OptionsFrame, Theme.Accent, 1.5)
				
				local OptionsLayout = Instance.new("UIListLayout")
				OptionsLayout.Padding = UDim.new(0, 2)
				OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
				OptionsLayout.Parent = OptionsFrame
				
				for _, option in ipairs(options) do
					local OptionBtn = Instance.new("TextButton")
					OptionBtn.Size = UDim2.new(1, 0, 0, 35)
					OptionBtn.BackgroundColor3 = option == selected and Theme.ElementBg or Color3.fromRGB(0, 0, 0, 0)
					OptionBtn.BackgroundTransparency = option == selected and 0 or 1
					OptionBtn.Text = option
					OptionBtn.Font = Theme.FontSemibold
					OptionBtn.TextSize = Theme.TextSize - 1
					OptionBtn.TextColor3 = option == selected and Theme.Accent or Theme.Text
					OptionBtn.AutoButtonColor = false
					OptionBtn.ZIndex = 6
					OptionBtn.Parent = OptionsFrame
					
					OptionBtn.MouseEnter:Connect(function()
						if option ~= selected then
							TweenService:Create(OptionBtn, TweenInfo.new(0.1), {
								BackgroundTransparency = 0,
								BackgroundColor3 = Theme.ElementBg
							}):Play()
						end
					end)
					
					OptionBtn.MouseLeave:Connect(function()
						if option ~= selected then
							TweenService:Create(OptionBtn, TweenInfo.new(0.1), {
								BackgroundTransparency = 1
							}):Play()
						end
					end)
					
					OptionBtn.MouseButton1Click:Connect(function()
						selected = option
						SelectedLabel.Text = option
						
						-- Update all option buttons
						for _, child in ipairs(OptionsFrame:GetChildren()) do
							if child:IsA("TextButton") then
								if child.Text == selected then
									child.BackgroundTransparency = 0
									child.BackgroundColor3 = Theme.ElementBg
									child.TextColor3 = Theme.Accent
								else
									child.BackgroundTransparency = 1
									child.TextColor3 = Theme.Text
								end
							end
						end
						
						-- Close dropdown
						open = false
						TweenService:Create(Container, TweenInfo.new(0.2), {
							Size = UDim2.new(0.94, 0, 0, 45)
						}):Play()
						TweenService:Create(OptionsFrame, TweenInfo.new(0.2), {
							Size = UDim2.new(1, 0, 0, 0)
						}):Play()
						TweenService:Create(Arrow, TweenInfo.new(0.2), {
							Rotation = 0
						}):Play()
						
						pcall(callback, selected)
					end)
				end
				
				Header.MouseButton1Click:Connect(function()
					open = not open
					
					if open then
						local optionsHeight = #options * 37
						TweenService:Create(Container, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
							Size = UDim2.new(0.94, 0, 0, 45 + optionsHeight)
						}):Play()
						TweenService:Create(OptionsFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
							Size = UDim2.new(1, 0, 0, optionsHeight)
						}):Play()
						TweenService:Create(Arrow, TweenInfo.new(0.2), {
							Rotation = 180
						}):Play()
					else
						TweenService:Create(Container, TweenInfo.new(0.2), {
							Size = UDim2.new(0.94, 0, 0, 45)
						}):Play()
						TweenService:Create(OptionsFrame, TweenInfo.new(0.2), {
							Size = UDim2.new(1, 0, 0, 0)
						}):Play()
						TweenService:Create(Arrow, TweenInfo.new(0.2), {
							Rotation = 0
						}):Play()
					end
				end)
				
				return {
					SetValue = function(val)
						selected = val
						SelectedLabel.Text = val
					end
				}
			end
			
			-- ══════════════════════════════════════════════════════════
			-- INPUT/TEXTBOX ELEMENT
			-- ══════════════════════════════════════════════════════════
			
			function Section:AddInput(text, placeholder, callback)
				local Container = Instance.new("Frame")
				Container.Size = UDim2.new(0.94, 0, 0, 70)
				Container.BackgroundColor3 = Theme.ElementBg
				Container.Parent = Items
				AddCorner(Container, 5)
				AddStroke(Container, Theme.Outline, 1.5)
				
				local Label = Instance.new("TextLabel")
				Label.Text = text
				Label.Size = UDim2.new(1, -30, 0, 25)
				Label.Position = UDim2.new(0, 15, 0, 5)
				Label.BackgroundTransparency = 1
				Label.Font = Theme.FontSemibold
				Label.TextSize = Theme.TextSize
				Label.TextColor3 = Theme.Text
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Parent = Container
				
				local InputBox = Instance.new("TextBox")
				InputBox.Size = UDim2.new(0.9, 0, 0, 30)
				InputBox.Position = UDim2.new(0.05, 0, 1, -35)
				InputBox.BackgroundColor3 = Color3.fromRGB(25, 25, 31)
				InputBox.PlaceholderText = placeholder or "Enter text..."
				InputBox.PlaceholderColor3 = Theme.TextDark
				InputBox.Text = ""
				InputBox.Font = Theme.FontSemibold
				InputBox.TextSize = Theme.TextSize - 1
				InputBox.TextColor3 = Theme.Text
				InputBox.ClearTextOnFocus = false
				InputBox.Parent = Container
				AddCorner(InputBox, 4)
				
				local inputStroke = AddStroke(InputBox, Theme.Outline, 1.5)
				
				InputBox.Focused:Connect(function()
					TweenService:Create(inputStroke, TweenInfo.new(0.2), {
						Color = Theme.Accent
					}):Play()
				end)
				
				InputBox.FocusLost:Connect(function(enterPressed)
					TweenService:Create(inputStroke, TweenInfo.new(0.2), {
						Color = Theme.Outline
					}):Play()
					
					if enterPressed then
						pcall(callback, InputBox.Text)
					end
				end)
				
				return {
					SetValue = function(val)
						InputBox.Text = val
					end
				}
			end
			
			-- ══════════════════════════════════════════════════════════
			-- LABEL ELEMENT
			-- ══════════════════════════════════════════════════════════
			
			function Section:AddLabel(text)
				local Label = Instance.new("TextLabel")
				Label.Size = UDim2.new(0.94, 0, 0, 35)
				Label.BackgroundColor3 = Theme.ElementBg
				Label.BackgroundTransparency = 0.5
				Label.Text = text
				Label.Font = Theme.FontSemibold
				Label.TextSize = Theme.TextSize
				Label.TextColor3 = Theme.TextDim
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Parent = Items
				AddCorner(Label, 5)
				AddPadding(Label, {Left = 15, Right = 15})
				
				return {
					SetText = function(newText)
						Label.Text = newText
					end
				}
			end
			
			return Section
		end
		
		return Tab
	end
	
	return Window
end

-- ══════════════════════════════════════════════════════════
-- NOTIFICATION SYSTEM
-- ══════════════════════════════════════════════════════════

function JobwareLib:Notify(config)
	local title = config.Title or "Notification"
	local message = config.Message or ""
	local duration = config.Duration or 3
	local type = config.Type or "info" -- info, success, warning, error
	
	local notifGui = CoreGui:FindFirstChild("JobwareNotifications")
	if not notifGui then
		notifGui = Instance.new("ScreenGui")
		notifGui.Name = "JobwareNotifications"
		notifGui.Parent = CoreGui
		notifGui.ResetOnSpawn = false
		notifGui.IgnoreGuiInset = true
		notifGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		
		local container = Instance.new("Frame")
		container.Name = "Container"
		container.Size = UDim2.new(0.3, 0, 0.15, 0)
		container.Position = UDim2.new(0.99, 0, 0.99, 0)
		container.AnchorPoint = Vector2.new(1, 1)
		container.BackgroundTransparency = 1
		container.Parent = notifGui
		
		local layout = Instance.new("UIListLayout")
		layout.Padding = UDim.new(0, 8)
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
		layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Parent = container
	end
	
	local container = notifGui.Container
	
	local typeColors = {
		info = Theme.Accent,
		success = Color3.fromRGB(80, 200, 120),
		warning = Color3.fromRGB(255, 180, 60),
		error = Color3.fromRGB(255, 80, 80)
	}
	
	local accentColor = typeColors[type] or Theme.Accent
	
	local Notif = Instance.new("Frame")
	Notif.Size = UDim2.new(0.95, 0, 0, 0)
	Notif.BackgroundColor3 = Theme.SectionBg
	Notif.BackgroundTransparency = 0.1
	Notif.Parent = container
	AddCorner(Notif, 6)
	AddStroke(Notif, accentColor, 2)
	
	local AccentBar = Instance.new("Frame")
	AccentBar.Size = UDim2.new(0, 4, 1, 0)
	AccentBar.BackgroundColor3 = accentColor
	AccentBar.BorderSizePixel = 0
	AccentBar.Parent = Notif
	
	local Title = Instance.new("TextLabel")
	Title.Text = title
	Title.Size = UDim2.new(1, -50, 0, 20)
	Title.Position = UDim2.new(0, 15, 0, 8)
	Title.BackgroundTransparency = 1
	Title.Font = Theme.Font
	Title.TextSize = 14
	Title.TextColor3 = Theme.Text
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Parent = Notif
	
	local Message = Instance.new("TextLabel")
	Message.Text = message
	Message.Size = UDim2.new(1, -50, 0, 18)
	Message.Position = UDim2.new(0, 15, 0, 30)
	Message.BackgroundTransparency = 1
	Message.Font = Theme.FontSemibold
	Message.TextSize = 12
	Message.TextColor3 = Theme.TextDim
	Message.TextXAlignment = Enum.TextXAlignment.Left
	Message.TextWrapped = true
	Message.Parent = Notif
	
	local CloseBtn = Instance.new("TextButton")
	CloseBtn.Size = UDim2.new(0, 30, 0, 30)
	CloseBtn.Position = UDim2.new(1, -35, 0, 5)
	CloseBtn.BackgroundTransparency = 1
	CloseBtn.Text = "×"
	CloseBtn.Font = Theme.Font
	CloseBtn.TextSize = 20
	CloseBtn.TextColor3 = Theme.TextDim
	CloseBtn.Parent = Notif
	
	-- Animate in
	TweenService:Create(Notif, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
		Size = UDim2.new(0.95, 0, 0, 65)
	}):Play()
	
	-- Auto close
	task.delay(duration, function()
		TweenService:Create(Notif, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Size = UDim2.new(0.95, 0, 0, 0),
			BackgroundTransparency = 1
		}):Play()
		
		task.wait(0.2)
		Notif:Destroy()
	end)
	
	CloseBtn.MouseButton1Click:Connect(function()
		TweenService:Create(Notif, TweenInfo.new(0.2), {
			Size = UDim2.new(0.95, 0, 0, 0),
			BackgroundTransparency = 1
		}):Play()
		
		task.wait(0.2)
		Notif:Destroy()
	end)
end

return JobwareLib
