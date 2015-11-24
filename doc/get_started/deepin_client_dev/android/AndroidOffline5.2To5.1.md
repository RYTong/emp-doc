# Android EMP5.2离线模块移植到5.1的解决方案

由于Android EMP5.2版本相较于5.1版本进行了较大规模的重构，很多类和方法挪动了位置，更改了名称，因此5.2版本的离线模块无法直接移植到5.1代码上，需要进行一些改动。

## 替换同功能类和方法

首先是将5.2改变了位置或者名称的类和方法，用5.1中同样功能的类和方法代替，具体对应关系如下表所示。

|**5.2** | **5.1** |  
| ------------- |:-------------:| -----:|
| *类* | *类* |
| com.rytong.emp.tool.Utils |com.rytong.tools.utils.Utils |
| com.rytong.emp.net.HttpManager | com.rytong.tools.httpconnect.HttpManager |
| com.rytong.emp.security.AESCipher | com.rytong.tools.crypto.AESCipher |  
| com.rytong.emp.security.Base64 | com.rytong.tools.crypto.Base64 |  
| *方法* | *方法* |  
| com.rytong.emp.tool.Utils.isEmpty(String) | android.text.TextUtils.isEmpty(String) |  
| com.rytong.emp.tool.Utils.printLog(String1, String2) |  com.rytong.emp.tool.Utils.printOutToConsole(String2) |  
| com.rytong.emp.security.HMac.getSHA1(byte[]) |  com.rytong.emp.tool.Utils.getSHA1(byte[]) |
| com.rytong.emp.data.FileManager.saveFileByEncrypt(String) |  com.rytong.tools.utils.Utils.saveFileByEncrypt(String) |
| com.rytong.emp.data.FileManager.saveFile(String) |  com.rytong.tools.utils.Utils.saveFile(String) |
| com.rytong.emp.data.FileManager.readFileByDecrypt(String) |   com.rytong.tools.utils.Utils.readFileByDecrypt(String) |
| com.rytong.emp.data.FileManager.readFile(String) |  com.rytong.tools.utils.Utils.readFile(String) |
| com.rytong.emp.data.FileManager.deleteFile(String) |  com.rytong.tools.utils.Utils.deleteDirectory(File) |
| com.rytong.emp.data.FileManager.readAssetFileToStr(Activity, String) |  com.rytong.tools.utils.Utils.getFromAssetForString(Activity, String) |
| com.rytong.emp.data.AndroidResource.OFFSTORED | com.rytong.tools.ui.BaseView.OFFSTORED  |  

## 改造5.2离线模块代码

然后将5.2离线模块中，无法直接用5.1的类和方法替换的代码，做改造处理

### EMPConfig类

在5.2代码中，EMPConfig类的作用，就相当于5.1中的配置文件config.txt和Constant.txt。因此，凡出现EMPConfig类及其下方法的地方，用5.1中的`Utils.getConfigStringFormAsset(Activity, String)`和`Utils.getConstantStringFromAsset(String)`方法改造即可。对应关系如下所示。


|**5.2** | **5.1** |  
| ------------- |:-------------:| -----:|
| EmpConfig.getOfflineVersion() | Integer.parseInt(Utils.getConfigStringFormAsset(Activity, "OfflineVersion")); |
| EmpConfig.getServerUriNoPort() | Utils.getConfigStringFormAsset(Activity, "SERVER_URI_NO_PORT") | 
| EMPConfig.mOfflinePromptOptionalStart | Utils.getConstantStringFromAsset("OfflinePrompt_0_Start") |  
| EMPConfig.mOfflinePromptMustStart | Utils.getConstantStringFromAsset("OfflinePrompt_1_Start") | 

有两个方法无法直接替换，需要处理下

1.EMPConfig.isOfflinePromptOn()方法

在OffStoreDownload类中添加变量和方法：

    /** 是否提示资源更新 Constant.txt中配置    */
    private boolean isOfflinePromptON = false;

    /**
     * <p>设置资源更新时，是否给出提示信息</p>
     * Constant.txt中配置  -- OfflinePrompt_ON
     */
    private void setIsOfflinePromptON(){
        String flag = Utils.getConstantStringFromAsset("OfflinePrompt_ON");
        if (!TextUtils.isEmpty(flag) && flag.equalsIgnoreCase("true")) {
            isOfflinePromptON = true;
        }
    }
在OffStoreDownload类构造方法中调用`setIsOfflinePromptON()`，然后在使用`EMPConfig.isOfflinePromptOn()`的地方直接替换为`isOfflinePromptON`。

2.EMPConfig.setOfflineVersion(version)方法

在Utils类中添加方法：

    public static final void setConfigString(String tag, String value) {
        if (configHm_ == null) {
            initConfigStringFormAsset(activity_);
        }
        if (configHm_ != null) {
            configHm_.put(tag, value);
        }
    }
然后在使用`EMPConfig.setOfflineVersion(version)`的地方替换为`Utils.setConfigString("OfflineVersion", version)`。

**注**：`OfflineVersion`是新离线协议中增加的配置项，表示当前使用的离线协议版本。协议版本的具体定义，可参考离线下载设计文档。

###EmpRender类和EMPThreadPool类

5.2中的`EmpRender.runTask(new EMPThreadPool.Task(int))`方法，相当于5.1中`WaitDialog().addBgTask(new Task(int))`方法的作用，开启一个新的任务线程。因此可做对应替换。

| **5.2** | **5.1** |
| ------------- |:-------------:| -----:|
| EmpRender.runTask(new EMPThreadPool.Task(EMPThreadPool.PRIORITY_OFFSTORE) { |  new WaitDialog().addBgTask(new Task(0) { |
| doRun() throws Exception | run(WaitDialog dlg) throws Exception | 
| onSuccess() | onSuccess(WaitDialog dlg) |
| onFailure() | onFailure(WaitDialog dlg) |  

同时将构造函数`OffStoreDownload(Activity, EMPRender)`改为`OffStoreDownload(Activity)`。

###EMPLua类和EMPLuaFactory类

在5.2中，处理lua函数时，没有使用LuaJava，而是使用了EMP产品自己编写的lua处理机制。EMPLua类和EMPLuaFactory类就是5.2处理lua函数时用到的类，因此在5.1中，需要改造为LuaJava的处理机制。

在5.2中，以下代码段表示调用lua回调函数。

    final EMPLua empLua = EMPLuaFactory.getEMPLua(luaIndex);
    empLua.callback(callIndex, new Object[] { Boolean.valueOf(result) });
在5.1中需要改造为

    Object[] params = new Object[3]
    try {
        if (luaFun != null && luaFun.isFunction()) {
            params[0] = result;
            luaFun.call(params);
        }
    } catch (LuaException e) {
        Utils.printException(e);
    }
同时，需要将调用回调函数的方法中的参数`final int luaIndex, final int callIndex`改为`final LuaObject luaFun`。

###CryptoHttpManager类

5.2中的CryptoHttpManager类是将body加密与http请求封装在一起。  
将5.2代码中的

    CryptoHttpManager hm = new CryptoHttpManager(mActivity);
    String reply = (String) hm.sendPostRequest(uri, body.toString(), true, HttpManager.MIME_JSON, null);
改造为

    HttpManager hm = new HttpManager(mActivity);
    String buf = body.toString();
    if (ClientHello.mTlsVersion <= ClientHello.TLS_VERSION_1_3) {
        // 离线下载走加解密
        buf = AESCipher.encrypt(buf, AESCipher.clientKey_, AESCipher.clientIv_);
    }
    String reply = (String) hm.sendPostRequest(uri, buf,  HttpManager.MIME_JSON, null);

###FileManager.FILEROOT变量

5.2中的`FileManager.FILEROOT`变量就是5.1中的`OffStoreDownload.FILEROOT`变量

在5.2的OffStoreDownload类中增加变量和方法：

    /** <p>离线资源存储根目录 。</p>*/
    static public String FILEROOT;
    /** <p>file.write目录。</p> */
    final static public String WRITEROOT = "write-resources/";
    /** <p>开发模式下，下载资源文件暂存。</p>  */
    final static public String TEMPROOT = "temp-resources/"; 

    /**
     * <p>
     * 设置离线资源存储根目录。
     * </p>
     */
    private void setRootPath() {
        FILEROOT = Utils.getActivity().getFilesDir().getPath().concat("/");
    }
在OffStoreDownload类构造方法中调用`setRootPath()`，然后在使用`FileManager.FILEROOT`的地方直接替换为`OffStoreDownload.FILEROOT`。

###Utils.getPlatform()方法

5.2中通过`Utils.getPlatform()`方法获取手机平台类型，在5.1中可以改造为：

    // 手机平台
    String platform = Utils.getConfigStringFormAsset(Activity, "offstoreplatform");

###Utils.getScreenResolution(Activity)方法

5.2中通过`Utils.getScreenResolution(Activity)`方法获取手机平台类型，在5.1中可以改造为：

    // 分辨率
    DisplayMetrics dm = new DisplayMetrics();
    mActivity.getWindowManager().getDefaultDisplay().getMetrics(dm);
    String screenResolution = String.valueOf(dm.widthPixels) + "*" + String.valueOf(dm.heightPixels);

##改造5.1代码

接着改造5.1代码，以应用新的离线功能。将源代码中引用旧离线模块OffStoreDownLoad类的地方，改成引用新的5.2离线模块OffStoreDownload类。

###Utils类

将使用`BaseView.OFFSTORED.checkOffLineFile_ZipForEach()`方法和`BaseView.OFFSTORED.checkOffLineFile_Normal()`方法的地方，修改为`OffStoreUtils.checkOffLineFile_ZipForEach()`方法和`OffStoreUtils.checkOfflineFile_Normal()`方法。

###PackageManagerAndroid类

在PackageManagerAndroid类中添加变量
    
    /** 记录客户端上次运行时版本号 */
    public static final String CLIENT_LASTVERSION = "client_lastversion";

###BaseView类

1.将`OffStoreDB.closeDB()`方法改为`OffStoreDB.onDestory()`方法。

2.修改`initOffline()`方法。

    public void initOffline() {
        
        // 初始化离线存储功能模块
        OFFSTORED = new OffStoreDownload(this);
        
        if (PackageManagerAndroid.ANDROIDDB != null) {
            //判断是否需要处理预置资源， 上次未成功处理。
            String lastVersion = PackageManagerAndroid.ANDROIDDB.get(PackageManagerAndroid.CLIENT_LASTVERSION);
            String currentVersion = Utils.getVersionName(this);
            // 1.上次运行的版本号不为空，并且与当前不一致-- 客户端版本升级 2.上次运行的版本号为空 -- 第一次运行
            if (TextUtils.isEmpty(lastVersion) || (!TextUtils.isEmpty(lastVersion) && !currentVersion.equals(lastVersion))) {
                // 处理预置离线资源
                OFFSTORED.preResourcesHandle();
            }
            // 存储当前的版本号
            PackageManagerAndroid.ANDROIDDB.save(PackageManagerAndroid.CLIENT_LASTVERSION, currentVersion);
        }
    }

###LuaUtility类

改造`tls()`中离线更新的流程。修改`initAfterTls()`方法。

    private void initAfterTls() {

        //离线资源更新
        String flag = Utils.getConfigStringFormAsset(Utils.getActivity(), "isUpdateOfflineRes");
        if(!TextUtils.isEmpty(flag) && flag.equalsIgnoreCase("true")){
            BaseView.OFFSTORED.startOfflineUpate(null);
        }
    }
