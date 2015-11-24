# 界面初始化

## 说明

脚本中非`function`中的代码为界面初始化时的默认执行代码。

## Examples

### 简述

在综合示例章节中，我们实现了账户详情界面的静态页面，本节中介绍如何实现该界面的动态初始化。

示例中用了两种方式动态初始化页面：
- 改变控件的属性值
- 局部刷新
- 使用slt预编译实现界面动态拼接数据

我们假定界面中需用到的动态数据来自于如下所示的json字符串:
``` json
{
    "Message": {
        "tranCode": "MB0103",
        "status": { "value": "0" },
        "myAccount": {
            "id": "4055122014011279",
            "alias": "我的工资卡",
            "currency":"01",
            "type": "01",
            "balance": "100000",
            "rate": "0.3850 %",
            "state":"0",
            "detail":[
                {
                  "sequenceNo": "100001",
                  "saveType": "001",
                  "period": "1",
                  "balance": "1000.00",
                  "rate": "3.12 %",
                  "beginDate": "20130709",
                  "endDate": "20140708"
                }
            ]
        }
    }
}
```
其中："myAccount"为账户信息总列表，"detail"为定期信息列表，除"detail"以外的字段中包括卡号和活期信息。

示例的完整代码链接为: [xhtml_init.xml](./../xhtmlCompost/images/xhtml_init.xml)

运行效果图:  

(截图一)
![](./../xhtmlCompost/images/xhtml_init1.jpg)
(截图二)
![](./../xhtmlCompost/images/xhtml_init2.jpg)

### 实现方法

首先我们需要将json格式的数据转换为lua能识别的table格式，并取出界面中需要用到的数值，这里不作多余的解释。下面我们详细介绍动态初始化界面的方法。

#### 改变控件属性

示例中用改变控件value属性的方式初始化卡号以及活期列表的信息。  
可以看到：`init_account_info()`函数调用`changeProperty()`函数，将卡号列表和活期信息列表中相应控件的value值修改为json中的数值，实现了前两个table中数据的动态初始化。

script代码片段:
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


--[[
@doc:初始化卡号和活期信息
@params:各个改变值
--]]
local function init_account_info(cardNo,currency,balance,rate,state)
    --币种名称
    local currency_c;
    --根据币种序号判断币种名称
    if currency == "01" then
        currency_c = "人民币"
    elseif currency == "00" then
        currency_c = "美元"
    else
        currency_c = "其他币种"
    end;

    --状态名称
    local state_c;
    --根据状态序号判断状态名称
    if state == "0" then
        state_c = "活动"
    else
        state_c = "禁止"
    end;

    --改变相应控件的value属性
    changeProperty("label_acc_num","value",cardNo);
    changeProperty("label_rmb","value",currency_c);
    changeProperty("label_balance","value",balance);
    changeProperty("label_intrest2","value",rate);
    changeProperty("label_state2","value",state_c);
end;
```

报文代码片段:
```html
<body name='body'>
    ...
    <!--卡号-->
    <table>
        <tr>
            <td class="td1" align="left">
                <label>当前一卡通:</label>
            </td>
            <td class="td2" align="right">
                <label name='label_acc_num'></label>
            </td>
        </tr>
    </table>

    <!--活期table-->
    <table>
        <tr>
            <td class="td1" align="left">
                <label class="label_detail">活期结算明细</label>
            </td>
            <td></td>
        </tr>
        <tr>
            <td class="td1" align="left">
                <label>币种:</label>
            </td>
            <td class="td2" align="right">
                <label name='label_rmb'></label>
            </td>
        </tr>  
        <tr>
            <td class="td1" align="left">
                <label>余额:</label>
            </td>
            <td class="td2" align="right">
                <label class="label_balance" name='label_balance'></label><label> 元</label>
            </td>
        </tr>
        <tr>
            <td class="td1" align="left">
                <label>利率:</label>
            </td>
            <td class="td2" align="right">
                <label name='label_intrest2'></label>
            </td>
        </tr>
        <tr>
            <td class="td1" align="left">
                <label>状态:</label>
            </td>
            <td class="td2" align="right">
                <label name='label_state2'></label>
            </td>
        </tr>
    </table>
    ...
</body>
```

#### 局部刷新

示例中用拼接报文局部刷新的方式实现了定期信息列表的动态初始化。

- `init_deposit_detail(tab_detail)`函数遍历定期信息table(tab_detail)，获得相关的数据，拼接界面中定期信息表格的报文。
- `initial()`函数获得完整的报文，并调用`setInnerHTML`接口局部刷新页面实现数据更新。  
注意: 调用`location:reload()`函数重新布局页面。

script代码片段:
```js
--[[
@doc:初始化定期列表
--]]
local function init_deposit_detail(tab_detail)
    local tr_detail =
    [[
        <tr>
            <td class="td1" align="left">
                <label class="label_detail">定期信息</label>
            </td>
            <td></td>
        </tr>
    ]];

    --遍历定期信息列表
    for key,detail in pairs(tab_detail) do
        local sequence = detail["sequenceNo"]; --定期序号
        local balance = detail["balance"]; --余额
        local period = detail["period"]; --存期
        local rate = detail["rate"]; --利率
        local beginDate = detail["beginDate"]; --起息日
        local endDate = detail["endDate"]; --到期日
        tr_detail =
        tr_detail ..
        [[
            <tr>
                <td class="td1" align="left">
                    <label>定期序号:</label>
                </td>
                <td class="td2" align="right">
                    <label name='label_sequence2'>]]..sequence..[[</label>
                </td>
            </tr>
            <tr>
                <td class="td1" align="left">
                    <label>余额:</label>
                </td>
                <td class="td2" align="right">
                    <label class="label_balance" name='label_balance'>]]..balance..[[</label><label> 元</label>
                </td>
            </tr>
            <tr>
                <td class="td1" align="left">
                    <label>存期:</label>
                </td>
                <td class="td2" align="right">
                    <label name='label_period2'>]]..period..[[</label><label> 年</label>
                </td>
            </tr>
            <tr>
                <td class="td1" align="left">
                    <label>利率:</label>
                </td>
                <td class="td2" align="right">
                    <label name='label_rate'>]]..rate..[[</label>
                </td>
            </tr>
            <tr>
                <td class="td1" align="left">
                    <label>起息日:</label>
                </td>
                <td class="td2" align="right">
                    <label name='label_start_date2'>]]..beginDate..[[</label>
                </td>
            </tr>
            <tr>
                <td class="td1" align="left">
                    <label>到期日:</label>
                </td>
                <td class="td2" align="right">
                    <label name='label_end_date2'>]]..endDate..[[</label>
                </td>
            </tr>
        ]];
    end;
    return tr_detail;
end;

--初始化函数
local function initial()
    ...
    --拼接定期信息列表
    local tr_info = init_deposit_detail(tab_detail);
    local table_info = [[<table name="table_fix">]] .. tr_info .. [[</table>]];
    --局部刷新
    local ctrl_fix_table = document:getElementsByName("table_fix");
    if ctrl_fix_table and #ctrl_fix_table>0 then
        ctrl_fix_table[1]:setInnerHTML(table_info);
    else
        window:alert("控件不存在！");
    end  

    location:reload();
end
```

报文代码片段：
```html
<body>
    ...
    <!--定期table-->
    <table name="table_fix"></table>
    ...
</body>
```

### slt预编译

TODO：
