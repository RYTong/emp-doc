# 国密证书生成工具设计

<!-- toc -->

## 需求概述

EMP在5.2版本中支持了国密算法，并在加密信道和离线资源相关功能支持了国密算法。由于目前市面没有标准的、统一的国密证书生成工具。因此我们需要提供EMP国密证书生成工具，满足各个项目生成各自国密证书的需求。

## 功能需求

我们需要实现以下需求：

* 需提供证书和私钥生成指令。
* 需提供证书签发指令。
* 需提供私钥文件加密方法。
* 可输入的证书信息为：Country Name、State or Province Name、Locality Name、Organization Name、Organizational Unit Name、Common Name、Email Address
* 可设置证书有效期
* 证书序列号自动生成

## 设计

### 命令行接口

指令：gen\_emp\_cert 
参数：
* -days 指定有效期
* -encrypt 私钥加密开关。指定时需要在后续交互流程输入密码
* -keyfile 指定签发证书的CA私钥。证书签发时使用。不指定时，生成自签名CA证书。
* -out 指定文件名称前缀
交互式信息输入：
* 如指定-encrypt参数，则提示用户输入私钥加密密码
* 如指定-keyfile参数，则提示用户输入CA私钥解密密码
* 证书信息输入内容：Country Name、State or Province Name、Locality Name、Organization Name、Organizational Unit Name、Common Name、Email Address
输出：证书和私钥文件，证书文件名称由-out参数+“\_cert”组成，私钥文件名称由-out参数+“\_key”组成。

### 有效期设置逻辑

将-days参数转换为GMT秒，通过ERTCryptoX509的setNotBefore和setNotAfter方法设置有效期开始和结束时间。

### 序列号生成逻辑

序列号为自动生成，使用当前时间戳生成。

### 私钥文件

* 私钥格式使用ERTCryptoSM2::ERTEccKey内部结构。
* 加解密方法使用SM4进行对称加密。加密后的私钥文件第一行设为“===EMP Encrypted Key===”文字，标识该密钥已加密。这样在签发时可以判断CA私钥文件是否需要解密。

### 证书和私钥生成逻辑

示例：
<pre>
    ERTCryptoSM2 *server_cert = NULL;
    server_cert = ERTCryptoSM2::generate(ERTCryptoSM2::ECType_Recommendation);
    server_cert->generateKey();
    ERTCryptoSM2::ERTEccKey server_key;
    server_cert->getGD(server_key);
    ERTCryptoX509 x509;
    setX509(&x509, name, serial_num);
    ERTUserData server_der = server_cert->toDerData(&x509);
    ERTUserData key_data = server_key.save();
</pre>

### 证书签发逻辑

示例：
<pre>
    ERTCryptoSM2::ERTEccKey ert_key;
    ERTCryptoSM2 priv_sm2;
    //初始化ert_key
    priv_sm2.fromKey(ert_key);
    x509.setPrivateKey(priv_sm2.getKey());
    ERTUserData server_der = server_cert->toDerData(&x509);
</pre>

### 证书信息设置

通过ERTCryptoX509的setSubjectName(key, value)方法设置证书信息。key分别为countryName、stateOrProvinceName、localityName、organizationName、organizationalUnitName、commonName、emailAddress。

### 文件保存

ERTCryptoSM2::ERTEccKey的save方法和ERTCryptoSM2的toDerData方法都可以生成ERTUserData对象，通过该对象的getData和count方法可以获取首指针和数据长度。利用这两个方法将数据写入文件。

### 文件读取

读取文件内容后，可以通过ERTUserData的append方法初始化ERTUserData类对象。再通过ERTCryptoSM2::ERTEccKey的read方法和ERTCryptoSM2的fromDer方法可以使用ERTUserData对象初始化ERTCryptoSM2::ERTEccKey和ERTCryptoSM2对象。