/*
by baruch o.
Get Personality data
where
p0 en
p1 He
*/
select
  p1.PersonalityId  as Lcode,
  p0.Title as TitleEn,
  p1.Title as TitleHe,
  p0.FirstName as FirstNameEn,
  p1.FirstName as FirstNameHE,
  p0.LastName  as LastNameEn,
  p1.LastName as LastNameHE,
  p0.MiddleName as MiddleNameEn,
  p0.NickName as NickNameEn,
  p0.OtherNames as OtherNamesEn,
  p1.MiddleName as MiddleNameHe,
  p1.NickName as NickNameHe,
  p1.OtherNames as OtherNamesHe
from PersonalitiesData p1,PersonalitiesData p0
where p0.PersonalityId=p1.PersonalityId and p0.LanguageCode=0 and p1.LanguageCode=1;
