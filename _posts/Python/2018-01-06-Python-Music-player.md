---
category: Python
layout: post
title: 基于Python和百度语音识别实现的音乐播放器
---

参考：  
[python写一个录音小程序](http://blog.csdn.net/yexiaohhjk/article/details/73132562)   
[pyaudio API](http://people.csail.mit.edu/hubert/pyaudio/docs/#class-stream)

**基于pyaudio库和wave库进行录音和播放wav格式的音频文件，基本实现录音+识别+播放歌曲的功能**  

完整程序地址： [Python_BaiduAPI_music_player](https://github.com/doingdd/Python_BaiduAPI_music_player)
# 录音

录音使用pyaudio实现，因为想实现一个功能就是让程序一直待命，知道判断出一个特定的唤醒词的时候，开始播放。  
所以写了个循环，每隔1.25秒左右录制一次麦克风输入，利用numpy库的计算功能简单计算1.25s内的声音阈值是否大于800，如果大于则认为这是有人在说话，可以将录制下来的音频交给百度API去识别了。  

上代码：
```python
framerate=8000
NUM_SAMPLES=2000
channels=1
sampwidth=2
TIME=2
chunk=2014
# 利用pyaudio录音
def save_wave_file(filename,data):
    '''save the date to the wavfile'''
    wf=wave.open(filename,'wb')
    wf.setnchannels(channels)
    wf.setsampwidth(sampwidth)
    wf.setframerate(framerate)
    wf.writeframes(b"".join(data))
    wf.close()

def my_record():
    pa=PyAudio()
    stream=pa.open(format = paInt16,channels=1,
                   rate=framerate,input=True,
                   frames_per_buffer=NUM_SAMPLES)
    print("开始缓存录音")
    monitor = False
    while not monitor:
        print 'begin '
        frames = []
        for i in range(0, 5):
            data = stream.read(NUM_SAMPLES)
            frames.append(data)
        audio_data = np.fromstring(data, dtype=np.short)
        # print type(data),data
        print audio_data

        large_sample_count = np.sum(audio_data > 800)
        temp = np.max(audio_data)
        # print time.clock()
        if temp > 800:
            print "检测到信号"
            print '当前阈值：', temp
            monitor = True
    else:
        print 'record now.'
        count=0
        while count<TIME*10:#控制录音时间
            string_audio_data = stream.read(NUM_SAMPLES)#一次性录音采样字节大小
            frames.append(string_audio_data)
            # print string_audio_data
            count+=1
            print('.')
        save_wave_file('01.wav',frames)
        stream.stop_stream()
        stream.close()
        pa.terminate()
```  

pyaudio的安装： 

![](http://oon3ys1qt.bkt.clouddn.com/pip_install_pyaudio.png)

save_wave_file比较好理解，就是利用wave模块，将二进制data写入到文件里。  

my_record()是录音的函数，主要由两部分思路，一部分是while not monitor的循环，只要阈值监测没超过800，则认为声音输入无效，一直循环录入，间隔是1.25s；第二部分是超过阈值800时，开启真正的录音(保留之前录取的超过阈值的那一段1.25s）,录音大概5s左右停止，并写入wav文件。  

# 识别
识别的思路就是利用wave库打开wave文件，读出data，传给百度API(参考百度官方给的格式和sample)，然后读取回传码中识别出来的字符串。  

[百度API说明](http://ai.baidu.com/docs#/ASR-Online-Python-SDK/top)   

```python
def baidu_speech():
    #// 成功返回
     #{
     #    "err_no": 0,
     #    "err_msg": "success.",
    #     "corpus_no": "15984125203285346378",
    #     "sn": "481D633F-73BA-726F-49EF-8659ACCC2F3D",
    #     "result": ["北京天气"]
    # }
    # // 失败返回
    # {
    #     "err_no": 2000,
    #     "err_msg": "data empty.",
    #     "sn": null
    # }
    # 你的 APPID AK SK
    APP_ID = '10639428'
    API_KEY = '****'  #百度申请的api_key
    SECRET_KEY = '****' #百度申请的密钥

    client = AipSpeech(APP_ID, API_KEY, SECRET_KEY)
    # 识别本地文件
    re = client.asr(get_file_content('01.wav'), 'wav', 8000, {'lan': 'zh',})
    # print re.get('err_no')
    # print re.get('result','Err')[0].encode('utf-8')
    return re.get('result','Err')[0].encode('utf-8')
    # 从URL获取文件识别
    # client.asr('', 'wav', 8000, {
    #     'url': 'http://121.40.195.233/res/16k_test.pcm',
    #     'callback': 'http://xxx.com/receive',
    # })

# 读取文件
def get_file_content(filePath):
    with open(filePath, 'rb') as fp:
        return fp.read()
```
APP_ID，APP_KEY,SECRET_KEY是在百度语音上面申请的，每天的语音识别限制是50000次，平均每s一次一够运行十几个小时了，自己玩完全够用。  

AipSpeech这个模块需要提前安装，参考百度API说明即可，或者直接`pip install baidu-aip`: 

![](http://oon3ys1qt.bkt.clouddn.com/pip_install_baidu_aip.png)

然后直接创建aip对象，并且调用接口函数就可以了，实测速度不算快，但大多在5s以内可以回传。  

# 播放

播放也是使用pyaudio，stream类型把output置成True就可以了
```python
def play(file):
    wf=wave.open(file,'rb')
    p=PyAudio()
    stream=p.open(format=p.get_format_from_width(wf.getsampwidth()),channels=
                  wf.getnchannels(),rate=wf.getframerate(),output=True)
    while True:
        data=wf.readframes(chunk)
        if data=="":break
        stream.write(data)
    stream.close()
    p.terminate()
```

另外，在主函数中可以加一些唤醒词，用来判断是不是真的要执行播放音乐的动作：
```python
if __name__ == '__main__':
    get_your_word = False
    while not get_your_word:
        my_record()
        print('Over!')
        # play(r'01.wav')
        speech_word = baidu_speech()
        print speech_word
        if '老铁老铁' in speech_word and '音乐' in speech_word:
            music = os.listdir('F:\KuGou')
            random.shuffle(music)
            for i in music:
                if i.endswith('.wav'):
                    play("F:\KuGou\{}".format(i))
        else:
            print "Don't know what you're talking!"
```
这里把"老铁老铁"和"音乐"设成了唤醒词，并且打开文件夹之后，随机播放其中的wav文件，可是直到写完这个程序我才发现，现在所有大型网站音乐下载都收费了，而我的酷狗本地只有一首歌。。。好吧无论如何基本的功能已经实现，这个播放器就暂且告一段落吧。  

# 思考

这个简单的demo还有很多有待改进的地方：

1. 阈值大于800之后开启录音，5s后停止，有很大可能发生唤醒词跨越了两个5s的时间段的情况，这样相当于浪费了10s的时间，会导致程序反应成功的概率不高。  

2. 播放音乐可以起一个子线程来做，这样的好处是可以在打断播放，加入停止，切歌等功能，也可以加入事先准备好的人机交互语音播报等等。    

3. 唤醒功能的实现目前的思路是实时(间隔1.25s)监控录音，然后不管有没有唤醒词，一定会录音5s左右再去访问百度API，这样导致的无效请求次数太多，而且浪费了5s的录音时间。    
但如果频繁的访问百度API(1.25s一次)进行语音识别的话会导致大部分时间都浪费在网络上面，成功率应该更低，这里的问题其实没有得到很好的解决。

