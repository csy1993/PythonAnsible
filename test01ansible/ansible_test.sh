# 获取全部模块的信息后查询ssh相关的·
ansible-doc -l |grep ssh
# 获取指定模块的使用帮助
ansible-doc -s ssh

#公钥登陆被控机
# 生成私钥
ssh-keygen 
# 复制到被控机
ssh-copy-id test2@192.168.1.32

# -m表示使用模块
# ping模块
# 测试连通性，test为/etc/ansible/hosts文件内的分组名
ansible test -m ping

# command模块，-a表示args参数，该命令不支持| 管道命令
ansible test -m command -a 'ps -ef'
# chdir 在执行命令之前，先切换到该目录
ansible test -m command -a 'chdir=/tmp ls'
# executable 切换shell来执行命令，需要使用命令的绝对路径，不推荐使用
# free_form 要执行的Linux指令，一般使用Ansible的-a参数代替
# creates 文件不存在则执行后面命令
ansible test -m command -a 'creates=/tmp/1.txt ls'
# removes 文件存在则执行后面命令
ansible test -m command -a 'removes=/tmp/1.txt ls'

# shell模块，与bash一致
# 查找test用户是否存在
ansible test -m shell -a 'cat /etc/passwd |grep "test"'

# copy模块，复制文件
# 在主控机本地新建空白文档1.txt
touch 1.txt
# src 被复制到被控机的本地文件。可以是绝对路径，也可以是相对路径。如果路径是一个目录，则会递归复制，用法类似于"rsync"
# dest 必选项，将源文件复制到被控机的绝对路径
# 将主控机用户目录下的1.txt复制到被控机用户目录下的1.txt
ansible test -m copy -a 'src=~/1.txt dest=~/1.txt'
# 通过ansible查看结果
ansible test -m shell -a 'ls -alh'
# content 可以直接指定文件的值
# 复制指定内容
ansible test -m copy -a 'content="I am csy\n" dest=~/2.txt'
# backup 当文件内容发生改变后，在覆盖之前把源文件备份，备份文件包含时间信息
ansible test -m copy -a 'content="You are mine\n" dest=~/2.txt backup=yes'
# 主控机本地新建一个目录3和内部的文件4.txt，查看权限
mkdir 3
touch 3/4.txt
ll -ah
ll -ah 3
# directory_mode 递归设定目录的权限，默认为系统默认权限，mode为文件权限，用法一致
ansible test -m copy -a 'src=~/3 dest=~/3 directory_mode=777'
# 改变主控机1.txt内容
echo "Changed" >> 1.txt
# force 当被控机包含该文件，但内容不同时，设为"yes"，表示强制覆盖；设为"no"，表示被控机的目标位置不存在该文件才复制。默认为"yes"
ansible test -m copy -a 'src=~/1.txt dest=~/1.txt force=yes'
# others 所有的 file 模块中的选项可以在这里使用

# file模块，文件操作
# path 必须参数，定义被控机文件/目录的路径
# state 状态，有以下选项：
    # directory：如果目录不存在，就创建目录
    # file：即使文件不存在，也不会被创建
    # link：创建软链接
    # hard：创建硬链接
    # touch：如果文件不存在，则会创建一个新的文件，如果文件或目录已存在，则更新其最后修改时间
    # absent：删除目录、文件或者取消链接文件
# 在被控机用户目录下创建5文件夹
ansible test -m file -a 'path=~/5 state=directory'
# dest 被链接到的路径，只应用于state=link的情况
# 在被控机用户目录下创建指向5的软连接6
ansible test -m file -a 'path=~/6 src=~/5 state=link'
# force 默认为yes，还有no选项。当state=link的时候，可配合此参数强制创建链接文件，当force=yes时，表示强制创建链接文件，分为三种情况。
# 情况一：当要创建的链接文件指向的源文件并不存在时，使用此参数，可以先强制创建出链接文件。
# 情况二：当要创建链接文件的目录中已经存在与链接文件同名的文件时，将force设置为yes，会将同名文件覆盖为链接文件，相当于删除同名文件，创建链接文件。
# 情况三：当要创建链接文件的目录中已经存在与链接文件同名的文件，并且链接文件指向的源文件也不存在，这时会强制替换同名文件为链接文件。
# 将原来指向5文件夹的6连接修改为指向3
ansible test -m file -a 'path=~/6 src=~/3 state=link force=yes'
# group 定义文件/目录的属组
# owner 定义文件/目录的属主
# mode 定义文件/目录的权限
# recurse 递归设置文件的属性，只对目录有效
#TODO:用root无此问题，普通用户修改属主和属组需要sudo权限
# 加入-b后提示需要sudo密码但python3的ansible无--ask-sudo-pass参数
# 可临时通过在hosts文件中用明文密码，因后期大部分操作通过ansible-playbook操作，故不在此处深究
ansible test -b -m file -a 'path=~/3 group=CSY owner=CSY mode=666 recurse=yes'

# fetch模块，远程复制
# dest 主控机用来存放文件的目录
# src 被控机文件路径，并且必须是一个file，不能是目录
# 复制被控机的2.txt到主控机的7.txt，会根据IP和被控机路径生成目录和文件
ansible test -m fetch -a 'dest=7.txt src=2.txt'

# cron模块，和linux下语法一致
# day 日应该运行的工作( 1-31, *, */2, )
# hour 小时 ( 0-23, *, */2, )
# minute 分钟( 0-59, *, */2, )
# month 月( 1-12, *, /2, )
# weekday 周 ( 0-6 for Sunday-Saturday,, )
# job 指明运行的命令是什么
# name 定时任务描述
# reboot 任务在重启时运行，不建议使用，建议使用special_time
# special_time 特殊的时间范围，参数：reboot（重启时），annually（每年），monthly（每月），weekly（每周），daily（每天），hourly（每小时）
# state 指定状态，present表示添加定时任务，也是默认设置，absent表示删除定时任务
# user 以哪个用户的身份执行
# 创建一个每5分钟ls当前目录的定时任务
ansible test -m cron -a 'name="ls every 5 min" minute=*/5 job="/usr/bin/ls >> /tmp/ls.txt"'
# 删除任务
ansible test -m cron -a 'name="ls every 5 min" state=absent'

# yum模块，用于软件安装，apt类似
# name 所安装的包的名称
# state present安装， latest安装最新的, absent卸载软件。
# update_cache 强制更新yum的缓存
# conf_file 指定远程yum安装时所依赖的配置文件（安装本地已有的包）。
# disable_pgp_check 是否禁止GPG checking，只用于presentor latest。
# disablerepo 临时禁止使用yum库。 只用于安装或更新时。
# enablerepo 临时使用的yum库。只用于安装或更新时。
# 安装ftp服务端，需要sudo权限
ansible test -b -m yum -a 'name=vsftpd state=present'

# service模块，管理服务
# arguments 命令行提供额外的参数
# enabled 设置开机启动。
# name 服务名称
# runlevel 开机启动的级别，一般不用指定。
# sleep 在重启服务的过程中，是否等待。如在服务关闭以后等待2秒再启动。(定义在剧本中。)
# state 有四种状态，分别为：started启动服务， stopped停止服务， restarted重启服务， reloaded重载配置
# 关闭vsftpd服务
ansible test -b -m service -a 'name="vsftpd" state=started'

# user模块,管理用户
# comment 用户的描述信息
# createhome 是否创建家目录
# force 在使用state=absent时, 行为与userdel –force一致.
# group 指定基本组
# groups 指定附加组，如果指定为(groups=)表示删除所有组
# home 指定用户家目录
# move_home 如果设置为home=时, 试图将用户主目录移动到指定的目录
# name 指定用户名
# non_unique 该选项允许改变非唯一的用户ID值
# password 指定用户密码
# remove 在使用state=absent时, 行为是与userdel –remove一致
# shell 指定默认shell
# state 设置帐号状态，不指定为创建，指定值为absent表示删除
# system 当创建一个用户，设置这个用户是系统用户。这个设置不能更改现有用户
# uid 指定用户的uid
ansible test -b -m user -a 'comment="A test user" createhome=yes group="CSY" name="test" password="123456" uid="20001"'

# group模块，管理组
# gid 设置组的GID号
# name 指定组的名称
# state 指定组的状态，默认为创建，设置值为absent为删除
# system 设置值为yes，表示创建为系统组
ansible test -b -m group -a 'gid="20001" name="test"'

# script模块，在被控机执行主控机脚本
# 在被控机运行主控机当前目录下的script.sh文件
ansible test -m script -a 'script.sh'

# setup模块，收集信息，是通过调用facts组件来实现的
# facts组件是Ansible用于采集被管机器设备信息的一个功能，我们可以使用setup模块查机器的所有facts信息，可以使用filter来查看指定信息。
# 整个facts信息被包装在一个JSON格式的数据结构中，ansible_facts是最上层的值。
# facts就是变量，内建变量 。每个主机的各种信息，cpu颗数、内存大小等。会存在facts中的某个变量中。
# 调用后返回很多对应主机的信息，在后面的操作中可以根据不同的信息来做不同的操作。如redhat系列用yum安装，而debian系列用apt来安装软件。
# 查看内存
ansible test -m setup -a 'filter="*mem*"'
# 保存在本地
ansible test -m setup -a 'filter="*mem*"' --tree /tmp/mem.txt