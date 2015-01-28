WITH   EngPersonalitiesData as (
select * from PersonalitiesData where LanguageCode = 0
),
HebPersonalitiesData as (
select * from PersonalitiesData where LanguageCode =1
),
    EngPersonTypesData as (
select * from PersonTypesData where LanguageCode = 0
)
select
  HebPersonalitiesData.PersonalityId  as PID,
  EngPersonalitiesData.Title as EnTitle,
  HebPersonalitiesData.Title as HeTitle,
  EngPersonalitiesData.FirstName as EnFirstName,
  HebPersonalitiesData.FirstName as HeFirstName,
  EngPersonalitiesData.LastName  as EnLastName,
  HebPersonalitiesData.LastName as HeLastName,
  EngPersonalitiesData.MiddleName as EnMiddleName,
  EngPersonalitiesData.NickName as EnNickName,
  EngPersonalitiesData.OtherNames as EnOtherNames,
  HebPersonalitiesData.MiddleName as HeMiddleName,
  HebPersonalitiesData.NickName as HeNickName,
  HebPersonalitiesData.OtherNames as HeOtherNames,
  /*PersonTypeDesc*/
  Ptypes.PersonTypeCode,
  EngPtypeData.PersonTypeDesc as EnPtype,
  HebPtypeData.PersonTypeDesc as HePtype,
  STUFF(( SELECT  cast(UnitPreviewPics.PictureId as nvarchar(max))+ ','FROM UnitPersonalities,Units,UnitPreviewPics  where UnitPreviewPics.UnitId = Units.UnitId and Personalities.PersonalityId = UnitPersonalities.PersonalityId  and Units.UnitId = UnitPersonalities.UnitId and (Units.UnitType=1) order by UnitPersonalities.PersonalityId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PicID,
  STUFF(( SELECT  cast(UnitPersonalities.UnitId as nvarchar(max))+ ','FROM UnitPersonalities,Units  where Personalities.PersonalityId = UnitPersonalities.PersonalityId  and Units.UnitId = UnitPersonalities.UnitId and (Units.UnitType=2) order by UnitPersonalities.PersonalityId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') MusicID,
  STUFF(( SELECT  cast(UnitPersonalities.UnitId as nvarchar(max))+ ','FROM UnitPersonalities,Units  where Personalities.PersonalityId = UnitPersonalities.PersonalityId  and Units.UnitId = UnitPersonalities.UnitId and (Units.UnitType=3) order by UnitPersonalities.PersonalityId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') MusicTextID,
  STUFF(( SELECT  cast(UnitPersonalities.UnitId as nvarchar(max))+ ','FROM UnitPersonalities,Units  where Personalities.PersonalityId = UnitPersonalities.PersonalityId  and Units.UnitId = UnitPersonalities.UnitId and (Units.UnitType=5) order by UnitPersonalities.PersonalityId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PlaceID,
  STUFF(( SELECT  cast(UnitPersonalities.UnitId as nvarchar(max))+ ','FROM UnitPersonalities,Units  where Personalities.PersonalityId = UnitPersonalities.PersonalityId  and Units.UnitId = UnitPersonalities.UnitId and (Units.UnitType=6) order by UnitPersonalities.PersonalityId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') FamiltNID,
  STUFF(( SELECT  cast(UnitPersonalities.UnitId as nvarchar(max))+ ','FROM UnitPersonalities,Units  where Personalities.PersonalityId = UnitPersonalities.PersonalityId  and Units.UnitId = UnitPersonalities.UnitId and (Units.UnitType=7) order by UnitPersonalities.PersonalityId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') SourceID,
  STUFF(( SELECT  cast(UnitPersonalities.UnitId as nvarchar(max))+ ','FROM UnitPersonalities,Units  where Personalities.PersonalityId = UnitPersonalities.PersonalityId  and Units.UnitId = UnitPersonalities.UnitId and (Units.UnitType=8) order by UnitPersonalities.PersonalityId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PersonalityID,
  STUFF(( SELECT  cast(UnitPersonalities.UnitId as nvarchar(max))+ ','FROM UnitPersonalities,Units  where Personalities.PersonalityId = UnitPersonalities.PersonalityId  and Units.UnitId = UnitPersonalities.UnitId and (Units.UnitType=9) order by UnitPersonalities.PersonalityId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') FilmID,
  STUFF(( SELECT  cast(UnitPersonalities.UnitId as nvarchar(max))+ ','FROM UnitPersonalities,Units  where Personalities.PersonalityId = UnitPersonalities.PersonalityId  and Units.UnitId = UnitPersonalities.UnitId and (Units.UnitType=10) order by UnitPersonalities.PersonalityId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') LexiconID,
  STUFF(( SELECT  cast(UnitPersonalities.UnitId as nvarchar(max))+ ','FROM UnitPersonalities,Units  where Personalities.PersonalityId = UnitPersonalities.PersonalityId  and Units.UnitId = UnitPersonalities.UnitId and (Units.UnitType=11) order by UnitPersonalities.PersonalityId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') CreatorID,
  STUFF(( SELECT  cast(UnitPersonalities.UnitId as nvarchar(max))+ ','FROM UnitPersonalities,Units  where Personalities.PersonalityId = UnitPersonalities.PersonalityId  and Units.UnitId = UnitPersonalities.UnitId and (Units.UnitType=12) order by UnitPersonalities.PersonalityId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') GlobalID
from Personalities
  left join PersonalitiesPersonTypes Ptypes on (Personalities.PersonalityId = Ptypes.PersonalityId)
  left join PersonTypesData EngPtypeData on (Ptypes.PersonTypeCode = EngPtypeData.PersonTypeCode and EngPtypeData.LanguageCode=0)
  left join PersonTypesData HebPtypeData on (Ptypes.PersonTypeCode = HebPtypeData.PersonTypeCode and HebPtypeData.LanguageCode=1)
  Left JOIN EngPersonalitiesData on (Personalities.PersonalityId = EngPersonalitiesData.PersonalityId )
  Left JOIN HebPersonalitiesData on (Personalities.PersonalityId = HebPersonalitiesData.PersonalityId)