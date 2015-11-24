# EMP EWP服务
<!--toc-->

## 概述

对于企业来说，开发出拥有良好用户体验的移动应用，不仅仅需要优秀的前端展现和交互设计，同样也需要不断丰富的后台服务作为支撑。而如何将企业散落在不同系统中的后台服务和数据整合起来，为移动终端用户提供优质的服务流程和体验，是企业在开发移动应用时需要面对的挑战。

EMP Server 正是为了应对这样的挑战而生。为帮助企业实现服务和数据的聚合，EMP Server 支持多种通讯协议，可以同时维持到多个企业后台服务的连接。通过合理的业务规则配置和开发，EMP Server 将来自终端用户的请求转发到业务流程所需的企业后台服务接口，通过对多种类型数据格式的支持，EMP Server 可以将不同服务后台的接口返回数据解析并作为业务流程中的动态数据嵌入到符合 EMP 界面规范的模板中形成报文，最终返回给移动设备前端去渲染并呈现。

通过 EMP Server，企业可以根据业务需求将不同后台系统中服务和数据整合，形成符合移动渠道使用特点的业务流程，给运行在不同平台上的移动终端设备提供统一的服务获取接口和 UI 展现。

一个 EMP Server 由两个基本要素组成：

- Web Service Framework —— EWP
- Web Services Provider —— EWP Applications

## Web Service Framework

EWP 是 EMP Server 的核心组成部分，其定义了三个重要概念：Channel、Collection 和 Adapter。

EWP 将移动应用上一个独立的业务功能封装为一个 Channel，开发者可以遵循 EWP 规定的 Channel 回调机制实现业务逻辑，并通过对应的 Web Service 接口来提供服务内容。

在 EWP 框架中，Collection 表示交易频道或菜单集合，包含若干 Channels 或 Collections。开发者可以用 Collection 构建具有层级结构的菜单。

Adapter 是 EWP 提供的服务获取工具，通过一些列配置和 API，开发者可以方便地与企业服务后台进行交互。

此外，EWP 还为开发者提供了日志、会话管理、数据库驱动、数据解析引擎、模板引擎、字符集转换等实用工具。
 
## Web Services Provider

EWP Applications 是 EMP Server 的重要组成，充当服务提供者角色。一个 EWP Application 封装了一个移动应用所需的所有服务，开发者需要根据服务内容和业务逻辑实现 Channels，并通过 Collection 对交易进行分类组合，形成树状的菜单结构。
