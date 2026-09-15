local v1 = { "PrimeKenzouOnTop" }

local function f1()
  local k13KeySystem = Instance.new("ScreenGui")
  k13KeySystem.Name = "K13KeySystem"
  k13KeySystem.ResetOnSpawn = false
  k13KeySystem.DisplayOrder = 99999
  k13KeySystem.IgnoreGuiInset = true
  k13KeySystem.Parent = game.CoreGui

  local frame = Instance.new("Frame")
  frame.Size = UDim2.new(1, 0, 1, 0)
  frame.Position = UDim2.new(0, 0, 0, 0)
  frame.BackgroundColor3 = Color3.fromRGB(2, 0, 6)
  frame.BorderSizePixel = 0
  frame.Parent = k13KeySystem

  local uiGradient = Instance.new("UIGradient")

  uiGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(2, 0, 6)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(8, 0, 18)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(2, 0, 6)),
  })

  uiGradient.Rotation = 135
  uiGradient.Parent = frame

  local frame2 = Instance.new("Frame")
  frame2.Size = UDim2.new(1, 0, 0, 3)
  frame2.Position = UDim2.new(0, 0, 0, 0)
  frame2.BackgroundColor3 = Color3.fromRGB(180, 0, 255)
  frame2.BorderSizePixel = 0
  frame2.ZIndex = 3
  frame2.Parent = frame

  local uiGradient2 = Instance.new("UIGradient")

  uiGradient2.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(180, 0, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
  })

  uiGradient2.Parent = frame2

  local frame3 = Instance.new("Frame")
  frame3.Size = UDim2.new(1, 0, 0, 3)
  frame3.Position = UDim2.new(0, 0, 1, -3)
  frame3.BackgroundColor3 = Color3.fromRGB(180, 0, 255)
  frame3.BorderSizePixel = 0
  frame3.ZIndex = 3
  frame3.Parent = frame

  local uiGradient3 = Instance.new("UIGradient")

  uiGradient3.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(180, 0, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
  })

  uiGradient3.Parent = frame3

  task.spawn(function()
    local v2 = {
      "0", "1", "K", "1", "3", "@", "#", "$", "%", "^", "&", "*", "!", "?", "<", ">", "~", "|",
    }

    for i = 1, 45 do
      local v3 = i

      task.spawn(function()
        task.wait(math.random() * 3)

        while k13KeySystem and k13KeySystem.Parent do
          local textLabel = Instance.new("TextLabel")
          textLabel.Size = UDim2.new(0, 16, 0, 16)
          textLabel.Position = UDim2.new(0, (v3 - 1) * 24, 0, -20)
          textLabel.BackgroundTransparency = 1
          textLabel.Text = v2[math.random(1, #v2)]
          textLabel.Font = Enum.Font.Code
          textLabel.TextSize = 12
          textLabel.TextColor3 = Color3.fromRGB(100, 0, 160)
          textLabel.TextTransparency = 0.4
          textLabel.ZIndex = 2
          textLabel.Parent = frame

          local v4 = math.random(2, 6) / 100
          local v5 = math.random(25, 55)

          for j = 1, v5 do
            if not textLabel.Parent then
              break
            else
              textLabel.Position = UDim2.new(0, (v3 - 1) * 24, 0, -20 + j * 16)
              textLabel.Text = v2[math.random(1, #v2)]

              local v6 = j / v5

              textLabel.TextColor3 = Color3.fromRGB(
                math.floor(60 + v6 * 120), 0, math.floor(120 + v6 * 135)
              )

              textLabel.TextTransparency = 0.2 + v6 * 0.5

              task.wait(v4)
            end
          end

          pcall(function() textLabel:Destroy() end)
          task.wait(math.random() * 1.5)
        end
      end)
    end
  end)

  task.spawn(function()
    while k13KeySystem and k13KeySystem.Parent do
      task.spawn(function()
        local v7 = math.random(2, 6)

        local frame4 = Instance.new("Frame")
        frame4.Size = UDim2.new(0, v7, 0, v7)
        frame4.Position = UDim2.new(math.random(), 0, 1, 0)
        frame4.BackgroundColor3 = Color3.fromHSV(0.75 + math.random() * 0.1, 1, 1)
        frame4.BackgroundTransparency = math.random(2, 5) * 0.1
        frame4.BorderSizePixel = 0
        frame4.ZIndex = 2

        local uiCorner = Instance.new("UICorner")
        uiCorner.CornerRadius = UDim.new(1, 0)
        uiCorner.Parent = frame4

        frame4.Parent = frame
        local v8 = (math.random() - 0.5) * 0.1

        for k = 1, 60 do
          if not frame4.Parent then
            break
          end

          frame4.Position = UDim2.new(
            frame4.Position.X.Scale + v8 * 0.016, 0, frame4.Position.Y.Scale - 0.008, 0
          )

          frame4.BackgroundTransparency = frame4.BackgroundTransparency + 0.015

          if frame4.BackgroundTransparency >= 1 then
            break
          end

          task.wait(0.05)
        end

        pcall(function() frame4:Destroy() end)
      end)

      task.wait(0.08)
    end
  end)

  for m = 1, 60 do
    local frame5 = Instance.new("Frame")
    frame5.Size = UDim2.new(1, 0, 0, 1)
    frame5.Position = UDim2.new(0, 0, m / 60, 0)
    frame5.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    frame5.BackgroundTransparency = 0.88
    frame5.BorderSizePixel = 0
    frame5.ZIndex = 4
    frame5.Parent = frame
  end

  local frame6 = Instance.new("Frame")
  frame6.Size = UDim2.new(0, 620, 0, 460)
  frame6.Position = UDim2.new(0.5, -310, 0.5, -204)
  frame6.BackgroundColor3 = Color3.fromRGB(6, 0, 12)
  frame6.BorderSizePixel = 0
  frame6.ZIndex = 5
  frame6.Parent = k13KeySystem

  local uiCorner2 = Instance.new("UICorner")
  uiCorner2.CornerRadius = UDim.new(0, 18)
  uiCorner2.Parent = frame6

  local uiGradient4 = Instance.new("UIGradient")

  uiGradient4.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(12, 0, 22)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(6, 0, 12)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 0, 22)),
  })

  uiGradient4.Rotation = 135
  uiGradient4.Parent = frame6

  local uiStroke = Instance.new("UIStroke")
  uiStroke.Color = Color3.fromRGB(180, 0, 255)
  uiStroke.Thickness = 2.5
  uiStroke.Parent = frame6

  local frame7 = Instance.new("Frame")
  frame7.Size = UDim2.new(0.6, 0, 0, 2)
  frame7.Position = UDim2.new(0.2, 0, 0, 0)
  frame7.BackgroundColor3 = Color3.fromRGB(220, 100, 255)
  frame7.BorderSizePixel = 0
  frame7.ZIndex = 6
  frame7.Parent = frame6

  local uiGradient5 = Instance.new("UIGradient")

  uiGradient5.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(220, 100, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
  })

  uiGradient5.Parent = frame7

  local frame8 = Instance.new("Frame")
  frame8.Size = UDim2.new(0, 1, 0.85, 0)
  frame8.Position = UDim2.new(0, 220, 0.075, 0)
  frame8.BackgroundColor3 = Color3.fromRGB(100, 0, 150)
  frame8.BorderSizePixel = 0
  frame8.ZIndex = 6
  frame8.Parent = frame6

  local uiGradient6 = Instance.new("UIGradient")

  uiGradient6.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(180, 0, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
  })

  uiGradient6.Rotation = 90
  uiGradient6.Parent = frame8

  local frame9 = Instance.new("Frame")
  frame9.Size = UDim2.new(0, 218, 1, 0)
  frame9.Position = UDim2.new(0, 0, 0, 0)
  frame9.BackgroundTransparency = 1
  frame9.ZIndex = 6
  frame9.Parent = frame6

  local frame10 = Instance.new("Frame")
  frame10.Size = UDim2.new(0, 160, 0, 160)
  frame10.Position = UDim2.new(0.5, -80, 0, 30)
  frame10.BackgroundColor3 = Color3.fromRGB(10, 0, 18)
  frame10.BorderSizePixel = 0
  frame10.ZIndex = 7
  frame10.Parent = frame9

  local uiCorner3 = Instance.new("UICorner")
  uiCorner3.CornerRadius = UDim.new(0, 12)
  uiCorner3.Parent = frame10

  local uiStroke2 = Instance.new("UIStroke")
  uiStroke2.Color = Color3.fromRGB(180, 0, 255)
  uiStroke2.Thickness = 2.5
  uiStroke2.Parent = frame10

  local imageLabel = Instance.new("ImageLabel")
  imageLabel.Size = UDim2.new(1, 0, 1, 0)
  imageLabel.Position = UDim2.new(0, 0, 0, 0)
  imageLabel.BackgroundTransparency = 1
  imageLabel.Image = "https://www.roblox.com/Thumbs/Asset.ashx?width=420&height=420&assetId=113281701497572"
  imageLabel.ScaleType = Enum.ScaleType.Fit
  imageLabel.ZIndex = 8
  imageLabel.Parent = frame10

  local textLabel2 = Instance.new("TextLabel")
  textLabel2.Size = UDim2.new(1, 0, 0, 30)
  textLabel2.Position = UDim2.new(0, 0, 0, 200)
  textLabel2.BackgroundTransparency = 1
  textLabel2.Text = "KENZOU ALWAYS ON TOP"
  textLabel2.Font = Enum.Font.LuckiestGuy
  textLabel2.TextSize = 17
  textLabel2.TextColor3 = Color3.fromRGB(255, 255, 255)
  textLabel2.ZIndex = 7
  textLabel2.Parent = frame9

  local textLabel3 = Instance.new("TextLabel")
  textLabel3.Size = UDim2.new(1, 0, 0, 20)
  textLabel3.Position = UDim2.new(0, 0, 0, 235)
  textLabel3.BackgroundTransparency = 1
  textLabel3.Text = "BY PRIME KENZOU"
  textLabel3.Font = Enum.Font.LuckiestGuy
  textLabel3.TextSize = 14
  textLabel3.TextColor3 = Color3.fromRGB(200, 150, 255)
  textLabel3.ZIndex = 7
  textLabel3.Parent = frame9

  local textLabel4 = Instance.new("TextLabel")
  textLabel4.Size = UDim2.new(1, 0, 0, 16)
  textLabel4.Position = UDim2.new(0, 0, 0, 258)
  textLabel4.BackgroundTransparency = 1
  textLabel4.Text = "V2.0"
  textLabel4.Font = Enum.Font.LuckiestGuy
  textLabel4.TextSize = 11
  textLabel4.TextColor3 = Color3.fromRGB(80, 40, 110)
  textLabel4.ZIndex = 7
  textLabel4.Parent = frame9

  local frame11 = Instance.new("Frame")
  frame11.Size = UDim2.new(0, 378, 1, 0)
  frame11.Position = UDim2.new(0, 230, 0, 0)
  frame11.BackgroundTransparency = 1
  frame11.ZIndex = 6
  frame11.Parent = frame6

  local frame12 = Instance.new("Frame")
  frame12.Size = UDim2.new(1, -20, 0, 40)
  frame12.Position = UDim2.new(0, 10, 0, 25)
  frame12.BackgroundTransparency = 1
  frame12.ZIndex = 6
  frame12.Parent = frame11

  local textLabel5 = Instance.new("TextLabel")
  textLabel5.Size = UDim2.new(1, 0, 1, 0)
  textLabel5.Position = UDim2.new(0, 3, 0, 3)
  textLabel5.BackgroundTransparency = 1
  textLabel5.Text = "KENZOU | KEY SYSTEM"
  textLabel5.Font = Enum.Font.LuckiestGuy
  textLabel5.TextSize = 26
  textLabel5.TextColor3 = Color3.fromRGB(50, 0, 80)
  textLabel5.ZIndex = 6
  textLabel5.Parent = frame12

  local textLabel6 = Instance.new("TextLabel")
  textLabel6.Size = UDim2.new(1, 0, 1, 0)
  textLabel6.BackgroundTransparency = 1
  textLabel6.Text = "KENZOU | KEY SYSTEM"
  textLabel6.Font = Enum.Font.LuckiestGuy
  textLabel6.TextSize = 26
  textLabel6.TextColor3 = Color3.fromRGB(255, 255, 255)
  textLabel6.ZIndex = 7
  textLabel6.Parent = frame12

  task.spawn(function()
    while k13KeySystem and k13KeySystem.Parent do
      task.wait(math.random(2, 6))

      for n = 1, math.random(3, 5) do
        pcall(function()
          textLabel6.Position = UDim2.new(0, math.random(-4, 4), 0, math.random(-2, 2))
          textLabel6.TextColor3 = Color3.fromRGB(220, 180, 255)
        end)

        task.wait(0.04)

        pcall(function()
          textLabel6.Position = UDim2.new(0, 0, 0, 0)
          textLabel6.TextColor3 = Color3.fromRGB(255, 255, 255)
        end)

        task.wait(0.04)
      end
    end
  end)

  local textLabel7 = Instance.new("TextLabel")
  textLabel7.Size = UDim2.new(1, -20, 0, 20)
  textLabel7.Position = UDim2.new(0, 10, 0, 72)
  textLabel7.BackgroundTransparency = 1
  textLabel7.Text = ""
  textLabel7.Font = Enum.Font.Code
  textLabel7.TextSize = 12
  textLabel7.TextColor3 = Color3.fromRGB(180, 120, 230)
  textLabel7.TextXAlignment = Enum.TextXAlignment.Left
  textLabel7.ZIndex = 6
  textLabel7.Parent = frame11

  task.spawn(function()
    task.wait(0.5)

    for i6 = 1, #"ENTER YOUR KEY TO ACCESS FNOP HUB..." do
      if not textLabel7.Parent then
        break
      end

      textLabel7.Text = string.sub("ENTER YOUR KEY TO ACCESS PRIMEKENZOUU | PUBLIC VERSION...", 1, i6)
      task.wait(0.035)
    end

    while k13KeySystem and k13KeySystem.Parent do
      task.wait(0.5)

      if not textLabel7.Parent then
        break
      else
        local text = textLabel7.Text

        if text:sub(-1) == "_" then
          textLabel7.Text = string.sub(text, 1, -2)
        else
          textLabel7.Text = text .. "_"
        end
      end
    end
  end)

  local frame13 = Instance.new("Frame")
  frame13.Size = UDim2.new(0.92, 0, 0, 1)
  frame13.Position = UDim2.new(0.04, 0, 0, 100)
  frame13.BackgroundColor3 = Color3.fromRGB(100, 0, 150)
  frame13.BorderSizePixel = 0
  frame13.ZIndex = 6
  frame13.Parent = frame11

  local uiGradient7 = Instance.new("UIGradient")

  uiGradient7.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 0, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(180, 0, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0)),
  })

  uiGradient7.Parent = frame13

  local textLabel8 = Instance.new("TextLabel")
  textLabel8.Size = UDim2.new(0.92, 0, 0, 18)
  textLabel8.Position = UDim2.new(0.04, 0, 0, 110)
  textLabel8.BackgroundTransparency = 1
  textLabel8.Text = "ACCESS KEY"
  textLabel8.Font = Enum.Font.LuckiestGuy
  textLabel8.TextSize = 13
  textLabel8.TextColor3 = Color3.fromRGB(255, 255, 255)
  textLabel8.TextXAlignment = Enum.TextXAlignment.Left
  textLabel8.ZIndex = 6
  textLabel8.Parent = frame11

  local frame14 = Instance.new("Frame")
  frame14.Size = UDim2.new(0.92, 0, 0, 44)
  frame14.Position = UDim2.new(0.04, 0, 0, 130)
  frame14.BackgroundColor3 = Color3.fromRGB(10, 0, 20)
  frame14.BorderSizePixel = 0
  frame14.ZIndex = 6
  frame14.Parent = frame11

  local uiCorner4 = Instance.new("UICorner")
  uiCorner4.CornerRadius = UDim.new(0, 8)
  uiCorner4.Parent = frame14

  local uiStroke3 = Instance.new("UIStroke")
  uiStroke3.Color = Color3.fromRGB(100, 0, 150)
  uiStroke3.Thickness = 1.5
  uiStroke3.Parent = frame14

  local textBox = Instance.new("TextBox")
  textBox.Size = UDim2.new(1, -20, 1, 0)
  textBox.Position = UDim2.new(0, 10, 0, 0)
  textBox.BackgroundTransparency = 1
  textBox.PlaceholderText = "ENTER KEY HERE..."
  textBox.Text = ""
  textBox.Font = Enum.Font.LuckiestGuy
  textBox.TextSize = 15
  textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
  textBox.PlaceholderColor3 = Color3.fromRGB(120, 80, 160)
  textBox.ZIndex = 7
  textBox.Parent = frame14

  textBox.Focused:Connect(function()
    uiStroke3.Color = Color3.fromRGB(200, 0, 255)
    uiStroke3.Thickness = 2
  end)

  textBox.FocusLost:Connect(function()
    uiStroke3.Color = Color3.fromRGB(100, 0, 150)
    uiStroke3.Thickness = 1.5
  end)

  local textButton = Instance.new("TextButton")
  textButton.Size = UDim2.new(0.92, 0, 0, 44)
  textButton.Position = UDim2.new(0.04, 0, 0, 185)
  textButton.BackgroundColor3 = Color3.fromRGB(140, 0, 200)
  textButton.BorderSizePixel = 0
  textButton.Text = "SUBMIT KEY"
  textButton.Font = Enum.Font.LuckiestGuy
  textButton.TextSize = 18
  textButton.TextColor3 = Color3.fromRGB(255, 255, 255)
  textButton.ZIndex = 6
  textButton.Parent = frame11

  local uiCorner5 = Instance.new("UICorner")
  uiCorner5.CornerRadius = UDim.new(0, 8)
  uiCorner5.Parent = textButton

  local uiStroke4 = Instance.new("UIStroke")
  uiStroke4.Color = Color3.fromRGB(220, 0, 255)
  uiStroke4.Thickness = 2
  uiStroke4.Parent = textButton

  textButton.MouseEnter:Connect(function()
    textButton.BackgroundColor3 = Color3.fromRGB(180, 0, 240)
    textButton.Text = "ACCESS PRIMEKENZOUU | PUBLIC VERSION"
  end)

  textButton.MouseLeave:Connect(function()
    textButton.BackgroundColor3 = Color3.fromRGB(140, 0, 200)
    textButton.Text = "SUBMIT KEY"
  end)

  local textLabel9 = Instance.new("TextLabel")
  textLabel9.Size = UDim2.new(0.92, 0, 0, 18)
  textLabel9.Position = UDim2.new(0.04, 0, 0, 240)
  textLabel9.BackgroundTransparency = 1
  textLabel9.Text = "SYSTEM STATUS"
  textLabel9.Font = Enum.Font.LuckiestGuy
  textLabel9.TextSize = 13
  textLabel9.TextColor3 = Color3.fromRGB(255, 255, 255)
  textLabel9.TextXAlignment = Enum.TextXAlignment.Left
  textLabel9.ZIndex = 6
  textLabel9.Parent = frame11

  local frame15 = Instance.new("Frame")
  frame15.Size = UDim2.new(0.92, 0, 0, 8)
  frame15.Position = UDim2.new(0.04, 0, 0, 260)
  frame15.BackgroundColor3 = Color3.fromRGB(15, 0, 25)
  frame15.BorderSizePixel = 0
  frame15.ZIndex = 6
  frame15.Parent = frame11

  local uiCorner6 = Instance.new("UICorner")
  uiCorner6.CornerRadius = UDim.new(0, 4)
  uiCorner6.Parent = frame15

  local uiStroke5 = Instance.new("UIStroke")
  uiStroke5.Color = Color3.fromRGB(80, 0, 120)
  uiStroke5.Thickness = 1
  uiStroke5.Parent = frame15

  local frame16 = Instance.new("Frame")
  frame16.Size = UDim2.new(0.22, 0, 1, 0)
  frame16.BackgroundColor3 = Color3.fromRGB(180, 0, 255)
  frame16.BorderSizePixel = 0
  frame16.ZIndex = 7
  frame16.Parent = frame15

  local uiCorner7 = Instance.new("UICorner")
  uiCorner7.CornerRadius = UDim.new(0, 4)
  uiCorner7.Parent = frame16

  local uiGradient8 = Instance.new("UIGradient")

  uiGradient8.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 0, 180)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(220, 100, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 0, 255)),
  })

  uiGradient8.Parent = frame16

  task.spawn(function()
    local v9 = 1
    local total = 0

    while k13KeySystem and k13KeySystem.Parent and true do
      total = total + v9 * 0.025

      if total >= 0.78 then
        v9 = -1
      end

      if total <= 0 then
        v9 = 1
      end

      pcall(function() frame16.Position = UDim2.new(total, 0, 0, 0) end)
      task.wait(0.03)
    end
  end)

  local textLabel10 = Instance.new("TextLabel")
  textLabel10.Size = UDim2.new(0.92, 0, 0, 22)
  textLabel10.Position = UDim2.new(0.04, 0, 0, 280)
  textLabel10.BackgroundTransparency = 1
  textLabel10.Text = "FOLLOW ME ON TIKTOK!"
  textLabel10.Font = Enum.Font.LuckiestGuy
  textLabel10.TextSize = 16
  textLabel10.TextColor3 = Color3.fromRGB(255, 255, 255)
  textLabel10.TextXAlignment = Enum.TextXAlignment.Center
  textLabel10.ZIndex = 6
  textLabel10.Parent = frame11

  local textButton2 = Instance.new("TextButton")
  textButton2.Size = UDim2.new(0.92, 0, 0, 46)
  textButton2.Position = UDim2.new(0.04, 0, 0, 308)
  textButton2.BackgroundColor3 = Color3.fromRGB(80, 0, 120)
  textButton2.BorderSizePixel = 0
  textButton2.Text = "TIKTOK.COM/@KENZXOUU.OFFICIAL"
  textButton2.Font = Enum.Font.LuckiestGuy
  textButton2.TextSize = 15
  textButton2.TextColor3 = Color3.fromRGB(255, 255, 255)
  textButton2.ZIndex = 6
  textButton2.Parent = frame11

  local uiCorner8 = Instance.new("UICorner")
  uiCorner8.CornerRadius = UDim.new(0, 8)
  uiCorner8.Parent = textButton2

  local uiStroke6 = Instance.new("UIStroke")
  uiStroke6.Color = Color3.fromRGB(180, 0, 255)
  uiStroke6.Thickness = 2
  uiStroke6.Parent = textButton2

  textButton2.MouseEnter:Connect(function()
    textButton2.BackgroundColor3 = Color3.fromRGB(120, 0, 160)
  end)

  textButton2.MouseLeave:Connect(function()
    textButton2.BackgroundColor3 = Color3.fromRGB(80, 0, 120)
  end)

  textButton2.MouseButton1Click:Connect(function()
    pcall(function() setclipboard("https://www.tiktok.com/@kenzxouu.official") end)

    textButton2.Text = "FOLLOW ME! THANK YOU PRE!"
    textButton2.TextColor3 = Color3.fromRGB(255, 255, 255)

    task.wait(2.5)

    textButton2.Text = "TIKTOK.COM/@KENZXOUU.OFFICIAL"
    textButton2.TextColor3 = Color3.fromRGB(255, 255, 255)
  end)

  local textLabel11 = Instance.new("TextLabel")
  textLabel11.Size = UDim2.new(0.92, 0, 0, 22)
  textLabel11.Position = UDim2.new(0.04, 0, 0, 365)
  textLabel11.BackgroundTransparency = 1
  textLabel11.Text = ""
  textLabel11.Font = Enum.Font.LuckiestGuy
  textLabel11.TextSize = 13
  textLabel11.TextColor3 = Color3.fromRGB(255, 80, 80)
  textLabel11.ZIndex = 6
  textLabel11.Parent = frame11

  task.spawn(function()
    while k13KeySystem and k13KeySystem.Parent do
      task.wait(0.05)
    end
  end)

  return k13KeySystem, textBox, textButton, textLabel11, frame16, true
end

local v10, v11, v12, v13, v14, v15 = f1()
local bindableEvent = Instance.new("BindableEvent")

v12.MouseButton1Click:Connect(function()
  local text2 = v11.Text
  local v16 = false

  for index, value in ipairs(v1) do
    if text2 == value then
      v16 = true
      break
    end
  end

  if v16 then
    v13.TextColor3 = Color3.fromRGB(0, 255, 120)
    v13.Text = "ACCESS GRANTED! LOADING PRIMEKENZOUU | PUBLIC VERSION..."

    v12.Active = false
    v12.Text = "LOADING..."

    task.spawn(function()
      v14.Position = UDim2.new(0, 0, 0, 0)

      for i7 = 1, 100 do
        if not v14.Parent then
          break
        end

        v14.Size = UDim2.new(i7 / 100, 0, 1, 0)
        task.wait(0.015)
      end

      task.wait(0.4)
      v10:Destroy()
      bindableEvent:Fire()
    end)
  else
    v13.TextColor3 = Color3.fromRGB(255, 60, 60)
    v13.Text = "ACCESS DENIED! INVALID KEY."

    task.spawn(function()
      for i8 = 1, 8 do
        if not v12.Parent then
          break
        end

        v12.Position = UDim2.new(0.04, math.random(-6, 6), 0, 185)
        task.wait(0.04)
      end

      v12.Position = UDim2.new(0.04, 0, 0, 185)
    end)

    v11.Text = ""
  end
end)

bindableEvent.Event:Wait()
loadstring(game:HttpGet("https://slh-hub.lovable.app/raw/kyomba2-obfuscated"))()
