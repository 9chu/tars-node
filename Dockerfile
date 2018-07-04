FROM centos
MAINTAINER 1871361697@qq.com

WORKDIR /root/
VOLUME ["/data"]

# 设置代理
#ENV http_proxy "http://dev-proxy.oa.com:8080"
#ENV https_proxy "http://dev-proxy.oa.com:8080"

# 设置时区
ENV TZ "Asia/Shanghai"

# 安装必要软件包
RUN yum -y update && yum install -y epel-release && yum install -y crontabs git gcc gcc-c++ gdb make cmake wget net-tools vim nano unzip iproute which glibc-devel flex bison ncurses-devel zlib-devel kde-l10n-Chinese glibc-common perl openvpn

# 创建时区和语言包文件
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone && localedef -c -f UTF-8 -i zh_CN zh_CN.utf8

# 设置语言
ENV LC_ALL "zh_CN.UTF-8"

# 执行安装脚本
COPY install_dep.sh /root/install_dep.sh
RUN chmod +x /root/install_dep.sh && sync && /root/install_dep.sh

COPY install.sh /root/install.sh
RUN chmod +x /root/install.sh && sync && /root/install.sh

# 暴露端口
EXPOSE 19385

# 启动参数
ENV TARS_BIND_INTERFACE eth0
ENV TARS_REGISTRY_HOST registry.tars.com
ENV TARS_REGISTRY_PORT 17890
ENV OPENVPN_ENABLE 0
ENV OPENVPN_CONFIG /data/node.ovpn
ENV OPENVPN_LOG /data/log/openvpn.log

# 创建入口
COPY entrypoint.sh /root/entrypoint.sh
RUN chmod +x /root/entrypoint.sh
ENTRYPOINT [ "/usr/local/sbin/pid1" ]
CMD bash -c "/root/entrypoint.sh"
