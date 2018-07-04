#!/bin/bash
set -e
source /etc/profile

# 创建日志目录
if [ ! -d /data/log ]; then
    mkdir -p /data/log
fi

if [ ! -d /data/log/tars ]; then
    mkdir -p /data/log/tars
fi

if [ ! -d /data/log/app_log ]; then
    mkdir -p /data/log/app_log
fi

if [ ! -d /data/log/remote_app_log ]; then
    mkdir -p /data/log/remote_app_log
fi

if [ ! -d /usr/local/app/tars/app_log ]; then
    ln -s /data/log/app_log /usr/local/app/tars/app_log
fi

if [ ! -d /usr/local/app/tars/remote_app_log ]; then
    ln -s /data/log/remote_app_log /usr/local/app/tars/remote_app_log
fi

# 创建数据目录
if [ ! -d /data/tars ]; then
    mkdir -p /data/tars
fi

if [ ! -d /data/tars/data ]; then
    mkdir -p /data/tars/data
fi

if [ ! -d /data/tars/data/tarsconfig ]; then
    mkdir -p /data/tars/data/tarsconfig
fi

if [ ! -d /data/tars/data/tarspatch ]; then
    mkdir -p /data/tars/data/tarspatch
fi

if [ ! -d /data/tars/data/tarsregistry ]; then
    mkdir -p /data/tars/data/tarsregistry
fi

if [ ! -d /usr/local/app/tars/tarsconfig/data ]; then
    ln -s /data/tars/data/tarsconfig /usr/local/app/tars/tarsconfig/data
fi

if [ ! -d /usr/local/app/tars/tarspatch/data ]; then
    ln -s /data/tars/data/tarspatch /usr/local/app/tars/tarspatch/data
fi

if [ ! -d /usr/local/app/tars/tarsregistry/data ]; then
    ln -s /data/tars/data/tarsregistry /usr/local/app/tars/tarsregistry/data
fi

# 创建节点目录
if [ ! -d /data/node ]; then
    mkdir -p /data/node
fi

if [ ! -d /usr/local/app/tars/tarsnode/data ]; then
    ln -s /data/node /usr/local/app/tars/tarsnode/data
fi

# 创建补丁目录
if [ ! -d /data/patch ]; then
    mkdir -p /data/patch
fi
if [ ! -d /usr/local/app/patchs ]; then
    ln -s /data/patch /usr/local/app/patchs
fi

# 获取本机信息
LOCAL_IP=$(ip addr | grep inet | grep ${TARS_BIND_INTERFACE} | awk '{print $2;}' | sed 's|/.*$||')

# 替换配置
sed -i -r "s/locator\s*=\s*tars.tarsregistry.QueryObj@tcp\s+-h\s+.*\s+-p\s+.*/locator=tars.tarsregistry.QueryObj@tcp -h ${TARS_REGISTRY_HOST} -p ${TARS_REGISTRY_PORT}/g" /usr/local/app/tars/tarsnode/conf/tarsnode.conf
sed -i -r "s/localip\s*=\s*.*/localip=${LOCAL_IP}/g" /usr/local/app/tars/tarsnode/conf/tarsnode.conf
sed -i -r "s/endpoint\s*=\s*tcp\s+-h\s+.*\s+-p/endpoint=tcp -h ${LOCAL_IP} -p/g" /usr/local/app/tars/tarsnode/conf/tarsnode.conf

# 拉起tarsnode
chmod u+x /usr/local/app/tars/tarsnode/util/*.sh
chmod u+x /usr/local/app/tars/tarsnode_install.sh && sync && /usr/local/app/tars/tarsnode_install.sh

# 配置crontab
grep -q -F "* * * * * root /usr/local/app/tars/tarsnode/util/monitor.sh" /etc/crontab || echo "* * * * * root /usr/local/app/tars/tarsnode/util/monitor.sh" >> /etc/crontab
crond

# 不退出
tail -f /dev/null
