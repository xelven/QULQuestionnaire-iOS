//
//  QULQuestionnaireViewController.h
//  QULQuestionnaire
//
/*
 Copyright 2014 Quality and Usability Lab, Telekom Innvation Laboratories, TU Berlin.
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */


#import <UIKit/UIKit.h>
#import "RMStepsController/RMStepsController.h"

@interface QULQuestionnaireViewController : RMStepsController

- (instancetype)initWithQuestionnaireData:(NSArray *)questionnaireData;

- (void)onNext:(void (^)(NSMutableDictionary* currentResults))nextBlock;
- (void)onPrevious:(void (^)(NSMutableDictionary* currentResults))previousBlock;
- (void)onFinished:(void (^)(NSMutableDictionary* results))finishedBlock;
- (void)onCancelled:(void (^)(NSMutableDictionary* currentResults))cancelledBlock;

@end
