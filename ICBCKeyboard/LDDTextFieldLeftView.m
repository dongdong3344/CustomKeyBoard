//
//  LDDTextFieldLeftView.m
//  ICBCKeyboard
//
//  Created by Ringo on 2017/5/13.
//  Copyright © 2017年 Ringo. All rights reserved.
//

#import "LDDTextFieldLeftView.h"

@implementation LDDTextFieldLeftView
+ (UIView *)textFiledLeftViewWithImageName:(NSString *)imageName andImageFrame:(CGRect)rect {
    UIView *view = [[UIView alloc] initWithFrame:rect];
    view.backgroundColor = [UIColor whiteColor];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    imageView.frame = rect;
    imageView.center = view.center;
    imageView.contentMode = UIViewContentModeCenter;
    [view addSubview:imageView];
    
    return view;
}
@end
