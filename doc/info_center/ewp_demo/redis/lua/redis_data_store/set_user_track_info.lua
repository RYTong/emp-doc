-- KEYS只指定客户号
-- 信用卡列表主键 HXRS_CREDIT:{客户号}:LIST
-- 信用卡信息主键 HXRS_CREDIT:{客户号}:INFO:卡号
-- 定期账户列表主键 HXRS_DEPO:{客户号}:LIST
-- 定期账户信息主键 HXRS_DEPO:{客户号}:INFO:卡号
-- ‘{}’符号为redis哈希标签算法
-- 信用卡信息包含：ALIAS、BALANCE、AVLIMT、CYCL_NBR、STATUS、PAYBACK_FEE、LOW_FEE、ENDPAY_DAY
-- 定期账户信息包含：status, acct_type, acctbal, depo_term, under_acct, interstr_date, mature_date, rate
-- ARGV[]格式为：逻辑表名，每条信用卡信息数据个数n, 
--               卡号1，数据1键，数据1值，数据2键，数据2值 ... ...，数据n键，数据n值，
--               卡号2，数据1键，数据1值，数据2键，数据2值 ... ...，数据n键，数据n值，
--               ... ...
local user_acct_list_key = ARGV[1] .. ':{' .. KEYS[1] .. '}:LIST'
local data_num = ARGV[2]
local i = 3

while ARGV[i] ~= nil do
    -- 获取卡号
    local acct = ARGV[i]
    -- 生成信用卡信息主键
    local user_acct_info_key = ARGV[1] .. ':{' .. KEYS[1] .. '}:INFO:' .. acct
    i = i + 1
    -- 遍历数据项生成
    for j = i, i + data_num * 2 - 1, 2 do
    	-- 用redis hashes存储卡信息
    	redis.call('hset', user_acct_info_key, ARGV[j], ARGV[j + 1])
    	i = i + 2
    end
    -- 用redis sets存储卡列表
    redis.call('sadd', user_acct_list_key, acct)
end

return redis.status_reply('ok')