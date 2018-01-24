//
//  ViewController.m
//  RedpacketRain
//
//  Created by xubojoy on 2018/1/23.
//  Copyright © 2018年 xubojoy. All rights reserved.
//

#import "ViewController.h"
#import <Masonry/Masonry.h>
#define screen_width          [UIScreen mainScreen].bounds.size.width
#define screen_height          [UIScreen mainScreen].bounds.size.height
@interface ViewController ()
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) CALayer *moveLayer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor cyanColor];
    [self startTime];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickRed:)];
    [self.view addGestureRecognizer:tap];
}

//开始倒计时
- (void)startTime
{
    __block int timeout = 5;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_timer, ^{
        if ( timeout <= 0 )
        {
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                 [self beginRain];
            });
        }
        else
        {
            int seconds = timeout % 6;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self countDown:seconds];
            });
            timeout--;
        }
    });
    dispatch_resume(_timer);
}
//倒计时显示
-(void)countDown:(int)count{
    if(count <=0){
        //倒计时已到，作需要作的事吧。
        return;
    }
    UILabel* lblCountDown = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    lblCountDown.textColor = [UIColor whiteColor];
    lblCountDown.font = [UIFont boldSystemFontOfSize:80];
    lblCountDown.textAlignment = NSTextAlignmentCenter;
    lblCountDown.center = self.view.center;
    lblCountDown.backgroundColor = [UIColor clearColor];
    lblCountDown.text = [NSString stringWithFormat:@"%d",count];
    [self.view addSubview:lblCountDown];
    
    [UIView animateWithDuration:1 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        lblCountDown.alpha = 0;
        lblCountDown.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.5, 0.5);
    } completion:^(BOOL finished) {
        [lblCountDown removeFromSuperview];
        //不用GCD可直接用递归调用，直到计时为零
        //[self countDown:count-1];
    }];
}

//设置定时器
- (void)beginRain{
    [self.timer invalidate];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:(0.5) target:self selector:@selector(showRain) userInfo:nil repeats:YES];
}
//红包雨动画
- (void)showRain
{
    CALayer *moveLayer = [CALayer new];
    moveLayer.bounds = CGRectMake(0, 0, 100, 100);
    moveLayer.anchorPoint = CGPointMake(0, 0);
    moveLayer.position = CGPointMake(0, -200/2-20);
    moveLayer.contents = (id)[UIImage imageNamed:@"redpacket"].CGImage;
    [self.view.layer addSublayer:moveLayer];
    
    int space = screen_width;
    CAKeyframeAnimation *moveAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    NSValue *A = [NSValue valueWithCGPoint:CGPointMake(arc4random() % space, 0)];
    NSValue *B = [NSValue valueWithCGPoint:CGPointMake(arc4random() % space, screen_height)];
    
    moveAnimation.values = @[A,B];
    moveAnimation.duration = arc4random() %200 / 100.0 + 3.5;
    moveAnimation.repeatCount = 1;
    moveAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [moveLayer addAnimation:moveAnimation forKey:nil];
    
//    旋转动画
    CAKeyframeAnimation *transAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    CATransform3D r0 = CATransform3DMakeRotation(M_PI/180 * (arc4random() % 360),0,0,-1);
    CATransform3D r1 = CATransform3DMakeRotation(M_PI/180 * (arc4random() % 360),0,0,-1);
    
    transAnimation.values = @[[NSValue valueWithCATransform3D:r0],[NSValue valueWithCATransform3D:r1]];
    transAnimation.duration = arc4random() %200 / 100.0 + 3.5;
    transAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [transAnimation setFillMode:kCAFillModeForwards];
    [transAnimation setRemovedOnCompletion:NO];
    [moveLayer addAnimation:transAnimation forKey:nil];
    
}

- (void)clickRed:(UITapGestureRecognizer *)sender{
    NSLog(@"-------------点击");
    
    CGPoint point = [sender locationInView:self.view];
    for (int i = 0 ; i < self.view.layer.sublayers.count ; i ++)
    {
        CALayer * layer = self.view.layer.sublayers[i];
        if ([[layer presentationLayer] hitTest:point] != nil)
        {
            NSLog(@"%d",i);
            
            BOOL hasRedPacketd = !(i % 3) ;
            
            NSLog(@"hasRedPacketd------%d",hasRedPacketd);
            
            UIImageView * newPacketIV = [UIImageView new];
            if (hasRedPacketd)
            {
                newPacketIV.image = [UIImage imageNamed:@"fudai"];
                newPacketIV.frame = CGRectMake(0, 0, 100, 100);
            }
            else
            {
                newPacketIV.image = [UIImage imageNamed:@"redpacket"];
                newPacketIV.frame = CGRectMake(0, 0, 100, 100);
            }
            
            layer.contents = (id)newPacketIV.image.CGImage;
            
            UIView * alertView = [UIView new];
            alertView.layer.cornerRadius = 5;
            alertView.frame = CGRectMake(point.x - 50, point.y, 100, 30);
            [self.view addSubview:alertView];
            
            UILabel * label = [UILabel new];
            label.font = [UIFont systemFontOfSize:17];
            
            if (!hasRedPacketd)
            {
                label.text = @"狗年行狗运！";
                label.textColor = [UIColor redColor];
            }
            else
            {
                NSString * string = [NSString stringWithFormat:@"+%d升鸡血",i];
                NSString * iString = [NSString stringWithFormat:@"%d",i];
                NSMutableAttributedString * attributedStr = [[NSMutableAttributedString alloc]initWithString:string];
                
                [attributedStr addAttribute:NSFontAttributeName
                                      value:[UIFont systemFontOfSize:27]
                                      range:NSMakeRange(0, 1)];
                [attributedStr addAttribute:NSFontAttributeName
                                      value:[UIFont fontWithName:@"PingFangTC-Semibold" size:32]
                                      range:NSMakeRange(1, iString.length)];
                [attributedStr addAttribute:NSFontAttributeName
                                      value:[UIFont systemFontOfSize:17]
                                      range:NSMakeRange(1 + iString.length, 2)];
                label.attributedText = attributedStr;
                label.textColor = [UIColor purpleColor];
            }
            
            [alertView addSubview:label];
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(alertView.mas_centerX);
                make.centerY.equalTo(alertView.mas_centerY);
            }];
            
            [UIView animateWithDuration:1 animations:^{
                alertView.alpha = 0;
                alertView.frame = CGRectMake(point.x- 50, point.y - 100, 100, 30);
            } completion:^(BOOL finished) {
                [alertView removeFromSuperview];
            }];
        }
    }
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
