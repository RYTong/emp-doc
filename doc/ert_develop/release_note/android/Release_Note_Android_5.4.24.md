# Release Note 5.4.24B

<!-- toc -->

## highlight

### 离线协议4.0

1. 优化可选资源更新逻辑，增加可选资源增量更新的功能；
2. 增加 H5 插件资源的下载支持，包括必选插件、可选插件；
3. 增加 android 大文件下载功能，解决 android 低端手机在下载比较大的离线文件时，在加解密的处理过程中，内存不足的问题。

[可选资源增量更新需求文档](../../inner_docs/software_process/requirement/offline/single_optional_resource_dl_offline.html)<br/>
[可选资源增量更新设计文档](../../inner_docs/software_process/design/offline/offline_resource_optinal_part_client.html)<br/>
[离线H5插件支持设计文档](../../inner_docs/software_process/design/offline/h5_plug_support_client.html)<br/>
[离线大文件更新设计文档](../../inner_docs/software_process/design/offline/offline_4_0_design_server.html#大文件资源更新)

### 客户端防重放功能

新增信道1.5版本，支持客户端防重放的功能。

[客户端防重放需求](../../../inner_docs/software_process/requirement/client_anti_replaying.html)<br>
[客户端防重放设计](../../../inner_docs/software_process/design/EWP/design_of_client_anti_replaying.html)

### 信道重连

优化信道重连功能，统一各客户端平台实现细节。

[信道重连需求及设计](../../../inner_docs/software_process/design/EMP/design_of_tls_rehandshake.html)

### 多https支持

增加EMP 多https 请求通道的支持。

[多https信道支持需求](../../../inner_docs/software_process/requirement/5.3/multi_encrypted_tunnels.html)<br>
[多https信道支持客户端设计](../../../inner_docs/software_process/design/EMP/EMP_support_https_list.html)<br>
[多https信道支持服务端设计](../../../inner_docs/software_process/design/EMP/EWP_support_https_list.html)

### select控件增加lua操作相关接口

[设计文档及接口说明文档](../../inner_docs/software_process/design/EMP/control_lua/select_lua_design.html)

## API修改

### 控件View创建方式优化

在旧版本中，Android客户端在创建控件View时，是通过查找控件库中已注册的控件，再用反射的方式获取构造方法实例化对象。

	Class<?> cls = GUIRepository.get(element);
	Constructor<?> cons = cls.getConstructor(Context.class);
	guiView = (GUIView) cons.newInstance(mActivity);

而反射在实际运行过程中，效率较低，因此在EMP5.4版本中，产品新增了一种控件的创建方式。

产品中添加了`EMPViewCreater`抽象类，其`createView`方法用于创建View实例。

	package com.rytong.emp.gui.atom.creater;

	import android.content.Context;
	
	import com.rytong.emp.gui.GUIView;
	
	
	public abstract class EMPViewCreater {
		
		public abstract GUIView createView(Context context);
	}

针对每一个控件，可继承`EMPViewCreater`类实现自定义的creater类，如div：

	package com.rytong.emp.gui.atom.creater;

	import android.content.Context;
	
	import com.rytong.emp.gui.GUIView;
	import com.rytong.emp.gui.atom.Div;
	
	
	public class DivCreator extends EMPViewCreater {
		
		private static final EMPViewCreater mDivCreater = new DivCreator();
	
		public static EMPViewCreater getInstance() {
			return mDivCreater;
		}
	
		@Override
		public GUIView createView(Context context) {
			return new Div(context);
		}
	}

同旧版本类似，需要在`GUIRepository`中注册控件类与creater的构造关系。

	GUIRepository.addGUIViewCreator("div", DivCreator.getInstance());

这样就可以在创建控件时走新的流程。新流程由于移除了反射的应用，采用了直接new的方式实例化对象，效率更高。同时为保证兼容性，旧的控件构建方式保留，且优先级高于新流程。

	Class<?> cls = GUIRepository.get(element);

	if (cls != null) {
		Constructor<?> cons = cls.getConstructor(Context.class);
		guiView = (GUIView) cons.newInstance(mActivity);
	} else {
		EMPViewCreater creator = GUIRepository.getCreator(element);
		guiView = creator.createView(mActivity);
	}

### BgStyle类构造方法变更

在EMP5.4版本中，Android客户端对布局流程做了优化，为此废弃了`BgStyle`类的原有构造方法

	// 废弃
	public BgStyle()
	public BgStyle(int decorate)

采用新构造方法，增加参数`org.w3c.dom.Element`

	public BgStyle(Element element)
	public BgStyle(Element element, int decorate)

	