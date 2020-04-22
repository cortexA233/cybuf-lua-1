------------------此文件用给定table构造CyBuf格式数据----------------


---------------encode主函数---------------------
function encode(map,tab_count)
  
  if(tab_count==nil) then
    tab_count=0
  end
  
  local cybuf_str=''
  ---------------默认最外层不带大括号-----------
  for i=1,tab_count-1 do
    cybuf_str=cybuf_str..'\t'
  end
  tab_count=tab_count+1
  
  if(tab_count>1) then
    cybuf_str=cybuf_str.."{\n"
  end
  
  for i,v in pairs(map) do
    
    for i=2,tab_count do
      cybuf_str=cybuf_str..'\t'
    end
    
    if(type(v)~="table") then
      cybuf_str=cybuf_str..tostring(i)..': '
      if(type(v)=="string") then
        cybuf_str=cybuf_str..'"'..tostring(v)..'"'
      else
        cybuf_str=cybuf_str..tostring(v)
      end
      cybuf_str=cybuf_str..'\n'
      
    else
      cybuf_str=cybuf_str..tostring(i)..': \n'
      cybuf_str=cybuf_str..encode(v,tab_count)
    end
  end
  
  for i=1,tab_count-2 do
    cybuf_str=cybuf_str..'\t'
  end
  ---------------默认最外层不带大括号，且文件末尾无多余空行-----------
  if(tab_count>1) then
    cybuf_str=cybuf_str..'}\n'
  end
  
  return cybuf_str
end

-----------以下为测试数据------------

a={}
a["cy_name"]="cy"
a["cy_age"]=21
a["cy_is_virginal"]=false
a["school"]={}
a["school"]["name"]="Wuhan University"
a["school"]["major"]={}
a["school"]["major"]["name"]="CS"
a["school"]["major"]["class"]="engineering"

-----------以上为测试数据------------

print("------------------↓↓↓  分割线：encode文件自带测试内容  ↓↓↓-------------------")

print(encode(a))

print("------------------↑↑↑  分割线：encode文件自带测试内容  ↑↑↑-------------------\n")
