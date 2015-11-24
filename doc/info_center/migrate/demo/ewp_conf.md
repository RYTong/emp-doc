<pre>
%% -*- mode: erlang -*-
%%
%% EWP application runtime parameters.

%% These code paths will be added when ewp is loaded.
{pa, []}.
{pz, []}.

%% Default mobile resolution for offline resources.
{mobile_resolution, [
    {iphone, {320, 480}},
    {android, {320, 480}},
    {wp, {320, 480}}
]}.

%% Set environment modes.
%% Values: development|production|test.
{environment, development}.

%% Set the default term style used by xml_eng.
%% default is legacy.
{xml2term_style, legacy}. % legacy | distinct

%% Convertor of procedure response.
%% default is none.
{res_convertor, none}. % none | xml2term | xml2json | {Module, Function} 

%% Set error code config file. Using absolute path or file name.
{include, "err_code.conf"}.

%% Set security code config file. Using absolute path or file name.
{include, "security.conf"}.

%% Mnesia and database node type.
{db_node_type, master}.

%% (Only Master support disc storage).
{mnesia, [{mnesia_dir, "./bin/mnesia"}]}.

%% Salve Config Sample
%% {db_node_type, slave}.
%% {master, 'ewp@localhost'}.
%% {mnesia_table_copy, [ota_phones, users]}. %% Optional

%% Session relative
%% {session_storage_type, shared_ets}.
%% {login_session_timeout, 300}.
{session_timeout, 600}.

%% session persistence
%%% do not persist session
%% {persistent_session, false}.
%%% persist session with generic_session_persistence
%% {persistent_session, {true, session|user, Mod}}.
%%% clear persistent session before 30 days.
%% {persistent_session, {true, session|user, Mod, 30}}. 
%%% persist session with user-defined procedure and storage
%% {persistent_session, {true, proxy, Mod}}.

%% Database config.
{databases, [
    {ewp_development, [
        {driver, mysql},
        {database, "ewp_development"},
        {host, "localhost"},
        {port, 3306},
        {password, "l1ghtp@l3"},
        {user, "lpdba"},
        {poolsize, 4},
        {default_pool, true}
    ]},
    {test, [
        {driver, mysql},
        {database, "test"},
        {host, "localhost"},
        {port, 3306},
        {password, "l1ghtp@l3"},
        {user, "lpdba"},
        {poolsize, 2}
    ]}
]}.

%% We load apps in apps' list when starting ewp. And the first one
%% is the default app for requests from outside if there is no queryvar
%% 'app' specified in the request url.
%% App could be in format of both 'appname' and {'appname', AppDir},
%% and the later one is recommended.
{apps, []}. %% ebank | {ebank, "path/to/ebank"}

%% Set the threshold of rest memory, below which ewp
%% will refuse all requsts. Interval in {bool, Interval, Bytes, MaxEtsItems}
%% represents the check interval(seconds), and bytes is the memory threshold,
%% both in format of integer().
{mem_threshold, {false, 30, 1234, 100000}}.

%% Configurations for xmpp.
%% Only 'pubsub' configuration is supported now.
%%{xmpp, 
%%    [{pubsub, 
%%        [{server, "192.168.64.105"}, %% configuration for xmpp server
%%         {port, 5223}, %% configuration for xmpp c2s port
%%         {pubsub_service, "pubsub.ermp"}, %% configuration for pubsub service's name
%%         {root_node, "ebank_root"}, %% configuration for root node of public nodes
%%         {optional_private_nodes, %% configuration for optional private nodes
%%             [{"test_node1", "name1"}, 
%%          {"test_node2", "name2"}]}
%%        ]}
%%    ]}.

%% Whether clean session.
{session_cleanup, true}.

%% Gettext language.
{language, chinese}.

%%----------------------------------------------------------------------
%% EWP internal URI Mapping
%%----------------------------------------------------------------------
{controllers,[{"channel", channel, [{verify, true}, {decrypt, false}]},
              {"collection", channel, [{verify, true}, {decrypt, false}]},
              {{"collection","list"},{channel,list},[{verify, true}, {decrypt, false}]},
              {"atompub", {channel, run}, [{verify, true}, {decrypt, false}]},
              {"atompub_s", {channel, run}, [{verify, true}, {decrypt, true}]},
              {"app", channel, [{verify, true}, {decrypt, false}]},
              {"app_s", channel, [{verify, true}, {decrypt, true}]},
              {"phone", user, [{verify, true}, {decrypt, false}]},
              {"phone_s", user, [{verify, true}, {decrypt, true}]},
              {"user", user, [{verify, true}, {decrypt, false}]},
              {{"user","stats_online"},{user,stats_online},[{verify, false}, {decrypt, false}]},
              {{"user","make_cert"},{user,make_cert},[{verify, false}, {decrypt, false}]},
              {{"user","hello"},{user,hello},[{verify, false}, {decrypt, false}]},
              {{"user","exchange"},{user,exchange},[{verify, false}, {decrypt, false}]},
              {{"user","handshake"},{user,handshake},[{verify, false}, {decrypt, false}]},
              {{"user","appverify"},{user,appverify},[{verify, true}, {decrypt, true}]},
              {{"user","main_page"},{user,main_page},[{https,true}]},
              {"user_s", user, [{verify, true}, {decrypt, true}]},
              {"test_s", test, [{verify, true}, {decrypt, true}]},
              {{"ota", "insert"}, {ota, insert}, [{verify, false}, {decrypt, false}]},
              {{"ota", "update"}, {ota, update}, [{verify, false}, {decrypt, false}]},
              {{"ota", "delete"}, {ota, delete}, [{verify, false}, {decrypt, false}]},
              {{"ota", "select"}, {ota, select}, [{verify, false}, {decrypt, false}]},
              {{"ota", "import"}, {ota, import}, [{verify, false}, {decrypt, false}]},
              {{"ota", "export"}, {ota, export}, [{verify, false}, {decrypt, false}]},
              {{"ota", "resource_update"}, {ota, resource_update}, [{verify, true}, {decrypt, true}]},
              {{"ota", "resource_hash"}, {ota, resource_hash}, [{verify, true}, {decrypt, true}]},
              {"map", map, [{verify, true}, {decrypt, true}, {encrypt, true}]}]}.

%%----------------------------------------------------------------------
%% List of servers to be started.
%% XXX put the db_server at the end.
%%----------------------------------------------------------------------
{server,[{ewp_syslog_server,false},
         {ewp_offline_server, false},
         {cpu_usage, false},
         {temp_file_cleaner,false},
         {sec_connection, true},
         {cron_service, true},
         {template_monitor, true},
         {ewp_websocket, true}
]}.

%%----------------------------------------------------------------------
%% Rearrange event handlers for specified event manager as below.
%%{event, [{EVENT_MANAGER, [{add, EVENT_HANDLER, Flag},
%%                          {delete, EVENT_HANDLER, Flag},
%%                          {swap, {HANDLER_DELETE, HANDLER_ADD}, Flag}
%%                         ]}
%%        ]}
%%----------------------------------------------------------------------
{event, [
    {error_logger, [{swap, {yaws_log_file_h, date_log_file_h}, false}]}
]}.

{ewp_stat_logger, [[{app, ebank},
                    {dir, "@127.0.0.1:8099"},
                    {action, "channel"},
                    {cache_size, 0},
                    {wrap_size, 10000000000},
                    {rules, [{{ewc, channel_controller, run},[]}]}],
                    [{app, ebank},
                     {dir, "@127.0.0.1:8099"},
                     {action, "ota_install"},
                     {cache_size, 0},
                     {wrap_size, 10000000000},
                     {rules, [{{ewc, user_controller, hello}, [{conditions, [{"is_first", "0"}]}]}]}],
                    [{app, ebank},
                     {dir, "@127.0.0.1:8099"},
                     {action, "ota_download"},
                     {cache_size, 0},
                     {wrap_size, 10000000000},
                    {rules, [{{ota, ota_controller, download},[]}]}]
]}.

%% configurations for EMP offline
{offline, [
    {tcp_port, 4060},        %tcp port for download resources
    {max_connections, 5000} %maximum number of accepted connections 
]}.

</pre>