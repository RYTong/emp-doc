# EWP升级FAQ

<!-- toc -->

## 编译

* Q：编译时候出错，提示找不到一些宏或头文件，这些都是在EWP定义的，怎么会找不到？

    *A：EWP5.x版本重新整理了hrl文件，删除一些无用的宏或hrl文件。具体变动可查看参考手册的第八章“宏”*

## 启动

* Q：我在启动的时候遇到sec_connection:108 error: error/{badmatch,{error,enoent}}错误，怎么办？

    *A：这个错误是由于根据信道配置没有读取到文件导致的。在升级时遇到该问题，很有可能是因为没有正确配置。EWP5.x信道相关配置的格式做了修改，如果仍使用旧版本的配置文件，将无法读取证书。具体修改可查看参考手册的第三章的“安全信道配置”小节。*

* Q：启动的时候遇到ewp\_ets\_cleaner模块undef的错误，该怎么解决？日志如下：
<pre>
=SUPERVISOR REPORT==== 30-Jan-2015::13:47:17 ===
     Supervisor: {local,ewp_sup}
     Context:    start_error
     Reason:     {'EXIT',
                     {undef,
                         [{ewp_ets_cleaner,start_link,[],[]},
                          {supervisor,do_start_child,2,
                              [{file,"supervisor.erl"},{line,286}]},
                          {supervisor,start_children,3,
                              [{file,"supervisor.erl"},{line,272}]},
                          {supervisor,init_children,2,
                              [{file,"supervisor.erl"},{line,238}]},
                          {gen_server,init_it,6,
                              [{file,"gen_server.erl"},{line,297}]},
                          {proc_lib,init_p_do_apply,3,
                              [{file,"proc_lib.erl"},{line,227}]}]}}
     Offender:   [{pid,undefined},
                  {name,ewp_ets_cleaner},
                  {mfargs,{ewp_ets_cleaner,start_link,[]}},
                  {restart_type,permanent},
                  {shutdown,4000},
                  {child_type,worker}]
</pre>

    *A：模块undef错误通常是由于编译错误导致beam文件未找到。但此问题是升级导致的问题，EWP5.x整理了提供的服务，因此需要修改ewp.conf的server配置。具体修改可查看参考手册的第三章的“server配置”小节。*

* Q：我已经修改好Server配置并且可以在EWP的ebin目录找到对应的beam文件，为什么还会出现EWP的模块undef错误？

    *A：这种情况是因为在启动时EWP的ebin目录没有被加入到代码路径，你可以尝试更新一下[iewp脚本](./demo/iewp.html)*

* Q：启动时提示sconf为badrecord错误，为什么？日志如图 ![](./images/EWP_FAQ/EWP_FAQ_2_1.jpg)

    *A：这个问题是由于编译和运行使用了不同版本的Yaws导致的。需要更新系统中的Erlang和Yaws版本，具体步骤可查看参考手册的第二章“基础环境”。*

* Q：启动的时候提示missed callback错误，是EWP的回调方法规范修改了么？

    *A：是的。EWP5.x重新整理了大多数回调的输入输出格式，具体修改可查看参考手册的第五章“Callbacks 改动”。*

* Q：我在修改callback，但是回调的输入找不到Arg或P参数了，我不想每个交易都修改请求参数的获取方式，这工作量太庞大了，有更好的解决方法么？

    *A：可以通过Arg = ewp\_params:get\_args()和P = ewp\_params:get\_params()来获取两个参数。需要注意的是，通过ewp\_params:get\_args()获取到的Arg参数后，再调用P = ewp\_params:from\_yaws\_arg(Arg)是无法获取所有请求参数的。*

* Q：我在启动的时候出现了load\_menu错误，怎么解决？错误信息为ewp\_app\_manager:720 error: error happend during calling ewp\_app_util:load\_menu

    *A：为了解决这个问题，需要在.app文件中添加menu配置，修改方法查看参考手册的第三章的“菜单存储类型配置”小节。*

## 运行

* Q：我已经启动成功，但没看到app启动的日志，并且客户端无法正常访问，后台报错，怎么办？错误如下：
<pre>
error_code_service:556 apply function with args:
[error_code_service,render_404,
 [{{err_app,ebank,undefined},
   {err,app_upgrade,undefined,"APP-Upgrading","APP-Upgrading",
        {callback,{error_code_service,render_404}}}},
  "App ebank not running, please try later"]]
</pre>

    *A：这个错误是由于App没有启动导致的，需要修改ewp.conf的apps配置，具体修改可查看参考手册的第三章的“conf配置项”小节。*

* Q：握手已经过了，但是菜单哪去了？

    *A：EWP5.x版本修改了菜单加载的逻辑，所有菜单数据不在根据配置文件获取，而是在mnesia或数据库中读取，因此在首次启动服务后需要调用菜单加载函数来读取配置文件并加载。具体方法查看参考手册的第九章的“菜单加载”和第三章的“菜单配置”小节。*

* Q：我可以看到菜单了，但是顺序乱了，为什么？

    *A：修改菜单配置的collections->items->menu_order参数即可，菜单会按照由小到大的顺序显示。*

* Q：我在一次一密解密之前从session数据获取cipher\_state并判断不为undefined才会解密，为什么升级之后cipher_state一直是undefined？

    *A：在新版本中，cipher_state将无法在session中获取。解密可以直接调用 sec_cipher:decrypt_password(Password) 方法。*

* Q：我在交易的cs模板中使用#{cs var:ewp\_host}#生成form的action属性，为什么升级后ewp_host变成了空字符串？

    *A：在新版本中channel旧回调的模板输入中删除了ewp_host，为了兼容可以在transform的返回结果中加入{ewp_host, ?arg("host")}*

* Q：升级之后发现很多页面都显示为空页面，原因是服务器返回的报文最开始多了一些空格，旧版本客户端逻辑无法解析，该如何解决？

    *A：cs模板在3.x版本中的换行符不会被过滤，在4.x版本中的换行符会被删除。但在5.x版本中，换行符会被替换成空格，这可能导致一些页面无法正常显示。此时可以修改ewp.conf的cs\_enter\_filter配置，为0时不过滤换行，为1时删除换行。*
