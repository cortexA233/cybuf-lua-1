------------------此文件用给定table构造CyBuf格式数据----------------
require("test")

---------------encode_zipped主函数---------------------
function encode_zipped(map,tab_count,optional_divider)
  
  if(tab_count==nil) then
    tab_count=0
  end
  if(optional_divider==nil) then
    optional_divider=''
  end
  local cybuf_str=''
  ---------------默认最外层不带大括号-----------
  
  tab_count=tab_count+1
  
  if(tab_count>1) then
    cybuf_str=cybuf_str.."{"
  end
  
  for i,v in pairs(map) do
    
    if(type(v)~="table") then
      cybuf_str=cybuf_str..tostring(i)..':'
      if(type(v)=="string") then
        cybuf_str=cybuf_str..'"'..tostring(v)..'"'
      else
        cybuf_str=cybuf_str..tostring(v)..' '
      end
      
    else
      cybuf_str=cybuf_str..tostring(i)..':'
      cybuf_str=cybuf_str..encode_zipped(v,tab_count)
    end
  end
  ---------------默认最外层不带大括号-----------
  if(tab_count>1) then
    cybuf_str=cybuf_str..'}'
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

print(encode_zipped(a))

print("------------------↑↑↑  分割线：encode文件自带测试内容  ↑↑↑-------------------\n")
