# [Claude Desktop使用自定义API](https://linux.do/t/topic/2032192)


女朋友经常使用Claude Desktop编辑ppt和excel，订阅了一个pro plan，奈何消耗太快，所以研究了下怎么接入第三方api。

官网提供有文档说明，写的有点复杂。

总结起来

1. 正常安装
    
2. 首次打开，不登陆，左上角菜单按钮(这里有个小坑，没有登录，貌似点击不了，需要通过鼠标选择邮件输入框，键盘tab跳到这里回车打开)–> help → troubleshooting → enable developer mode  
    
    [![image](https://cdn3.ldstatic.com/optimized/4X/1/e/3/1e3b6e4fdc12d7e76d9b0a7e6205a633a6070ca4_2_599x500.png)
    
    image960×801 92.5 KB
    
    ](https://cdn3.ldstatic.com/original/4X/1/e/3/1e3b6e4fdc12d7e76d9b0a7e6205a633a6070ca4.png "image")
    
3. **Developer → Configure third-party inference**  
    
    [![image](https://cdn3.ldstatic.com/optimized/4X/0/1/8/018a18e47414f8267efc2f166471d9a00744c93d_2_513x500.png)
    
    image756×736 72.1 KB
    
    ](https://cdn3.ldstatic.com/original/4X/0/1/8/018a18e47414f8267efc2f166471d9a00744c93d.png "image")
    
4. 配置中转地址和key，apply locally 选择local进入就好了。  
    
    [![image](https://cdn3.ldstatic.com/optimized/4X/d/f/a/dfa2faa00eeedccc1048ff42246a8754819b10b9_2_618x500.png)
    
    image1347×1089 104 KB
    
    ](https://cdn3.ldstatic.com/original/4X/d/f/a/dfa2faa00eeedccc1048ff42246a8754819b10b9.png "image")
    

效果：  

[![image](https://cdn3.ldstatic.com/optimized/4X/e/6/b/e6b1e87449b8a3c4c2d534c39588d2fad40167bc_2_690x429.jpeg)

image1920×1195 328 KB

](https://cdn3.ldstatic.com/original/4X/e/6/b/e6b1e87449b8a3c4c2d534c39588d2fad40167bc.jpeg "image")

官网链接

1. [Installation and setup - Claude.ai Documentation](https://claude.com/docs/cowork/3p/installation)
2. [Deploy Claude Desktop for Windows | Claude Help Center](https://support.claude.com/en/articles/12622703-deploy-claude-desktop-for-windows)