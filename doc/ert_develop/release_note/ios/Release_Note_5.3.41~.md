# Release Note 5.3
<!-- toc -->

## HighLight

### MDAP相关API修改
* MDAP中删除RYTUncaughtExceptionHandler类.  
* MDAP中增加RYTUncaughtExceptionTrack类.  
* EMP的Utility库中增加RYTUncaughtExceptionHandler类. 负责异常的捕获功能. 通过调用[[RYTUncaughtExceptionHandler sharedUncaughtExceptionHandler] setExceptionHandler]开启监听.   
* EMPConfig 增加saveCrashLog方法,控制是否将RYTUncaughtExceptionHandler捕获的异常写入文件.如果设置为YES,会将信息写入Document/crash.log中.

MDAP中的RYTUncaughtExceptionTrack类负责将RYTUncaughtExceptionHandler捕获的异常收集并上传MDAP服务器.
当MDAP中需要采集异常信息时,需要实现如下代码

	// 开启异常捕获功能
	[[RYTUncaughtExceptionHandler sharedUncaughtExceptionHandler] setExceptionHandler];
	// 为异常捕获设置代理.
	[[RYTUncaughtExceptionHandler sharedUncaughtExceptionHandler] setDelegate:[RYTUncaughtExceptionTrack sharedUncaughtExceptionTrack]];



### Crash问题说明
当以动画方式进行页面跳转时, 请不要同时使控件宽高或其一为0,并且设置border属性为1. 这种情况下在ios8系统中会崩溃.
宽度为0的情况包括:
样式设置宽高为0 ,宽高任何一项为零都是有问题的.
由于没有子控件,或子控件因此,导致计算宽高为0的情况.

### 离线资源2.0

1. 支持在服务端配置离线资源安全传输的方式：明文传输、EMP信道明文传输、EMP信道密文传输、HTTPS/SSL。
2. 服务端根据配置在描述文件中增加传输方式字段，客户端根据该字段标识的传输方式下载资源。不符合规定的下载请求将被拒绝。
3. 修改现有HTTP和TCP下载接口，使其支持四种传输方式。
4. 修改服务端存储离线资源的路径，使资源不会被直接下载。
5. 兼容旧版本客户端
6. 支持加载进度

[离线资源2.0需求文档](http://dev.rytong.me/emp5.3/inner_docs/software_process/requirement/security_optimization_of_offline.html)<br/>
[离线资源2.0设计文档](http://dev.rytong.me/emp5.3/inner_docs/software_process/design/offline/offline_resource_2.0.html)

### 国际化
[国际化设计及使用说明文档](http://dev.rytong.me/emp5.3/inner_docs/software_process/design/EMP/internationalization.html)

### SDK定制功能优化
[SDK定制说明](http://dev.rytong.me/emp5.3/info_center/emp_ui_reference/html_tags/sdkexplain.html)<br/>
[客户端配置属性说明](http://dev.rytong.me/emp5.3/info_center/emp_ui_reference/property/control_global_property.html)

### 富文本
[富文本功能说明](http://dev.rytong.me/emp5.3/info_center/emp_ui_reference/html_tags/Richtext.html)

### DOM API
[document:createElement()](http://dev.rytong.me/emp5.3/info_center/emp_ui_reference/lua/Document.html#documentcreateelement)<br/>
[element:appendChild](http://dev.rytong.me/emp5.3/info_center/emp_ui_reference/lua/Metatable.html#appendchild)<br/>
[element:insertBefore](http://dev.rytong.me/emp5.3/info_center/emp_ui_reference/lua/Metatable.html#insertBefore)<br/>
[element:removeChild](http://dev.rytong.me/emp5.3/info_center/emp_ui_reference/lua/Metatable.html#removeChild)

### GIF支持
img控件增加对gif的支持.img src属性增加gif格式的文件支持.<br/>
[imggif支持](http://dev.rytong.me/emp5.3/info_center/emp_ui_reference/html_tags/Img.html#属性)

### iOS 状态栏
增加新的ios状态栏适配方案<br/>
[ios状态栏适配方案](http://dev.rytong.me/emp5.3/xhtml_example/ios/ios_adaptation.html)

### SLT2脚本解析功能
[SLT2设计方案](http://dev.rytong.me/emp5.3/inner_docs/software_process/design/EMP/slt2/design_of_slt2_parsing.html)

### DOM节点查找性能优化
[DOM节点查找性能优化方案](http://dev.rytong.me/emp5.3/inner_docs/software_process/design/EMP/dom_search_optimization_scheme.html)

### CSS 公共样式
[CSS公共样式设计方案](http://dev.rytong.me/emp5.3/inner_docs/software_process/design/EMP/globalcss/css_global_cache.html)

### #11832
lua getPropertyByName接口支持获取所有属性.包括自定义属性.

## 布局算法调整
#### #12453 完善布局算法, 当br作为第一个控件时,其后面控件需要换行.
#### #12107 删除text-align属性相对于父控件对齐的功能.
#### #11760 div控件大小根据其子控件内容动态计算
#### #12012 br作为容器类控件最后一个元素时的处理
1. 如果br前一个元素为block,需要增加行高.
2. 如果br前一个元素为inline,则不做换行处理

#### #11576 button不在支持默认大小,在没有样式指定的情况下,根据内容计算button控件大小

## 标准化
#### #12450 日期控件默认显示格式及上传格式统一为yyyymmdd.
#### #12404 check属性值处理.对于segment,switch,radio,check控件,其支持的checked属性,可以支持checked,true,false三种值.其中checked和true都表示选中.false及其他非法值表示不选中.
#### #12337 switch的check属性设置非法值时,按默认值false处理
#### #12289 enable属性设置非法值时,按默认值true处理
#### #11930 统一select默认字体颜色为黑色

## API变更
####  EMPConfig
增加 @property (nonatomic, assign) BOOL supporStatusBarInXML;

 返回是否支持 ios7 状态栏效果. 如果通过模板实现ios 状态栏的效果,这里需要返回 true.<br/>
 根据 emp 对 ios7状态栏的支持方式,当设置状态栏高度为0时,说明状态栏不占位.<br/>
 这里没有处理通过调整 UIContentView 的位置的情况.<br/>
 因此这里的算法并不能覆盖所有的情况. 如果项目中自定义了 UIContentView 的位置,需要重写本接口已返回正确的状态.

####  Lua Element
* 增加 getElementsById() 接口
* 增加 getElementsByClassName() 接口

#### RYTCSSStyle
* 增加 @property (nonatomic, copy) NSString *styleName;  获取样式名
* 删除 - (NSArray *)styleNames; 获取样式名列表


