我把vivado的所有资源(源)文件放在了 "./vivado_HDL/source"里面.

GenshinKitchen这个快捷方式是windows客户端

GenshinKitchen_vivado这个快捷方式是打开vivado

那两个cmd脚本是打开项目网站和示例github仓库

bit文件里放的是助教提供的示例bit文件

剩余projec说明文件都在"GenshinKitchen_introduction"里面

"测试反馈数据(启动参数为切换毫秒数).exe" 这个是向FPGA发送反馈数据(Feedback Signal)
启动参数是发送的间隔(单位毫秒)
比如: ./测试反馈数据(启动参数为切换毫秒数).exe 100	
是设置发送间隔为100ms

"检测发送数据(启动参数是检测的模式).exe" 这个是检测FPGA版发送到电脑客户端的数据
启动参数是检测模式(0和1,0是检测所有输入,1是检测变化的输入,默认是1)
比如: ./检测发送数据(启动参数是检测的模式).exe 1	
是设置检测模式为1

可能会爆毒,如果你担心的话,源码在others/test里