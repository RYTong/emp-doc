%% @private
%% @doc 用户轨迹数据存储示例。假设用户轨迹数据由信用卡和定期账户组成，
%%      由于涉及到多个接口，实时请求耗时较长，将会给用户带来不好的用户体验。
%%      可以将信用卡信息和账户信息以每日跑批形式从数据集市中获取，汇总存储
%%      到Redis中，从而降低读取延迟。
%%      由于对可用性要求较高，单纯使用redis缓存并不合适。使用redis cluster
%%      构建数据存储以提供较好的可用性，单个节点故障不会影响服务。
%% ======================== 实现原理 ============================
%% 使用redis lua脚本功能实现轨迹数据的写入和读取操作，相关脚本位于
%% lua/redis_data_store目录。使用ewp_redis_data_store_api:eval/3、/4
%% 方法调用脚本，方法须指定脚本名称（lua文件前缀），主键（例中为客
%% 户号）和脚本参数列表。
%%
%% 写入时需要将Erlang数据格式转换成参数列表，参考encode_batch_data/4。
%% redis lua脚本可以返回数组及嵌套数组，对应Erlang中list和嵌套list，
%% 因此在读取时需将返回数据转换为业务中使用的Erlang数据格式，参考
%% decode_user_track/1。
%% ======================== 初始化操作 ============================
%% 1. 启动redis server
%% 2. 在ewp.conf中配置ewp_redis_cache和lua_path：
%% {ewp_redis_data_store, [
%%     {pool_size, 5}, %% 连接池大小。EWP会自动与每个主节点建立指定数量的连接
%%     {port, 30001}   %% 有效节点端口。只需指定一个有效节点的端口，EWP会
%%                     %% 自动检测到所有主节点。
%% ]}.
%% {redis_lua_path, "lua脚本存储根目录"}. %%可嵌套子目录
%% 3. 确保ewp_redis_sup服务启动(ewp_redis:start())
%% 4. 如想查看性能测试的单次请求消耗时间，确保cpu_usage服务
%%    启动(cpu_usage:start_link()) 
%% 5. 执行本demo方法
%% ======================== Redis存储结构 ============================
%% 主键                          类型          说明
%% HXRS_CREDIT:客户号:LIST       Redis Sets    存储信用卡账户列表
%% HXRS_CREDIT:客户号:INFO:账户  Redis Hashes  存储每个信用卡账户信息
%% HXRS_DEPO:客户号:LIST         Redis Sets    存储定期账户列表，ACCOUNT_NO集合
%% HXRS_DEPO:客户号:INFO:账户    Redis Hashes  存储每个定期账户信息

-module(user_track_store_demo).

-export([batch_write/2,
	     read_performance/3]).

%%====================================================================
%% export
%%====================================================================
batch_write(NProcess, NTimes) ->
    TestFun = 
        fun(_) ->
        	{UserCode, CreditList, DepositList} = gen_random(),
            [set_credit_info(UserCode, CardNum) || CardNum <- CreditList],
            [set_deposit_info(UserCode, AcctNum) || AcctNum <- DepositList],
            ok
        end,
    performance_test:main(NProcess, NTimes, TestFun, [], 1).

read_performance(NProcess, NTimes, NLoop) ->
    TestFun = 
        fun(_) ->
            get_user_track(gen_id())
        end,
    performance_test:main(NProcess, NTimes, TestFun, [], NLoop).

%%====================================================================
%% internal
%%====================================================================

get_user_track(UserCode) ->
    Decoder = fun(Res) -> decode_user_track(Res) end,
    cpu_usage:start(get_user_track_eval),
    {ok, Result} = ewp_redis_data_store_api:eval("get_user_track_info", UserCode, [], Decoder),
    cpu_usage:stop(get_user_track_eval),
    Result.

set_credit_info(UserCode, CardNum) ->
    [_, _|Values] = gen_credit_info(UserCode, CardNum),
    Keys = ["alias", "balance", "avlimt", "cycl_nbr", "status", "payback_fee", 
            "low_fee", "endpay_day"],
    Args = encode_batch_data(Keys, Values, CardNum, <<"HXRS_CREDIT">>),
    cpu_usage:start(set_user_credit_info),
    ewp_redis_data_store_api:eval("set_user_track_info", UserCode, Args),
    cpu_usage:stop(set_user_credit_info).

set_deposit_info(UserCode, AcctNum) ->
    [_, _|Values] = gen_deposit_info(UserCode, AcctNum),
    Keys = ["status", "acct_type", "acctbal", "depo_term", "under_acct", 
            "interstr_date", "mature_date", "rate"],
    Args = encode_batch_data(Keys, Values, AcctNum, <<"HXRS_DEPO">>),
    cpu_usage:start(set_user_depo_info),
    ewp_redis_data_store_api:eval("set_user_track_info", UserCode, Args),
    cpu_usage:stop(set_user_depo_info).

%% 解码轨迹数据并转换成proplist
%% 脚本返回数据格式为[<<"credit_info">>, info_list(), <<"depo_info">>, info_list()]
%% info_list() = [AcctNum, info()]
%% info() = [Key, Value]
decode_user_track(TrackData) ->
    decode_user_track(TrackData, []).

decode_user_track([], Acc) ->
    Acc;
decode_user_track([InfoName, TrackInfo|T], Acc) ->
    decode_user_track(T, [{binary_to_list(InfoName), 
    	                   decode_acct_info_list(TrackInfo)}|Acc]).

decode_acct_info_list(AcctInfoList) ->
    decode_acct_info_list(AcctInfoList, []).

decode_acct_info_list([], Acc) ->
    Acc;
decode_acct_info_list([AcctNum, Info|T], Acc) ->
    decode_acct_info_list(T, [{ewp_redis_util:decode(AcctNum), 
    	                       decode_to_proplist(Info)}|Acc]).

decode_to_proplist(Info) ->
    decode_to_proplist(Info, []).

decode_to_proplist([], Acc) ->
    Acc;
decode_to_proplist([Key, Value|T], Acc) ->
    decode_to_proplist(T, [{ewp_redis_util:decode(Key),
    	                    ewp_redis_util:decode(Value)}|Acc]).

%% 编码生成脚本输入参数
%% ARGV[]格式为：逻辑表名，每条账户信息数据个数n, 
%%               卡号1，数据1键，数据1值，数据2键，数据2值 ... ...，数据n键，数据n值，
%%               卡号2，数据1键，数据1值，数据2键，数据2值 ... ...，数据n键，数据n值，
encode_batch_data(Keys, Values, CardNum, Tab) ->
    [Tab|encode_batch_data(Keys, Values, CardNum, [], length(Keys))].

encode_batch_data([], _, CardNum, Acc, DataNum) ->
    [integer_to_binary(DataNum), CardNum|Acc];
encode_batch_data([Key|Keys], [Val|Values], CardNum, Acc, DataNum) ->
    encode_batch_data(Keys, Values, CardNum, [Key, Val|Acc], DataNum).

integer_to_binary(Int) ->
    list_to_binary(integer_to_list(Int)).

%% 生成随机的客户号、2个信用卡号、5个定期账户
gen_random() ->
    random:seed(now()),
    {gen_id(), 
     [gen_id(), gen_id()], 
     [gen_id(), gen_id(), gen_id(), gen_id(), gen_id()]}.

%% 生成随机16位id
gen_id() ->
    lists:flatten(io_lib:format("~16.10.0B",[random:uniform(9999999999999999)])).

gen_credit_info(UserCode, CardNum) ->
    %% [客户号, 信用卡号, alias, balance, avlimt, cycl_nbr, status, payback_fee, low_fee, endpay_day]
    [UserCode, CardNum, [230,160,135,229,135,134,229,141,161], "5000", "2000", "03", 
     "O", "2000", "200", "2016/02/25"].

gen_deposit_info(UserCode, AcctNum) ->
    %% [客户号, 定期账号, status, acct_type, acctbal, depo_term, under_acct, interstr_date, mature_date, rate]
    [UserCode, AcctNum, "O", "1", "2000", "12", "5239590000148231", "2015/06/01", "2016/01/01", "3%"].