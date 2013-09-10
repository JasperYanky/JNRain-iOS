//
//  HttpRequestCenter.m
//  JNRain
//
//  Created by Yin Qiang on 13-9-10.
//  Copyright (c) 2013年 YinQiang. All rights reserved.
//

#import "HttpRequestCenter.h"
static HttpRequestCenter *shareNetCenter = nil;


// private method
@interface HttpRequestCenter()
@end



@implementation HttpRequestCenter
@synthesize requestQueue = _requestQueue;

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark - Singleton
+(HttpRequestCenter *)shareNetCenter
{
    @synchronized(self) {
        if (shareNetCenter == nil) {
            shareNetCenter =  [[self alloc] init];
        }
    }
    return shareNetCenter;
}
+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self) {
        if (shareNetCenter == nil) {
            shareNetCenter = [super allocWithZone:zone];
            return shareNetCenter;  // assignment and return on first allocation
        }
    }
    return nil;
}
- (id)copyWithZone:(NSZone *)zone
{
    return self;
}
- (id)retain
{
    return self;
}
- (unsigned)retainCount
{
    return UINT_MAX;  //denotes an object that cannot be released
}
//http://hi.baidu.com/jis2007/item/75cccecdcadaf30a0bd93af7
- (oneway void)release
{
    //do nothing
}
- (id)autorelease
{
    return self;
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - initialization
-(id)init
{
    self = [super init];
    if (self) {
        _requestQueue = [[ASINetworkQueue alloc]init];
        _requestQueue.showAccurateProgress = YES;
        [_requestQueue go];
    }
    return self;
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - request methods

-(ASIHTTPRequest *)getDataWithSpecificUrl:(NSString *)url
                               withTarget:(id)target
                            requestSccess:(SEL)requestSccessAction
                             requestError:(SEL)requestErrorAction
{
    ASIHTTPRequest *request = [[ASIHTTPRequest alloc]initWithURL:[NSURL URLWithString:url]];
    //填入回调的函数的位置以及方法
    if (target) {
        NSValue *requestSccessValue = [NSValue value:&requestSccessAction withObjCType:@encode(SEL)];
        NSValue *requestErrorValue = [NSValue value:&requestErrorAction withObjCType:@encode(SEL)];
        NSMutableDictionary *aDic = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                                     target,TARGET,
                                     requestSccessValue,REQUEST_SCCESS,
                                     requestErrorValue,REQUEST_ERROR,
                                     nil];
        request.userInfo = aDic;
        [aDic release];
    }
    [request setDelegate:self];
    [request setShowAccurateProgress:YES];
    [request setDidFinishSelector:@selector(requestDone:)];
    [request setDidFailSelector:@selector(requestFailed:)];
    [_requestQueue addOperation:request];
    [request release];
    return request;    
}

-(ASIHTTPRequest *)postDataWithBaseUrl:(NSString *)url
                            withTarget:(id)target
                                params:(NSDictionary *)params
                          requestSccess:(SEL)requestSccessAction
                          requestError:(SEL)requestErrorAction
{
    
    
    ASIFormDataRequest *request = [[ASIFormDataRequest alloc]initWithURL:[NSURL URLWithString:url]];
    //填入回调的函数的位置以及方法
    if (target) {
        NSValue *requestSccessValue = [NSValue value:&requestSccessAction withObjCType:@encode(SEL)];
        NSValue *requestErrorValue = [NSValue value:&requestErrorAction withObjCType:@encode(SEL)];
        NSMutableDictionary *aDic = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                                     target,TARGET,
                                     requestSccessValue,REQUEST_SCCESS,
                                     requestErrorValue,REQUEST_ERROR,
                                     nil];
        request.userInfo = aDic;
        [aDic release];
    }
    //Post的参数
    if (params) {
        NSArray *values = [params allValues];
        NSArray *keys = [params allKeys];
        for (int i = 0; i < [params count]; i++) {
            id tempvalue = [values objectAtIndex:i];
            id tempkey = [keys objectAtIndex:i];
            [request setPostValue:tempvalue forKey:tempkey];
        }
    }
    [request setDelegate:self];
    [request setShowAccurateProgress:YES];
    [request setDidFinishSelector:@selector(requestDone:)];
    [request setDidFailSelector:@selector(requestFailed:)];
    [_requestQueue addOperation:request];
    [request release];
    return request;  
}


#pragma mark - request details handle
-(void)requestDone:(ASIHTTPRequest *)request
{
    //除去 404等异常状态
    if ([request responseStatusCode] == 200) {
        SEL action;
        [(NSValue *)[request.userInfo objectForKey:REQUEST_SCCESS] getValue:&action];
        if (action) {
            [[request.userInfo objectForKey:TARGET] performSelector:action withObject:request];
        }
    }else
    {
        [self requestFailed:request];
    }
}

-(void)requestFailed:(ASIHTTPRequest *)request
{
    SEL action;
    [(NSValue *)[request.userInfo objectForKey:REQUEST_ERROR] getValue:&action];
    if (action) {
        [[request.userInfo objectForKey:TARGET] performSelector:action withObject:request];
    }
}


-(void)requestDidStart:(ASIHTTPRequest *)request
{
    SEL action;
    [(NSValue *)[request.userInfo objectForKey:REQUEST_DID_START] getValue:&action];
    if (action) {
        [[request.userInfo objectForKey:TARGET] performSelector:action withObject:request];
    }
}





@end
