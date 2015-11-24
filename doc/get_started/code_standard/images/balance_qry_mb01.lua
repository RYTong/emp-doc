--[[
@doc: 根据获得的json数据拼接账户列表
@params:
coll_lists: 账户列表table
]]--
local function acc_list(coll_lists)
    local tr_channel = "";
    for key, coll_list in pairs(coll_lists) do
        tr_channel =
        tr_channel ..
        [[
        <tr onclick="balance_req(']]..coll_list["acc_no"]..[[',
                                 ']]..coll_list["acc_alias"]..[[',
                                 ']]..coll_list["card_desc"]..[['>
            <td>
                <div class="tr_div"  border="0">
                    <img src="local:balance_qry/images/logo.png" class="img_rytong"/>
                    <label class="label_alias">]]..coll_list["acc_alias"]..[[</label><br/>
                    <label class="label_acc">]]..string.sub(coll_list["acc_no"],1,4)..[[ **** ]]..string.sub(coll_list["acc_no"],string.len(coll_list["acc_no"])-3,-1)..[[</label>
                    <img src="local:balance_qry/images/card_pull_but.png" class="img_onclick"/><br/>
                    <label class="label_py">]]..coll_list["card_desc"]..[[</label>
                </div>
            </td>
        </tr>]];
    end;
    return tr_channel;
end;

--[[
@doc:界面初始化
@params:账户列表
--]]
local function initial(acc_lists)
    --调用拼接方法生成tr
    local tr_lists = acc_list(acc_lists);
    local div_acc =
    [[
    <div class="acc_div" name="div_acc" border="0">
        <table class="acc_table" border="0">]].. tr_lists .. [[
        </table>
    </div>
    ]];
    --局部刷新
    local div_acc_ctrl = document:getElementsByName("div_acc");
    if div_acc_ctrl and #div_acc_ctrl > 0 then
        div_acc_ctrl[1]:setInnerHTML(div_acc);
    end;
end;

--从全局变量中获取json数据
local json_data = globalTable["mb01"];
local acc_obj = json:objectFromJSON(json_data);
local acc_lists = acc_obj["return"]["account"];

--调用初始化
initial(acc_lists);
