# Android 特殊问题汇总

<!-- toc -->

## 已知问题列表

### SLT解析问题[14033](https://dev.rytong.me:9998/proj/emp/ticket/14033)

在EMP5.3版本中，产品增加了SLT解析功能（详见[SLT2设计方案](../../../inner_docs/software_process/design/EMP/slt2/design_of_slt2_parsing.md)）。

在SLT解析脚本中使用了协程，任何假设Lua状态机不变的Lua方法执行时都可能有问题。因此，建议对于已发布的版本，要求项目上在SLT中的Lua Snippet只使用Lua原生API，而不要使用客
户端扩展的Lua API（或者一部分）。

或者，若项目确定不使用SLT解析功能，可以将此功能屏蔽。对于5.3.105B以上版本，可通过配置关闭此功能；5.3.105B以下版本，则需要替换定制的luajava.so库屏蔽SLT功能。

## 特殊机型问题

### [11203](https://dev.rytong.me:9998/proj/emp/ticket/11203)

三星S3手机，执行透明度动画时，偶发目标控件背景色变为纯白色，只留有边框线。

### [12399](https://dev.rytong.me:9998/proj/emp/ticket/12399)

系统bug，当table中tr数目过多或者label中文字过少的时候，偶发设置透明度失效。

### [12440](https://dev.rytong.me:9998/proj/emp/ticket/12440)

三星S3手机，window:alert的弹框会抢夺输入框的焦点

### [13039](https://dev.rytong.me:9998/proj/emp/ticket/13039)

三星S3手机，在重复执行showcontent和有动画的hide()操作的时候，偶发出现动画不执行的情况。


 Date      | Note | Modifier
-----------|------|----------
2015-11-16 | 初稿，增加特殊机型问题 | lei.zhihui
2016-03-11 | 增加slt解析问题说明 | zhou.changjin
