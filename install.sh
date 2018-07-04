#!/bin/bash
set -e

### 第三方库安装脚本
# 编译MYSQL
mkdir -p /root/source && cd /root/source
git clone https://github.com/mysql/mysql-server --branch=5.6 --depth=1 mysql-server
mkdir -p mysql-server/_build
cd mysql-server/_build
cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local/mysql-5.6 -DWITH_INNOBASE_STORAGE_ENGINE=1 -DMYSQL_USER=mysql -DDEFAULT_CHARSET=utf8 -DDEFAULT_COLLATION=utf8_general_ci
make -j5 && make install && make clean
ln -s /usr/local/mysql-5.6 /usr/local/mysql

# 安装Java-SDK
mkdir -p /root/package && cd /root/package
wget -c -t 0 --header "Cookie: oraclelicense=accept" -c --no-check-certificate http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.rpm
rpm -ivh jdk-8u131-linux-x64.rpm

# 安装Maven & resin
wget -c -t 0 https://mirrors.tuna.tsinghua.edu.cn/apache/maven/maven-3/3.5.3/binaries/apache-maven-3.5.3-bin.tar.gz
wget -c -t 0 http://caucho.com/download/resin-4.0.56.tar.gz
cd /usr/local/
tar zxvf /root/package/apache-maven-3.5.3-bin.tar.gz
tar zxvf /root/package/resin-4.0.56.tar.gz
ln -s /usr/local/apache-maven-3.5.3 /usr/local/apache-maven
ln -s /usr/local/resin-4.0.56 /usr/local/resin

# 安装PID1
cd /root/package
wget -c -t 0 https://github.com/fpco/pid1/releases/download/v0.1.2.0/pid1-0.1.2.0-linux-x86_64.tar.gz
mkdir -p /usr/local/sbin
cd /usr/local
tar zxvf /root/package/pid1-0.1.2.0-linux-x86_64.tar.gz
chmod +x /usr/local/sbin/pid1

# 设置环境变量
echo "/usr/local/mysql/lib/" >> /etc/ld.so.conf && ldconfig
echo "export JAVA_HOME=/usr/java/jdk1.8.0_131" >> /etc/profile
echo "export CLASSPATH=\$JAVA_HOME/lib/dt.jar:\$JAVA_HOME/lib/tools.jar" >> /etc/profile
echo "export MAVEN_HOME=/usr/local/apache-maven" >> /etc/profile
echo "export PATH=\$JAVA_HOME/bin:\$MAVEN_HOME/bin:/usr/local/mysql/bin:\$PATH" >> /etc/profile

# 测试
source /etc/profile && mvn -v

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
chmod u+x build.sh && sync
./build.sh all && sync && ./build.sh install && sync
make framework-tar && make tarsstat-tar && make tarsnotify-tar && make tarsproperty-tar && make tarslog-tar && make tarsquerystat-tar && make tarsqueryproperty-tar
make clean
mkdir -p /usr/local/app/tars/ && cd /usr/local/app/tars/ && sync
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
