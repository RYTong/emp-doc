%% @private
%% @doc 缓存用户信息。假设用户信息在数据库中存储，
%%      使用redis将数据缓存，从而降低数据库访问压力
%% ======================== 测试结果 ============================
%% 环境：Inter core i7-4702MQ 2.2GHz 4核 CPU
%%       2G内存
%%       100进程并发共请求10000次
%% 1. 内存使用：插入47317个用户数据，每个用户5条数据（1条用户信息，
%%              1条账户列表，3条账户信息），共236585条数据，使用约
%%              285M内存，每个用户约使用6k内存
%% 2. 写入性能：约3580 tps，请求redis消耗约23ms，每次执行7次写入操作
%% 3. 读取性能：约21800 tps，请求redis消耗约4ms，每次执行5次读取操作
%% ======================== 实现原理 ============================
%% 使用redis lua脚本功能实现user_obj的写入和读取操作，相关脚本位于
%% lua/redis_cache目录。使用ewp_redis_cache_api:eval/3、/4方法调用
%% 脚本，方法须指定脚本名称（lua文件前缀），主键（例中为客户号）和
%% 脚本参数列表。每个参数可以为数字、字符串、atom、{date, date()}、
%% {time, time()}和{datetime, {date(), time()}}。
%%
%% 写入时需要将Erlang数据格式转换成参数列表，参考encode_user_obj/2。
%% redis lua脚本可以返回数组及嵌套数组，对应Erlang中list和嵌套list，
%% 因此在读取时需将返回数据转换为业务中使用的Erlang数据格式，参考
%% decode_user_obj/2。
%% ======================== 初始化操作 ============================
%% 1. 启动redis server
%% 2. 在ewp.conf中配置ewp_redis_cache和lua_path：
%% {ewp_redis_cache, [
%%    {pools, [ %% 可配置多个连接池，数据会根据主键被分配到多个实例中
%%        {redis1, [ %%连接池名称
%%            {pool_size, 5}, %% 连接池大小
%%            {host, "127.0.0.1"}, %% redis服务主机
%%            {port, 6380} %% redis服务端口
%%        ]}
%%    ]}
%% ]}.
%% {redis_lua_path, "lua脚本存储根目录"}. %%可嵌套子目录
%% 3. 确保ewp_redis_sup服务启动(ewp_redis:start())
%% 4. 如想查看性能测试的单次请求消耗时间，确保cpu_usage服务
%%    启动(cpu_usage:start_link()) 
%% 5. 执行本demo方法
%% ======================== Redis存储结构 ============================
%% 主键                                 类型          说明
%% HXRC_USER_OBJ:客户号:USER_INFO       Redis Hashes  存储用户信息，对应#user_obj.fields
%% HXRC_USER_OBJ:客户号:ACCTS_LIST      Redis Sets    存储账户列表，ACCOUNT_NO集合
%% HXRC_USER_OBJ:客户号:ACCT_INFO:账户  Redis Hashes  存储每个账户信息，对应#acct_obj.fields
-module(user_obj_cache_demo).

-export([write_performance/3,
	     read_performance/3]).

-include("ewp.hrl").

-record(user_obj, {fields, accts}).
-record(acct_obj, {fields}).

%%====================================================================
%% export
%%====================================================================
consistency_test() ->
    {UserCode, AcctList} = gen_random(),
    UserObj = gen_user_obj(UserCode, AcctList),
    set_user_obj(UserObj),
    case is_equal(UserObj, get_user_obj(UserCode)) of
    	true ->
            error_logger:info_msg("pass consistency test~n");
        _ ->
            error_logger:info_msg("consistency test error~n")
    end.

write_performance(NProcess, NTimes, NLoop) ->
    TestFun = 
        fun(_) ->
        	{UserCode, AcctList} = gen_random(),
            UserObj = gen_user_obj(UserCode, AcctList),
            set_user_obj(UserObj)
        end,
    performance_test:main(NProcess, NTimes, TestFun, [], NLoop).

read_performance(NProcess, NTimes, NLoop) ->
    TestFun = 
        fun(_) ->
            get_user_obj(gen_id())
        end,
    performance_test:main(NProcess, NTimes, TestFun, [], NLoop).

%%====================================================================
%% internal
%%====================================================================
%% 判断两个Userobj是否相同
is_equal(#user_obj{fields = UserInfo, accts = Accts1},
	     #user_obj{fields = UserInfo, accts = Accts2}) ->
    Length = length(Accts2),
    case length(Accts1) of
        Length ->
            is_accts_equal(Accts1, Accts2);
        _ ->
            false
    end;
is_equal(_, _) ->
    false.

is_accts_equal([], _) ->
    true;
is_accts_equal([AcctObj|T], Accts) ->
    case lists:member(AcctObj, Accts) of 
    	true ->
    	    is_accts_equal(T, Accts);
    	_ ->
    	    false
    end.

%% 将UserObj写入Redis
set_user_obj(#user_obj{fields = UserInfo, accts = AcctsInfo}) ->
    {Key, Args} = encode_user_obj(UserInfo, AcctsInfo),
    cpu_usage:start(set_user_obj_eval),
    ewp_redis_cache_api:eval("set_user_obj", Key, Args),
    cpu_usage:stop(set_user_obj_eval).

%% 从Redis读取UserObj
get_user_obj(UserCode) ->
    Decoder = fun(Res) -> decode_user_obj(Res, UserCode) end,
    cpu_usage:start(get_user_obj_eval),
    {ok, Result} = ewp_redis_cache_api:eval("get_user_obj", UserCode, [], Decoder),
    cpu_usage:stop(get_user_obj_eval),
    Result.

%% 将Redis读取结果解码成userobj
decode_user_obj([<<"user_info">>, UserInfo, 
	             <<"acct_info_list">>, AcctsInfo], UserCode) ->
    #user_obj{fields = [{'USER_CODE', UserCode}|decode_user_info(UserInfo)],
              accts = decode_accts_info(AcctsInfo, UserCode)}.

decode_user_info(UserInfo) ->
    decode_key_value(UserInfo, []).

decode_key_value([], Acc) ->
    lists:reverse(Acc);
decode_key_value([Key, Value|T], Acc) ->
    decode_key_value(T, [{ewp_redis_util:decode(Key), 
    	                  ewp_redis_util:decode(Value)}|Acc]).

decode_accts_info(AcctsInfo, UserCode) ->
    decode_accts_info(AcctsInfo, [], UserCode).

decode_accts_info([], Acc, _UserCode) ->
    lists:reverse(Acc);
decode_accts_info([Acct, Info|T], Acc, UserCode) ->
    AcctNum = ewp_redis_util:decode(Acct),
    AcctInfo = [{'USER_CODE', UserCode}, {'ACCOUNT_NO', AcctNum}
    	        |decode_key_value(Info, [])],
    decode_accts_info(T, [#acct_obj{fields = AcctInfo}|Acc], UserCode).

%% 将用户信息和账户信息列表编码成脚本参数
encode_user_obj(UserInfo, AcctsInfo) ->
    {UserCode, Acc1} = encode_user_info(UserInfo),
    Acc2 = encode_accts(AcctsInfo, Acc1),
    {UserCode, lists:reverse(Acc2)}.

%% 将用户信息转成{客户号, 参数列表}
%% 列表第一个元素为数据个数N，后每两个元素分别为key和value
%% 共N对key-value
encode_user_info(UserInfo) ->
    %% 数据个数，排除'USER_CODE'数据
    %% 需要将个数转为二进制，避免ewp_redis_api对其进行编码，
    %% 使得脚本中无法正常获取整数
    DataNum = integer_to_binary(length(UserInfo) - 1),
    encode_user_info(UserInfo, [DataNum], undefined).

encode_user_info([], Acc, UserCode) ->
    {UserCode, Acc};
encode_user_info([{'USER_CODE', UserCode}|T], Acc, _) ->
    encode_user_info(T, Acc, UserCode);
encode_user_info([{Key, Value}|T], Acc, UserCode) ->
    %% Key Value倒序插入，最后倒置
    encode_user_info(T, [Value, Key|Acc], UserCode).

%% 将账户列表信息转成参数列表
%% 每个账户信息第一个参数为账户，第二个参数为数据个数N，
%% 后每两个元素分别为key和value，共N对key-value
encode_accts([], Acc) ->
    Acc;
encode_accts([#acct_obj{fields = Fields}|T], Acc) -> 
    DataNum = integer_to_binary(length(Fields) - 2),
    Acct = proplists:get_value('ACCOUNT_NO', Fields),
    Acc1 = do_encode_accts(Fields, [DataNum, Acct|Acc]),
    encode_accts(T, Acc1).

do_encode_accts([], Acc) ->
    Acc;
do_encode_accts([{'USER_CODE',_}|T], Acc) ->
    do_encode_accts(T, Acc);
do_encode_accts([{'ACCOUNT_NO',_}|T], Acc) ->
    do_encode_accts(T, Acc);
do_encode_accts([{Key, Value}|T], Acc) ->
    do_encode_accts(T, [Value, Key|Acc]).

integer_to_binary(Int) ->
    list_to_binary(integer_to_list(Int)).

%% 根据指定的客户号和账户列表生成user_obj
gen_user_obj(UserCode, AcctList) ->
    #user_obj{fields = gen_user(UserCode),
              accts = gen_accts(UserCode, AcctList)}.

%% 生成随机的客户号和账户列表
gen_random() ->
    random:seed(now()),
    {gen_id(), [gen_id(), gen_id(), gen_id()]}.

%% 生成随机16位id
gen_id() ->
    lists:flatten(io_lib:format("~16.10.0B",[random:uniform(9999999999999999)])).

gen_user(UserCode) ->
    [{'USER_CODE',UserCode},
       {'CLIENT_NO',"136089666"},
       {'BRANCH_CODE',"9000"},
       {'REG_CHANNEL',"3"},
       {'REG_TYPE',"1"},
       {'FEE_TYPE',"0"},
       {'CLIENT_TYPE',"2"},
       {'CERT_TYPE',"98"},
       {'CERT_NO',"110101199006015555"},
       {'MOBILE_NO',"13410008888"},
       {'NAME',[229,136,152,228,186,140]},
       {'ACCOUNT_TYPE',"2"},
       {'ACCOUNT_NO',"5239590000148231"},
       {'PASSWORD',"2e4d5e64f88eaf8fefa85203f7833cc07169db40"},
       {'SEX',"M"},
       {'VERIFY_TEXT',"123"},
       {'AUTH_TYPE',undefined},
       {'SESSION_ID',"91a055af476c09d427898408a4c31e1e"},
       {'SD_CSN',undefined},
       {'SD_CSN_TELLER',undefined},
       {'SD_STATE',undefined},
       {'TRANSFER_FLAG',"1"},
       {'SINGLE_TRANSFER',undefined},
       {'TOTAL_TRANSFER',undefined},
       {'JJK_PAY_FLAG',"1"},
       {'CREDIT_PAY_FLAG',"0"},
       {'SINGLE_PAY',undefined},
       {'TOTAL_PAY',undefined},
       {'FUND_ACCOUNT',undefined},
       {'FINANCIAL_ACCOUNT',undefined},
       {'METAL_ACCOUNT',undefined},
       {'DEPOSITORY_ACCOUNT',undefined},
       {'EXCHANGE_ACCOUNT',undefined},
       {'SD_ACTIVE_DATE',undefined},
       {'FAILED_COUNT',0},
       {'TODAY_FAILED',undefined},
       {'LOGIN_COUNT',2},
       {'LAST_FAILED',undefined},
       {'LAST_LOGIN',{datetime,{{2023,7,21},{16,12,6}}}},
       {'LOGIN_TIME',undefined},
       {'CLIENT_VERSION',"5.8.0"},
       {'CLIENT_OS',"01"},
       {'SERVER_IP',"127.0.0.1"},
       {'SERVER_PORT',"4402"},
       {'STATUS',"1"},
       {'TOKEN_TYPE',undefined},
       {'TOKEN_NO',undefined},
       {'TOKEN_STATUS',undefined},
       {'MANAGE_NAME',undefined},
       {'IDEN_APPLY_DATE',undefined},
       {'IDEN_VALID_DATE',undefined},
       {'IDEN_STATUS',undefined},
       {'VERIFY_FLAG',undefined},
       {'VERIFIOR',{datetime,{{2023,7,21},{15,58,7}}}},
       {'VERIFY_TIME',{datetime,{{2023,7,21},{16,12,6}}}},
       {'CREATE_TIME',undefined},
       {'UPDATE_TIME',undefined},
       {'REMARK_ONE',undefined},
       {'REMARK_TWO',undefined},
       {'REMARK_NUMBER',"0"},
       {'REMARK_NUMBTHR',undefined},
       {'REMARK_DATE',{datetime,{{2023,7,21},{15,58,7}}}},
       {'IN_SINGLE_TRANSFER_COUNTER',undefined},
       {'IN_TOTAL_TRANSFER_COUNTER',undefined},
       {'SINGLE_TRANSFER_COUNTER',undefined},
       {'TOTAL_TRANSFER_COUNTER',undefined},
       {'IN_SINGLE_TRANSFER_ONLINE',"0"},
       {'IN_TOTAL_TRANSFER_ONLINE',"0"},
       {'SINGLE_TRANSFER_ONLINE',"0"},
       {'TOTAL_TRANSFER_ONLINE',"0"}].

gen_accts(UserCode, AcctList) ->
    GenFun = fun(Acct) ->
    	Fields = 
           [{'USER_CODE',UserCode},
            {'ACCOUNT_NO',Acct},
            {'ACCOUNTS_ID',"16899730871608600"},
            {'CLIENT_NO',"136089666"},
            {'ACCOUNT_TYPE',"2"},
            {'PRODUCT_TYPE',"0010"},
            {'MAIN_SIGN_FLAG',"0"},
            {'ACCOUNT_ALIAS',[230,160,135,229,135,134,229,141,161]},
            {'OPEN_BRANCH',"9000"},
            {'CURRENCY',"CNY"},
            {'RELATE_ACCOUNT',undefined},
            {'DELETE_FLAG',"0"},
            {'CREATE_TIME',{datetime,{{2023,7,21},{15,58,7}}}},
            {'UPDATE_TIME',undefined},
            {'REMARK_ONE',undefined},
            {'REMARK_TWO',undefined}],
        #acct_obj{fields = Fields}
    end,
    [GenFun(Num) || Num <- AcctList].