# 获取全部模块的信息后查询ssh相关的·
ansible-doc -l |grep ssh
# 获取指定模块的使用帮助
ansible-doc -s ssh


#公钥登陆被控主机
# 生成私钥
ssh-keygen 
# 复制到被控主机
ssh-copy-id test2@192.168.1.32

# 测试连通性，test为hosts文件内的分组名，-m表示使用模块
ansible test -m ping

# command模块，-a表示args参数，该命令不支持| 管道命令
ansible test -m command -a 'ps -ef'
# chdir 在执行命令之前，先切换到该目录
ansible test -m command -a 'chdir=/tmp ls'
# executable 切换shell来执行命令，需要使用命令的绝对路径，不推荐使用
# free_form 要执行的Linux指令，一般使用Ansible的-a参数代替
# creates 文件存在则后面命令不执行
ansible test -m command -a 'creates=/tmp/1.txt ls'
# removes 文件不存在则后面命令不执行
ansible test -m command -a 'removes=/tmp/1.txt ls'
