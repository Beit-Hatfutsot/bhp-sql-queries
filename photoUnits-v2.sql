--------------------------
-----  Pictures ----------
--------------------------
with unitFileAttac as
(SELECT 	UnitFileAttachments.unitid, 
			FileAttachments.AttachmentFileName, 
			FileAttachments.AttachmentNum, 
			FileAttachments.AttachmentPath
 FROM 		FileAttachments,UnitFileAttachments
WHERE  		FileAttachments.AttachmentNum = UnitFileAttachments.AttachmentNum),
 v as
(SELECT   	u.UnitId					as UnitId,
			u.EditorRemarks				as EditorRemarks, 
			u.ForPreview				as ForPreview, 
			u.IsValueUnit				as IsValueUnit,
			u.OldUnitId					as OldUnitId,
			u.RightsCode				as RightsCode, 
			rt.RightsDesc				as RightsDesc,
			u.TS						as TS,
			u.UnitDisplayStatus			as UnitDisplayStatus, 
			uds.DisplayStatusDesc		as DisplayStatusDesc,
			u.UnitStatus				as UnitStatus, 
			us.StatusDesc				as StatusDesc,
			u.UnitType					as UnitType, 
			ut.UnitTypeDesc				as UnitTypeDesc,
			u.UpdateDate				as UpdateDate, 
			u.UpdateUser				as UpdateUser,
			heb.Bibiliography 			as HeBibiliography, 
			eng.Bibiliography 			as EnBibiliography,
			heb.id						as id,
			heb.LocationInMuseum		as LocationInMuseum,
			eng.UnitHeader 				as EnHeader,
			heb.UnitHeader 				as HeHeader,
			heb.UnitHeaderDMSoundex 	as HeUnitHeaderDMSoundex, 
			eng.UnitHeaderDMSoundex 	as EnUnitHeaderDMSoundex,
			heb.UnitText1 				as HeUnitText1,
			heb.UnitText2 				as HeUnitText2,
			eng.UnitText1 				as EnUnitText1,
			eng.UnitText2 				as EnUnitText2,
			STUFF(( SELECT cast(ul.LexiconId as varchar(max)) + ',' FROM dbo.UnitsLexicon ul where ul.UnitId=u.UnitId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') UserLexicon,
			STUFF(( SELECT cast(ufl.AttachmentFileName as nvarchar(max)) + ',' FROM unitFileAttac ufl where ufl.UnitId=u.UnitId order by ufl.AttachmentNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') AttachmentFileName,
			STUFF(( SELECT cast(ufl.AttachmentPath as nvarchar(max)) + ',' FROM unitFileAttac ufl where ufl.UnitId=u.UnitId order by ufl.AttachmentNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') AttachmentPath,
			STUFF(( SELECT cast(ufl.AttachmentNum as nvarchar(max)) + ',' FROM unitFileAttac ufl where ufl.UnitId=u.UnitId order by ufl.AttachmentNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') AttachmentNum
--dbo.PlaceTypesData.PlaceTypeDesc,dbo.Places.PlaceTypeCode,
FROM        dbo.Units u
LEFT JOIN	dbo.UnitData heb ON u.UnitId = heb.UnitId and heb.LanguageCode=1
LEFT JOIN	dbo.UnitData eng ON u.UnitId = eng.UnitId and eng.LanguageCode=0
--LEFT JOIN dbo.UnitsLexicon ul ON ul.UnitId=u.UnitId
LEFT JOIN dbo.RightsTypes rt ON u.RightsCode = rt.RightsCode
LEFT JOIN dbo.UnitDisplayStatus uds ON u.UnitDisplayStatus = uds.DisplayStatus
LEFT JOIN dbo.UnitStatuses us ON u.UnitStatus = us.UnitStatus
LEFT JOIN dbo.UnitTypes ut ON u.UnitType = ut.UnitType
WHERE     u.UnitType =1) -- 141405
SELECT  pic.*,
		--UnitSources
		STUFF(( SELECT cast(us.SourceId as varchar(max)) + ',' FROM dbo.UnitSources us where us.UnitId=pic.UnitId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PictureSources,
		--UnitPreviewPics
		STUFF(( SELECT  cast(dbo.PicturesUnitPics.PictureUnitId as varchar(max)) FROM dbo.UnitPreviewPics upp JOIN dbo.PicturesUnitPics ON upp.PictureId = dbo.PicturesUnitPics.PictureId AND upp.UnitId =pic.UnitId order by upp.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PrevPictureUnitsIds,
		STUFF(( SELECT cast(upp.IsPreview as varchar(1)) FROM dbo.UnitPreviewPics upp where upp.UnitId=pic.UnitId order by upp.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') IsPreview,
		STUFF(( SELECT cast(upp.PictureId as varchar(max)) FROM dbo.UnitPreviewPics upp where upp.UnitId=pic.UnitId order by upp.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PrevPictureIds,
		-- + Pictures Files Details
		STUFF(( SELECT isnull(cast(P.PicturePath as varchar(max)),'') + ',' FROM dbo.UnitPreviewPics upp left join Pictures P on P.PictureId=upp.PictureId where upp.UnitId=pic.UnitId order by upp.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PrevPicturePaths,
		STUFF(( SELECT  isnull(cast(P.PictureFileName as varchar(max)),'') FROM dbo.UnitPreviewPics upp left join Pictures P on P.PictureId=upp.PictureId where upp.UnitId=pic.UnitId order by upp.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PrevPictureFileNames,
		-- UnitPlaces
		STUFF(( SELECT cast(upp.PlaceId as varchar(max)) + ',' FROM dbo.UnitPlaces upp where upp.UnitId=pic.UnitId order by upp.PlaceId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PlaceIds,
		STUFF(( SELECT cast(upp.PlaceDescriptionTypeCode as varchar(max)) + ',' FROM dbo.UnitPlaces upp where upp.UnitId=pic.UnitId order by upp.PlaceId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PlaceTypeCodes,
		STUFF(( SELECT cast(upd.PlaceDescriptionTypeDesc as nvarchar(max)) + ',' FROM dbo.UnitPlaces up join dbo.PlaceDescriptionTypesData upd on upd.PlaceDescriptionTypeCode=up.PlaceDescriptionTypeCode where up.UnitId=pic.UnitId and upd.LanguageCode=1 order by up.PlaceId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') HePlaceTypeCodesDesc,
		STUFF(( SELECT cast(upd.PlaceDescriptionTypeDesc as nvarchar(max)) + ',' FROM dbo.UnitPlaces up join dbo.PlaceDescriptionTypesData upd on upd.PlaceDescriptionTypeCode=up.PlaceDescriptionTypeCode where up.UnitId=pic.UnitId and upd.LanguageCode=0 order by up.PlaceId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') EnPlaceTypeCodesDesc,
		-- PIctureReceived
		STUFF(( SELECT cast(pu.PictureReceiveUnitId as varchar(max)) + ',' FROM dbo.PictureUnits pu where pu.PictureUnitId=pic.UnitId order by pu.PictureReceiveUnitId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PIctureReceivedIds,
		-- UnitPersonalities
		STUFF(( SELECT cast(pu.PersonalityId as varchar(max)) + ',' FROM dbo.UnitPersonalities pu where pu.UnitId=pic.UnitId order by pu.PersonalityId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PersonalityIds,
		STUFF(( SELECT cast(pu.PersonTypeCode as varchar(max)) + ',' FROM dbo.UnitPersonalities pu where pu.UnitId=pic.UnitId order by pu.PersonalityId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PersonalityTypes,
		STUFF(( SELECT cast(ptd.PersonTypeDesc as nvarchar(max)) + ',' FROM dbo.UnitPersonalities pu join dbo.PersonTypesData ptd on ptd.PersonTypeCode=pu.PersonTypeCode  where pu.UnitId=pic.UnitId and ptd.LanguageCode=1 order by pu.PersonalityId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') HePersonalityTypeDesc,
		STUFF(( SELECT cast(ptd.PersonTypeDesc as nvarchar(max)) + ',' FROM dbo.UnitPersonalities pu join dbo.PersonTypesData ptd on ptd.PersonTypeCode=pu.PersonTypeCode  where pu.UnitId=pic.UnitId and ptd.LanguageCode=0 order by pu.PersonalityId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') EnPersonalityTypeDesc,
		STUFF(( SELECT cast(pu.PerformerType as varchar(max)) + ',' FROM dbo.UnitPersonalities pu where pu.UnitId=pic.UnitId order by pu.PersonalityId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PerformerTyps,
		STUFF(( SELECT cast(ptd.PerformerTypeDesc as nvarchar(max)) + ',' FROM dbo.UnitPersonalities pu join dbo.PerformersTypesData ptd on ptd.PerformerType=pu.PerformerType where pu.UnitId=pic.UnitId  and ptd.LanguageCode=1 order by pu.PersonalityId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') HePerformerTypeDec,
		STUFF(( SELECT cast(ptd.PerformerTypeDesc as nvarchar(max)) + ',' FROM dbo.UnitPersonalities pu join dbo.PerformersTypesData ptd on ptd.PerformerType=pu.PerformerType where pu.UnitId=pic.UnitId  and ptd.LanguageCode=0 order by pu.PersonalityId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') EnPerformerTypeDec,
		STUFF(( SELECT cast(pu.OrderBy as varchar(max)) + ',' FROM dbo.UnitPersonalities pu where pu.UnitId=pic.UnitId order by pu.PersonalityId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') OrderBy,
		-- RelatedPictures
		STUFF(( SELECT cast(pu.PicId as varchar(max))  + ','FROM dbo.PicturesUnitPics pu where pu.PictureUnitId=pic.UnitId order by pu.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PicIds,
		STUFF(( SELECT cast(pu.PictureId as varchar(max)) + ',' FROM dbo.PicturesUnitPics pu where pu.PictureUnitId=pic.UnitId order by pu.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PictureIds,
		STUFF(( SELECT cast(pu.OldPictureNumber as varchar(max)) + ',' FROM dbo.PicturesUnitPics pu where pu.PictureUnitId=pic.UnitId order by pu.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') OldPictureNumbers,
		STUFF(( SELECT cast(pu.PictureTypeCode as varchar(max)) + ',' FROM dbo.PicturesUnitPics pu where pu.PictureUnitId=pic.UnitId order by pu.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PictureTypeCodes,
		STUFF(( SELECT cast(ptd.PictureTypeDesc as nvarchar(max)) + ',' FROM dbo.PicturesUnitPics pu join dbo.PictureTypesData ptd on ptd.PictureTypeCode=pu.PictureTypeCode where pu.PictureUnitId=pic.UnitId and ptd.LanguageCode=1 order by pu.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') HePictureTypeDesc,
		STUFF(( SELECT cast(ptd.PictureTypeDesc as nvarchar(max)) + ',' FROM dbo.PicturesUnitPics pu join dbo.PictureTypesData ptd on ptd.PictureTypeCode=pu.PictureTypeCode where pu.PictureUnitId=pic.UnitId and ptd.LanguageCode=0 order by pu.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') EnPictureTypeDesc,
		STUFF(( SELECT cast(pu.Resolution as varchar(max)) + ',' FROM dbo.PicturesUnitPics pu where pu.PictureUnitId=pic.UnitId order by pu.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') Resolutions,
		STUFF(( SELECT cast(pu.NegativeNumber as varchar(max)) + ',' FROM dbo.PicturesUnitPics pu where pu.PictureUnitId=pic.UnitId order by pu.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') NegativeNumbers,
		STUFF(( SELECT cast(pu.PictureLocation as varchar(max)) + ',' FROM dbo.PicturesUnitPics pu where pu.PictureUnitId=pic.UnitId order by pu.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PictureLocations,
		STUFF(( SELECT cast(pu.LocationCode as varchar(max)) + ',' FROM dbo.PicturesUnitPics pu where pu.PictureUnitId=pic.UnitId order by pu.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') LocationCode,
		STUFF(( SELECT cast(pu.ToScan as varchar(max)) + ',' FROM dbo.PicturesUnitPics pu where pu.PictureUnitId=pic.UnitId order by pu.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') ToScan,
		STUFF(( SELECT cast(pu.ForDisplay as varchar(max)) + ',' FROM dbo.PicturesUnitPics pu where pu.PictureUnitId=pic.UnitId order by pu.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') ForDisplay,
		STUFF(( SELECT cast(pu.IsPreview as varchar(max)) + ',' FROM dbo.PicturesUnitPics pu where pu.PictureUnitId=pic.UnitId order by pu.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') IsPreview,
		STUFF(( SELECT cast(pu.IsLandscape as varchar(max)) + ',' FROM dbo.PicturesUnitPics pu where pu.PictureUnitId=pic.UnitId order by pu.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') IsLandscape,
		-- Pictures Files Details
		STUFF(( SELECT isnull(cast(P.PicturePath as varchar(max)),'') FROM dbo.PicturesUnitPics pu left join Pictures P on P.PictureId=pu.PictureId where pu.PictureUnitId=pic.UnitId and pu.PictureId is not null order by pu.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PicturePaths,
		STUFF(( SELECT isnull(cast(P.PictureFileName as varchar(max)),'') + ',' FROM dbo.PicturesUnitPics pu left join Pictures P on P.PictureId=pu.PictureId where pu.PictureUnitId=pic.UnitId and pu.PictureId is not null order by pu.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PictureFileNames,
		--UnitPeriod
		STUFF(( SELECT cast(pu.PeriodNum as varchar(max)) + ',' FROM dbo.UnitPeriods pu where pu.UnitId=pic.UnitId order by pu.PeriodNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PeriodNum,
		STUFF(( SELECT cast(pu.PeriodTypeCode as varchar(max)) + ',' FROM dbo.UnitPeriods pu where pu.UnitId=pic.UnitId order by pu.PeriodNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PeriodTypeCode,
		STUFF(( SELECT cast(ptd.PeriodTypeDesc as nvarchar(max)) + ',' FROM dbo.UnitPeriods pu join dbo.PeriodTypesData ptd on ptd.PeriodTypeCode=pu.PeriodTypeCode where pu.UnitId=pic.UnitId and ptd.LanguageCode=1 order by pu.PeriodNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') HePeriodTypeDesc,
		STUFF(( SELECT cast(ptd.PeriodTypeDesc as nvarchar(max)) + ',' FROM dbo.UnitPeriods pu join dbo.PeriodTypesData ptd on ptd.PeriodTypeCode=pu.PeriodTypeCode where pu.UnitId=pic.UnitId and ptd.LanguageCode=0 order by pu.PeriodNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') EnPeriodTypeDesc,
		STUFF(( SELECT cast(pu.PeriodDateTypeCode as varchar(max)) + ',' FROM dbo.UnitPeriods pu where pu.UnitId=pic.UnitId order by pu.PeriodNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PeriodDateTypeCode,
		STUFF(( SELECT cast(ptd.PeriodDateTypeDesc as nvarchar(max)) + ',' FROM dbo.UnitPeriods pu join dbo.PeriodDateTypesData ptd on ptd.PeriodDateTypeCode=pu.PeriodDateTypeCode where pu.UnitId=pic.UnitId and ptd.LanguageCode=1 order by pu.PeriodNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') HePeriodDateTypeDesc,
		STUFF(( SELECT cast(ptd.PeriodDateTypeDesc as nvarchar(max)) + ',' FROM dbo.UnitPeriods pu join dbo.PeriodDateTypesData ptd on ptd.PeriodDateTypeCode=pu.PeriodDateTypeCode where pu.UnitId=pic.UnitId and ptd.LanguageCode=0 order by pu.PeriodNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') EnPeriodDateTypeDesc,
		STUFF(( SELECT cast(pu.PeriodStartDate as varchar(max)) + ',' FROM dbo.UnitPeriods pu where pu.UnitId=pic.UnitId order by pu.PeriodNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PeriodStartDate,
		STUFF(( SELECT cast(pu.PeriodEndDate as varchar(max)) + ',' FROM dbo.UnitPeriods pu where pu.UnitId=pic.UnitId order by pu.PeriodNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PeriodEndDate,
		STUFF(( SELECT cast(pu.PeriodDesc as nvarchar(max)) + ',' FROM dbo.UnitPeriodsData pu where pu.UnitId=pic.UnitId and pu.LanguageCode=1 order by pu.PeriodNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') HePeriodDesc,
		STUFF(( SELECT cast(pu.PeriodDesc as nvarchar(max)) + ',' FROM dbo.UnitPeriodsData pu where pu.UnitId=pic.UnitId and pu.LanguageCode=0 order by pu.PeriodNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') EnPeriodDesc,
		-- Exhabitions
		STUFF(( SELECT cast(ex.[ExhibitionId] as nvarchar(max)) + ',' FROM dbo.ExhibitionLinkedUnits ex where ex.[LinkedUnitId]=pic.UnitId order by ex.[ExhibitionId] for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') ExhibitionId,
		STUFF(( SELECT cast(ex.IsPreview as nvarchar(max)) + ',' FROM dbo.ExhibitionLinkedUnits ex where ex.[LinkedUnitId]=pic.UnitId order by ex.[ExhibitionId] for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') ExhibitionIsPreview
FROM v pic
