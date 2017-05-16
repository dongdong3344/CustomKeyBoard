//
//  LDDSheetController.m
//  ICBCKeyboard
//
//  Created by Ringo on 2017/5/10.
//  Copyright © 2017年 Ringo. All rights reserved.
//

#import "LDDSheetController.h"

@interface LDDSheetController ()

@end

@implementation LDDSheetController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.view.subviews  enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[UIButton class]]) {
            UIButton *button=(UIButton*)obj;
            [button addTarget:self action:@selector(sheetActionClick:) forControlEvents:UIControlEventTouchUpInside];
        }
    }];
}

-(void)sheetActionClick:(UIButton*)button{

    if (self.sheetBlock) {
        self.sheetBlock(button.tag);
    }
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

@end
