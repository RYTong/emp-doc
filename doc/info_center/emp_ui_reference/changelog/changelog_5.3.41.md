# 5.3基础版变更记录

<!-- toc -->

## 前言

本文档记录5.3基础版（5.3.41）相对于5.2在控件和lua脚本上的变更范围，具体修改内容请点击链接进相关页面查看。

## 属性

### 新增属性

**全局属性**

- [id](./property/Property.md#id)

**其他属性**

- [adjustsfontsize](./property/Property.md#adjustsfontsize)
- [autoplay](./property/Property.md#autoplay)
- [clearmode](./property/Property.md#clearmode)
- [cornerradius](./property/Property.md#cornerradius)
- [delay](./property/Property.md#delay)
- [failed](./property/Property.md#failed)
- [isorder](./property/Property.md#isorder)
- [istap](./property/Property.md#istap)
- [leftimg](./property/Property.md#leftimg)
- [leftimgmode](./property/Property.md#leftimgmode)
- [linebreakmode](./property/Property.md#linebreakmode)
- [loading](./property/Property.md#loading)
- [minfontsize](./property/Property.md#minfontsize)
- [offtintcolor](./property/Property.md#offtintcolor)
- [ontintcolor](./property/Property.md#ontintcolor)
- [returnkeyaction](./property/Property.md#returnkeyaction)
- [returnkeytype](./property/Property.md#returnkeytype)
- [rightimg](./property/Property.md#rightimg)
- [rightimgmode](./property/Property.md#rightimgmode)
- [shadowcolor](./property/Property.md#shadowcolor)
- [shadowoffset](./property/Property.md#shadowoffset)
- [substitute](./property/Property.md#substitute)
- [thumbtintcolor](./property/Property.md#thumbtintcolor)
- [titleimg](./property/Property.md#titleimg)
- [velocity](./property/Property.md#velocity)

### 属性变更

- [checked](./property/Property.md#checked)只支持checked、true、false三种值，其中checked和true都表示选中，false表示不选中。其余均为非法值
- [enable](./property/Property.md#enable)设置非法值时，按默认值true处理
- 原encryptMode改为小写[encryptmode](./property/Property.md#encryptmode)
- 原showFormat改为小写[showformat](./property/Property.md#showformat)，默认格式统一为yyyyMMdd
- 原valueFormat改为小写[valueformat](./property/Property.md#valueformat)，默认格式统一为yyyyMMdd

## 样式

### 新增样式

**全局样式**

- [position:topLevel](./css/CSS.md#position)

**其他样式**

- [border-radius](./css/CSS.md#border-radius)
- [font-style](./css/CSS.md#font-style)
- [inline-block](./css/CSS.md#inline-block)
- [visibility](./css/CSS.md#visibility)

### 样式变更

- 增加[伪类](./css/CSS.md#伪类)支持
- [text-align](./css/CSS.md#text-align)样式取消相对于父控件布局的功能

## 页面控件标签

### 新增标签

- [Richtext](./html_tags/Richtext.md)

### 标签变更

**注**：

1. 新增的全局属性和样式在各控件标签中不再赘述；
2. 控件默认宽高均以320*480为报文基础分辨率。

#### A

- 详情参考[A](./html_tags/A.md)
- 新增支持[linebreakmode](./property/Property.md#linebreakmode)属性
- 取消支持**value**属性
- 新增支持[伪类](./html_tags/A.md#伪类)
- 默认宽高统一为根据文字内容计算，但宽度不可超出父控件显示范围

#### Br

- 详情参考[Br](./html_tags/Br.md)
- 默认高度统一为35px

#### Div

- 详情参考[Div](./html_tags/Div.md)
- 新增支持[font-style](./css/CSS.md#font-style)、[border-radius](./css/CSS.md#border-radius)、[inline-block](./css/CSS.md#inline-block)样式
- 默认宽高统一为根据子控件内容计算，但宽度不可超出父控件显示范围

#### Img

- 详情参考[Img](./html_tags/Img.md)
- 新增支持[gif格式](./html_tags/Img.md#属性)图片
- 新增支持[autoplay](./property/Property.md#autoplay)、[istap](./property/Property.md#istap)、[loading](./property/Property.md#loading)、[failed](./property/Property.md#failed)属性
- 默认宽度统一为30px，默认高度统一为30px

#### InputButton

- 详情参考[InputButton](./html_tags/InputButton.md)
- 新增支持[delay](./property/Property.md#delay)、[leftimg](./property/Property.md#leftimg)、[rightimg](./property/Property.md#rightimg)属性
- 新增支持[font-style](./css/CSS.md#font-style)、[border-radius](./css/CSS.md#border-radius)、[visibility](./css/CSS.md#visibility)样式
- 新增支持[伪类](./html_tags/InputButton.md#伪类)
- 默认宽高统一为根据文字内容计算，但宽度不可超出父控件显示范围

#### InputCheckbox

- 详情参考[InputCheckbox](./html_tags/InputCheckbox.md)
- 新增支持[linebreakmode](./property/Property.md#linebreakmode)、[numlines](./property/Property.md#numlines)、[shadowcolor](./property/Property.md#shadowcolor)、[shadowoffset](./property/Property.md#shadowoffset)、[valign](./property/Property.md#valign)属性
- 新增支持[background-color](./css/CSS.md#background-color)、[background-image](./css/CSS.md#background-image)、[filter](./css/CSS.md#filter)、[font-style](./css/CSS.md#font-style)样式
- 默认宽高统一为根据文字内容计算，但宽度不可超出父控件显示范围

#### InputPassword

- 详情参考[InputPassword](./html_tags/InputPassword.md)
- 新增支持[isorder](./property/Property.md#isorder)、[substitute](./property/Property.md#substitute)属性
- 新增支持[border-radius](./css/CSS.md#border-radius)样式
- 默认宽度统一为300px，默认高度统一为24px

#### InputRadio

- 详情参考[InputRadio](./html_tags/InputRadio.md)
- 新增支持[linebreakmode](./property/Property.md#linebreakmode)、[numlines](./property/Property.md#numlines)、[shadowcolor](./property/Property.md#shadowcolor)、[shadowoffset](./property/Property.md#shadowoffset)、[valign](./property/Property.md#valign)属性
- 新增支持[background-color](./css/CSS.md#background-color)、[background-image](./css/CSS.md#background-image)、[filter](./css/CSS.md#filter)、[font-style](./css/CSS.md#font-style)样式
- 默认宽高统一为根据文字内容计算，但宽度不可超出父控件显示范围

#### InputSegment

- 详情参考[InputSegment](./html_tags/InputSegment.md)
- 新增支持[cornerradius](./property/Property.md#cornerradius)、[ontintcolor](./property/Property.md#ontintcolor)、[titleimg](./property/Property.md#titleimg)属性
- 新增支持[font-style](./css/CSS.md#font-style)、[visibility](./css/CSS.md#visibility)样式
- 默认宽度统一为180px，默认高度统一为30px（iOS平台除外）

#### InputSwitch

- 详情参考[InputSwitch](./html_tags/InputSwitch.md)
- 新增支持[offtintcolor](./property/Property.md#offtintcolor)、[ontintcolor](./property/Property.md#ontintcolor)、[thumbtintcolor](./property/Property.md#thumbtintcolor)属性
- [check](./property/Property.md#check)属性设置非法值时，按默认值false处理
- 默认宽度统一为120px，默认高度统一为30px（iOS平台除外）

#### InputText

- 详情参考[InputText](./html_tags/InputText.md)
- 新增支持[clearmode](./property/Property.md#clearmode)、[leftimg](./property/Property.md#leftimg)、[leftimgmode](./property/Property.md#leftimgmode)、[rightimg](./property/Property.md#rightimg)、[rightimgmode](./property/Property.md#rightimgmode)、[returnkeyaction](./property/Property.md#returnkeyaction)、[returnkeytype](./property/Property.md#returnkeytype)、
- 新增支持[border-radius](./css/CSS.md#border-radius)、[font-style](./css/CSS.md#font-style)样式
- 默认宽度统一为300px，默认高度统一为24px

#### Label & I & Em & B & Strong

- 详情参考 [Label](./html_tags/Label.md)、[I & Em](./html_tags/I%20&%20Em.md)、[B & Strong](./html_tags/B%20&%20Strong.md)
- 新增支持[adjustsfontsize](./property/Property.md#adjustsfontsize)、[linebreakmode](./property/Property.md#linebreakmode)、[minfontsize](./property/Property.md#minfontsize)、[shadowcolor](./property/Property.md#shadowcolor)、[shadowoffset](./property/Property.md#shadowoffset)、[velocity](./property/Property.md#velocity)属性
- 取消支持**value**属性
- 新增支持[font-style](./css/CSS.md#font-style)样式
- 默认宽高统一为根据文字内容计算，但宽度不可超出父控件显示范围

#### Select & Option

- 详情参考[Select & Option](./html_tags/Select%20&%20Option.md)
- select新增支持[border](./property/Property.md#border)属性
- select新增支持[border](./css/CSS.md#border)、[border-radius](./css/CSS.md#border-radius)、[font-style](./css/CSS.md#font-style)样式
- option新增支持[color](./css/CSS.md#color)、[font-size](./css/CSS.md#font-size)、[font-style](./css/CSS.md#font-style)、[font-weight](./css/CSS.md#font-weight)、[text-align](./css/CSS.md#text-align)样式
- select默认宽度统一为根据内容最长的子option计算，但不可超出父控件显示范围，默认高度统一为30px

#### Table

- 详情参考[Table](./html_tags/Table%20&%20Tr%20&%20Td%20&%20Th.md)
- 新增支持[border-radius](./css/CSS.md#border-radius)、[font-style](./css/CSS.md#font-style)样式
- 默认宽高统一为根据子控件内容计算，但宽度不可超出父控件显示范围

#### Td

- 详情参考[Td](./html_tags/Table%20&%20Tr%20&%20Td%20&%20Th.md)
- 新增支持[font-style](./css/CSS.md#font-style)样式
- 默认宽高统一为根据子控件内容计算，但宽度不可超出父控件显示范围

#### Tr

- 详情参考[Tr](./html_tags/Table%20&%20Tr%20&%20Td%20&%20Th.md)
- 新增支持[font-style](./css/CSS.md#font-style)样式
- 默认宽高统一为根据子控件内容计算，但宽度不可超出父控件显示范围

## 布局规则

各平台布局规则统一，具体可参考[布局与刷新](./layout/layout_introduction.md)章节。

## Lua接口

### 新增接口

- [document:getElementById(id)](./lua/Document.md#documentgetelementbyid)
- [document:getElementsByClassName(className)](./lua/Document.md#documentgetelementsbyclassname)
- [document:createElement(tagname, property)](./lua/Document.md#documentcreateelement)
- [kv:put(key, value)](./lua/KV.md#kvput)
- [kv:get(key)](./lua/KV.md#kvget)
- [kv:del(key)](./lua/KV.md#kvdel)
- [offline:checkOfflineFileWithServer(filename)](./lua/Offline.md#offlinecheckofflinefilewithserverfilename)
- [control:appendChild(control1)](./lua/Metatable.md#appendchild)
- [control:insertBefore(control1, control2)](./lua/Metatable.md#insertbefore)
- [control:removeChild(control1)](./lua/Metatable.md#removechild)

### 接口变更

- location:reload()增加可选参数，改为[location:reload(reset)](./lua/Location.md#locationreload)
- offline:update\_resource()增加可选参数，改为[offline:update\_reource(params)](./lua/Offline.md#offlineupdateresourceparams)
- [offline:checkOfflineFile(filename)](./lua/Offline.md#offlinecheckofflinefilefilename)针对可选资源的检验规则变更
- window:showControl(object, tag, transitionType)增加可选参数，改为[window:showControl(object, tag, transitionType, isModel)](./lua/Window.md#windowshowcontrol)
- [control:getPropertyByName()](./lua/Metatable.html#getpropertybyname)接口支持获取所有属性，包括自定义属性


  Date     | Note | Modifier
-----------|------|----------
2015-09-21 | 初版 | zhou.changjin