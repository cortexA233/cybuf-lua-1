-----------------encode测试函数-----------------
function encode_test(map,tab_count)
  
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
        cybuf_str=cybuf_str..tostring(v)..'\t('..type(v)..')'
      else
        cybuf_str=cybuf_str..tostring(v)..'\t('..type(v)..')'
      end
      cybuf_str=cybuf_str..'\n'
      
    else
      cybuf_str=cybuf_str..tostring(i)..': '..'\t('..type(v)..')'..'\n'
      cybuf_str=cybuf_str..encode_test(v,tab_count)
    end
  end
  
  for i=1,tab_count-2 do
    cybuf_str=cybuf_str..'\t'
  end
  ---------------默认最外层不带大括号-----------
  if(tab_count>1) then
    cybuf_str=cybuf_str..'}\n'
  end
  --------------文件末尾无多余空行------------
  if(tab_count<=1) then
    return cybuf_str.sub(cybuf_str,1,#cybuf_str-1)
  end
  return cybuf_str
  
end