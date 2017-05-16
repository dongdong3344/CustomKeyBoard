//
//  LDDKeyChain.h
//  newKeyboard
//
//  Created by Ringo on 2016/10/17.
//  Copyright © 2016年 delta wjdsbu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>

@interface LDDKeyChain : NSObject
+ (NSMutableDictionary *)getKeychainQuery:(NSString *)service;

// save username and password to keychain


+ (void)save:(NSString *)service data:(id)data;

// load username and password from keychain
+ (id)load:(NSString *)service;

// delete username and password from keychain
+ (void)delete:(NSString *)serviece;


@end
