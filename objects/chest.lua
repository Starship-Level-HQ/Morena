Chest = {}

require("inventory.box.box")
require("inventory.box.boxGui")
local ItemModule = require("items.item")

function Chest:new(world, oData) 
  local chest = physics.makeBody(world, oData.x, oData.y, oData.h, oData.w, "static")

  chest.fixture:setCategory(cat.ITEM)
  chest.fixture:setMask(cat.VOID)
  chest.fixture:setUserData(chest)

  chest.img = love.graphics.newImage("res/sprites/chest.png")
  chest.zoom = 1.2

  chest.widthDivTwo = chest.img:getWidth()/2
  chest.heightDivTwo = chest.img:getHeight()/2

  chest.inventory = Box:new(6, 4)
  chest.class = "Chest"
  for i, id in ipairs(oData.loot) do
    chest.inventory:addItem(ItemModule.create_item(id))
  end

  chest.inventoryGui = BoxGui:new(chest.inventory)
  chest.inventoryIsOpen = false

  setmetatable(chest,self)
  self.__index = self
  return chest
end

function Chest:draw()
  local xx = self.body:getX()-self.widthDivTwo*self.zoom
  local yy = self.body:getY()-self.heightDivTwo*self.zoom
  love.graphics.draw(self.img, xx, yy, nil, self.zoom)    
end