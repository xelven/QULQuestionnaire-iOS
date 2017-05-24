//
//  QULQuestionnaireVerticalSingleSelectViewController.m
//  Pods
//
//  Created by Scott Chou on 24/05/2017.
//
//

#import "QULQuestionnaireVerticalSingleSelectViewController.h"
#import "RMStepsController.h"
#import "NSMutableArray+Shuffle.h"
#import "QULTapGestureRecognizer.h"

static const NSInteger otherOption = -1;

@interface QULQuestionnaireVerticalSingleSelectViewController () <UITextFieldDelegate>  {
	NSBundle *resourceBundle;
}

@property (strong, nonatomic) NSMutableArray *buttons;
@property (strong, nonatomic) UITextField *textField;

@end

@implementation QULQuestionnaireVerticalSingleSelectViewController

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
	
	[self updateQuestionTitle:self.questionnaireData[@"question"]];
	self.required = ![self.questionnaireData[@"required"] boolValue];

	UILabel *instructionLabel = [[UILabel alloc] init];
	instructionLabel.font = [UIFont systemFontOfSize:12];
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

	NSString *radioOffPath = [resourceBundle pathForResource:@"radioOff" ofType:@"png"];
	UIImage *radioOff = [UIImage imageWithContentsOfFile:radioOffPath];
	NSString *radioOnPath = [resourceBundle pathForResource:@"radioOn" ofType:@"png"];
	UIImage *radioOn = [UIImage imageWithContentsOfFile:radioOnPath];

	int i = 0;
	id previousElement = startSeparatorView;
	self.buttons = [@[] mutableCopy];
	for (NSDictionary *option in self.questionnaireData[@"options"]) {
		QULButton *button = [QULButton buttonWithType:UIButtonTypeCustom];
		button.translatesAutoresizingMaskIntoConstraints = NO;
		[button setImage:radioOff forState:UIControlStateNormal];
		[button setImage:radioOn forState:UIControlStateSelected];
		button.tag = i;
		[button addTarget:self
				   action:@selector(didSelectButton:)
		 forControlEvents:UIControlEventTouchUpInside];
		[self.buttons addObject:button];
		[self.contentView addSubview:button];

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
				[self didSelectButton:button];
		}
	}

//	if ([self.questionnaireData[@"other"] boolValue]) {
//		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
//		button.translatesAutoresizingMaskIntoConstraints = NO;
//		[button setImage:radioOff forState:UIControlStateNormal];
//		[button setImage:radioOn forState:UIControlStateSelected];
//		button.tag = otherOption;
//		[button addTarget:self
//				   action:@selector(didSelectButton:)
//		 forControlEvents:UIControlEventTouchUpInside];
//		[self.buttons addObject:button];
//		[self.contentView addSubview:button];
//
//		UITextField *textField = [[UITextField alloc] init];
//		textField.tag = otherOption;
//		textField.delegate = self;
//		textField.translatesAutoresizingMaskIntoConstraints = NO;
//		textField.placeholder = NSLocalizedString(@"Other", nil);
//		self.textField = textField;
//
//		UIToolbar *toolbar = [[UIToolbar alloc] init];
//		[toolbar sizeToFit];
//		UIBarButtonItem *doneButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
//																						target:textField
//																						action:@selector(resignFirstResponder)];
//		doneButtonItem.enabled = YES;
//		UIBarButtonItem *flexibleSpaceButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
//																								 target:nil
//																								 action:nil];
//		toolbar.items = @[flexibleSpaceButtonItem,doneButtonItem];
//		[textField setInputAccessoryView:toolbar];
//		[self.contentView addSubview:textField];
//
//		[self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:button
//																	 attribute:NSLayoutAttributeWidth
//																	 relatedBy:NSLayoutRelationEqual
//																		toItem:nil
//																	 attribute:NSLayoutAttributeNotAnAttribute
//																	multiplier:1.0
//																	  constant:33.0]];
//		[self.contentView addConstraint:[NSLayoutConstraint constraintWithItem:button
//																	 attribute:NSLayoutAttributeHeight
//																	 relatedBy:NSLayoutRelationEqual
//																		toItem:nil
//																	 attribute:NSLayoutAttributeNotAnAttribute
//																	multiplier:1.0
//																	  constant:33.0]];
//		[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[previousElement]-[button]|"
//																				 options:NSLayoutFormatAlignAllLeading
//																				 metrics:nil
//																				   views:NSDictionaryOfVariableBindings(previousElement,button)]];
//		[self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-[button]-[textField]-|"
//																				 options:NSLayoutFormatAlignAllCenterY
//																				 metrics:nil
//																				   views:NSDictionaryOfVariableBindings(button,textField)]];
//
//	}

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillShow:)
												 name:UIKeyboardWillShowNotification
											   object:nil];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(keyboardWillHide:)
												 name:UIKeyboardWillHideNotification
											   object:nil];
}

- (void)handleSingleTap:(QULTapGestureRecognizer *)recognizer {
	//	CGPoint location = [recognizer locationInView:[recognizer.view superview]];
	if([recognizer isKindOfClass:[QULTapGestureRecognizer class]]==YES) {
		[self didSelectButton:recognizer.buttonObj];
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

- (BOOL)proceed {
	if ([super proceed]) {
		NSMutableDictionary *result = [@{} mutableCopy];
		result[@"q"] = self.questionnaireData[@"key"];

		[self.buttons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
			if (button.selected) {
				if (button.tag == otherOption) {
					result[@"a"] = self.textField.text;
				} else {
					NSDictionary *option = self.questionnaireData[@"options"][button.tag];
					result[@"a"] = option[@"key"];
				}

				*stop = YES;
			}
		}];
		[self.stepsController.results[@"data"] addObject:result];

		[self.stepsController showNextStep];

		return YES;
	}
	return NO;
}

- (void)previousProceed {
	[super previousProceed];

	NSMutableDictionary *result = [@{} mutableCopy];
	result[@"q"] = self.questionnaireData[@"key"];

	[self.buttons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
		if (button.selected) {
			if (button.tag == otherOption) {
				result[@"a"] = self.textField.text;
			} else {
				NSDictionary *option = self.questionnaireData[@"options"][button.tag];
				result[@"a"] = option[@"key"];
			}

			*stop = YES;
		}
	}];
	[self.stepsController.results[@"data"] addObject:result];

	[self.stepsController showPreviousStep];
}

- (void)didSelectButton:(UIButton *)selected {
	for (UIButton *button in self.buttons) {
		button.selected = (button == selected);
	}

	if (selected.tag == otherOption &&  self.textField) {
		[self.textField becomeFirstResponder];
	}
}

#pragma mark - UITextField delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField {
	if ([[self.view viewWithTag:textField.tag] isKindOfClass:[UIButton class]]) {
		UIButton *button = (UIButton *)[self.view viewWithTag:textField.tag];
		[self didSelectButton:button];
	}
}

#pragma mark - UIKeyboard show / hide

- (void)keyboardWillShow:(NSNotification *)notification {
	NSDictionary *info = [notification userInfo];
	CGRect keyboardRect = [info[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
	keyboardRect = [self.view convertRect:keyboardRect fromView:nil];

	UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0,
												  0.0,
												  keyboardRect.size.height - self.stepsController.stepsBar.frame.size.height + 15,
												  0.0);
	UIScrollView *scrollView = [[self.view subviews] firstObject];
	scrollView.contentInset = contentInsets;
	scrollView.scrollIndicatorInsets = contentInsets;

	CGRect viewRect = self.view.frame;
	viewRect.size.height -= keyboardRect.size.height;
	if (!CGRectContainsPoint(viewRect, self.textField.frame.origin) ) {
		[scrollView scrollRectToVisible:self.textField.frame animated:YES];
	}
}

- (void)keyboardWillHide:(NSNotification *)notification {
	UIEdgeInsets contentInsets = UIEdgeInsetsZero;
	UIScrollView *scrollView = [[self.view subviews] firstObject];
	scrollView.contentInset = contentInsets;
	scrollView.scrollIndicatorInsets = contentInsets;
}


@end
