local Item = {}
Item.__index = Item

local available_items = {
  [1] = {
      name = "Зелье здоровья",
      type = "Зелье",
      effects = {{"Здоровье", 20}},
      cost = 10,
      target = "Герой",
      img = "inventory/assets/mem.png",
      desc = "Сварено из моркови"
  },
  [2] = {
      name = "Зелье регенерации",
      type = "Зелье",
      effects = {{"Регенерация", 3, 20}},
      cost = 15,
      target = "Герой",
      img = "inventory/assets/thing2.png",
      desc = "Восстонавливает мнОго здоровья"
  }
}

function Item.new(name, type, effects, cost, target, img, desc)
    local self = setmetatable({}, Item)
    self.name = name
    self.type = type
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
