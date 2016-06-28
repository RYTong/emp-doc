# MDAP 文档--iOS
##配置MDAP

参考文档 [《功能扩展之统计分析使用指南》](./iOS_MDAP.md)

		
##MDAP使用
1.AppDelegate.h遵守协议RYTLocationManagerDelegate，<br/>
声明定位变量RYTLocationManager *locManager;<br/>
2.AppDelegate.m通过调用UserBehaviourAnalyseLaunching类，启动MDAP采集功能。

代码：
	
	UserBehaviourAnalyseLaunching *launch = [UserBehaviourAnalyseLaunching sharedUserBehaviourAnalyseLaunching];
    //检查是否为首次运行
    BOOL first = [launch checkAppFirstLaunch];
    if (first == YES) {
        //设置info信息，这些信息会在应用程序第一次启动时存入数据库。后续客户端可以通过接口进行修改,如果客户端不进行设置，则会使用默认值
        UserInformationModel *info = [[UserInformationModel alloc] initUserInformation];//获取初始信息
        [info storeInformation];//存入数据库
        [info release];
    }

在AppDelegate.h中声明了定位变量，采集位置信息
 
 	//设置用户相关信息,注册定位方法
    SessionControl *sc = [SessionControl sharedSessionControl];
    //这里对直接从lua接受位置参数做了兼容，如果lua传进了位置信息，则直接将其存入数据库；否则会执行	下面注册的定位方法，如果不存在改方法，则定位失败
    locManager = [[RYTLocationManager alloc] init];
    locManager.delegate = self;
    sc.delegate = self;
    sc.locSelector = @selector(getCurrentLocation);//对当前位置进行定位

	//对当前位置进行定位
	- (void) getCurrentLocation {
    [locManager setLocationDesiredAccuracy:kCLLocationAccuracyBest];
    [locManager setLocationDistanceFilter:kCLDistanceFilterNone];
    [locManager startUpdateLocation];
	}
	//RYTLocationManagerDelegate method定位功能代理方法
	//定位功能回调函数
	- (void) newLocationSuccess:(CLLocation *)newlocation manager:(RYTLocationManager *)manager {
    SessionControl *sc = [SessionControl sharedSessionControl];
    [sc setLocationByLatitude:newlocation.coordinate.latitude longitude:newlocation.coordinate.longitude andAccuracy:kCLLocationAccuracyBest];
    [locManager stopUpdateLocation];
	}

	- (void) newLocationFail:(NSError *)error manager:(RYTLocationManager *)manager 	{
    SessionControl *sc = [SessionControl sharedSessionControl];
    ZNLog(@"定位失败");
    if (sc.location == nil) {
        sc.location = @"";
    }
    [locManager stopUpdateLocation];
	}
	
设置统计数据相关delegate,实现各种delegate与其他静态库解耦

    [launch setDelegateForOtherLibs];//此处设置的代理，作用是记录程序退出session结束时间

设置统计数据发送相关参数：数据发送方法、加密方法、应用程序apikey

	[launch setDataSendingParameters:self andSendSelector:@selector(sendUserBehaviourAnalyseData:) andEncryptMethod:[[UserBehaviouAnalyseConfig sharedUserBehaviouAnalyseConfig] encrptMethod] andApiKey:[[UserBehaviouAnalyseConfig sharedUserBehaviouAnalyseConfig] apiKey]];
	其中sendUserBehaviourAnalyseData:此方法是用来发送给服务器数据的方法
	[[UserBehaviouAnalyseConfig sharedUserBehaviouAnalyseConfig] encrptMethod]是加密方式
	[[UserBehaviouAnalyseConfig sharedUserBehaviouAnalyseConfig] apiKey]是程序设置的apiKey,apiKey是应用唯一标识，通过管理端添加应用时生成
	
设置程序异常处理监听，收集程序的异常信息
	
	[[RYTUncaughtExceptionHandler sharedUncaughtExceptionHandler] setExceptionHandler];
    [[RYTUncaughtExceptionHandler sharedUncaughtExceptionHandler] setDelegate:[RYTUncaughtExceptionTrack sharedUncaughtExceptionTrack]];
	
准备统计,每隔设置的发送时间，会向服务器发送一条收集的信息

    [launch prepareToLaunchUserBehaviourAnalyse];

3.发送数据接口，对应InformationMange.h中声明的函数指针sendDataSelector<br/>
发送数据前，判断网络状态。<br/>

	 - (void) sendUserBehaviourAnalyseData:(NSMutableData *)bodyData {
    //在统计数据发送前，需要判断当前的网络状态
    Reachability *netReach = [Reachability reachabilityForInternetConnection];
    if ([netReach currentReachabilityStatus] == NotReachable) {
        ZNLog(@"当前无网，无法发送统计数据");
        return;
    }
    //采集服务器地址
    NSString *analyseDataServerUrl = [[UserBehaviouAnalyseConfig sharedUserBehaviouAnalyseConfig] serverUrl];
    //采集服务器地址加路径拼接而成
    NSString *analyseDataRequestUrl = [[UserBehaviouAnalyseConfig sharedUserBehaviouAnalyseConfig] requestUrl];
    if (analyseDataRequestUrl == nil || analyseDataServerUrl == nil) {
        ZNLog(@"统计数据发送地址不存在");
        return;
    }
    //依照统计数据使用的不同的加密方式，选择使用不同的数据发送方法
    //移位加密：使用系统自带api
    ZNLog(@"指定采用移位加密方式");
    //根据要求需要在ruquest请求中添加appName和平台标示参数
    NSString *appName = [[UserBehaviouAnalyseConfig sharedUserBehaviouAnalyseConfig] tackAppName];
    NSString *os = [[RYTConfig sharedRYTConfig] OS];
    if (appName == nil || os == nil) {
        ZNLog(@"request 请求中缺少appName或os参数");
        return;
    }
    NSString *requestStr = [NSString stringWithFormat:@"%@/%@?o=%@",analyseDataServerUrl,analyseDataRequestUrl,os];
    ZNLog(@"request str.....%@",requestStr);
    //此处用系统NSURLConnection方式异步发送数据，可用其他方法，如：emp代码的RYTHttpConnection
    NSURL *requestUrl = [NSURL URLWithString:requestStr];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:requestUrl];
    [request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:bodyData];
    if (analyseData) {
        [analyseData setLength:0];
    } else {
        analyseData = [[NSMutableData alloc] initWithCapacity:0];
    }
    //异步发送给采集服务器数据
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [connection release];
    [request release];
	}

代码示例采用系统NSURLConnection发送数据，实现其代理。<br/>
	
	- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [analyseData setLength:0];
	}
	
接收数据

	- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    ZNLog(@"数据接收中。。。。");
    [analyseData appendData:data];
	}

其中analyseData是NSMutableData类型，用于存放服务器返回的数据。<br/>
接收数据完成时要通过方法startParseResponseData:验证返回的数据的完整及解析响应数据

	- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    ZNLog(@"数据接收完成");
    [[InformationMange shareInformationManager] startParseResponseData:analyseData];
    NSString *responseStr = [[NSString alloc] initWithData:analyseData encoding:NSUTF8StringEncoding];
    ZNLog(@"response str ==== %@",responseStr);
    [responseStr release];
    [analyseData setLength:0];
	}

	- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    ZNLog(@"数据接收失败");
    [analyseData setLength:0];
    if (error) {
        ZNLog(@"analyse request error by original method=%@",error);
    }
	}
