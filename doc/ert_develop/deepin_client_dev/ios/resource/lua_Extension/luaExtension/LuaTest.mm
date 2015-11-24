//
//  LuaTest.m
//  APP
//
//  Created by lin.jitao on 14-08-08.
//  Copyright (c) 2014年 RYTong. All rights reserved.
//

#import "LuaTest.h"

@implementation LuaTest

static LuaTest *sharedLuaTest = nil;

+(id)sharedLuaObject {
    @synchronized ([LuaTest class]) {
        if (sharedLuaTest == nil) {
            [[LuaTest alloc] init];
            return sharedLuaTest;
        }
    }
    return sharedLuaTest;
}

+ (id)alloc {
    @synchronized ([LuaTest class]) {
        sharedLuaTest = [super alloc];
        return sharedLuaTest;
    }
    return nil;
}

static int startTest(lua_State *lua) {
    
    ZNLog(@"实现自定义方法");
    
    return 0;
}

const struct luaL_reg test_libs [] = {
    {"startTest", startTest},
    {NULL, NULL}
};

int luaopen_testlibs(lua_State *lua) {
    
	luaL_register(lua, "TEST", test_libs);
	return 1;
}

- (void)openTest:(lua_State *)lua {
	luaopen_testlibs(lua);
}

@end
