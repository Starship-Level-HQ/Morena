Chest = {}

local inventory = require("inventory.box.box")
local ItemModule = require("items.item")

function Chest:new(world, oData) 
  local chest = physics.makeBody(world, oData.x, oData.y, oData.h, oData.w, "static")

  chest.fixture:setCategory(cat.ITEM)
  chest.fixture:setMask(cat.VOID)
  chest.fixture:setUserData(chest)
  chest.img = love.graphics.newImage("res/sprites/chest.png")

  chest.widthDivTwo = chest.img:getWidth()/2
  chest.heightDivTwo = chest.img:getHeight()/2

  chest.inventory = inventory.new(6, 4)
  chest.class = "Chest"
  for i, id in ipairs(oData.loot) do
    chest.inventory:addItem(ItemModule.create_item(id))
  end

  chest.inventoryGui = require("inventory.box.boxGui")
  chest.inventoryGui:setInventory(chest.inventory, 50, 50)
  chest.inventoryIsOpen = false

  function Chest:draw()
    local xx = self.body:getX()-self.widthDivTwo
    local yy = self.body:getY()-self.heightDivTwo
    love.graphics.draw(self.img, xx, yy)
    if (self.inventoryIsOpen) then
      self.inventoryGui:draw()
    end
  end

  setmetatable(chest,self)
  self.__index = self

  return chest
end

