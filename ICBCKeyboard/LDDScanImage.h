//
//  LDDScanImage.h
//  ICBCKeyboard
//
//  Created by Ringo on 2017/5/9.
//  Copyright © 2017年 Ringo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface LDDScanImage : NSObject


+(instancetype)sharedBigImage;


-(void)scanBigImageWithImageView:(UIImageView *)currentImageview;

@end
