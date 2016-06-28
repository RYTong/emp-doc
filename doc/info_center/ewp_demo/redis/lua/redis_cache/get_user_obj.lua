-- KEYS只指定客户号
local user_info_key = 'HXRC_USER_OBJ:' .. KEYS[1] .. ':USER_INFO'
local user_accts_list_key = 'HXRC_USER_OBJ:' .. KEYS[1] .. ':ACCTS_LIST'

-- 查询用户信息
local user_info = redis.call('hgetall', user_info_key)
-- 查询账户列表
local accts_list = redis.call('smembers', user_accts_list_key)

local accts_info = {}
local i = 1
-- 遍历账户列表，查询每个账户信息
-- 将acct_info拼装为{账户1，账户1信息数组，......，账户N，账户N信息数组}
-- 账户信息数组每两个元素为一对key-value
for j = 1, #accts_list do
    local user_acct_info_key = 'HXRC_USER_OBJ:' .. KEYS[1] .. ':ACCT_INFO:' .. accts_list[j]
    accts_info[i] = accts_list[j]
    accts_info[i + 1] = redis.call('hgetall', user_acct_info_key)
    i = i + 2
end

return {"user_info", user_info, "acct_info_list", accts_info}