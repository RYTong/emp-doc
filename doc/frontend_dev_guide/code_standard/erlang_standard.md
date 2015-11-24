# Erlang 编码规范
<!-- toc -->

## 命名规范

### Module名

在我们的系统中，module名为全小写，如包含两个或以上的单词，用`_`间隔。如：`channel_parser`,`channel_controller`。

Module名称需要体现module功能。

对于应用中channel模块的命名，我们应该统一命名为app_channelID。

### 函数名

函数命名规范与module相同。名称太长时，可以使用简写，如：
`gen_channel_req（generate_channel_request）`，根据名称可以推断该方法的逻辑是产生一个与channel相关的request。
_注：不需要其返回结果的方法或者主要逻辑功能为某种`side effect` 的方法，可以使用动词 do_xx或者将动词置后，如`do_db_update，data_validate，role_authenticate`等等。_

*`side effect`是`function`中纯运算以外的逻辑，如发送消息，调用I/O，改变系统环境等等。*

### 变量名

Erlang中的变量名称需以大写字母开头，可以使用`My_variable`或者`MyVariable`，在我们的系统中，一致使用后者（也称驼峰命名法）。变量名称需要体现其意义，如`Pid`表示进程`ID`，`ChannelItem`为`channel`内容的一项等等。（请不要使用如`A`，`B`，`X`之类的变量名称）

### 常量名

在`erlang`中我们可以在头文件或者`module`开头定义常量。格式如下：
`-define(MAX_MAPTILE_WIDTH, 1024).`
常量名称需全部大写，用`_`分割。

## 代码样式

### 缩进

4个`space`作为缩进的单元。不可用TAB键做缩进。

### 长度控制

建议`module`内容不要超过`400`行，`function`内容为`15-20`行，单行不要超过`80`个字符。
当`module`内容超过长度时，可将其分割为几个更小的`module`，`funtion`同理。
当单行内容过长时，可以以运算符或标点为尾，另起一行，如：
```
ewp_util:render_xml(ewp_util:export_xml
        ({feed,
          [{entry,[{title,["test"]},         
          {description,["Test:<form action="test_form_post_2"></form>"]}
                  ]}]}))
```

### 空格

在编码中需要对空格的使用保持一致的风格。在目前系统中，我们应该使用
`{12, 23, 45}`
而不是：
`{12,23,45}`。

### 注释

我们要求注释言简意赅，尽量使用英语。
注释格式为：关于`module`的注释使用三个`%`开头，即`%%%`，无缩进。
关于`function`的注释使用两个`%`，即`%%`，无缩进。(函数注释的具体规则参考程序规则中注释Function章节)。
而关于`code`的注释使用一个`%`，缩进与代码保持一致。（尽量直接在行尾注释）。

## 程序规则

### 注释Function

我们需要为每一个`function`撰写注释，内容包括：

- 函数功能
- 参数格式及意义
- 返回结果的可能格式及意义
- 可能产生的side effect

格式为：
```
%%-----------------------------------------------------------------
%% Function: get_server_statistics/2
%% Purpose: Get various information from a process.
%% Args:   Option is normal|all.
%% Returns: A list of {Key, Value} 
%%     or {error, Reason} (if the process is dead)
%%-----------------------------------------------------------------
get_server_statistics(Option, Pid) when pid(Pid) ->
```
并且，我们应该在函数设计之初就撰写其所对应的`@spec`，目前最新版本的`erlang`已经支持在编译时对`function`的`specification`进行检查（目前我们还未使用）。`function`的`@spec`格式可以参考`《programing-eralng》`中的`Appendix A`。示例如下：
```
%% @doc Create a new ErlyWeb application in the directory AppDir.
%% This function creates the standard ErlyWeb directory structure as well as
%% a few basic files for a rudimantary application.
%%
%% @spec create_app(AppName::string(), AppDir::string()) -> ok | {error, Err}
create_app(AppName, AppDir) ->
```

### 公共提取

当你试图复制、粘贴一段代码时，请先思考能否提取出其中的公共逻辑，将其封装为粒度更细的`function`。这对于增加程序可读性、健壮性、可扩展性，降低维护成本，都有着重要的意义。

### 细化

编码时，让一个`function`只完成某一种逻辑功能，而不要试图用一个`function`去做所有的事情。
尽量把包含`side effect`的逻辑剥离出来，封装成另一个`function`。但同时，要保证`do/undo one thing in a same function`。例如，打开和关闭一个文件，创建和销毁一个`XML handle`。
我们需要
```
do_something_with(File) -> 
  	case file:open(File, read) of
    	{ok, Stream} ->
      		doit(Stream), 
      		file:close(Stream) % The correct solution
    	Error -> 
    		Error
  	end.
```
而不是：
```
do_something_with(File) -> 
  	case file:open(File, read) of
    	{ok, Stream} ->
      		doit(Stream)
    	Error -> 
    		Error
  	end.
doit(Stream) -> 
  	...., 
  	func234(...,Stream,...).
  	...
func234(..., Stream, ...) ->
  	...,
  	file:close(Stream) %% Don't do this
```

### 嵌套简化

不要使用深层嵌套的case、if、receive，这会大大降低程序的可读性。
对于
```
case checkprefix(FirstPrefix, String) of
    {ok, Tail} ->
        do_this(Tail);
    _ ->
        case checkprefix(SecondPrefix, String) of
            {ok, Tail} ->
                do_that(Tail);
            _ ->
                case checkprefix(ThirdPrefix, String) of
                    and so on...
```
你可以使用：
```
Prefixes = [{"prefix1", fun do_this/1},
            {"prefix2", fun do_that/1},
            {"prefix3", fun do_something/1}],
case checkprefixes(Prefixes) of
     {ok, {Fun,Tail}} ->
           Fun(Tail);
     {error, not_found} ->
          ...
end.

checkprefixes([], String) ->
      {error, not_found};
checkprefixes([{Pre,Fun}|T], String) ->
      case check_prefix({Pre,Fun}, String) of
           {ok, Tail} ->
                {ok, {Fun,Tail}};
            _ ->  % I'd be specific in what I'm matching here.
                check_prefixes(T, String)
      end.
```
或者：
```
Prefixes = [{"prefix1", fun do_this/1},
            {"prefix2", fun do_that/1},
            {"prefix3", fun do_something/1}],
    catch lists:foldl(fun({Prefix, Fun}, Tail) ->
        case checkprefix(Prefix, Tail) of
            {ok, NewTail} ->
                Fun(NewTail);
            _ ->
                throw(done)
        end
    end, String, Prefixes).
```
或者其他的方式。

### 标识消息返回

避免这样的代码出现：
```
loop(State) ->
  	receive
    	...
    	{Mod, Funcs, Args} -> % Don't do this
      		apply(Mod, Funcs, Args},
      		loop(State);
    		...
  	end.
```
我们可以给`message`加上标识：
```
loop(State) ->
  receive
    ...
    {execute, Mod, Funcs, Args} -> % Use a tagged message.
      apply(Mod, Funcs, Args},
      loop(State);
    {get_status_info, From, Option} ->
      From ! {status_info, get_status_info(Option, State)},
      loop(State);    
    ...
  end.
```
当返回结果有多种情况时同理。

### 代码并行

当你发现你的代码在等待一个可以并行的任务，并因此而耗费很多时间时，创建一个平行的进程去处理它。例如：
```
get_item_type(CollectionId, User) ->
    {ID, Type} = 
    	case CollectionId of
            undefined->
                {o(User,favorite_collection_id),collection};
            _->
                {CollectionId,channel}
        end,
    A = get(arg),
    spawn(?MODULE, call_app_send_sms, [ID,A]),
    %% don’t use call_app_send_sms(ID,A)
    {ID, Type}.
call_app_send_sms(ID,A) ->
    ...
    case binary_to_list(Name) of
        "基金" ->
            ewp_http_client:request(post, RequestX, [], []);
        "转账" ->
            ewp_http_client:request(post, RequestX, [], []);
		"手机支付" ->
            ewp_http_client:request(post, RequestX, [], []);
        _ ->  go_on
    end.
```

### 慎用进程字典和ETS表

对于进程字典，由于可以在一个进程的多处对其进行修改，导致其状态不确定。对于ETS，如果为`public`类型，则可以在多个进程中对其进行读写，那么它的状态同步需要通过编码来实现。因此，除非你非常清楚所有可能出现情况，否则请谨慎使用它们。
另外，使用时请尽量保证一处写、多处读的原则。

### import和export

请不要使用`import`。
对于`export`，请按照功能分组到处，并分别注释。例如：
```
%% Callbacks for ota behavior.
-export([get_params_for_download/1,
         get_params_for_update/1,
         download_check/1,
         publisher_from_user_id/1,
         get_and_set_file_content/2,
         do_db_update/1
        ]).

%% APIs for user.
-export([download/1,
         update/1,
         notify/1]).
```

### 分类撰写lib

编码时应避免模块之间的循环调用，减少用户功能模块间的调用。将经常使用的代码按照功能分类，放到lib库中。
在修改lib库中的方法或者某公共方法（如`behavior`）时，如果改变了接口规范（接口参数、格式、意义），应同时修改所有的相关调用，并email通知所有小组成员。

### 减少文件读写

编码或者调试接口时，避免在代码中加入`file:write_file(xxx.json,[Data])`. 这样的代码。
如果一定需要写文件操作，我们可以通过宏定义开关来打开或者关闭写文件操作，一种解决方案是：
```
-ifdef(ewp_debug_flag).
	-define(
		WRITE_FILE(File,Content),
	    file:write_file(File,[Content])
	    ).
-endif.
```




