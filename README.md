# PythonAnsible
Python的Ansible代码

Ansible安装方法：
Centos：sudo yum install ansible
Ubuntu:sudo apt install ansible

阅读顺序：
ansible.cfg:ansible配置文件，默认路径在/etc/ansible/
hosts:ansible主机配置文件，默认路径在/etc/ansible/
ansible_test.sh:ansible命令测试文件
script.sh:配合ansible_test.sh测试
ansible_playbook_test.yml:剧本测试文件
templates/httpd.j2:作为模板的apache默认配置文件
index.html:自定义首页
vars.yml:变量yml文件
from.txt:参考来源