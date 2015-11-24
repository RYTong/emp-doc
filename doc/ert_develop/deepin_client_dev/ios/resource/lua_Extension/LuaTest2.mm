//
//  LuaTest.m
//  APP
//
//  Created by Yu Cheng on 12-11-13.
//  Copyright (c) 2012年 RYTong. All rights reserved.
//

#import "LuaTest2.h"
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

@implementation LuaTest2

static LuaTest2 *sharedLuaTest2 = nil;
static     lua_State *lua_s;

+(id)sharedLuaObject {
    @synchronized ([LuaTest2 class]) {
        if (sharedLuaTest2 == nil) {
            [[LuaTest2 alloc] init];
            return sharedLuaTest2;
        }
    }
    return sharedLuaTest2;
}

+ (id)alloc {
    @synchronized ([LuaTest2 class]) {
        sharedLuaTest2 = [super alloc];
        return sharedLuaTest2;
    }
    return nil;
}

static int startTest(lua_State *lua) {
    
    NSLog(@"实现自定义方法");
    
    return 0;
}

static int showControl(lua_State *lua) {
    //此处重写
    NSLog(@"此处重写");
}


const struct luaL_reg test_libs [] = {
    {"showControl", showControl},
    {"startTest", startTest},
    {NULL, NULL}
};

int luaopen_testlibs(lua_State *lua) {
	luaL_register(lua, "window", test_libs);
	return 1;
}

- (void)openTest:(lua_State *)lua {
    lua_s = lua;
    [self openWindowLib:lua];//调用父类（luaWindow）的注册方法,确保luaWindow的所有方法可用
	luaopen_testlibs(lua);
}

@end
