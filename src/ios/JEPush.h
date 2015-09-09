//
//  JEPush.h
//  BPushDemo
//
//  Created by Work on 15/9/8.
//
//


#import <Foundation/Foundation.h>
#import <Cordova/CDVPlugin.h>

@interface JEPush : CDVPlugin


- (void)getBChannelID:(CDVInvokedUrlCommand *)command;

- (void)cancelAllLocalNotifications:(CDVInvokedUrlCommand *)command;

- (void)apiKeyAndMode:(CDVInvokedUrlCommand *)command;


@end
