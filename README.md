# tars-node

该仓库为腾讯[Tars微服务框架](https://github.com/Tencent/Tars)的节点容器。

此节点容器作为微服务执行的最基本环境，已包含了tarsnode和monitor脚本，基于CentOS镜像构建而成。

## 使用样例

```shell
docker run -v /Users/chu/Docker/node1:/data -e TARS_REGISTRY_HOST=myreg.example.com -d --name node1 9chu/tars-node
```

## 基本参数

- TARS_BIND_INTERFACE

    指定tarsnode绑定的网卡。默认为eth0。

- TARS_REGISTRY_HOST

    指定注册表的主机名。默认为registry.tars.com，必须手动修改。

- TARS_REGISTRY_PORT

    指定注册表的端口。默认为17890。

## 挂载目录

- /data

    容器需要挂载/data目录作为数据目录，如此一来即便重建容器也能恢复其运行的状态。

    在数据目录下将会看到下述子目录。

        /data/log：日志目录
        /data/tars：TARS基础组件数据目录，对于节点容器而言无意义。
        /data/patch：补丁目录。
        /data/node：连接到tarsnode/data，亦为其他服务的部署目录。

## 参考

- https://github.com/tangramor/tars-node
