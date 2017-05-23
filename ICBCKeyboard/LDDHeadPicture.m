//
//  LDDHeadPicture.m
//  ICBCKeyboard
//
//  Created by Ringo on 2017/5/9.
//  Copyright © 2017年 Ringo. All rights reserved.
//

#import "LDDHeadPicture.h"

@interface LDDHeadPicture ()

@property (nonatomic, strong) NSMutableDictionary *dict;//用于存储照片

-(NSString *)imagePathForKey:(NSString *)key;

@end

@implementation LDDHeadPicture

//创建单例
+(instancetype)sharedPicture{
    static LDDHeadPicture *sharedPicture=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPicture=[[self alloc]initPrivate];
    });
    return sharedPicture;
}

//不容许直接调用init方法
-(instancetype)init{
    
    @throw [NSException exceptionWithName:@"singleton" reason:@"Pls use [LDDHeadPicture sharedPicture]" userInfo:nil];
    
    return nil;
    
}

//私有初始化方法
-(instancetype)initPrivate{
    
    self = [super init];
    if (self) {
        
        _dict = [[NSMutableDictionary alloc] init];
        //注册为低内存通知的观察者
        NSNotificationCenter *notification = [NSNotificationCenter defaultCenter];
        [notification addObserver:self
               selector:@selector(clearCache:)
                   name:UIApplicationDidReceiveMemoryWarningNotification
                 object:nil];
    }
    return self;
}

-(void)setImage:(UIImage *)image forKey:(NSString *)key{
    
    //将照片加入字典中
    self.dict[key]=image;
    
    //获取保存图片的全路径
    NSString *path = [self imagePathForKey:key];
    
    //从图片提取JPEG格式的数据,第2个参数为图片压缩质量，0-1，1代表最高质量（不压缩）
    NSData *data = UIImageJPEGRepresentation(image, 1);
    
    //以PNG格式提取图片数据
    //NSData *data = UIImagePNGRepresentation(image);
    
    //将图片数据写入文件，YES是将数据先写入某个临时文件，等写入操作完成后再将文件移至第一个实参所指定的路径并覆盖已有的文件
    [data writeToFile:path atomically:YES];
}

-(UIImage *)imageForKey:(NSString *)key{
    //先尝试通过字典获取照片
    UIImage *image = [self.dict objectForKey:key];
    if (!image) {
        NSString *path = [self imagePathForKey:key];
        //通过文件创建UIImage对象
        image = [UIImage imageWithContentsOfFile:path];
        //如果能够通过文件创建图片，就将其放入缓存
        if (image) {
            self.dict[key]=image;
        }else{
            NSLog(@"Error: unable to find %@", [self imagePathForKey:key]);
        }
    }
    return image;
}

-(NSString *)imagePathForKey:(NSString *)key{
    //获取Documents目录数组
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //数组获取第一个，也是唯一文档目录路径
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    
    return [documentDirectory stringByAppendingPathComponent:key];
}

-(void)clearCache:(NSNotification *)notification{
    
    NSLog(@"Flushing %ld images out of the cache", (unsigned long)[self.dict count]);
    [self.dict removeAllObjects];
}

@end
