# 迁移项目到代码服务器
<!-- toc -->

## 迁移项目
以emp为例。
### 拷贝已有的项目代码
ssh到`192.168.64.10`代码服务器上， 执行：

```
scp -rv /home/trac/emp root@192.168.64.239:/home/trac/
scp -rv /home/hg/repos/proj/emp root@192.168.64.239:/home/hg/repos/proj/
```
### 修改已有项目配置
修改所有trac项目的`trac.ini`的inherit的配置。

```
vi /home/trac/emp/conf/trac.ini
[inherit]
file = /home/hg/scripts/trac.ini
```
### 升级已有trac项目
```
trac-admin /home/trac/emp upgrade
trac-admin /home/trac/emp wiki upgrade
```
