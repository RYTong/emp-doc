--[[
@doc: 请求余额查询界面
@params:
accNo: 账户号
accAlias: 卡名
card_desc: 账户名
]]--
function balance_req(acc_no,acc_alias,card_desc)
    globalTable["acc_no"] =  acc_no;
    globalTable["acc_alias"] =  acc_alias;
    globalTable["card_desc"] =  card_desc;
    string.sub(accNo);
    window:showContent("local:FullSLoading1.xml",loadingtag);
    local channelId = "balance_qry";
    invoke_trancode(channelId,"mb02", {id="balance_qry",tranCode= "mb02"}, callback_channel, {trancode="mb02",channelId=channelId,login_auth = "false"});
end;
