//
//  JEPush.m
//  BPushDemo
//
//  Created by Work on 15/9/8.
//
//

#import "JEPush.h"
#import "BPush.h"

@interface JEPush()

@property (nonatomic, strong) NSString *callbackId;

@end
    
@implementation JEPush


- (void)getBChannelID:(CDVInvokedUrlCommand *)command{

    JEPush *push = [JEPush sharedInstance];
    
    push.callbackId = command.callbackId;
    
    push.commandDelegate = self.commandDelegate;
  
    [push registLocalNotification];

    if (![JEPush isAllowedNotification]) {

        //首次打开应用时，会弹出授权alert，那么这里的状态是未知的，如果用户允许，会造成这里调用一次，获取devicetoken时又调用一次
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"获取失败"];
        [pluginResult setKeepCallbackAsBool:YES];
        [[JEPush sharedInstance].commandDelegate sendPluginResult:pluginResult callbackId:[JEPush sharedInstance].callbackId];

    }
}


- (void)cancelAllLocalNotifications:(CDVInvokedUrlCommand *)command{
    
        //清除通知列表
        [[UIApplication sharedApplication] cancelAllLocalNotifications];

}


- (void)apiKeyAndMode:(CDVInvokedUrlCommand *)command{

    if (command.arguments.count == 2) {
        
        NSString *key = command.arguments.firstObject;
        BPushMode mode = BPushModeProduction;
        if ([command.arguments.lastObject isEqualToString:@"0"]) {
            mode = BPushModeDevelopment;
        }
        
        [BPush registerChannel:nil apiKey:key pushMode:mode withFirstAction:nil withSecondAction:nil withCategory:nil isDebug:NO];

    }
    
}

- (void)registLocalNotification{
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        UIUserNotificationType myTypes = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:myTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }else {
        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge|UIRemoteNotificationTypeAlert|UIRemoteNotificationTypeSound;
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:myTypes];
    }
    
}

- (void)didRegisterForRemoteNotificationsWithDeviceToken:(id)sender{
    if ([[sender name] isEqualToString:CDVRemoteNotification]) {
        
        NSString *token = [sender object];
        
        [BPush registerDeviceToken:[self dataFromHexString:token]];
        
        [BPush bindChannelWithCompleteHandler:^(id result, NSError *error) {
            if ([result isKindOfClass:[NSDictionary class]]) {

                NSString *channelId = [BPush getChannelId];
                
                if (channelId.length) {
                    
                    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:channelId];
                    [pluginResult setKeepCallbackAsBool:YES];
                    [[JEPush sharedInstance].commandDelegate sendPluginResult:pluginResult callbackId:[JEPush sharedInstance].callbackId];
                    
                }else{
                    
                    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"获取失败"];
                    [pluginResult setKeepCallbackAsBool:YES];
                    [[JEPush sharedInstance].commandDelegate sendPluginResult:pluginResult callbackId:[JEPush sharedInstance].callbackId];
                    
                }
                
            }
        }];
    }
    
}


- (void)didFailToRegisterForRemoteNotificationsWithError:(id)sender{
    
    
    
}

- (NSData *) dataFromHexString:(NSString *)hexstr{
    NSMutableData *data = [[NSMutableData alloc] init];
    NSString *inputStr = [hexstr uppercaseString];
    
    NSString *hexChars = @"0123456789ABCDEF";
    
    Byte b1,b2;
    b1 = 255;
    b2 = 255;
    for (int i=0; i<hexstr.length; i++) {
        NSString *subStr = [inputStr substringWithRange:NSMakeRange(i, 1)];
        NSRange loc = [hexChars rangeOfString:subStr];
        
        if (loc.location == NSNotFound) continue;
        
        if (255 == b1) {
            b1 = (Byte)loc.location;
        }else {
            b2 = (Byte)loc.location;
            
            //Appending the Byte to NSData
            Byte *bytes = malloc(sizeof(Byte) *1);
            bytes[0] = ((b1<<4) & 0xf0) | (b2 & 0x0f);
            [data appendBytes:bytes length:1];
            
            b1 = b2 = 255;
        }
    }
    
    return data;
}

+ (BOOL)isAllowedNotification {
    //iOS8 check if user allow notification
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {// system is iOS8
        UIUserNotificationSettings *setting = [[UIApplication sharedApplication] currentUserNotificationSettings];
        if (UIUserNotificationTypeNone != setting.types) {
            return YES;
        }
    } else {//iOS7
        UIRemoteNotificationType type = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
        if(UIRemoteNotificationTypeNone != type)
            return YES;
    }
    return NO;
}

//单例模式
+ (instancetype)sharedInstance {
    static JEPush *sharedInstance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        
        sharedInstance = [[self alloc] init];
        
        [[NSNotificationCenter defaultCenter]addObserver:sharedInstance selector:@selector(didRegisterForRemoteNotificationsWithDeviceToken:) name:CDVRemoteNotification object:nil];
        
        [[NSNotificationCenter defaultCenter]addObserver:sharedInstance selector:@selector(didFailToRegisterForRemoteNotificationsWithError:) name:CDVRemoteNotificationError object:nil];
        
    });
    return sharedInstance;
}

@end
