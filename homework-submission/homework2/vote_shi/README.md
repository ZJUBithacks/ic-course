# 执行日志
**ref** https://brson.github.io/2021/01/30/dfinity-impressions

**注意**：直接看md原文能够有更清晰的格式输出

Upgrading code for canister vote, with canister_id rrkah-fqaaa-aaaaa-aaaaq-cai
Upgrading code for canister vote_assets, with canister_id ryjl3-tyaaa-aaaaa-aaaba-cai
Module hash e0df779f65fe44893d8991bef0f9af442bff019b79ec756eface2b58beec236f is already installed.
Uploading assets to asset canister...
Starting batch.
Staging contents of new and changed assets:
  /sample-asset.txt (24 bytes) sha 2d523f5aaeb195da24dcff49b0d560a3d61b8af859cee78f4cff0428963929e6 is already installed
Committing batch.
Deployed canisters.
jinshi@Mac-Pro vote % dfx canister call vote getAllProrosal                    
(vec {})

## 创建投票
jinshi@Mac-Pro vote % dfx canister call vote createProposal \ "(\"hh\", 15, 40)"

()

## 投票
jinshi@Mac-Pro vote % dfx canister call vote vote "(\"hh\", variant {Support})"
(variant { Err = variant { VoteNotBegin } })
jinshi@Mac-Pro vote % dfx canister call vote vote "(\"hh\", variant {Support})"
(
  variant {
    Ok = record {
      id = "hh";
      startTime = 1_648_444_001_156_705_000 : int;
      endTime = 1_648_444_026_156_705_000 : int;
      createTime = 1_648_443_986_156_705_000 : int;
      againstVote = 0 : nat;
      proposer = principal "jgaia-s2745-wn64x-5es2y-ftmev-npn5q-vu6q4-wnxh5-35ewk-rgz7v-jae";
      supportVote = 1 : nat;
    }
  },
)

## 投票的重复测试、超时测试（未开始测试）
jinshi@Mac-Pro vote % dfx canister call vote vote "(\"hh\", variant {Support})"
(variant { Err = variant { VoteRepeat } })
jinshi@Mac-Pro vote % dfx canister call vote vote "(\"hh\", variant {Support})"
(variant { Err = variant { VoteIsOver } })
jinshi@Mac-Pro vote % dfx canister call vote createProposal  "(\"hhh\", 0, 40)"
()

## 再新建一个投票
jinshi@Mac-Pro vote % dfx canister call vote vote "(\"hhh\", variant {Support})"

(
  variant {
    Ok = record {
      id = "hhh";
      startTime = 1_648_444_070_386_240_000 : int;
      endTime = 1_648_444_110_386_240_000 : int;
      createTime = 1_648_444_070_386_240_000 : int;
      againstVote = 0 : nat;
      proposer = principal "jgaia-s2745-wn64x-5es2y-ftmev-npn5q-vu6q4-wnxh5-35ewk-rgz7v-jae";
      supportVote = 1 : nat;
    }
  },
)

## 测试投票的结果（投票不存在测试）
jinshi@Mac-Pro vote % dfx canister call vote proposalResult hh                 
(variant { Ok = variant { Approved } })
jinshi@Mac-Pro vote % dfx canister call vote proposalResult hhh
(variant { Ok = variant { Approved } })
jinshi@Mac-Pro vote % dfx canister call vote proposalResult sss
(variant { Err = variant { VoteNotExist } })

## 显示所有的存在的投票
jinshi@Mac-Pro vote % dfx canister call vote getAllProrosal
(
  vec {
    record {
      id = "hhh";
      startTime = 1_648_444_070_386_240_000 : int;
      endTime = 1_648_444_110_386_240_000 : int;
      createTime = 1_648_444_070_386_240_000 : int;
      againstVote = 0 : nat;
      proposer = principal "jgaia-s2745-wn64x-5es2y-ftmev-npn5q-vu6q4-wnxh5-35ewk-rgz7v-jae";
      supportVote = 1 : nat;
    };
    record {
      id = "hh";
      startTime = 1_648_444_001_156_705_000 : int;
      endTime = 1_648_444_026_156_705_000 : int;
      createTime = 1_648_443_986_156_705_000 : int;
      againstVote = 0 : nat;
      proposer = principal "jgaia-s2745-wn64x-5es2y-ftmev-npn5q-vu6q4-wnxh5-35ewk-rgz7v-jae";
      supportVote = 1 : nat;
    };
  },
)

## 升级后查询是否stable变量还保存了
jinshi@Mac-Pro vote % dfx deploy               
Deploying all canisters.
All canisters have already been created.
Building canisters...
Installing canisters...

Upgrading code for canister vote, with canister_id rrkah-fqaaa-aaaaa-aaaaq-cai
Module hash 964f289aa06d95b717280762966b8ba68bd321393bacb5f46dbe9ef01ded66c4 is already installed.
Upgrading code for canister vote_assets, with canister_id ryjl3-tyaaa-aaaaa-aaaba-cai
Module hash e0df779f65fe44893d8991bef0f9af442bff019b79ec756eface2b58beec236f is already installed.
Uploading assets to asset canister...
Starting batch.
Staging contents of new and changed assets:
  /sample-asset.txt (24 bytes) sha 2d523f5aaeb195da24dcff49b0d560a3d61b8af859cee78f4cff0428963929e6 is already installed
Committing batch.
Deployed canisters.

## 查询
jinshi@Mac-Pro vote % dfx canister call vote getAllProrosal
(
  vec {
    record {
      id = "hhh";
      startTime = 1_648_444_070_386_240_000 : int;
      endTime = 1_648_444_110_386_240_000 : int;
      createTime = 1_648_444_070_386_240_000 : int;
      againstVote = 0 : nat;
      proposer = principal "jgaia-s2745-wn64x-5es2y-ftmev-npn5q-vu6q4-wnxh5-35ewk-rgz7v-jae";
      supportVote = 1 : nat;
    };
    record {
      id = "hh";
      startTime = 1_648_444_001_156_705_000 : int;
      endTime = 1_648_444_026_156_705_000 : int;
      createTime = 1_648_443_986_156_705_000 : int;
      againstVote = 0 : nat;
      proposer = principal "jgaia-s2745-wn64x-5es2y-ftmev-npn5q-vu6q4-wnxh5-35ewk-rgz7v-jae";
      supportVote = 1 : nat;
    };
  },
)
jinshi@Mac-Pro vote % 