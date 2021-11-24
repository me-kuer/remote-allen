由于部分操作无法在dockerfile中完成(翻墙等)
本版本基于v2生成的container，手动安装node及复制couchdb数据文件等操作后生的image(wbq-remote:1.0)继续优化

设置go（将go放到PATH中）
pull 代码（django go flora flora-base）

export https_proxy=http://192.168.10.32:7890 http_proxy=http://192.168.10.32:7890 all_proxy=socks5://192.168.10.32:7890
go get -v -x github.com/githubnemo/CompileDaemon
go get -v -x github.com/cheekybits/genny
