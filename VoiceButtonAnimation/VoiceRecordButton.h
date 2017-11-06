//
//  VoiceButton.h
//  VoiceButtonAnimation
//
//  Created by yunfei on 2017/9/26.
//  Copyright © 2017年 yunfei. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol VoiceButtonDelegate <NSObject>

- (void)voiceRecordingWillBegin;
- (void)voiceRecordingDidFinish;

@end

@interface VoiceRecordButton : NSButton 
@property (nonatomic, weak) id<VoiceButtonDelegate> delegate;
@property (nonatomic, strong) NSArray *pointArray;              //point 数组，[NSValue valueWithPoint:point]，按时间正序排序
@property (nonatomic) NSTimeInterval recordingDuration;         //最长录制时长

- (void)startAnimation;

- (void)stopRecording;
@end
