require("encode")
require("decode")

function load(filename)
  file=io.open(filename,'r')
  io.input(file)
  str=io.read('*a')
  io.close(file)
  object=decode(str)
  return object
end
---[[
function save(filename,object)
  file=io.open(filename,'w')
  str=encode(object)
  io.output(file)
  io.write(str)
  io.close(file)
end
--]]--
print("----------------分割线")

save("test.txt",a)
b={}
b=load("test.txt",b)
encode(b)

