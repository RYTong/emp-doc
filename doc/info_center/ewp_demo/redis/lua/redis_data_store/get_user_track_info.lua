-- KEYS只指定客户号

-- 信用卡列表主键 HXRS_CREDIT:{客户号}:LIST
-- 信用卡信息主键 HXRS_CREDIT:{客户号}:INFO:卡号
-- 定期账户列表主键 HXRS_DEPO:{客户号}:LIST
-- 定期账户信息主键 HXRS_DEPO:{客户号}:INFO:卡号
-- ‘{}’符号为redis哈希标签算法
-- 卡信息包含：ALIAS、BALANCE、AVLIMT、CYCL_NBR、STATUS、PAYBACK_FEE、LOW_FEE、ENDPAY_DAY
-- 定期账户信息包含：status, acct_type, acctbal, depo_term, under_acct, interstr_date, mature_date, rate
local function get_user_track_info(tab_name) 
	local user_acct_list_key = tab_name .. ':{' .. KEYS[1] .. '}:LIST'
	-- 获取卡号列表
	local acct_list = redis.call('smembers', user_acct_list_key)
	local info = {}
	local j = 1

	-- 遍历卡号列表，获取卡信息
	for i = 1, #acct_list do
		local user_acct_info_key = tab_name .. ':{' .. KEYS[1] .. '}:INFO:' .. acct_list[i]
		--获取当前卡信息
		local acct_info = redis.call('hgetall', user_acct_info_key)
		-- redis lua脚本只支持将数组转换成redis数据类型，故返回值须构建为数组
		info[j] = acct_list[i]
        info[j + 1] = acct_info
        j = j + 2
	end
	return info
end

local track_info = {"credit_info", get_user_track_info("HXRS_CREDIT"),
                    "depo_info", get_user_track_info("HXRS_DEPO")}
return track_info