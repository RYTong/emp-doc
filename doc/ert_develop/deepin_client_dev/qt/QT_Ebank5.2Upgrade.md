 #Qt升级说明

##一. Qt升级调研
###1. 可行性分析
从Qt4.8版本升级到Qt5.4版本，Qt的变化和修改。

1.1 插件包的修改

	Qt5.4版本去除phonon音视频插件，增加多媒体库multimedia。需要对qt平台产品中的音视频类进行重写。
1.2 部分头文件位置修改

	需要修改源码中部分头文件查找位置。例如：#include<QtGui/QApplication>改为#include<Qapplication>
1.3 Qt API的替换和删除

	替换掉的接口需要根据Qt文档替换；删除的接口需要改用其他方法实现，带来的问题就是产品的一些原有功能需要重新实现。
	
1.4 Qt控件修改
	
	控件优化或修改会影响当前产品中定制控件的显示效果或功能，这部分需要测试和修改。

1.5 工程编码方式修改

	Qt5.4默认编码方式是utf-8，工程中的编码操作相关都需要作调整。

1.6 总结

	升级qt版本到Qt5.4可行，升级过程中可以将代码优化一并做了。

	
###2. 升级遇到的问题及解决方法

2.1 工程.pro文件的修改

	. 去掉音视频插件 (phonon) ,增加qt 多媒体库multimedia：Qt += multimedia；调研发现升级后的插件包还是不支持播放MP4格式视频。
	. 修改gui库配置为widgets库，添加：Qt += widgets。
2.2 Qt Api代码替换

	QtAPI的替换和删除（例如编码api，toAscii（）接口被替换，QTextCodec::setCodecForCStrings()接口被删除）
2.3 对C++11标准的支持

	当Qt的系统上安装了C++11，默认建立链接系统的C++ 11库（libc++）。为了能够支持较旧的C++标准（libstdc++），需要修改构建中的C++11编译配置选项。
	 
2.4 Qt的图形视图框架变动

	Qt平台的产品开发，基于qt的图形视图框架。重点是 Qt5.4的图形视图框架是否有大的变动，如果有大的变动工作量会很大。目前根据Qt5.4帮助文档，图形视图框架变动不大。
	 
2.5 增加了信号槽基于函数指针方式链接的支持（这种方式不再局限于信号槽参数统一问题）
	
###3. Qt5.4部分新特性
	. Qt5.4支持html5混合开发，增加基于chromium引擎的QWebEngine，实现qt与html5混合开发。QWebEngine不仅提供了易于使用的跨平台API，还完全集成了Qt的图形库，允许网页内容进行叠加，并与Qt用户界面或OpenGL图形效果混合。
	. Qt5.4还针对几大主流移动平台进行了改进，更适用于iOS 8和Xcode 6，而Qt Quick还增加了对Android原生应用风格的支持。引入WP的支持。
	. 信号槽链接：
		string-based 和 functor-based（qt新增附加语法） connect（）区别
		1. string-based只有运行时（run-time）才会检测错误。
		functor-based编译过程中检测错误。
		2. string-based 槽函数不支持匿名函数
		functor-based 槽函数支持匿名函数	
		3. string-based 支持信号槽参数不兼容
		functor-based 不支持信号槽参数不兼容
	. QRegularExpression 提供了兼容Perl语言正则表达式更好的支持。
	. OpenGL 相关类的修改，当前OpenGl相关类移动到Qt GUI 模块。
	. 增加了QJson支持。
	
###4. 升级参考文档

	. http://doc.qt.io/qt-5/qt5-intro.html Qt官方版本升级更改文档
	. http://doc.qt.io/qt-5/whatsnew50.html
	. http://doc.qt.io/qt-5/whatsnew51.html
	. http://doc.qt.io/qt-5/whatsnew52.html
	. http://doc.qt.io/qt-5/whatsnew53.html
	. http://doc.qt.io/qt-5/whatsnew54.html


##二. 音视频类的修改
Qt5.4.0不再支持phonon音视频插件。以前用phonon写的相关代码都需要做修改，其中涉及音频类：RYTLuaAudioManager、RYTAudioPlayer、LuaAudio，视频相关类R：YTLuaVideoManager、RYTVideoPlayer、LuaVideo。新的音视频插件用multimedia。

###1. 音频类修改

####1.1 RYTAudioPlayer
此类继承自QWidget，并二次封装了QMediaPlayer的功能，包括：播放、暂停、停止等功能。
	
成员函数及其说明：
	
	public:
	QString getAudioName();		// 获取Audio的名称（名称：是加载Audio的全路径）
    bool loadAudioPlayerFile(const QString& aAudioName); // 加载音频播放器
    void startAudioPlayer(int nCallBackId = 0, int numberOfLoops = 0); // 开启音频播放器
    void stopAudioPlayer();		// 关闭音频播放器
    void pauseAudioPlayer();	// 暂停音频播放器
    void resumeAudioPlayer();	// 恢复音频播放器
    qreal getAudioVolume();		// 获得音频播放器音量
    void setAudioVolume(qreal volume = 50.0);	// 设置音频播放器音量
    int getAudioMaxVolume();	// 获得音频播放器最大音量
    int getAudioMinVolume();	// 获得音频播放器最小音量
    void makeShow();			// 显示音频播放器窗口
    void makeClose();			// 关闭音频播放器窗口

	public slots:
	// 获得音频播放器状态改变的槽函数
    void slotStateChanged(QMediaPlayer::State newState);	
	
成员变量及其说明：

	int           m_nAudioLoop;    // 单个音频播放的循环次数
    int           m_nCallBackID;   // 回调的ID值，音频播放完之后进行回调
    QMediaPlayer *m_pMediaPlayer;  // 音频播放器
    QString       m_strAudioName;  // 音频名称（加载Audio的全路径）


####1.2 RYTLuaAudioManager
RYTLuaAudioManager管理RYTAudioPlayer，并用QHash存储被加载到内存中的所有音频播放器。它是一个单例，RYTLuaAudioManager类二次封装了RYTAudioPlayer一些函数功能，供使用者调用。总之，该类负责管理内存中已经被创建的音频播放器。
	
成员函数及其说明：

	public:
	// 根据aAudioName加载服务器上（或者本地）的音频文件；若加载成功，返回音频对象，否则为NULL。
	QObject * loadAudioFile(const QString& aAudioName);
    void startPlay(QObject* object, int callbackID = 0, int loopsNumber = 0); // 开启音频播放器object
    void stopPlay(QObject* object);	// 停止音频播放器object
    void pause(QObject* object);	// 暂停音频播放器object
    void resume(QObject* object);	// 恢复音频播放器object
    void disposeObject(QObject* object);  // 销毁音频播放器object
    qreal getVolume(QObject* object);	  // 获得音频播放器object的音量
    void setVolume(QObject* object,qreal volume = 50); // 设置音频播放器object的音量
    int  getMaxVolume(QObject* object);   // 获得音频播放器object的最大音量
    int  getMinVolume(QObject* object);   // 获得音频播放器object的最小音量
    void makeShow(QObject* object);       // 显示音频播放器object
    void setAudioParent(QObject* object, QWidget *aWidget = 0);  // 设置音频播放器object的父窗口
    Q_INVOKABLE void cleanAllAudios();	  // 清空此类管理的所有音频播放器
    void notifyPlayEnd(int nCallBackID);  // 音频播放结束后告知LuaAudio启用回调
    void stopAllPlayer();		// 关闭所有音频播放器

成员变量及其说明

    RYTBankClient_UI            *m_pBankClientUi;	// 此窗口作为新建音频播放器的父窗口
    QHash<QString, RYTAudioPlayer*>  m_rytAudioPlayerList; // 存储已经加载的音频播放器
    QString                     m_strCurPlayerPath;     // 当前正在播放的音频的全路径

###2. 视频类修改

####1.1 RYTVideoPlayer
封装的一个简单视频播放器，显示视频播放窗口，提供播放、暂停、关闭播放器功能。
	
成员函数及其说明：
	
	public:
	    RYTVideoPlayer(QWidget *parent = NULL, Qt::WindowFlags = 0);
	    ~RYTVideoPlayer();
	
	    /**
	     * @brief loadVideoFile 播放器加载资源
	     * @param strVideoSourcePath 资源路径
	     */
	    void loadVideoFile(QString &strVideoSourcePath);
	
	    /**
	     * @brief startVideoPlay 开始视频播放
	     */
	    void startVideoPlay();
	
	    /**
	     * @brief pauseVideoPlay 暂停视频播放
	     */
	    void pauseVideoPlay();
	
	    /**
	     * @brief resumeVideoPlay 恢复视频播放
	     */
	    void resumeVideoPlay();
	
	    /**
	     * @brief stopVideoPlay 停止视频播放
	     */
	    void stopVideoPlay();
	
	    /**
	     * @brief getVideoVolume 获取视频音量
	     * @return 视频音量值
	     */
	    int getVideoVolume();
	
	    /**
	     * @brief setVideoVolume 设置视频音量
	     * @param nVolume 音量值
	     */
	    void setVideoVolume(int nVolume = 50);
	
	    /**
	     * @brief setFrame 设置播放器几何位置
	     * @param nX x轴坐标
	     * @param nY y轴坐标
	     * @param nWidth 宽
	     * @param nHeight 高
	     */
	    void setFrame(int nX, int nY, int nWidth, int nHeight);
	
	    /**
	     * @brief setPlayEndCallBackId 设置视频播放结束的回调
	     * @param nCallBackId 回调id
	     */
	    void setPlayEndCallBackId(int nCallBackId){m_nCallBackId = nCallBackId;}
	
	    /**
	     * @brief getPlayEndCallBackId 获取视频播放结束的回调
	     * @return 回调Id
	     */
	    int getPlayEndCallBackId(){return m_nCallBackId;}
	
	    /**
	     * @brief showVideoPlayer 显示视频播放器
	     */
	    void showVideoPlayer();
	
	    /**
	     * @brief hideVideoPlayer 隐藏视频播放器
	     */
	    void hideVideoPlayer();
	signals:
	    /**
	     * @brief stateChanged 通知视频管理器当前视频播放状态改变
	     */
    void stateChanged(QMediaPlayer::State);
	
	public slots:
	    /**
     	* @brief slotVidoStateChanged 通知管理器 视频播放器停止，暂停，开始播放
     	* @param status 视频播放器状态
     	*/
    	void slotVidoStateChanged(QMediaPlayer::State status);
	
	    /**
	     * @brief slotCloseButtonClicked 监听关闭视频按钮信号
	     */
	    void slotCloseButtonClicked();
	
	    /**
	     * @brief slotPauseButtonClicked 监听暂停、播放视频按钮信号
	     */
	    void slotPauseButtonClicked();

	
成员变量及其说明：

	private:
	   QMediaPlayer *m_pMediaPlayer; //多媒体播放类
	   QString m_strMediaSource;//多媒体资源路径
	   QVideoWidget *m_pVideoWidget;//视频播放窗口
	   int m_nCallBackId; //播放结束回调
	   QPushButton *m_pBtnClose;//关闭播放器按钮
	   QPushButton *m_pBtnPause;//暂停播放器按钮


####1.2 RYTLuaVideoManager
视频管理器类，RYTLuaVideoManager管理通过lua接口启动的视频播放器(RYTVideoPlayer)，设计该类为单例模式。原理是通过hash管理一个视频播放器的列表，转发lua接口对单个视频播放器的操作，并根据界面跳转逻辑管理当前视图中所有视频播放器。
	
成员函数及其说明：

	public:
	
	    virtual ~RYTLuaVideoManager();
	
	    /**
	     * @brief getInstance 获取视频管理器的单例
	     * @return
	     */
	    static RYTLuaVideoManager *getInstance();
	
	    /**
	     * @brief destroyInstance 销毁视频管理器单例
	     */
	    static void destroyInstance();
	
	    /**
	     * @brief loadVideoFileManager 创建视频播放器，并加载视频资源
	     * @param strVideoSourcePath 视频资源路径
	     * @return 返回视频播放器指针
	     */
	    RYTVideoPlayer *loadVideoFileManager(QString &strVideoSourcePath);
	
	    /**
	     * @brief startVideoPlayer 通知视频播放器，开始播放视频
	     * @param pPlayer 播放器
	     */
	    void startVideoPlayer(RYTVideoPlayer *pPlayer = NULL );
	
	    /**
	     * @brief pauseVideoPlayer 通知播放器暂停播放视频
	     * @param pPlayer 播放器
	     */
	    void pauseVideoPlayer(RYTVideoPlayer *pPlayer = NULL );
	
	    /**
	     * @brief resumeVideoPlayer 通知视频播放器回复播放视频
	     * @param pPlayer 播放器
	     */
	    void resumeVideoPlayer(RYTVideoPlayer *pPlayer = NULL );
	
	    /**
	     * @brief stopVideoPlayer 通知视频播放器停止播放视频
	     * @param pPlayer 播放器
	     */
	    void stopVideoPlayer( RYTVideoPlayer *pPlayer = NULL );
	
	    /**
	     * @brief destroyVideoPlayer 通知视频播放器关闭
	     * @param pPlayer 视频播放器
	     * @return true删除成功
	     */
	    bool destroyVideoPlayer(RYTVideoPlayer *pPlayer = NULL );
	
	    /**
	     * @brief getVideoPlayerVolume 获取视频播放器音量
	     * @param pPlayer 视频播放器
	     * @return 返回当前视频播放器音量
	     */
	    int getVideoPlayerVolume(RYTVideoPlayer *pPlayer = NULL );
	
	    /**
	     * @brief setVideoPlayerVolume 设置视频播放器音量
	     * @param pPlayer 视频播放器
	     * @param nVolume 音量值
	     */
	    void setVideoPlayerVolume(RYTVideoPlayer *pPlayer = NULL, int nVolume = 50 );
	
	    /**
	     * @brief setVideoPlayerParent 设置视频播放器父窗口，固定播放器窗口位置
	     * @param pParent 父窗口
	     * @param pPlayer 视频播放器
	     */
	    void setVideoPlayerParent(QWidget *pParent = NULL,RYTVideoPlayer *pPlayer = NULL );
	
	    /**
	     * @brief setVideoPlayerFrame 设置视频播放器几何位置
	     * @param pPlayer 视频播放器
	     * @param nX x轴坐标
	     * @param nY y轴坐标
	     * @param nWidth 宽
	     * @param nHeight 高
	     */
	    void setVideoPlayerFrame(RYTVideoPlayer *pPlayer = NULL, int nX = 0, int nY = 0, int nWidth = 320, int nHeight = 460 );
	
	    /**
	     * @brief setPlayEndCallBackId 设置视频播放结束的回调
	     * @param pPlayer 播放器
	     * @param nCallBackId 回调id
	     */
	    void setPlayEndCallBackId(RYTVideoPlayer *pPlayer = NULL, int nCallBackId = 0);
	    /**
	     * @brief showVideoPlayer 显示视频播放器
	     * @param pPlayer 视频播放器
	     */
	    void showVideoPlayer(RYTVideoPlayer *pPlayer = NULL);
	
	    /**
	     * @brief hideVideoPlayer 隐藏视频播放器
	     * @param pPlayer 视频播放器
	     */
	    void hideVideoPlayer(RYTVideoPlayer *pPlayer = NULL);
	
	    /**
	     * @brief isContainThisPlayer 视频管理器列表中是否有该播放器
	     * @param pPlayer 播放器
	     * @return true:列表中有， false:列表中无
	     */
	    bool isContainThisPlayer(RYTVideoPlayer *pPlayer = NULL );
	
	signals:
	    void signalPlayEnd(int);
	public slots:
	    /**
	     * @brief cleanAllVideos 清理当前界面中的视频播放器
	     */
	    Q_INVOKABLE void cleanAllVideos();
	
	    /**
	     * @brief slotVideoStateChanged 通知管理器 视频播放器停止，暂停，开始播放
	     * @param status 视频播放器状态
	     */
	    void slotVideoStateChanged(QMediaPlayer::State status);
	
	private:
	   RYTLuaVideoManager(QObject *parent = NULL );
	   RYTLuaVideoManager & operator =(RYTLuaVideoManager &that);
	   RYTLuaVideoManager(RYTLuaVideoManager &that);


成员变量及其说明

	private:
	
	   /**
	    * @brief m_pSelf 单例句柄
	    */
	   static RYTLuaVideoManager *s_pSelf;
	
	   /**
	    * @brief m_pBankClientUi 视频播放器父窗口
	    */
	   RYTBankClient_UI *m_pBankClientUi;
	
	   /**
	    * @brief m_sourcePathMapPlayer 视频播放器与多媒体资源的映射
	    */
	   QHash<QString, RYTVideoPlayer*> m_sourcePathMapPlayer;


##三. QCA库的替换

QCA：Qt Cryptographic Architecture是一个非常好的用于Qt平台的加密解密类库，它基于openssl，提供常见的对称、非对称算法。Qt从4.8.1升级到5.4.0之后，对应的QCA库也需要被重新编译。目前QCA的最新版本是2.1.0，经过编译后却无法正常使用。而且，如果以后Qt版本再次升级，QCA库也必然需要再次编译。为了以后减少应用程序对外部库的依赖，不再编译QCA库，决定用BankClient_SMEncrypt的模块中提供了一套国际标准的对称、非对称加解密算法替代QCA。

具体修改内容：

###1. 去掉QMyRSA类

	QMyRSA二次封装了QCA的“RSA”算法，并在加密信道建立的过程中使用。所以类QMyTls中的QMyRSA的代码被ERTCryptoRSA类替代。
###2. 修改QMyAes类
	
	在QMyAes中，使用ERTCryptoAES类替换掉QCA的相关类。修改内容是函数内部的实现代码，函数参数列表和返回值均未改变。