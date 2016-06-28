# Release Note 5.4.26B~
<!-- toc -->

###接口修改
####[#14445](https://dev.rytong.me:9998/proj/emp/ticket/14445)<br>
iOS-H5集成功能中的网络请求接口优化,按请求的url = serverurl + 参数url ；请求的body = params做uri编码，修改了httpPostASync方法



###离线功能
####[#14325](https://dev.rytong.me:9998/proj/emp/ticket/14325)<br>
 修改了离线中读取失败列表的方式；修改了resourceModel模型的变量；修改了失败列表合并到下载列表后，在下载列表中查找模型的方法等。
 
 
 
###后台版本兼容问题
注意：现在版本（V5.4.26-b）客户端无法兼容低于5.4版本的后台服务器，此兼容功能会在后续版本中实现。


###注意
目前版本的离线不支持重复调用 update_desc，这样会导致一些无法预知的错误。