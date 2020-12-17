## Cmcc-l2tpdClient

用于在 linux 连接校园网有线宽带

### 使用范围

用 l2tp 方式拨号的有线网

测试通过：Ubuntu 20.04 连接移动有线宽带，模拟 Windows 上的 Auth_supplicant 

### 安装

```shell
bash setup.sh
```

或者

```shell
chmod +x setup.sh
./setup.sh
```

### 配置

文件不存在，需要自己创建

###### /etc/xl2tpd/xl2tpd.conf

```
[lac testvpn]
name = testvpn
lns = 192.168.113.1    #l2tp服务器ip
pppoptfile = /etc/xl2tpd/testvpn.l2tpd
ppp debug = yes
```

###### /etc/xl2tpd/testvpn.l2tpd (和xl2tpd.conf里pppoptfile处的位置一致)

```
remotename testvpn
user "username" #拨号用户名
password "password" #拨号密码
unit 0
nodeflate
noauth
persist
noaccomp
maxfail 5
usepeerdns 
debug
```

### 拨号

```shell
sudo auth_supplicant
```

确保 /usr/local/bin/ 在环境变量里

输出 `Connection established` 则脚本顺利运行，能不能联网看运气

