
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local Http = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local Library = {}
local Window = {}; Window.__index = Window
local Tab = {}; Tab.__index = Tab
local Section = {}; Section.__index = Section
local T = {Bg=Color3.fromRGB(17,18,23), Side=Color3.fromRGB(21,22,29), Card=Color3.fromRGB(25,27,35), Field=Color3.fromRGB(33,35,45), Border=Color3.fromRGB(46,49,61), Text=Color3.fromRGB(231,232,241), Muted=Color3.fromRGB(147,151,169)}
local function make(class, parent, props)
 local o = Instance.new(class)
 for k,v in pairs(props or {}) do o[k]=v end
 o.Parent=parent
 return o
end
local function round(o,r) make("UICorner",o,{CornerRadius=UDim.new(0,r or 6)}) end
local function outline(o) return make("UIStroke",o,{Color=T.Border,Thickness=1,ApplyStrokeMode=Enum.ApplyStrokeMode.Border}) end
local function frame(parent,props)
 props=props or {}; props.BorderSizePixel=0
 return make("Frame",parent,props)
end
local function text(parent,str,props)
 local p={Text=str,Font=Enum.Font.Gotham,TextSize=13,TextColor3=T.Text,BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,Size=UDim2.new(1,0,0,20)}
 for k,v in pairs(props or {}) do p[k]=v end
 return make("TextLabel",parent,p)
end
local function button(parent,str,props)
 local p={Text=str,Font=Enum.Font.GothamMedium,TextSize=12,TextColor3=T.Text,BackgroundColor3=T.Field,BorderSizePixel=0,AutoButtonColor=false,Size=UDim2.new(1,0,0,30)}
 for k,v in pairs(props or {}) do p[k]=v end
 local b=make("TextButton",parent,p); round(b,5); return b
end
local function input(parent,placeholder,props)
 local p={Text="",PlaceholderText=placeholder,PlaceholderColor3=T.Muted,TextColor3=T.Text,Font=Enum.Font.Gotham,TextSize=12,ClearTextOnFocus=false,TextXAlignment=Enum.TextXAlignment.Left,BackgroundColor3=T.Field,BorderSizePixel=0,Size=UDim2.new(1,0,0,30)}
 for k,v in pairs(props or {}) do p[k]=v end
 local o=make("TextBox",parent,p); round(o,5)
 make("UIPadding",o,{PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,10)})
 return o
end
local function vertical(parent,gap)
 return make("UIListLayout",parent,{Padding=UDim.new(0,gap or 8),SortOrder=Enum.SortOrder.LayoutOrder})
end
local function scroll(parent,props)
 props=props or {}; props.BackgroundTransparency=1; props.BorderSizePixel=0; props.CanvasSize=UDim2.new(); props.AutomaticCanvasSize=Enum.AutomaticSize.Y; props.ScrollBarThickness=3; props.ScrollBarImageColor3=T.Border
 return make("ScrollingFrame",parent,props)
end
function Window:_connect(signal,callback)
 local c=signal:Connect(callback); table.insert(self.Connections,c); return c
end
function Window:_call(fn,...)
 if not fn then return end
 local ok,err=pcall(fn,...)
 if not ok then warn("[Perplexity callback] "..tostring(err)); self:Notify("Callback error",tostring(err)) end
end
function Window:_closePopup()
 if self.PopupCleanup then self.PopupCleanup(); self.PopupCleanup=nil end
 if self.Popup then self.Popup:Destroy(); self.Popup=nil end
end
function Window:_popup(anchor,width,height)
 self:_closePopup()
 local size=self.Root.AbsoluteSize
 width=math.min(width,size.X); height=math.min(height,size.Y)
 local pos=anchor.AbsolutePosition; local x=math.clamp(pos.X,0,math.max(0,size.X-width))
 local y=pos.Y+anchor.AbsoluteSize.Y+5
 if y+height>size.Y then y=pos.Y-height-5 end
 y=math.clamp(y,0,math.max(0,size.Y-height))
 local layer=button(self.Root,"",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,ZIndex=100})
 self.Popup=layer
 local panel=frame(layer,{Position=UDim2.fromOffset(x,y),Size=UDim2.fromOffset(width,height),BackgroundColor3=T.Card,ZIndex=101,Active=true})
 round(panel,7); outline(panel)
 layer.Activated:Connect(function() self:_closePopup() end)
 return panel
end
function Window:_capture(btn,fn)
 if self.CaptureCancel then self.CaptureCancel() end
 local old=btn.Text
 btn.Text="Press Key"
 self.Capture=function(key) btn.Text=old; self.Capture=nil; self.CaptureCancel=nil; fn(key) end
 self.CaptureCancel=function() btn.Text=old; self.Capture=nil; self.CaptureCancel=nil end
end
function Window:SetAccent(color)
 assert(typeof(color)=="Color3","Accent must be Color3")
 self.Accent=color
 for _,fn in ipairs(self.Painters) do fn() end
end
function Window:Toggle(state)
 if state==nil then state=not self.Visible end
 self.Visible=state
 self.DragControl=nil
 self.Main.Visible=self.Visible
 self:_closePopup()
 if self.CaptureCancel then self.CaptureCancel() end
end
function Window:Destroy()
 if self.Dead then return end
 self.Dead=true; self:_closePopup()
 for _,c in ipairs(self.Connections) do c:Disconnect() end
 self.Connections={}; self.Capture=nil; self.CaptureCancel=nil
 self.Gui:Destroy()
end
function Window:Notify(title,message,duration)
 if self.Dead then return end
 local holder=frame(self.Notifications,{Size=UDim2.new(1,0,0,74),BackgroundColor3=T.Card})
 round(holder,7); outline(holder)
 text(holder,title,{Position=UDim2.fromOffset(12,8),Size=UDim2.new(1,-24,0,20),Font=Enum.Font.GothamMedium,TextColor3=self.Accent})
 text(holder,message,{Position=UDim2.fromOffset(12,30),Size=UDim2.new(1,-24,0,36),TextSize=12,TextColor3=T.Muted,TextWrapped=true,TextTruncate=Enum.TextTruncate.None,TextYAlignment=Enum.TextYAlignment.Top})
 task.delay(duration or 4,function() if holder.Parent then holder:Destroy() end end)
 local cards={}
 for _,o in ipairs(self.Notifications:GetChildren()) do if o:IsA("Frame") then table.insert(cards,o) end end
 if #cards>4 then cards[1]:Destroy() end
end
function Library.new(options)
 if type(options)=="string" then options={Title=options} end
 options=options or {}
 local self=setmetatable({Connections={},Painters={},Controls={},Tabs={},Visible=true,Accent=options.Accent or Color3.fromRGB(178,165,245),MenuKey=Enum.KeyCode.RightShift,Storage=options.Storage,Slots={},Dead=false},Window)
 local player=Players.LocalPlayer
 assert(player,"Perplexity must run on the client")
 local parent=options.Parent or player:WaitForChild("PlayerGui")
 local old=parent:FindFirstChild("PerplexitySlate")
 if old then old:Destroy() end
 self.Gui=make("ScreenGui",parent,{Name="PerplexitySlate",ResetOnSpawn=false,IgnoreGuiInset=true,DisplayOrder=100,ZIndexBehavior=Enum.ZIndexBehavior.Sibling})
 self.Root=frame(self.Gui,{Size=UDim2.fromScale(1,1),BackgroundTransparency=1})
 self.Main=frame(self.Root,{Size=UDim2.fromOffset(860,560),Position=UDim2.fromOffset(100,80),BackgroundColor3=T.Bg})
 round(self.Main,10); outline(self.Main)
 self.Scale=make("UIScale",self.Main,{Scale=1})
 local sidebar=frame(self.Main,{Size=UDim2.new(0,196,1,0),BackgroundColor3=T.Side}); round(sidebar,10)
 frame(sidebar,{Position=UDim2.new(1,-1,0,12),Size=UDim2.new(0,1,1,-24),BackgroundColor3=T.Border})
 local brand=text(sidebar,"Perplexity.win",{Position=UDim2.fromOffset(22,21),Size=UDim2.fromOffset(164,26),Font=Enum.Font.GothamBold,TextSize=19})
 text(sidebar,"",{Position=UDim2.fromOffset(23,49),TextSize=10,TextColor3=T.Muted,Size=UDim2.fromOffset(160,20)})
 table.insert(self.Painters,function() brand.TextColor3=self.Accent end)
 text(sidebar,"",{Position=UDim2.fromOffset(22,97),TextSize=10,TextColor3=T.Muted,Size=UDim2.fromOffset(150,18)})
 self.Nav=scroll(sidebar,{Position=UDim2.fromOffset(12,125),Size=UDim2.new(1,-24,1,-218)}); vertical(self.Nav,6)
 frame(sidebar,{Position=UDim2.new(0,18,1,-75),Size=UDim2.new(1,-36,0,1),BackgroundColor3=T.Border})
 text(sidebar,"@"..player.Name,{Position=UDim2.new(0,22,1,-62),Size=UDim2.fromOffset(155,22),TextSize=12})
 self.KeyHint=text(sidebar,"RightShift to toggle",{Position=UDim2.new(0,22,1,-37),Size=UDim2.fromOffset(160,20),TextSize=10,TextColor3=T.Muted})
 local handle=frame(self.Main,{Position=UDim2.fromOffset(196,0),Size=UDim2.new(1,-240,0,86),BackgroundTransparency=1,Active=true})
 self.Heading=text(handle,options.Title or "Overview",{Position=UDim2.fromOffset(24,18),Size=UDim2.fromOffset(260,28),Font=Enum.Font.GothamMedium,TextSize=22})
 self.Description=text(handle,"",{Position=UDim2.fromOffset(24,49),Size=UDim2.fromOffset(380,22),TextSize=12,TextColor3=T.Muted})
 local close=button(self.Main,"×",{Position=UDim2.new(1,-42,0,20),Size=UDim2.fromOffset(26,26),BackgroundTransparency=1,TextSize=20,TextColor3=T.Muted})
 self:_connect(close.Activated,function() self:Toggle(false) end)
 self.ScreenGui=self.Gui
 self.MainFrame=self.Main
 self.Search=input(self.Main,"Search…",{Position=UDim2.fromOffset(220,88),Size=UDim2.new(1,-244,0,32)})
 self.Body=frame(self.Main,{Position=UDim2.fromOffset(220,138),Size=UDim2.new(1,-244,1,-180),BackgroundTransparency=1})
 text(self.Main,"",{Position=UDim2.new(0,220,1,-28),Size=UDim2.fromOffset(350,18),TextSize=10,TextColor3=T.Muted})
 self.Notifications=frame(self.Root,{AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-16,1,-16),Size=UDim2.fromOffset(280,340),BackgroundTransparency=1,ZIndex=200})
 local nl=vertical(self.Notifications,8); nl.VerticalAlignment=Enum.VerticalAlignment.Bottom
 local moved=false; local dragging; local start; local origin
 local function clampPos(x,y)
  local sz=self.Root.AbsoluteSize; local scale=self.Scale.Scale
  self.Main.Position=UDim2.fromOffset(math.clamp(x,0,math.max(0,sz.X-860*scale)),math.clamp(y,0,math.max(0,sz.Y-560*scale)))
 end
 local function resize()
  self:_closePopup()
  local sz=self.Root.AbsoluteSize
  self.Scale.Scale=math.max(0.1,math.min(1,(sz.X-24)/860,(sz.Y-24)/560))
  if moved then clampPos(self.Main.Position.X.Offset,self.Main.Position.Y.Offset)
  else clampPos((sz.X-860*self.Scale.Scale)/2,(sz.Y-560*self.Scale.Scale)/2) end
 end
 self:_connect(self.Root:GetPropertyChangedSignal("AbsoluteSize"),resize)
 self:_connect(handle.InputBegan,function(i)
  if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
   self:_closePopup(); dragging=i; start=i.Position; origin=self.Main.Position; moved=true
  end
 end)
 self.DragControl=nil
 self:_connect(UIS.InputChanged,function(i)
  if dragging and (i==dragging or (dragging.UserInputType==Enum.UserInputType.MouseButton1 and i.UserInputType==Enum.UserInputType.MouseMovement)) then
   local delta=i.Position-start; clampPos(origin.X.Offset+delta.X,origin.Y.Offset+delta.Y)
  end
  local drag=self.DragControl
  if drag and (i==drag.Input or (drag.Input.UserInputType==Enum.UserInputType.MouseButton1 and i.UserInputType==Enum.UserInputType.MouseMovement)) then drag.Update(i.Position) end
 end)
 self:_connect(RunService.RenderStepped,function()
  local drag=self.DragControl
  if drag then
   local pos=drag.Input.UserInputType==Enum.UserInputType.Touch and drag.Input.Position or UIS:GetMouseLocation()
   drag.Update(pos)
  end
 end)
 self:_connect(UIS.InputEnded,function(i)
  if i==dragging then dragging=nil end
  if self.DragControl and i==self.DragControl.Input then self.DragControl=nil end
 end)
 self:_connect(UIS.WindowFocusReleased,function() dragging=nil; self.DragControl=nil end)
 self:_connect(UIS.InputBegan,function(i,processed)
  if self.Capture then
   if i.KeyCode==Enum.KeyCode.Escape then self.CaptureCancel(); return end
   if i.KeyCode==Enum.KeyCode.Backspace then self.Capture("None"); return end
   if i.UserInputType==Enum.UserInputType.Keyboard then self.Capture(i.KeyCode.Name); return end
   if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.MouseButton2 then self.Capture(i.UserInputType.Name); return end
   return
  end
  if UIS:GetFocusedTextBox() then return end
  if self.MenuKey~=Enum.KeyCode.Unknown and (i.KeyCode==self.MenuKey or i.UserInputType==self.MenuKey) then self:Toggle(); return end
  if i.KeyCode==Enum.KeyCode.Escape and self.Popup then self:_closePopup(); return end
  if processed then return end
  for _,c in pairs(self.Controls) do
   if c.Kind=="Keybind" and (c.Value==i.KeyCode.Name or c.Value==i.UserInputType.Name) then self:_call(c.OnPressed,c.Value) end
  end
 end)
 self:_connect(self.Search:GetPropertyChangedSignal("Text"),function() self:_filter() end)
 self:_connect(self.Gui.Destroying,function() self:Destroy() end)
 resize(); self:SetAccent(self.Accent)
 return self
end
function Window:_filter()
 if not self.ActiveTab then return end
 local q=self.Search.Text:lower()
 for _,s in ipairs(self.ActiveTab.Sections) do
  local count=0
  for _,r in ipairs(s.Rows) do
   local match=q=="" or r.Name:lower():find(q,1,true)~=nil
   r.Frame.Visible=match
   if match then count+=1 end
  end
  s.Frame.Visible=q=="" or count>0
 end
end
function Window:Tab(name,description)
 local tab=setmetatable({Window=self,Name=name,Description=description or "",Sections={}},Tab)
 tab.Button=button(self.Nav,name,{Size=UDim2.new(1,-4,0,38),TextXAlignment=Enum.TextXAlignment.Left,BackgroundTransparency=1,TextColor3=T.Muted})
 make("UIPadding",tab.Button,{PaddingLeft=UDim.new(0,14)})
 tab.Frame=frame(self.Body,{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Visible=false})
 tab.Columns={}
 for i=1,2 do
  local col=scroll(tab.Frame,{Position=UDim2.new((i-1)*0.515,0,0,0),Size=UDim2.new(0.485,0,1,0)})
  vertical(col,14); make("UIPadding",col,{PaddingLeft=UDim.new(0,1),PaddingRight=UDim.new(0,5),PaddingTop=UDim.new(0,1),PaddingBottom=UDim.new(0,4)})
  self:_connect(col:GetPropertyChangedSignal("CanvasPosition"),function() self:_closePopup() end)
  tab.Columns[i]=col
 end
 local function paint()
  local active=self.ActiveTab==tab
  tab.Button.BackgroundTransparency=active and 0 or 1
  tab.Button.BackgroundColor3=T.Field
  tab.Button.TextColor3=active and self.Accent or T.Muted
 end
 table.insert(self.Painters,paint)
 self:_connect(tab.Button.Activated,function() tab:Select() end)
 table.insert(self.Tabs,tab)
 if not self.ActiveTab then tab:Select() end
 return tab
end
function Tab:Select()
 local w=self.Window; w:_closePopup()
 if w.ActiveTab then w.ActiveTab.Frame.Visible=false end
 w.ActiveTab=self; self.Frame.Visible=true
 w.Heading.Text=self.Name; w.Description.Text=self.Description
 w.Search.Text=""; w:_filter(); w:SetAccent(w.Accent)
end
function Tab:Section(title,column)
 assert(column==nil or column==1 or column==2,"Column must be 1 or 2")
 local s=setmetatable({Window=self.Window,Rows={},Title=title,Tab=self},Section)
 s.Frame=frame(self.Columns[column or 1],{Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=T.Card})
 round(s.Frame,7); outline(s.Frame)
 make("UIPadding",s.Frame,{PaddingTop=UDim.new(0,14),PaddingBottom=UDim.new(0,14),PaddingLeft=UDim.new(0,14),PaddingRight=UDim.new(0,14)})
 vertical(s.Frame,10)
 text(s.Frame,title,{Font=Enum.Font.GothamMedium,TextSize=13,Size=UDim2.new(1,0,0,23),LayoutOrder=-2})
 frame(s.Frame,{Size=UDim2.new(1,0,0,1),BackgroundColor3=T.Border,LayoutOrder=-1})
 table.insert(self.Sections,s); return s
end
function Section:_row(name,height)
 local r=frame(self.Frame,{Size=UDim2.new(1,0,0,height or 32),BackgroundTransparency=1,LayoutOrder=#self.Rows+1})
 table.insert(self.Rows,{Frame=r,Name=name}); return r
end
function Section:Label(message)
 local r=self:_row(message,44)
 return text(r,message,{Size=UDim2.fromScale(1,1),TextColor3=T.Muted,TextSize=12,TextWrapped=true,TextTruncate=Enum.TextTruncate.None})
end
function Section:_control(kind,o,initial,validate,render)
 local w=self.Window
 assert(type(o.Id)=="string" and o.Id~="","A unique Id is required")
 assert(not w.Controls[o.Id],"Duplicate Id: "..o.Id)
 local c={Kind=kind,Value=initial,Validate=validate,OnChanged=o.OnChanged,OnPressed=o.OnPressed}
 function c:Get() return self.Value end
 function c:Set(v,silent)
  local ok,value=validate(v)
  if not ok then return false,value end
  local changed=self.Value~=value
  self.Value=value; render(value)
  if not silent and changed then w:_call(self.OnChanged,value) end
  return true
 end
 w.Controls[o.Id]=c
 local ok,err=c:Set(initial,true); assert(ok,err)
 return c
end
function Section:Toggle(o)
 local w=self.Window; local r=self:_row(o.Name or o.Id,30)
 local b=button(r,o.Name or o.Id,{BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,Size=UDim2.new(1,-52,1,0)})
 local switch=button(r,"",{Position=UDim2.new(1,-34,0.5,-9),Size=UDim2.fromOffset(34,18)})
 round(switch,9)
 local dot=frame(switch,{Size=UDim2.fromOffset(12,12),Position=UDim2.fromOffset(3,3),BackgroundColor3=T.Muted}); round(dot,6)
 local state=false
 local function paint(v)
  state=v; switch.BackgroundColor3=v and w.Accent or T.Field
  dot.BackgroundColor3=v and T.Bg or T.Muted
  dot.Position=UDim2.fromOffset(v and 19 or 3,3)
 end
 local c=self:_control("Toggle",o,o.Default==true,function(v) return type(v)=="boolean",v end,paint)
 table.insert(w.Painters,function() paint(state) end)
 w:_connect(b.Activated,function() c:Set(not c.Value) end)
 w:_connect(switch.Activated,function() c:Set(not c.Value) end)
 c.Frame=r; c.LabelButton=b; c.Section=self
 return c
end
function Section:Slider(o)
 local min,max,step=o.Min or 0,o.Max or 100,o.Step or 1
 assert(max>min and step>0,"Slider requires Max > Min and Step > 0")
 local w=self.Window; local r=self:_row(o.Name or o.Id,50)
 text(r,o.Name or o.Id,{Size=UDim2.new(1,-65,0,22)})
 local value=text(r,"",{Position=UDim2.new(1,-65,0,0),Size=UDim2.fromOffset(65,22),TextXAlignment=Enum.TextXAlignment.Right,TextColor3=w.Accent,TextSize=12})
 local hit=button(r,"",{Position=UDim2.fromOffset(0,26),Size=UDim2.new(1,0,0,24),BackgroundTransparency=1})
 local track=frame(hit,{Position=UDim2.new(0,0,0.5,-2),Size=UDim2.new(1,0,0,4),BackgroundColor3=T.Field}); round(track,2)
 local fill=frame(track,{Size=UDim2.fromScale(0,1),BackgroundColor3=w.Accent}); round(fill,2)
 local knob=frame(track,{AnchorPoint=Vector2.new(0.5,0.5),Size=UDim2.fromOffset(10,10),BackgroundColor3=T.Text}); round(knob,5)
 local c=self:_control("Slider",o,o.Default or min,function(v)
  if type(v)~="number" or v~=v or math.abs(v)==math.huge then return false,"Expected finite number" end
  return true,math.clamp(min+math.floor((v-min)/step+0.5)*step,min,max)
 end,function(v)
  local p=(v-min)/(max-min); value.Text=string.format("%.4g%s",v,o.Suffix or "")
  fill.Size=UDim2.fromScale(p,1); knob.Position=UDim2.fromScale(p,0.5)
 end)
 table.insert(w.Painters,function() fill.BackgroundColor3=w.Accent; value.TextColor3=w.Accent end)
 w:_connect(hit.InputBegan,function(i)
  if i.UserInputType~=Enum.UserInputType.MouseButton1 and i.UserInputType~=Enum.UserInputType.Touch then return end
  local function update(pos)
   local pct=math.clamp((pos.X-track.AbsolutePosition.X)/math.max(1,track.AbsoluteSize.X),0,1)
   c:Set(min+(max-min)*pct)
   -- Keep visual position continuous even when the stored value uses a step.
   fill.Size=UDim2.fromScale(pct,1)
   knob.Position=UDim2.fromScale(pct,0.5)
  end
  w.DragControl={Input=i,Update=update}; update(i.Position)
 end)
 return c
end
function Section:Dropdown(o)
 local values=table.clone(o.Values or {})
 for _,v in ipairs(values) do assert(type(v)=="string","Dropdown values must be strings") end
 local w=self.Window; local r=self:_row(o.Name or o.Id,58)
 text(r,o.Name or o.Id)
 local b=button(r,"",{Position=UDim2.fromOffset(0,25),TextXAlignment=Enum.TextXAlignment.Left})
 make("UIPadding",b,{PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,26)})
 b.TextTruncate=Enum.TextTruncate.AtEnd
 local arrow=frame(r,{Position=UDim2.new(1,-20,0,37),Size=UDim2.fromOffset(10,7),BackgroundTransparency=1})
 frame(arrow,{Position=UDim2.fromOffset(0,1),Size=UDim2.fromOffset(6,2),Rotation=45,BackgroundColor3=T.Muted})
 frame(arrow,{Position=UDim2.fromOffset(4,1),Size=UDim2.fromOffset(6,2),Rotation=-45,BackgroundColor3=T.Muted})
 local c=self:_control("Dropdown",o,o.Default or values[1] or "",function(v)
  if type(v)=="string" and (table.find(values,v) or (#values==0 and v=="")) then return true,v end
  return false,"Unknown dropdown option"
 end,function(v) b.Text=v=="" and "No options" or v end)
 w:_connect(b.Activated,function()
  local panel=w:_popup(b,math.max(200,b.AbsoluteSize.X),math.min(220,math.max(36,#values*30+12)))
  local list=scroll(panel,{Position=UDim2.fromOffset(6,6),Size=UDim2.new(1,-12,1,-12),ZIndex=102}); vertical(list,0)
  for _,v in ipairs(values) do
   local item=button(list,v,{Size=UDim2.new(1,-4,0,30),ZIndex=103,TextXAlignment=Enum.TextXAlignment.Left,BackgroundTransparency=v==c.Value and 0 or 1,TextColor3=v==c.Value and w.Accent or T.Text})
   make("UIPadding",item,{PaddingLeft=UDim.new(0,8)})
   item.Activated:Connect(function() c:Set(v); w:_closePopup() end)
  end
 end)
 function c:SetValues(list)
  for _,v in ipairs(list) do assert(type(v)=="string","Dropdown values must be strings") end
  w:_closePopup(); values=table.clone(list)
  if not table.find(values,self.Value) then self:Set(values[1] or "") end
 end
 return c
end
function Section:Input(o)
 local r=self:_row(o.Name or o.Id,o.Multiline and 104 or 58)
 text(r,o.Name or o.Id)
 local b=input(r,o.Placeholder or "Enter value…",{Position=UDim2.fromOffset(0,25),Size=UDim2.new(1,0,0,o.Multiline and 76 or 30),MultiLine=o.Multiline or false,TextWrapped=o.Multiline or false})
 local c=self:_control("Input",o,o.Default or "",function(v)
  if type(v)~="string" or #v>(o.MaxLength or 16384) then return false,"Invalid or oversized text" end
  return true,v
 end,function(v) b.Text=v end)
 self.Window:_connect(b.FocusLost,function() local ok=c:Set(b.Text); if not ok then b.Text=c.Value end end)
 return c
end
function Section:Button(o)
 local w=self.Window; local r=self:_row(o.Name,32)
 local b=button(r,o.Name)
 w:_connect(b.Activated,function() w:_call(o.OnClick) end)
 return b
end
function Section:Keybind(o)
 local w=self.Window; local r=self:_row(o.Name or o.Id,32)
 text(r,o.Name or o.Id,{Size=UDim2.new(1,-118,1,0)})
 local b=button(r,"",{Position=UDim2.new(1,-112,0,0),Size=UDim2.fromOffset(112,30),TextColor3=w.Accent,TextTruncate=Enum.TextTruncate.AtEnd})
 local function validate(v)
  if typeof(v)=="EnumItem" then v=v.Name end
  if v=="None" or v=="MouseButton1" or v=="MouseButton2" then return true,v end
  if type(v)~="string" then return false,"Invalid key" end
  local ok,k=pcall(function() return Enum.KeyCode[v] end)
  return ok and k~=nil and k~=Enum.KeyCode.Unknown,v
 end
 local c=self:_control("Keybind",o,o.Default or "None",validate,function(v) b.Text=v end)
 table.insert(w.Painters,function() b.TextColor3=w.Accent end)
 w:_connect(b.Activated,function() w:_capture(b,function(key) c:Set(key) end) end)
 return c
end
function Section:Color(o)
 local w=self.Window; local r=self:_row(o.Name or o.Id,32)
 text(r,o.Name or o.Id,{Size=UDim2.new(1,-108,1,0)})
 local b=button(r,"",{Position=UDim2.new(1,-100,0,0),Size=UDim2.fromOffset(100,30),TextSize=11})
 local swatch=frame(b,{Position=UDim2.fromOffset(7,8),Size=UDim2.fromOffset(14,14)}); round(swatch,3)
 local c=self:_control("Color",o,o.Default or w.Accent,function(v)
  if typeof(v)=="Color3" then return true,v end
  if type(v)=="string" and v:match("^#?%x%x%x%x%x%x$") then return true,Color3.fromHex(v:gsub("#","")) end
  return false,"Expected Color3 or six-digit HEX"
 end,function(v) swatch.BackgroundColor3=v; b.Text=o.Compact and "" or "     #"..v:ToHex():upper() end)
 w:_connect(b.Activated,function()
  local panel=w:_popup(b,240,224)
  text(panel,"Accent / color",{Position=UDim2.fromOffset(12,9),Size=UDim2.fromOffset(210,20),ZIndex=102})
  local h,s,v=c.Value:ToHSV()
  local sv=button(panel,"",{Position=UDim2.fromOffset(12,38),Size=UDim2.fromOffset(184,130),BackgroundColor3=Color3.fromHSV(h,1,1),ZIndex=102})
  local sat=frame(sv,{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(1,1,1),ZIndex=103})
  make("UIGradient",sat,{Transparency=NumberSequence.new(0,1)})
  local val=frame(sv,{Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),ZIndex=104})
  make("UIGradient",val,{Rotation=90,Transparency=NumberSequence.new(1,0)})
  local marker=frame(sv,{AnchorPoint=Vector2.new(0.5,0.5),Size=UDim2.fromOffset(7,7),BackgroundColor3=T.Text,ZIndex=105}); round(marker,4); outline(marker)
  local hue=button(panel,"",{Position=UDim2.fromOffset(208,38),Size=UDim2.fromOffset(18,130),BackgroundColor3=Color3.new(1,1,1),ZIndex=102})
  local keys={}; for i=0,6 do table.insert(keys,ColorSequenceKeypoint.new(i/6,Color3.fromHSV(i/6,1,1))) end
  make("UIGradient",hue,{Rotation=90,Color=ColorSequence.new(keys)})
  local hm=frame(hue,{AnchorPoint=Vector2.new(0,0.5),Size=UDim2.new(1,0,0,3),BackgroundColor3=T.Text,ZIndex=103})
  local hex=input(panel,"#RRGGBB",{Position=UDim2.fromOffset(12,180),Size=UDim2.fromOffset(214,30),ZIndex=102})
  local function paint()
   sv.BackgroundColor3=Color3.fromHSV(h,1,1); marker.Position=UDim2.fromScale(s,1-v); hm.Position=UDim2.fromScale(0,h)
   hex.Text="#"..c.Value:ToHex():upper()
  end
  local function bind(obj,isHue)
   obj.InputBegan:Connect(function(i)
    if i.UserInputType~=Enum.UserInputType.MouseButton1 and i.UserInputType~=Enum.UserInputType.Touch then return end
    local function update(pos)
     local x=math.clamp((pos.X-obj.AbsolutePosition.X)/obj.AbsoluteSize.X,0,1)
     local y=math.clamp((pos.Y-obj.AbsolutePosition.Y)/obj.AbsoluteSize.Y,0,1)
     if isHue then h=y else s=x; v=1-y end
     c:Set(Color3.fromHSV(h,s,v)); paint()
    end
    w.DragControl={Input=i,Update=update}; update(i.Position)
   end)
  end
  bind(sv,false); bind(hue,true)
  hex.FocusLost:Connect(function() local ok=c:Set(hex.Text); if ok then h,s,v=c.Value:ToHSV() end; paint() end)
  w.PopupCleanup=function() w.DragControl=nil end
  paint()
 end)
 c.Frame=r; c.Button=b; c.Swatch=swatch
 return c
end
function Window:ExportConfig()
 local values={}
 for id,c in pairs(self.Controls) do values[id]=c.Kind=="Color" and c.Value:ToHex() or c.Value end
 return Http:JSONEncode({Version=3,Values=values})
end
function Window:ImportConfig(json)
 if type(json)~="string" or #json>262144 then return false,"Config is too large or not text" end
 local ok,data=pcall(function() return Http:JSONDecode(json) end)
 if not ok or type(data)~="table" or data.Version~=3 or type(data.Values)~="table" then return false,"Expected a v3 config" end
 local validated={}
 for id,v in pairs(data.Values) do
  local c=self.Controls[id]
  if c then
   local valid,value=c.Validate(v)
   if not valid then return false,"Invalid value: "..id end
   validated[id]=value
  end
 end
 -- Validate first, then update all state, then notify callbacks.
 self:_closePopup()
 for id,v in pairs(validated) do self.Controls[id]:Set(v,true) end
 for id,v in pairs(validated) do self:_call(self.Controls[id].OnChanged,v) end
 return true
end
local function slotName(name) return type(name)=="string" and #name>0 and #name<=48 and name:match("^[%w_-]+$") end
function Window:SaveConfig(name)
 if not slotName(name) then return false,"Use 1–48 letters, digits, _ or -" end
 local json=self:ExportConfig()
 if self.Storage then
  local ok,err=pcall(self.Storage.Write,name,json); if not ok then return false,tostring(err) end
 else self.Slots[name]=json end
 return true
end
function Window:LoadConfig(name)
 if not slotName(name) then return false,"Invalid slot name" end
 local json
 if self.Storage then
  local ok,value=pcall(self.Storage.Read,name); if not ok then return false,tostring(value) end
  json=value
 else json=self.Slots[name] end
 if not json then return false,"Slot not found" end
 return self:ImportConfig(json)
end
function Window:Settings()
 local tab=self:Tab("Settings","")
 local s=tab:Section("Appearance",1)
 s:Color({Id="ui.accent",Name="Accent Color",Default=self.Accent,OnChanged=function(c) self:SetAccent(c) end})
 s:Keybind({Id="ui.key",Name="Menu Key",Default=self.MenuKey.Name,OnChanged=function(k)
  local ok,key=pcall(function()
   if k=="MouseButton1" or k=="MouseButton2" then return Enum.UserInputType[k] end
   return Enum.KeyCode[k]
  end)
  if ok and key and key~=Enum.KeyCode.Unknown then self.MenuKey=key; self.KeyHint.Text=k.." to toggle"
  else self.MenuKey=Enum.KeyCode.RightShift; self.KeyHint.Text="RightShift to toggle" end
 end})
 s:Label("Escape cancels key capture. Backspace clears a shortcut.")
 s:Button({Name="Unload interface",OnClick=function() self:Destroy() end})
 local cfg=tab:Section("Configurations",2)
 cfg:Label(self.Storage and "Using your configured storage adapter." or "Slots last until this window is unloaded. Export JSON to keep a copy.")
 local slot=cfg:Input({Id="ui.slot",Name="Slot name",Default="default",MaxLength=48})
 local function report(ok,err,success) self:Notify("Configurations",ok and success or tostring(err)) end
 cfg:Button({Name="Save slot",OnClick=function() local ok,e=self:SaveConfig(slot:Get()); report(ok,e,"Saved.") end})
 cfg:Button({Name="Load slot",OnClick=function() local ok,e=self:LoadConfig(slot:Get()); report(ok,e,"Loaded.") end})
 local transfer=tab:Section("Import / export",1)
 -- Transfer box deliberately is not a saved control (avoids recursive configs).
 local row=transfer:_row("JSON",112)
 local box=input(row,"Paste JSON here…",{Size=UDim2.fromScale(1,1),MultiLine=true,TextWrapped=true,TextYAlignment=Enum.TextYAlignment.Top})
 transfer:Button({Name="Export to text box",OnClick=function() box.Text=self:ExportConfig(); box:CaptureFocus() end})
 transfer:Button({Name="Import from text box",OnClick=function() local ok,e=self:ImportConfig(box.Text); report(ok,e,"Imported.") end})
 return tab
end
-- Legacy API used by ui-Perplexity.win2-/Example.lua.
Window.CreateTab=Window.Tab
Window.CreateSettingsTab=Window.Settings
Window.UpdateTheme=Window.SetAccent
Tab.CreateSection=Tab.Section
function Section:_legacyId(name)
 return "legacy/"..self.Tab.Name.."/"..self.Title.."/"..name
end
function Section:CreateCheckbox(name,default,callback)
 local section=self
 local c=self:Toggle({Id=self:_legacyId(name),Name=name,Default=default,OnChanged=callback})
 function c:CreateColorpicker(color,cb)
  local picker=section:Color({Id=section:_legacyId(name).."/color",Name=name.." Color",Default=color,OnChanged=cb,Compact=true})
  -- Move the color button into the checkbox row; remove its old layout row.
  picker.Button.Parent=c.Frame
  picker.Button.Size=UDim2.fromOffset(26,24)
  picker.Button.Position=UDim2.new(1,-72,0.5,-12)
  picker.Swatch.Position=UDim2.fromOffset(6,5)
  c.LabelButton.Size=UDim2.new(1,-82,1,0)
  c.LabelButton.TextTruncate=Enum.TextTruncate.AtEnd
  for i,row in ipairs(section.Rows) do
   if row.Frame==picker.Frame then table.remove(section.Rows,i); break end
  end
  picker.Frame:Destroy(); picker.Frame=c.Frame
  return picker
 end
 function c:CreateKeybind(key,cb)
  return section:CreateKeybind(name.." Key",key,cb)
 end
 return c
end
function Section:CreateSlider(name,min,max,default,callback)
 return self:Slider({Id=self:_legacyId(name),Name=name,Min=min,Max=max,Default=default,Step=1,OnChanged=callback})
end
function Section:CreateDropdown(name,values,default,callback)
 return self:Dropdown({Id=self:_legacyId(name),Name=name,Values=values,Default=default,OnChanged=callback})
end
function Section:CreateKeybind(name,default,callback)
 return self:Keybind({Id=self:_legacyId(name),Name=name,Default=default,OnChanged=function(key)
  local value=nil
  if key~="None" then
   if key=="MouseButton1" or key=="MouseButton2" then value=Enum.UserInputType[key]
   else value=Enum.KeyCode[key] end
  end
  self.Window:_call(callback,value)
 end})
end
function Section:CreateButton(name,callback)
 return self:Button({Name=name,OnClick=callback})
end
function Section:CreateInput(name,default,placeholder,callback,multiline)
 return self:Input({Id=self:_legacyId(name),Name=name,Default=default,Placeholder=placeholder,OnChanged=callback,Multiline=multiline})
end
return Library
