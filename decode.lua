-------------此文件主要用于用cybuf格式数据构造table---------------
require("test")

--------------基本类型值类型判断----------------
function class_identify(val)
  local des_val=val
  if(des_val=="true") then
    des_val=true
    return des_val
  end
  if(des_val=="false") then
    des_val=false
    return des_val
  end
  if(des_val=="nil") then
    des_val=nil
    return des_val
  end
  if(des_val==tostring(tonumber(des_val))) then
    des_val=tonumber(des_val)
    return des_val
  end
  return des_val.sub(des_val,2,#des_val-1)
end


--------------字符空格判断----------------
function judge_space_char(char)
  if(char==' ' or char=='\t' or char=='\n' or char=='\r') then
    return true
  end
  return false
end


-------------------decode主函数-------------------
function decode(cybuf_data,is_array)
  if(is_array==nil) then
    is_array=false
  end
  -------------数组型数据处理--------------
  if(is_array) then
    local data_begin=1
    local data_size=#cybuf_data
    local begin_char=cybuf_data.sub(cybuf_data,data_begin,data_begin)
    while(judge_space_char(begin_char)) do
      data_begin=data_begin+1
      begin_char=cybuf_data.sub(cybuf_data,data_begin,data_begin)
    end
    local end_char=cybuf_data.sub(cybuf_data,data_size,data_size)
    while(judge_space_char(end_char)) do
      data_size=data_size-1
      end_char=cybuf_data.sub(cybuf_data,data_size,data_size)
    end
    
    local cur_downmark=1------------数组当前下标
    local target_array={}
    local cur_val=''
    local is_in_string=false
    
    local i=data_begin+1------------迭代变量
    
    while(i<=data_size) do
      c=cybuf_data.sub(cybuf_data,i,i)
      i=i+1
      if(c=='"') then
        if(is_in_string==true) then
          cur_val=cur_val..'"'
          target_array[cur_downmark]=class_identify(cur_val)
          cur_val=''
          cur_downmark=cur_downmark+1
        else
          cur_val=cur_val..'"'
        end
        
        is_in_string=not is_in_string
        goto array_continue
      end
      if(is_in_string) then
        cur_val=cur_val..c
        goto array_continue
      end
      
      ----------------数组中的子table----------
      if(c=='{' and (not is_in_string)) then
        if(cur_val~='') then
          target_array[cur_downmark]=class_identify(cur_val)
          cur_downmark=cur_downmark+1
        end
        
        local son_table_data='{'
        local son_is_in_string=false
        local son_brace_count=1
        while(son_brace_count>=1 or son_is_in_string) do
          c=cybuf_data.sub(cybuf_data,i,i)
          i=i+1
          son_table_data=son_table_data..c
          if(c=='"') then
            son_is_in_string=not son_is_in_string
          end
          if(c=='{' and (not son_is_in_string)) then
            son_brace_count=son_brace_count+1
          end
          if(c=='}' and (not son_is_in_string)) then
            son_brace_count=son_brace_count-1
          end
          
        end
        son_table_data=son_table_data..''
      --  i=i+1
    --    print(son_table_data..'!!!')
        target_array[cur_downmark]=decode(son_table_data)
        cur_val=''
        cur_downmark=cur_downmark+1
        goto array_continue
      end
      
      -----------------数组中的子数组---------------
      if(c=='[' and (not is_in_string)) then
        if(cur_val~='') then
       --   print('val!!!!!!!!!!!!!!!!!')
          target_array[cur_downmark]=class_identify(cur_val)
          cur_val=''
          cur_downmark=cur_downmark+1
        end
        local son_table_data='['
        local son_is_in_string=false
        local son_brace_count=1
        while(son_brace_count>=1 or son_is_in_string) do
         -- i=i+1
          c=cybuf_data.sub(cybuf_data,i,i)
          i=i+1
          son_table_data=son_table_data..c
          if(c=='"') then
            son_is_in_string=not son_is_in_string
          end
          if(c=='[' and (not son_is_in_string)) then
            son_brace_count=son_brace_count+1
          end
          if(c==']' and (not son_is_in_string)) then
            son_brace_count=son_brace_count-1
          end
          
        end
        son_table_data=son_table_data..''
        i=i+1
     --   print(son_table_data..'!!!')
        target_array[cur_downmark]=decode(son_table_data,true)
        cur_val=''
        cur_downmark=cur_downmark+1
        goto array_continue
      end
      
      ---------------空白字符判定--------------
      if(judge_space_char(c)) then
        if(cur_val~='') then
          target_array[cur_downmark]=class_identify(cur_val)
          cur_val=''
          cur_downmark=cur_downmark+1
        end
        goto array_continue
      else
        cur_val=cur_val..c
      end
      
      if(i==data_size) then
        if(cur_val~='') then
          target_array[cur_downmark]=class_identify(cur_val)
          cur_val=''
        end
        goto array_continue
      end
      
      ::array_continue::
    end
    return target_array
  end
  
  ------计算数据起始点-----
  local data_begin=1
  local data_size=#cybuf_data
  local begin_char=cybuf_data.sub(cybuf_data,data_begin,data_begin)
  while(judge_space_char(begin_char)) do
    data_begin=data_begin+1
    begin_char=cybuf_data.sub(cybuf_data,data_begin,data_begin)
  end
  
  ------计算数据结束点-----
  if(cybuf_data.sub(cybuf_data,data_begin,data_begin)=='{') then
    data_begin=data_begin+1
    local end_char=cybuf_data.sub(cybuf_data,data_size,data_size)
    while(judge_space_char(end_char)) do
      data_size=data_size-1
      end_char=cybuf_data.sub(cybuf_data,data_size,data_size)
    end
    if(cybuf_data.sub(cybuf_data,data_size,data_size)=='}') then
      data_size=data_size-1
    end
  end
  
  local target_table={}
  local cur_table=target_table
  local cur_val=""
  local cur_key=""
  local cur_status=0 -----------cur_status为0表示当前读取的字符为key，否则为table
  local is_in_string=false -----------表示当前字符是否处于一组引号内
  local table_count=0 ----------表示当前table嵌套的层数
  
  local i=data_begin------------迭代变量
  
  while(i<=data_size) do
    local c=cybuf_data.sub(cybuf_data,i,i)
    if(i==data_size and (cur_key~='' and cur_key~='}')) then
      if(c~=' ') then
        cur_val=cur_val..c
      end
      target_table[cur_key]=class_identify(cur_val)
    end
    -----------------table型数据--------------------
    if(c=='{') then
      local son_data=''
      local son_ch=c
      local son_is_in_string=false
      local brace_count=1 -----------子table当前大括号的嵌套层数计数
      while(brace_count>0 or son_is_in_string) do
        i=i+1
        son_data=son_data..son_ch
        son_ch=cybuf_data.sub(cybuf_data,i,i)
        if(son_ch=='"') then
          son_is_in_string=not son_is_in_string
        end
        if(son_ch=='{' and (not son_is_in_string)) then
          brace_count=brace_count+1
        end
        if(son_ch=='}' and (not son_is_in_string)) then
          brace_count=brace_count-1
        end
      end
      
      son_data=son_data..'}'
      i=i+1
      target_table[cur_key]=decode(son_data)
      
      cur_status=0
      cur_key=''
      goto continue
    end
    
    -----------------数组table型数据--------------------
    if(c=='[') then
      local son_data='['
      local son_ch=c
      local son_is_in_string=false
      local brace_count=1 -----------子table当前大括号的嵌套层数计数
      local array_cur_status=0 ----------当此标记为0表示
      while(brace_count>0 or son_is_in_string) do
        i=i+1
        son_ch=cybuf_data.sub(cybuf_data,i,i)
        son_data=son_data..son_ch
        
        if(son_ch=='"') then
          son_is_in_string=not son_is_in_string
        end
        if(son_ch=='[' and (not son_is_in_string)) then
          brace_count=brace_count+1
        end
        if(son_ch==']' and (not son_is_in_string)) then
          brace_count=brace_count-1
        end
        
      end
    --  print(son_data..'&&&')
      target_table[cur_key]=decode(son_data,true)
      cur_status=0
      cur_key=''
      goto continue
    end
    
    if(c=='"') then
      if(is_in_string) then
        is_in_string=false
        cur_val=cur_val..'"'
        target_table[cur_key]=class_identify(cur_val)
        cur_key=""
        cur_val=""
        cur_status=0
      else
        is_in_string=true
        cur_val=cur_val..'"'
      end
      goto continue
    end
    
    if(is_in_string) then
      if(cur_status==0) then
        cur_key=cur_key..c
      else
        cur_val=cur_val..c
      end
      goto continue
    end
    
    if(not is_in_string) then
      if(c==':') then
        cur_status=1
        if(cybuf_data.sub(cybuf_data,i+1,i+1)==' ') then
          i=i+1
        end
        goto continue
      end
      if(judge_space_char(c)) then
        if(cur_key~='') then
          target_table[cur_key]=class_identify(cur_val)
          cur_key=""
          cur_val=""
          cur_status=0
        end
        goto continue
      end
      
      if(cur_status==0) then
        cur_key=cur_key..c
      else
        cur_val=cur_val..c
      end
    end
    
    ::continue::
    i=i+1
  end

  return target_table
end



-----------以下为测试数据------------

a1='{school: {name: "whu"  age: 120   is_good: true  opening_time: nil  major: {name:"cs"  is_good: true} }       Name:"hello"  Age:10   Live: true  }  '
a2='{Name:"hello"Age:10 Live:true friends:["csl""John Doe"1 2 3 true{name:"sss"age:12}[11 22 33]]major:{name:"cs"is_good:true students:["a1""a2""a3"]}}'
a3='{Name: "nil"  test: "true"  Age: 11 Live: true friends: ["csl" "John Doe" 1 2 3 true {name: "sss" age: 12} [11 22 33] ]  major: {name: "cs" is_good: true students: ["a1" "a2" "a3"]} }'
a4='[1 2 3 4 5]'
-----------以上为测试数据------------


print("------------------↓↓↓  分割线：decode文件自带测试内容  ↓↓↓-------------------")

aa=decode(a3)
print(encode_test(aa))

print("------------------↑↑↑  分割线：decode文件自带测试内容  ↑↑↑-------------------\n")
