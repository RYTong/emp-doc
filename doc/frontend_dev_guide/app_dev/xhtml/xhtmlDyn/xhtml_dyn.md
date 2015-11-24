# 动态界面
<!-- toc -->

## 说明

动态界面即非静态界面，表示界面数据从服务器或者其他界面获取，不同用户看到的数据不一样。

## 实现方式

常用的实现动态界面的方式有以下几种:

- **slt预编译**
直接使用slt预编译方法将lua代码嵌入xhtml中以实现界面展现不同数据。
- **局部刷新**  
将动态的数据拼接到界面的报文中，再调用lua接口setInnerHtml更新报文以达到界面动态展现。
- **改变控件属性**  
调用lua接口修改控件属性，比如value，动态改变控件显示值。
- **联动**  
根据不同的条件控制控件的显隐以达到界面动态展现。


## Examples

### 简述

在前一章节中，我们引入了账户总览界面的示例，该示例只实现了一个静态的界面，但在实际应用中，数据都是动态获取的，每个人看到的数据都不尽相同。本节我们将从四种实现方式入手，介绍如何实现动态的账户总览界面。

示例增加的主要功能包括:
1. 初始化界面时更新时间取当前最新时间，我的资产和我的负债显示为动态获取的数值；
2. 动态生成我的一卡通信息列表；
3. 在我的一卡通列表中，选择不同的账号显示相应的账号详细信息。

完整的代码链接: [xhtml_dyn.xml](./../xhtmlCompost/images/xhtml_dyn.xml)

示例中使用Json格式的数据作为动态数据传入，数据如下:  
``` json
{
  "Message": {
    "tranCode": "MB0102",
    "status": { "value": "0" },
    "asset": "98763.87",
    "debt": "0.00",
     "account":[
        {
            "cardNo":"3338480010038844666",
            "balance":"100,000.00",
            "flag":"0"
        },
        {
            "cardNo":"8888480011138855777",
            "balance":"20,000.00",
            "flag":"1"
        },
        {
            "cardNo":"6222534758583922020",
            "balance":"0.67",
            "flag":"0"
        }
    ]
  }
}
```
其中：
- "asset"对应界面中的我的资产；
- "debt"对应界面中的我的负债；
- "account"为账户信息列表，列表中有三项代表三个账号，每项中的"cardNo"对应界面中的一卡通，"balance"对应界面中的活期结算户，"flag"对应界面中的朝朝盈状态。

运行效果图：  
1. 初始界面  
![](./../xhtmlCompost/images/xhtml_dyn1.jpg)  
2. 点击刷新时间按钮后时间更新，选择不同的一卡通账号详细信息改变  
![](./../xhtmlCompost/images/xhtml_dyn2.jpg)

### 实现方法

#### 数据格式转换

在示例中，我们暂且将数据写为界面中的静态数据。要使用json字符串中的数据，首先需要将json转换成lua可用的table格式，客户端提供了`json:objectFromJson()`接口实现json到lua table的格式转换，之后我们便可以从table中取出资产、负债和账号信息列表等信息了。

数据格式转换的代码片段如下:
```js
--暂时将数据写为界面中静态数据
local json_data = [[
                    ...
                    这里省略了json字符串
                    ...
                  ]];

--使用客户端提供的json接口将json转换为lua中的table结构
local tab_data = json:objectFromJSON(json_data);
--账号信息列表
local tab_card = tab_data["Message"]["account"];
--资产
local asset = tab_data["Message"]["asset"];
--负债
local debt = tab_data["Message"]["debt"];
...
```

#### 改变控件属性

在示例中，更新时间和我的资产、我的负债的初始化都是通过改变控件value属性的方式实现的。

- `changeProperty(name,property,value)`函数实现的功能为将名称为name的控件的proerty属性值修改为value。
- `refresh()`函数调用`changeProperty()`函数将更新时间label控件的value值修改为当前时间。
- `change_asset(asset,debt)`函数调用`changeProperty()`函数将我的资产和负债的value值修改为动态获取到的数据。
- 初始化函数`initial()`调用了`refresh()`和`change_asset(asset,debt)`。

以下为脚本代码的片段:
```js
--[[
@doc:根据名称改变控件属性
@params:
name:控件名称
property:属性，比如："value"
value:修改值，需要将控件属性修改的值
@attention:如果界面中有多个此名称控件则这些控件都会被修改。
]]--
function changeProperty(name,property,value)
    local ctrl = document:getElementsByName(name);
    if ctrl and #ctrl > 0 then
        for key,ctrl_atom in pairs(ctrl) do
            ctrl_atom:setPropertyByName(property,value);
        end;
    else
        window:alert(name .. "控件不存在！");
    end;
end;

--刷新时间
function refresh()
    --获取当前时间
    local now = os.date("%H:%M:%S");
    local label_now = "更新时间:" .. now;
    --改变label_date控件值为当前时间
    changeProperty("label_date","value",label_now);
end;

--实现资产和负债数值动态
function change_asset(asset,debt)
    --改变资产和负债为json中的数值
    changeProperty("label_money","value",asset);
    changeProperty("label_bs","value",debt);
end;

...

--初始化函数
function initial()
    refresh();
    change_asset(asset,debt);
    ...
end
```

#### 局部刷新

一卡通的账户信息列表是通过动态拼接报文再局部刷新页面实现的，其思路如下:
- `change_card(tab_card)`函数遍历账户信息列表table(tab_card)，获取table中的数据，逐步拼接列表报文的各部分。
- 拼接完成的账户列表包括所有账号的详细信息，通过下一步骤中的联动控制tr的显隐才能实现只显示被选账号的信息。
- 报文中将属于同一账号的详细信息的tr的name值都设为"tr+相应的cardNo值"，以便于标识同一组的信息。
- 初始化函数`initial()`获得拼接完成的报文，并调用setInnerHTML接口局部刷新页面。

脚本片段如下：
```js
--动态生成账户信息列表
function change_card(tab_card)
    local tr_card = "";

    --拼接账号选择select下拉框报文
    local select_ctrl = [[<select name="select_card">]];
    --pairs：lua为数据结构table提供的泛型循环方法
    for key , card in pairs(tab_card) do
        local cardNo = card["cardNo"];
        select_ctrl = select_ctrl .. [[<option value="]]..cardNo..[[" onclick="select_card(']]..cardNo..[[')">]]..cardNo..[[</option>]];
    end;
    select_ctrl = select_ctrl .. [[</select>]];


    --拼接账户信息列表报文
    tr_card = [[<tr>
                    <td align="left" class="td3">
                        <label name="label_flag">一卡通</label>
                    </td>
                    <td align="right" class="td4">]]
                    .. select_ctrl .. [[</td>
                </tr>
                <tr class="tr1">
                    <td class="td3">
                        <div class="div_line" border="0"></div>
                    </td>
                    <td class="td3">
                        <div class="div_line" border="0"></div>
                    </td>
                </tr>]];

    for key , card in pairs(tab_card) do
        --一卡通账号
        local cardNo = card["cardNo"];
        --活期结算户
        local balance = card["balance"];
        --朝朝盈状态
        local zzyFlag = card["flag"];
        --zzyFlag对应的文字
        local zzyStr;
        if zzyFlag == "0" then
            zzyStr = "未开通";
        else
            zzyStr = "已开通";
        end;
        --tr的name值
        local tr_name = "tr_" .. cardNo;
        tr_card = tr_card .. [[ <tr name="]]..tr_name..[[" onclick = "sub_account(']]..cardNo..[[')">
                                    <td align="left" class="td3">
                                        <label >活期结算户</label>
                                    </td>
                                    <td align="right" class="td4">
                                        <label name="label_current">]]..balance..[[</label>
                                    </td>
                                </tr>
                                <tr name="]]..tr_name..[[" class="tr1">
                                    <td class="td3">
                                        <div class="div_line" border="0"></div>
                                    </td>
                                    <td class="td3">
                                        <div class="div_line" border="0"></div>
                                    </td>
                                </tr>
                                <tr name="]]..tr_name..[[">
                                    <td align="left" class="td3" >
                                        <label class="label_zzy">朝朝盈:</label><label class="label_fund">超高收益 0秒赎回</label>
                                    </td>
                                    <td align="right" class="td4">
                                        <label name="label_current">]]..zzyStr..[[</label>
                                    </td>
                                </tr>
                            ]];
    end;

    return tr_card;
end;

--界面初始化
function initial()
    ...
    --拼接账户信息列表
    local tr_card = change_card(tab_card);
    local card_table = [[<table name="card_table">]] .. tr_card .. [[</table>]];
    --局部刷新
    local ctrl_card_table = document:getElementsByName("card_table");
    if ctrl_card_table and #ctrl_card_table > 0 then
        ctrl_card_table[1]:setInnerHTML(card_table);
    else
        window:alert("card_table控件不存在！");
    end;
    ...
end
```

#### 联动

在示例中，选择不同的卡号能够显示不同的账户详情信息，这种动态效果是通过联动实现的。

- `changeStyle(name,style,value)`函数实现的功能为将名称为name的style样式值修改为value。若界面中有多个此名称的控件则这些控件都会被修改。
- `select_card(selected_cardNo)`函数为select控件中option选项的onclick事件响应函数，实现了显示选中账号详细信息的功能。此函数的思路为先将所有账户信息的tr都隐藏("display"属性值设为"none")，再显示选中的账号信息的tr("displaty"属性值设为"block")。初始化时默认选中第一个账号。
- 注意: 当改变display样式布局发生变化时，要调用`location:reload()`函数重新布局。

脚本代码片段如下：
```js
--[[
@doc:根据名称改变控件样式
@params:
name:控件名称
style:样式名称，比如："display"
value:修改值，需要将控件样式修改的值
@attention:如果界面中有多个此名称控件则这些控件都会被修改。
]]--
function changeStyle(name,style,value)
    local ctrl = document:getElementsByName(name);
    if ctrl and #ctrl > 0 then
        for key,ctrl_atom in pairs(ctrl) do
            ctrl_atom:setStyleByName(style,value);
        end;
    else
        window:alert(name .. "控件不存在！");
    end;
end;

--显示选中账户的信息
function select_card(selected_cardNo)
    --先将所有账户信息的tr都隐藏
    for key , card in pairs(tab_card) do
        local cardNo =  card["cardNo"];
        local ctrl_name = "tr_" .. cardNo;
        changeStyle(ctrl_name,"display","none");
    end;

    --再显示选中的账号信息的tr
    local ctrl_name = "tr_" .. selected_cardNo;
    changeStyle(ctrl_name,"display","block");

    --重新布局
    location:reload();
end;

...

--界面初始化
function initial()
    ...
    --默认选中第一个账号
    select_card(tab_card[1]["cardNo"]);
    location:reload();
end
```

### 使用slt预编译

前面写了这么多的初始化脚本，特别上在lua脚本中拼接html代码，在后期维护和查找html错误时都很不方便，利用slt我们实现在html代码中嵌入lua脚本。

根据前面所写json数据，此界面中账户信息列表可以使用下面代码实现：

TODO: 
