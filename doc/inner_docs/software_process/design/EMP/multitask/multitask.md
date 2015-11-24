# 多任务设计<!-- toc --> ## 版本历史			版本号   | 日期      | 作者   | 描述
------- | --------- | ----- | --------------
V1.0    | 2015.8.27 | 周长晋 | 初稿## 需求概述在目前的银行业务办公中，业务人员经常会遇到同时处理多个任务的情况，如业务人员正在办理工作记录填报（任务1）的过程中，临时来了个客户，需要通过办理理财产品查询的业务（任务2）。任务1和任务2为两个完全独立的功能，业务人员可以随意切换查看，以及随意打开关闭某个任务。这种场景通过我们目前产品中的单任务设计是很难做到的，因此我们需要扩展产品的功能，以达到支持多任务的业务场景。 多任务拟实现的效果与浏览器能同时打开多个标签页类似。## 名词说明
- 根任务模块：指当前应用程序的任务模块，该任务在整个程序中有且仅有一个，关闭则程序退出。
- 子任务模块：可随时打开关闭的业务模块，嵌套与根任务中，由根任务创建，可存在多个。## 功能需求

- 根任务可以通过添加标签打开一个新的子任务，或者删除标签关闭（结束）该子任务；
- 根任务模块可通过标签页看到当前已打开的多个任务，并可以通过点击标签页切换子任务的显示；
- 子任务支持emp和h5两种任务类型；
- 各个子任务彼此独立，无数据共享，无操作交互。子任务与根任务间也无数据共享，无操作交互；
- 各任务只通过全局样式库共享样式，一些可以被继承的样式无需从根任务模块传递给子任务模块；
- 需后台保存交易数据（跨会话存在）的“已暂存任务”功能，暂不考虑实现。## 设计说明### emp类型子任务#### 子任务控件由于子任务的功能需求和根任务类似，我们可以通过扩展body的扩展控件作为子任务的容器控件。	<body type=subtask" class="subtask1"></body>##### 属性支持body-subtask的支持以下属性：- `id`：控件的id
- `name`：控件的name
- `class`：控件应用的样式
- `hide`：显示/隐藏

##### 样式支持body-subtask的支持以下样式：- `width`、`height`：控件的宽高。同body控件，子任务控件的宽高不可动态修改，我们只支持初始化时的静态设置
- `left`、`right`、`top`、bottom：控件的位置
- `background-color`、`background-image`、`filter`：背景色、背景图和渐变色
- `display`、`visbility`：显示/隐藏#### 数据存储为增强子任务间的独立性，减少数据交互，我们为每个子任务都单独分配一个dom树和一个lua状态机。子任务的dom树和lua状态机也可存储在对应body-subtask控件中，与其绑定。##### dom树子任务dom树与父任务dom树相互无联系，即遍历父任务dom树，不会遍历到子任务dom树内的节点；同样遍历子任务dom树，也不会遍历到父任务dom树内的节点。![](./multitask_dom.png)##### lua状态机由于在实际使用场景中，不太可能对多个任务同时做操作，因此程序中所有的lua状态机都可以跑在同一个lua线程中，子任务lua状态机对现有lua接口的支持如下：- 与dom树相关的lua接口，需要做改造，以保证操作的dom树准确，包括`document`、`history`以及`control:setInnerHTML`、`control:appendChild`、`control:insertBefore`、`control:removeChild`；- `location:reload`与`location:replace`，由于操作的是整体页面，在子任务不适用，不应支持，同样功能应该用其他接口或者扩展lua实现。replace操作可用父控件的`setInnerHTML`实现，reload功能需要扩展新的lua接口实现。
- 涉及公共操作的接口无需特殊处理，包括`accelerometer`、`audio`、`corp`、`database`、`file`、`gesture`、`gps`、`http`、`json`、`kv`、`offline`、`qrcode`、`screen`、`system`、`timer`、`utility`、`video`、`window`及control剩余接口；

#### 子任务页面显示

子任务控件内的页面显示内容，可通过调用`setInnerHTML`接口局部刷新的方式显示。

	local subTask1 = document:getElementbyId("task1");
	subTask1：setInnerHTML(<content>...</content>);

为保证通用性，子任务控件支持接收现在规范的页面报文结构，但由于子任务的特殊性，需要对body控件的实现做修改。之前的body控件，强制是铺满整个屏幕的，因此对`width`、`height`、`left`、`right`、`top`、`bottom`样式都是不支持的，而子任务控件里的body需要对这些样式增加支持，因此我们需要在解析body的时候增加判断，看当前body属于父任务dom树还是子任务dom树，以此来决定是否应用这些样式。

产品目前没有控件reload的接口，要实现子任务控件的reload，需要扩展新的lua接口。

### h5类型子任务h5类型的任务，可以通过webview控件实现，webview的实现方式完全可以满足现有需求，无需特殊处理。### 打开/关闭子任务我们可以通过5.3新增的`document:createElement`接口创建一个新的子任务控件。然后通过`control:appendChild`将子任务控件加载到根任务中，或者通过`control:removeChild`关闭子任务。	function openTask(id)		local div = document:getElementById("div");		if id == 1 then			local subTask1 = document:createElement(body, {type="subtask", class="subtask1", id="task1"});			div:appendChild(subTask1);		else if id == 2 then			local subTask2 = document:createElement(div, {type="webview", class="subtask2", id="task2"});			div:appendChild(subTask2);		end	end	function showTask(id)		local subTask1 = document:getElementbyId("task1");		local subTask2 = document:getELementById("task2");		if id == 1 then			if subTask1 then				subTask1:setStyleByName("display", "block");			end			if subTask2 then				subTask2:setStyleByName("display", "none");			end		else if id == 2 then			if subTask1 then				subTask1:setStyleByName("display", "none");			end			if subTask2 then				subTask2:setStyleByName("display", "block");			end		end	end		function closeTask(id)		local div = document:getElementById("div");		if id == 1 then			local subTask1 = document:getElementbyId("task1");			if subTask1 then				div:removeChild(subTask1);			end		else if id == 2 then			local subTask2 = document:getELementById("task2");			if subTask2 then				div:removeChild(subTask2);			end		end	end	<body>		<input type="button" value="打开任务一" onclick="openTask(1)"/>		<input type="button" value="打开任务二" onclick="openTask(2)"/>		<input type="button" value="显示任务一" onclick="showTask(1)"/>		<input type="button" value="显示任务二" onclick="showTask(2)"/>		<input type="button" value="关闭任务一" onclick="closeTask(1)"/>		<input type="button" value="关闭任务二" onclick="closeTask(2)"/>		<div class="class1" id="div"></div>	</body>