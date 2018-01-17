//
//  ViewController.m
//  Runtime动态创建基础详解
//
//  Created by apple on 2017/7/14.
//  Copyright © 2017年 ZY. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self creatHeroClass];
}

-(void)creatHeroClass{
    /*  创建类
     *  参数1 父类  参数二 类名 参数3关于内存默认
     */
    Class  Hero = objc_allocateClassPair([NSObject class], "Hero", 0);
    
    class_addMethod(Hero, @selector(R:), (IMP)R, "@@:@");//添加方法
    
    class_addIvar(Hero, "Q", sizeof(NSString *), 0, "@");//添加成员变量
    class_addIvar(Hero, "W", sizeof(NSString *), 0, "@");//添加成员变量
    
    //添加属性实现setter  getter方法
    class_addMethod(Hero, @selector(setW:), (IMP)setW, "v@:@");
    class_addMethod(Hero, @selector(getW), (IMP)getW, "@@:");
    
    //注册类
    objc_registerClassPair(Hero);
    
    //实例化应用
    id hanbing = [[Hero alloc]init];
    
    //objc_setAssociatedObject 绑定key  value
    objc_setAssociatedObject(hanbing, @"beidong", @"寒冰的被动", OBJC_ASSOCIATION_COPY);
    NSLog(@"%@",objc_getAssociatedObject(hanbing, @"beidong"));
    
    //通过kvc设置上面定义的成员变量
    [hanbing setValue:@"寒冰射手的Q" forKey:@"Q"];
    
    [hanbing setW:@"寒冰的w"];
    NSLog(@"%@",[hanbing getW]);
    
    //类的属性
    objc_property_attribute_t type = { "T", "@\"NSString\"" };
    objc_property_attribute_t ownership = { "C", "" }; // C = copy
    objc_property_attribute_t backingivar  = { "V", "E" };
    objc_property_attribute_t attrs[] = { type, ownership, backingivar };
    class_addProperty(Hero, "E", attrs, 3);
    
    //遍历属性查看
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([Hero class], &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        fprintf(stdout, "Hero %s : %s\n", property_getName(property), property_getAttributes(property));
    }
    
    [hanbing R:@"德玛西亚"];
}

#pragma mark  OC方法

//OC方法不会调用，但是必须得写。实际调用IMP针织实现。
-(void)setW:(NSString *)w{
    
}

-(NSString *)getW{
    return nil;
}

-(NSString *)R:(NSString *)emery{
    
    return nil;
}

#pragma mark  IMP方法

void setW(id self,SEL cmd,NSString * str){
    Ivar  w = class_getInstanceVariable([self class], "W");
    NSString * oldW = object_getIvar(self, w);
    if (oldW!=str) {
        object_setIvar(self, w, [str copy]);
    }
}

NSString * getW(id self,SEL cmd){
    Ivar  w = class_getInstanceVariable([self class], "W");
    return object_getIvar(self, w);
}

id R(id self,SEL cmd,id emery){
    Ivar v  = class_getInstanceVariable([self class], "Q");
    NSString * vStr = object_getIvar(self, v);
    NSString * result = [NSString stringWithFormat:@"%@R死了%@",vStr,emery];
    NSLog(@"%@", result);
    return [NSString stringWithFormat:@"R死了%@",emery];
}

@end
