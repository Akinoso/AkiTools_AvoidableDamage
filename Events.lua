local frame = AkiAD.frame
local DB = AkiAD.DB
local avoidableDamage = AkiAD.avoidableDamage

frame:SetScript('OnEvent', function(self, event, ...)
	local a = self[event]
	if a then
		a(self, ...)
	end
end)

frame:RegisterEvent('ADDON_LOADED')
function frame:ADDON_LOADED(name)
	if name ~= 'AkiTools_AvoidableDamage' then return end
	self:UnregisterEvent('ADDON_LOADED')
	if not AkiADDB then AkiADDB = {} end
	AkiAD:UpdateConfig(DB, AkiADDB)
end

frame:RegisterEvent('PLAYER_LOGOUT')
function frame:PLAYER_LOGOUT()
	AkiAD:UpdateConfig(AkiADDB, DB)
end

-- 战斗日志
frame:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
function frame:COMBAT_LOG_EVENT_UNFILTERED( ...) 
	local cfg = AkiAD:GetConfig()
	
	-- 读取事件返回值
	local timestamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = CombatLogGetCurrentEventInfo()
	local prefix, suffix = eventType:match('^(%u*)_(%S*)$')

	-- 毒瘤提醒
	if eventType == 'SPELL_DAMAGE' or eventType == 'SPELL_PERIODIC_DAMAGE' or eventType == 'SPELL_BUILDING_DAMAGE' or eventType == 'RANGE_DAMAGE' then
		local spellId, spellName, spellSchool, amount = select(12,CombatLogGetCurrentEventInfo())
		if avoidableDamage.spells[spellId] then
			if destName == UnitName('player') then
				AkiAD:SpellDamage(cfg.ownAD, destName, spellId, amount, cfg.ownADSound)
			elseif AkiAD:IsInMyGroup(destFlags) then
				local name = AkiAD:ShortName(destName)
				if cfg.otherAD == 'self' and AkiAD:IsPlayer(destFlags) then
					name = AkiAD:ClassColor(name)
				end
				AkiAD:SpellDamage(cfg.otherAD, name, spellId, amount, cfg.otherADSound)
			end
		
		elseif avoidableDamage.spellsNT[spellId] then
		
		end
	end
end

frame:RegisterEvent('CHALLENGE_MODE_COMPLETED')
function frame:CHALLENGE_MODE_COMPLETED(...)
	AkiAD:AnnounceAD('self')
end

frame:RegisterEvent('CHALLENGE_MODE_START')
function frame:CHALLENGE_MODE_START(...)
	avoidableDamage['cache'] = {}
	avoidableDamage['sum'] = {}
	avoidableDamage['saveByName'] = {}
	avoidableDamage['saveBySpell'] = {}
	avoidableDamage['timer'] = {}
	avoidableDamage['list'] = {}
	avoidableDamage['alist'] = {}
end