//
//  SscanfDemo.m
//  ReviewLessionOfOC
//
//  Created by Dylan Xiao on 2018/11/21.
//  Copyright © 2018年 Dylan Xiao. All rights reserved.
//

#import "SscanfDemo.h"
#include <stdio.h>
#include <assert.h>

#define IP_STR_LEN     18
#define MAC_STR_LEN    18
#define MAC_BIT_LEN    6
//#define LITTLE_ENDIAN  0
//#define BIG_ENDIAN     1

@implementation SscanfDemo

typedef unsigned char  uchar;
typedef unsigned int   uint;

int big_little_endian()
{
    int data = 0x1;
    if (*((char*)&data) == 0x1)
        return LITTLE_ENDIAN;
    return BIG_ENDIAN;
}

uint ipstr2int(const char * ipstr)
{
    assert(ipstr);
    uint a,b,c,d;
    uint ip = 0;
    sscanf(ipstr,"%u.%u.%u.%u",&a,&b,&c,&d);
    a = (a << 24) ;
    b = (b << 16) ;
    c = (c << 8) ;
    d = (d << 0) ;
    ip = a | b | c | d;
    return ip;
}

char *int2ipstr(const uint ip, char *ipstr, const uint ip_str_len)
{
    assert(ipstr);
    if (big_little_endian() == LITTLE_ENDIAN)
        sprintf(ipstr,"%u.%u.%u.%u",
                (uchar)*((char*)(&ip)+3),
                (uchar)*((char*)(&ip)+2),
                (uchar)*((char*)(&ip)+1),
                (uchar)*((char*)(&ip)+0));
    else
        sprintf(ipstr,"%u.%u.%u.%u",
                (uchar)*((char*)(&ip)+0),
                (uchar)*((char*)(&ip)+1),
                (uchar)*((char*)(&ip)+2),
                (uchar)*((char*)(&ip)+3));
    
    return ipstr;
}

char *mac2str(const unsigned char *mac,char *mac_str,const uint mac_str_len)
{
    assert(mac_str);
    sprintf(mac_str,"%02X-%02X-%02X-%02X-%02X-%02X",
            mac[0],mac[1],mac[2],
            mac[3],mac[4],mac[5]);
    return mac_str;
}

-(void)test
{
    char  ip_str[IP_STR_LEN] = {0};
    char  mac_str[MAC_STR_LEN] = {0};
    unsigned char mac[MAC_BIT_LEN] = {0XEF,0XAD,0XF4,0X4F,0XAA,0X0F};
    const char *ipstr = "10.0.3.193";
    unsigned int ip;
    int2ipstr(167773121,ip_str,IP_STR_LEN);
    mac2str(mac,mac_str,MAC_STR_LEN);
    ip = ipstr2int(ipstr);
    printf("%s\n",ip_str);
    printf("%s\n",mac_str);
    printf("ip:%u\n",ip);
}




#pragma mark - sprintf

/*sprintf函数
 sprintf函数原型为 int sprintf(char *str, const char *format, ...)。作用是格式化字符串，具体功能如下所示：
 （1）将数字变量转换为字符串。
 （2）得到整型变量的16进制和8进制字符串。
 （3）连接多个字符串。
 */
-(void)sprintfDemo
{
    char str[256] = { 0 };
    int data = 1024;
    //将data转换为字符串
    sprintf(str,"%d",data);   // str = "1024"
    //获取data的十六进制
    sprintf(str,"0x%X",data); // str = "0x400"
    //获取data的八进制
    sprintf(str,"0%o",data);  // str = "02000"
    const char *s1 = "Hello";
    const char *s2 = "World";
    //连接字符串s1和s2
    sprintf(str,"%s %s",s1,s2); // str = "Hello World"
}


#pragma mark -sscanf
/*
 sscanf函数
 　   sscanf函数原型为int sscanf(const char *str, const char *format, ...)。将参数str的字符串根据参数format字符串来转换并格式化数据，转换后的结果存于对应的参数内。具体功能如下：
 
 （1）根据格式从字符串中提取数据。如从字符串中取出整数、浮点数和字符串等。
 （2）取指定长度的字符串
 （3）取到指定字符为止的字符串
 （4）取仅包含指定字符集的字符串
 （5）取到指定字符集为止的字符串
 
 sscanf可以支持格式字符%[]：
 
 (1)-: 表示范围，如：%[1-9]表示只读取1-9这几个数字 %[a-z]表示只读取a-z小写字母，类似地 %[A-Z]只读取大写字母
 (2)^: 表示不取，如：%[^1]表示读取除'1'以外的所有字符 %[^/]表示除/以外的所有字符
 (3),: 范围可以用","相连接 如%[1-9,a-z]表示同时取1-9数字和a-z小写字母
 (4)原则：从第一个在指定范围内的数字开始读取，到第一个不在范围内的数字结束%s 可以看成%[] 的一个特例 %[^ ](注意^后面有一个空格！)
 */
-(void)sscanfDemo
{
    const char *s = "http://www.baidu.com:1234";
    char protocol[32] = { 0 };
    char host[128] = { 0 };
    char port[8] = { 0 };
    sscanf(s,"%[^:]://%[^:]:%[1-9]",protocol,host,port);
    
    printf("protocol: %s\n",protocol);  // protocol: http
    printf("host: %s\n",host);          // host: www.baidu.com
    printf("port: %s\n",port);          // port: 1234
    
    char* str = "!test5678tst0102aaf. http:www.baidu.com:4404";
    
    char title[32] ={0};
    sscanf(str, "!%[a-z,0-9].%[^.].%[^:]:%[1-9]",title,protocol,host,port);
    printf("%s",title);
}

/*
 snprintf函数
 　　snprintf函数是sprintf函数的更加安全版本，考虑到字符串的字节数，防止了字符串溢出。函数形式为：int snprintf(char *restrict buf, size_t n, const char * restrict  format, ...);。最多从源串中拷贝n－1个字符到目标串中，然后再在后面加一个0。所以如果目标串的大小为n 的话，将不会溢出。
 */


@end
