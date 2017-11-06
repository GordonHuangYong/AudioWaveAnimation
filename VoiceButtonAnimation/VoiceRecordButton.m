//
//  VoiceButton.m
//  VoiceButtonAnimation
//
//  Created by yunfei on 2017/9/26.
//  Copyright © 2017年 yunfei. All rights reserved.
//

#import "VoiceRecordButton.h"
#import <QuartzCore/QuartzCore.h>

@interface VoiceRecordButton () <CAAnimationDelegate>
@property (nonatomic) BOOL talking;
@property (nonatomic) NSRect initialFrame;
@property (nonatomic) CGFloat initialWidth;
@end

@implementation VoiceRecordButton
#pragma mark - setters
- (void)setPointArray:(NSArray *)pointArray{
    _pointArray = pointArray;
    [self setNeedsDisplay:YES];
}

#pragma mark - init
- (instancetype)initWithFrame:(NSRect)frameRect{
    self = [super initWithFrame:frameRect];
    if (self) {
        self.bordered = NO;
        self.wantsLayer = YES;
        self.layer.cornerRadius = NSHeight(frameRect) / 2.f;
        NSButtonCell *cell = (NSButtonCell *)self.cell;
        cell.highlightsBy = NSNoCellMask;   //高亮样式
        
        self.initialWidth = frameRect.size.width;
        self.initialFrame = frameRect;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect{
    [super drawRect:dirtyRect];
    
    if (!self.talking) {
        
        NSBezierPath *rectPath = [NSBezierPath bezierPathWithOvalInRect:dirtyRect];
        [[NSColor blueColor] setFill];
        [rectPath fill];
        
        NSImage *image = [NSImage imageNamed:@"SideAudio"];
        [image drawInRect:dirtyRect];
        return;
    }
    
    CGFloat midY = NSHeight(dirtyRect) / 2.f;
    CGFloat midX = NSWidth(dirtyRect) / 2.f;
    CGFloat leftX = midX - _pointArray.count / 2.f - _initialWidth / 2.f;
    CGFloat rightX = midX + _pointArray.count / 2.f + _initialWidth / 2.f;
    
    // Drawing code here.
    CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
    
    //绘制初始线型
    CGMutablePathRef linePath = CGPathCreateMutable();
    CGPathMoveToPoint(linePath, nil, leftX, midY);
    CGPathAddLineToPoint(linePath, nil, leftX + _initialWidth, midY);
    CGContextAddPath(ctx, linePath);
    
    //绘制上半部分波形
    CGMutablePathRef halfPath = CGPathCreateMutable();                 //绘制路径
    CGPathMoveToPoint(halfPath, nil, NSWidth(dirtyRect), midY);
    for (NSInteger i = 0; i < _pointArray.count; i++) {
        NSValue *pointValue = _pointArray[i];
        NSPoint point = pointValue.pointValue;
        NSInteger j = _pointArray.count - i - 1;
        if (point.y == 0) {
            CGPathMoveToPoint(halfPath, nil, rightX - j + 1, midY);
            CGPathAddLineToPoint(halfPath, NULL, rightX - j, midY);
        }else{
            CGPathMoveToPoint(halfPath, nil, rightX - j, midY);
            CGPathAddLineToPoint(halfPath, NULL, rightX - j, midY + point.y);
        }
    }
    
    //实现波形图反转
    CGMutablePathRef fullPath = CGPathCreateMutable();//创建新路径
    CGPathAddPath(fullPath, NULL, halfPath);          //合并路径
    CGAffineTransform transform = CGAffineTransformIdentity; //反转
    //反转配置
    transform = CGAffineTransformTranslate(transform, 0, NSHeight(dirtyRect));
    transform = CGAffineTransformScale(transform, 1.0, -1.0);
    CGPathAddPath(fullPath, &transform, halfPath);
    
    //将路径添加到上下文中
    CGContextAddPath(ctx, fullPath);
    
    //绘制矩形区域
    CGMutablePathRef rectPath = CGPathCreateMutable();
    CGPathMoveToPoint(rectPath, nil, leftX, 0);
    CGPathAddRoundedRect(rectPath, nil, CGRectMake(leftX, 0, _pointArray.count + _initialWidth, NSHeight(dirtyRect)), NSHeight(dirtyRect) / 2.f, NSHeight(dirtyRect) / 2.f);
    CGContextAddPath(ctx, rectPath);
    
    CGContextSetLineWidth(ctx, 1);
    CGContextSetStrokeColorWithColor(ctx, [NSColor whiteColor].CGColor);
    CGContextSetFillColorWithColor(ctx, [NSColor blueColor].CGColor);
    CGContextDrawPath(ctx, kCGPathFillStroke);
    
    //移除
    CGPathRelease(halfPath);
    CGPathRelease(fullPath);

}

#pragma mark - custom methods
- (void)startAnimation{
    self.enabled = NO;
    [self moveAnchorPointToCenter];   //将锚点移到中心 (为了达到围绕中心缩放的效果)
    
    //放大
    CAKeyframeAnimation *scaleToBigAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    scaleToBigAnimation.values = @[@(1.0), @(.7f), @(1.f), @(1.3f), @(1.7f)];
    scaleToBigAnimation.duration = 0.5;
    scaleToBigAnimation.beginTime = 0;
    
    //缩小
    CAKeyframeAnimation *scaleAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.values = @[@(1.7f), @(1)];
    scaleAnimation.duration = 0.75;
    scaleAnimation.beginTime = scaleToBigAnimation.beginTime + scaleToBigAnimation.duration;
    
    //位置下移，与缩小动画同时进行
    CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position.y"];
    positionAnimation.toValue = @(self.layer.position.y - NSWidth(self.frame));
    positionAnimation.duration = scaleAnimation.duration;
    positionAnimation.beginTime = scaleAnimation.beginTime;
    
    //添加动画组
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.delegate = self;
    animationGroup.duration = scaleToBigAnimation.duration + positionAnimation.duration;
    [animationGroup setValue:@"animationGroup" forKey:@"AnimationKey"];
    animationGroup.animations = @[scaleToBigAnimation, scaleAnimation, positionAnimation];
    [self.layer addAnimation:animationGroup forKey:@"animationGroup"];
}

- (void)startRecording{
    self.talking = YES;
    [self setNeedsDisplay:YES];
    
    //延迟_recordingDuration执行，若没有手动停止，则自动停止录音
    [self performSelector:@selector(stopRecording) withObject:nil afterDelay:_recordingDuration];
}

- (void)stopRecording{
    //取消延迟执行
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopRecording) object:nil];
    
    self.enabled = YES;
    self.frame = self.initialFrame;
    self.talking = NO;
    
    [self setNeedsDisplay:YES];
    
    if ([self.delegate respondsToSelector:@selector(voiceRecordingDidFinish)]) {
        [self.delegate voiceRecordingDidFinish];
    }
}

#pragma mark - anchor configuration
- (void)moveAnchorPointToCenter{
    self.layer.anchorPoint = CGPointMake(0.5, 0.5);
    
    NSRect rect = self.frame;
    CGFloat centerX = rect.origin.x + rect.size.width / 2.f;
    CGFloat centerY = rect.origin.y + rect.size.height / 2.f;
    self.layer.position = CGPointMake(centerX, centerY);
}

- (void)resumeAnchorPoint{
    self.layer.anchorPoint = CGPointZero;
    self.layer.position = self.frame.origin;
}

#pragma mark - CAAnimation delegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if (flag) {
        if ([self.delegate respondsToSelector:@selector(voiceRecordingWillBegin)]) {
            [self.delegate voiceRecordingWillBegin];
        }
        [self resumeAnchorPoint];
        [self startRecording];
        
    }
}

@end
