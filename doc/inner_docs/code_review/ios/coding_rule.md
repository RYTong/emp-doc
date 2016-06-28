# 编码规则
<!-- toc -->

## 清晰易读的代码
清晰易读的代码对于其他开发人员阅读代码和减少后期的维护成本是十分重要的.
1. 良好的封装可以减少代码量,并且可以灵活的组装函数的功能以满足不同的需求.
2. 良好的封装还可以减少测试的工作量.并提高测试用例的代码覆盖率.

``` objective-c
	   ResponseServerModel * responseServerModel = [responseServerModelDic_ objectForKey:appName]; // ①
	    // 通过path取得该资源对象
	    NSString * key = [path lastPathComponent];
	    if ([responseServerModel.h5DownloadList objectForKey:path] != nil) {
	        key = path;
	    }
	    ResourceModel * resourceModel = [[[responseServerModelDic_ objectForKey:appName] downloadList] objectForKey:key]; // ②
	    if (resourceModel == nil) {
	        resourceModel = [[[responseServerModelDic_ objectForKey:appName] downloadList] objectForKey:path];// ③
	        key = path;
	    }
```
上面代码①②③行出现了多次的`[responseServerModelDic_ objectForKey:appName]`. 并且在①中已经将其值使用`responseServerModel`表示了. 在后面的操作中完全可以使用`responseServerModel`来表达`[responseServerModelDic_ objectForKey:appName]`.

更正后代码如下:

``` objective-c
    ResponseServerModel * responseServerModel = [responseServerModelDic_ objectForKey:appName];// ①
    // 通过path取得该资源对象
    NSString * key = [path lastPathComponent];④
    if ([responseServerModel.h5DownloadList objectForKey:path] != nil) {//⑤
        key = path;
    }
    ResourceModel * resourceModel = [[responseServerModel downloadList] objectForKey:key];// ②
    if (resourceModel == nil) {
        resourceModel = [[responseServerModel downloadList] objectForKey:path];// ③
        key = path;
    }
```
  ④,⑤两行代码对key进行了重复的复制,此处可以修改为:

``` objective-c
  NSString *_key = nil;
  ResourceModel *resourceModelH5 = [responseModel.h5DownloadList objectForKey:path];
  if (resourceModelH5 != nil) {
		_key = path;
  }else{
      _key = [path lastPathComponent];;
  }
```
 第二:
 	关于此段逻辑中使用到的path和key,完全没有注释来说明其来历和用途.
 	从代码逻辑可以推断出downloadlist和h5downloadlist中的key,既可能是key也可能是path. 也就是说同一个字典中的key存在不同的含义. 这种情况在编码中要尽量避免.

 第三:
 	此段代码在`- (void)offlineFileUpdateSuccess:(NSString *)path withType:(RYTStyleFileDealResult)type persistent:(BOOL)persistent`和`- (void)offlineFileUpdateFail:(NSString *)path withType:(RYTStyleFileDealResult)type persistent:(BOOL)persistent`中都有出现,而且一模一样. 相同或相似的功能或逻辑在代码中出现2次或两次以上,就要考虑将此部分功能封装.并明确其功能的作用.
对上面的代码进行封装后如下:
``` objective-c
	- (void)getResourceMode:(ResourceModel **)resourceModel key:(NSString **)key fromResponseModel:(ResponseServerModel *)responseModel path:(NSString *)path{
	    // 通过path取得该资源对象
	    ResourceModel *resourceModelH5 = [responseModel.h5DownloadList objectForKey:path];
	    NSString *_key = nil;
	    if (resourceModelH5 != nil) {
	        _key = path;
	    }else{
	        _key = [path lastPathComponent];;
	    }
	    ResourceModel *_resourceModel = [[responseModel downloadList] objectForKey:_key];
	    if (_resourceModel == nil) {
	        _resourceModel = [[responseModel downloadList] objectForKey:path];
	        _key = path;
	    }
	    *key = _key;
	    *resourceModel = _resourceModel;
	}
```
调用: 在`offlineFileUpdateSuccess:`和`offlineFileUpdateFail:`方法中调用如下代码
``` objective-c
	 NSString *key = nil;
    ResourceModel *resourceModel = nil;
    [self getResourceMode:&resourceModel key:&key fromResponseModel:responseServerModel path:path];
	```
