-- This file was generated at discord.gg/syncrypt

local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local u7 = pcall(function()
	return gethui()
end) and gethui() or game:GetService("CoreGui")

if not pcall(function()
	return u7.Name
end) then
	u7 = LocalPlayer:WaitForChild("PlayerGui")
end

local function u8()
	for _, v in ipairs({
		"Armoured_TSB_Splash",
		"Armoured_TSB_Hub",
		"Galaxy_TSB_Hub",
		"Galaxy_TSB_FloatBtn",
		"Galaxy_Rayfield_Mobile",
	}) do
		local v2 = u7:FindFirstChild(v)

		if v2 then
			local _pcall = pcall
			local u253 = v2

			pcall(function()
				u253:Destroy()
			end)
		end
	end
end

_G.ArmouredTSBVersion = (_G.ArmouredTSBVersion or 0) + 1

local ArmouredTSBVersion = _G.ArmouredTSBVersion
local u10 = false

-- Universal loader: do not block the hub based on PlaceId.
-- TSB-specific features may still depend on TSB remotes/objects, but the hub itself
-- can now initialize in any Roblox experience.
local GALAXY_TARGET_PLACE_ID = 10449761463
local GALAXY_IS_TSB = (game.PlaceId == GALAXY_TARGET_PLACE_ID)

do
	local t1, t3, u27, s1, n4, u33, s2, n5, u39, u43, n6, u56, t16, u93, u98, u103, u108, t18, t25, t26, v129, Part, u139, u147, u148, n8, n9, u154, v157, v163, u169, u170, n10, u172, u174, u175, u176, u177, s7, t30, Void, v183, vector3, t32, u186, u187, u188, u193, u194, u196, u197, t33, s8, u200, v204, v209, u210, u215, u216, u217, u218, u219, u220, u221, u222, u223, u224, u225

	do
		local u109, u112, u113
		local t10, t11, v49, t15, v66, u110, u111, u114

		do
			local connection

			do
				do
					do
						do
							do
								local v60

								do
									do
										local u44, t12
										local t13

										do
											do
												do
													local u20

													do
														local t2

														do
															do
																do
																	local ArmouredTSBShutdown = _G.ArmouredTSBShutdown

																	if type(ArmouredTSBShutdown) == "function" then
																		pcall(_G.ArmouredTSBShutdown)
																	end
																end

																u8()
															end

															print(string.format("[Galaxy] Universal hub booting. PlaceId=%s | TSB=%s", tostring(game.PlaceId), tostring(GALAXY_IS_TSB)))
															t1 = {}
															t2 = {
																Background = Color3.fromRGB(8, 10, 24),
																Header = Color3.fromRGB(18, 20, 44),
																Sidebar = Color3.fromRGB(11, 14, 32),
																Panel = Color3.fromRGB(20, 24, 50),
																PanelAlt = Color3.fromRGB(29, 34, 68),
																Stroke = Color3.fromRGB(62, 70, 118),
																Accent = Color3.fromRGB(137, 101, 255),
																AccentDim = Color3.fromRGB(71, 52, 148),
												GalaxyCyan = Color3.fromRGB(83, 213, 255),
												GalaxyPink = Color3.fromRGB(241, 115, 231),
																Text = Color3.fromRGB(245, 247, 255),
																SubText = Color3.fromRGB(176, 184, 215),
																GreyText = Color3.fromRGB(112, 121, 155),
																Danger = Color3.fromRGB(255, 92, 139),
															}
															t3 = {}
														end

														local u17 = t2
														local u18 = TweenService
														local u19 = ArmouredTSBVersion

														function t3.CreateSplash(_, p2, p3, p4, p5)
															local ScreenGui = Instance.new("ScreenGui")

															ScreenGui.Name = "Galaxy_TSB_Splash"
															ScreenGui.Parent = u7
															ScreenGui.ResetOnSpawn = false
															ScreenGui.IgnoreGuiInset = true
															ScreenGui.DisplayOrder = 50

															local Frame = Instance.new("Frame")

															Frame.Size = UDim2.fromScale(1, 1)
															Frame.BackgroundColor3 = Color3.fromRGB(5, 7, 18)
															Frame.BackgroundTransparency = 1
															Frame.BorderSizePixel = 0
															Frame.Parent = ScreenGui

															local Frame2 = Instance.new("Frame")

															Frame2.Size = UDim2.new(0, 420, 0, 120)
															Frame2.Position = UDim2.new(0.5, -210, 0.5, -60)
															Frame2.BackgroundTransparency = 1
															Frame2.Parent = Frame

															local TextLabel = Instance.new("TextLabel")

															TextLabel.Size = UDim2.new(1, 0, 0, 28)
															TextLabel.BackgroundTransparency = 1
															TextLabel.Font = Enum.Font.GothamBold
															TextLabel.TextSize = 20
															TextLabel.TextColor3 = u17.Accent
															TextLabel.Text = p2
															TextLabel.TextTransparency = 1
															TextLabel.Parent = Frame2

															local TextLabel2 = Instance.new("TextLabel")

															TextLabel2.Size = UDim2.new(1, 0, 0, 16)
															TextLabel2.Position = UDim2.new(0, 0, 0, 32)
															TextLabel2.BackgroundTransparency = 1
															TextLabel2.Font = Enum.Font.Gotham
															TextLabel2.TextSize = 12
															TextLabel2.TextColor3 = u17.SubText
															TextLabel2.Text = p3
															TextLabel2.TextTransparency = 1
															TextLabel2.Parent = Frame2

															local TextLabel3 = Instance.new("TextLabel")

															TextLabel3.Size = UDim2.new(1, 0, 0, 14)
															TextLabel3.Position = UDim2.new(0, 0, 0, 58)
															TextLabel3.BackgroundTransparency = 1
															TextLabel3.Font = Enum.Font.Gotham
															TextLabel3.TextSize = 11
															TextLabel3.TextColor3 = u17.GreyText
															TextLabel3.Text = ""
															TextLabel3.TextTransparency = 1
															TextLabel3.Parent = Frame2

															
															local spawn = task.spawn
															local u276 = p4
															local u277 = p5

															spawn(function()
																local tweenInfo = TweenInfo.new(0.3)

																u18:Create(Frame, tweenInfo, {
																	BackgroundTransparency = 0.15,
																}):Play()
																u18:Create(TextLabel, tweenInfo, {
																	TextTransparency = 0,
																}):Play()
																u18:Create(TextLabel2, tweenInfo, {
																	TextTransparency = 0,
																}):Play()
																u18:Create(TextLabel3, tweenInfo, {
																	TextTransparency = 0,
																}):Play()
																


																local n1 = 0

																for _, v in ipairs(u276) do
																	n1 = n1 + v.duration
																end

																local n2 = 0

																for _, v in ipairs(u276) do
																	if _G.ArmouredTSBVersion ~= u19 or u10 then
																		break
																	end

																	TextLabel3.Text = v.label
																	n2 = n2 + v.duration

																	local v601 = n2 / n1

																	
																	task.wait(v.duration)
																end

																if _G.ArmouredTSBVersion == u19 and not u10 then
																	local tweenInfo2 = TweenInfo.new(0.3)

																	u18:Create(Frame, tweenInfo2, {
																		BackgroundTransparency = 1,
																	}):Play()
																	u18:Create(TextLabel, tweenInfo2, {
																		TextTransparency = 1,
																	}):Play()
																	u18:Create(TextLabel2, tweenInfo2, {
																		TextTransparency = 1,
																	}):Play()
																	u18:Create(TextLabel3, tweenInfo2, {
																		TextTransparency = 1,
																	}):Play()
																	u18:Create(Frame3, tweenInfo2, {
																		BackgroundTransparency = 1,
																	}):Play()
																	u18:Create(Frame4, tweenInfo2, {
																		BackgroundTransparency = 1,
																	}):Play()
																	task.wait(0.3)
																	ScreenGui:Destroy()

																	if u277 then
																		u277()
																	end

																	return
																end

																ScreenGui:Destroy()
															end)
														end

														u20 = t2
													end

													local u21 = UserInputService
													local u22 = RunService
													local u23 = ArmouredTSBVersion
													local u24 = TweenService

													function t3.CreateWindow(_, p7)
														local Armoured_TSB_Hub = u7:FindFirstChild("Galaxy_TSB_Hub")

														if Armoured_TSB_Hub then
															Armoured_TSB_Hub:Destroy()
														end

														local ScreenGui = Instance.new("ScreenGui")

														ScreenGui.Name = "Galaxy_TSB_Hub"
														ScreenGui.Parent = u7
														ScreenGui.ResetOnSpawn = false
														ScreenGui.IgnoreGuiInset = true

														local Frame = Instance.new("Frame")

														Frame.Name = "Main"
														Frame.Size = UDim2.new(0, 640, 0, 440)
														Frame.Position = UDim2.new(0.5, -320, 0.5, -220)
														Frame.BackgroundColor3 = u20.Background
														Frame.BorderSizePixel = 0
														Frame.ClipsDescendants = true
														Frame.Visible = false
														Frame.Parent = ScreenGui

												-- Galaxy visual layer only.
												local GalaxyBackdrop = Instance.new("Frame")
												GalaxyBackdrop.Name = "GalaxyBackdrop"
												GalaxyBackdrop.Size = UDim2.fromScale(1, 1)
												GalaxyBackdrop.BackgroundColor3 = u20.Background
												GalaxyBackdrop.BorderSizePixel = 0
												GalaxyBackdrop.ZIndex = 0
												GalaxyBackdrop.Parent = Frame
												local GalaxyGradient = Instance.new("UIGradient")
												GalaxyGradient.Color = ColorSequence.new({
													ColorSequenceKeypoint.new(0, Color3.fromRGB(7, 9, 23)),
													ColorSequenceKeypoint.new(0.45, Color3.fromRGB(20, 15, 48)),
													ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 17, 37)),
												})
												GalaxyGradient.Rotation = 35
												GalaxyGradient.Parent = GalaxyBackdrop
												local rng = Random.new(314159)
												for i = 1, 34 do
													local Star = Instance.new("Frame")
													local starSize = rng:NextNumber(1.5, 4.5)
													Star.Size = UDim2.fromOffset(starSize, starSize)
													Star.Position = UDim2.fromScale(rng:NextNumber(0.01, 0.99), rng:NextNumber(0.10, 0.99))
													Star.BackgroundColor3 = (i % 5 == 0) and u20.GalaxyCyan or ((i % 7 == 0) and u20.GalaxyPink or Color3.fromRGB(228, 234, 255))
													Star.BackgroundTransparency = rng:NextNumber(0.2, 0.62)
													Star.BorderSizePixel = 0
													Star.ZIndex = 0
													Star.Parent = GalaxyBackdrop
													local StarCorner = Instance.new("UICorner")
													StarCorner.CornerRadius = UDim.new(1, 0)
													StarCorner.Parent = Star
												end
												local Nebula = Instance.new("Frame")
												Nebula.Size = UDim2.fromOffset(230, 230)
												Nebula.Position = UDim2.new(0.68, -115, 0.58, -115)
												Nebula.BackgroundColor3 = u20.Accent
												Nebula.BackgroundTransparency = 0.93
												Nebula.BorderSizePixel = 0
												Nebula.ZIndex = 0
												Nebula.Parent = GalaxyBackdrop
												local NebulaCorner = Instance.new("UICorner")
												NebulaCorner.CornerRadius = UDim.new(1, 0)
												NebulaCorner.Parent = Nebula

														local UICorner = Instance.new("UICorner")

														UICorner.CornerRadius = UDim.new(0, 16)
														UICorner.Parent = Frame
												local MainStroke = Instance.new("UIStroke")
												MainStroke.Color = Color3.fromRGB(93, 103, 170)
												MainStroke.Thickness = 1
												MainStroke.Transparency = 0.22
												MainStroke.Parent = Frame

														local Frame5 = Instance.new("Frame")

														Frame5.Size = UDim2.new(1, 0, 0, 40)
														Frame5.BackgroundColor3 = u20.Header
														Frame5.BorderSizePixel = 0
														Frame5.Parent = Frame

														local UICorner2 = Instance.new("UICorner")

														UICorner2.CornerRadius = UDim.new(0, 12)
														UICorner2.Parent = Frame5
												local HeaderGradient = Instance.new("UIGradient")
												HeaderGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(22,24,53)), ColorSequenceKeypoint.new(0.52, Color3.fromRGB(35,24,76)), ColorSequenceKeypoint.new(1, Color3.fromRGB(17,32,58))})
												HeaderGradient.Rotation = 12
												HeaderGradient.Parent = Frame5

														local Frame6 = Instance.new("Frame")

														Frame6.Size = UDim2.new(1, 0, 0, 8)
														Frame6.Position = UDim2.new(0, 0, 1, -8)
														Frame6.BackgroundColor3 = u20.Header
														Frame6.BorderSizePixel = 0
														Frame6.Parent = Frame5

														local Frame7 = Instance.new("Frame")

														Frame7.Size = UDim2.new(1, 0, 0, 2)
														Frame7.BackgroundColor3 = u20.Accent
														Frame7.BorderSizePixel = 0
														Frame7.ZIndex = 2
														Frame7.Parent = Frame5

														local Frame8 = Instance.new("Frame")

														Frame8.Size = UDim2.new(0, 11, 0, 11)
														Frame8.Position = UDim2.new(0, 15, 0.5, -5)
														Frame8.Rotation = 45
														Frame8.BackgroundColor3 = u20.Accent
														Frame8.BorderSizePixel = 0
														Frame8.Parent = Frame5

														local TextLabel = Instance.new("TextLabel")

														TextLabel.Text = p7
														TextLabel.Font = Enum.Font.GothamBold
														TextLabel.TextColor3 = u20.Text
														TextLabel.TextSize = 14
														TextLabel.TextXAlignment = Enum.TextXAlignment.Left
														TextLabel.Position = UDim2.new(0, 36, 0, 0)
														TextLabel.Size = UDim2.new(1, -36, 1, 0)
														TextLabel.BackgroundTransparency = 1
														TextLabel.Parent = Frame5

														local Frame9 = Instance.new("Frame")

														Frame9.Position = UDim2.new(0, 0, 0, 40)
														Frame9.Size = UDim2.new(0, 160, 1, -40)
														Frame9.BackgroundColor3 = u20.Sidebar
														Frame9.BorderSizePixel = 0
														Frame9.Parent = Frame
												local SidebarGradient = Instance.new("UIGradient")
												SidebarGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, Color3.fromRGB(11,14,34)), ColorSequenceKeypoint.new(1, Color3.fromRGB(15,11,38))})
												SidebarGradient.Rotation = 90
												SidebarGradient.Parent = Frame9

														local TextLabel4 = Instance.new("TextLabel")

														TextLabel4.Size = UDim2.new(1, -16, 0, 14)
														TextLabel4.Position = UDim2.new(0, 8, 1, -22)
														TextLabel4.BackgroundTransparency = 1
														TextLabel4.Font = Enum.Font.Gotham
														TextLabel4.TextSize = 11
														TextLabel4.TextColor3 = u20.GreyText
														TextLabel4.TextXAlignment = Enum.TextXAlignment.Right
														TextLabel4.Text = "v1"
														TextLabel4.Parent = Frame9

														local u292 = false
														local p8Position = nil
														local Position = nil
														local u295 = nil
														local u296 = false
														local u297 = true
														local u298 = false
														local u299 = false
														local InputBegan = Frame5.InputBegan
														local u301 = Frame

														-- PC drag begin
														InputBegan:Connect(function(p8)
															if p8.UserInputType == Enum.UserInputType.MouseButton1 then
																u292 = true
																p8Position = p8.Position
																Position = u301.Position
																u295 = u301.Position
															end
														end)

														-- Mobile touch drag begin (via UIS, not Frame event)
														Frame5.InputBegan:Connect(function(p8)
															if p8.UserInputType == Enum.UserInputType.Touch then
																u292 = true
																p8Position = p8.Position
																Position = u301.Position
																u295 = u301.Position
															end
														end)

														local connection2 = u21.InputEnded:Connect(function(input)
															if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
																u292 = false
															end
														end)

														t1[#t1 + 1] = connection2

														local connection3 = u21.InputChanged:Connect(function(input)
															-- PC mouse drag
															if u292 and input.UserInputType == Enum.UserInputType.MouseMovement then
																local v606 = input.Position - p8Position
																u295 = UDim2.new(
																	Position.X.Scale,
																	Position.X.Offset + v606.X,
																	Position.Y.Scale,
																	Position.Y.Offset + v606.Y
																)
															end
															-- Mobile touch drag
															if u292 and input.UserInputType == Enum.UserInputType.Touch then
																local v606 = input.Position - p8Position
																u295 = UDim2.new(
																	Position.X.Scale,
																	Position.X.Offset + v606.X,
																	Position.Y.Scale,
																	Position.Y.Offset + v606.Y
																)
															end
														end)

														t1[#t1 + 1] = connection3

														-- Mobile floating toggle icon
														local isMobile = u21.TouchEnabled and not u21.KeyboardEnabled
														local floatButton = nil
														if isMobile then
															local floatGui = Instance.new("ScreenGui")
															floatGui.Name = "Galaxy_TSB_FloatBtn"
															floatGui.ResetOnSpawn = false
															floatGui.IgnoreGuiInset = true
															floatGui.DisplayOrder = 100
															floatGui.Parent = u7

															floatButton = Instance.new("TextButton")
															floatButton.Size = UDim2.new(0, 52, 0, 52)
															floatButton.Position = UDim2.new(1, -68, 0.5, -26)
															floatButton.BackgroundColor3 = u20.Accent
															floatButton.Text = "☰"
															floatButton.Font = Enum.Font.GothamBold
															floatButton.TextSize = 22
															floatButton.TextColor3 = u20.Background
															floatButton.BorderSizePixel = 0
															floatButton.AutoButtonColor = false
															floatButton.ZIndex = 10
															floatButton.Parent = floatGui

															local UICornerFloat = Instance.new("UICorner")
															UICornerFloat.CornerRadius = UDim.new(1, 0)
															UICornerFloat.Parent = floatButton
												local FloatGradient = Instance.new("UIGradient")
												FloatGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, u20.GalaxyCyan), ColorSequenceKeypoint.new(0.55, u20.Accent), ColorSequenceKeypoint.new(1, u20.GalaxyPink)})
												FloatGradient.Rotation = 25
												FloatGradient.Parent = floatButton
												local FloatStroke = Instance.new("UIStroke")
												FloatStroke.Color = Color3.fromRGB(212, 222, 255)
												FloatStroke.Transparency = 0.35
												FloatStroke.Thickness = 1.2
												FloatStroke.Parent = floatButton

															-- Float button drag and tap via UIS
															local fbDragging = false
															local fbDragStart = nil
															local fbStartPos = nil

															floatButton.InputBegan:Connect(function(input)
																if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
																	fbDragging = false
																	fbDragStart = input.Position
																	fbStartPos = floatButton.Position
																end
															end)

															floatButton.InputChanged:Connect(function(input)
																if (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) and fbDragStart then
																	local delta = input.Position - fbDragStart
																	if delta.Magnitude > 6 then
																		fbDragging = true
																	end
																	if fbDragging then
																		floatButton.Position = UDim2.new(
																			fbStartPos.X.Scale,
																			fbStartPos.X.Offset + delta.X,
																			fbStartPos.Y.Scale,
																			fbStartPos.Y.Offset + delta.Y
																		)
																	end
																end
															end)

															-- Tap to toggle (only if not dragging)
															floatButton.InputEnded:Connect(function(input)
																if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
																	if not fbDragging then
																		task.spawn(function()
																			if u298 or u299 then return end
																			u298 = true
																			u297 = not u297
																			if not u297 then
																				local tw = u24:Create(u301, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
																					BackgroundTransparency = 1,
																					Size = UDim2.new(0, 640, 0, 0),
																				})
																				tw:Play()
																				tw.Completed:Wait()
																				u301.Visible = false
																			else
																				u301.Visible = true
																				local tw = u24:Create(u301, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
																					BackgroundTransparency = 0,
																					Size = UDim2.new(0, 640, 0, 440),
																				})
																				tw:Play()
																				tw.Completed:Wait()
																			end
																			u298 = false
																		end)
																	end
																	fbDragging = false
																end
															end)

															t1[#t1 + 1] = floatGui
														end

														local RenderStepped = u22.RenderStepped
														local u305 = Frame
														local connection4 = RenderStepped:Connect(function()
															if _G.ArmouredTSBVersion == u23 and not u10 and u295 and not u298 and not u299 and u305.Visible then
																local Position2 = u305.Position
																local v608 = u292 and 0.18 or 0.14
																local v609 = Position2.X.Offset + (u295.X.Offset - Position2.X.Offset) * v608
																local v610 = Position2.Y.Offset + (u295.Y.Offset - Position2.Y.Offset) * v608
																local v611 = v609 - u295.X.Offset

																if math.abs(v611) < 0.5 then
																	v609 = u295.X.Offset
																end

																local v612 = v610 - u295.Y.Offset

																if math.abs(v612) < 0.5 then
																	v610 = u295.Y.Offset
																end

																u305.Position = UDim2.new(u295.X.Scale, v609, u295.Y.Scale, v610)

																return
															end
														end)

														t1[#t1 + 1] = connection4

														local InputBegan2 = u21.InputBegan
														local u308 = Frame
														-- Toggle helper: shared by RightShift and P key
														local function doToggle()
															if u298 or u299 then return end
															u298 = true
															u297 = not u297
															if not u297 then
																local v615 = u24:Create(u308, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {
																	BackgroundTransparency = 1,
																	Size = UDim2.new(0, 640, 0, 0),
																})
																v615:Play()
																v615.Completed:Wait()
																u308.Visible = false
															else
																u308.Visible = true
																local v616 = u24:Create(
																	u308,
																	TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
																	{
																		BackgroundTransparency = 0,
																		Size = UDim2.new(0, 640, 0, 440),
																	}
																)
																v616:Play()
																v616.Completed:Wait()
															end
															u298 = false
														end
														local connection5 = InputBegan2:Connect(function(p9, p10)
															if not p10 and (p9.KeyCode == Enum.KeyCode.RightShift or p9.KeyCode == Enum.KeyCode.P) then
																task.spawn(doToggle)
															end
														end)

														t1[#t1 + 1] = connection5

														local u310 = nil
														local u311 = nil
														local u312 = nil
														local u313 = nil
														local u314 = nil
														local n3 = 0
														local t4 = {}
														local u317 = Frame

														function t4.PlayIntro(_)
															u299 = true
															u317.Visible = true
															u317.BackgroundTransparency = 1
															u317.Size = UDim2.new(0, 588, 0, 404)
															u317.Position = UDim2.new(0.5, -294, 0.5, -202)

															local v618 =
																u24:Create(u317, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
																	BackgroundTransparency = 0,
																	Size = UDim2.new(0, 640, 0, 440),
																	Position = UDim2.new(0.5, -320, 0.5, -220),
																})

															v618:Play()
															v618.Completed:Wait()
															u295 = u317.Position
															u299 = false
															u296 = true
														end

														local u318 = Frame9
														local u319 = Frame

														function t4.CreateTab(_, p13, _)
															local TextButton = Instance.new("TextButton")

															TextButton.Size = UDim2.new(1, -16, 0, 34)
															TextButton.Position = UDim2.new(0, 8, 0, 10 + n3 * 40)
															TextButton.BackgroundColor3 = u20.Sidebar
															TextButton.Text = ""
															TextButton.AutoButtonColor = false
															TextButton.BorderSizePixel = 0
															TextButton.Parent = u318

															local UICorner3 = Instance.new("UICorner")

															UICorner3.CornerRadius = UDim.new(0, 10)
															UICorner3.Parent = TextButton

															local Frame10 = Instance.new("Frame")

															Frame10.Size = UDim2.new(0, 3, 1, -10)
															Frame10.Position = UDim2.new(0, 0, 0, 5)
															Frame10.BackgroundColor3 = u20.Accent
															Frame10.BorderSizePixel = 0
															Frame10.BackgroundTransparency = 1
															Frame10.Parent = TextButton

															local UICorner4 = Instance.new("UICorner")

															UICorner4.CornerRadius = UDim.new(0, 2)
															UICorner4.Parent = Frame10

															local TextLabel5 = Instance.new("TextLabel")

															TextLabel5.Size = UDim2.new(0, 0, 0, 0)
															TextLabel5.BackgroundTransparency = 1
															TextLabel5.Text = ""
															TextLabel5.Parent = TextButton

															local TextLabel6 = Instance.new("TextLabel")

															TextLabel6.Size = UDim2.new(1, -20, 1, 0)
															TextLabel6.Position = UDim2.new(0, 12, 0, 0)
															TextLabel6.BackgroundTransparency = 1
															TextLabel6.Font = Enum.Font.GothamSemibold
															TextLabel6.TextSize = 13
															TextLabel6.TextColor3 = u20.GreyText
															TextLabel6.TextXAlignment = Enum.TextXAlignment.Left
															TextLabel6.Text = p13
															TextLabel6.Parent = TextButton

															local ScrollingFrame = Instance.new("ScrollingFrame")

															ScrollingFrame.Name = p13 .. "_Container"
															ScrollingFrame.Position = UDim2.new(0, 172, 0, 52)
															ScrollingFrame.Size = UDim2.new(1, -184, 1, -64)
															ScrollingFrame.BackgroundTransparency = 1
															ScrollingFrame.BorderSizePixel = 0
															ScrollingFrame.ScrollBarThickness = 3
															ScrollingFrame.ScrollBarImageColor3 = u20.Accent
															ScrollingFrame.ScrollingDirection = Enum.ScrollingDirection.Y
															ScrollingFrame.Visible = false
															ScrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
															ScrollingFrame.Parent = u319

															local UIPadding = Instance.new("UIPadding")

															UIPadding.PaddingLeft = UDim.new(0, 8)
															UIPadding.PaddingRight = UDim.new(0, 12)
															UIPadding.PaddingTop = UDim.new(0, 4)
															UIPadding.Parent = ScrollingFrame

															local UIListLayout = Instance.new("UIListLayout")

															UIListLayout.Padding = UDim.new(0, 6)
															UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
															UIListLayout.Parent = ScrollingFrame

															local PropertyChangedSignal = UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize")
															local u632 = ScrollingFrame
															local u633 = UIListLayout

															PropertyChangedSignal:Connect(function()
																u632.CanvasSize = UDim2.new(0, 0, 0, u633.AbsoluteContentSize.Y + 20)
															end)

															local u634 = ScrollingFrame
															local u635 = TextButton
															local u636 = TextLabel5
															local u637 = TextLabel6
															local u638 = Frame10

															local function v639()
																if u310 ~= u634 then
																	if u310 then
																		u310.Visible = false
																	end

																	if u311 then
																		u24:Create(u311, TweenInfo.new(0.18), {
																			BackgroundColor3 = u20.Sidebar,
																		}):Play()

																		if u312 then
																			u24:Create(u312, TweenInfo.new(0.18), {
																				TextColor3 = u20.GreyText,
																			}):Play()
																		end

																		if u313 then
																			u24:Create(u313, TweenInfo.new(0.18), {
																				TextColor3 = u20.GreyText,
																			}):Play()
																		end

																		if u314 then
																			u24:Create(u314, TweenInfo.new(0.18), {
																				BackgroundTransparency = 1,
																			}):Play()
																		end
																	end

																	u310 = u634
																	u311 = u635
																	u312 = u636
																	u313 = u637
																	u314 = u638
																	u634.Visible = true
																	u24:Create(u635, TweenInfo.new(0.18), {
																		BackgroundColor3 = u20.Panel,
																	}):Play()
																	u24:Create(u636, TweenInfo.new(0.18), {
																		TextColor3 = u20.Accent,
																	}):Play()
																	u24:Create(u637, TweenInfo.new(0.18), {
																		TextColor3 = u20.Text,
																	}):Play()
																	u24:Create(u638, TweenInfo.new(0.18), {
																		BackgroundTransparency = 0,
																	}):Play()

																	return
																end
															end

															if n3 == 0 then
																v639()
															end

															TextButton.MouseButton1Click:Connect(v639)

															local MouseEnter = TextButton.MouseEnter
															local u641 = ScrollingFrame
															local u642 = TextButton
															local u643 = TextLabel6

															MouseEnter:Connect(function()
																if u310 ~= u641 then
																	u24:Create(u642, TweenInfo.new(0.15), {
																		BackgroundColor3 = u20.Panel,
																	}):Play()
																	u24:Create(u643, TweenInfo.new(0.15), {
																		TextColor3 = u20.SubText,
																	}):Play()
																end
															end)

															local MouseLeave = TextButton.MouseLeave
															local u645 = ScrollingFrame
															local u646 = TextButton
															local u647 = TextLabel6

															MouseLeave:Connect(function()
																if u310 ~= u645 then
																	u24:Create(u646, TweenInfo.new(0.15), {
																		BackgroundColor3 = u20.Sidebar,
																	}):Play()
																	u24:Create(u647, TweenInfo.new(0.15), {
																		TextColor3 = u20.GreyText,
																	}):Play()
																end
															end)
															n3 = n3 + 1

															return ScrollingFrame
														end
														function t4.CreateSection(_, p16, p17)
															local Frame11 = Instance.new("Frame")

															Frame11.Size = UDim2.new(1, 0, 0, 26)
															Frame11.BackgroundTransparency = 1
															Frame11.Parent = p17

															local TextLabel7 = Instance.new("TextLabel")

															TextLabel7.Size = UDim2.new(1, 0, 0, 14)
															TextLabel7.Position = UDim2.new(0, 0, 0, 6)
															TextLabel7.BackgroundTransparency = 1
															TextLabel7.Font = Enum.Font.GothamBold
															TextLabel7.TextSize = 11
															TextLabel7.TextColor3 = u20.Accent
															TextLabel7.Text = string.upper(p16)
															TextLabel7.TextXAlignment = Enum.TextXAlignment.Left
															TextLabel7.Parent = Frame11

															local Frame12 = Instance.new("Frame")

															Frame12.Size = UDim2.new(1, 0, 0, 1)
															Frame12.Position = UDim2.new(0, 0, 0, 22)
															Frame12.BackgroundColor3 = u20.Stroke
															Frame12.BorderSizePixel = 0
															Frame12.Parent = Frame11
														end
														function t4.CreateToggle(_, p19, p20, p21, p22)
															local Frame13 = Instance.new("Frame")

															Frame13.Size = UDim2.new(1, 0, 0, 32)
															Frame13.BackgroundTransparency = 1
															Frame13.Active = true
															Frame13.Parent = p20

															local TextLabel8 = Instance.new("TextLabel")

															TextLabel8.Text = p19
															TextLabel8.Size = UDim2.new(1, -50, 1, 0)
															TextLabel8.TextColor3 = u20.Text
															TextLabel8.Font = Enum.Font.Gotham
															TextLabel8.TextSize = 13
															TextLabel8.TextXAlignment = Enum.TextXAlignment.Left
															TextLabel8.BackgroundTransparency = 1
															TextLabel8.Parent = Frame13

															local Frame14 = Instance.new("Frame")

															Frame14.Size = UDim2.new(0, 34, 0, 18)
															Frame14.Position = UDim2.new(1, -40, 0.5, -9)
															Frame14.BackgroundColor3 = p21 and u20.Accent or Color3.fromRGB(42, 42, 42)
															Frame14.BorderSizePixel = 0
															Frame14.Parent = Frame13

															local UICorner5 = Instance.new("UICorner")

															UICorner5.CornerRadius = UDim.new(0, 10)
															UICorner5.Parent = Frame14

															local Stroke = u20.Stroke
															local UIStroke = Instance.new("UIStroke")

															UIStroke.Color = Stroke or u20.Stroke
															UIStroke.Thickness = 1
															UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
															UIStroke.Parent = Frame14

															local u665 = UIStroke

															UIStroke.Transparency = p21 and 0.3 or 0
															UIStroke.Color = p21 and u20.Accent or u20.Stroke

															local Frame15 = Instance.new("Frame")

															Frame15.Size = UDim2.new(0, 14, 0, 14)
															Frame15.Position = p21 and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
															Frame15.BackgroundColor3 = Color3.fromRGB(230, 230, 230)
															Frame15.BorderSizePixel = 0
															Frame15.Parent = Frame14

															local UICorner6 = Instance.new("UICorner")

															UICorner6.CornerRadius = UDim.new(0, 9)
															UICorner6.Parent = Frame15

															local u668 = p21 and true or false
															local u669 = Frame15

															local function v670(p23)
																u668 = p23
																u24
																	:Create(u669, TweenInfo.new(0.18), {
																		Position = p23 and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
																	})
																	:Play()
																u24
																	:Create(Frame14, TweenInfo.new(0.18), {
																		BackgroundColor3 = p23 and u20.Accent or Color3.fromRGB(42, 42, 42),
																	})
																	:Play()
																u24:Create(u665, TweenInfo.new(0.18), {
																	Color = p23 and u20.Accent or u20.Stroke,
																	Transparency = p23 and 0.3 or 0,
																}):Play()
															end

															local InputBegan3 = Frame13.InputBegan
															local u672 = v670
															local u673 = p22

															InputBegan3:Connect(function(p24)
																if p24.UserInputType == Enum.UserInputType.MouseButton1
																	or p24.UserInputType == Enum.UserInputType.Touch then
																	u672(not u668)
																	u673(u668)

																	return
																end
															end)

															local MouseEnter = Frame13.MouseEnter
															local u675 = Frame15

															MouseEnter:Connect(function()
																u24:Create(u675, TweenInfo.new(0.15), {
																	Size = UDim2.new(0, 15, 0, 15),
																}):Play()
															end)

															local MouseLeave = Frame13.MouseLeave
															local u677 = Frame15

															MouseLeave:Connect(function()
																u24:Create(u677, TweenInfo.new(0.15), {
																	Size = UDim2.new(0, 14, 0, 14),
																}):Play()
															end)

															local t5 = {
																Frame = Frame13,
															}
															local u679 = v670
															local u680 = p22

															function t5.SetValue(p25)
																if p25 ~= u668 then
																	u679(p25)
																	u680(u668)
																end
															end
															function t5.GetValue()
																return u668
															end

															return t5
														end
														function t4.CreateSlider(_, p27, p28, p29, p30, p31, p32, p33, p34)
															local Frame16 = Instance.new("Frame")

															Frame16.Size = UDim2.new(1, 0, 0, 50)
															Frame16.BackgroundTransparency = 1
															Frame16.Parent = p28

															local TextLabel9 = Instance.new("TextLabel")

															TextLabel9.Size = UDim2.new(1, -110, 0, 16)
															TextLabel9.BackgroundTransparency = 1
															TextLabel9.Font = Enum.Font.Gotham
															TextLabel9.TextColor3 = u20.Text
															TextLabel9.TextSize = 13
															TextLabel9.TextXAlignment = Enum.TextXAlignment.Left
															TextLabel9.Text = p27
															TextLabel9.Parent = Frame16

															local TextLabel10 = Instance.new("TextLabel")

															TextLabel10.Size = UDim2.new(0, 100, 0, 16)
															TextLabel10.Position = UDim2.new(1, -100, 0, 0)
															TextLabel10.BackgroundTransparency = 1
															TextLabel10.Font = Enum.Font.GothamSemibold
															TextLabel10.TextColor3 = u20.Text
															TextLabel10.TextSize = 12
															TextLabel10.TextXAlignment = Enum.TextXAlignment.Right
															TextLabel10.Parent = Frame16

															local TextButton = Instance.new("TextButton")

															TextButton.Size = UDim2.new(1, 0, 0, 6)
															TextButton.Position = UDim2.new(0, 0, 0, 30)
															TextButton.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
															TextButton.Text = ""
															TextButton.AutoButtonColor = false
															TextButton.BorderSizePixel = 0
															TextButton.Parent = Frame16

															local UICorner7 = Instance.new("UICorner")

															UICorner7.CornerRadius = UDim.new(0, 4)
															UICorner7.Parent = TextButton

															local Frame17 = Instance.new("Frame")

															Frame17.Size = UDim2.new(0, 0, 1, 0)
															Frame17.BackgroundColor3 = u20.Accent
															Frame17.BorderSizePixel = 0
															Frame17.Parent = TextButton

															local UICorner8 = Instance.new("UICorner")

															UICorner8.CornerRadius = UDim.new(0, 4)
															UICorner8.Parent = Frame17

															local UIGradient = Instance.new("UIGradient")

															UIGradient.Color = ColorSequence.new({
																ColorSequenceKeypoint.new(0, u20.AccentDim),
																ColorSequenceKeypoint.new(1, u20.Accent),
															})
															UIGradient.Parent = Frame17

															local Frame18 = Instance.new("Frame")

															Frame18.Size = UDim2.new(0, 12, 0, 12)
															Frame18.AnchorPoint = Vector2.new(0.5, 0.5)
															Frame18.Position = UDim2.new(0, 0, 0.5, 0)
															Frame18.BackgroundColor3 = u20.Accent
															Frame18.BorderSizePixel = 0
															Frame18.Parent = TextButton

															local UICorner9 = Instance.new("UICorner")

															UICorner9.CornerRadius = UDim.new(0, 6)
															UICorner9.Parent = Frame18

															local color3 = Color3.fromRGB(240, 240, 240)
															local UIStroke = Instance.new("UIStroke")

															UIStroke.Color = color3 or u20.Stroke
															UIStroke.Thickness = 1
															UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
															UIStroke.Parent = Frame18

															local u702 = math.clamp(p32, p29, p30)
															local u703 = false
															local u707 = p29
															local u708 = p30
															local u709 = p33

															local function v710()
																local v971 = (u702 - u707) / (u708 - u707)

																Frame17.Size = UDim2.new(v971, 0, 1, 0)
																Frame18.Position = UDim2.new(v971, 0, 0.5, 0)
																TextLabel10.Text = string.format("%g%s", u702, u709 or "")
															end

															local _ = TextButton

															v710()

															local InputBegan4 = TextButton.InputBegan
															local u718 = TextButton
															local u719 = p29
															local u720 = p30
															local u721 = p31
															local u722 = v710
															local u723 = p34

															InputBegan4:Connect(function(p35)
																if p35.UserInputType == Enum.UserInputType.MouseButton1
																	or p35.UserInputType == Enum.UserInputType.Touch then
																	u703 = true

																	local v984 = p35.Position.X - u718.AbsolutePosition.X
																	local AbsoluteSizeX = u718.AbsoluteSize.X
																	local v986 = v984 / math.max(AbsoluteSizeX, 1)
																	local v987 = math.clamp(v986, 0, 1)
																	local v988 = u719 + (u720 - u719) * v987
																	local v990 = (v988 - u719) / u721 + 0.5
																	local v991 = u719 + math.floor(v990) * u721

																	u702 = math.clamp(v991, u719, u720)
																	u722()
																	u723(u702)
																end
															end)

															local InputChanged = u21.InputChanged
															local u725 = TextButton
															local u726 = p29
															local u727 = p30
															local u728 = p31
															local u729 = v710
															local u730 = p34
															local connection6 = InputChanged:Connect(function(p36)
																if u703 and (p36.UserInputType == Enum.UserInputType.MouseMovement
																	or p36.UserInputType == Enum.UserInputType.Touch) then
																	local v995 = p36.Position.X - u725.AbsolutePosition.X
																	local AbsoluteSizeX = u725.AbsoluteSize.X
																	local v997 = v995 / math.max(AbsoluteSizeX, 1)
																	local v998 = math.clamp(v997, 0, 1)
																	local v999 = u726 + (u727 - u726) * v998
																	local v1001 = (v999 - u726) / u728 + 0.5
																	local v1002 = u726 + math.floor(v1001) * u728

																	u702 = math.clamp(v1002, u726, u727)
																	u729()
																	u730(u702)
																end
															end)

															t1[#t1 + 1] = connection6

															local connection7 = u21.InputEnded:Connect(function(input)
																if input.UserInputType == Enum.UserInputType.MouseButton1
																	or input.UserInputType == Enum.UserInputType.Touch then
																	u703 = false
																end
															end)

															t1[#t1 + 1] = connection7

															local t6 = {
																Frame = Frame16,
															}
															local u734 = p29
															local u735 = p31
															local u736 = p30
															local u737 = v710
															local u738 = p34

															function t6.SetValue(p37)
																local v1008 = (p37 - u734) / u735 + 0.5
																local v1009 = u734 + math.floor(v1008) * u735
																local v1012 = math.clamp(v1009, u734, u736)

																u702 = math.clamp(v1012, u734, u736)
																u737()
																u738(u702)
															end
															function t6.GetValue()
																return u702
															end

															return t6
														end
														function t4.CreateButton(_, p39, p40, p41)
															local TextButton = Instance.new("TextButton")

															TextButton.Size = UDim2.new(1, 0, 0, 32)
															TextButton.BackgroundColor3 = u20.Panel
															TextButton.Text = p39
															TextButton.TextColor3 = u20.Text
															TextButton.TextSize = 13
															TextButton.Font = Enum.Font.GothamSemibold
															TextButton.BorderSizePixel = 0
															TextButton.AutoButtonColor = false
															TextButton.Parent = p40

															local UICorner10 = Instance.new("UICorner")

															UICorner10.CornerRadius = UDim.new(0, 10)
															UICorner10.Parent = TextButton

															local Stroke = u20.Stroke
															local UIStroke = Instance.new("UIStroke")

															UIStroke.Color = Stroke or u20.Stroke
															UIStroke.Thickness = 1
															UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
															UIStroke.Parent = TextButton
															TextButton.MouseButton1Click:Connect(p41)

															local MouseEnter = TextButton.MouseEnter
															local u748 = TextButton
															local u749 = UIStroke

															MouseEnter:Connect(function()
																u24:Create(u748, TweenInfo.new(0.18), {
																	BackgroundColor3 = u20.PanelAlt,
																}):Play()
																u24:Create(u749, TweenInfo.new(0.18), {
																	Color = u20.Accent,
																}):Play()
															end)

															local MouseLeave = TextButton.MouseLeave
															local u751 = TextButton
															local u752 = UIStroke

															MouseLeave:Connect(function()
																u24:Create(u751, TweenInfo.new(0.18), {
																	BackgroundColor3 = u20.Panel,
																}):Play()
																u24:Create(u752, TweenInfo.new(0.18), {
																	Color = u20.Stroke,
																}):Play()
															end)
														end
														function t4.CreateInput(_, p43, p44, p45, p46, p47)
															local Frame19 = Instance.new("Frame")

															Frame19.Size = UDim2.new(1, 0, 0, 54)
															Frame19.BackgroundTransparency = 1
															Frame19.Parent = p44

															local TextLabel11 = Instance.new("TextLabel")

															TextLabel11.Size = UDim2.new(1, 0, 0, 16)
															TextLabel11.BackgroundTransparency = 1
															TextLabel11.Font = Enum.Font.Gotham
															TextLabel11.TextColor3 = u20.Text
															TextLabel11.TextSize = 13
															TextLabel11.TextXAlignment = Enum.TextXAlignment.Left
															TextLabel11.Text = p43
															TextLabel11.Parent = Frame19

															local Frame20 = Instance.new("Frame")

															Frame20.Size = UDim2.new(1, 0, 0, 30)
															Frame20.Position = UDim2.new(0, 0, 0, 20)
															Frame20.BackgroundColor3 = u20.Panel
															Frame20.BorderSizePixel = 0
															Frame20.Parent = Frame19

															local UICorner11 = Instance.new("UICorner")

															UICorner11.CornerRadius = UDim.new(0, 10)
															UICorner11.Parent = Frame20

															local Stroke = u20.Stroke
															local UIStroke = Instance.new("UIStroke")

															UIStroke.Color = Stroke or u20.Stroke
															UIStroke.Thickness = 1
															UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
															UIStroke.Parent = Frame20

															local TextBox = Instance.new("TextBox")

															TextBox.Size = UDim2.new(1, -16, 1, 0)
															TextBox.Position = UDim2.new(0, 8, 0, 0)
															TextBox.BackgroundTransparency = 1
															TextBox.Font = Enum.Font.GothamSemibold
															TextBox.TextSize = 12
															TextBox.TextColor3 = u20.Text
															TextBox.PlaceholderText = p45 or ""
															TextBox.PlaceholderColor3 = u20.GreyText
															TextBox.Text = ""
															TextBox.ClearTextOnFocus = false
															TextBox.Parent = Frame20

															local Focused = TextBox.Focused
															local u769 = UIStroke

															Focused:Connect(function()
																u24:Create(u769, TweenInfo.new(0.15), {
																	Color = u20.Accent,
																}):Play()
															end)

															local FocusLost = TextBox.FocusLost
															local u771 = UIStroke
															local u772 = TextBox

															FocusLost:Connect(function()
																u24:Create(u771, TweenInfo.new(0.15), {
																	Color = u20.Stroke,
																}):Play()

																local Text = u772.Text

																if p46 then
																	Text = tonumber(Text)

																	if Text == nil then
																		return
																	end
																end

																p47(Text)
															end)

															local t7 = {
																Frame = Frame19,
															}
															local u774 = TextBox

															function t7.SetValue(p48)
																u774.Text = tostring(p48)
															end

															local u775 = TextBox

															function t7.GetValue()
																return u775.Text
															end

															return t7
														end
														function t4.CreateDropdown(_, p50, p51, p52, p53, p54)
															local Frame21 = Instance.new("Frame")

															Frame21.Size = UDim2.new(1, 0, 0, 54)
															Frame21.BackgroundTransparency = 1
															Frame21.ClipsDescendants = false
															Frame21.Parent = p51

															local TextLabel12 = Instance.new("TextLabel")

															TextLabel12.Size = UDim2.new(1, 0, 0, 16)
															TextLabel12.BackgroundTransparency = 1
															TextLabel12.Font = Enum.Font.Gotham
															TextLabel12.TextColor3 = u20.Text
															TextLabel12.TextSize = 13
															TextLabel12.TextXAlignment = Enum.TextXAlignment.Left
															TextLabel12.Text = p50
															TextLabel12.Parent = Frame21

															local u784 = p52[p53] or p52[1]
															local u785 = false
															local TextButton = Instance.new("TextButton")

															TextButton.Size = UDim2.new(1, 0, 0, 30)
															TextButton.Position = UDim2.new(0, 0, 0, 20)
															TextButton.BackgroundColor3 = u20.Panel
															TextButton.BorderSizePixel = 0
															TextButton.AutoButtonColor = false
															TextButton.Text = u784
															TextButton.Font = Enum.Font.GothamSemibold
															TextButton.TextColor3 = u20.Text
															TextButton.TextSize = 12
															TextButton.Parent = Frame21

															local UICorner12 = Instance.new("UICorner")

															UICorner12.CornerRadius = UDim.new(0, 10)
															UICorner12.Parent = TextButton

															local Stroke = u20.Stroke
															local UIStroke = Instance.new("UIStroke")

															UIStroke.Color = Stroke or u20.Stroke
															UIStroke.Thickness = 1
															UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
															UIStroke.Parent = TextButton

															local Frame22 = Instance.new("Frame")

															Frame22.Size = UDim2.new(1, 0, 0, #p52 * 26)
															Frame22.Position = UDim2.new(0, 0, 0, 54)
															Frame22.BackgroundColor3 = u20.PanelAlt
															Frame22.BorderSizePixel = 0
															Frame22.ZIndex = 5
															Frame22.Visible = false
															Frame22.Parent = Frame21

															local UICorner13 = Instance.new("UICorner")

															UICorner13.CornerRadius = UDim.new(0, 10)
															UICorner13.Parent = Frame22

															local Accent = u20.Accent
															local UIStroke2 = Instance.new("UIStroke")

															UIStroke2.Color = Accent or u20.Stroke
															UIStroke2.Thickness = 1
															UIStroke2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
															UIStroke2.Parent = Frame22

															local UIListLayout = Instance.new("UIListLayout")

															UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
															UIListLayout.Parent = Frame22

															local t8 = {}

															for i, v in ipairs(p52) do
																local TextButton2 = Instance.new("TextButton")

																TextButton2.Size = UDim2.new(1, 0, 0, 26)
																TextButton2.BackgroundTransparency = 1
																TextButton2.BorderSizePixel = 0
																TextButton2.AutoButtonColor = false
																TextButton2.Text = v
																TextButton2.Font = Enum.Font.Gotham
																TextButton2.TextColor3 = v == u784 and u20.Accent or u20.SubText
																TextButton2.TextSize = 12
																TextButton2.ZIndex = 6
																TextButton2.LayoutOrder = i
																TextButton2.Parent = Frame22
																t8[i] = TextButton2

																local MouseButton1Click = TextButton2.MouseButton1Click
																local u800 = v
																local u801 = TextButton
																local u802 = Frame21
																local u803 = Frame22
																local u804 = t8
																local u805 = UIStroke
																local u806 = p54

																MouseButton1Click:Connect(function()
																	u784 = u800
																	u801.Text = u800 .. "  ▾"
																	u785 = false
																	u802.Size = UDim2.new(1, 0, 0, 54)
																	u803.Visible = false

																	for _, v3 in ipairs(u804) do
																		v3.TextColor3 = v3.Text == u784 and u20.Accent or u20.SubText
																	end

																	u24:Create(u805, TweenInfo.new(0.15), {
																		Color = u20.Stroke,
																	}):Play()
																	u806(u800)
																end)
															end

															local MouseButton1Click = TextButton.MouseButton1Click
															local u808 = Frame22
															local u809 = Frame21
															local u810 = p52
															local u811 = UIStroke

															MouseButton1Click:Connect(function()
																u785 = not u785
																u808.Visible = u785

																if not u785 then
																	u809.Size = UDim2.new(1, 0, 0, 54)
																	u24:Create(u811, TweenInfo.new(0.15), {
																		Color = u20.Stroke,
																	}):Play()

																	return
																end

																u809.Size = UDim2.new(1, 0, 0, 54 + #u810 * 26 + 4)
																u24:Create(u811, TweenInfo.new(0.15), {
																	Color = u20.Accent,
																}):Play()
															end)

															local t9 = {
																Frame = Frame21,
															}
															local u813 = TextButton
															local u814 = t8
															local u815 = p54

															function t9.SetValue(p55)
																u784 = p55
																u813.Text = p55 .. "  ▾"

																for _, v in ipairs(u814) do
																	v.TextColor3 = v.Text == u784 and u20.Accent or u20.SubText
																end

																u815(p55)
															end
															function t9.GetValue()
																return u784
															end

															return t9
														end

														local u320 = ScreenGui

														function t4.Destroy(_)
															u320:Destroy()
														end

														return t4
													end
												end

												t10 = {
													wsLoop = nil,
													wsCA = nil,
												}
												u27 = nil
												s1 = "Disabled"
												n4 = 0

												local u30 = t10
												local u31 = RunService
												local u32 = LocalPlayer

												function u33(p57, p58, p59)
													local Humanoid = p57:FindFirstChildOfClass("Humanoid")
													local HumanoidRootPart = p57:FindFirstChild("HumanoidRootPart")

													if Humanoid and HumanoidRootPart then
														if u30.wsLoop then
															u30.wsLoop:Disconnect()
														end

														if u30.wsCA then
															u30.wsCA:Disconnect()
														end

														local u328 = u27

														if u27 then
															u27:Disconnect()
														end

														if p59 ~= "CFrame Speed" then
															if p59 ~= "Velocity Speed" then
																if p59 == "Loop WalkSpeed" then
																	local u330 = p58

																	function u328()
																		if p57 and Humanoid then
																			Humanoid.WalkSpeed = u330
																		end
																	end

																	if p57 and Humanoid then
																		Humanoid.WalkSpeed = p58
																	end

																	u30.wsLoop = Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(u328)
																	local CharacterAdded = u32.CharacterAdded
																	local u333 = p58

																	u30.wsCA = CharacterAdded:Connect(function(p60)
																		local Humanoid2 = p60:WaitForChild("Humanoid")

																		p57 = p60
																		Humanoid = Humanoid2

																		if p60 and Humanoid2 then
																			Humanoid2.WalkSpeed = u333
																		end

																		local v820 = u30

																		if u30.wsLoop then
																			if u30.wsLoop:Disconnect() then
																			end
																		end

																		v820.wsLoop = Humanoid2:GetPropertyChangedSignal("WalkSpeed"):Connect(u328)
																	end)
																end
															else
																local Heartbeat = u31.Heartbeat
																local u335 = HumanoidRootPart
																local u336 = p58

																u328 = Heartbeat:Connect(function()
																	if p57 and u335 and Humanoid.MoveDirection.Magnitude > 0 then
																		local v817 = Humanoid.MoveDirection * u336

																		u335.Velocity = Vector3.new(v817.X, u335.Velocity.Y, v817.Z)
																	end
																end)
																u27 = u328
															end
														else
															local Heartbeat = u31.Heartbeat
															local u338 = HumanoidRootPart
															local u339 = p58

															u328 = Heartbeat:Connect(function()
																if p57 and u338 and Humanoid.MoveDirection.Magnitude > 0 then
																	u338.CFrame = u338.CFrame + Humanoid.MoveDirection * u339 / 50
																end
															end)
															u27 = u328
														end

														return
													end
												end
											end

											t11 = {
												jpLoop = nil,
												jpCA = nil,
											}
											s2 = "Disabled"
											n5 = 0

											local u37 = t11
											local u38 = LocalPlayer

											function u39(p61, p62, p63)
												local Humanoid = p61:FindFirstChildOfClass("Humanoid")

												if Humanoid then
													if u37.jpLoop then
														u37.jpLoop:Disconnect()
													end

													if u37.jpCA then
														u37.jpCA:Disconnect()
													end

													if p63 ~= "Disabled" then
														local u345 = p62

														local function v346()
															if Humanoid then
																Humanoid.UseJumpPower = true
																Humanoid.JumpPower = u345
															end
														end

														if Humanoid then
															Humanoid.UseJumpPower = true
															Humanoid.JumpPower = p62
														end

														u37.jpLoop = Humanoid:GetPropertyChangedSignal("JumpPower"):Connect(v346)
														local CharacterAdded = u38.CharacterAdded
														local u349 = p62
														local u350 = v346

														u37.jpCA = CharacterAdded:Connect(function(p64)
															local Humanoid3 = p64:WaitForChild("Humanoid")

															p61 = p64
															Humanoid = Humanoid3

															if Humanoid3 then
																Humanoid3.UseJumpPower = true
																Humanoid3.JumpPower = u349
															end

															local v823 = u37

															if u37.jpLoop then
																if u37.jpLoop:Disconnect() then
																end
															end

															v823.jpLoop = Humanoid3:GetPropertyChangedSignal("JumpPower"):Connect(u350)
														end)

														return
													end

													return
												end
											end
											local u40 = nil

											local u41 = UserInputService
											local u42 = LocalPlayer

											function u43(p65)
												if not p65 then
													if u40 then
														u40:Disconnect()
														u40 = nil
													end

													return
												end

												u40 = u41.InputBegan:Connect(function(input, gameProcessed)
													if not gameProcessed then
														if
															input.UserInputType == Enum.UserInputType.Touch
															or input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.Space
														then
															local Character = u42.Character

															if Character then
																local Humanoid = Character:FindFirstChildOfClass("Humanoid")

																if Humanoid then
																	Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
																end
															end
														end

														return
													end
												end)
											end

											u44 = false
											n6 = 100
											t12 = {}
											t13 = {
												Forward = 0,
												Backward = 0,
												Left = 0,
												Right = 0,
												Up = 0,
												Down = 0,
											}

											local u48 = LocalPlayer

											function v49()
												u44 = false

												for _, v in ipairs(t12) do
													v:Disconnect()
												end

												t12 = {}

												local Character = u48.Character

												if Character then
													local Humanoid = Character:FindFirstChildOfClass("Humanoid")

													if Humanoid then
														Humanoid.PlatformStand = false
													end

													local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")

													if HumanoidRootPart then
														for _, child in ipairs(HumanoidRootPart:GetChildren()) do
															if child:IsA("BodyGyro") or child:IsA("BodyVelocity") then
																child:Destroy()
															end
														end
													end
												end
											end
										end

										local u50 = LocalPlayer
										local u51 = v49
										local u52 = RunService
										local u53 = Workspace
										local u54 = t13
										local u55 = UserInputService

										function u56()
											local function v359(...)
												local t14 = { ... }

												t14.n = select("#", ...)

												return t14
											end

											local Character = u50.Character

											if Character then
												local v361 = Character:FindFirstChild("HumanoidRootPart") or Character:FindFirstChild("Torso")

												if v361 then
													u51()

													local BodyGyro = Instance.new("BodyGyro")

													BodyGyro.P = 10000
													BodyGyro.maxTorque = Vector3.new(1e999, 1e999, 1e999)
													BodyGyro.cframe = v361.CFrame
													BodyGyro.Parent = v361

													local BodyVelocity = Instance.new("BodyVelocity")

													BodyVelocity.velocity = Vector3.new(0, 0, 0)
													BodyVelocity.maxForce = Vector3.new(1e999, 1e999, 1e999)
													BodyVelocity.Parent = v361
													u44 = true

													local Humanoid = Character:FindFirstChildOfClass("Humanoid")

													if Humanoid then
														Humanoid.PlatformStand = true
													end
													local Heartbeat = u52.Heartbeat
													local u367 = BodyVelocity
													local u368 = BodyGyro
													local v369 = v359(Heartbeat:Connect(function()
														if u44 then
															local CurrentCamera = u53.CurrentCamera
															local vector3_2 = Vector3.new(u54.Right - u54.Left, u54.Up - u54.Down, u54.Forward - u54.Backward)

															if not (vector3_2.Magnitude > 0) then
																u367.velocity = Vector3.new(0, 0, 0)
															else
																u367.velocity = (
																	CurrentCamera.CFrame.LookVector * vector3_2.Z
																	+ CurrentCamera.CFrame.RightVector * vector3_2.X
																	+ Vector3.new(0, 1, 0) * vector3_2.Y
																) * n6
															end

															u368.cframe = CurrentCamera.CFrame

															return
														end
													end))

													table.insert(t12, unpack(v369, 1, v369.n))
													local v374 = v359(u55.InputBegan:Connect(function(input, gameProcessed)
														if not gameProcessed then
															local v833 = input.KeyCode.Name:lower()

															if v833 ~= "w" then
																if v833 ~= "s" then
																	if v833 ~= "a" then
																		if v833 ~= "d" then
																			if v833 ~= "e" then
																				if v833 == "q" then
																					u54.Down = 1
																				end

																				return
																			end

																			u54.Up = 1

																			return
																		end

																		u54.Right = 1

																		return
																	end

																	u54.Left = 1

																	return
																end

																u54.Backward = 1

																return
															end

															u54.Forward = 1

															return
														end
													end))

													table.insert(t12, unpack(v374, 1, v374.n))
													local v379 = v359(u55.InputEnded:Connect(function(input)
														local v835 = input.KeyCode.Name:lower()

														if v835 ~= "w" then
															if v835 ~= "s" then
																if v835 ~= "a" then
																	if v835 ~= "d" then
																		if v835 ~= "e" then
																			if v835 == "q" then
																				u54.Down = 0
																			end

																			return
																		end

																		u54.Up = 0

																		return
																	end

																	u54.Right = 0

																	return
																end

																u54.Left = 0

																return
															end

															u54.Backward = 0

															return
														end

														u54.Forward = 0
													end))

													table.insert(t12, unpack(v379, 1, v379.n))

													return
												end

												return
											end
										end
									end

									t15 = {
										front = {
											animationId = "rbxassetid://10479335397",
											speed = 100,
											duration = 0.6,
											maxForce = 100000000,
											pValue = 100000000,
											obstacleDistance = 6,
											enabled = false,
											direction = function(p66)
												return p66.CFrame.LookVector
											end,
										},
										left = {
											animationId = "rbxassetid://10480796021",
											speed = 150,
											duration = 0.25,
											maxForce = 100000000,
											pValue = 100000000,
											enabled = false,
											direction = function(p67)
												return -p67.CFrame.RightVector
											end,
										},
										right = {
											animationId = "rbxassetid://10480793962",
											speed = 150,
											duration = 0.25,
											maxForce = 100000000,
											pValue = 100000000,
											enabled = false,
											direction = function(p68)
												return p68.CFrame.RightVector
											end,
										},
										back = {
											animationId = "rbxassetid://10491993682",
											speed = 100,
											duration = 0.5,
											enabled = false,
											direction = function(p69)
												return -p69.CFrame.LookVector
											end,
											requiresExistingBV = true,
										},
									}
									t16 = {}
									local t17 = {}

									function v60()
										for _, v in pairs(t16) do
											if v and v.Connected then
												v:Disconnect()
											end
										end

										t16 = {}
										t17 = {}
									end

									local u61 = t15

									local function u62(p70)
										for _, child in pairs(p70:GetChildren()) do
											if child:IsA("BodyVelocity") then
												return child
											end
										end
									end

									local u63 = LocalPlayer
									local u64 = RunService
									local u65 = Workspace

									function v66(p71, p72, p73)
										local v395 = u61[p72]
										local u396 = u62(p71)
										local speed = v395.speed

										if p72 ~= "front" then
											if p72 ~= "left" and p72 ~= "right" then
												if p72 == "back" and v395.requiresExistingBV and not u396 then
													return
												end
											elseif not u396 then
												u396 = Instance.new("BodyVelocity")
												u396.MaxForce = Vector3.new(v395.maxForce, 0, v395.maxForce)
												u396.P = v395.pValue
												u396.Parent = p71
											end
										elseif not u396 then
											u396 = Instance.new("BodyVelocity")
											u396.MaxForce = Vector3.new(v395.maxForce, 0, v395.maxForce)
											u396.P = v395.pValue
											u396.Parent = p71
										else
											speed = u396.Velocity.Magnitude * v395.speed
										end

										if u396 then
											local u398 = false
											local v399 = p72 .. "_" .. tick()

											t17[v399] = true

											local raycastParams = nil

											if p72 == "front" then
												raycastParams = RaycastParams.new()
												raycastParams.FilterDescendantsInstances = {
													u63.Character,
												}
												raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
											end
											local connection8 = nil

											if p73 then
												local Stopped = p73.Stopped
												local u405 = p72
												local u406 = v399

												connection8 = Stopped:Connect(function()
													local v837 = connection8

													if not u398 then
														if not u396 or not u396.Parent or u405 == "back" then
															if u396 and u405 == "back" then
																u396.Velocity = Vector3.zero
															end
														else
															u396:Destroy()
														end

														if v837 and v837.Connected then
															v837:Disconnect()
														end

														t17[u406] = nil
														u398 = true

														return
													end
												end)
											end

											local connection9 = nil
											local Heartbeat = u64.Heartbeat
											local u409 = v395
											local u410 = p72
											local u411 = v399
											local u412 = p73
											local u413 = p71

											connection9 = Heartbeat:Connect(function()
												if u396 and (u396.Parent and not u398 and u409.enabled) then
													if not u412 or u412.IsPlaying then
														if u410 == "front" and raycastParams then
															local raycastResult =
																u65:Raycast(u413.Position, u409.direction(u413) * u409.obstacleDistance, raycastParams)

															if raycastResult and raycastResult.Instance then
																local v839 = connection9

																if not u398 then
																	if not u396 or not u396.Parent or u410 == "back" then
																		if u396 and u410 == "back" then
																			u396.Velocity = Vector3.zero
																		end
																	else
																		u396:Destroy()
																	end

																	if v839 and v839.Connected then
																		v839:Disconnect()
																	end

																	t17[u411] = nil
																	u398 = true

																	return
																end

																return
															end
														end

														u396.Velocity = u409.direction(u413) * speed

														return
													end

													local v840 = connection9

													if not u398 then
														if not u396 or not u396.Parent or u410 == "back" then
															if u396 and u410 == "back" then
																u396.Velocity = Vector3.zero
															end
														else
															u396:Destroy()
														end

														if v840 and v840.Connected then
															v840:Disconnect()
														end

														t17[u411] = nil
														u398 = true

														return
													end

													return
												end

												local v841 = connection9

												if not u398 then
													if not u396 or not u396.Parent or u410 == "back" then
														if u396 and u410 == "back" then
															u396.Velocity = Vector3.zero
														end
													else
														u396:Destroy()
													end

													if v841 and v841.Connected then
														v841:Disconnect()
													end

													t17[u411] = nil
													u398 = true

													return
												end
											end)

											local delay = task.delay
											local duration = v395.duration
											local u416 = p72
											local u417 = v399

											delay(duration, function()
												if not u398 then
													local v842 = connection9

													if not u398 then
														if not u396 or not u396.Parent or u416 == "back" then
															if u396 and u416 == "back" then
																u396.Velocity = Vector3.zero
															end
														else
															u396:Destroy()
														end

														if v842 and v842.Connected then
															v842:Disconnect()
														end

														t17[u417] = nil
														u398 = true
													end

													if connection8 and connection8.Connected then
														connection8:Disconnect()
													end
												end
											end)

											return
										end
									end
								end

								v60()

								if LocalPlayer.Character then
									local Character = LocalPlayer.Character

									if Character then
										local v76, AnimationPlayed

										do
											local Humanoid = Character:WaitForChild("Humanoid")

											v76 = #t16 + 1
											AnimationPlayed = Humanoid.AnimationPlayed
										end

										local u78 = Character
										local u79 = t15
										local u80 = v66

										t16[v76] = AnimationPlayed:Connect(function(p74)
											local AnimationId = p74.Animation.AnimationId
											local HumanoidRootPart = u78:FindFirstChild("HumanoidRootPart")

											if HumanoidRootPart then
												for k, v in pairs(u79) do
													if v.enabled and AnimationId == v.animationId then
														u80(HumanoidRootPart, k, p74)

														return
													end
												end

												return
											end
										end)
									end
								end

								local v81 = #t16 + 1
								local CharacterAdded = LocalPlayer.CharacterAdded
								local u83 = v60
								local u84 = LocalPlayer
								local u85 = t15
								local u86 = v66

								t16[v81] = CharacterAdded:Connect(function()
									u83()
									task.wait(0.1)

									local Character = u84.Character

									if Character then
										local Humanoid = Character:WaitForChild("Humanoid")
										local v438 = #t16 + 1
										local AnimationPlayed = Humanoid.AnimationPlayed
										local u440 = Character

										t16[v438] = AnimationPlayed:Connect(function(p75)
											local AnimationId = p75.Animation.AnimationId
											local HumanoidRootPart = u440:FindFirstChild("HumanoidRootPart")

											if HumanoidRootPart then
												for k, v in pairs(u85) do
													if v.enabled and AnimationId == v.animationId then
														u86(HumanoidRootPart, k, p75)

														return
													end
												end

												return
											end
										end)

										return
									end
								end)
							end

							local u89 = nil
							local u90 = RunService
							local u91 = LocalPlayer
							local s3 = "Ragdoll"

							function u93(p76)
								if not p76 then
									if u89 then
										u89:Disconnect()
										u89 = nil
									end

									return
								end

								u89 = u90.RenderStepped:Connect(function()
									local Character = u91.Character

									if Character then
										local s3_2 = Character:FindFirstChild(s3)

										if s3_2 then
											s3_2:Destroy()
										end
									end
								end)
							end

							local u94 = nil
							local u95 = RunService
							local u96 = LocalPlayer
							local s4 = "Freeze"

							function u98(p77)
								if not p77 then
									if u94 then
										u94:Disconnect()
										u94 = nil
									end

									return
								end

								u94 = u95.RenderStepped:Connect(function()
									local Character = u96.Character

									if Character then
										local s4_2 = Character:FindFirstChild(s4)

										if s4_2 then
											s4_2:Destroy()
										end
									end
								end)
							end
						end

						local u99 = nil
						local u100 = RunService
						local u101 = LocalPlayer
						local s5 = "NoJump"

						function u103(p78)
							if not p78 then
								if u99 then
									u99:Disconnect()
									u99 = nil
								end

								return
							end

							u99 = u100.RenderStepped:Connect(function()
								local Character = u101.Character

								if Character then
									local s5_2 = Character:FindFirstChild(s5)

									if s5_2 then
										s5_2:Destroy()
									end
								end
							end)
						end

						local u104 = nil
						local u105 = RunService
						local u106 = LocalPlayer
						local s6 = "Slowed"

						function u108(p79)
							if not p79 then
								if u104 then
									u104:Disconnect()
									u104 = nil
								end

								return
							end

							u104 = u105.RenderStepped:Connect(function()
								local Character = u106.Character

								if Character then
									local s6_2 = Character:FindFirstChild(s6)

									if s6_2 then
										s6_2:Destroy()
									end
								end
							end)
						end
					end

					u109 = nil
					u110 = RunService
					u111 = LocalPlayer
					u112 = nil
					u113 = nil
					u114 = LocalPlayer
					t18 = {}

					local t19 = {
						name = "No Block Animation",
						id = "rbxassetid://10470389827",
					}
					local t20 = {
						name = "Prey's Peril",
						id = "rbxassetid://12351854556",
					}
					local t21 = {
						name = "Omni Directional Punch",
						id = "rbxassetid://13927612951",
					}
					local t22 = {
						name = "Serious Punch",
						id = "rbxassetid://12983333733",
					}
					local t23 = {
						name = "Table Flip",
						id = "rbxassetid://11365563255",
					}
					local t24 = {
						name = "Hold Trashcan",
						id = "rbxassetid://13813448561",
					}

					t18[1] = t19
					t18[2] = t20
					t18[3] = t21
					t18[4] = t22
					t18[5] = t23
					t18[6] = t24
					t25 = {}
					t26 = {}

					for i, _ in ipairs(t18) do
						t25[i] = false
						t26[i] = nil
					end

					local u126 = t26
					local u127 = t25
					local u128 = t18

					function v129(p80, p81)
						if u126[p80] then
							u126[p80]:Disconnect()
						end

						local v454 = p81 and p81:FindFirstChildOfClass("Humanoid")

						if v454 and u127[p80] then
							local id = u128[p80].id
							local AnimationPlayed = v454.AnimationPlayed
							local u458 = id

							u126[p80] = AnimationPlayed:Connect(function(p82)
								if p82.Animation.AnimationId == u458 then
									p82:Stop()
								end
							end)

							return
						end
					end
				end

				local CharacterAdded = LocalPlayer.CharacterAdded
				local u131 = t18
				local u132 = v129
				local connection10 = CharacterAdded:Connect(function(p83)
					for i = 1, #u131 do
						u132(i, p83)
					end
				end)

				t1[#t1 + 1] = connection10

				Part = Instance.new("Part")
				Part.Size = Vector3.new(20, 20, 20)
				Part.Transparency = 1
				Part.Anchored = true
				Part.CanCollide = false
				Part.Name = "ArmouredM1Zone"
				Part.Parent = Workspace
				u139 = false
				local t27 = {}
				local u141 = false

				local Heartbeat = RunService.Heartbeat
				local u143 = LocalPlayer
				local u144 = Part
				local u145 = Players

				connection = Heartbeat:Connect(function()
					if u139 then
						local Character = u143.Character
						local v464 = Character and Character:FindFirstChild("HumanoidRootPart")

						if v464 then
							u144.Position = v464.Position
						end

						local t28 = {}

						for _, player in ipairs(u145:GetPlayers()) do
							if player ~= u143 and player.Character then
								local HumanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")

								if HumanoidRootPart and (HumanoidRootPart.Position - u144.Position).Magnitude <= u144.Size.X / 2 then
									table.insert(t28, player)
								end
							end
						end

						t27 = t28
						u141 = #t28 > 0

						if u141 then
							local Character2 = u143.Character
							local v470 = Character2 and Character2:FindFirstChild("HumanoidRootPart")

							if not v470 then
								return
							end

							local v471 = nil
							local n7 = 1e999

							for _, v in ipairs(t27) do
								if v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
									local Magnitude = (v.Character.HumanoidRootPart.Position - v470.Position).Magnitude

									if Magnitude < n7 then
										n7 = Magnitude
										v471 = v
									end
								end
							end

							if v471 then
								local Character3 = u143.Character

								if Character3 and Character3:FindFirstChild("M1ing") and v471.Character then
									local HumanoidRootPart = v471.Character:FindFirstChild("HumanoidRootPart")

									if HumanoidRootPart then
										local v478 = HumanoidRootPart.CFrame.LookVector * -3
										v470.CFrame = CFrame.new(HumanoidRootPart.Position + v478, HumanoidRootPart.Position)
									end
								end
							end
						end

						return
					end
				end)
			end

			t1[#t1 + 1] = connection
			u147 = false
			u148 = nil
			n8 = 20
			n9 = 0.5
			local u151 = nil
			local u152 = nil
			local t29 = {}
			u154 = nil
			local u156 = LocalPlayer

			function v157()
				if u151 then
					u151:Disconnect()
					u151 = nil
				end

				if u152 then
					u152:Disconnect()
					u152 = nil
				end

				for _, _ in pairs(t29) do
					local Character = u156.Character

					if Character and Character:FindFirstChild("Communicate") then
						Character:FindFirstChild("Communicate"):FireServer({
							{
								Goal = "KeyRelease",
								Key = Enum.KeyCode.F,
							},
						})
					end
				end

				t29 = {}
			end

			local u158 = v157
			local u159 = Workspace
			local u160 = RunService
			local u161 = LocalPlayer
			local u162 = Players

			function v163()
				u158()

				if not u148 then
					u148 = Instance.new("Part")
					u148.Size = Vector3.new(n8, n8, n8)
					u148.Transparency = n9
					u148.Anchored = true
					u148.CanCollide = false
					u148.Name = "ArmouredShieldZone"
					u148.Parent = u159
				end

				u152 = u160.Heartbeat:Connect(function()
					if u148 and u161.Character then
						local Character = u161.Character
						local v885 = Character and Character:FindFirstChild("HumanoidRootPart")

						if v885 then
							u148.Position = v885.Position
						end
					end
				end)
				u151 = u160.Heartbeat:Connect(function()
					local Character = u161.Character

					if Character and Character:FindFirstChild("Communicate") then
						for _, player in ipairs(u162:GetPlayers()) do
							if player ~= u161 and player.Character then
								local HumanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
								local v890 = HumanoidRootPart and (u148 and (HumanoidRootPart.Position - u148.Position).Magnitude <= u148.Size.X / 2)
								local M1ing = player.Character:FindFirstChild("M1ing")

								if not v890 then
									if t29[player] then
										t29[player] = nil
										Character:FindFirstChild("Communicate"):FireServer({
											{
												Goal = "KeyRelease",
												Key = Enum.KeyCode.F,
											},
										})
									end
								else
									if M1ing and not t29[player] then
										t29[player] = true
										Character:FindFirstChild("Communicate"):FireServer({
											{
												Goal = "KeyPress",
												Key = Enum.KeyCode.F,
											},
										})
									end

									if not M1ing and t29[player] then
										t29[player] = nil
										Character:FindFirstChild("Communicate"):FireServer({
											{
												Goal = "KeyRelease",
												Key = Enum.KeyCode.F,
											},
										})
									end
								end
							end
						end

						return
					end
				end)
			end
			local CharacterAdded = LocalPlayer.CharacterAdded
			local u166 = LocalPlayer
			local u167 = v157
			local u168 = v163

			u154 = CharacterAdded:Connect(function()
				if u147 then
					task.wait(1)

					if u148 then
						local Character = u166.Character
						local v483 = Character and Character:FindFirstChild("HumanoidRootPart")

						if v483 then
							u148.Position = v483.Position
						end

						u167()
						u168()

						return
					end

					u168()
				end
			end)
		end

		u169 = false
		u170 = true
		n10 = 100
		u172 = nil
		local u173 = nil

		function u174(p84)
			if p84 then
				local Humanoid = p84:WaitForChild("Humanoid")
				local HumanoidRootPart = p84:WaitForChild("HumanoidRootPart")

				if u172 then
					u172:Disconnect()
				end

				if u169 then
					local AnimationPlayed = Humanoid.AnimationPlayed
					local u488 = HumanoidRootPart

					u172 = AnimationPlayed:Connect(function(p85)
						if u169 and p85.Animation.AnimationId == "rbxassetid://12296113986" then
							u173 = u488.CFrame
							task.wait(1)
							u488.CFrame = CFrame.new(u488.Position.X, u488.Position.Y + n10, u488.Position.Z)

							local connection = nil
							p85.Stopped:Connect(function()
								if u173 and u170 then
									u488.CFrame = u173
								end

								u173 = nil
								connection:Disconnect()
							end)
						end
					end)

					return
				end

				return
			end
		end

		u174(LocalPlayer.Character)
		LocalPlayer.CharacterAdded:Connect(u174)
		u175 = false
		u176 = false
		u177 = nil
		local u178 = nil
		s7 = "Void"
		t30 = {
			Void = CFrame.new(0, -492, 0),
			["Atomic Room"] = CFrame.new(1079, 155, 23003),
			["Death Counter Room"] = CFrame.new(-92, 29, 20347),
			Baseplate = CFrame.new(968, 20, 23088),
			["Middle of Map"] = CFrame.new(148, 441, 27),
			["Mountain 1"] = CFrame.new(266, 699, 458),
			["Mountain 2"] = CFrame.new(551, 630, -265),
			["Mountain 3"] = CFrame.new(-107, 642, -328),
		}
		Void = t30.Void
		local t31 = {
			"rbxassetid://12296113986",
			"rbxassetid://12273188754",
		}

		function v183(p86)
			if p86 then
				local Humanoid = p86:WaitForChild("Humanoid")
				local HumanoidRootPart = p86:WaitForChild("HumanoidRootPart")

				if u177 then
					u177:Disconnect()
				end

				if u175 then
					local AnimationPlayed = Humanoid.AnimationPlayed
					local u493 = HumanoidRootPart

					u177 = AnimationPlayed:Connect(function(p87)
						if u175 then
							for _, v in ipairs(t31) do
								if v == p87.Animation.AnimationId then
									if u176 then
										u178 = u493.CFrame
									end

									task.wait(1)
									u493.CFrame = Void

									if not u176 then
										return
									end

									local connection = nil

									connection = p87.Stopped:Connect(function()
										if u178 then
											u493.CFrame = u178
											u178 = nil
										end

										connection:Disconnect()
									end)

									return
								end
							end

							return
						end
					end)

					return
				end

				return
			end
		end

		v183(LocalPlayer.Character)
		LocalPlayer.CharacterAdded:Connect(v183)
		vector3 = Vector3.new(0, 0, 0)
		t32 = {}
		u186 = nil
		u187 = nil
		u188 = nil
		local u189 = nil

		local u190 = t32

		local function v191(p88)
			u188 = p88:WaitForChild("Humanoid")
			u189 = p88:WaitForChild("HumanoidRootPart")

			if u186 then
				local Animation = Instance.new("Animation")

				Animation.AnimationId = "rbxassetid://" .. tostring(u186)
				u187 = u188:LoadAnimation(Animation)
			end

			u188.AnimationPlayed:Connect(function(animation)
				if u190[animation.Animation.AnimationId] then
					animation:Stop()

					if u189.Velocity.Magnitude > 1 and u187 and not u187.IsPlaying then
						u187.Looped = true
						u187:Play()
					end
				end
			end)
		end

		local connection = RunService.RenderStepped:Connect(function()
			if u187 and u187.IsPlaying and u189 and u189.Velocity.Magnitude <= 1 then
				u187:Stop()
			end
		end)

		t1[#t1 + 1] = connection
		LocalPlayer.CharacterAdded:Connect(v191)

		if LocalPlayer.Character then
			v191(LocalPlayer.Character)
		end

		u193 = nil
		u194 = nil
		local u195 = nil
		u196 = nil

		function u197(p89)
			if u194 then
				u194:Stop()
			end

			if u196 and p89 and p89 ~= "rbxassetid://0" then
				u193 = p89

				local Animation = Instance.new("Animation")

				Animation.AnimationId = p89
				u194 = u196:LoadAnimation(Animation)
				u194:Play()

				return
			end

			u193 = nil
		end

		LocalPlayer.CharacterAdded:Connect(function(character)
			u195 = character:WaitForChild("Humanoid")
			u196 = u195:FindFirstChildOfClass("Animator") or u195:WaitForChild("Animator")
			u194 = nil
		end)

		if LocalPlayer.Character then
			u195 = LocalPlayer.Character:WaitForChild("Humanoid")
			u196 = u195:FindFirstChildOfClass("Animator") or u195:WaitForChild("Animator")
			u194 = nil
		end

		task.spawn(function()
			while true do
				if u195 and u193 then
					if not (u195.MoveDirection.Magnitude > 0) then
						if (not u194 or not u194.IsPlaying) and u196 then
							local Animation = Instance.new("Animation")

							Animation.AnimationId = u193
							u194 = u196:LoadAnimation(Animation)
							u194:Play()
						end
					elseif u194 and u194.IsPlaying then
						u194:Stop()
					end
				end

				task.wait(0.1)
			end
		end)
		t33 = {}
		s8 = "Fist"
		u200 = nil
		local u201 = nil
		local u202 = nil
		local t34 = {
			Fist = {
				10469493270,
				10469630950,
				10469639222,
				10469643643,
			},
			Bat = {
				14004222985,
				13997092940,
				14001963401,
				14136436157,
			},
			Ninjato = {
				13370310513,
				13390230973,
				13378751717,
				13378708199,
			},
			Katana = {
				15259161390,
				15240216931,
				15240176873,
				15162694192,
			},
			LightningFist = {
				89044067797964,
				74334194837918,
				94353845974131,
				80601239139774,
			},
			HunterFist = {
				13532562418,
				13532600125,
				13532604085,
				13294471966,
			},
			CyborgFist = {
				13491635433,
				13296577783,
				13295919399,
				13295936866,
			},
			EsperFist = {
				16515503507,
				16515520431,
				16515448089,
				16552234590,
			},
			KJFist = {
				17325510002,
				17325513870,
				17325522388,
				17325537719,
			},
			PurpleFist = {
				17889458563,
				17889461810,
				17889471098,
				17889290569,
			},
		}

		function v204(p90)
			t33 = {}
			u200 = p90

			if p90 then
				local v504 = t34[s8]
				local v505 = t34[p90]

				if v504 and v505 then
					for i = 1, #v504 do
						if v505[i] then
							t33["rbxassetid://" .. v504[i]] = "rbxassetid://" .. v505[i]
						end
					end

					return
				end

				return
			end
		end

		local u205 = v204

		local function v206(p91)
			u201 = p91:WaitForChild("Humanoid")
			u202 = p91:WaitForChild("HumanoidRootPart")

			local connection11 = u201.AnimationPlayed:Connect(function(animation)
				local v900 = t33[animation.Animation.AnimationId]

				if v900 then
					animation:Stop()

					local spawn = task.spawn
					local u902 = v900

					spawn(function()
						task.wait(0.1)

						local Animation = Instance.new("Animation")

						Animation.AnimationId = u902
						u201:LoadAnimation(Animation):Play()
					end)
				end
			end)
			local AncestryChanged = p91.AncestryChanged
			local u511 = p91

			AncestryChanged:Connect(function()
				if not u511.Parent then
					connection11:Disconnect()
				end
			end)

			if u200 then
				task.spawn(function()
					task.wait(1)
					u205(u200)
				end)
			end
		end

		LocalPlayer.CharacterAdded:Connect(v206)

		if LocalPlayer.Character then
			v206(LocalPlayer.Character)
		end
		local u207 = false

		local u208 = Workspace

		function v209(p92)
			u207 = p92

			if not p92 then
				local VoidProtection = u208:FindFirstChild("VoidProtection")

				if VoidProtection then
					VoidProtection:Destroy()
				end
			elseif not u208:FindFirstChild("VoidProtection") then
				local Part2 = Instance.new("Part")

				Part2.Size = Vector3.new(10000, 10, 10000)
				Part2.Position = Vector3.new(0, -500, 0)
				Part2.Anchored = true
				Part2.CanCollide = true
				Part2.Transparency = 0.5
				Part2.Color = Color3.fromRGB(255, 0, 0)
				Part2.Name = "VoidProtection"
				Part2.Parent = u208

				return
			end
		end

		u210 = nil

		local u211 = v49
		local u212 = v157
		local u213 = v209
		local u214 = Part

		function u215()
			if not u10 then
				u10 = true
				u211()
				u212()

				if u154 then
					u154:Disconnect()
					u154 = nil
				end

				if u148 then
					u148:Destroy()
					u148 = nil
				end

				u213(false)

				if u214 then
					u214:Destroy()
				end

				for _, v in ipairs(t1) do
					local _pcall = pcall
					local u518 = v

					pcall(function()
						u518:Disconnect()
					end)
				end

				t1 = {}

				if u210 then
					pcall(function()
						u210:Destroy()
					end)
				end

				u8()

				if _G.ArmouredTSBShutdown == u215 then
					_G.ArmouredTSBShutdown = nil
				end

				return
			end
		end

		_G.ArmouredTSBShutdown = u215
		u216 = t3


		-- Rayfield Gen2 bridge ----------------------------------------------------
		-- Keeps the original Galaxy feature callbacks intact while replacing the
		-- old fixed-size custom GUI with Rayfield Gen2. If Rayfield cannot load,
		-- the original Galaxy UI is used as a fallback.
		local GalaxyOriginalUI = t3
		local GalaxyRayfieldBridge = {}

		local GalaxyTabIcons = {
			Movement = "user",
			Exploits = "zap",
			Combat = "swords",
			Teleports = "map-pin",
			Animations = "play",
			["Target Farm"] = "target",
			["Rage Kill"] = "skull",
			Settings = "settings",
		}

		local function GalaxySafeDisconnect(connection)
			if connection then
				pcall(function()
					connection:Disconnect()
				end)
			end
		end

		local function GalaxyNormalizeDropdown(value)
			if type(value) == "table" then
				return value[1]
			end
			return value
		end

		function GalaxyRayfieldBridge:CreateWindow(title)
			local ok, Rayfield = pcall(function()
				return loadstring(game:HttpGet("https://sirius.menu/gen2"))()
			end)

			if not ok or not Rayfield then
				warn("[Galaxy] Rayfield Gen2 failed to load; using the original Galaxy UI.")
				return GalaxyOriginalUI:CreateWindow(title)
			end

			local Window = Rayfield:CreateWindow({
				name = title,
				subtitle = GALAXY_IS_TSB and "Fallen • Rayfield Gen2" or "Universal • Rayfield Gen2",
				sidebarLayout = true,
				theme = "cobalt",
				showName = "Galaxy",
				configuration = {
					autoSave = false,
					autoLoad = false,
					fileName = "GalaxyHub",
					customFolder = "GalaxyHub",
				},
			})

			local BridgeWindow = {
				_window = Window,
				_rayfield = Rayfield,
				_connections = {},
				_mobileGui = nil,
				_destroyed = false,
			}

			function BridgeWindow:CreateTab(name, _icon)
				return self._window:CreateTab({
					name = name,
					icon = GalaxyTabIcons[name] or "circle",
				})
			end

			function BridgeWindow:CreateSection(name, tab)
				local success = pcall(function()
					tab:CreateSection({name = name})
				end)
				if not success then
					pcall(function()
						tab:CreateSection(name)
					end)
				end
			end

			function BridgeWindow:CreateToggle(name, tab, defaultValue, callback)
				local current = defaultValue and true or false
				local element
				element = tab:CreateToggle({
					name = name,
					value = current,
					forgetState = true,
					callback = function(value)
						current = value and true or false
						if callback then
							callback(current)
						end
					end,
				})
				return {
					SetValue = function(_, value)
						current = value and true or false
						if element and element.Set then
							element:Set(current)
						elseif callback then
							callback(current)
						end
					end,
					GetValue = function()
						return current
					end,
				}
			end

			function BridgeWindow:CreateSlider(name, tab, minValue, maxValue, increment, defaultValue, suffix, callback)
				local current = defaultValue
				local element = tab:CreateSlider({
					name = name,
					range = {minValue, maxValue},
					increment = increment,
					suffix = suffix or "",
					value = defaultValue,
					forgetState = true,
					callback = function(value)
						current = value
						if callback then
							callback(value)
						end
					end,
				})
				return {
					SetValue = function(_, value)
						current = value
						if element and element.Set then
							element:Set(value)
						elseif callback then
							callback(value)
						end
					end,
					GetValue = function()
						return current
					end,
				}
			end

			function BridgeWindow:CreateButton(name, tab, callback)
				return tab:CreateButton({
					name = name,
					callback = function()
						if callback then
							callback()
						end
					end,
				})
			end

			function BridgeWindow:CreateInput(name, tab, placeholder, numericOnly, callback)
				local current = ""
				local element = tab:CreateInput({
					name = name,
					placeholder = placeholder or "",
					value = "",
					numeric = numericOnly and true or false,
					forgetState = true,
					callback = function(value)
						current = tostring(value or "")
						if numericOnly then
							local numberValue = tonumber(current)
							if numberValue == nil then
								BridgeWindow:Notify("Invalid number", name .. " needs a numeric value.")
								return
							end
							if callback then
								callback(numberValue)
							end
						elseif callback then
							callback(current)
						end
					end,
				})
				return {
					SetValue = function(_, value)
						current = tostring(value or "")
						if element and element.Set then
							element:Set(current)
						end
					end,
					GetValue = function()
						return current
					end,
				}
			end

			function BridgeWindow:CreateDropdown(name, tab, options, defaultIndex, callback)
				local defaultValue = options[tonumber(defaultIndex) or 1] or options[1]
				local current = defaultValue
				local element = tab:CreateDropdown({
					name = name,
					options = options,
					value = defaultValue,
					multiSelect = false,
					forgetState = true,
					callback = function(value)
						value = GalaxyNormalizeDropdown(value)
						if value == nil then
							return
						end
						current = value
						if callback then
							callback(value)
						end
					end,
				})
				return {
					SetValue = function(_, value)
						current = value
						if element and element.Set then
							element:Set(value)
						elseif callback then
							callback(value)
						end
					end,
					GetValue = function()
						return current
					end,
				}
			end

			function BridgeWindow:Notify(titleText, contentText)
				local sent = false
				if self._window and self._window.Notify then
					sent = pcall(function()
						self._window:Notify({
							title = titleText,
							content = contentText,
						})
					end)
				end
				if not sent and self._rayfield and self._rayfield.Notify then
					pcall(function()
						self._rayfield:Notify({
							title = titleText,
							content = contentText,
						})
					end)
				end
			end

			function BridgeWindow:Toggle()
				if self._window and self._window.ToggleHide then
					pcall(function()
						self._window:ToggleHide()
					end)
					return
				end
				if self._rayfield and self._rayfield.SetVisibility then
					pcall(function()
						local visible = true
						if self._rayfield.IsVisible then
							visible = self._rayfield:IsVisible()
						elseif self._visible ~= nil then
							visible = self._visible
						end
						self._visible = not visible
						self._rayfield:SetVisibility(self._visible)
					end)
				end
			end

			function BridgeWindow:PlayIntro()
				self:Notify(
					"Galaxy Hub",
					UserInputService.TouchEnabled
						and "Rayfield Gen2 loaded. Tap the floating G button to hide/show the hub."
						or "Rayfield Gen2 loaded. Press RightShift or P to hide/show the hub."
				)
			end

			function BridgeWindow:Destroy()
				if self._destroyed then
					return
				end
				self._destroyed = true
				for _, connection in ipairs(self._connections) do
					GalaxySafeDisconnect(connection)
				end
				self._connections = {}
				if self._mobileGui then
					pcall(function()
						self._mobileGui:Destroy()
					end)
					self._mobileGui = nil
				end
				pcall(function()
					if self._window.Unload then
						self._window:Unload()
					elseif self._rayfield.Destroy then
						self._rayfield:Destroy()
					end
				end)
			end

			-- Desktop fallback toggle. Rayfield's own controls still remain available.
			local keyboardConnection = UserInputService.InputBegan:Connect(function(input, processed)
				if processed or UserInputService:GetFocusedTextBox() then
					return
				end
				if input.KeyCode == Enum.KeyCode.RightShift or input.KeyCode == Enum.KeyCode.P then
					BridgeWindow:Toggle()
				end
			end)
			table.insert(BridgeWindow._connections, keyboardConnection)

			-- Mobile helper: large touch target that can be dragged and tapped.
			if UserInputService.TouchEnabled then
				pcall(function()
					local oldGui = u7:FindFirstChild("Galaxy_Rayfield_Mobile")
					if oldGui then
						oldGui:Destroy()
					end

					local mobileGui = Instance.new("ScreenGui")
					mobileGui.Name = "Galaxy_Rayfield_Mobile"
					mobileGui.ResetOnSpawn = false
					mobileGui.IgnoreGuiInset = true
					mobileGui.DisplayOrder = 100000
					mobileGui.Parent = u7
					BridgeWindow._mobileGui = mobileGui

					local button = Instance.new("TextButton")
					button.Name = "GalaxyToggle"
					button.Size = UDim2.fromOffset(54, 54)
					button.Position = UDim2.new(1, -70, 0.5, -27)
					button.BackgroundColor3 = Color3.fromRGB(74, 92, 255)
					button.BorderSizePixel = 0
					button.Text = "G"
					button.TextColor3 = Color3.fromRGB(255, 255, 255)
					button.TextSize = 22
					button.Font = Enum.Font.GothamBold
					button.AutoButtonColor = false
					button.Active = true
					button.ZIndex = 1000
					button.Parent = mobileGui

					local corner = Instance.new("UICorner")
					corner.CornerRadius = UDim.new(1, 0)
					corner.Parent = button

					local stroke = Instance.new("UIStroke")
					stroke.Thickness = 1.5
					stroke.Transparency = 0.25
					stroke.Color = Color3.fromRGB(220, 230, 255)
					stroke.Parent = button

					local gradient = Instance.new("UIGradient")
					gradient.Color = ColorSequence.new({
						ColorSequenceKeypoint.new(0, Color3.fromRGB(63, 215, 255)),
						ColorSequenceKeypoint.new(0.5, Color3.fromRGB(113, 86, 255)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(236, 104, 255)),
					})
					gradient.Rotation = 30
					gradient.Parent = button

					local dragging = false
					local moved = false
					local dragStart
					local startPosition

					button.InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
							dragging = true
							moved = false
							dragStart = input.Position
							startPosition = button.Position
						end
					end)

					local moveConnection = UserInputService.InputChanged:Connect(function(input)
						if not dragging or not dragStart or not startPosition then
							return
						end
						if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement then
							local delta = input.Position - dragStart
							if delta.Magnitude > 7 then
								moved = true
							end
							if moved then
								local viewport = Workspace.CurrentCamera and Workspace.CurrentCamera.ViewportSize or Vector2.new(800, 600)
								local x = math.clamp(startPosition.X.Offset + delta.X, -viewport.X + 60, -8)
								local y = math.clamp(startPosition.Y.Offset + delta.Y, -viewport.Y / 2 + 36, viewport.Y / 2 - 62)
								button.Position = UDim2.new(startPosition.X.Scale, x, startPosition.Y.Scale, y)
							end
						end
					end)
					table.insert(BridgeWindow._connections, moveConnection)

					local endConnection = UserInputService.InputEnded:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
							if dragging and not moved then
								BridgeWindow:Toggle()
							end
							dragging = false
							dragStart = nil
							startPosition = nil
						end
					end)
					table.insert(BridgeWindow._connections, endConnection)
				end)
			end

			return BridgeWindow
		end

		u216 = GalaxyRayfieldBridge
		u217 = t10
		u218 = LocalPlayer
		u219 = t11
		u220 = v49
		u221 = t15
		u222 = v66
		u223 = Workspace

		function u224(p93)
			if not p93 then
				if u109 then
					u109:Disconnect()
					u109 = nil
				end

				return
			end

			u109 = u110.RenderStepped:Connect(function()
				local Character = u111.Character

				if Character then
					for _, v in ipairs({
						"ComboStun",
						"StopRunning",
					}) do
						local v4 = Character:FindFirstChild(v)

						if v4 then
							v4:Destroy()
						end
					end
				end
			end)
		end
		function u225(p94)
			if not p94 then
				if u112 then
					u112:Disconnect()
					u112 = nil
				end

				if u113 then
					u113:Disconnect()
					u113 = nil
				end

				return
			end

			if u114.Character then
				local Character = u114.Character
				local u451 = Character

				if Character:GetAttribute("Blocking") == true then
					Character:SetAttribute("Blocking", false)
				end

				u112 = Character:GetAttributeChangedSignal("Blocking"):Connect(function()
					if u451:GetAttribute("Blocking") == true then
						u451:SetAttribute("Blocking", false)
					end
				end)
			end

			u113 = u114.CharacterAdded:Connect(function(character)
				local u880 = character

				if character:GetAttribute("Blocking") == true then
					character:SetAttribute("Blocking", false)
				end

				u112 = character:GetAttributeChangedSignal("Blocking"):Connect(function()
					if u880:GetAttribute("Blocking") == true then
						u880:SetAttribute("Blocking", false)
					end
				end)
			end)
		end
	end

	local u226 = t18
	local u227 = t25
	local u228 = v129
	local u229 = t26
	local u230 = Part
	local u231 = v163
	local u232 = v157
	local u233 = v183
	local u234 = t32
	local u235 = v204
	local u236 = v209
	local u237 = u215

	-- ========================== ZYKEHUB INVISIBILITY ==========================
	-- Added to the Exploits tab. Uses the same invisibility behavior from ZykeHub.
	local ZK_InvisActive = false
	local ZK_InvisProcessing = false
	local ZK_InvisAnimation = nil
	local ZK_LastInvisHumanoid = nil
	local ZK_SavedRootCFrame = nil
	local ZK_InvisConnections = {}

	local ZK_InvisModel = Instance.new("Model")
	ZK_InvisModel.Name = "Galaxy_InvisCamera"
	ZK_InvisModel.Parent = Workspace
	local ZK_InvisHumanoid = Instance.new("Humanoid")
	ZK_InvisHumanoid.Parent = ZK_InvisModel
	local ZK_InvisPart = Instance.new("Part")
	ZK_InvisPart.Name = "HumanoidRootPart"
	ZK_InvisPart.CanCollide = false
	ZK_InvisPart.Transparency = 1
	ZK_InvisPart.Anchored = true
	ZK_InvisPart.Size = Vector3.new(2, 2, 1)
	ZK_InvisPart.Parent = ZK_InvisModel

	local function ZK_DisableInvis()
		if not ZK_InvisActive then return end
		ZK_InvisActive = false
		ZK_InvisProcessing = false
		getgenv().InvisActive = false

		if ZK_InvisAnimation then
			pcall(function()
				if ZK_InvisAnimation.IsPlaying then ZK_InvisAnimation:Stop() end
				ZK_InvisAnimation:Destroy()
			end)
			ZK_InvisAnimation = nil
		end
		ZK_LastInvisHumanoid = nil

		local char = LocalPlayer.Character
		if char then
			local root = char:FindFirstChild("HumanoidRootPart")
			if root and ZK_SavedRootCFrame then
				pcall(function() root.CFrame = ZK_SavedRootCFrame end)
			end
			ZK_SavedRootCFrame = nil
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then pcall(function() Workspace.CurrentCamera.CameraSubject = hum end) end
			pcall(function() char:SetAttribute("NoHeadLerp", false) end)
			for _, conn in ipairs(ZK_InvisConnections) do pcall(function() conn:Disconnect() end) end
			ZK_InvisConnections = {}
			for _, obj in ipairs(char:GetDescendants()) do
				if obj:IsA("BasePart") and obj.Name ~= "HumanoidRootPart" then
					obj.LocalTransparencyModifier = 0
				end
			end
		end
	end

	local function ZK_MakeSemiTransparent(part)
		if not part:IsA("BasePart") or part.Name == "HumanoidRootPart" or part.Transparency == 1 or part.Name:lower():find("hitbox") then return end
		part.LocalTransparencyModifier = 0.5
		local conn = part:GetPropertyChangedSignal("LocalTransparencyModifier"):Connect(function()
			if ZK_InvisActive and part.LocalTransparencyModifier ~= 0.5 then
				part.LocalTransparencyModifier = 0.5
			end
		end)
		table.insert(ZK_InvisConnections, conn)
	end

	local function ZK_HookInvis(model)
		for _, obj in ipairs(model:GetDescendants()) do ZK_MakeSemiTransparent(obj) end
		table.insert(ZK_InvisConnections, model.DescendantAdded:Connect(function(obj)
			if ZK_InvisActive then ZK_MakeSemiTransparent(obj) end
		end))
	end

	local function ZK_EnableInvis()
		if ZK_InvisActive then
			ZK_DisableInvis()
			return
		end
		local char = LocalPlayer.Character
		if not char then return end
		local hum = char:FindFirstChildOfClass("Humanoid")
		local root = char:FindFirstChild("HumanoidRootPart")
		if not hum or not root then return end
		ZK_InvisActive = true
		getgenv().InvisActive = true
		ZK_InvisProcessing = false
		ZK_HookInvis(char)
	end

	RunService.Heartbeat:Connect(function()
		if not ZK_InvisActive or ZK_InvisProcessing then return end
		ZK_InvisProcessing = true
		local char = LocalPlayer.Character
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		local root = char and char:FindFirstChild("HumanoidRootPart")
		if not char or not hum or not root or hum.Health <= 0 then
			ZK_InvisProcessing = false
			return
		end

		local rootCF = root.CFrame
		local velocity = root.Velocity
		ZK_SavedRootCFrame = rootCF
		local camera = Workspace.CurrentCamera

		if ZK_LastInvisHumanoid ~= hum then
			if ZK_InvisAnimation then pcall(function() ZK_InvisAnimation:Stop(); ZK_InvisAnimation:Destroy() end) end
			ZK_InvisAnimation = nil
			ZK_LastInvisHumanoid = hum
		end

		local animator = hum:FindFirstChildOfClass("Animator")
		if animator then
			if not ZK_InvisAnimation or ZK_InvisAnimation.Parent == nil then
				local anim = Instance.new("Animation")
				anim.AnimationId = "rbxassetid://71181015443030"
				ZK_InvisAnimation = animator:LoadAnimation(anim)
				ZK_InvisAnimation.Priority = Enum.AnimationPriority.Action4
				ZK_InvisAnimation:Play()
				ZK_InvisAnimation:AdjustSpeed(0)
				ZK_InvisAnimation:AdjustWeight(2e9)
			end
			ZK_InvisAnimation.TimePosition = 13.45
		end

		RunService.RenderStepped:Wait()
		ZK_InvisHumanoid.CameraOffset = hum.CameraOffset
		if camera and camera.CameraSubject == ZK_InvisHumanoid then
			camera.CameraSubject = hum
		end
		if ZK_InvisAnimation and ZK_InvisAnimation.IsPlaying then pcall(function() ZK_InvisAnimation:Stop() end) end
		root.CFrame = rootCF
		root.Velocity = velocity
		ZK_InvisProcessing = false
	end)

	LocalPlayer.CharacterAdded:Connect(function(char)
		for _, conn in ipairs(ZK_InvisConnections) do pcall(function() conn:Disconnect() end) end
		ZK_InvisConnections = {}
		ZK_SavedRootCFrame = nil
		if ZK_InvisActive then
			task.spawn(function()
				char:WaitForChild("HumanoidRootPart", 5)
				if ZK_InvisActive then ZK_HookInvis(char) end
			end)
		end
	end)

	local function u238()
		u210 = u216:CreateWindow(GALAXY_IS_TSB and "Galaxy Hub:Fallen" or "Galaxy Hub:Universal")

		local v519 = u210:CreateTab("Movement", "")
		local v520 = u210:CreateTab("Exploits", "")
		local v521 = u210:CreateTab("Combat", "")
		local v522 = u210:CreateTab("Teleports", "")
		local v523 = u210:CreateTab("Animations", "")
		local v525 = u210:CreateTab("Target Farm", "")
		local v526 = u210:CreateTab("Rage Kill", "")
		local v524 = u210:CreateTab("Settings", "")

		u210:CreateSection("CHARACTER", v519)
		u210:CreateDropdown(
			"Speed Method",
			v519,
			{
				"Disabled",
				"CFrame Speed",
				"Velocity Speed",
				"Loop WalkSpeed",
			},
			1,
			function(p95)
				s1 = p95

				if u217.wsLoop then
					u217.wsLoop:Disconnect()
				end

				if u217.wsCA then
					u217.wsCA:Disconnect()
				end

				if u27 then
					u27:Disconnect()
				end

				if p95 ~= "Disabled" and u218.Character and n4 ~= 0 then
					u33(u218.Character, n4, p95)
				end
			end
		)
		u210:CreateInput("Speed Value", v519, "enter speed (e.g. 50)", true, function(p96)
			n4 = p96

			if s1 ~= "Disabled" and u218.Character then
				u33(u218.Character, p96, s1)
			end
		end)
		u210:CreateDropdown(
			"Jump Method",
			v519,
			{
				"Disabled",
				"Loop JumpPower",
			},
			1,
			function(p97)
				s2 = p97

				if u219.jpLoop then
					u219.jpLoop:Disconnect()
					u219.jpLoop = nil
				end

				if u219.jpCA then
					u219.jpCA:Disconnect()
					u219.jpCA = nil
				end

				if p97 ~= "Disabled" and u218.Character and n5 ~= 0 then
					u39(u218.Character, n5, p97)
				end
			end
		)
		u210:CreateInput("Jump Value", v519, "enter jump power (e.g. 100)", true, function(p98)
			n5 = p98

			if s2 ~= "Disabled" and u218.Character then
				u39(u218.Character, p98, s2)
			end
		end)
		u210:CreateToggle("Infinite Jump", v519, false, u43)
		u210:CreateSection("FLY", v519)
		u210:CreateToggle("Fly", v519, false, function(p99)
			if not p99 then
				u220()

				return
			end

			u56()
		end)
		u210:CreateSlider("Fly Speed", v519, 10, 500, 10, 100, "", function(p100)
			n6 = p100
		end)
		u210:CreateSection("EMOTES", v520)
		u210:CreateToggle("Emote Search Bar", v520, false, function(p101)
			u218:SetAttribute("EmoteSearchBar", p101)
		end)
		u210:CreateToggle("Extra Slots", v520, false, function(p102)
			u218:SetAttribute("ExtraSlots", p102)
		end)
		u210:CreateSection("INVISIBILITY", v520)
		u210:CreateToggle("Invis", v520, false, function(enabled)
			if enabled then
				ZK_EnableInvis()
			else
				ZK_DisableInvis()
			end
		end)
		u210:CreateSection("CUSTOM DASHES", v520)
		u210:CreateInput("Front Dash Speed", v520, "default: 100", true, function(p103)
			u221.front.speed = p103
		end)
		u210:CreateToggle("Custom Front Dash", v520, false, function(p104)
			u221.front.enabled = p104

			if p104 and u218.Character then
				local Character = u218.Character

				if not Character then
					return
				end

				local Humanoid = Character:WaitForChild("Humanoid")
				local v916 = #t16 + 1
				local AnimationPlayed = Humanoid.AnimationPlayed
				local u918 = Character

				t16[v916] = AnimationPlayed:Connect(function(p105)
					local AnimationId = p105.Animation.AnimationId
					local HumanoidRootPart = u918:FindFirstChild("HumanoidRootPart")

					if HumanoidRootPart then
						for k, v in pairs(u221) do
							if v.enabled and AnimationId == v.animationId then
								u222(HumanoidRootPart, k, p105)

								return
							end
						end

						return
					end
				end)
			end
		end)
		u210:CreateInput("Side Dash Speed", v520, "default: 150", true, function(p106)
			u221.left.speed = p106
			u221.right.speed = p106
		end)
		u210:CreateToggle("Custom Side Dash", v520, false, function(p107)
			u221.left.enabled = p107
			u221.right.enabled = p107

			if p107 and u218.Character then
				local Character = u218.Character

				if not Character then
					return
				end

				local Humanoid = Character:WaitForChild("Humanoid")
				local v924 = #t16 + 1
				local AnimationPlayed = Humanoid.AnimationPlayed
				local u926 = Character

				t16[v924] = AnimationPlayed:Connect(function(p108)
					local AnimationId = p108.Animation.AnimationId
					local HumanoidRootPart = u926:FindFirstChild("HumanoidRootPart")

					if HumanoidRootPart then
						for k, v in pairs(u221) do
							if v.enabled and AnimationId == v.animationId then
								u222(HumanoidRootPart, k, p108)

								return
							end
						end

						return
					end
				end)
			end
		end)
		u210:CreateInput("Back Dash Speed", v520, "default: 100", true, function(p109)
			u221.back.speed = p109
		end)
		u210:CreateToggle("Custom Back Dash", v520, false, function(p110)
			u221.back.enabled = p110

			if p110 and u218.Character then
				local Character = u218.Character

				if not Character then
					return
				end

				local Humanoid = Character:WaitForChild("Humanoid")
				local v932 = #t16 + 1
				local AnimationPlayed = Humanoid.AnimationPlayed
				local u934 = Character

				t16[v932] = AnimationPlayed:Connect(function(p111)
					local AnimationId = p111.Animation.AnimationId
					local HumanoidRootPart = u934:FindFirstChild("HumanoidRootPart")

					if HumanoidRootPart then
						for k, v in pairs(u221) do
							if v.enabled and AnimationId == v.animationId then
								u222(HumanoidRootPart, k, p111)

								return
							end
						end

						return
					end
				end)
			end
		end)
		u210:CreateSection("STATUS REMOVAL", v520)
		u210:CreateToggle("No Dash Cooldown", v520, false, function(p112)
			u223:SetAttribute("NoDashCooldown", p112)
		end)
		u210:CreateToggle("No Fatigue", v520, false, function(p113)
			u223:SetAttribute("NoFatigue", p113)
		end)
		u210:CreateToggle("No Ragdoll", v520, false, u93)
		u210:CreateToggle("No Freeze", v520, false, u98)
		u210:CreateToggle("No Jump Bypass", v520, false, u103)
		u210:CreateToggle("No Slow", v520, false, u108)
		u210:CreateToggle("No Stun", v520, false, u224)
		u210:CreateToggle("No Block Slowdown", v520, false, u225)
		u210:CreateSection("INVISIBLE MOVES", v520)

		for i, v in ipairs(u226) do
			local name = v.name
			local u529 = i

			u210:CreateToggle(name, v520, false, function(p114)
				u227[u529] = p114

				local Character = u218.Character

				if not p114 then
					if u229[u529] then
						u229[u529]:Disconnect()
						u229[u529] = nil
					end

					return
				end

				u228(u529, Character)
			end)
		end

		u210:CreateSection("M1 CATCH", v521)
		u210:CreateToggle("M1 Catch", v521, false, function(p115)
			u139 = p115
			u230.Transparency = p115 and 0.5 or 1
		end)
		u210:CreateSlider("Zone Size", v521, 5, 100, 1, 20, "", function(p116)
			u230.Size = Vector3.new(p116, p116, p116)
		end)
		u210:CreateSlider("Zone Transparency", v521, 0, 1, 0.05, 0.5, "", function(p117)
			if u139 then
				u230.Transparency = p117
			end
		end)
		u210:CreateSection("AUTO BLOCK (BETA)", v521)
		u210:CreateSlider("AB Zone Size", v521, 5, 50, 1, 20, "", function(p118)
			n8 = p118

			if u148 then
				u148.Size = Vector3.new(p118, p118, p118)
			end
		end)
		u210:CreateSlider("AB Zone Transparency", v521, 0, 1, 0.05, 0.5, "", function(p119)
			n9 = p119

			if u148 then
				u148.Transparency = p119

				for _, child in pairs(u148:GetChildren()) do
					if child:IsA("Texture") then
						child.Transparency = p119
					end
				end
			end
		end)
		u210:CreateToggle("Auto Block M1ing (re-enable after respawn)", v521, false, function(p120)
			u147 = p120

			if not p120 then
				u232()

				if u154 then
					u154:Disconnect()
					u154 = nil
				end

				if u148 then
					u148:Destroy()
					u148 = nil
				end

				return
			end

			u231()
		end)
		u210:CreateSection("EXTRA DAMAGE", v521)
		u210:CreateToggle("Extra Damage (Lethal Whirlwind Stream)", v521, false, function(p121)
			u169 = p121

			if not p121 then
				if u172 then
					u172:Disconnect()
					u172 = nil
				end

				return
			end

			u174(u218.Character)
		end)
		u210:CreateToggle("Return to Original Position", v521, true, function(p122)
			u170 = p122
		end)
		u210:CreateSlider("Teleport Distance", v521, 100, 1000, 50, 100, " studs", function(p123)
			n10 = p123
		end)
		u210:CreateSection("SKILL BRING / TELEPORT", v521)
		u210:CreateDropdown(
			"Teleport Location",
			v521,
			{
				"Void",
				"Atomic Room",
				"Death Counter Room",
				"Baseplate",
				"Middle of Map",
				"Mountain 1",
				"Mountain 2",
				"Mountain 3",
			},
			1,
			function(p124)
				s7 = p124
				Void = t30[p124]
			end
		)
		u210:CreateToggle("Auto Teleport on Skill", v521, false, function(p125)
			u175 = p125

			if not p125 then
				if u177 then
					u177:Disconnect()
					u177 = nil
				end

				return
			end

			u233(u218.Character)
		end)
		u210:CreateToggle("TP Back After Skill", v521, false, function(p126)
			u176 = p126
		end)
		u210:CreateSection("SAVED POSITION", v522)
		u210:CreateButton("Save Position", v522, function()
			local Character = u218.Character
			local v954 = Character and Character:FindFirstChild("HumanoidRootPart")

			if v954 then
				vector3 = v954.Position
			end
		end)
		u210:CreateButton("Teleport to Saved Position", v522, function()
			local Character = u218.Character
			local v956 = Character and Character:FindFirstChild("HumanoidRootPart")

			if v956 then
				v956.CFrame = CFrame.new(vector3)
			end
		end)
		u210:CreateSection("LOCATIONS", v522)

		local t35 = {}
		local t36 = {
			"Atomic Room",
			CFrame.new(1079, 155, 23003),
		}
		local t37 = {
			"Death Counter Room",
			CFrame.new(-92, 29, 20347),
		}
		local t38 = {
			"Void",
			CFrame.new(0, -492, 0),
		}
		local t39 = {
			"Baseplate",
			CFrame.new(968, 20, 23088),
		}
		local t40 = {
			"Middle of Map",
			CFrame.new(148, 441, 27),
		}
		local t41 = {
			"Mountain 1",
			CFrame.new(266, 699, 458),
		}
		local t42 = {
			"Mountain 2",
			CFrame.new(551, 630, -265),
		}
		local t43 = {
			"Mountain 3",
			CFrame.new(-107, 642, -328),
		}
		local t44 = {
			"Trap 1",
			CFrame.new(378, 440, 448),
		}
		local t45 = {
			"Trap 2",
			CFrame.new(287, 440, 481),
		}
		local t46 = {
			"Corner 1",
			CFrame.new(-226, 440, -415),
		}
		local t47 = {
			"Corner 2",
			CFrame.new(526, 440, 481),
		}

		t35[1] = t36
		t35[2] = t37
		t35[3] = t38
		t35[4] = t39
		t35[5] = t40
		t35[6] = t41
		t35[7] = t42
		t35[8] = t43
		t35[9] = t44
		t35[10] = t45
		t35[11] = t46
		t35[12] = t47

		for _, v in ipairs(t35) do
			local v545 = v[1]
			local v546 = v[2]
			local u548 = v546

			u210:CreateButton(v545, v522, function()
				local Character = u218.Character
				local v958 = Character and Character:FindFirstChild("HumanoidRootPart")

				if v958 then
					v958.CFrame = u548
				end
			end)
		end

		u210:CreateSection("WALK / RUN", v523)
		u210:CreateButton("Default Walk", v523, function()
			u234["rbxassetid://7815618175"] = nil
			u234["rbxassetid://7807831448"] = nil
			u186 = nil

			if u187 then
				u187:Stop()
				u187 = nil
			end
		end)

		local t48 = {}
		local t49 = {
			"Helicopter",
			17862998594,
		}
		local t50 = {
			"Hunter",
			15962326593,
		}
		local t51 = {
			"March",
			15962443652,
		}
		local t52 = {
			"Gojo",
			18897115785,
		}
		local t53 = {
			"wtf",
			17122254184,
		}
		local t54 = {
			"Girl",
			17861862787,
		}
		local t55 = {
			"Girl 2",
			17861893094,
		}
		local t56 = {
			"Sword",
			17120635926,
		}
		local t57 = {
			"Runner",
			18897724289,
		}
		local t58 = {
			"Runner 2",
			95575238948327,
		}

		t48[1] = t49
		t48[2] = t50
		t48[3] = t51
		t48[4] = t52
		t48[5] = t53
		t48[6] = t54
		t48[7] = t55
		t48[8] = t56
		t48[9] = t57
		t48[10] = t58

		for _, v in ipairs(t48) do
			local v562 = v[1]
			local v563 = v[2]
			local u565 = v563

			u210:CreateButton(v562, v523, function()
				u234["rbxassetid://7815618175"] = true
				u234["rbxassetid://7807831448"] = true

				local v959 = u565

				u186 = u565

				if u187 then
					u187:Stop()
					u187 = nil
				end

				if u188 and v959 then
					local Animation = Instance.new("Animation")

					Animation.AnimationId = "rbxassetid://" .. tostring(v959)
					u187 = u188:LoadAnimation(Animation)
				end
			end)
		end

		u210:CreateSection("IDLE", v523)
		u210:CreateButton("Default Idle", v523, function()
			if u194 then
				u194:Stop()
			end

			if u196 then
			end

			u193 = nil
		end)

		local t59 = {}
		local t60 = {
			"Fly",
			"rbxassetid://17124061663",
		}
		local t61 = {
			"Fly 2",
			"rbxassetid://18897538537",
		}
		local t62 = {
			"Fly 3",
			"rbxassetid://14840458512",
		}
		local t63 = {
			"Unknown",
			"rbxassetid://18897713456",
		}
		local t64 = {
			"Watch",
			"rbxassetid://18897733312",
		}
		local t65 = {
			"Confident",
			"rbxassetid://17109012516",
		}
		local t66 = {
			"Aka Stance",
			"rbxassetid://118383042869348",
		}
		local t67 = {
			"Ao Stance",
			"rbxassetid://113201609340793",
		}
		local t68 = {
			"Helicopter",
			"rbxassetid://17862998594",
		}
		local t69 = {
			"Perfect Concentration",
			"rbxassetid://102959457211902",
		}
		local t70 = {
			"Sit",
			"rbxassetid://114499085231058",
		}
		local t71 = {
			"Sit 2",
			"rbxassetid://18450698238",
		}
		local t72 = {
			"wtf",
			"rbxassetid://17122254184",
		}
		local t73 = {
			"Insane",
			"rbxassetid://104862750267967",
		}
		local t74 = {
			"Insane 2",
			"rbxassetid://127234845846317",
		}

		t59[1] = t60
		t59[2] = t61
		t59[3] = t62
		t59[4] = t63
		t59[5] = t64
		t59[6] = t65
		t59[7] = t66
		t59[8] = t67
		t59[9] = t68
		t59[10] = t69
		t59[11] = t70
		t59[12] = t71
		t59[13] = t72
		t59[14] = t73
		t59[15] = t74

		for _, v in ipairs(t59) do
			local v584 = v[1]
			local v585 = v[2]
			local u587 = v585

			u210:CreateButton(v584, v523, function()
				u197(u587)
			end)
		end

		u210:CreateSection("RAGE KILL", v526)
		u210:CreateButton("Load Rage Kill", v526, function()
			local ok, err = pcall(function()
				loadstring(game:HttpGet("https://raw.githubusercontent.com/JoshSuarez425/Infographics_MCO2/refs/heads/main/public%20farm.lua"))()
			end)
			if ok then
				print("[Galaxy] Rage Kill loaded.")
			else
				warn("[Galaxy] Rage Kill failed: " .. tostring(err))
			end
		end)
		u210:CreateSection("M1 ATTACK ANIMATIONS", v523)
		u210:CreateDropdown(
			"Character Type",
			v523,
			{
				"Fist",
				"Bat",
				"Ninjato",
				"Katana",
				"LightningFist",
				"HunterFist",
				"CyborgFist",
				"EsperFist",
				"KJFist",
				"PurpleFist",
			},
			1,
			function(p127)
				s8 = p127

				if u200 then
					u235(u200)
				end
			end
		)
		u210:CreateButton("Default M1", v523, function()
			t33 = {}
			u200 = nil
		end)

		local t75 = {
			"Fist",
			"Bat",
			"Ninjato",
			"Katana",
			"LightningFist",
			"HunterFist",
			"CyborgFist",
			"EsperFist",
			"KJFist",
			"PurpleFist",
		}

		for _, v in ipairs(t75) do
			local v592 = v .. " M1"
			local u593 = v

			u210:CreateButton(v592, v523, function()
				u235(u593)
			end)
		end

		u210:CreateSection("UTILITY", v524)
		u210:CreateToggle("Void Protection", v524, false, u236)
		u210:CreateButton("Unload Script & UI", v524, u237)


		-- ========================== ZYKEHUB TARGET FARM (REFIXED) ==========================
		do
			-- This block ports the stable Target Farm core from zykehub_updated.lua
			-- while keeping TSBNEW's existing tab/UI library.
			local ZK_Target = nil
			local ZK_Follow = false
			local ZK_AutoCombat = false
			local ZK_Hitbox = false
			local ZK_Spectate = false
			local ZK_CurrentTarget = nil

			local ZK_CombatConnection = nil
			local ZK_SpectateConnection = nil

			local ZK_SpectateYaw, ZK_SpectatePitch = 0, -0.3
			local ZK_SpectateDistance, ZK_TargetDistance = 10, 10
			local ZK_SpectateRotating = false

			local ZK_LastSkill, ZK_LastDash, ZK_SkillIndex = 0, 0, 1
			local ZK_SkillKeys = {
				Enum.KeyCode.One,
				Enum.KeyCode.Two,
				Enum.KeyCode.Three,
				Enum.KeyCode.Four
			}

			local ZK_HitboxPart = nil
			local ZK_HitboxOriginalSize = nil
			local ZK_HITBOX_SIZE = Vector3.new(4, 4, 4)

			local ZK_Render = false
			local ZK_RenderConnection = nil
			local ZK_RenderEnforceThread = nil
			local ZK_RenderGeneration = 0

			-- Saved render state so the FPS mode is reversible and does not destroy
			-- the game's VFX/objects. Anything muted while enabled is restored on off.
			local ZK_SavedLighting = {}
			local ZK_SavedTerrain = {}
			local ZK_SavedPartState = {}
			local ZK_SavedEffectState = {}
			local ZK_SavedTransparencyState = {}
			local ZK_SavedSurfaceAppearanceParents = {}
			local ZK_SavedAtmosphere = nil
			local ZK_RenderRenderingQuality = nil
			local ZK_RenderGlobalShadows = nil
			local ZK_RenderTechnology = nil
			local ZK_RenderBrightness = nil

			-- Lighting is intentionally local to this Target Farm scope. The previous
			-- implementation referenced a non-existent Lighting upvalue, which caused
			-- ZK_SetRender to error when the toggle was pressed.
			local ZK_Lighting = game:GetService("Lighting")

			local ZK_VirtualInputManager = game:GetService("VirtualInputManager")

			local function ZK_GetChar(plr)
				return plr and plr.Character
			end
			local function ZK_GetRoot(model)
				return model and model:FindFirstChild("HumanoidRootPart")
			end

			local function ZK_GetHum(model)
				return model and model:FindFirstChildOfClass("Humanoid")
			end

			local function ZK_Valid(model)
				if not model then return false end
				local root = ZK_GetRoot(model)
				local hum = ZK_GetHum(model)
				return root and hum and hum.Health > 0
			end

			local function ZK_Press(keyCode, jitterMax)
				task.spawn(function()
					pcall(function()
						if UserInputService:GetFocusedTextBox() then
							return
						end
						if jitterMax and jitterMax > 0 then
							task.wait(math.random() * jitterMax)
						end
						ZK_VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
						task.wait()
						ZK_VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
					end)
				end)
			end

			local function ZK_RestoreHitbox()
				if ZK_HitboxPart and ZK_HitboxPart.Parent and ZK_HitboxOriginalSize then
					pcall(function()
						ZK_HitboxPart.Size = ZK_HitboxOriginalSize
					end)
				end
				ZK_HitboxPart = nil
				ZK_HitboxOriginalSize = nil
			end

			local function ZK_ApplyHitbox()
				ZK_RestoreHitbox()
				if not ZK_Hitbox or not ZK_Target then
					return
				end

				local targetRoot = ZK_GetRoot(ZK_GetChar(ZK_Target))
				if targetRoot and targetRoot:IsA("BasePart") then
					ZK_HitboxPart = targetRoot
					ZK_HitboxOriginalSize = targetRoot.Size
					pcall(function()
						targetRoot.Size = ZK_HITBOX_SIZE
					end)
				end
			end

			local function ZK_GetBehindCFrame(targetRoot)
				local cf = targetRoot.CFrame
				local _, ry = cf:ToEulerAnglesYXZ()
				local yaw = CFrame.fromEulerAnglesYXZ(0, ry, 0)
				return CFrame.new(cf.Position) * yaw * CFrame.new(0, 0, 5)
			end

			local function ZK_DetachPhysics()
				local char = LocalPlayer.Character
				if char then
					local root = ZK_GetRoot(char)
					if root then
						root.AssemblyLinearVelocity = Vector3.zero
						root.AssemblyAngularVelocity = Vector3.zero
						pcall(function()
							if sethiddenproperty then
								sethiddenproperty(root, "PhysicsRepRootPart", nil)
							end
						end)
					end

					local hum = ZK_GetHum(char)
					if hum then
						hum.AutoRotate = true
					end
				end
			end

			local function ZK_StopCombat()
				if ZK_CombatConnection then
					ZK_CombatConnection:Disconnect()
					ZK_CombatConnection = nil
				end
				ZK_DetachPhysics()
				ZK_CurrentTarget = nil
			end

			local function ZK_StartCombat()
				if ZK_CombatConnection then
					return
				end

				ZK_CombatConnection = RunService.Heartbeat:Connect(function()
					if not ZK_Follow or not ZK_Target then
						if ZK_CurrentTarget then
							ZK_CurrentTarget = nil
							ZK_DetachPhysics()
						end
						return
					end

					if not ZK_Target.Parent then
						ZK_Follow = false
						ZK_Target = nil
						ZK_StopCombat()
						return
					end

					local targetChar = ZK_GetChar(ZK_Target)
					if not ZK_Valid(targetChar) then
						ZK_Follow = false
						ZK_CurrentTarget = nil
						ZK_RestoreHitbox()
						ZK_StopCombat()
						return
					end

					local myChar = LocalPlayer.Character
					local myRoot = ZK_GetRoot(myChar)
					local myHum = ZK_GetHum(myChar)
					local targetRoot = ZK_GetRoot(targetChar)

					if not myRoot or not myHum or not targetRoot then
						return
					end

					ZK_CurrentTarget = ZK_Target

					myHum.AutoRotate = false
					myRoot.AssemblyLinearVelocity = Vector3.zero
					myRoot.AssemblyAngularVelocity = Vector3.zero

					if not getgenv().desync then
						myRoot.CFrame = ZK_GetBehindCFrame(targetRoot)
					end

					if sethiddenproperty then
						pcall(function()
							sethiddenproperty(myRoot, "PhysicsRepRootPart", targetRoot)
						end)
					end

					if ZK_AutoCombat and not targetChar:FindFirstChild("ForceField") then
						local now = tick()

						if now - ZK_LastDash > 3.5 then
							ZK_LastDash = now
							ZK_Press(Enum.KeyCode.Q, 0.03)
						end

						if now - ZK_LastSkill > 0.8 then
							ZK_LastSkill = now
							local keyToPress = ZK_SkillKeys[ZK_SkillIndex]
							ZK_SkillIndex = (ZK_SkillIndex % #ZK_SkillKeys) + 1
							ZK_Press(keyToPress, 0.03)
						end
					end
				end)
			end

			-- Stable M1 loop copied from ZykeHub's working Auto Combat architecture.
			task.spawn(function()
				while true do
					if ZK_AutoCombat and ZK_Follow and ZK_CurrentTarget then
						local char = LocalPlayer.Character
						local communicate = char and char:FindFirstChild("Communicate")
						if communicate then
							pcall(communicate.FireServer, communicate, {Goal = "LeftClick"})
							pcall(communicate.FireServer, communicate, {Goal = "LeftClickRelease"})
						end
					end
					RunService.Heartbeat:Wait()
				end
			end)

			local function ZK_StopSpectate()
				ZK_Spectate = false

				if ZK_SpectateConnection then
					ZK_SpectateConnection:Disconnect()
					ZK_SpectateConnection = nil
				end

				local cam = Workspace.CurrentCamera
				cam.CameraType = Enum.CameraType.Custom

				if LocalPlayer.Character then
					local hum = ZK_GetHum(LocalPlayer.Character)
					if hum then
						cam.CameraSubject = hum
					end
				end

				ZK_SpectateRotating = false
				UserInputService.MouseBehavior = Enum.MouseBehavior.Default
			end

			local function ZK_StartSpectate()
				if not ZK_Target then
					return
				end

				ZK_StopSpectate()
				ZK_Spectate = true
				ZK_SpectateYaw, ZK_SpectatePitch = 0, -0.3
				ZK_SpectateDistance, ZK_TargetDistance = 10, 10

				local cam = Workspace.CurrentCamera
				cam.CameraType = Enum.CameraType.Scriptable
				ZK_SpectateRotating = false

				ZK_SpectateConnection = RunService.RenderStepped:Connect(function(dt)
					if not ZK_Spectate or not ZK_Target or not ZK_Target.Parent then
						ZK_StopSpectate()
						return
					end

					local targetChar = ZK_GetChar(ZK_Target)
					local root = ZK_GetRoot(targetChar) or (targetChar and targetChar:FindFirstChild("Head"))
					if not root then
						return
					end

					ZK_SpectateDistance =
						ZK_SpectateDistance
						+ (ZK_TargetDistance - ZK_SpectateDistance)
						* (1 - math.exp(-15 * dt))

					local dir =
						(CFrame.Angles(0, ZK_SpectateYaw, 0)
						* CFrame.Angles(ZK_SpectatePitch, 0, 0)).LookVector
						* ZK_SpectateDistance

					cam.CFrame = CFrame.new(root.Position - dir, root.Position)
				end)
			end

			-- Spectate camera controls mirrored from ZykeHub's working spectate implementation.
			UserInputService.InputBegan:Connect(function(input, gameProcessed)
				if gameProcessed then return end
				if input.UserInputType == Enum.UserInputType.MouseButton2 and ZK_Spectate then
					ZK_SpectateRotating = true
					UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
				end
			end)

			UserInputService.InputEnded:Connect(function(input, gameProcessed)
				if gameProcessed then return end
				if input.UserInputType == Enum.UserInputType.MouseButton2 and ZK_Spectate then
					ZK_SpectateRotating = false
					UserInputService.MouseBehavior = Enum.MouseBehavior.Default
				end
			end)

			UserInputService.InputChanged:Connect(function(input, gameProcessed)
				if gameProcessed then return end
				if input.UserInputType == Enum.UserInputType.MouseMovement and ZK_SpectateRotating and ZK_Spectate then
					ZK_SpectateYaw = ZK_SpectateYaw - input.Delta.X * 0.005
					ZK_SpectatePitch = math.clamp(ZK_SpectatePitch - input.Delta.Y * 0.005, -1.5, 0.5)
				end
				if input.UserInputType == Enum.UserInputType.MouseWheel and ZK_Spectate then
					ZK_TargetDistance = math.clamp(ZK_TargetDistance - input.Position.Z * 3.5, 2, 50)
				end
			end)

			-- ========================== SAFE LOW RENDER / FPS BOOST ==========================
			-- Disables/mutes expensive visual effects across Workspace + Lighting without
			-- permanently destroying instances. Newly spawned VFX are caught automatically.
			local ZK_HeavyEffectClasses = {
				ParticleEmitter = true,
				Trail = true,
				Beam = true,
				Smoke = true,
				Fire = true,
				Sparkles = true,
				Highlight = true,
				Clouds = true,
			}

			local function ZK_SafeSet(instance, property, value)
				pcall(function()
					instance[property] = value
				end)
			end

			local function ZK_MuteTransparency(instance)
				if ZK_SavedTransparencyState[instance] == nil then
					local ok, value = pcall(function() return instance.Transparency end)
					if ok then
						ZK_SavedTransparencyState[instance] = value
					end
				end
				ZK_SafeSet(instance, "Transparency", 1)
			end

			local function ZK_MuteEffect(instance)
				if not instance or not instance.Parent or not ZK_Render then return end

				if ZK_HeavyEffectClasses[instance.ClassName] then
					if ZK_SavedEffectState[instance] == nil then
						local ok, enabled = pcall(function() return instance.Enabled end)
						ZK_SavedEffectState[instance] = ok and enabled or true
					end
					ZK_SafeSet(instance, "Enabled", false)
				return
				end

				if instance:IsA("Explosion") then
					-- Explosions have no Enabled property and are short-lived; moving them out
					-- of the render tree is cheaper than letting their visual effect spawn.
					if ZK_SavedSurfaceAppearanceParents[instance] == nil then
						ZK_SavedSurfaceAppearanceParents[instance] = instance.Parent
					end
					instance.Parent = nil
					return
				end

				if instance:IsA("Decal") or instance:IsA("Texture") then
					ZK_MuteTransparency(instance)
					return
				end

				if instance:IsA("SurfaceAppearance") then
					-- SurfaceAppearance has no Enabled property. Detach temporarily so it no
					-- longer participates in rendering, while keeping the instance restorable.
					if ZK_SavedSurfaceAppearanceParents[instance] == nil then
						ZK_SavedSurfaceAppearanceParents[instance] = instance.Parent
					end
					instance.Parent = nil
					return
				end

				if instance:IsA("Atmosphere") then
					if ZK_SavedAtmosphere == nil then
						ZK_SavedAtmosphere = {
							Instance = instance,
							Density = instance.Density,
							Haze = instance.Haze,
							Glare = instance.Glare,
							Offset = instance.Offset,
						}
					end
					ZK_SafeSet(instance, "Density", 0)
					ZK_SafeSet(instance, "Haze", 0)
					ZK_SafeSet(instance, "Glare", 0)
					ZK_SafeSet(instance, "Offset", 0)
					return
				end

				if instance:IsA("PostEffect") then
					if ZK_SavedEffectState[instance] == nil then
						local ok, enabled = pcall(function() return instance.Enabled end)
						ZK_SavedEffectState[instance] = ok and enabled or true
					end
					ZK_SafeSet(instance, "Enabled", false)
				end
			end

			local function ZK_OptimizePart(part)
				if not part or not part.Parent or not part:IsA("BasePart") then return end

				if ZK_SavedPartState[part] == nil then
					local state = {}
					state.Material = part.Material
					state.CastShadow = part.CastShadow
					state.Reflectance = part.Reflectance
					if part:IsA("MeshPart") then
						state.RenderFidelity = part.RenderFidelity
					end
					ZK_SavedPartState[part] = state
				end

				ZK_SafeSet(part, "Material", Enum.Material.SmoothPlastic)
				ZK_SafeSet(part, "CastShadow", false)
				ZK_SafeSet(part, "Reflectance", 0)
				if part:IsA("MeshPart") then
					ZK_SafeSet(part, "RenderFidelity", Enum.RenderFidelity.Performance)
				end
			end

			local function ZK_SweepInstance(instance)
				if not ZK_Render or not instance then return end
				pcall(function()
					if instance:IsA("BasePart") then
						ZK_OptimizePart(instance)
					end
					ZK_MuteEffect(instance)
				end)
			end

			local function ZK_ScanWorkspace()
				if not ZK_Render then return end
				pcall(function()
					for _, descendant in ipairs(Workspace:GetDescendants()) do
						ZK_SweepInstance(descendant)
					end
				end)
				pcall(function()
					for _, descendant in ipairs(ZK_Lighting:GetDescendants()) do
						ZK_SweepInstance(descendant)
					end
				end)
			end

			local function ZK_RestoreRender()
				-- Restore effects that still exist in the game tree.
				for instance, enabled in pairs(ZK_SavedEffectState) do
					pcall(function()
						if instance.Parent then
							instance.Enabled = enabled
						end
					end)
				end

				for instance, transparency in pairs(ZK_SavedTransparencyState) do
					pcall(function()
						if instance.Parent then
							instance.Transparency = transparency
						end
					end)
				end

				for instance, parent in pairs(ZK_SavedSurfaceAppearanceParents) do
					pcall(function()
						if instance and parent and instance.Parent == nil and parent.Parent then
							instance.Parent = parent
						end
					end)
				end

				for part, state in pairs(ZK_SavedPartState) do
					pcall(function()
						if part and part.Parent then
							part.Material = state.Material
							part.CastShadow = state.CastShadow
							part.Reflectance = state.Reflectance
							if part:IsA("MeshPart") and state.RenderFidelity then
								part.RenderFidelity = state.RenderFidelity
							end
						end
					end)
				end

			for effect, state in pairs(ZK_SavedLighting) do
				pcall(function()
					if effect.Parent then
						effect.Enabled = state.Enabled
					end
				end)
			end

			if ZK_SavedAtmosphere and ZK_SavedAtmosphere.Instance then
				pcall(function()
					local instance = ZK_SavedAtmosphere.Instance
					if instance.Parent then
						instance.Density = ZK_SavedAtmosphere.Density
						instance.Haze = ZK_SavedAtmosphere.Haze
						instance.Glare = ZK_SavedAtmosphere.Glare
						instance.Offset = ZK_SavedAtmosphere.Offset
					end
				end)
			end

			if ZK_SavedTerrain.Terrain then
				pcall(function()
					local terrain = ZK_SavedTerrain.Terrain
					if terrain.Parent then
						terrain.Decoration = ZK_SavedTerrain.Decoration
						terrain.WaterWaveSize = ZK_SavedTerrain.WaterWaveSize
						terrain.WaterReflectance = ZK_SavedTerrain.WaterReflectance
						terrain.WaterTransparency = ZK_SavedTerrain.WaterTransparency
					end
				end)
			end

			ZK_SavedLighting = {}
			ZK_SavedTerrain = {}
			ZK_SavedPartState = {}
			ZK_SavedEffectState = {}
			ZK_SavedTransparencyState = {}
			ZK_SavedSurfaceAppearanceParents = {}
			ZK_SavedAtmosphere = nil
		end

			local function ZK_SetRender(on)
				if on then
					if ZK_Render then return end
					ZK_Render = true
					ZK_RenderGeneration = ZK_RenderGeneration + 1
					local generation = ZK_RenderGeneration

					-- Snapshot Lighting state before modifying it.
					ZK_SavedLighting = {}
					for _, effect in ipairs(ZK_Lighting:GetChildren()) do
						if effect:IsA("PostEffect") then
							ZK_SavedLighting[effect] = {Enabled = effect.Enabled}
							ZK_SafeSet(effect, "Enabled", false)
						end
					end

					pcall(function()
						ZK_RenderRenderingQuality = settings().Rendering.QualityLevel
					end)
					pcall(function()
						ZK_RenderGlobalShadows = ZK_Lighting.GlobalShadows
						ZK_RenderTechnology = ZK_Lighting.Technology
						ZK_RenderBrightness = ZK_Lighting.Brightness
					end)

					pcall(function()
						settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
						ZK_Lighting.GlobalShadows = false
						ZK_Lighting.Technology = Enum.Technology.Compatibility
						ZK_Lighting.Brightness = math.min(ZK_Lighting.Brightness, 1)
					end)

					local terrain = Workspace:FindFirstChildOfClass("Terrain")
					if terrain then
						ZK_SavedTerrain = {
							Terrain = terrain,
							Decoration = terrain.Decoration,
							WaterWaveSize = terrain.WaterWaveSize,
							WaterReflectance = terrain.WaterReflectance,
							WaterTransparency = terrain.WaterTransparency,
						}
						pcall(function()
							terrain.Decoration = false
							terrain.WaterWaveSize = 0
							terrain.WaterReflectance = 0
							terrain.WaterTransparency = 1
						end)
					end

					ZK_ScanWorkspace()

					if ZK_RenderConnection then
						ZK_RenderConnection:Disconnect()
					end
					ZK_RenderConnection = Workspace.DescendantAdded:Connect(function(descendant)
						if not ZK_Render then return end
						task.defer(function()
							if ZK_Render and generation == ZK_RenderGeneration then
								ZK_SweepInstance(descendant)
							end
						end)
					end)

					-- A modest periodic sweep catches effects that are enabled or reconfigured
					-- after spawning without scanning every frame.
					if ZK_RenderEnforceThread then
						ZK_RenderGeneration = ZK_RenderGeneration + 1
					end
					local workerGeneration = ZK_RenderGeneration
					ZK_RenderEnforceThread = task.spawn(function()
						while ZK_Render and workerGeneration == ZK_RenderGeneration do
							task.wait(2)
							if ZK_Render and workerGeneration == ZK_RenderGeneration then
								ZK_ScanWorkspace()
							end
						end
				end)
				else
					if not ZK_Render then return end
					ZK_Render = false
					ZK_RenderGeneration = ZK_RenderGeneration + 1

					if ZK_RenderConnection then
						ZK_RenderConnection:Disconnect()
						ZK_RenderConnection = nil
					end
					-- No task.cancel required: the generation guard lets the old worker exit
					-- safely, avoiding executor-specific task cancellation errors.
					ZK_RenderEnforceThread = nil

					ZK_RestoreRender()
					pcall(function()
						if ZK_RenderRenderingQuality then
							settings().Rendering.QualityLevel = ZK_RenderRenderingQuality
						else
							settings().Rendering.QualityLevel = Enum.QualityLevel.Automatic
						end
					end)
					pcall(function()
						if ZK_RenderGlobalShadows ~= nil then ZK_Lighting.GlobalShadows = ZK_RenderGlobalShadows end
						if ZK_RenderTechnology ~= nil then ZK_Lighting.Technology = ZK_RenderTechnology end
						if ZK_RenderBrightness ~= nil then ZK_Lighting.Brightness = ZK_RenderBrightness end
					end)

					ZK_RenderRenderingQuality = nil
					ZK_RenderGlobalShadows = nil
					ZK_RenderTechnology = nil
					ZK_RenderBrightness = nil
				end
			end

			local function ZK_ToggleFollow(on)
				ZK_Follow = on

				if on then
					if not ZK_Target then
						ZK_Follow = false
						return
					end
					ZK_StartCombat()
				else
					ZK_StopCombat()
				end
			end

			local function ZK_ToggleAuto(on)
				ZK_AutoCombat = on
				if on then
					ZK_LastSkill = 0
					ZK_LastDash = 0
					ZK_SkillIndex = 1
				end
			end

			local function ZK_ToggleHitbox(on)
				ZK_Hitbox = on
				if on then
					ZK_ApplyHitbox()
				else
					ZK_RestoreHitbox()
				end
			end

			local function ZK_TeleportDummy()
				local char = LocalPlayer.Character
				local root = char and ZK_GetRoot(char)
				if not root then
					return
				end

				local playerNames = {}
				for _, p in ipairs(Players:GetPlayers()) do
					playerNames[p.Name] = true
				end

				for _, obj in ipairs(Workspace:GetDescendants()) do
					if obj:IsA("Model") and not playerNames[obj.Name] then
						local hum = ZK_GetHum(obj)
						local hrp = ZK_GetRoot(obj)
						if hum and hrp then
							root.CFrame = hrp.CFrame + Vector3.new(0, 4, 0)
							return
						end
					end
				end
			end

			u210:CreateSection("TARGET", v525)

			-- Local theme snapshot: u20/t2 are outside u238's valid scope.
			local ZK_Theme = {
				Panel = Color3.fromRGB(24, 24, 24),
				PanelAlt = Color3.fromRGB(32, 32, 32),
				Stroke = Color3.fromRGB(40, 40, 40),
				Accent = Color3.fromRGB(230, 140, 60),
				Text = Color3.fromRGB(240, 240, 240),
				SubText = Color3.fromRGB(160, 160, 160),
				GreyText = Color3.fromRGB(110, 110, 110),
			}

			-- Live target dropdown. TSBNEW's built-in dropdown stores a static list,
			-- so this uses a small custom control whose entries are rebuilt whenever
			-- players join/leave and whenever the dropdown is opened.
			local ZK_TargetFrame = Instance.new("Frame")
			ZK_TargetFrame.Size = UDim2.new(1, 0, 0, 54)
			ZK_TargetFrame.BackgroundTransparency = 1
			ZK_TargetFrame.ClipsDescendants = false
			ZK_TargetFrame.ZIndex = 20
			ZK_TargetFrame.Active = true
			ZK_TargetFrame.Parent = v525

			local ZK_TargetLabel = Instance.new("TextLabel")
			ZK_TargetLabel.Size = UDim2.new(1, 0, 0, 16)
			ZK_TargetLabel.BackgroundTransparency = 1
			ZK_TargetLabel.Font = Enum.Font.Gotham
			ZK_TargetLabel.TextSize = 13
			ZK_TargetLabel.TextColor3 = ZK_Theme.Text
			ZK_TargetLabel.TextXAlignment = Enum.TextXAlignment.Left
			ZK_TargetLabel.Text = "Target Player"
			ZK_TargetLabel.Parent = ZK_TargetFrame

			local ZK_TargetButton = Instance.new("TextButton")
			ZK_TargetButton.Size = UDim2.new(1, 0, 0, 30)
			ZK_TargetButton.Position = UDim2.new(0, 0, 0, 20)
			ZK_TargetButton.BackgroundColor3 = ZK_Theme.Panel
			ZK_TargetButton.BorderSizePixel = 0
			ZK_TargetButton.AutoButtonColor = false
			ZK_TargetButton.Font = Enum.Font.GothamSemibold
			ZK_TargetButton.TextSize = 12
			ZK_TargetButton.TextColor3 = ZK_Theme.Text
			ZK_TargetButton.Text = "Select Target...  ▾"
			ZK_TargetButton.Active = true
			ZK_TargetButton.Selectable = true
			ZK_TargetButton.ZIndex = 21
			ZK_TargetButton.Parent = ZK_TargetFrame

			local ZK_TargetCorner = Instance.new("UICorner")
			ZK_TargetCorner.CornerRadius = UDim.new(0, 6)
			ZK_TargetCorner.Parent = ZK_TargetButton

			local ZK_TargetStroke = Instance.new("UIStroke")
			ZK_TargetStroke.Color = ZK_Theme.Stroke
			ZK_TargetStroke.Thickness = 1
			ZK_TargetStroke.Parent = ZK_TargetButton

			local ZK_TargetList = Instance.new("ScrollingFrame")
			ZK_TargetList.Size = UDim2.new(1, 0, 0, 130)
			ZK_TargetList.Position = UDim2.new(0, 0, 0, 54)
			ZK_TargetList.BackgroundColor3 = ZK_Theme.PanelAlt
			ZK_TargetList.BorderSizePixel = 0
			ZK_TargetList.ScrollBarThickness = 8
			ZK_TargetList.ScrollBarImageColor3 = ZK_Theme.Accent
			ZK_TargetList.Visible = false
			ZK_TargetList.Active = true
			ZK_TargetList.ClipsDescendants = true
			ZK_TargetList.ZIndex = 50
			ZK_TargetList.ElasticBehavior = Enum.ElasticBehavior.Always
			ZK_TargetList.Parent = ZK_TargetFrame

			local ZK_TargetListCorner = Instance.new("UICorner")
			ZK_TargetListCorner.CornerRadius = UDim.new(0, 6)
			ZK_TargetListCorner.Parent = ZK_TargetList

			local ZK_TargetListLayout = Instance.new("UIListLayout")
			ZK_TargetListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			ZK_TargetListLayout.Parent = ZK_TargetList

			local ZK_DropdownOpen = false
			local ZK_TargetPlayerRows = {}

			local function ZK_ClearTargetRows()
				for _, row in ipairs(ZK_TargetPlayerRows) do
					pcall(function()
						row:Destroy()
					end)
				end
				ZK_TargetPlayerRows = {}
			end

			local function ZK_SetTarget(player)
				if not player or not player.Parent then
					return
				end

				ZK_Target = player
				if ZK_Hitbox then
					ZK_ApplyHitbox()
				end

				ZK_TargetButton.Text = player.DisplayName .. " (@" .. player.Name .. ")  ▾"
				ZK_DropdownOpen = false
				ZK_TargetList.Visible = false
				ZK_TargetFrame.Size = UDim2.new(1, 0, 0, 54)

				if ZK_Follow then
					ZK_StopCombat()
					ZK_StartCombat()
				end

				if ZK_Spectate then
					ZK_StopSpectate()
					ZK_StartSpectate()
				end
			end

			local function ZK_RefreshTargetList()
				ZK_ClearTargetRows()

				local count = 0
				for _, player in ipairs(Players:GetPlayers()) do
					if player ~= LocalPlayer then
						count = count + 1

						local row = Instance.new("TextButton")
						row.Size = UDim2.new(1, -4, 0, 34)
						row.BackgroundTransparency = 1
						row.BorderSizePixel = 0
						row.AutoButtonColor = false
						row.Active = true
						row.Selectable = true
						row.Text = player.DisplayName .. " (@" .. player.Name .. ")"
						row.TextColor3 = player == ZK_Target and ZK_Theme.Accent or ZK_Theme.SubText
						row.TextSize = 12
						row.Font = Enum.Font.Gotham
						row.TextXAlignment = Enum.TextXAlignment.Left
						row.LayoutOrder = count
						row.Active = true
						row.Selectable = true
						row.ZIndex = 51
						row.Parent = ZK_TargetList

						row.MouseEnter:Connect(function()
							if player ~= ZK_Target then
								u24:Create(row, TweenInfo.new(0.1), {
									BackgroundColor3 = ZK_Theme.Stroke
								}):Play()
							end
						end)

						row.MouseLeave:Connect(function()
							u24:Create(row, TweenInfo.new(0.1), {
								BackgroundColor3 = ZK_Theme.PanelAlt
							}):Play()
						end)

						-- Activated is the reliable cross-platform button event.
						row.Activated:Connect(function()
							ZK_SetTarget(player)
						end)

						table.insert(ZK_TargetPlayerRows, row)
					end
				end

				if count == 0 then
					local empty = Instance.new("TextLabel")
					empty.Size = UDim2.new(1, 0, 0, 34)
					empty.BackgroundTransparency = 1
					empty.Text = "No players"
					empty.TextColor3 = ZK_Theme.GreyText
					empty.TextSize = 12
					empty.Font = Enum.Font.Gotham
					empty.ZIndex = 21
					empty.Parent = ZK_TargetList
					table.insert(ZK_TargetPlayerRows, empty)
					count = 1
				end

				local rowHeight = 34
				ZK_TargetList.CanvasSize = UDim2.new(0, 0, 0, count * rowHeight)
				ZK_TargetList.Size = UDim2.new(
					1, 0, 0,
					math.min(156, math.max(rowHeight, count * rowHeight))
				)
			end

			local function ZK_SetDropdownOpen(open)
				ZK_DropdownOpen = open

				if open then
					ZK_RefreshTargetList()
					ZK_TargetList.Visible = true
					ZK_TargetFrame.Size = UDim2.new(1, 0, 0, 54 + ZK_TargetList.AbsoluteSize.Y)
					ZK_TargetButton.Text = (ZK_Target
						and (ZK_Target.DisplayName .. " (@" .. ZK_Target.Name .. ")")
						or "Select Target...") .. "  ▴"
					u24:Create(ZK_TargetStroke, TweenInfo.new(0.15), {
						Color = ZK_Theme.Accent
					}):Play()
				else
					ZK_TargetList.Visible = false
					ZK_TargetFrame.Size = UDim2.new(1, 0, 0, 54)
					ZK_TargetButton.Text = (ZK_Target
						and (ZK_Target.DisplayName .. " (@" .. ZK_Target.Name .. ")")
						or "Select Target...") .. "  ▾"
					u24:Create(ZK_TargetStroke, TweenInfo.new(0.15), {
						Color = ZK_Theme.Stroke
					}):Play()
				end
			end

			-- Activated handles mouse clicks and mobile taps with one path.
			ZK_TargetButton.Activated:Connect(function()
				ZK_SetDropdownOpen(not ZK_DropdownOpen)
			end)

			-- Initial list + live join/leave updates.
			ZK_RefreshTargetList()

			local ZK_PlayerAddedConnection = Players.PlayerAdded:Connect(function()
				task.defer(ZK_RefreshTargetList)
			end)

			local ZK_PlayerRemovingConnection = Players.PlayerRemoving:Connect(function(player)
				if player == ZK_Target then
					ZK_Target = nil
					ZK_ToggleFollow(false)
					ZK_StopSpectate()
					ZK_RestoreHitbox()
					ZK_TargetButton.Text = "Select Target...  ▾"
				end
				task.defer(ZK_RefreshTargetList)
			end)

			u210:CreateSection("FARM", v525)

			u210:CreateToggle("Follow Target [R]", v525, false, function(on)
				ZK_ToggleFollow(on)
			end)

			u210:CreateToggle("Auto Combat [G]", v525, false, function(on)
				ZK_ToggleAuto(on)
			end)

			u210:CreateToggle("Spectate Target [Y]", v525, false, function(on)
				if on then
					if ZK_Target then
						ZK_StartSpectate()
					end
				else
					ZK_StopSpectate()
				end
			end)

			u210:CreateToggle("Hitbox Helper", v525, false, function(on)
				ZK_ToggleHitbox(on)
			end)

			u210:CreateToggle("Low Render / FPS Boost", v525, false, function(on)
				task.spawn(function()
					ZK_SetRender(on)
				end)
			end)

			u210:CreateSection("UTILITY", v525)
			u210:CreateButton("TP to Dummy", v525, ZK_TeleportDummy)

			local ZK_AntiAFK = false
			u210:CreateToggle("Anti-AFK", v525, false, function(on)
				ZK_AntiAFK = on
			end)

			pcall(function()
				LocalPlayer.Idled:Connect(function()
					if not ZK_AntiAFK then
						return
					end
					local vu = game:GetService("VirtualUser")
					vu:CaptureController()
					vu:ClickButton2(Vector2.new())
				end)
			end)

			-- Target Farm keyboard shortcuts.
			UserInputService.InputBegan:Connect(function(input, processed)
				if processed or UserInputService:GetFocusedTextBox() then
					return
				end

				if input.KeyCode == Enum.KeyCode.R then
					ZK_ToggleFollow(not ZK_Follow)
				elseif input.KeyCode == Enum.KeyCode.G then
					ZK_ToggleAuto(not ZK_AutoCombat)
				elseif input.KeyCode == Enum.KeyCode.Y then
					if ZK_Spectate then
						ZK_StopSpectate()
					elseif ZK_Target then
						ZK_StartSpectate()
					end
				end
			end)

			LocalPlayer.CharacterAdded:Connect(function()
				task.wait(0.25)

				if ZK_Hitbox and ZK_Target then
					ZK_ApplyHitbox()
				end

				if ZK_Follow and ZK_Target then
					ZK_StopCombat()
					ZK_StartCombat()
				end
			end)
		end

		u210:PlayIntro()
	end

	local RenderStepped = RunService.RenderStepped
	local u240 = ArmouredTSBVersion
	local connection = RenderStepped:Connect(function()
		if _G.ArmouredTSBVersion == u240 and not u10 then
			return
		end
	end)

	t1[#t1 + 1] = connection

	-- Clean up an older hub instance, then boot the main hub directly.
	pcall(function()
		for _, guiName in ipairs({"Galaxy_TSB_Hub", "Galaxy_TSB_FloatBtn"}) do
			local gui = u7:FindFirstChild(guiName)
			if gui then gui:Destroy() end
		end
	end)

	u238()
	print(string.format("[Galaxy] Hub loaded in PlaceId %s.", tostring(game.PlaceId)))
	print("[Galaxy] Rayfield Gen2 UI ready. Mobile: tap G; Desktop: RightShift or P.")
	return
end

local ArmouredTSBShutdown = _G.ArmouredTSBShutdown

if type(ArmouredTSBShutdown) == "function" then
	pcall(_G.ArmouredTSBShutdown)
end

u8()
