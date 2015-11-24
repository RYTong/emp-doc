//
//  LuaTest.m
//  APP
//
//  Created by Yu Cheng on 12-11-13.
//  Copyright (c) 2012年 RYTong. All rights reserved.
//

#import "LuaTest.h"
#import "RYTConfig.h"
#import "RYTBodyControl.h"
#import "RYTControl.h"

extern "C"
{
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
}


int luaopen_timerlibs(lua_State *lua);

@implementation LuaTest

static LuaTest *sharedLuaTest = nil;
static     lua_State *lua_s;

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
    
    NSLog(@"实现自定义方法");
    
    return 0;
}

const struct luaL_reg test_libs [] = {
    {"startTest", startTest},
    {NULL, NULL}
};

int luaopen_testlibs(lua_State *lua) {
    
	luaL_register(lua, "test", test_libs);
	return 1;
}

- (void)openTest:(lua_State *)lua {
    lua_s = lua;
	luaopen_testlibs(lua);
}

@end
