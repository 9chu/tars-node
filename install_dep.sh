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
