# Release Note 5.4.24B
<!-- toc -->

## HighLight

### CSS样式优化
类 RYTCSSStyle
增加接口:
@property (nonatomic, retain) NSMutableDictionary *style;
注: 样式中解析生产的RYTCSSStyle对象中的style属性包含了本样式的所有样式值.
而RYTCSSStyle对象其他的样式属性将为nil或默认值.

获取样式请使用RYTControl的- (void)getCSSStyle方法.

###新增静态库MultiHttps
MultiHttps静态库支持了多https信道功能。<br>
使用说明：<br>
1. 添加静态库到工程<br>
2. 导入头文件 "RYTMultiHttps.h"<br>
3. 开启功能方法 <br>
[[RYTMultiHttpsSupport sharedMultiHttpsSupport] multiHttpsSupport];
文档链接：[客户端支持多https信道](http://dev.rytong.me/emp/inner_docs/software_process/design/EMP/EMP_support_https_list.html)

### [#13587](https://dev.rytong.me:9998/proj/emp/ticket/13587)
离线优化修改<br/>
[离线资源优化-客户选设计文档](http://dev.rytong.me/emp/inner_docs/software_process/design/offline/offline_resource_optimization_client.html)
<br/>
可选增量更新<br/>
说明:<br/>
1.lua接口修改
	
	offline:downOptionalFile(filename, parameter)；
	Description:
	根据插件包名，比较客户端已下载与服务器返回的描述，记录需要删除及下载的文件。
	需要兼容之前功能。
	Parameters:
	filename(required) 文件名（依.zip结尾）
	parameter(optional) (类型：Table) 详情参照下面文档链接

2.下载进度回调存在平台差异，具体见下文档说明<br/>
[可选资源增量更新 - 客户端设计](http://dev.rytong.me/emp/inner_docs/software_process/design/offline/offline_resource_optinal_part_client.html)
<br/>
离线优化修改补充<br/>
说明：lua接口修改
	
	offline:checkOfflineFileWithLocal(filename, appName)
	offline:checkOfflineFileWithServer(filename, appName)
	offline:checkOfflineFileWithLocalH5(filename, appName)
	offline:checkOfflineFileWithServerH5(filename, appName)
	offline:checkOfflineFile(filename)
	以上五个lua方法变更为:  只针对可选资源做判断，若为必选资源或不存在的资源返回false。

更为详细修改见文档<br/>
[离线优化客户端-补充设计文档](../../../inner_docs/software_process/design/offline/offline_resource_optimization_client_supplement.md)

### [#13200](https://dev.rytong.me:9998/proj/emp/ticket/13200)
增加H5插件支持，增加H5可选功能。<br/>
[离线H5资源插件下载说明](http://dev.rytong.me/emp/inner_docs/software_process/design/offline/h5_plug_support_client.html)

###整合js接口，新增cordova库  
整合了Cordova的功能到新的webView中，通过API，移动应用能够以JavaScript访问原生的设备功能，如摄像头、麦克风等。  
使用说明: [Cordova库使用说明](http://dev.rytong.me/emp/ert_develop/deepin_client_dev/ios/iOS_EMPCordova.html)  
技术分享: [PhoneGap与Cordova](http://dev.rytong.me/emp/inner_docs/technology_accumulation/iOS/advanced_technology/cordova.html)


### [#13282](https://dev.rytong.me:9998/proj/emp/ticket/13282)
select控件增加lua操作相关接口.   
[设计文档及接口说明文档](http://dev.rytong.me/emp5.3/inner_docs/software_process/design/EMP/control_lua/select_lua_design.html)

###[#10924](https://dev.rytong.me:9998/proj/emp/ticket/10924)
信道重连  
[设计文档](http://dev.rytong.me/emp/inner_docs/software_process/design/EMP/design_of_tls_rehandshake.html)

### [#13208](https://dev.rytong.me:9998/proj/emp/ticket/13208)
基于信道1.5实现客户端对服务器的防重放功能.  
[需求规格说明书](http://dev.rytong.me/emp5.3/inner_docs/software_process/requirement/client_anti_replaying.html)  
[设计文档](http://dev.rytong.me/emp5.3/inner_docs/software_process/design/EWP/design_of_client_anti_replaying.html)


### [#13581](https://dev.rytong.me:9998/proj/emp/ticket/13581) 颜色值增加ARGB格式支持
说明：
颜色值的设置增加ARGB格式支持.


### [#13564](https://dev.rytong.me:9998/proj/emp/ticket/13564) table最后一行的分隔线去掉
说明：去掉了系统table控件在最后一行会有一条分隔线，这条线会和table的边框线重合。

### [#13579](https://dev.rytong.me:9998/proj/emp/ticket/13579) 控件Onclick事件的响应与取消
说明：修改a标签、checkBox、Segment、div、img、radio、select、td等控件点击响应事件的方式 改为同UIControlEventTouchUpInside 类似，当点击控件后，手指移出控件范围后放开手指，不会触发事件。

### [#10818](https://192.168.64.239/proj/emp/ticket/10818)添加email键盘类型[#10819 ](https://192.168.64.239/proj/emp/ticket/10819)添加url键盘类型
说明： 根据inputText控件的style属性决定弹出键盘类型，此功能只支持iOS平台.  
[文档说明](../../../info_center/emp_ui_reference/html_tags/InputText.md)

### [#14011](https://192.168.64.239/proj/emp/ticket/14011) 富文本H7字体大小问题
说明：获取设置的默认字体大小,h7字号为正文默认字号大小,由配置RYTDefines的宏DEFAULT_FONT_HEIGHT决定，此处修改为iOS平台

### [#13741](https://192.168.64.239/proj/emp/ticket/13741) segment和checkbox的onclick事件
说明：修改segment和checkbox当为选中状态时不可再触发onclick事件，此处修改为iOS平台

### [#13576](https://192.168.64.239/proj/emp/ticket/13576) MDAP离线资源问题
说明：删除文件检测的逻辑，避免因为插件中某个资源读取不到,而删除整个插件包；无论资源是否存在都由离线资源的读取接口处理，此处修改为iOS平台

### [#13353](https://192.168.64.239/proj/emp/ticket/13353) 控件name属性
说明：修改name属性为只读

### [#13576](https://192.168.64.239/proj/emp/ticket/13576) MDAP离线资源问题
说明：删除文件检测的逻辑，避免因为插件中某个资源读取不到,而删除整个插件包；无论资源是否存在都由离线资源的读取接口处理，此处修改为iOS平台


##恒丰兼容
### [#14299](https://192.168.64.239/proj/emp/ticket/14299)饼图未显示

5.3产品代码做了一次样式优化，解析样式表时有一个空的样式对象(属性值为nil)，还有一个属性property_字典，此属性字典中存样式值，一般控件通过getCSSStyle方法获取，此方法中通过- (void) copy:(RYTCSSStyle *)style方法给样式对象(即属性值)赋值。此ticket不必修改产品代码，需要恒丰代码修改，在- (void)createCakeControl 方法的样式赋值给rotateCustomView.itemsColorArray数组之前添加[style copy:style];即：调用RYTCSSStyle的- (void) copy:(RYTCSSStyle *)style方法