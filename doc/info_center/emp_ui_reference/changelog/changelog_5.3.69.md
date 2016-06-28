# 5.3增强版（5.3.69R）变更记录

<!-- toc -->

## 前言

本文档记录5.3增强版（5.3.69R）相对于5.3基础版（5.3.41）在控件和lua脚本上的变更范围，具体修改内容请点击链接进相关页面查看。

## 属性

### 新增属性

**其他属性**

- [gooffline](./property/Property.md#gooffline)
- [leftimgpos](./property/Property.md#leftimgpos)
- [rightimgpos](./property/Property.md#rightimgpos)

**特殊属性**

- [minscrolllimit](./property/Property.md#minscrolllimit)

## 样式

### 样式变更

- [background-image](./css/CSS.md#background-image)样式增加图片文件不存在时，控件背景图显示空的说明
- [right](./css/CSS.md#right)样式增加必须设置父控件width的说明

## 页面控件标签

### 标签变更

**注**：

1. 新增的全局属性和样式在各控件标签中不再赘述；
2. 控件默认宽高均以320*480为报文基础分辨率。

#### [Body](./html_tags/Body.md)

- 新增支持[minscrolllimit](./property/Property.md#minscrolllimit)属性

#### [Div](./html_tags/Div.md)

- 新增支持[minscrolllimit](./property/Property.md#minscrolllimit)属性

#### [InputButton](./html_tags/InputButton.md)

- 新增支持[leftimgpos](./property/Property.md#leftimgpos)、[rightimgpos](./property/Property.md#rightimgpos)属性
- 完善Button[布局规则](./html_tags/InputButton.md#布局规则)

#### [InputSegment](./html_tags/InputSegment.md)

- 新增支持[background-color](./css/CSS.md#background-color)、[color](./css/CSS.md#color)样式
- 新增支持[伪类](./html_tags/InputSegment.md#伪类)

#### [Table](./html_tags/Table%20&%20Tr%20&%20Td%20&%20Th.md)

- 新增支持[minscrolllimit](./property/Property.md#minscrolllimit)属性

#### [Webview](./html_tags/Webview.md)

- 新增支持[gooffline](./property/Property.md#gooffline)属性

## 图片适配规则

增加图片适配规则，具体可参考[图片适配规则](./layout/emp_screen_adaptation.md#图片适配规则)章节。

## Lua接口

### 新增接口

- [document:removeOnClickListener(function)](./lua/Document.md#documentremoveonclicklistener)
- [document:removeOnFocusListener(function)](./lua/Document.md#documentremoveonfocuslistener)
- [document:removeOnBlurListener(function)](./lua/Document.md#documentremoveonblurlistener)
- [document:removeOnChangeListener(function)](./lua/Document.md#documentremoveonchangelistener)
- [file:readH5(name, type)](./lua/File.md#filereadh5name-type)
- [offline:checkOfflineFileWithLocalH5(filename)](./lua/Offline.md#offlinecheckofflinefilewithlocalh5filename)
- [offline:checkOfflineFileWithServerH5(filename)](./lua/Offline.md#offlinecheckofflinefilewithserverh5filename)
- [offline:update_hash(callback, parameter)](./lua/Offline.md#offlineupdatehashcallback-parameter)
- [offline:update_desc(callback, parameter)](./lua/Offline.md#offlineupdatedesccallback-parameter)
- [offline:update_resource(parameter)](./lua/Offline.md#offlineupdateresourceparameter)
- [offline:downOptionalFile(filename, callback, parameter)](./lua/Offline.md#offlinedownoptionalfilefilename-callback-parameter)
- [offline:getOptInfoInServer(appName)](./lua/Offline.md#offlinegetoptinfoinserverappname)
- [offline:getOptInfoInLocal(appName)](./lua/Offline.md#offlinegetoptinfoinlocalappname)
- [offline:checkOfflineFileWithLocal(filename, appName)](./lua/Offline.md#offlinecheckofflinefilewithlocalfilename-appname)
- [offline:checkOfflineFileWithLocalH5(filename, appName)](./lua/Offline.md#offlinecheckofflinefilewithlocalh5filename-appname)
- [offline:checkOfflineFileWithServer(filename, appName)](./lua/Offline.md#offlinecheckofflinefilewithserverfilename-appname)
- [offline:checkOfflineFileWithServerH5(filename, appName)](./lua/Offline.md#offlinecheckofflinefilewithserverh5filename-appname)
- [offline:removeOptionalFile(filaname, appName)](./lua/Offline.md#offlineremoveoptionalfilefilaname-appname)
- [offline:commentOfFile(filaname, appName)](./lua/Offline.md#offlinecommentoffilefilaname-appname)
- [offline:setResReadAppName(appName)](./lua/Offline.md#offlinesetresreadappnameappname)

### 接口变更

- [location:replace()](./lua/Location.md#locationreplace)增加支持文件路径参数，并新增参数类型支持
- [window:showcontent()](./lua/Window.md#windowshowcontentcontentpath-tag-optionparams)增加支持文件路径参数，并新增参数类型支持
- [control:getPropertyByName()](./lua/Metatable.html#getpropertybyname)接口支持获取所有属性，包括自定义属性

## Javascript接口

### 新增接口

- [EMPHttp:httpPostASync()](./js/EMPHttp.md#emphttphttppostasync)
- [EMPLocation:replace()](./js/EMPLocation.md#emplocationreplace)
- [EMPLocation:replaceContent()](./js/EMPLocation.md#emplocationreplacecontent)

## 事件分发规则

统一事件分发与冒泡规则，具体可参考[图片适配规则](./Event.md#事件分发与冒泡规则)章节。

  Date     | Note | Modifier
-----------|------|----------
2015-12-01 | 初版 | zhou.changjin