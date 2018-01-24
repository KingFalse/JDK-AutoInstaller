# JDK-AutoInstaller
Windows环境下自动安装JDK，自动配置环境变量

## 如何使用？
* 下载JDK
* 将JDK-AutoInstaller-v1.0.bat跟JDK安装包放在同一目录
* 双击JDK-AutoInstaller-v1.0.bat脚本即可开始安装
* 等待安装完成然后重启电脑即可

## 支持的操作系统？
* win7 / win8.x / win10 
* x86跟x64
* 以及对应的Server版本操作系统

## 支持的JDK版本？
* Oracle JDK 8-9

## Q&A?
### Q1 : 默认安装目录?
* %ProgramFiles(x86)%\Java\jdk
* %ProgramFiles(x86)%\Java\jre
* 或者：
* %ProgramFiles%\Java\jdk
* %ProgramFiles%\Java\jre

### Q2 : 如何自定义JDK跟JRE的安装目录?
* 自定义安装目录有两种方式
* 方式一：(建议)
* 通过命令行参数：JDK-AutoInstaller-v1.0.bat "C:\jdk" "C:\jre"
* 方式二：
* 修改JDK-AutoInstaller-v1.0.bat第83-84行
~~~bat
83| set "absjdkpath="     修改后     set "absjdkpath=C:\jdk"
84| set "absjrepath="     修改后     set "absjrepath=C:\jre"
~~~

### Q3 : 环境变量?
* 安装完成会自动配置环境变量，您只需重启一下即可

## 特色？
* 支持自定义安装目录
* 自动配置环境变量，采用修改注册表方式，完全防覆盖
* 支持UAC权限申请
* 绿色单文件

## 示例
* win7x64 && JDK-8u161-i586

![](example/1.gif)
* win8.1x86 && JDK-8u161-i586

![](example/2.gif)
* win10x64 && JDK9.0.4

![](example/3.gif)
