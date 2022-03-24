# qsort



MAC M1下踩坑指南
1. 前端不能够连接后端
https://forum.dfinity.org/t/connectionrefused-on-localhost-frontend-unable-to-connect-to-my-backend/9357

2. dfx 0.9.2不能创建 canister
https://forum.dfinity.org/t/after-upgrade-to-dfx-0-9-2-can-not-deploy-to-existing-motoko-canister/11242

3. node 降级为稳定版本
https://zmis.me/user/zmisgod/post/1648



## Running the project locally


```bash
# Starts the replica, running in the background
dfx start --background

# Deploys your canisters to the replica and generates your candid interface
dfx deploy
```

Once the job completes, your application will be available at `http://localhost:8000?canisterId={asset_canister_id}`.


```bash
# 测试
dfx canister call qsort qsort_print '(vec { 5; 3; 0; 9; 8; 2; 1; 4; 7; 6 })'

# UI界面地址
echo "http://localhost:8000/?canisterId=$(dfx canister id qsort_assets)"
```
