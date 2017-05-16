//
//  LDDAlertView.h
//  ICBCKeyboard
//
//  Created by Ringo on 2017/5/12.
//  Copyright © 2017年 Ringo. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^LDDAlertViewComfirmBlock)();

@interface LDDAlertView : UIView


@property (weak, nonatomic) IBOutlet UILabel *msgLabel;

@property(nonatomic,copy)LDDAlertViewComfirmBlock comfirmBlock;

/**加载xib*/
+(instancetype)loadAlertView;


/**设置label Alignment*/
-(void)labelAlignment;

@end
