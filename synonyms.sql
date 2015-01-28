select  syno1.Num,
STUFF(( SELECT  cast(syno2.Synonym as nvarchar(max))+ ','FROM synonyms syno2 where syno1.Num = syno2.Num  order by syno2.Synonym for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') SynonymText,
STUFF(( SELECT  cast(syno2.LanguageCode as nvarchar(max))+ ','FROM synonyms syno2 where syno1.Num = syno2.Num  order by syno2.Synonym for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') SynoLang
from synonyms syno1
group by syno1.Num;