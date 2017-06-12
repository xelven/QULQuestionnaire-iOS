//
//  QULQuestionnaireMultiSelectViewController.m
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


#import "QULQuestionnaireMultiSelectViewController.h"
#import "RMStepsController.h"
#import "NSMutableArray+Shuffle.h"
#import "QULTapGestureRecognizer.h"

@interface QULQuestionnaireMultiSelectViewController () {
    NSBundle *resourceBundle;
}

@property (strong, nonatomic) NSMutableArray *selectedOptions;

@end

@implementation QULQuestionnaireMultiSelectViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    resourceBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[self class]]
                                               pathForResource:@"QULQuestionnaire"
                                               ofType:@"bundle"]];

    self.selectedOptions = [@[] mutableCopy];
	
	[self updateQuestionTitle:self.questionnaireData[@"question"]];
	self.required = [self.questionnaireData[@"required"] boolValue];

	// TODO: line: 15px (1.3)
    UILabel *instructionLabel = [[UILabel alloc] init];
	instructionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:12.f];
	instructionLabel.textColor = [UIColor colorWithRed:138.f/255.f green:138.f/255.f blue:138.f/255.f alpha:1.f]; // #8A8A8A
    instructionLabel.numberOfLines = 0;
    instructionLabel.translatesAutoresizingMaskIntoConstraints = NO;
    instructionLabel.text = self.questionnaireData[@"instruction"];
    [self.contentView addSubview:instructionLabel];
	
    if ([self.questionnaireData[@"randomized"] boolValue]) {
        NSMutableArray *shuffledOptions = [self.questionnaireData[@"options"] mutableCopy];
        [shuffledOptions shuffle];
        
        NSMutableDictionary *dataCopy = [self.questionnaireData mutableCopy];
        dataCopy[@"options"] = shuffledOptions;
        self.questionnaireData = dataCopy;
    }

	UIColor *separatorColor = [UIColor colorWithRed:229.f/255.f green:229.f/255.f blue:229.f/255.f alpha:1.f]; // #E5E5E5
	UIView *startSeparatorView = [[UIView alloc] init];
	startSeparatorView.translatesAutoresizingMaskIntoConstraints = NO;
	startSeparatorView.backgroundColor = separatorColor;
	[self.contentView addSubview:startSeparatorView];

	UIView *endSeparatorView = [[UIView alloc] init];
	endSeparatorView.translatesAutoresizingMaskIntoConstraints = NO;
	endSeparatorView.backgroundColor = separatorColor;
	[self.contentView addSubview:endSeparatorView];

	NSDictionary *views = @{@"questionLabel": self.questionLabel,
							@"instructionLabel": instructionLabel,
							@"startSeparatorView": startSeparatorView,
							@"endSeparatorView": endSeparatorView};

    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[questionLabel]-(57)-[instructionLabel]-(2)-[startSeparatorView(1)]"
																		options:0
																		metrics:nil
																			views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(15)-[instructionLabel]-(15@999)-|"
																			 options:0
																			 metrics:nil
																			   views:views]];
	[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[startSeparatorView]|"
																			 options:0
																			 metrics:nil
																			   views:views]];
	[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[endSeparatorView]|"
																			 options:0
																			 metrics:nil
																			   views:views]];

    NSString *radioOffPath = [resourceBundle pathForResource:@"checkboxOff" ofType:@"png"];
    NSString *radioOnPath = [resourceBundle pathForResource:@"checkboxOn" ofType:@"png"];
	UIImage *radioOff = [UIImage imageWithContentsOfFile:radioOffPath];
    UIImage *radioOn = [UIImage imageWithContentsOfFile:radioOnPath];

    int i = 0;
    id previousElement = startSeparatorView;
    for (NSDictionary *option in self.questionnaireData[@"options"]) {
        QULButton *button = [QULButton buttonWithType:UIButtonTypeCustom];
        button.translatesAutoresizingMaskIntoConstraints = NO;
		button.tag = i;
        [button setImage:radioOff forState:UIControlStateNormal];
        [button setImage:radioOn forState:UIControlStateSelected];
        [button addTarget:self action:@selector(checkboxToggle:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:button];

		// TODO: line: 21px (1.2)
		UILabel *label = [[UILabel alloc] init];
        label.translatesAutoresizingMaskIntoConstraints = NO;
		label.font = [UIFont systemFontOfSize:17];
		label.numberOfLines = 0;
		label.text = option[@"value"];
        [self.contentView addSubview:label];
		button.labelObj = label;

		label.userInteractionEnabled = YES;
		QULTapGestureRecognizer *singleTap = [[QULTapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
		singleTap.numberOfTapsRequired = 1;
		singleTap.numberOfTouchesRequired = 1;
		singleTap.buttonObj = button;
		[label addGestureRecognizer:singleTap];

		UIView *separatorView = [[UIView alloc] init];
		separatorView.translatesAutoresizingMaskIntoConstraints = NO;
		separatorView.backgroundColor = separatorColor;
		[self.contentView addSubview:separatorView];

		CGFloat anwsersWidth = [UIScreen mainScreen].bounds.size.width - 55 - 8;
		NSInteger anwsersHeight = [self findHeightForText:option[@"value"] havingWidth:anwsersWidth andFont:label.font].height;
		anwsersHeight += 10;
		if (anwsersHeight < 51) {
			anwsersHeight = 51;
		}

		NSDictionary *viewBindings = NSDictionaryOfVariableBindings(previousElement, label, button, separatorView, endSeparatorView);

		[self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:button
																	 attribute:NSLayoutAttributeHeight
																	 relatedBy:NSLayoutRelationEqual
																		toItem:nil
																	 attribute:NSLayoutAttributeNotAnAttribute
																	multiplier:1.0
																	  constant:anwsersHeight]];
        NSString *format;
        if (i == [self.questionnaireData[@"options"] count]-1) {
            format = @"V:[previousElement][button][endSeparatorView(1)]|";
        } else {
            format = @"V:[previousElement][button][separatorView(1)]";
        }
		
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:format
																				 options:0
																				 metrics:nil
																				   views:viewBindings]];
        [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(16)-[button(33)]-(4)-[label]-(15@999)-|"
																				 options:NSLayoutFormatAlignAllCenterY
																				 metrics:nil
																				   views:viewBindings]];
		[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(55)-[separatorView]-(0@999)-|"
																				 options:0
																				 metrics:nil
																				   views:viewBindings]];
        
        previousElement = separatorView;
        i++;
		
		if(option[@"selected"] && option[@"selected"] != [NSNull null]){
			BOOL selected = [option[@"selected"]boolValue];
			if(selected == YES)
				[self checkboxToggle:button];
		}
    }
}

- (void)handleSingleTap:(QULTapGestureRecognizer *)recognizer {
	if([recognizer isKindOfClass:[QULTapGestureRecognizer class]] == YES) {
		[self checkboxToggle:recognizer.buttonObj];
	}
}

- (CGSize)findHeightForText:(NSString *)text havingWidth:(CGFloat)widthValue andFont:(UIFont *)font {
	CGSize size = CGSizeZero;
	if (text) {
		CGRect frame = [text boundingRectWithSize:CGSizeMake(widthValue, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{ NSFontAttributeName:font } context:nil];
		size = CGSizeMake(frame.size.width, frame.size.height + 1);
	}
	return size;
}

- (void)proceed {
	[super proceed];

	NSInteger minSelectable = [self.questionnaireData[@"minSelectable"] integerValue];
	NSInteger maxSelectable = [self.questionnaireData[@"maxSelectable"] integerValue];

	if ((self.selectedOptions.count < minSelectable || (maxSelectable > 0 && self.selectedOptions.count > maxSelectable)) &&
		self.isRequired && self.alertBottomLabel.hidden == YES) {
		self.alertBottomLabel.text = [NSString stringWithFormat:NSLocalizedString(@"This is a required function. If you wish to skip, please tap the '%@' button again.", nil), [self.nextButton titleForState:UIControlStateNormal]];
		self.alertBottomLabel.hidden = NO;
	} else {
		self.alertBottomLabel.hidden = YES;

		[self sendResults];
		[self.stepsController showNextStep];
	}
}

- (void)previousProceed {
	[super previousProceed];
	
	[self sendResults];
	[self.stepsController showPreviousStep];
}

- (void)sendResults {
	NSMutableDictionary *result = [@{} mutableCopy];
	result[@"q"] = self.questionnaireData[@"key"];
	result[@"a"] = [@[] mutableCopy];

	[self.selectedOptions enumerateObjectsUsingBlock:^(NSNumber *buttonTag, NSUInteger idx, BOOL *stop) {
		NSDictionary *option = self.questionnaireData[@"options"][[buttonTag integerValue]];
		result[@"a"][idx] = option[@"key"];
	}];
	[self.stepsController.results[@"data"] addObject:result];
}

- (void)checkboxToggle:(UIButton *)button {
	self.alertBottomLabel.hidden = YES;
	
    if (button.selected) {
        [self.selectedOptions removeObject:@(button.tag)];
        button.selected = !button.selected;
    } else {
        if (self.questionnaireData[@"maxSelectable"]) {
            if ([self.selectedOptions count] < [self.questionnaireData[@"maxSelectable"] intValue]) {
                [self.selectedOptions addObject:@(button.tag)];
                button.selected = !button.selected;
            }
        } else {
            [self.selectedOptions addObject:@(button.tag)];
            button.selected = !button.selected;
        }
    }
}

@end
