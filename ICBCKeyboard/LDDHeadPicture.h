//
//  LDDHeadPicture.h
//  ICBCKeyboard
//
//  Created by Ringo on 2017/5/9.
//  Copyright © 2017年 Ringo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LDDHeadPicture : NSObject

+(instancetype)sharedPicture;

/**
 *  设置头像
 *
 *  @param image 图片
 */
-(void)setImage:(UIImage *)image forKey:(NSString *)key;

/**
 *  读取图片
 *
 */
-(UIImage *)imageForKey:(NSString *)key;

@end
