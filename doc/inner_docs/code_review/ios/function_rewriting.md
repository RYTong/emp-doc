# 方法重写
<!-- toc -->

## 方法重写的注意事项
1. 子类重写的方法不能丢失父类方法所含有的功能.有明确的功能说明除外.
2. 父类的函数要有通用性.不能使用子类或其他不在同一层级的子类的属性和方法.
3. 强制类型转换必须要合理并保证安全.
4. 类似功能的逻辑要保持一致.

## 子类不能丢失父类的功能

``` objective-c
父类的方法
// name：scribe_line.png  login/images/table1.png
- (UIImage *)dataFromImageName:(NSString *)name{
    if (name) {
        // 开发模式
        if ([[EMPConfig sharedEMPConfig] appTest]){
          // 这个逻辑是错误的，应该先从离线资源中读取， 读不到时再通过开发模式读取。
            UIImage *image = nil;
            image = [[FileManager sharedFileManager] dataImageWithSHA1AndEncrypt:name];
            if (image == nil && [[EMPConfig sharedEMPConfig] loadImageFile]){
                NSData *_imageData = [[FileManager sharedFileManager] loadRemoteFile:name];
                image = [UIImage imageWithData:_imageData];
            }
            return image;
        }else{
            // 生产模式
            // 确保更新 单个资源下载
            if ([[FilesUpdateVerFir sharedFilesUpdateVerFir] isEnsureDownload:name]) {
                [[FilesUpdateVerFir sharedFilesUpdateVerFir] performSelectorOnMainThread:@selector(ensureDownloadResource:) withObject:[[FilesUpdateVerFir sharedFilesUpdateVerFir] isEnsureDownload:name] waitUntilDone:YES];
                UIImage *image = [UIImage imageWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"ENSUREDOWNLOAD"]];
                return image;
            }
            else{
                // 非确保更新，读取文件
                UIImage *image = nil;
                image = [[FileManager sharedFileManager] dataImageWithSHA1AndEncrypt:name];
                return image;
            }
        }
    }
    return nil;
}

```
``` objective-c
子类的方法
- (UIImage *)dataFromImageName:(NSString *)name{
    if (name) {
        id imageDate = [[FilesUpdate sharedFilesUpdate] readResourceFile:name isH5:NO];
        if (imageDate) {
            if ([imageDate isKindOfClass:[UIImage class]]) {
                return imageDate;
            }else{
                return [UIImage imageWithData:imageDate];
            }
        }
    }
    return nil;
}
```
从代码上看子类中丢失了apptest的功能.

## 父类的函数要有通用性

``` objective-c
FileManager 类方法
- (ResourceStore *)getResourceInfoWithResourceModel:(ResourceModel *)resourceModel{
    NSString * appName = ((ResourceModelVerThird *)resourceModel).appName;
    ResourceStore *resourceStore = [[ResourceStore alloc] init];
    resourceStore.name = resourceModel.fileName;
    resourceStore.rev = resourceModel.rev;
    resourceStore.comment = resourceModel.comment;
    resourceStore.encrypt = [NSNumber numberWithBool:resourceModel.encrypt];
    resourceStore.path = resourceModel.path;
    resourceStore.desc = nil;
    resourceStore.mineType = resourceModel.mineType;
    resourceStore.keyName = [NSString stringWithFormat:@"%@:%@",resourceModel.fileName,appName];
    return [resourceStore autorelease];
}
```
**问题:**  
1. 函数参数数据类型为`ResourceModel`. 但是在方法中强转成了 `ResourceModelVerThird`. 并且调用了只有`ResourceModelVerThird`才有的属性`appName`.  

**要求:**  
1. 基类中的函数必须要有通用性,不能使用子类中特有的属性或方法.  
对象的强转要保证类型转换时是安全的. 如本例中的`((ResourceModelVerThird *)resourceModel).appName`.
如果`resourceModel`不是`ResourceModelVerThird`类型.会导致程序崩溃.    
既然我们使用了子类化的方式来处理各个版本的差异.就要充分利用这个优势.见差异的内容通过函数重载的方式做到子类中.

2. 强制类型转换必须要合理并保证安全.

## 类似功能的逻辑要保持一致
比如下面两端代码:
方法一:
 `- (UIImage *)dataFromImageName:(NSString *)name`方法(代码在上面的同名方法).

方法二:
``` objective-c
- (NSData *)dataFromFileName:(NSString *)name {
    if ([[FilesUpdateVerFir sharedFilesUpdateVerFir] isEnsureDownload:name]) {
        [[FilesUpdateVerFir sharedFilesUpdateVerFir] performSelectorOnMainThread:@selector(ensureDownloadResource:) withObject:[[FilesUpdateVerFir sharedFilesUpdateVerFir] isEnsureDownload:name] waitUntilDone:YES];
        NSData *data = [NSData dataWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"ENSUREDOWNLOAD"]];
        return data;
    }else{
        // 非确保更新，读取文件
        return [self dataFileWithSHA1AndEncrypt:name];
    }
}
```
分析两端代码:  
方法一:  
①从离线资源中查找数据,  
②当数据找不到时会通过测试模式下载数据.  
方法二:  
①从离线资源中查找数据,  

问题:  
1. 上面的代码来自同一个类`FileManager`,方法一的功能是获取图片数据,方法二的功能是获取文件数据.这两个方法的功能是类似的.
但是从方法的功能实现看,这两个方法的使用方式是不同的.
对于方法一,只需要调用`- (UIImage *)dataFromImageName:(NSString *)name`方法就可以完成数据的获取,包括开发模式下载数据.但是对于方法二`- (NSData *)dataFromFileName:(NSString *)name`,要实现开发模式下载的功能,需要额外的处理.
2. 缺少注释说明,这两个方法输入没有看起内部实现的话,也不会找到上面的区别.这样的接口使用起来很不方便,而且容易出现问题.
