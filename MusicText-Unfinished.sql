---------------------------
-----  Music Text --------- Not Finished Yet!!!!
---------------------------
select m.MusicTextId, m.StanzaNumber, m.TextTypeCode,ttEng.TextTypeDesc,ttHeb.TextTypeDesc,
		EngData.Incipit, HebData.Incipit,
		EngData.IncipitTranslation, HebData.IncipitTranslation,
		EngData.OriginalTitle, HebData.OriginalTitle,
		EngData.SongName, HebData.SongName,
		EngData.SongNameTranslation, HebData.SongNameTranslation,
		EngData.StanzaDesc, HebData.StanzaDesc,
		-- Music Languages (ml.IsOrigLanguage, ml.LanguageId,l.LanguageDesc,l.LanguageHebDesc)
		STUFF(( SELECT ',' + cast(ml.LanguageId as nvarchar(max)) FROM MusicTextLanguages ml where ml.MusicTextId=m.MusicTextId order by ml.LanguageId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') LanguageIds,
		STUFF(( SELECT ',' + cast(ml.IsOrigLanguage as nvarchar(max)) FROM MusicTextLanguages ml where ml.MusicTextId=m.MusicTextId order by ml.LanguageId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') IsOrigLanguage,
		STUFF(( SELECT ',' + cast(l.LanguageDesc as nvarchar(max)) FROM MusicTextLanguages ml join Languages l on l.LanguageCode=ml.LanguageId where ml.MusicTextId=m.MusicTextId order by ml.LanguageId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') LanguageDesc,
		STUFF(( SELECT ',' + cast(l.LanguageHebDesc as nvarchar(max)) FROM MusicTextLanguages ml join Languages l on l.LanguageCode=ml.LanguageId where ml.MusicTextId=m.MusicTextId order by ml.LanguageId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') LanguageHebDesc
from [dbo].MusicText m
left join MusicTextTypesData ttEng on ttEng.TextTypeCode=m.TextTypeCode and ttEng.LanguageCode=0
left join MusicTextTypesData ttHeb on ttHeb.TextTypeCode=m.TextTypeCode and ttHeb.LanguageCode=1
left join [MusicTextsData] EngData on EngData.MusicTextId=m.MusicTextId and EngData.LanguageCode=0
left join [MusicTextsData] HebData on HebData.MusicTextId=m.MusicTextId and HebData.LanguageCode=1