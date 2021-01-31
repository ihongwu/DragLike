#import "DragLikePlugin.h"
#if __has_include(<drag_like/drag_like-Swift.h>)
#import <drag_like/drag_like-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "drag_like-Swift.h"
#endif

@implementation DragLikePlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftDragLikePlugin registerWithRegistrar:registrar];
}
@end
