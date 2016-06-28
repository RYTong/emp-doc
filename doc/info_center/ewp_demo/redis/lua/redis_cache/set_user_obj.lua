-- KEYS只指定客户号
-- ARGV[]格式为：用户信息数据个数N，
--                   用户信息数据1键，用户信息数据1值，......，用户信息数据N键，用户信息数据N值，
--               账户1，账户1信息数据个数M1，
--                   账户1信息数据1键，账户1信息数据1值，......，账户1信息数据M1键，账户1信息数据M1值，
--               账户2，账户2信息数据个数M2，
--                   账户2信息数据1键，账户2信息数据1值，......，账户2信息数据M2键，账户2信息数据M2值，
--               ......
local user_info_key = 'HXRC_USER_OBJ:' .. KEYS[1] .. ':USER_INFO'
local user_accts_list_key = 'HXRC_USER_OBJ:' .. KEYS[1] .. ':ACCTS_LIST'
-- 设置数据有效期(秒)
local timeout = 300

-- 第一个参数为用户信息数据个数
if ARGV[1] == nil then
	return redis.status_reply('ok')
end
local data_num = ARGV[1]

local hmset_tab = {}
local k = 1
-- 遍历用户信息数据，使用redis hashes保存数据
for j = 2, data_num * 2 + 1, 2 do
	hmset_tab[k] = ARGV[j]
	hmset_tab[k + 1] = ARGV[j + 1]
	k = k + 2
	-- redis.call('hset', user_info_key, ARGV[j], ARGV[j + 1])
end
--利用unpack将hmset_tab转换成可变参数列表
redis.call('hmset', user_info_key, unpack(hmset_tab))
redis.call('expire', user_info_key, timeout)

-- 遍历账户信息列表
local i = data_num * 2 + 2
while ARGV[i] ~= nil do
    -- 获取账户
    local acct = ARGV[i]
    -- 获取账户信息数据个数
    data_num = ARGV[i + 1]
    -- 生成账户信息主键
    local user_acct_info_key = 'HXRC_USER_OBJ:' .. KEYS[1] .. ':ACCT_INFO:' .. acct
    i = i + 2
    k = 1
    -- 遍历data_num对数据
    hmset_tab = {}
    for j = i, i + data_num * 2 - 1, 2 do
	    hmset_tab[k] = ARGV[j]
	    hmset_tab[k + 1] = ARGV[j + 1]
	    k = k + 2
    	-- 用redis hashes存储卡信息
    	-- redis.call('hset', user_acct_info_key, ARGV[j], ARGV[j + 1])
    	i = i + 2
    end
    redis.call('hmset', user_acct_info_key, unpack(hmset_tab))
    redis.call('expire', user_acct_info_key, timeout)
    -- 用redis sets存储卡列表
    redis.call('sadd', user_accts_list_key, acct)
end
redis.call('expire', user_accts_list_key, timeout)

return redis.status_reply('ok')