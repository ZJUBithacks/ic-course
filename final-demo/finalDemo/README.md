# finalDemo
由于需要进行跨容器转账有了余额才能投票，并且前端不是很熟悉，仅实现部分功能仅供参考。对之前的投票合约进行多功能扩展，希望实现更加复杂的功能
## 遇到的问题：
> send capability required, but not available (need an enclosing async expression or function body)
https://forum.dfinity.org/t/cant-call-an-imported-actors-query-functions/1732/11  
  
注意：利用candid UI 时候，msg.caller并不为用户的Principal
# 功能
在普通的投票功能外完成了以下功能
### 1. 能够根据您拥有的代币多少进行投票
### 2. 预留了keeper接口，方便未来可以和自动调用器联动
### 3. 多canister进行相互调用
### 4. 利用消息订阅模式，将投票的结果可以推送到所有订阅该主题的人里
### 5. 多种数据合规校验
### 6. 只有关注了别人才能投票，在关注某人时候，同时成为他的粉丝
### 7. 利用回调函数处理推送过来的数据
### 8. 代币的基本功能

# 流程演示
dfx start --clean 将服务器中storage的数据清空，重新开始运行
dfx deploy
</br>
</br>
> 本机中的两个canister容器id </br>
"finalDemo": {
    "local": "rrkah-fqaaa-aaaaa-aaaaq-cai"
  },
  "finalDemo0": {
    "local": "ryjl3-tyaaa-aaaaa-aaaba-cai"
  },  
  
  <br/>
  
![avatar](https://tva1.sinaimg.cn/large/e6c9d24ely1h18f3s3tg1j20lk0uxdhs.jpg)
初始时候都为空
一些简单步骤，图片跳过，显示日志（看Markdown源码格式更清晰）
</br>
```shell
OUTPUT LOG
› getBalance(principal "rrkah-fqaaa-aaaaa-aaaaq-cai")
(0)
› getAllProrosal()
(vec {})
› allVoteMsgs()
(vec {})
› transfer(principal "rrkah-fqaaa-aaaaa-aaaaq-cai", 300)
(record {to=principal "rrkah-fqaaa-aaaaa-aaaaq-cai"; status=variant {Succeed}; from=principal "2vxsx-fae"; timestamp=1649856885556819000; index=1; amount=300})
› transfer(principal "ryjl3-tyaaa-aaaaa-aaaba-cai", 400)
(record {to=principal "ryjl3-tyaaa-aaaaa-aaaba-cai"; status=variant {Succeed}; from=principal "2vxsx-fae"; timestamp=1649856908636257000; index=2; amount=400})
› getTxRecordSize()
(3)
› createProposal("raiseTax", 0, 200)
()
› getAllProrosal()
(vec {record {id="raiseTax"; startTime=1649857203870143000; endTime=1649857403870143000; createTime=1649857203870143000; againstVote=0; proposer=principal "2vxsx-fae"; supportVote=0}})
› follow(principal "rrkah-fqaaa-aaaaa-aaaaq-cai", "raiseTax", variant {Support})
(variant {Err=variant {VoteRepeat}}) //第二次投票会显示重复（校验过程）
```
</br>
分别两个canister进行投票

![avatar](https://tva1.sinaimg.cn/large/e6c9d24ely1h18feqic69j20lg09fab3.jpg)
从另外一个canister进行调用
</br>
查看结果
› proposalResult("raiseTax")
(variant {Ok=variant {Rejected}})
raiseTax

 调用此方法将向所有订阅过的进行推送
![avatar](https://tva1.sinaimg.cn/large/e6c9d24ely1h18fkilcroj20l4063dfs.jpg)
 可见所有的接受者都收到了这条推送
![avatar](https://tva1.sinaimg.cn/large/e6c9d24ely1h18fp4lvoij21lc07r40a.jpg)
 测试给未产生提案的投票，返回不存在错误
![avatar](https://tva1.sinaimg.cn/large/e6c9d24ely1h18ftrqvfbj20nu079gm9.jpg)
 查看所有正在关注的人
![avatar](https://tva1.sinaimg.cn/large/e6c9d24ely1h18frzz1vcj20nr049mxa.jpg)