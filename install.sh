#!/bin/bash
set -e

### TARS安装脚本
# 克隆Tars
mkdir -p /root/source && cd /root/source
git clone https://github.com/Tencent/Tars --depth=1 Tars
cd Tars/cpp/thirdparty
chmod +x thirdparty.sh && sync
./thirdparty.sh

# 编译CPP部分
mkdir -p /data
cd /root/source/Tars/cpp/build
cp CMakeLists.txt ../ && cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo && make && make install && make clean
make framework-tar && make tarsstat-tar && make tarsnotify-tar && make tarsproperty-tar && make tarslog-tar && make tarsquerystat-tar && make tarsqueryproperty-tar
mkdir -p /usr/local/app/tars/ && cd /usr/local/app/tars/
tar zxvf /root/source/Tars/cpp/build/framework.tgz && sync
if [ ! -f "/usr/local/app/tars/tarsnode/conf/tarsnode.conf" ]; then
    (>&2 echo "unknown error")
    exit 1
fi

# 编译JAVA部分
#proxy_mvn='mvn -Dhttp.proxyHost=dev-proxy.oa.com -Dhttp.proxyPort=8080 -Dhttp.nonProxyHosts=localhost -Dhttps.proxyHost=dev-proxy.oa.com -Dhttps.proxyPort=8080 -Dhttps.nonProxyHosts=localhost'
proxy_mvn='mvn'
source /etc/profile
cd /root/source/Tars/java
$proxy_mvn clean install && $proxy_mvn clean install -f core/client.pom.xml && $proxy_mvn clean install -f core/server.pom.xml

cd /root/source/Tars/web/src/main/resources
sed -i "s/DEBUG/INFO/g" `grep DEBUG -rl .`
cd /root/source/Tars/web
$proxy_mvn clean package
cp /root/source/Tars/build/conf/resin.xml /usr/local/resin/conf/
sed -i 's/servlet-class="com.caucho.servlets.FileServlet"\/>/servlet-class="com.caucho.servlets.FileServlet">\n\t<init>\n\t\t<character-encoding>utf-8<\/character-encoding>\n\t<\/init>\n<\/servlet>/g' /usr/local/resin/conf/app-default.xml
sed -i 's/<page-cache-max>1024<\/page-cache-max>/<page-cache-max>1024<\/page-cache-max>\n\t\t<character-encoding>utf-8<\/character-encoding>/g' /usr/local/resin/conf/app-default.xml
cp /root/source/Tars/web/target/tars.war /usr/local/resin/webapps/
