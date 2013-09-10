//
//  HttpRequestCenter.h
//  JNRain
//
//  Created by Yin Qiang on 13-9-10.
//  Copyright (c) 2013年 YinQiang. All rights reserved.
//
#import "NetDefine.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "ASINetworkQueue.h"
#import "ASIProgressDelegate.h"

#import <Foundation/Foundation.h>






@interface HttpRequestCenter : NSObject
{
    //请求队列
    ASINetworkQueue *_requestQueue;
}
@property (nonatomic,retain) ASINetworkQueue *requestQueue;

+(HttpRequestCenter *)shareNetCenter;

/**request
 请求部分
 */
///---------------------------------------------------------------------------------------
/// @name  通用数据请求模块
///---------------------------------------------------------------------------------------


//GET
-(ASIHTTPRequest *)getDataWithSpecificUrl:(NSString *)url
                               withTarget:(id)target
                            requestSccess:(SEL)requestSccessAction
                             requestError:(SEL)requestErrorAction;

//POST
-(ASIHTTPRequest *)postDataWithBaseUrl:(NSString *)url
                            withTarget:(id)target
                                params:(NSDictionary *)params
                         requestSccess:(SEL)requestSccessAction
                          requestError:(SEL)requestErrorAction;




@end
