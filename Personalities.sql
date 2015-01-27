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
  HebPtypeData.PersonTypeDesc as HbPtype,
  STUFF(( SELECT ',' + cast(UnitPersonalities.UnitId as nvarchar(max)) FROM UnitPersonalities  where Personalities.PersonalityId = UnitPersonalities.PersonalityId order by UnitPersonalities.PersonalityId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') UnitID
from Personalities
 -- left JOIN  UnitPersonalities on (Personalities.PersonalityId = UnitPersonalities.PersonalityId)
  left join PersonalitiesPersonTypes Ptypes on (Personalities.PersonalityId = Ptypes.PersonalityId)
  left join PersonTypesData EngPtypeData on (Ptypes.PersonTypeCode = EngPtypeData.PersonTypeCode and EngPtypeData.LanguageCode=0)
  left join PersonTypesData HebPtypeData on (Ptypes.PersonTypeCode = HebPtypeData.PersonTypeCode and HebPtypeData.LanguageCode=1)
  Left JOIN EngPersonalitiesData on (Personalities.PersonalityId = EngPersonalitiesData.PersonalityId )
  Left JOIN HebPersonalitiesData on (Personalities.PersonalityId = HebPersonalitiesData.PersonalityId);
