//
//  LDDSheetController.h
//  ICBCKeyboard
//
//  Created by Ringo on 2017/5/10.
//  Copyright © 2017年 Ringo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^LDDSheetActionBlock)(NSInteger buttonTag);

@interface LDDSheetController : UIViewController

@property(nonatomic,copy)LDDSheetActionBlock sheetBlock;

@end
