# lua共通方法介绍
<!-- toc -->

## 前提

将关于http请求的共通方法放在一个lua文件中取名为http_fun.lua。
将公共变量放在一个lua文件中取名为global_variable.lua。

## 公共变量
在客户端中整个运行过程为一个状态机，所以将界面中数据的传输放入全局table进行赋值和获取。

在当前示例中我们在global_variable.lua中添加如下代码：

```
--[[
全局变量说明,为了避免全局变量不小心被替换赋值，将项目上用到的全局变量放在此处说明其含义。
--]]

globalTable = {}; --全局table

ewp_debug = false; --控制请求为channel/run还是直接读取json数据

page_ewp_debug = true; --控件为从app请求界面还是直接读取离线资源界面

loadingtag = 3; --加载界面tag数

```

## 请求界面

在前面的界面例子中我们发现很多位置都出现了`http:postAsyn(nil,"test_s/get_page","name=training/subacc_dyn.xhtml",qry_page_callback,nil);`,而且这个回调方法qry_page_callback的内容在很多界面基本都一样。所以我们将此界面的请求封装为共通方法。

这里简单说明一下离线存储功能，EMP产品提供了离线存储，那么界面就可以保存在客户端本地，调用界面的时候直接从客户端中读取文件即可，但是如果我们现在处于开发阶段，界面需要频繁修改，每次都让客户端同步我们本地的界面会有诸多麻烦，所以我们使用了一个page_ewp_debug的全局变量用于控制是从app中请求界面还是直接读取客户端本地资源界面。

修改http_fun.lua文件为：
```
http_fun = {};

--[[
    说明：通用请求获取静态界面回调方法
    参数：
    params：
    说明：客户端post请求回调方法传入参数。
    格式：table
    例子：{["responseCode"] = 200,["responseBody"] = "<?xml><content>..</content>"}
    返回：
    跳转入下个界面，并将此界面加入缓存。
]]--
function page_callback(params)
    if params["responseCode"] == 1599 then
        location:replace(params["responseBody"],replace_callback,nil);
    elseif params["responseCode"] == 200 then
        local page = params["responseBody"];
        history:add(page);
        location:replace(page,replace_callback,nil);
    else
        window:hide(loadingtag);
        window:alert("该离线资源还没有下载完成");
    end
end;

--[[
    说明：根据是否为开发模式获取不同界面资源
        如果为开发模式发送请求test_s/get_page获得ewp服务器上静态界面。
        如果为生产模式直接读取客户端本地离线资源界面。
    参数：
    ebank_file：
    说明：请求界面名称。
    格式：string
    例子：balance_qry/xhtml/balance_qry_mb01.xhtml
    fun_callback:
    说明：post请求回调方法。
    格式：function 名称。
    例子：page_callback
    fun_params:
    说明：请求回调方法时所需参数。
    格式：table
    例子：{trancode="mb01",channelId="balance_qry"}
]]--
function http_fun.invoke_page(ebank_file,fun_callback,fun_params)
    local page =nil;
    if page_ewp_debug then
        local path = "name="..utility:escapeURI("channels/"..ebank_file);
        ryt:post(nil, "test_s/get_page", path, fun_callback, fun_params, false)
    else
        local response = {};
        if file:isExist(ebank_file) then
            response["responseCode"] = 200;
            page = file:read(ebank_file, "text");
            response["responseBody"] = page;
        else
            --暂时定义如果没有读取到离线资源则返回code为404
            response["responseCode"] = 404
        end;
        fun_callback(response);
    end
end;
```

## 请求json数据
修改http_fun.lua文件为：
```
--[[
    说明：invoke_trancode中post请求回调方法。
        在此方法中封装错误信息处理方法。
        如果返回responseCode 为1599 则表示会话超时，
        此时返回responseBody为超时界面，后台直接replace即可。
        如果返回responseCode 为200 则表示报文正常返回，
        此时需要判断返回报文为json还是xml数据，如果为xml数据表示在处理过程中出现错误返回，
        将此xml界面直接replace即可弹出错误信息界面。
        在项目中业务流程数据从simulator或者网银app中取回时先进行错误码的判断，如果返回为错误信息，
        则将此业务错误信息throw出来即可。
        返回正常即走正常流程，在xhtml界面报文中只用对正确情况进行处理。
    参数：
    params:
    说明：客户端回调传回table列表。
    格式：table
    例子：{["responseCode"] = 1599,["responseBody"] = "<?xml><content>..</content>"}
    返回：
    如果为会话超时则进入会话超时界面。
    如果为错误信息则会弹出错误信息。
    如果为正常返回则调用正常流程回调方法，此时一般为跳转入下个界面。
]]--
local function all_callback(params)
    params.callbackParams["responseBody"] = params["responseBody"];
    params.callbackParams["responseCode"] = params["responseCode"];
    -- 会话超时界面
    if params["responseCode"] == 1599 then
        location:replace(params["responseBody"],replace_callback,nil);
    elseif params["responseCode"] == 200 then
        local ret_data = params["responseBody"];
        --返回为xml
        if get_format(ret_data) == "xml" then
            location:replace(ret_data,replace_callback,nil);
        elseif get_format(ret_data) == "json" then
            params.app_callback(params.callbackParams);
        else
            window:alert("返回数据格式不对，请重新请求!");
        end;
    else
        window:alert("网络请求失败，请重试！");
        window:hide(loadingtag);
        return;
    end;
end;

--[[
    说明：根据是否为开发模式请求不同数据来源
    如果为开发模式请求接口为test_s/get_page,请求资源为各个channelId文件夹下json文件夹中静态json数据。
    如果为生产模式请求接口为channel_s/run,请求数据资源为业务处理流程中返回json数据。

    参数：
    channelId:
    说明：此业务频道channelId。
    格式：string。
    例子："balance_qry"
    tranCode:
    说明：此业务流程唯一业务标识。
    格式：string。
    例子："MB2010"
    postParams:
    说明：此业务流程请求下个接口所需参数。
    格式：table。
    例子：{tranCode="MB2010",accNo= "62252430987612345"}
    busiCallback:
    说明：post请求的回调方法。
    格式：function 名称。
    例子：funCallback
    callbackParams:
    说明：回调方法所需其他参数。
    格式：table。
    例子：{trancode="mb02",channelId="balance_qry"}

    返回：
    一般回调函数实现为跳转入下个界面。

]]--
function http_fun.invoke_trancode(channelId, tranCode, postParams, busiCallback, callbackParams)
    --[[保存invoke_trancode()的五个参数到callbackParams，用以传值给all_callback()来进入页面]]--
    local params = {};

    params.channelId = channelId;
    params.tranCode = tranCode;
    params.postParams = postParams;
    params.busiCallback = busiCallback;
    params.callbackParams = callbackParams;

    if ewp_debug then
        -- get sample data for debug
        local path = "name="..utility:escapeURI("channels/"..channelId.."/json/"..tranCode..".json");
        params.app_callback = busiCallback;
        ryt:post(nil, "/test_s/get_page", path, all_callback, params, false);
    else
        -- ryt:post接口的params格式{header, url, data, callback, parameters, synchronous}
        local client_post = http_fun.to_post_body(postParams);
        params.app_callback = busiCallback;
        ryt:post(nil, "channel_s/run", client_post, all_callback, params, false);
    end;
end;
```
## 参数拼接
```
--[[
    说明：组装网络请求参数
    参数：
    params:
    说明：请求下个接口所需参数列表
    格式：table
    例子：{trancode="mb001",accno= "12314"}

    返回：
    根据table组装成post请求参数，如trancode=mb001&accno=12314
]]--
function http_fun.to_post_body(postParams)
    local post = "";
    local ret_post;
    if postParams then
        for key,value in pairs(postParams) do
            print(key);
            post = post .. key .. "=" ..utility:escapeURI(value) .. "&";
        end;
        ret_post = string.sub(post,1,string.len(post)-1);
    else
        ret_post = "";
    end;
    return ret_post;
end;
```

## 判断返回内容是否为json
```
--[[说明：判断传入数据的格式为json还是xml。
    正则表达式：^%s*%{ 表示以   {开始的字符串。
            ^<%?xml 表示以<?xml 开始的字符串
    参数：
    params_str:
    说明：需要验证字符串
    格式：string
    例子：{"return":{"error":"000000"}}

    返回：
        如果为json返回"json"。
        如果为xml返回"xml"。
        如果不为这两种则返回nil。
]]--
function get_format(paramsStr)
    if string.find(paramsStr,"^%s*%{") ~= nil then
        return "json";
    elseif string.find(paramsStr,"^<%?xml ") ~= nil then
        return "xml"
    else
        return nil;
    end;
end;
```