---------------------------
-----  Personalities ------
---------------------------
with unitFileAttac as
(SELECT UnitFileAttachments.unitid, FileAttachments.AttachmentFileName, FileAttachments.AttachmentNum, FileAttachments.AttachmentPath
FROM 		FileAttachments,UnitFileAttachments
WHERE  	FileAttachments.AttachmentNum = UnitFileAttachments.AttachmentNum),
 v as
(SELECT   	u.UnitId,u.EditorRemarks, u.ForPreview, u.IsValueUnit,u.OldUnitId,
			u.RightsCode, dbo.RightsTypes.RightsDesc,
			u.TS,u.UnitDisplayStatus, dbo.UnitDisplayStatus.DisplayStatusDesc,
			u.UnitStatus, dbo.UnitStatuses.StatusDesc,
			u.UnitType, dbo.UnitTypes.UnitTypeDesc,
			u.UpdateDate, u.UpdateUser,
			heb.Bibiliography HeBibiliography, eng.Bibiliography EnBibiliography,
			heb.id,heb.LocationInMuseum,
			eng.UnitHeader EnHeader,
			heb.UnitHeader HeHeader ,
			heb.UnitHeaderDMSoundex HeUnitHeaderDMSoundex, eng.UnitHeaderDMSoundex EnUnitHeaderDMSoundex,
			heb.UnitText1 HeUnitText1,
			heb.UnitText2 HeUnitText2,
			eng.UnitText1 EnUnitText1,
			eng.UnitText2 EnUnitText2,
			STUFF(( SELECT ',' + cast(ul.LexiconId as varchar(max)) FROM dbo.UnitsLexicon ul where ul.UnitId=u.UnitId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') UserLexicon,
			STUFF(( SELECT ',' + cast(ufl.AttachmentFileName as nvarchar(max)) FROM unitFileAttac ufl where ufl.UnitId=u.UnitId order by ufl.AttachmentNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') AttachmentFileName,
			STUFF(( SELECT ',' + cast(ufl.AttachmentPath as nvarchar(max)) FROM unitFileAttac ufl where ufl.UnitId=u.UnitId order by ufl.AttachmentNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') AttachmentPath,
			STUFF(( SELECT ',' + cast(ufl.AttachmentNum as nvarchar(max)) FROM unitFileAttac ufl where ufl.UnitId=u.UnitId order by ufl.AttachmentNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') AttachmentNum
--dbo.PlaceTypesData.PlaceTypeDesc,dbo.Places.PlaceTypeCode,
FROM        dbo.Units u
LEFT JOIN	dbo.UnitData heb ON u.UnitId = heb.UnitId and heb.LanguageCode=1
LEFT JOIN	dbo.UnitData eng ON u.UnitId = eng.UnitId and eng.LanguageCode=0
LEFT JOIN 	dbo.RightsTypes ON u.RightsCode = dbo.RightsTypes.RightsCode
LEFT JOIN 	dbo.UnitDisplayStatus ON u.UnitDisplayStatus = dbo.UnitDisplayStatus.DisplayStatus
LEFT JOIN 	dbo.UnitStatuses ON u.UnitStatus = dbo.UnitStatuses.UnitStatus
LEFT JOIN 	dbo.UnitTypes ON u.UnitType = dbo.UnitTypes.UnitType
WHERE     	u.UnitType =8)
SELECT   v.*,
		STUFF(( SELECT cast(ppt.PersonTypeCode as varchar(max)) + ',' FROM dbo.PersonalitiesPersonTypes ppt where ppt.PersonalityId=v.UnitId order by PersonTypeId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PersonTypeCodes,
		STUFF(( SELECT cast(pt.PersonTypeDesc as varchar(max)) + ',' FROM dbo.PersonalitiesPersonTypes ppt, PersonTypesData pt where pt.PersonTypeCode=ppt.PersonTypeCode and ppt.PersonalityId=v.UnitId and pt.LanguageCode=0 for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') HePersonTypeCodesDesc,
		STUFF(( SELECT cast(pt.PersonTypeDesc as nvarchar(max)) + ',' FROM dbo.PersonalitiesPersonTypes ppt, PersonTypesData pt where pt.PersonTypeCode=ppt.PersonTypeCode and ppt.PersonalityId=v.UnitId and pt.LanguageCode=1 for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') EnPersonTypeCodesDesc,
		STUFF(( SELECT cast(ppt.PersonTypeId as varchar(max)) + ',' FROM dbo.PersonalitiesPersonTypes ppt where ppt.PersonalityId=v.UnitId order by PersonTypeId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PersonTypeIds,
		STUFF(( SELECT cast(ppt.IsMainCreatorType as varchar(max)) + ',' FROM dbo.PersonalitiesPersonTypes ppt where ppt.PersonalityId=v.UnitId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') IsMainCreatorType,
		--UnitSources
		STUFF(( SELECT cast(us.SourceId as varchar(max)) + ',' FROM dbo.UnitSources us where us.UnitId=v.UnitId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PictureSources,
		--UnitPreviewPics
		STUFF(( SELECT cast(dbo.PicturesUnitPics.PictureId as varchar(max)) + ',' FROM dbo.UnitPreviewPics upp JOIN dbo.PicturesUnitPics ON upp.PictureId = dbo.PicturesUnitPics.PictureId AND upp.UnitId <> dbo.PicturesUnitPics.PictureUnitId and upp.UnitId =v.UnitId order by upp.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PictureId,
		STUFF(( SELECT cast(upp.IsPreview as varchar(1)) + ',' FROM dbo.UnitPreviewPics upp where upp.UnitId=v.UnitId order by upp.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') IsPreview,
		-- UnitPlaces
		STUFF(( SELECT cast(upp.PlaceId as varchar(max)) + ',' FROM dbo.UnitPlaces upp where upp.UnitId=v.UnitId order by upp.PlaceId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PlaceIds,
		STUFF(( SELECT cast(upp.PlaceDescriptionTypeCode as varchar(max)) + ',' FROM dbo.UnitPlaces upp where upp.UnitId=v.UnitId order by upp.PlaceId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PlaceTypeCodes,
		STUFF(( SELECT cast(upd.PlaceDescriptionTypeDesc as nvarchar(max)) + ',' FROM dbo.UnitPlaces up join dbo.PlaceDescriptionTypesData upd on upd.PlaceDescriptionTypeCode=up.PlaceDescriptionTypeCode where up.UnitId=v.UnitId and upd.LanguageCode=1 order by up.PlaceId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') HePlaceTypeCodesDesc,
		STUFF(( SELECT cast(upd.PlaceDescriptionTypeDesc as nvarchar(max)) + ',' FROM dbo.UnitPlaces up join dbo.PlaceDescriptionTypesData upd on upd.PlaceDescriptionTypeCode=up.PlaceDescriptionTypeCode where up.UnitId=v.UnitId and upd.LanguageCode=0 order by up.PlaceId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') EnPlaceTypeCodesDesc,
		--Family Name
		STUFF(( SELECT cast(uf.FamilyNameId as nvarchar(max)) + ',' FROM [dbo].[UnitFamilyNames] uf where uf.UnitId=v.UnitId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') FamilyNameIds,
		--Period
		STUFF(( SELECT cast(pu.PeriodNum as varchar(max)) + ',' FROM dbo.UnitPeriods pu where pu.UnitId=v.UnitId order by pu.PeriodNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PeriodNum,
		STUFF(( SELECT cast(pu.PeriodTypeCode as varchar(max)) + ',' FROM dbo.UnitPeriods pu where pu.UnitId=v.UnitId order by pu.PeriodNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PeriodTypeCode,
		STUFF(( SELECT cast(ptd.PeriodTypeDesc as nvarchar(max)) + ',' FROM dbo.UnitPeriods pu join dbo.PeriodTypesData ptd on ptd.PeriodTypeCode=pu.PeriodTypeCode where pu.UnitId=v.UnitId and ptd.LanguageCode=1 order by pu.PeriodNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') HePeriodTypeDesc,
		STUFF(( SELECT cast(ptd.PeriodTypeDesc as nvarchar(max)) + ',' FROM dbo.UnitPeriods pu join dbo.PeriodTypesData ptd on ptd.PeriodTypeCode=pu.PeriodTypeCode where pu.UnitId=v.UnitId and ptd.LanguageCode=0 order by pu.PeriodNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') EnPeriodTypeDesc,
		STUFF(( SELECT cast(pu.PeriodDateTypeCode as varchar(max)) + ',' FROM dbo.UnitPeriods pu where pu.UnitId=v.UnitId order by pu.PeriodNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PeriodDateTypeCode,
		STUFF(( SELECT cast(ptd.PeriodDateTypeDesc as nvarchar(max)) + ',' FROM dbo.UnitPeriods pu join dbo.PeriodDateTypesData ptd on ptd.PeriodDateTypeCode=pu.PeriodDateTypeCode where pu.UnitId=v.UnitId and ptd.LanguageCode=1 order by pu.PeriodNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') HePeriodDateTypeDesc,
		STUFF(( SELECT cast(ptd.PeriodDateTypeDesc as nvarchar(max)) + ',' FROM dbo.UnitPeriods pu join dbo.PeriodDateTypesData ptd on ptd.PeriodDateTypeCode=pu.PeriodDateTypeCode where pu.UnitId=v.UnitId and ptd.LanguageCode=0 order by pu.PeriodNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') EnPeriodDateTypeDesc,
		STUFF(( SELECT cast(pu.PeriodStartDate as varchar(max)) + ',' FROM dbo.UnitPeriods pu where pu.UnitId=v.UnitId order by pu.PeriodNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PeriodStartDate,
		STUFF(( SELECT cast(pu.PeriodEndDate as varchar(max)) + ',' FROM dbo.UnitPeriods pu where pu.UnitId=v.UnitId order by pu.PeriodNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PeriodEndDate,
		STUFF(( SELECT cast(pu.PeriodDesc as nvarchar(max)) + ',' FROM dbo.UnitPeriodsData pu where pu.UnitId=v.UnitId and pu.LanguageCode=1 order by pu.PeriodNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') HePeriodDesc,
		STUFF(( SELECT cast(pu.PeriodDesc as nvarchar(max)) + ',' FROM dbo.UnitPeriodsData pu where pu.UnitId=v.UnitId and pu.LanguageCode=0 order by pu.PeriodNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') EnPeriodDesc
		,per.PersonalityId,
		HeData.FirstName HeFirstName, HeData.LastName HeLastName, HeData.MiddleName HeMiddleName, HeData.NickName HeNickName, HeData.OtherNames HeOtherNames,HeData.Title HeTitle,
		EnData.FirstName AS Expr1, EnData.LastName AS Expr2, EnData.MiddleName, EnData.NickName, EnData.OtherNames,EnData.Title
FROM v
JOIN dbo.Personalities AS per on v.UnitId=per.PersonalityId
LEFT JOIN dbo.PersonalitiesData AS HeData ON v.UnitId = HeData.PersonalityId AND HeData.LanguageCode = 0
LEFT JOIN dbo.PersonalitiesData AS EnData ON v.UnitId = EnData.PersonalityId AND EnData.LanguageCode = 1;