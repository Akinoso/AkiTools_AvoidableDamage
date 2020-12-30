AkiAD = {}

AkiAD.version = GetAddOnMetadata('AkiTools_AvoidableDamage', 'Version')

AkiAD.frame = CreateFrame('Frame', 'AkiADFrame')
AkiAD.frame:Hide()
AkiAD.panel = CreateFrame('Frame', 'AkiADPanel')
AkiAD.panel:Hide()
AkiAD.scrollFrame = CreateFrame("ScrollFrame", nil, UIParent, "UIPanelScrollFrameTemplate")
AkiAD.scrollFrame:Hide()