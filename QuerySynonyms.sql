select Num,
STUFF(( SELECT cast(snk.SynonymKey as nvarchar(100)) + ';'  FROM dbo.Synonyms snk where sn.Num=snk.Num  order by snk.SynonymKey for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') AS SynKey,
STUFF(( SELECT cast(snk.LanguageCode as nvarchar(100)) + ';' FROM dbo.Synonyms snk where sn.Num=snk.Num  order by snk.SynonymKey for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') AS LanCode,
STUFF(( SELECT cast(snk.Synonym as nvarchar(100)) + ';' FROM dbo.Synonyms snk where sn.Num=snk.Num  order by snk.SynonymKey for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') AS SynList
from Synonyms sn
group by Num;