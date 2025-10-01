function extended (child, parent)
  setmetatable(child,{__index = parent}) 
end

Person = {}
function Person:new(name)


  local public = {}
  public.name = name or "Vasya" 
  public.age = 18

  --этот метод можно переопределить
  function Person:getName()
    return "Person1 "..self.age
  end

  setmetatable(public,self)
  self.__index = self;
  return public
end

--создадим класс, унаследованный от Person
Woman = {}
extended(Woman, Person)  --не забываем про эту функцию

function Woman:new(name)
  local public = Person.new(self, name)
  public.age = 20

  function Woman:getName()
    local res = Person.getName(self)
    return res.."Woman "..self.age
  end

  setmetatable(public,self)
  self.__index = self
  return public
end




masha = Woman:new("Masha")
print(masha:getName())  --> Woman Вася

--вызываем метод родительского класса
print(Person.getName(masha)) --> Person Вася