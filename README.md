## Cmcc-l2tpdClient

用于在 linux 连接校园网有线宽带

参考：https://www.jianshu.com/p/85cd5bd3c7a2?tdsourcetag=s_pcqq_aiomsg

### 使用范围

用 l2tp 方式拨号的有线网

测试通过：Ubuntu 20.04 连接移动有线宽带，模拟 Windows 上的 Auth_supplicant

### 前提

1. 需要认证接入内网的先认证
2. 能 ping 通 lns

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

**/etc/xl2tpd/xl2tpd.conf**

```
...

[lac myvpn]
name = username		#拨号时的用户名
lns = 192.168.113.1		#l2tp服务器ip
require pap = no
require chap = yes
require authentication = yes
pppoptfile = /etc/ppp/options.xl2tpd
ppp debug = yes

...
```

**/etc/ppp/chap-secrets**

```
# Secrets for authentication using CHAP
# client    server  secret          IP addresses
# 用户名 星号 密码 星号
username * password *
```

### 拨号

```shell
sudo auth_supplicant
```

确保 /usr/local/bin/ 在环境变量里

输出 `Connection established` 则脚本顺利运行，能不能联网看运气

