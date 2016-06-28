# Android离线协议4.0 -- H5插件下载  - 使用指南

<!-- toc -->

## 概述

本文主要介绍离线协议4.0版本支持的H5必选插件和可选插件下载。

## 使用对象

Android 客户端开发人员

## 离线协议版本配置

	@Override
	public void onAdjustEMPConfig(EMPConfig empConfig) {
		super.onAdjustEMPConfig(empConfig);
		...
		// 配置离线协议版本 4.0
		empConfig.setOfflineVersion(4.0);
	}
## 新增Lua接口及使用

新增了只在4版本离线协议中支持的Lua接口，具体请参见[离线协议4版本支持的Lua接口](../../../info_center/emp_ui_reference/lua/Offline.html#协议4.0版本支持的lua接口)。

## 离线请求接口调用流程

流程与其他版本一致。部分接口内容变更如下：

加密信道改造：
在加密信道上送的hash中,增加h5和h5_o的描述. 这样就会有四个描述的hash.加密信道上送的格式与之前版本相同.
增加type类型如下:
* 0x0C emp必选资源(原有类型)
* 0x0D emp可选资源(原有类型)
* 0x0F H5必选资源(新增类型)
* 0x0G H5可选资源(新增类型)

ota/resource_hash服务器返回内容变更：
resource_hash接口返回值定义.由于hash比对的情况较多,我们通过位运算的方式定义返回值的不同情况.
目前:通过返回值计算需要更新的资源类型. 比如当ewp必选资源和h5必选资源需要更新时,服务器会返回5.5仅代表1和4的组合.
* 0为不更新，
* 1为必选资源描述更新, 1<<0
* 2为可选资源描述更新, 1<<1
* 4为h5 必选资源更新, 1<<2
* 8为h5 可选资源更新, 1<<3

此方案可以保证任意情况的组合有且仅有一个唯一的确定值.

## 代码介绍

### 扩展类 FlowManagerImpl_Four

说明：

* 增加文件目录h5_plugin，保存已下载的h5插件资源,包括可选和必选.

* ota/update_hash增加h5必选和可选资源hash值的上传

		public StringBuffer initHashBody(HashMap<String, String> paramsMap) {}

		此方法将保存的h5可选必选hash值，追加置请求服务器body中。

* 保存h5_o描述文件

		public void preAnalyzeServerDesc(String serverDesc) {}

		此方法将服务器h5_o字段，保存到可选资源描述文件"h5_option_server.desc"中

* 解析h5字段，获取h5必选插件下载列表,追加到H5文件下载列表中

		@Override
		protected void analyzeServerDesc() {}

* 下载H5必选插件，保存文件，并更新描述文件

		@Override
		protected void getSource(Model model) {}

* 下载H5可选插件，保存文件，并更新描述文件

		@Override
		public byte[] downloadOption(Model model) {}

### 扩展类 DescManager_Four

- 针对H5可选资源描述文件的保存，更新。

### 扩展类 H5PluginModel

- 定义H5插件资源类型模型，区分其它资源类型。

### 下载H5插件

*	必选插件下载：发起离线请求流程，update_resource()会执行下载，具体的下载过程FlowManagerImpl_Four.getSource()方法中实现。

* 可选H5插件下载：首先getH5OptInfoInServer(appname)接口获取可选插件列表，之后downH5OptionalFile(filename, callback,parameter)接口下载文件。

### H5插件下载示例

	<?xml version="1.0" encoding="UTF-8" ?>
	<content>
		<head>
			<style>
				.body{background-color:#ffffff;}
				.divWeb {width:320px;height:200px;}
				.button1 {left:20px;font-size:15px;color:#FF0000;width:280px;height:40px;background-color:#FFFFFF;}
				.height{height:400px;width:320px;}
				.close_but {width:300px;height:30px;left:10px;font-size:20px;color:#000000;background-color:#ffff00;}
				.label_0{left: 10px;width: 300px;font-size: 15px;color: #ffffff;background-color: #445544;}
			</style>
			<script type="text/x-lua" src="RYTL.lua"></script>
			<script type="text/x-lua">
				<![CDATA[
					ryt = RYTL:new{};
					function close()
								ryt:back();
								end;
					--离线资源下载
					function download_default()
							parameter = {appname="ebank", info = "message"}
							local optTable = offline:getH5OptInfoInServer("ebank");
							for key,value in pairs(optTable) do
									if key == "test2.zip" then
											offline:downH5OptionalFile(key, callback_download_default,parameter);
									end;
							end
					end;
					function callback_download_default(result)
						if result then
							window:alert("下载成功")
						else
							window:alert("没有成功下载")
						end
					end;
					function doSetInnerHtml1()
						local div1 = document:getElementsByName("webview");
						local content = [[
																<div name="webview" class="height">
																	<div type="webview" gooffline="true" url="http://localhost:8080/undefined/test2.html">
																	</div>
																</div>
														]];
						div1[1]:setInnerHTML(content)
					end;
					function del_default()
						local result = offline:removeH5Plug("test2.zip","ebank");
						if result == true then
							window:alert("文件删除成功。");
						else
							window:alert("文件不存在或删除失败。");
						end
					end;
				]]>
			</script>
		</head>
		<body>
			<label class="label_0">点击下载可选资源包先下载可选资源，在点击下面按钮来展示webview内容</label>
			<input type="button" class="button1" onclick="download_default()" value="下载可选资源包" border="1"/>
			<input type="button" class="button1" onclick="del_default()" value="删除可选资源包" border="1"/>
			<input type='button' name='showDiv' class='button1' value='setInnerHtml设置webview1内容' onclick='doSetInnerHtml1()' border="1"/><br/>
			<div name="webview" class="height">
				<label>加载html页面空间</label>
			</div>
			<input type="button" border="0" class="close_but" value="关闭" onclick="close()"/>
		</body>
	</content>
