--[[
    ╔══════════════════════════════════════════════════════════╗
    ║         JOBWARE V5 ULTRA - NEVERLOSE PREMIUM            ║
    ║     Mobile-Optimized · Advanced Animations · Pro UI    ║
    ║           Made by Jobware Development Team               ║
    ╚══════════════════════════════════════════════════════════╝
    
    Features:
    - NeverLose/Onetap inspired design
    - Smooth animations & transitions
    - Mobile-optimized touch controls
    - RGB gradient effects
    - Advanced UI elements
    - Notification system
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local JobwareLib = {}

-- ══════════════════════════════════════════════════════════
-- THEME SETTINGS (NeverLose Premium)
-- ══════════════════════════════════════════════════════════
local Theme = {
	-- Core Colors (Darker than before for premium look)
	MainBg       = Color3.fromRGB(8, 8, 12),
	SidebarBg    = Color3.fromRGB(12, 12, 16),
	SectionBg    = Color3.fromRGB(16, 16, 22),
	ElementBg    = Color3.fromRGB(24, 24, 30),
	
	-- Accent Colors (NeverLose Blue)
	Accent       = Color3.fromRGB(70, 150, 255),
	AccentDark   = Color3.fromRGB(50, 120, 220),
	AccentHover  = Color3.fromRGB(90, 170, 255),
	AccentLight  = Color3.fromRGB(110, 190, 255),
	
	-- Text
	Text         = Color3.fromRGB(255, 255, 255),
	TextDim      = Color3.fromRGB(140, 140, 150),
	TextDark     = Color3.fromRGB(90, 90, 100),
	
	-- Borders
	Outline      = Color3.fromRGB(35, 35, 45),
	OutlineLight = Color3.fromRGB(50, 50, 65),
	
	-- Status Colors
	Success      = Color3.fromRGB(70, 200, 120),
	Warning      = Color3.fromRGB(255, 170, 50),
	Error        = Color3.fromRGB(255, 70, 70),
	
	-- Fonts
	Font         = Enum.Font.GothamBold,
	FontSemi     = Enum.Font.GothamSemibold,
	TextSize     = 15,
	TitleSize    = 20,
	
	-- Animation
	AnimSpeed    = 0.25,
	HoverSpeed   = 0.12
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
	stroke.Thickness = thickness or 1.5
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

local function AddGradient(instance, rotation, colors)
	local gradient = Instance.new("UIGradient")
	gradient.Rotation = rotation or 90
	if colors then
		gradient.Color = ColorSequence.new(colors)
	end
	gradient.Parent = instance
	return gradient
end

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
			object.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
end

local function AddHoverEffect(button, stroke, brighten)
	if not stroke then return end
	
	local originalColor = stroke.Color
	local hoverColor = brighten and Theme.AccentLight or Theme.AccentHover
	
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

local function CreateRipple(parent, position)
	local ripple = Instance.new("Frame")
	ripple.Name = "Ripple"
	ripple.Size = UDim2.new(0, 0, 0, 0)
	ripple.Position = UDim2.new(0, position.X - parent.AbsolutePosition.X, 0, position.Y - parent.AbsolutePosition.Y)
	ripple.AnchorPoint = Vector2.new(0.5, 0.5)
	ripple.BackgroundColor3 = Theme.Accent
	ripple.BackgroundTransparency = 0.6
	ripple.BorderSizePixel = 0
	ripple.ZIndex = 100
	ripple.Parent = parent
	AddCorner(ripple, 999)
	
	local maxSize = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 2.5
	
	local tween = TweenService:Create(ripple, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, maxSize, 0, maxSize),
		BackgroundTransparency = 1
	})
	
	tween:Play()
	tween.Completed:Connect(function()
		ripple:Destroy()
	end)
end

-- ══════════════════════════════════════════════════════════
-- MAIN WINDOW CREATION
-- ══════════════════════════════════════════════════════════

function JobwareLib:CreateWindow(config)
	local Window = {}
	local hubName = type(config) == "string" and config or (config.Name or "JOBWARE")
	local prefix = type(config) == "table" and (config.Prefix or "PREMIUM") or "PREMIUM"
	
	-- Cleanup
	if CoreGui:FindFirstChild("JobwareV5Ultra") then 
		CoreGui:FindFirstChild("JobwareV5Ultra"):Destroy() 
	end
	
	-- ScreenGui
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "JobwareV5Ultra"
	ScreenGui.Parent = CoreGui
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.ResetOnSpawn = false
	ScreenGui.IgnoreGuiInset = true
	
	-- ══════════════════════════════════════════════════════════
	-- MOBILE TOGGLE BUTTON (Premium Design)
	-- ══════════════════════════════════════════════════════════
	
	local ToggleFrame = Instance.new("Frame")
	ToggleFrame.Name = "MobileToggle"
	ToggleFrame.Size = UDim2.new(0, 75, 0, 75)
	ToggleFrame.Position = UDim2.new(0.05, 0, 0.15, 0)
	ToggleFrame.BackgroundColor3 = Theme.MainBg
	ToggleFrame.Parent = ScreenGui
	AddCorner(ToggleFrame, 38)
	
	local toggleStroke = AddStroke(ToggleFrame, Theme.Accent, 3)
	MakeDraggable(ToggleFrame, ToggleFrame)
	
	-- Glow Effect
	local ToggleGlow = Instance.new("ImageLabel")
	ToggleGlow.Size = UDim2.new(1.3, 0, 1.3, 0)
	ToggleGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
	ToggleGlow.AnchorPoint = Vector2.new(0.5, 0.5)
	ToggleGlow.BackgroundTransparency = 1
	ToggleGlow.Image = "rbxassetid://5028857084"
	ToggleGlow.ImageColor3 = Theme.Accent
	ToggleGlow.ImageTransparency = 0.7
	ToggleGlow.ZIndex = 0
	ToggleGlow.Parent = ToggleFrame
	
	local ToggleIcon = Instance.new("TextLabel")
	ToggleIcon.Size = UDim2.new(1, 0, 1, 0)
	ToggleIcon.BackgroundTransparency = 1
	ToggleIcon.Text = "JW"
	ToggleIcon.Font = Theme.Font
	ToggleIcon.TextSize = 26
	ToggleIcon.TextColor3 = Theme.Accent
	ToggleIcon.ZIndex = 2
	ToggleIcon.Parent = ToggleFrame
	
	local ToggleBtn = Instance.new("TextButton")
	ToggleBtn.Size = UDim2.new(1, 0, 1, 0)
	ToggleBtn.BackgroundTransparency = 1
	ToggleBtn.Text = ""
	ToggleBtn.ZIndex = 3
	ToggleBtn.Parent = ToggleFrame
	
	-- Pulse + Glow Animation
	local pulseActive = true
	task.spawn(function()
		while pulseActive and ToggleFrame.Parent do
			TweenService:Create(toggleStroke, TweenInfo.new(1.8, Enum.EasingStyle.Sine), {
				Thickness = 4
			}):Play()
			TweenService:Create(ToggleGlow, TweenInfo.new(1.8, Enum.EasingStyle.Sine), {
				ImageTransparency = 0.4
			}):Play()
			wait(1.8)
			if not pulseActive then break end
			TweenService:Create(toggleStroke, TweenInfo.new(1.8, Enum.EasingStyle.Sine), {
				Thickness = 3
			}):Play()
			TweenService:Create(ToggleGlow, TweenInfo.new(1.8, Enum.EasingStyle.Sine), {
				ImageTransparency = 0.7
			}):Play()
			wait(1.8)
		end
	end)
	
	-- ══════════════════════════════════════════════════════════
	-- MAIN FRAME (Premium NeverLose Style)
	-- ══════════════════════════════════════════════════════════
	
	local MainFrame = Instance.new("Frame")
	MainFrame.Name = "MainFrame"
	MainFrame.Size = UDim2.new(0.82, 0, 0.78, 0)
	MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	MainFrame.BackgroundColor3 = Theme.MainBg
	MainFrame.Visible = false
	MainFrame.ClipsDescendants = true
	MainFrame.Parent = ScreenGui
	AddCorner(MainFrame, 10)
	
	local mainStroke = AddStroke(MainFrame, Theme.Outline, 2)
	
	-- Shadow/Glow
	local MainGlow = Instance.new("ImageLabel")
	MainGlow.Size = UDim2.new(1.1, 0, 1.1, 0)
	MainGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
	MainGlow.AnchorPoint = Vector2.new(0.5, 0.5)
	MainGlow.BackgroundTransparency = 1
	MainGlow.Image = "rbxassetid://5028857084"
	MainGlow.ImageColor3 = Theme.Accent
	MainGlow.ImageTransparency = 0.85
	MainGlow.ZIndex = 0
	MainGlow.Parent = MainFrame
	
	-- Toggle Open/Close
	ToggleBtn.MouseButton1Click:Connect(function()
		MainFrame.Visible = not MainFrame.Visible
		pulseActive = not MainFrame.Visible
		
		if MainFrame.Visible then
			MainFrame.Size = UDim2.new(0, 0, 0, 0)
			MainFrame.BackgroundTransparency = 1
			mainStroke.Transparency = 1
			
			TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = UDim2.new(0.82, 0, 0.78, 0),
				BackgroundTransparency = 0
			}):Play()
			
			TweenService:Create(mainStroke, TweenInfo.new(0.35), {
				Transparency = 0
			}):Play()
		else
			TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
				Size = UDim2.new(0, 0, 0, 0),
				BackgroundTransparency = 1
			}):Play()
			
			TweenService:Create(mainStroke, TweenInfo.new(0.25), {
				Transparency = 1
			}):Play()
		end
	end)
	
	-- ══════════════════════════════════════════════════════════
	-- TOP BAR (NeverLose Premium Design)
	-- ══════════════════════════════════════════════════════════
	
	local TopBar = Instance.new("Frame")
	TopBar.Name = "TopBar"
	TopBar.Size = UDim2.new(1, 0, 0, 60)
	TopBar.BackgroundColor3 = Theme.SidebarBg
	TopBar.BorderSizePixel = 0
	TopBar.Parent = MainFrame
	AddCorner(TopBar, 10)
	
	local TopBarFill = Instance.new("Frame")
	TopBarFill.Size = UDim2.new(1, 0, 0.5, 0)
	TopBarFill.Position = UDim2.new(0, 0, 0.5, 0)
	TopBarFill.BackgroundColor3 = Theme.SidebarBg
	TopBarFill.BorderSizePixel = 0
	TopBarFill.Parent = TopBar
	
	-- RGB Accent Line (NeverLose Style)
	local AccentLine = Instance.new("Frame")
	AccentLine.Size = UDim2.new(1, 0, 0, 3)
	AccentLine.BackgroundColor3 = Theme.Accent
	AccentLine.BorderSizePixel = 0
	AccentLine.Parent = TopBar
	
	local gradient = AddGradient(AccentLine, 0, {
		Theme.Accent,
		Theme.AccentHover,
		Theme.Accent
	})
	
	-- Animated Gradient
	task.spawn(function()
		while AccentLine.Parent do
			TweenService:Create(gradient, TweenInfo.new(3.5, Enum.EasingStyle.Linear), {
				Offset = Vector2.new(1, 0)
			}):Play()
			wait(3.5)
			if not AccentLine.Parent then break end
			gradient.Offset = Vector2.new(-1, 0)
		end
	end)
	
	-- Logo/Icon (Left)
	local Logo = Instance.new("Frame")
	Logo.Size = UDim2.new(0, 35, 0, 35)
	Logo.Position = UDim2.new(0, 15, 0.5, -17.5)
	Logo.BackgroundColor3 = Theme.Accent
	Logo.Parent = TopBar
	AddCorner(Logo, 6)
	
	local LogoText = Instance.new("TextLabel")
	LogoText.Size = UDim2.new(1, 0, 1, 0)
	LogoText.BackgroundTransparency = 1
	LogoText.Text = "JW"
	LogoText.Font = Theme.Font
	LogoText.TextSize = 16
	LogoText.TextColor3 = Color3.fromRGB(255, 255, 255)
	LogoText.Parent = Logo
	
	-- Title
	local Title = Instance.new("TextLabel")
	Title.Text = hubName:upper()
	Title.Size = UDim2.new(0.5, 0, 0.5, 0)
	Title.Position = UDim2.new(0, 60, 0, 8)
	Title.BackgroundTransparency = 1
	Title.Font = Theme.Font
	Title.TextSize = Theme.TitleSize
	Title.TextColor3 = Theme.Text
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Parent = TopBar
	
	-- Subtitle/Prefix
	local Subtitle = Instance.new("TextLabel")
	Subtitle.Text = prefix
	Subtitle.Size = UDim2.new(0.5, 0, 0.4, 0)
	Subtitle.Position = UDim2.new(0, 60, 0.5, 2)
	Subtitle.BackgroundTransparency = 1
	Subtitle.Font = Theme.FontSemi
	Subtitle.TextSize = 12
	Subtitle.TextColor3 = Theme.Accent
	Subtitle.TextXAlignment = Enum.TextXAlignment.Left
	Subtitle.Parent = TopBar
	
	-- Minimize Button
	local MinimizeBtn = Instance.new("TextButton")
	MinimizeBtn.Size = UDim2.new(0, 45, 0, 45)
	MinimizeBtn.Position = UDim2.new(1, -100, 0.5, -22.5)
	MinimizeBtn.BackgroundTransparency = 1
	MinimizeBtn.Text = "−"
	MinimizeBtn.Font = Theme.Font
	MinimizeBtn.TextSize = 28
	MinimizeBtn.TextColor3 = Theme.TextDim
	MinimizeBtn.Parent = TopBar
	
	MinimizeBtn.MouseButton1Click:Connect(function()
		TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
			Size = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1
		}):Play()
		TweenService:Create(mainStroke, TweenInfo.new(0.25), {
			Transparency = 1
		}):Play()
		wait(0.25)
		MainFrame.Visible = false
		pulseActive = true
	end)
	
	MinimizeBtn.MouseEnter:Connect(function()
		TweenService:Create(MinimizeBtn, TweenInfo.new(0.1), {TextColor3 = Theme.Accent}):Play()
	end)
	
	MinimizeBtn.MouseLeave:Connect(function()
		TweenService:Create(MinimizeBtn, TweenInfo.new(0.1), {TextColor3 = Theme.TextDim}):Play()
	end)
	
	-- Close Button
	local CloseBtn = Instance.new("TextButton")
	CloseBtn.Size = UDim2.new(0, 45, 0, 45)
	CloseBtn.Position = UDim2.new(1, -50, 0.5, -22.5)
	CloseBtn.BackgroundTransparency = 1
	CloseBtn.Text = "×"
	CloseBtn.Font = Theme.Font
	CloseBtn.TextSize = 32
	CloseBtn.TextColor3 = Theme.TextDim
	CloseBtn.Parent = TopBar
	
	CloseBtn.MouseButton1Click:Connect(function()
		TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
			Size = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 1
		}):Play()
		TweenService:Create(mainStroke, TweenInfo.new(0.25), {
			Transparency = 1
		}):Play()
		wait(0.25)
		MainFrame.Visible = false
		pulseActive = true
	end)
	
	CloseBtn.MouseEnter:Connect(function()
		TweenService:Create(CloseBtn, TweenInfo.new(0.1), {TextColor3 = Theme.Error}):Play()
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
	Sidebar.Size = UDim2.new(0.28, 0, 1, -60)
	Sidebar.Position = UDim2.new(0, 0, 0, 60)
	Sidebar.BackgroundColor3 = Theme.SidebarBg
	Sidebar.BorderSizePixel = 0
	Sidebar.ScrollBarThickness = 0
	Sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
	Sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
	Sidebar.Parent = MainFrame
	
	local SidebarLayout = Instance.new("UIListLayout")
	SidebarLayout.Padding = UDim.new(0, 12)
	SidebarLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
	SidebarLayout.Parent = Sidebar
	
	AddPadding(Sidebar, {Top = 18, Bottom = 18})
	
	-- Divider
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
	Content.Size = UDim2.new(0.72, 0, 1, -60)
	Content.Position = UDim2.new(0.28, 0, 0, 60)
	Content.BackgroundTransparency = 1
	Content.Parent = MainFrame
	
	local Tabs = {}
	
	-- ══════════════════════════════════════════════════════════
	-- CREATE TAB
	-- ══════════════════════════════════════════════════════════
	
	function Window:CreateTab(name)
		local Tab = {}
		
		-- Tab Button
		local TabBtn = Instance.new("TextButton")
		TabBtn.Name = name.."Tab"
		TabBtn.Size = UDim2.new(0.90, 0, 0, 58)
		TabBtn.BackgroundColor3 = Theme.SectionBg
		TabBtn.BackgroundTransparency = 1
		TabBtn.Text = ""
		TabBtn.AutoButtonColor = false
		TabBtn.Parent = Sidebar
		AddCorner(TabBtn, 8)
		
		local tabStroke = AddStroke(TabBtn, Theme.Outline, 1.5)
		
		-- Tab Label
		local TabLabel = Instance.new("TextLabel")
		TabLabel.Text = name
		TabLabel.Size = UDim2.new(1, -50, 1, 0)
		TabLabel.Position = UDim2.new(0, 15, 0, 0)
		TabLabel.BackgroundTransparency = 1
		TabLabel.Font = Theme.FontSemi
		TabLabel.TextSize = 17
		TabLabel.TextColor3 = Theme.TextDim
		TabLabel.TextXAlignment = Enum.TextXAlignment.Left
		TabLabel.Parent = TabBtn
		
		-- Chevron Icon
		local Chevron = Instance.new("TextLabel")
		Chevron.Text = "›"
		Chevron.Size = UDim2.new(0, 30, 1, 0)
		Chevron.Position = UDim2.new(1, -35, 0, 0)
		Chevron.BackgroundTransparency = 1
		Chevron.Font = Theme.Font
		Chevron.TextSize = 22
		Chevron.TextColor3 = Theme.TextDim
		Chevron.TextTransparency = 1
		Chevron.Parent = TabBtn
		
		-- Active Indicator
		local ActiveLine = Instance.new("Frame")
		ActiveLine.Size = UDim2.new(0, 4, 0.65, 0)
		ActiveLine.Position = UDim2.new(0, 0, 0.175, 0)
		ActiveLine.BackgroundColor3 = Theme.Accent
		ActiveLine.BackgroundTransparency = 1
		ActiveLine.BorderSizePixel = 0
		ActiveLine.Parent = TabBtn
		AddCorner(ActiveLine, 2)
		
		-- Page
		local Page = Instance.new("ScrollingFrame")
		Page.Name = name.."Page"
		Page.Size = UDim2.new(1, 0, 1, 0)
		Page.BackgroundTransparency = 1
		Page.Visible = false
		Page.ScrollBarThickness = 5
		Page.ScrollBarImageColor3 = Theme.Accent
		Page.CanvasSize = UDim2.new(0, 0, 0, 0)
		Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
		Page.Parent = Content
		
		local PageLayout = Instance.new("UIListLayout")
		PageLayout.Padding = UDim.new(0, 20)
		PageLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
		PageLayout.Parent = Page
		
		AddPadding(Page, {Top = 20, Bottom = 20})
		
		-- Tab Click
		TabBtn.MouseButton1Click:Connect(function()
			CreateRipple(TabBtn, UserInputService:GetMouseLocation())
			
			-- Deactivate all
			for _, tab in pairs(Tabs) do
				tab.Page.Visible = false
				
				TweenService:Create(tab.Label, TweenInfo.new(Theme.AnimSpeed), {
					TextColor3 = Theme.TextDim
				}):Play()
				
				TweenService:Create(tab.Line, TweenInfo.new(Theme.AnimSpeed), {
					BackgroundTransparency = 1
				}):Play()
				
				TweenService:Create(tab.Btn, TweenInfo.new(Theme.AnimSpeed), {
					BackgroundTransparency = 1
				}):Play()
				
				TweenService:Create(tab.Stroke, TweenInfo.new(Theme.AnimSpeed), {
					Color = Theme.Outline
				}):Play()
				
				TweenService:Create(tab.Chevron, TweenInfo.new(Theme.AnimSpeed), {
					TextTransparency = 1
				}):Play()
			end
			
			-- Activate this tab
			Page.Visible = true
			
			TweenService:Create(TabLabel, TweenInfo.new(Theme.AnimSpeed), {
				TextColor3 = Theme.Text
			}):Play()
			
			TweenService:Create(ActiveLine, TweenInfo.new(Theme.AnimSpeed), {
				BackgroundTransparency = 0
			}):Play()
			
			TweenService:Create(TabBtn, TweenInfo.new(Theme.AnimSpeed), {
				BackgroundTransparency = 0
			}):Play()
			
			TweenService:Create(tabStroke, TweenInfo.new(Theme.AnimSpeed), {
				Color = Theme.Accent
			}):Play()
			
			TweenService:Create(Chevron, TweenInfo.new(Theme.AnimSpeed), {
				TextTransparency = 0,
				TextColor3 = Theme.Accent
			}):Play()
		end)
		
		-- Hover
		AddHoverEffect(TabBtn, tabStroke, false)
		
		table.insert(Tabs, {
			Btn = TabBtn,
			Page = Page,
			Label = TabLabel,
			Line = ActiveLine,
			Stroke = tabStroke,
			Chevron = Chevron
		})
		
		-- Auto-activate first
		if #Tabs == 1 then
			Page.Visible = true
			TabLabel.TextColor3 = Theme.Text
			ActiveLine.BackgroundTransparency = 0
			TabBtn.BackgroundTransparency = 0
			tabStroke.Color = Theme.Accent
			Chevron.TextTransparency = 0
			Chevron.TextColor3 = Theme.Accent
		end
		
		-- ══════════════════════════════════════════════════════════
		-- CREATE SECTION
		-- ══════════════════════════════════════════════════════════
		
		function Tab:CreateSection(sectionName)
			local Section = {}
			
			local SectionFrame = Instance.new("Frame")
			SectionFrame.Name = sectionName.."Section"
			SectionFrame.Size = UDim2.new(0.95, 0, 0, 0)
			SectionFrame.BackgroundColor3 = Theme.SectionBg
			SectionFrame.AutomaticSize = Enum.AutomaticSize.Y
			SectionFrame.Parent = Page
			AddCorner(SectionFrame, 8)
			AddStroke(SectionFrame, Theme.Outline, 1.5)
			
			-- Section Header
			local SectionHeader = Instance.new("Frame")
			SectionHeader.Size = UDim2.new(1, 0, 0, 50)
			SectionHeader.BackgroundTransparency = 1
			SectionHeader.Parent = SectionFrame
			
			local SectionTitle = Instance.new("TextLabel")
			SectionTitle.Text = sectionName
			SectionTitle.Size = UDim2.new(1, -30, 1, 0)
			SectionTitle.Position = UDim2.new(0, 18, 0, 0)
			SectionTitle.BackgroundTransparency = 1
			SectionTitle.Font = Theme.FontSemi
			SectionTitle.TextSize = 18
			SectionTitle.TextColor3 = Theme.Accent
			SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
			SectionTitle.Parent = SectionHeader
			
			-- Divider
			local Divider = Instance.new("Frame")
			Divider.Size = UDim2.new(0.96, 0, 0, 1.5)
			Divider.Position = UDim2.new(0.02, 0, 1, -1)
			Divider.BackgroundColor3 = Theme.Outline
			Divider.BorderSizePixel = 0
			Divider.Parent = SectionHeader
			
			-- Items Container
			local Items = Instance.new("Frame")
			Items.Size = UDim2.new(1, 0, 0, 0)
			Items.Position = UDim2.new(0, 0, 0, 50)
			Items.BackgroundTransparency = 1
			Items.AutomaticSize = Enum.AutomaticSize.Y
			Items.Parent = SectionFrame
			
			local ItemLayout = Instance.new("UIListLayout")
			ItemLayout.Padding = UDim.new(0, 14)
			ItemLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
			ItemLayout.SortOrder = Enum.SortOrder.LayoutOrder
			ItemLayout.Parent = Items
			
			AddPadding(Items, {Top = 16, Bottom = 20})
			
			-- ══════════════════════════════════════════════════════════
			-- BUTTON ELEMENT
			-- ══════════════════════════════════════════════════════════
			
			function Section:AddButton(text, callback)
				local Button = Instance.new("TextButton")
				Button.Size = UDim2.new(0.93, 0, 0, 52)
				Button.BackgroundColor3 = Theme.ElementBg
				Button.Text = text
				Button.Font = Theme.FontSemi
				Button.TextSize = Theme.TextSize
				Button.TextColor3 = Theme.Text
				Button.AutoButtonColor = false
				Button.Parent = Items
				AddCorner(Button, 7)
				
				local btnStroke = AddStroke(Button, Theme.Outline, 1.5)
				AddHoverEffect(Button, btnStroke, false)
				
				Button.MouseButton1Click:Connect(function()
					CreateRipple(Button, UserInputService:GetMouseLocation())
					
					TweenService:Create(Button, TweenInfo.new(0.1), {
						BackgroundColor3 = Theme.Accent
					}):Play()
					
					TweenService:Create(btnStroke, TweenInfo.new(0.1), {
						Color = Theme.AccentLight
					}):Play()
					
					task.wait(0.15)
					
					TweenService:Create(Button, TweenInfo.new(0.2), {
						BackgroundColor3 = Theme.ElementBg
					}):Play()
					
					TweenService:Create(btnStroke, TweenInfo.new(0.2), {
						Color = Theme.Outline
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
				Container.Size = UDim2.new(0.93, 0, 0, 52)
				Container.BackgroundColor3 = Theme.ElementBg
				Container.Text = ""
				Container.AutoButtonColor = false
				Container.Parent = Items
				AddCorner(Container, 7)
				
				local containerStroke = AddStroke(Container, Theme.Outline, 1.5)
				AddHoverEffect(Container, containerStroke, false)
				
				local Label = Instance.new("TextLabel")
				Label.Text = text
				Label.Size = UDim2.new(0.63, 0, 1, 0)
				Label.Position = UDim2.new(0, 18, 0, 0)
				Label.BackgroundTransparency = 1
				Label.Font = Theme.FontSemi
				Label.TextSize = Theme.TextSize
				Label.TextColor3 = Theme.Text
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Parent = Container
				
				-- Switch
				local Switch = Instance.new("Frame")
				Switch.Size = UDim2.new(0, 58, 0, 30)
				Switch.Position = UDim2.new(1, -70, 0.5, -15)
				Switch.BackgroundColor3 = toggled and Theme.Accent or Color3.fromRGB(35, 35, 45)
				Switch.Parent = Container
				AddCorner(Switch, 15)
				
				local switchStroke = AddStroke(Switch, toggled and Theme.AccentLight or Theme.Outline, 1)
				
				-- Dot
				local Dot = Instance.new("Frame")
				Dot.Size = UDim2.new(0, 24, 0, 24)
				Dot.Position = toggled and UDim2.new(1, -27, 0.5, -12) or UDim2.new(0, 3, 0.5, -12)
				Dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Dot.Parent = Switch
				AddCorner(Dot, 12)
				
				local dotShadow = Instance.new("ImageLabel")
				dotShadow.Size = UDim2.new(1.4, 0, 1.4, 0)
				dotShadow.Position = UDim2.new(0.5, 0, 0.5, 0)
				dotShadow.AnchorPoint = Vector2.new(0.5, 0.5)
				dotShadow.BackgroundTransparency = 1
				dotShadow.Image = "rbxassetid://5028857084"
				dotShadow.ImageColor3 = Color3.fromRGB(255, 255, 255)
				dotShadow.ImageTransparency = 0.8
				dotShadow.ZIndex = 0
				dotShadow.Parent = Dot
				
				Container.MouseButton1Click:Connect(function()
					toggled = not toggled
					
					local goalPos = toggled and UDim2.new(1, -27, 0.5, -12) or UDim2.new(0, 3, 0.5, -12)
					local goalColor = toggled and Theme.Accent or Color3.fromRGB(35, 35, 45)
					local strokeColor = toggled and Theme.AccentLight or Theme.Outline
					
					TweenService:Create(Dot, TweenInfo.new(Theme.AnimSpeed, Enum.EasingStyle.Quad), {
						Position = goalPos
					}):Play()
					
					TweenService:Create(Switch, TweenInfo.new(Theme.AnimSpeed), {
						BackgroundColor3 = goalColor
					}):Play()
					
					TweenService:Create(switchStroke, TweenInfo.new(Theme.AnimSpeed), {
						Color = strokeColor
					}):Play()
					
					pcall(callback, toggled)
				end)
				
				return {
					SetValue = function(value)
						toggled = value
						local goalPos = toggled and UDim2.new(1, -27, 0.5, -12) or UDim2.new(0, 3, 0.5, -12)
						local goalColor = toggled and Theme.Accent or Color3.fromRGB(35, 35, 45)
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
				Container.Size = UDim2.new(0.93, 0, 0, 75)
				Container.BackgroundColor3 = Theme.ElementBg
				Container.Parent = Items
				AddCorner(Container, 7)
				AddStroke(Container, Theme.Outline, 1.5)
				
				local Label = Instance.new("TextLabel")
				Label.Text = text
				Label.Size = UDim2.new(1, -30, 0, 30)
				Label.Position = UDim2.new(0, 18, 0, 8)
				Label.BackgroundTransparency = 1
				Label.Font = Theme.FontSemi
				Label.TextSize = Theme.TextSize
				Label.TextColor3 = Theme.Text
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Parent = Container
				
				local ValueLabel = Instance.new("TextLabel")
				ValueLabel.Text = tostring(value)
				ValueLabel.Size = UDim2.new(0, 80, 0, 30)
				ValueLabel.Position = UDim2.new(1, -90, 0, 8)
				ValueLabel.BackgroundTransparency = 1
				ValueLabel.Font = Theme.FontSemi
				ValueLabel.TextSize = Theme.TextSize
				ValueLabel.TextColor3 = Theme.Accent
				ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
				ValueLabel.Parent = Container
				
				-- Track
				local Track = Instance.new("TextButton")
				Track.Size = UDim2.new(0.88, 0, 0, 13)
				Track.Position = UDim2.new(0.06, 0, 1, -24)
				Track.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
				Track.Text = ""
				Track.AutoButtonColor = false
				Track.Parent = Container
				AddCorner(Track, 7)
				AddStroke(Track, Theme.Outline, 1)
				
				-- Fill
				local Fill = Instance.new("Frame")
				Fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
				Fill.BackgroundColor3 = Theme.Accent
				Fill.BorderSizePixel = 0
				Fill.Parent = Track
				AddCorner(Fill, 7)
				
				local fillGradient = AddGradient(Fill, 0, {
					Theme.AccentDark,
					Theme.Accent
				})
				
				-- Thumb
				local Thumb = Instance.new("Frame")
				Thumb.Size = UDim2.new(0, 22, 0, 22)
				Thumb.Position = UDim2.new((value - min) / (max - min), -11, 0.5, -11)
				Thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Thumb.Parent = Track
				AddCorner(Thumb, 11)
				
				local thumbStroke = AddStroke(Thumb, Theme.Accent, 2)
				
				local thumbGlow = Instance.new("ImageLabel")
				thumbGlow.Size = UDim2.new(1.6, 0, 1.6, 0)
				thumbGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
				thumbGlow.AnchorPoint = Vector2.new(0.5, 0.5)
				thumbGlow.BackgroundTransparency = 1
				thumbGlow.Image = "rbxassetid://5028857084"
				thumbGlow.ImageColor3 = Theme.Accent
				thumbGlow.ImageTransparency = 0.7
				thumbGlow.ZIndex = 0
				thumbGlow.Parent = Thumb
				
				local function Update(input)
					local relativeX = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
					local newValue = math.floor(min + ((max - min) * relativeX))
					
					value = newValue
					ValueLabel.Text = tostring(value)
					
					TweenService:Create(Fill, TweenInfo.new(0.05), {
						Size = UDim2.new(relativeX, 0, 1, 0)
					}):Play()
					
					TweenService:Create(Thumb, TweenInfo.new(0.05), {
						Position = UDim2.new(relativeX, -11, 0.5, -11)
					}):Play()
					
					pcall(callback, value)
				end
				
				Track.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or 
					   input.UserInputType == Enum.UserInputType.Touch then
						dragging = true
						Update(input)
						
						TweenService:Create(Thumb, TweenInfo.new(0.1), {
							Size = UDim2.new(0, 26, 0, 26)
						}):Play()
						
						TweenService:Create(thumbGlow, TweenInfo.new(0.1), {
							ImageTransparency = 0.4
						}):Play()
					end
				end)
				
				UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or 
					   input.UserInputType == Enum.UserInputType.Touch then
						dragging = false
						
						TweenService:Create(Thumb, TweenInfo.new(0.1), {
							Size = UDim2.new(0, 22, 0, 22)
						}):Play()
						
						TweenService:Create(thumbGlow, TweenInfo.new(0.1), {
							ImageTransparency = 0.7
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
						Thumb.Position = UDim2.new(relativeX, -11, 0.5, -11)
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
				Container.Size = UDim2.new(0.93, 0, 0, 52)
				Container.BackgroundColor3 = Theme.ElementBg
				Container.ClipsDescendants = false
				Container.ZIndex = 2
				Container.Parent = Items
				AddCorner(Container, 7)
				AddStroke(Container, Theme.Outline, 1.5)
				
				local Header = Instance.new("TextButton")
				Header.Size = UDim2.new(1, 0, 0, 52)
				Header.BackgroundTransparency = 1
				Header.Text = ""
				Header.AutoButtonColor = false
				Header.ZIndex = 3
				Header.Parent = Container
				
				local Label = Instance.new("TextLabel")
				Label.Text = text
				Label.Size = UDim2.new(0.5, 0, 1, 0)
				Label.Position = UDim2.new(0, 18, 0, 0)
				Label.BackgroundTransparency = 1
				Label.Font = Theme.FontSemi
				Label.TextSize = Theme.TextSize
				Label.TextColor3 = Theme.Text
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.ZIndex = 3
				Label.Parent = Header
				
				local SelectedLabel = Instance.new("TextLabel")
				SelectedLabel.Text = selected
				SelectedLabel.Size = UDim2.new(0.4, 0, 1, 0)
				SelectedLabel.Position = UDim2.new(0.5, -10, 0, 0)
				SelectedLabel.BackgroundTransparency = 1
				SelectedLabel.Font = Theme.FontSemi
				SelectedLabel.TextSize = Theme.TextSize - 1
				SelectedLabel.TextColor3 = Theme.Accent
				SelectedLabel.TextXAlignment = Enum.TextXAlignment.Right
				SelectedLabel.TextTruncate = Enum.TextTruncate.AtEnd
				SelectedLabel.ZIndex = 3
				SelectedLabel.Parent = Header
				
				local Arrow = Instance.new("TextLabel")
				Arrow.Text = "▼"
				Arrow.Size = UDim2.new(0, 28, 1, 0)
				Arrow.Position = UDim2.new(1, -38, 0, 0)
				Arrow.BackgroundTransparency = 1
				Arrow.Font = Theme.Font
				Arrow.TextSize = 15
				Arrow.TextColor3 = Theme.TextDim
				Arrow.ZIndex = 3
				Arrow.Parent = Header
				
				local OptionsFrame = Instance.new("ScrollingFrame")
				OptionsFrame.Size = UDim2.new(1, 0, 0, 0)
				OptionsFrame.Position = UDim2.new(0, 0, 0, 52)
				OptionsFrame.BackgroundColor3 = Theme.SectionBg
				OptionsFrame.ClipsDescendants = true
				OptionsFrame.ScrollBarThickness = 4
				OptionsFrame.ScrollBarImageColor3 = Theme.Accent
				OptionsFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
				OptionsFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
				OptionsFrame.ZIndex = 5
				OptionsFrame.Parent = Container
				AddCorner(OptionsFrame, 7)
				AddStroke(OptionsFrame, Theme.Accent, 1.5)
				
				local OptionsLayout = Instance.new("UIListLayout")
				OptionsLayout.Padding = UDim.new(0, 4)
				OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
				OptionsLayout.Parent = OptionsFrame
				
				for _, option in ipairs(options) do
					local OptionBtn = Instance.new("TextButton")
					OptionBtn.Size = UDim2.new(1, 0, 0, 42)
					OptionBtn.BackgroundColor3 = option == selected and Theme.ElementBg or Color3.fromRGB(0, 0, 0)
					OptionBtn.BackgroundTransparency = option == selected and 0 or 1
					OptionBtn.Text = option
					OptionBtn.Font = Theme.FontSemi
					OptionBtn.TextSize = Theme.TextSize
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
						
						open = false
						local maxHeight = math.min(#options * 46, 220)
						
						TweenService:Create(Container, TweenInfo.new(0.2), {
							Size = UDim2.new(0.93, 0, 0, 52)
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
						local maxHeight = math.min(#options * 46, 220)
						
						TweenService:Create(Container, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
							Size = UDim2.new(0.93, 0, 0, 52 + maxHeight)
						}):Play()
						
						TweenService:Create(OptionsFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
							Size = UDim2.new(1, 0, 0, maxHeight)
						}):Play()
						
						TweenService:Create(Arrow, TweenInfo.new(0.2), {
							Rotation = 180
						}):Play()
					else
						TweenService:Create(Container, TweenInfo.new(0.2), {
							Size = UDim2.new(0.93, 0, 0, 52)
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
			-- INPUT ELEMENT
			-- ══════════════════════════════════════════════════════════
			
			function Section:AddInput(text, placeholder, callback)
				local Container = Instance.new("Frame")
				Container.Size = UDim2.new(0.93, 0, 0, 85)
				Container.BackgroundColor3 = Theme.ElementBg
				Container.Parent = Items
				AddCorner(Container, 7)
				AddStroke(Container, Theme.Outline, 1.5)
				
				local Label = Instance.new("TextLabel")
				Label.Text = text
				Label.Size = UDim2.new(1, -30, 0, 30)
				Label.Position = UDim2.new(0, 18, 0, 8)
				Label.BackgroundTransparency = 1
				Label.Font = Theme.FontSemi
				Label.TextSize = Theme.TextSize
				Label.TextColor3 = Theme.Text
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.Parent = Container
				
				local InputBox = Instance.new("TextBox")
				InputBox.Size = UDim2.new(0.88, 0, 0, 38)
				InputBox.Position = UDim2.new(0.06, 0, 1, -43)
				InputBox.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
				InputBox.PlaceholderText = placeholder or "Enter text..."
				InputBox.PlaceholderColor3 = Theme.TextDark
				InputBox.Text = ""
				InputBox.Font = Theme.FontSemi
				InputBox.TextSize = Theme.TextSize
				InputBox.TextColor3 = Theme.Text
				InputBox.ClearTextOnFocus = false
				InputBox.Parent = Container
				AddCorner(InputBox, 6)
				
				local inputStroke = AddStroke(InputBox, Theme.Outline, 1.5)
				AddPadding(InputBox, {Left = 12, Right = 12})
				
				InputBox.Focused:Connect(function()
					TweenService:Create(inputStroke, TweenInfo.new(0.2), {
						Color = Theme.Accent,
						Thickness = 2
					}):Play()
					
					TweenService:Create(InputBox, TweenInfo.new(0.2), {
						BackgroundColor3 = Color3.fromRGB(20, 20, 28)
					}):Play()
				end)
				
				InputBox.FocusLost:Connect(function(enterPressed)
					TweenService:Create(inputStroke, TweenInfo.new(0.2), {
						Color = Theme.Outline,
						Thickness = 1.5
					}):Play()
					
					TweenService:Create(InputBox, TweenInfo.new(0.2), {
						BackgroundColor3 = Color3.fromRGB(16, 16, 22)
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
				Label.Size = UDim2.new(0.93, 0, 0, 42)
				Label.BackgroundColor3 = Theme.ElementBg
				Label.BackgroundTransparency = 0.4
				Label.Text = text
				Label.Font = Theme.FontSemi
				Label.TextSize = Theme.TextSize
				Label.TextColor3 = Theme.TextDim
				Label.TextXAlignment = Enum.TextXAlignment.Left
				Label.TextWrapped = true
				Label.Parent = Items
				AddCorner(Label, 7)
				AddPadding(Label, {Left = 18, Right = 18})
				
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
	local duration = config.Duration or 3.5
	local notifType = config.Type or "info"
	
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
		container.Size = UDim2.new(0.35, 0, 0.25, 0)
		container.Position = UDim2.new(0.98, 0, 0.98, 0)
		container.AnchorPoint = Vector2.new(1, 1)
		container.BackgroundTransparency = 1
		container.Parent = notifGui
		
		local layout = Instance.new("UIListLayout")
		layout.Padding = UDim.new(0, 12)
		layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
		layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Parent = container
	end
	
	local container = notifGui.Container
	
	local typeColors = {
		info = Theme.Accent,
		success = Theme.Success,
		warning = Theme.Warning,
		error = Theme.Error
	}
	
	local accentColor = typeColors[notifType] or Theme.Accent
	
	local Notif = Instance.new("Frame")
	Notif.Size = UDim2.new(0.95, 0, 0, 0)
	Notif.BackgroundColor3 = Theme.SectionBg
	Notif.BackgroundTransparency = 0.05
	Notif.Parent = container
	AddCorner(Notif, 8)
	AddStroke(Notif, accentColor, 2)
	
	local AccentBar = Instance.new("Frame")
	AccentBar.Size = UDim2.new(0, 5, 1, 0)
	AccentBar.BackgroundColor3 = accentColor
	AccentBar.BorderSizePixel = 0
	AccentBar.Parent = Notif
	AddCorner(AccentBar, 8)
	
	-- Icon (Type-based)
	local IconFrame = Instance.new("Frame")
	IconFrame.Size = UDim2.new(0, 36, 0, 36)
	IconFrame.Position = UDim2.new(0, 15, 0.5, -18)
	IconFrame.BackgroundColor3 = accentColor
	IconFrame.Parent = Notif
	AddCorner(IconFrame, 6)
	
	local IconText = Instance.new("TextLabel")
	IconText.Size = UDim2.new(1, 0, 1, 0)
	IconText.BackgroundTransparency = 1
	IconText.Font = Theme.Font
	IconText.TextSize = 20
	IconText.TextColor3 = Color3.fromRGB(255, 255, 255)
	IconText.Parent = IconFrame
	
	if notifType == "success" then
		IconText.Text = "✓"
	elseif notifType == "warning" then
		IconText.Text = "!"
	elseif notifType == "error" then
		IconText.Text = "×"
	else
		IconText.Text = "i"
	end
	
	local Title = Instance.new("TextLabel")
	Title.Text = title
	Title.Size = UDim2.new(1, -120, 0, 26)
	Title.Position = UDim2.new(0, 60, 0, 10)
	Title.BackgroundTransparency = 1
	Title.Font = Theme.Font
	Title.TextSize = 16
	Title.TextColor3 = Theme.Text
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Parent = Notif
	
	local Message = Instance.new("TextLabel")
	Message.Text = message
	Message.Size = UDim2.new(1, -120, 0, 24)
	Message.Position = UDim2.new(0, 60, 0, 38)
	Message.BackgroundTransparency = 1
	Message.Font = Theme.FontSemi
	Message.TextSize = 13
	Message.TextColor3 = Theme.TextDim
	Message.TextXAlignment = Enum.TextXAlignment.Left
	Message.TextWrapped = true
	Message.Parent = Notif
	
	local CloseBtn = Instance.new("TextButton")
	CloseBtn.Size = UDim2.new(0, 38, 0, 38)
	CloseBtn.Position = UDim2.new(1, -43, 0, 8)
	CloseBtn.BackgroundTransparency = 1
	CloseBtn.Text = "×"
	CloseBtn.Font = Theme.Font
	CloseBtn.TextSize = 26
	CloseBtn.TextColor3 = Theme.TextDim
	CloseBtn.Parent = Notif
	
	CloseBtn.MouseEnter:Connect(function()
		TweenService:Create(CloseBtn, TweenInfo.new(0.1), {TextColor3 = Theme.Error}):Play()
	end)
	
	CloseBtn.MouseLeave:Connect(function()
		TweenService:Create(CloseBtn, TweenInfo.new(0.1), {TextColor3 = Theme.TextDim}):Play()
	end)
	
	TweenService:Create(Notif, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0.95, 0, 0, 80)
	}):Play()
	
	task.delay(duration, function()
		TweenService:Create(Notif, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Size = UDim2.new(0.95, 0, 0, 0),
			BackgroundTransparency = 1
		}):Play()
		
		task.wait(0.25)
		if Notif then Notif:Destroy() end
	end)
	
	CloseBtn.MouseButton1Click:Connect(function()
		TweenService:Create(Notif, TweenInfo.new(0.2), {
			Size = UDim2.new(0.95, 0, 0, 0),
			BackgroundTransparency = 1
		}):Play()
		
		task.wait(0.2)
		if Notif then Notif:Destroy() end
	end)
end

return JobwareLib
