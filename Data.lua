-- 初始配置
AkiAD.DB = {
	solo = {
		ownAD = 'self',
		ownADSound = '',
	},
	instance = {
		ownAD = 'self',
		ownADSound = '',
		otherAD = 'self',
		otherADSound = ''
	},
	party = {
		ownAD = 'self',
		ownADSound = '',
		otherAD = 'self',
		otherADSound = ''
	},
	raid = {
		ownAD = 'self',
		ownADSound = '',
		otherAD = 'self',
		otherADSound = ''
	},
}

--所有音效列表
AkiAD.soundList = {
	'', '关',
	566564, 'Bell 1',
	565853, 'Bell 2',
	839999, 'Ice Shard',
	623880, 'Impact',
	565875, 'Orb Explode',
	569673, 'Pet Call',
	542499, 'Roar Dwarf',
	542504, 'Roar Orc',
	644480, 'Swoosh',
	539153, 'Whistle',
}

-- 可规避法术
AkiAD.avoidableDamage = {
	cache = {},
	saveByName = {},
	saveBySpell = {},
	sum = {},
	list = {},
	alist = {},
	timer = {},
	spells = {
		-- 测试
		[167381] = true,		--- Dummy Strike
		[167385] = true,		--- 超强打击
		
		-- 仙林
		[323177] = true,		--- 森林之泪
		[323250] = true,		--- 心能泥浆
		[323137] = true,		--- 迷乱花粉
		[336759] = true,		--- 闪避球
		[321834] = true,		--- 闪避球
		[341709] = true,		--- 鬼抓人
		[326263] = true,		--- 心能剥离

		-- 彼界
		[333729] = true,		--- 巨魔之护
		[328729] = true,		--- 黑暗莲花
		[333250] = true,		--- 放血之击
		[334051] = true,		--- 喷涌黑暗
		[332672] = true,		--- 剑刃风暴
		[323118] = true,		--- 鲜血弹幕
		[332332] = true,		--- 溅洒精魂
		[323569] = true,		--- 溅洒精魂
		[342869] = true,		--- 狂怒面具
		[331933] = true,		--- 失控
		[331398] = true,		--- 易爆电容
		[332157] = true,		--- 超频启动
		[331847] = true,		--- W-00F
		[323992] = true,		--- 反射手指型激光发射器究极版
		[320132] = true,		--- 暗影之怒
		[345498] = true,		--- 心能星尘风暴
		[323136] = true,		--- 心能星尘风暴
		[340026] = true,		--- 哀嚎之痛
		[320232] = true,		--- 爆破计谋
		[320723] = true,		--- 错位冲击波
		[325691] = true,		--- 寰宇崩塌
		[334913] = true,		--- 死亡之主
		[335000] = true,		--- 星辰之云
		
		-- 赎罪大厅
	},
	spellsNT = {
		-- 赎罪大厅
		[325523] = true,		--- 致命推刺
	}
}