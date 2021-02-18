SLASH_AKIAD1 = '/akiad'
SLASH_AKIAD2 = '/akiAD'
SlashCmdList['AKIAD'] = function(msg)

    local command, rest = msg:lower():match('^(%S*)%s*(.-)$')

	if command == 'ad' then
		AkiAD:AnnounceAD(rest)
	
	elseif command == 'ads' then
		AkiAD:AnnounceADS(rest)

	elseif command == 'adn' then
		AkiAD:AnnounceADN(rest)

	elseif command == 'adml' then
		AkiAD:AnnounceADMsgList(rest)

	elseif command == 'cfg' then
		InterfaceOptionsFrame_OpenToCategory('AkiTools_AD')
		InterfaceOptionsFrame_OpenToCategory('AkiTools_AD')

	else
		print('\124cFFFF0000------AkiTools------\n\124cFF00FF00/akiad cfg   :打开设置菜单\n/akiad ad [频道] :播报毒瘤排行榜\n/akiad ads [频道] :播报可规避法术排行榜\n/akiad adn [频道] :播报毒瘤王的可规避法术排行榜\n/akiad adml   :打印所有毒瘤播报记录\n\124cFFFF0000注：其中[频道]包括：s:说 | g:工会 | r:团队 | p:小队 | y:喊话 | i: 副本队伍\n注：[频道]为空则打印在聊天窗口')
	end
end