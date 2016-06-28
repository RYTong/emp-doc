# 内存管理
<!-- toc -->

## 内存泄露

错误示例
``` objective-c
	@property (nonatomic,retain) NSMutableDictionary * downloadList;

	self.downloadList = [[NSMutableDictionary alloc] initWithCapacity:0];
```
正确示例:
``` objective-c
    @property (nonatomic,retain) NSMutableDictionary * downloadList;
	 self.downloadList = [NSMutableDictionary dictionaryWithCapacity:0];
	- (void)dealloc{
	    self.downloadList = nil;// 建议使用这种释放方式
	    [super dealloc];
	}
```
规范1:
全局变量需要声明get/set方法. 并通过get,set方法来操作变量值.
错误示例:
``` objective-c
    NSMutableDictionary * inDownLoadList_;
    inDownLoadList_ = [[NSMutableDictionary alloc] initWithCapacity:0];

	- (void)dealloc{
	    if (inDownLoadList_) {// 这种释放也是正确的, 但是使用self.inDownLoadList = nil;代码更简洁.
	        [inDownLoadList_ release];
	    }

	    [super dealloc];
	}
```

正确示例:
``` objective-c
	@interface FilesUpdateVerFour()
	@property (nonatomic, retain) NSMutableDictionary *inDownLoadList;// 声明get/set方法
	@end

	@implementation FilesUpdateVerFour{
	    //记录是否为更新列表中的资源
	    NSMutableDictionary * inDownLoadList_;//声明变量

	}
	@synthesize inDownLoadList = inDownLoadList_;// 实现get/set方法

	-(void)test{
	    self.inDownLoadList = [NSMutableDictionary dictionaryWithCapacity:0];// 初始化变量
	    [self.inDownLoadList setObject:<#(nullable id)#> forKeyedSubscript:<#(nonnull id<NSCopying>)#>]; // 使用成员变量

	}

	- (void)dealloc{
	    self.inDownLoadList = nil;
	    [super dealloc];
	}
	@end   
```
