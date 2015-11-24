//
//  ChannelRequest.m
//  CEB
//
//  Created by linjitao on 15-2-10.
//
//

#import "ChannelRequest.h"
#import "LPHTTPConnection.h"
#import "Channel.h"
#import "LPDataBaseManage.h"
#import "ConfigManager.h"
#import "TaskManager.h"
#import "HTTPManager.h"
#import "LPHMac.h"
#import "LPBase64.h"
@implementation ChannelRequest
- (void)loadChannelUseEMP:(Channel *)channel{
    NSString *channelId = channel.id_;
    NSString *page = @"1";//[NSString stringWithFormat:@"%d",paged<0 ? 1 : paged];
    NSString *perPage = [NSString stringWithFormat:@"%d", PER_CHANNEL_PAGE];
    
    //Begin Added by zhao.shaokang
    //当为票e通时，添加参数
    BOOL isNeedAddPara = NO;
    NSString *mobileNo = nil;
    NSString *deMobileNo = nil;
    NSString *activeStatus = nil;
    if ([channelId isEqualToString:@"ebank_pet_i"]) {
        //检查数据库中的mobileNo和is_ative的值
        LPDataBaseManage *dataBase = APPLICATION.dataBase_;
        if (dataBase) {
            mobileNo = [dataBase getValueWithKey:MOBILE_NO];
            //转换成明文
            if (mobileNo) {
                if (mobileNo.length > 0) {
                    deMobileNo = [[APPLICATION desDecryptMobileNumber:mobileNo] retain];
                }
            }
            
            activeStatus = [dataBase getValueWithKey:ACTIVE_STATUS];
            //判断是否存在且不为空
            if(mobileNo.length > 0 && activeStatus.length > 0){
                isNeedAddPara = YES;
            }
        }
    }
    
    NSString *rang = [NSString stringWithFormat:@"%@%@p=%@&s=%@&id=%@",
                      SERVER_URL,
                      COLLECTION_URL,
                      page,
                      perPage,
                      channelId
                      ];
    if (isNeedAddPara)
    {
        rang = [rang stringByAppendingFormat:@"&mobileNo=%@&is_active=%@",deMobileNo,activeStatus];
    }
    if (deMobileNo)
    {
        [deMobileNo release];
        deMobileNo = nil;
    }
    //End
    
    /* 静态库 */
    NSMutableDictionary *_dic = [[[NSMutableDictionary alloc] init] autorelease];
    NSString *cookie = [APPLICATION.userManager_ getCookie];
    
    if (cookie) {
        //dic_ = [NSDictionary dictionaryWithObject:cookie forKey:TAG_PROPERTY_COOKIE];
        [_dic setObject:cookie forKey:TAG_PROPERTY_COOKIE];
    }
    
    /////////////////////////////////////////////////////////
    LPHTTPConnection *connection = [[HTTPManager sharedHTTPManager] getHTTPConnection:rang cachePolicy:0 timeoutInterval:NETWORK_TIME_OUT method:@"GET" header:_dic body:nil];
    connection.delegate = self;
    
    
    [[TaskManager sharedTaskManager] addTaskToAsynchronousArray:@"ChannelList" httpConnection:connection showWaitDialogFS:NO showWaitDialogHS:YES noCancel:YES];
}
- (void) startConnection:(int)paged params:(NSArray *)params channel:(Channel *) channel{
    {
        if (channel==nil)
            return;
        
//        isRequestFromChannel_ = YES;
        
        //Begin Changed by zhao.shaokang
        //currentChannel_ = channel;
        Channel *currentChannel_ = channel;
        //End
        
        
        NSString *page = [NSString stringWithFormat:@"%d",paged<0 ? 1 : paged];
        
        /////////////////////// Set up the url for getting POI's list ///////////////////////////////////
        //
        //
        // We need replace these in the future, add a function what get current location.
        BoundingBox *currentBoundingBox = [APPLICATION getCurrentMapBoundingBox];
        int maxlat = currentBoundingBox.maxLat_;
        int maxlng = currentBoundingBox.maxLon_;
        int minlat = currentBoundingBox.minLat_;
        int minlng = currentBoundingBox.minLon_;
        
        /////////////////////////////////////////////////////////////////////////
        NSString *range = [NSString stringWithFormat:@"maxlat=%d&maxlong=%d&minlat=%d&minlong=%d", maxlat, maxlng, minlat, minlng];
        NSString *url;
        NSData *body;
        
        
        if ([params count] > 0) {
            NSString* queryStr = @"";
            
            for (int i=0; i<[params count]; i++) {
                NSDictionary *dic = [params objectAtIndex:i];
                NSString *str = [NSString stringWithFormat:@"%@=%@", [[dic allKeys] objectAtIndex:0], [LPURICode escapeURIComponent:[[dic allValues] objectAtIndex:0]]];
                queryStr = [queryStr stringByAppendingFormat:@"&%@", str];
                if ([channel.id_ isEqualToString:@"ewm"]) {
                    LPDataBaseManage *dataBase = APPLICATION.dataBase_;
                    NSString *activeStatus = @"";
                    NSString *mobileNo = @"";
                    if (dataBase) {
                        activeStatus = [dataBase getValueWithKey:ACTIVE_STATUS];
                        mobileNo = [dataBase getValueWithKey:MOBILE_NO];
                        //转换成明文
                        if (mobileNo) {
                            if (mobileNo.length > 0) {
                                mobileNo = [[APPLICATION desDecryptMobileNumber:mobileNo] retain];
                            }
                        }
                    }
                    NSString *loginSt = [dic objectForKey:@"login"];
                    if (loginSt != nil) {
                        queryStr = [queryStr stringByAppendingFormat:@"-isactive=%@-mobileNo=%@", activeStatus, mobileNo];
                    }
                }
                
                
                
                // channel_.id_=order 需要传两个参数  by lq 4-15
                else{
                    
                    LPDataBaseManage *dataBase = APPLICATION.dataBase_;
                    NSString *activeStatus = @"";
                    NSString *mobileNo = @"";
                    if (dataBase) {
                        activeStatus = [dataBase getValueWithKey:ACTIVE_STATUS];
                        mobileNo = [dataBase getValueWithKey:MOBILE_NO];
                        //转换成明文
                        if (mobileNo) {
                            if (mobileNo.length > 0) {
                                mobileNo = [[APPLICATION desDecryptMobileNumber:mobileNo] retain];
                            }
                        }
                    }
                    NSString *loginSt = [dic objectForKey:@"login"];
                    if (loginSt != nil) {
                        queryStr = [queryStr stringByAppendingFormat:@"-isactive=%@-mobileNo=%@", activeStatus, mobileNo];
                    }
                    
                    
                }
                // end
                
            }
            
            NSMutableString *finalStr = [NSMutableString stringWithString:queryStr];
            [finalStr deleteCharactersInRange:NSMakeRange(0, 1)];
            
            
            NSString *_body = nil;
            if (currentChannel_.channelUrl_ != nil && [currentChannel_.channelUrl_ length] > 0) {
                
                NSArray *array = [currentChannel_.channelUrl_ componentsSeparatedByString:@"?"];
                NSString *_url = (NSString *)[array objectAtIndex:0];
                if ([_url rangeOfString:@"http://"].length <= 0)
                    url = [NSString stringWithFormat:@"%@%@", @"http://", _url];
                else
                    url = _url;
                if ([currentChannel_.shortcut_ isEqualToString:@"ewm"]) {
                    url = [NSString stringWithFormat:@"%@%@",
                           SERVER_URL,
                           POI_LIST_URL];
                    
                    _body = [NSString stringWithFormat:@"id=%@&%@&%@&quickmark=%@&querystr=%@&p=%@",
                             channel.id_,
                             range,
                             POI_RUL_PORTION,
                             [LPURICode escapeURIComponent:APPLICATION.tabBarViewController_.ewmValue],
                             [LPURICode escapeURIComponent:finalStr],
                             page];
                    //                NSLog(@"body body 66666666666 %@",_body);
                    
                } else {
                    _body = [NSString stringWithFormat:@"%@&%@&%@&querystr=%@&p=%@",
                             (NSString *)[array objectAtIndex:1],
                             range,
                             POI_RUL_PORTION,
                             [LPURICode escapeURIComponent:finalStr],
                             page];
                }
                
                
            } else {
                url = [NSString stringWithFormat:@"%@%@",
                       SERVER_URL,
                       POI_LIST_URL];
                
                _body = [NSString stringWithFormat:@"id=%@&%@&%@&querystr=%@&p=%@",
                         channel.id_,
                         range,
                         POI_RUL_PORTION,
                         [LPURICode escapeURIComponent:finalStr],
                         page];
            }
#ifdef SECURITY
            body = [APPLICATION AES256EncyrptBody:[_body dataUsingEncoding:NSUTF8StringEncoding]];
            
#else
            body = [_body dataUsingEncoding:NSUTF8StringEncoding];
#endif
            
            
        } else {
            
            NSString *_body = nil;
            if (currentChannel_.channelUrl_ != nil && [currentChannel_.channelUrl_ length] > 0) {
                
                NSArray *array = [currentChannel_.channelUrl_ componentsSeparatedByString:@"?"];
                NSString *_url = (NSString *)[array objectAtIndex:0];
                if ([_url rangeOfString:@"http://"].length <= 0)
                    url = [NSString stringWithFormat:@"%@/%@", SERVER_URL, _url];
                else
                    url = _url;
                
                
                _body = [NSString stringWithFormat:@"%@&%@&%@&p=%@",
                         (NSString *)[array objectAtIndex:1],
                         range,
                         POI_RUL_PORTION,
                         page];
                
            }
            else
            {
                //Begin Added by zhao.shaokang
                //在点击手机银行时发送激活状态
                //if ([channel.id_ isEqualToString:@"sjyh"])
                
                //未登录的页面都发送激活状态 changed by su.chuyang
                if(!APPLICATION.userManager_.userLogin_.isLoginSucceed)
                    //end
                {
                    //检查数据库中的mobileNo和is_ative的值
                    LPDataBaseManage *dataBase = APPLICATION.dataBase_;
                    if (dataBase)
                    {
                        NSString *mobileNo = [dataBase getValueWithKey:MOBILE_NO];
                        NSString *deMobileNo = nil;
                        if (mobileNo)
                        {
                            if (mobileNo.length > 0)
                            {
                                deMobileNo = [[APPLICATION desDecryptMobileNumber:mobileNo] retain];
                            }
                        }
                        NSString *activeStatus = [dataBase getValueWithKey:ACTIVE_STATUS];
                        //若不存在，插入空值
                        //if (deMobileNo == nil || activeStatus == nil) {
                        if (mobileNo == nil && activeStatus == nil)
                        {
                            [dataBase insertDataToBuffer:MOBILE_NO value:@""];
                            [dataBase insertDataToBuffer:ACTIVE_STATUS value:@""];
                            
                            url = [NSString stringWithFormat:@"%@%@",
                                   SERVER_URL,
                                   POI_LIST_URL];
                        }
                        //存在且值不为空，拼接url
                        else if(deMobileNo.length > 0 && activeStatus.length > 0)
                        {
                            url = [NSString stringWithFormat:@"%@%@%@=%@&%@=%@",
                                   SERVER_URL, POI_LIST_URL, MOBILE_NO,deMobileNo,ACTIVE_STATUS,activeStatus];
                        }
                        else
                        {
                            url = [NSString stringWithFormat:@"%@%@",
                                   SERVER_URL,
                                   POI_LIST_URL];
                        }
                        if (deMobileNo != nil)
                        {
                            [deMobileNo release];
                            deMobileNo = nil;
                        }
                        
                    }
                    else
                    {
                        url = [NSString stringWithFormat:@"%@%@",
                               SERVER_URL,
                               POI_LIST_URL];
                    }
                    //End
                }
                else
                {
                    url = [NSString stringWithFormat:@"%@%@",
                           SERVER_URL,
                           POI_LIST_URL];
                }
                /*
                 url = [NSString stringWithFormat:@"%@%@",
                 SERVER_URL,
                 POI_LIST_URL];
                 */
                _body = [NSString stringWithFormat:@"id=%@&%@&%@&p=%@",
                         [channel.id_ stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]],//channel.id_,
                         range,
                         POI_RUL_PORTION,
                         page];
            }
            NSString * addressString = [APPLICATION macaddress];
            if(![addressString isEqualToString:@" "])
            {
                _body = [_body stringByAppendingFormat:@"&mac_add=%@",addressString];
            }
            
            //		NSLog(@"ZSKLog-------url:%@",url);
            //		NSLog(@"ZSKLog-------channelId:%@",_body);
#ifdef SECURITY
            body = [APPLICATION AES256EncyrptBody:[_body dataUsingEncoding:NSUTF8StringEncoding]];
#else
            body = [_body dataUsingEncoding:NSUTF8StringEncoding];
#endif
        }
        
//        if ([url rangeOfString:@"_s"].length > 0) {
//            isSecure_ = YES;
//        }
        /* 静态库 */
        NSMutableDictionary *_dic = [[[NSMutableDictionary alloc] init] autorelease];
        NSString *cookie = [APPLICATION.userManager_ getCookie];
        
        if (cookie) {
            //dic_ = [NSDictionary dictionaryWithObject:cookie forKey:TAG_PROPERTY_COOKIE];
            [_dic setObject:cookie forKey:TAG_PROPERTY_COOKIE];
        }
        body = [APPLICATION addSerialDada:body];
        //hmac
        if (body != nil && [TLS sharedTLS].clientHmacKey_ != nil) {
            NSData *bodyData = nil;
            if ([body isKindOfClass:[NSString class]]) {
                bodyData = [body dataUsingEncoding:NSUTF8StringEncoding];
            } else {
                bodyData = body;
            }		
            NSData *temp = [LPHMac encryptHMAC:bodyData Key:[TLS sharedTLS].clientHmacKey_ KeyMacMode:KEY_MAC_SHA1];
            NSString *hmacStr = [LPBase64 stringByEncodingData:temp];
            [_dic setObject:hmacStr forKey:@"X-EMP-Signature"];
        }    
        
        
        //if ([method isEqualToString:@"POST"]) {
        [_dic setObject:@"application/x-www-form-urlencoded" forKey:@"Content-Type"];
        
        if (body != nil && [body length] > 0)
            [_dic setObject:[NSString stringWithFormat:@"%d", [body length]] forKey:@"Content-Length"];
        else
            [_dic setObject:@"0" forKey:@"Content-Length"];
        //}
        //    NSLog(@"2222222222%@",_dic);
        //    NSLog(@"2222222222222%@",body);
        /////////////////////////////////////////////////////////
        LPHTTPConnection *connection = [[HTTPManager sharedHTTPManager] getHTTPConnection:url cachePolicy:0 timeoutInterval:NETWORK_TIME_OUT method:@"POST" header:_dic body:body];
        connection.delegate = self;
        
        [[TaskManager sharedTaskManager] addTaskToAsynchronousArray:@"POIList" httpConnection:connection showWaitDialogFS:NO showWaitDialogHS:YES noCancel:NO];
    }

}
- (void) receiveResponse:(NSURLResponse *)response{
}
- (void) failWithError:(NSError *)error{
}
- (void) doneData:(NSData *)data{
    NSLog(@"Http connection success");
    
    NSData *decryptData = [APPLICATION AES256DecyrptBody:data];
    
    NSString *content = [[NSString alloc]initWithData:decryptData encoding:NSUTF8StringEncoding];

    NSLog(@"%@",content);
    [APPLICATION loadFirstPageFormEMP:content];
    
}
- (void) cancelRequest{

}
@end
