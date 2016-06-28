# xhtml嵌套lua代码
<!-- toc -->

## slt2概述

slt2（Simple Lua Template 2）是一个 Lua 模板引擎。

Simple Lua Template 的想法很简单。就像 jsp 可以在 HTML 中嵌入 Java 代码一样，或者像 PHP 的风格一样，slt 就是在 HTML 中嵌入 Lua 代码。

比如：
```
<label>
#{ if user ~= nil then }#
  Hello, #{= user.name }#!
#{ else }#
  Please login !
#{ end }#
</label>
```

具体请参照: https://github.com/henix/slt2

## slt编写规则

### xhtml标记里嵌套lua代码

我们规定使用`#{ }#`格式来包裹lua语句。

比如:
```
#{ for key,account in pairs(account_tab) do}#
<input type='radio' name='payAccount' value ='#{= account["id"] }#'>
#{ end }#
```

### 赋值

在xhtml中嵌套的lua语句只要符合lua语法即可，需要特殊注意的只有获取变量值。

比如：  
定义变量: `#{local name = "xiaohei"}#`  
根据lua语法不知道如何将 `name` 在label控件中显示，根据slt2规则，我们可以这么写:`<label>我的名字是#{= name}#</label>`

## 应用场景

ERT在调用replace接口时先调用slt中render方法将嵌套lua代码预编译得到最终正常报文然后渲染展现。

目前ERT已经实现预编译的接口有三个:`location:replace`,`window:showContent()`,`ctrl:setInnerHTML`

### 初始化

在没有slt时界面初始化基本使用`setInnerHTML`来实现数据的填充。

在实现了预编译功能后我们应该摈弃局部刷新方法，实现整个界面一次性渲染完成。

以展现账户列表为例比较这两种实现方式优缺点

__setInnerHTML__

_body内容_

```
<!--Title-->
<table class="table_title" border="0">
    <tr class="tr_title" >
        <td align="center" valign="middle">
            <label class="label_title">余额查询</label>
            <input type="button" class="button_back" name="back_but" onclick="back_fun_mb01('account_qry')"/>
            <input type="button" class="button_main" name="main_but" onclick="main_page_callback()"/>
        </td>
    </tr>
</table>

<!--账户列表-->
<div class="acc_div" name="div_acc" border="0"></div>
```
_脚本内容_
```
--账户列表
local channel_data = globalTable["channel_data"];
local acc_obj = json:objectFromJSON(channel_data);
local coll_lists = acc_obj["return"]["account"];

--[[
@doc: 根据获得的json数据拼接账户列表
@params:
coll_lists: 账户列表table
]]--
local function acc_list(coll_lists)
    local tr_channel = "";
    for key, coll_list in pairs(coll_lists) do
        --[[此时key为1,2,3,4,5,6,7,8,9]]--
        tr_channel =
              tr_channel ..
              [[<tr name="card_tr">
                    <td>
                        <div class="tr_div"  border="0">
                            <img src="local:balance_qry/images/logo.png" class="img_rytong"/>
                            <label class="label_alias">]]..coll_list["accAlias"]..[[</label><br/>
                            <label class="label_acc">]]..coll_list["accNo"]..[[</label>
                            <img src="local:balance_qry/images/card_pull_but.png" class="img_onclick"/><br/>
                            <label class="label_py">]]..coll_list["card_desc"]..[[</label>
                        </div>
                    </td>
                </tr>]];
    end;
    return tr_channel;
end;

--[[
@doc:初始化
@params:
无
]]--
local function initial()
    --拼接账户列表
    local acc_tr =  acc_list(coll_lists);
    local div_acc =  [[<div class="acc_div" name="div_acc" border="0">
                    <table class="acc_table" border="0">]].. acc_tr ..
                [[</table></div>]];

    --局部刷新
    local div_acc_ctrl = document:getElementsByName("div_acc");
    if div_acc_ctrl and #div_acc_ctrl > 0 then
        div_acc_ctrl[1]:setInnerHTML(div_acc);
    end;
end;

initial();
```

__预编译__

_body内容_

```
#{ local channel_data = globalTable["channel_data"];}#
#{ local acc_obj = json:objectFromJSON(channel_data);}#
#{ local coll_lists = acc_obj["return"]["account"];}#

<!--Title-->
<table class="table_title" border="0">
    <tr class="tr_title" >
        <td align="center" valign="middle">
            <label class="label_title">余额查询</label>
            <input type="button" class="button_back" name="back_but" onclick="back_fun_mb01('account_qry')"/>
            <input type="button" class="button_main" name="main_but" onclick="main_page_callback()"/>
        </td>
    </tr>
</table>

<!--账户列表-->
<div class="acc_div" name="div_acc" border="0">
    <table class="acc_table" border="0">
        #{for key, coll_list in pairs(coll_lists) do}#
        <tr name="card_tr">
              <td>
                  <div class="tr_div"  border="0">
                      <img src="local:balance_qry/images/logo.png" class="img_rytong"/>
                      <label class="label_alias">#{= coll_list["accAlias"] }#</label><br/>
                      <label class="label_acc">#{= coll_list["accNo"]}#</label>
                      <img src="local:balance_qry/images/card_pull_but.png" class="img_onclick"/><br/>
                      <label class="label_py">#{= coll_list["card_desc"]}#</label>
                  </div>
              </td>
          </tr>
          #{end }#
      </table>
</div>
```
无需初始化脚本。

__比较__

1. 局部刷新方式界面结构不清晰，在初始化需要拼接很多内容时，整个界面内容不容易查找。
2. 局部刷新方式会先展现body中已有静态内容，然后再刷新局部div内容，在手机配置不高的情况下从视觉上能捕捉到此过程。
3. 使用局部刷新方式时数据在脚本一开始转换为table，在后面的脚本中可以直接使用转换出的table。
但是用预编译方式时数据在预编译时转换为table，如果在脚本中也需要使用时要重新定义和转换，比局部刷新多了一次数据解析过程。
在后面章节中我们会介绍lua的封装方法，使用规定的封装方法可以解决此种限制。

综合上面几点，推荐使用预编译方式，要求在5.2及之后版本都使用预编译方式实现界面初始化。

### showContent

showContent和初始化实现语法一样。

### setInnerHTML

setInnerHTML和初始化实现语法一样。
