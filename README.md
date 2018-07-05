# tars-node

该仓库为腾讯[Tars微服务框架](https://github.com/Tencent/Tars)的节点容器。

此节点容器作为微服务执行的最基本环境，已包含了tarsnode和monitor脚本，基于CentOS镜像构建而成。

## 使用样例

```shell
docker run -v /Users/chu/Docker/node1:/data -e TARS_REGISTRY_HOST=myreg.example.com -d --name node1 9chu/tars-node
```

当启用OpenVPN时：

```shell
docker run -v /Users/chu/Docker/node1:/data --cap-add NET_ADMIN -e OPENVPN_ENABLE=1 -e OPENVPN_CONFIG=/data/node1.ovpn -e TARS_REGISTRY_HOST=myreg.example.com -d --name node1 9chu/tars-node
```

注意：OpenVPN应当分配静态IP地址。

## 基本参数

- TARS_BIND_INTERFACE

    指定tarsnode绑定的网卡。默认为eth0。

- TARS_REGISTRY_HOST

    指定注册表的主机名。默认为registry.tars.com，必须手动修改。

- TARS_REGISTRY_PORT

    指定注册表的端口。默认为17890。

- OPENVPN_ENABLE

    是否启用OpenVPN，用于组建跨机器部署的环境。默认为0。

- OPENVPN_CONFIG

    指定OpenVPN客户端配置文件。默认为/data/node.ovpn。

- OPENVPN_LOG

    指定OpenVPN的日志文件路径。默认为/data/log/openvpn.log。

## 挂载目录

- /data

    容器需要挂载/data目录作为数据目录，如此一来即便重建容器也能恢复其运行的状态。

    在数据目录下将会看到下述子目录。

        /data/log：日志目录
        /data/tars：TARS基础组件数据目录，对于节点容器而言无意义。
        /data/patch：补丁目录。
        /data/node：连接到tarsnode/data，亦为其他服务的部署目录。

## 暴露端口

- 19385

    节点端口，当前容器的节点对外暴露的服务端口。

## 参考

- https://github.com/tangramor/tars-node
