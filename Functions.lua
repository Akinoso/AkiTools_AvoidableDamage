local DB = AkiAD.DB
local avoidableDamage = AkiAD.avoidableDamage

function AkiAD:UpdateConfig(dst, src)
	for k, v in pairs(src) do
		if type(v) == 'table' then
			if type(dst[k]) == 'table' then
				self:UpdateConfig(dst[k], v)
			else
				dst[k] = self:UpdateConfig({}, v)
			end
		elseif type(dst[k]) ~= 'table' then
			dst[k] = v
		end
	end
	return dst
end

function AkiAD:Announce(mode, msg, sound)
	if sound ~= '' then
		PlaySoundFile(sound, 'MASTER')
	end
	if mode == 'off' then
		return
	elseif mode == 'self' or mode == '' then
		print(msg)
		return
	elseif mode == 'instance' or mod == 'i' then
		mode = 'INSTANCE_CHAT'
	elseif mode == 's'then
		mode = 'say'
	elseif mode == 'g' then
		mode = 'guild'
	elseif mode == 'p' then
		mode = 'party'
	elseif mode == 'r' then
		mode = 'raid'
	elseif mode == 'y' then
		mode = 'yell'
	end
	SendChatMessage(msg, mode:upper())
end

-- 获取当前状态对应的配置
function AkiAD:GetConfig()
	local inInstance = IsInGroup(LE_PARTY_CATEGORY_INSTANCE)
	local inParty = IsInGroup()
	local inRaid = IsInRaid()
	local cfg
	if inInstance then
		cfg = DB.instance
	elseif inRaid then
		cfg = DB.raid
	elseif inParty and not inRaid  then
		cfg = DB.party
	else
		cfg = DB.solo
	end
	return cfg
end

function AkiAD:Round(number, decimals)
    return (('%%.%df'):format(decimals)):format(number)
end

function AkiAD:Count(a)
	local count = 0
	for k, v in pairs(a) do
		count = count + 1
	end
	return count
end

function AkiAD:Sort(a,key)
	local count = AkiAD:Count(a)
	if count < 2 then return a end
	local cache = {}
	for i = 1, count-1 do
		for j = 1, count - i do
			if a[j][key] < a[j+1][key] then
				cache = a[j]
				a[j] = a[j+1]
				a[j+1] = cache
			end
		end
	end
	return a
end

function AkiAD:ShortName(name)
	local shortName = name:match('^(%S*)%-') or name or '?'
	return shortName
end

function AkiAD:IsInMyGroup(flag)
	local inParty = IsInGroup()
	local inRaid = IsInRaid()
	local result = (inRaid and bit.band(flag, COMBATLOG_OBJECT_AFFILIATION_RAID) ~= 0) or (inParty and bit.band(flag, COMBATLOG_OBJECT_AFFILIATION_PARTY) ~= 0)
	return result
end

function AkiAD:IsPlayer(flag)
	local result = bit.band(flag, COMBATLOG_OBJECT_TYPE_PLAYER) ~= 0
	return result
end

function AkiAD:ClassColor(name)
	local _, classFileName = UnitClass(name)
	name = '|c' .. RAID_CLASS_COLORS[classFileName or 'PRIEST'].colorStr .. name .. '|r'
	return name
end

function AkiAD:SaveDamage(destName, spellId, amount)
	if avoidableDamage['cache'][destName] == nil then
		avoidableDamage['cache'][destName] = {}
	end
	if avoidableDamage['saveByName'][destName] == nil then
		avoidableDamage['saveByName'][destName] = {}
	end
	if avoidableDamage['sum'][destName] == nil then
		avoidableDamage['sum'][destName] = 0
	end
	if avoidableDamage['saveBySpell'][spellId] == nil then
		avoidableDamage['saveBySpell'][spellId] = {}
	end
	if amount == nil then
		amount = 0
	end
	
	avoidableDamage['sum'][destName] = avoidableDamage['sum'][destName] + amount
	if avoidableDamage['cache'][destName][spellId] == nil then
		avoidableDamage['cache'][destName][spellId] = amount
	else
		avoidableDamage['cache'][destName][spellId] = avoidableDamage['cache'][destName][spellId] + amount
	end
	if avoidableDamage['saveByName'][destName][spellId] == nil then
		avoidableDamage['saveByName'][destName][spellId] = amount
	else
		avoidableDamage['saveByName'][destName][spellId] = avoidableDamage['saveByName'][destName][spellId] + amount
	end
	if avoidableDamage['saveBySpell'][spellId][destName] == nil then
		avoidableDamage['saveBySpell'][spellId][destName] = amount
	else
		avoidableDamage['saveBySpell'][spellId][destName] = avoidableDamage['saveBySpell'][spellId][destName] + amount
	end
end

function AkiAD:AnnounceDamage(mode, destName)
	if avoidableDamage['timer'][destName] == nil then
		avoidableDamage['timer'][destName]  = true
		C_Timer.After(2,function()
			local msg = '['..destName..'] ← ['
			local amount = 0
			for k,v in pairs(avoidableDamage['cache'][destName]) do
				msg = msg..GetSpellLink(k)..']'
				amount = amount + v
			end
			avoidableDamage['cache'][destName] = nil
			avoidableDamage['timer'][destName] = nil
			local userMaxHealth = UnitHealthMax(destName)
			local msgAmount = AkiAD:Round(amount/1000 ,1)
			local pct = Round(amount / userMaxHealth * 100)
			msg = msg..'('..msgAmount..'k - '..pct..'%)'
			table.insert(avoidableDamage['alist'], msg)
			if pct >= 20 then
				AkiAD:Announce(mode, msg, '')
			end
		end)
	end
end

function AkiAD:SpellDamage(mode, destName, spellId, amount, sound)
	if (avoidableDamage['spells'][spellId] or (avoidableDamage['spellsNoTank'][spellId] and UnitGroupRolesAssigned(destName) ~= 'TANK')) and UnitIsPlayer(destName) then
		AkiAD:SaveDamage(destName, spellId, amount)
		AkiAD:AnnounceDamage(mode, destName)
	end
	if sound ~= '' then
		PlaySoundFile(sound, 'MASTER')
	end
end

function AkiAD:AnnounceAD(mode)
	if AkiAD:Count(avoidableDamage['sum']) == 0 then
		AkiAD:Announce(mode, '--------------------', '')
		AkiAD:Announce(mode, '没有人受到可规避伤害，人人都是魂斗罗！', '')
		AkiAD:Announce(mode, '--------------------', '')
		return
	end
	avoidableDamage['list'] = {}
	for k, v in pairs(avoidableDamage['sum']) do
		table.insert(avoidableDamage['list'], {['name'] = k, ['damage'] = v })
	end
	avoidableDamage['list'] = AkiAD:Sort(avoidableDamage['list'], 'damage')
	AkiAD:Announce(mode, '--------------------', '')
	AkiAD:Announce(mode, '毒瘤排行榜', '')
	AkiAD:Announce(mode, '--------------------', '')
	for k,v in pairs(avoidableDamage['list']) do
		local msg = k..'. '..v['name']..' '..AkiAD:Round(v['damage'] / 1000 ,1)..'k'
		AkiAD:Announce(mode, msg, '')
	end
	AkiAD:Announce(mode, '--------------------', '')
end

function AkiAD:AnnounceADS(mode)
	if AkiAD:Count(avoidableDamage['sum']) == 0 then
		AkiAD:Announce(mode, '--------------------', '')
		AkiAD:Announce(mode, '没有人受到可规避伤害，人人都是魂斗罗！', '')
		AkiAD:Announce(mode, '--------------------', '')
		return
	end
	local list = {}
	for id, v in pairs(avoidableDamage['saveBySpell']) do
		local sum = 0
		for name, amount in pairs(v) do
			sum = sum + amount
		end
		table.insert(list, {['id'] = id, ['damage'] = sum })
	end
	list = AkiAD:Sort(list, 'damage')
	AkiAD:Announce(mode, '--------------------', '')
	AkiAD:Announce(mode, '可规避法术伤害排行榜', '')
	AkiAD:Announce(mode, '--------------------', '')
	for k,v in pairs(list) do
		local msg = k..'. '..GetSpellLink(v['id'])..' '..AkiAD:Round(v['damage'] / 1000 ,1)..'k'
		AkiAD:Announce(mode, msg, '')
	end
	AkiAD:Announce(mode, '--------------------', '')
end

function AkiAD:AnnounceADN(mode)
	local name = avoidableDamage['list'][1]['name']
	if not avoidableDamage['saveByName'][name] then
		print('['..name..']未受到毒瘤伤害。')
		return
	end
	list = {}
	for id, v in pairs(avoidableDamage['saveByName'][name]) do
		table.insert(list, {['id'] = id, ['damage'] = v })
	end
	list = AkiAD:Sort(list, 'damage')
	AkiAD:Announce(mode, '--------------------', '')
	AkiAD:Announce(mode, '['..name..']受到的可规避法术伤害排行榜', '')
	AkiAD:Announce(mode, '--------------------', '')
	for k,v in pairs(list) do
		local msg = k..'. '..GetSpellLink(v['id'])..' '..AkiAD:Round(v['damage'] / 1000 ,1)..'k'
		AkiAD:Announce(mode, msg, '')
	end
	AkiAD:Announce(mode, '--------------------', '')
end

function AkiAD:AnnounceADMsgList(mode)
	for k, v in pairs(avoidableDamage['alist']) do
		local msg = k..'. '..v
		AkiAD:Announce(mode, msg, '')
	end
end
