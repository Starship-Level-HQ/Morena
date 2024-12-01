local Item = {}
Item.__index = Item

local available_items = {
  [1] = {
      name = "Зелье здоровья",
      type = "Зелье",
      effects = {здоровье = 50},
      cost = 10,
      target = "self",
      img = "inventory/assets/mem.png",
      desc = "This is a health potion."
  },
  [2] = {
      name = "Зелье скорости",
      type = "Зелье",
      effects = {скорость = 10},
      cost = 15,
      target = "self",
      img = "inventory/assets/thing2.png",
      desc = "This is a speed potion."
  }
}

function Item.new(item_id, name, item_type, effects, cost, target, img, desc)
    local self = setmetatable({}, Item)
    self.item_id = item_id
    self.name = name
    self.item_type = item_type
    self.effects = effects
    self.cost = cost
    self.target = target
    self.img = img
    self.desc = desc
    return self
end

function Item.create_item(item_id)
    local item_data = available_items[item_id]
    
    if item_data then
        return Item.new(
            item_id,
            item_data.name,
            item_data.type,
            item_data.effects,
            item_data.cost,
            item_data.target,
            love.graphics.newImage(item_data.img),
            item_data.desc
        )
    else
        error("Предмет с ID " .. item_id .. " не найден.")
    end
end

return Item
