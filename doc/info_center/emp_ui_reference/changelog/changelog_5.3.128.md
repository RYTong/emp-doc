# 5.3增强版（5.3.128R)变更记录

<!-- toc -->

## 前言

本文档记录5.3增强版（5.3.128R）相对于5.3增强版（5.3.69R）在控件和lua脚本上的变更范围，具体修改内容请点击链接进相关页面查看。

## Lua接口

### 删除接口

- 离线4.0协议废弃[offline:update_hash(callback, parameter)](./lua/Offline.md#offlineupdatehashcallback-parameter)

### 接口变更

- [window:showcontent()](./lua/Window.md#windowshowcontentcontentpath-tag-optionparams)增加回调参数
- [control:setInnerHTML()](./lua/Metatable.html#setinnerhtml)接口增加回调参数

  Date     | Note | Modifier
-----------|------|----------
2016-03-24 | 初版 | zhou.changjin