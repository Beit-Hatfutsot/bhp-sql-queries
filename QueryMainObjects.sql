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
FROM        dbo.Units u
LEFT JOIN	dbo.UnitData heb ON u.UnitId = heb.UnitId and heb.LanguageCode=1
LEFT JOIN	dbo.UnitData eng ON u.UnitId = eng.UnitId and eng.LanguageCode=0
LEFT JOIN dbo.RightsTypes rt ON u.RightsCode = rt.RightsCode
LEFT JOIN dbo.UnitDisplayStatus uds ON u.UnitDisplayStatus = uds.DisplayStatus
LEFT JOIN dbo.UnitStatuses us ON u.UnitStatus = us.UnitStatus
LEFT JOIN dbo.UnitTypes ut ON u.UnitType = ut.UnitType
WHERE     u.UnitType =1)
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
FROM v pic;

--------------------------
-----  Places ------------
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
LEFT JOIN	dbo.UnitData heb 			ON u.UnitId = heb.UnitId and heb.LanguageCode=1
LEFT JOIN	dbo.UnitData eng 			ON u.UnitId = eng.UnitId and eng.LanguageCode=0
LEFT JOIN 	dbo.RightsTypes rt 			ON u.RightsCode = rt.RightsCode
LEFT JOIN 	dbo.UnitDisplayStatus uds 	ON u.UnitDisplayStatus = uds.DisplayStatus
LEFT JOIN 	dbo.UnitStatuses us			ON u.UnitStatus = us.UnitStatus
LEFT JOIN 	dbo.UnitTypes ut			ON u.UnitType = ut.UnitType
WHERE     u.UnitType = 5)
SELECT		plcdheb.PlaceTypeDesc 			as HePlaceTypeDesc,
			plcdeng.PlaceTypeDesc 			as EnPlaceTypeDesc,
			plc.PlaceTypeCode     			as PlaceTypeCode,
			plc.PlaceParentId	  			as PlaceParentId,
			plcd_parentheb.PlaceTypeDesc 	as PlaceParentTypeCodeDesc,
			plcd_parentheb.PlaceTypeDesc 	as HePlaceParentTypeCodeDesc,
			plcd_parenteng.PlaceTypeDesc 	as EnPlaceParentTypeCodeDesc,
			STUFF(( SELECT ',' + cast(dbo.PicturesUnitPics.PictureUnitId as varchar(max)) FROM dbo.UnitPreviewPics upp JOIN dbo.PicturesUnitPics ON upp.PictureId = dbo.PicturesUnitPics.PictureId AND upp.UnitId <> dbo.PicturesUnitPics.PictureUnitId and upp.UnitId =v.UnitId order by upp.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PictureUnitsIds,
			STUFF(( SELECT cast(upp.IsPreview as varchar(1)) + ',' FROM dbo.UnitPreviewPics upp where upp.UnitId=v.UnitId order by upp.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') IsPreview,
			STUFF(( SELECT cast(upp.PictureId as varchar(max)) + ',' FROM dbo.UnitPreviewPics upp where upp.UnitId=v.UnitId order by upp.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PictureId,
			-- + Pictures Files Details
			STUFF(( SELECT ',' + isnull(cast(P.PicturePath as varchar(max)),'') FROM dbo.UnitPreviewPics upp left join Pictures P on P.PictureId=upp.PictureId where upp.UnitId=v.UnitId order by upp.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PrevPicturePaths,
			STUFF(( SELECT ',' + isnull(cast(P.PictureFileName as varchar(max)),'') FROM dbo.UnitPreviewPics upp left join Pictures P on P.PictureId=upp.PictureId where upp.UnitId=v.UnitId order by upp.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PrevPictureFileNames
,v.*
FROM  		dbo.Places plc
JOIN  		v on plc.PlaceId = v.UnitId
LEFT JOIN 	dbo.PlaceTypesData plcdheb ON plc.PlaceTypeCode = plcdheb.PlaceTypeCode AND 1=plcdheb.LanguageCode
LEFT JOIN 	dbo.PlaceTypesData plcdeng ON plc.PlaceTypeCode = plcdeng.PlaceTypeCode AND 0=plcdeng.LanguageCode
LEFT JOIN 	dbo.Places plc_parent ON  plc_parent.PlaceId=plc.PlaceParentId
LEFT JOIN 	dbo.PlaceTypesData plcd_parentheb ON plc_parent.PlaceTypeCode = plcd_parentheb.PlaceTypeCode AND 1=plcd_parentheb.LanguageCode
LEFT JOIN 	dbo.PlaceTypesData plcd_parenteng ON plc_parent.PlaceTypeCode = plcd_parenteng.PlaceTypeCode AND 0=plcd_parenteng.LanguageCode
ORDER BY 	v.UnitId;

--------------------------
-----  Family Names ------
--------------------------
with unitFileAttac as
(SELECT 	UnitFileAttachments.unitid, 
			FileAttachments.AttachmentFileName, 
			FileAttachments.AttachmentNum, 
			FileAttachments.AttachmentPath
FROM 		FileAttachments,
			UnitFileAttachments
WHERE  		FileAttachments.AttachmentNum = UnitFileAttachments.AttachmentNum)
SELECT   	u.UnitId 				as UnitId,
			u.EditorRemarks 		as EditorRemarks, 
			u.ForPreview			as ForPreview, 
			u.IsValueUnit			as IsValueUnit,
			u.OldUnitId				as OldUnitId,
			u.RightsCode			as RightsCode, 
			u.TS					as TS,
			u.UnitDisplayStatus		as UnitDisplayStatus, 
			u.UnitStatus			as UnitStatus, 
			u.UnitType				as UnitType, 
			u.UpdateDate			as UpdateDate, 
			u.UpdateUser			as UpdateUser,
			ut.UnitTypeDesc			as UnitTypeDesc,
			uts.StatusDesc			as StatusDesc,
			rt.RightsDesc			as RightsDesc,
			uds.DisplayStatusDesc	as DisplayStatusDesc,
			heb.Bibiliography 		as HeBibiliography, 
			eng.Bibiliography 		as EnBibiliography,
			heb.id					as Id,
			heb.LocationInMuseum	as LocationInMuseum,
			eng.UnitHeader 			as EnHeader,
			heb.UnitHeader 			as HeHeader,
			heb.UnitHeaderDMSoundex as HeUnitHeaderDMSoundex, 
			eng.UnitHeaderDMSoundex as EnUnitHeaderDMSoundex,
			heb.UnitText1 			as HeUnitText1,
			heb.UnitText2 			as HeUnitText2,
			eng.UnitText1 			as EnUnitText1,
			eng.UnitText2 			as EnUnitText2,
			STUFF(( SELECT cast(ul.LexiconId as varchar(max)) + ',' 
					FROM dbo.UnitsLexicon ul 
					where ul.UnitId=u.UnitId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') 	UserLexicon,
			STUFF(( SELECT cast(ufl.AttachmentFileName as nvarchar(max)) + ','
					FROM unitFileAttac ufl 
					where ufl.UnitId=u.UnitId 
					order by ufl.AttachmentNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') AttachmentFileName,
			STUFF(( SELECT cast(ufl.AttachmentPath as nvarchar(max)) + ','
					FROM unitFileAttac ufl 
					where ufl.UnitId=u.UnitId 
					order by ufl.AttachmentNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') AttachmentPath,
			STUFF(( SELECT cast(ufl.AttachmentNum as nvarchar(max)) + ',' 
					FROM unitFileAttac ufl 
					where ufl.UnitId=u.UnitId 
					order by ufl.AttachmentNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') AttachmentNum,
			STUFF(( SELECT cast(dbo.PicturesUnitPics.PictureUnitId as varchar(max)) + ',' 
					FROM dbo.UnitPreviewPics upp 
					JOIN dbo.PicturesUnitPics ON upp.PictureId = dbo.PicturesUnitPics.PictureId AND upp.UnitId <> dbo.PicturesUnitPics.PictureUnitId and upp.UnitId =u.UnitId 
					order by upp.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PictureUnitsIds,
			STUFF(( SELECT  cast(upp.IsPreview as varchar(1)) + ',' 
					FROM dbo.UnitPreviewPics upp 
					where upp.UnitId=u.UnitId 
					order by upp.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') IsPreview,
			STUFF(( SELECT  cast(upp.PictureId as varchar(max)) + ',' 
					FROM dbo.UnitPreviewPics upp 
					where upp.UnitId=u.UnitId 
					order by upp.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PictureIds,
			-- + Pictures Files Details
			STUFF(( SELECT isnull(cast(P.PicturePath as varchar(max)),'') + ',' 
					FROM dbo.UnitPreviewPics upp left join Pictures P on P.PictureId=upp.PictureId 
					where upp.UnitId=u.UnitId  order by upp.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PrevPicturePaths,
			STUFF(( SELECT isnull(cast(P.PictureFileName as varchar(max)),'') + ',' 
					FROM dbo.UnitPreviewPics upp 
					left join Pictures P on P.PictureId=upp.PictureId 
					where upp.UnitId=u.UnitId
					order by upp.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PrevPictureFileNames
FROM        dbo.Units u
LEFT JOIN	dbo.UnitData heb ON u.UnitId = heb.UnitId and heb.LanguageCode=1
LEFT JOIN	dbo.UnitData eng ON u.UnitId = eng.UnitId and eng.LanguageCode=0
LEFT JOIN 	dbo.RightsTypes rt ON u.RightsCode = rt.RightsCode
LEFT JOIN 	dbo.UnitDisplayStatus uds ON u.UnitDisplayStatus = uds.DisplayStatus
LEFT JOIN 	dbo.UnitStatuses uts ON u.UnitStatus = uts.UnitStatus
LEFT JOIN 	dbo.UnitTypes ut ON u.UnitType = ut.UnitType
WHERE     	u.UnitType = 6;

--------------------------
-----  Gen Trees ---------
--------------------------

with unitFileAttac as
(SELECT UnitFileAttachments.unitid, FileAttachments.AttachmentFileName, FileAttachments.AttachmentNum, FileAttachments.AttachmentPath
FROM 		FileAttachments,UnitFileAttachments
WHERE  	FileAttachments.AttachmentNum = UnitFileAttachments.AttachmentNum),
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
FROM        dbo.Units u
LEFT JOIN	dbo.UnitData heb ON u.UnitId = heb.UnitId and heb.LanguageCode=1
LEFT JOIN	dbo.UnitData eng ON u.UnitId = eng.UnitId and eng.LanguageCode=0
LEFT JOIN dbo.RightsTypes rt ON u.RightsCode = rt.RightsCode
LEFT JOIN dbo.UnitDisplayStatus uds ON u.UnitDisplayStatus = uds.DisplayStatus
LEFT JOIN dbo.UnitStatuses us ON u.UnitStatus = us.UnitStatus
LEFT JOIN dbo.UnitTypes ut ON u.UnitType = ut.UnitType
WHERE     u.UnitType = 4) -- 10376
select gt.GenTreeNumber, gt.GenTreeFileId,gt.GenTreePath ,
		gt.GenTreeFileName, gt.GenTreeXmlPath,
		gtrs.LastUpdate,gtrs.AttemptCount,
		STUFF(( SELECT cast(us.SourceId as varchar(max)) + ',' FROM dbo.UnitSources us where us.UnitId=v.UnitId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,''),
		v.* 
FROM v
JOIN dbo.GenTree gt on  gt.GenTreeId=v.UnitId
LEFT JOIN GenTreeReportStatus gtrs on gtrs.GenTreeId=gt.GenTreeId;


-----------------------
-----  Movies ---------
-----------------------
with unitFileAttac as
(SELECT UnitFileAttachments.unitid, FileAttachments.AttachmentFileName, FileAttachments.AttachmentNum, FileAttachments.AttachmentPath
FROM 	FileAttachments,UnitFileAttachments
WHERE  	FileAttachments.AttachmentNum = UnitFileAttachments.AttachmentNum),
 v as
(SELECT   	u.UnitId,u.EditorRemarks, u.ForPreview, u.IsValueUnit,u.OldUnitId,
					u.RightsCode, dbo.RightsTypes.RightsDesc,--ul.LexiconId,
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
FROM         		dbo.Units u
LEFT JOIN	dbo.UnitData heb ON u.UnitId = heb.UnitId and heb.LanguageCode=1
LEFT JOIN	dbo.UnitData eng ON u.UnitId = eng.UnitId and eng.LanguageCode=0
LEFT JOIN dbo.RightsTypes ON u.RightsCode = dbo.RightsTypes.RightsCode
LEFT JOIN dbo.UnitDisplayStatus ON u.UnitDisplayStatus = dbo.UnitDisplayStatus.DisplayStatus
LEFT JOIN dbo.UnitStatuses ON u.UnitStatus = dbo.UnitStatuses.UnitStatus
LEFT JOIN dbo.UnitTypes ON u.UnitType = dbo.UnitTypes.UnitType
WHERE     u.UnitType = 9)
select  /*dbo.Movie.MovieId,*/ dbo.Movie.Minutes, dbo.Movie.ProductionYear,
		dbo.Movie.MovieFileId, dbo.Movie.ReceiveDate,
		dbo.Movie.ReceiveType,MovieRecieveEng.MovieReceiveTypeDesc MovieReceiveTypeDescEnglish,
		MovieRecieveHeb.MovieReceiveTypeDesc MovieReceiveTypeDescHebrew,
		dbo.Movie.ColorType,colorEng.ColorDesc,colorHeb.ColorDesc,
		movieDataEng.DistributionCompany,movieDataHeb.DistributionCompany,
		movieDataEng.ProductionCompany,movieDataHeb.ProductionCompany
		,dbo.MovieFiles.MovieFileName, dbo.MovieFiles.MoviePath,
		v.*,
		STUFF(( SELECT ',' + cast(up.PlaceId as nvarchar(max)) FROM dbo.UnitPlaces up where up.UnitId=dbo.Movie.MovieId order by up.PlaceId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') RelatedPlaces,
		STUFF(( SELECT ',' + cast(eu.ExhibitionId as nvarchar(max)) FROM dbo.ExhibitionLinkedUnits eu where eu.LinkedUnitId=dbo.Movie.MovieId order by eu.ExhibitionId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') RelatedExhibitions,
		STUFF(( SELECT ',' + cast(us.SourceId as nvarchar(max)) FROM dbo.UnitSources us where us.UnitId=dbo.Movie.MovieId order by us.SourceId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') RelatedSources,
		STUFF(( SELECT ',' + cast(up.PersonalityId as nvarchar(max)) FROM dbo.UnitPersonalities up where up.UnitId=dbo.Movie.MovieId order by up.PersonalityId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') RelatedPersonalitys,
		STUFF(( SELECT ',' + cast(pup.PictureUnitId as nvarchar(max)) FROM dbo.UnitPreviewPics up INNER JOIN dbo.PicturesUnitPics pup ON up.PictureId = pup.PictureId AND up.UnitId <> pup.PictureUnitId where up.UnitId=dbo.Movie.MovieId order by pup.PictureUnitId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') RelatedPics,
		STUFF(( SELECT ',' + cast(mf.CatalogCode as nvarchar(max)) FROM dbo.MovieFormat mf where mf.MovieId=dbo.Movie.MovieId order by mf.FormatId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') CatalogCodes,
		STUFF(( SELECT ',' + cast(mf.FormatCode as nvarchar(max)) FROM dbo.MovieFormat mf where mf.MovieId=dbo.Movie.MovieId order by mf.FormatId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') FormatCode,
		STUFF(( SELECT ',' + cast(mf.FormatId as nvarchar(max)) FROM dbo.MovieFormat mf where mf.MovieId=dbo.Movie.MovieId order by mf.FormatId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') FormatId,
		STUFF(( SELECT ',' + cast(mf.IsPrimaryVersion as nvarchar(max)) FROM dbo.MovieFormat mf where mf.MovieId=dbo.Movie.MovieId order by mf.FormatId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') IsPrimaryVersion,
		STUFF(( SELECT ',' + cast(mfs.FormatDesc as nvarchar(max)) FROM dbo.MovieFormats mfs, dbo.MovieFormat mf where mf.MovieId=dbo.Movie.MovieId and mfs.FormatCode=mf.FormatId order by mf.FormatId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') FormatDesc,
		STUFF(( SELECT ',' + cast(mv.LanguageId as nvarchar(max)) FROM dbo.MovieVersions mv where mv.MovieId=dbo.Movie.MovieId order by mv.VersionId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') LanguageId,
		STUFF(( SELECT ',' + cast(l.LanguageDesc as nvarchar(max)) FROM dbo.MovieVersions mv, dbo.Languages l where mv.MovieId=dbo.Movie.MovieId and l.LanguageCode=mv.LanguageId order by mv.VersionId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') VersionLanguageDesc,
		STUFF(( SELECT ',' + cast(l.LanguageHebDesc as nvarchar(max)) FROM dbo.MovieVersions mv, dbo.Languages l where mv.MovieId=dbo.Movie.MovieId and l.LanguageCode=mv.LanguageId order by mv.VersionId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') VersionLanguageHebDesc,
		STUFF(( SELECT ',' + cast(mv.VersionId as nvarchar(max)) FROM dbo.MovieVersions mv where mv.MovieId=dbo.Movie.MovieId order by mv.VersionId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') VersionId,
		STUFF(( SELECT ',' + cast(mv.VersionTypeCode as nvarchar(max)) FROM dbo.MovieVersions mv where mv.MovieId=dbo.Movie.MovieId order by mv.VersionId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') VersionTypeCode,
		STUFF(( SELECT ',' + cast(mvt.MovieVersionTypeDesc as nvarchar(max)) FROM dbo.MovieVersions mv, dbo.MovieVersionTypes mvt where mv.MovieId=dbo.Movie.MovieId and mvt.MovieVersionTypeCode=mv.VersionTypeCode and mvt.LanguageCode=0 order  by mv.VersionId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') MovieVersionTypeDescEnglish,
		STUFF(( SELECT ',' + cast(mvt.MovieVersionTypeDesc as nvarchar(max)) FROM dbo.MovieVersions mv, dbo.MovieVersionTypes mvt where mv.MovieId=dbo.Movie.MovieId and mvt.MovieVersionTypeCode=mv.VersionTypeCode and mvt.LanguageCode=1 order  by mv.VersionId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') MovieVersionTypeDescHebrew,
		msEng.SectionHeader,msEng.SectionId, msHeb.SectionHeader,msHeb.SectionId,
		msd.SectionId,msd.SectionStartMinute, msd.SectionEndMinute,
		--UnitPreviewPics
		STUFF(( SELECT ',' + cast(dbo.PicturesUnitPics.PictureUnitId as varchar(max)) FROM dbo.UnitPreviewPics upp JOIN dbo.PicturesUnitPics ON upp.PictureId = dbo.PicturesUnitPics.PictureId AND upp.UnitId <> dbo.PicturesUnitPics.PictureUnitId and upp.UnitId =dbo.Movie.MovieId order by upp.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PictureUnitsIds,
		STUFF(( SELECT ',' + cast(upp.IsPreview as varchar(1)) FROM dbo.UnitPreviewPics upp where upp.UnitId=dbo.Movie.MovieId order by upp.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') IsPreview,
		STUFF(( SELECT ',' + cast(upp.PictureId as varchar(max)) FROM dbo.UnitPreviewPics upp where upp.UnitId=dbo.Movie.MovieId order by upp.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PrevPictureIds,
		-- + Pictures Files Details
		STUFF(( SELECT ',' + isnull(cast(P.PicturePath as varchar(max)),'') FROM dbo.UnitPreviewPics upp left join Pictures P on P.PictureId=upp.PictureId where upp.UnitId=dbo.Movie.MovieId order by upp.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PrevPicturePaths,
		STUFF(( SELECT ',' + isnull(cast(P.PictureFileName as varchar(max)),'') FROM dbo.UnitPreviewPics upp left join Pictures P on P.PictureId=upp.PictureId where upp.UnitId=dbo.Movie.MovieId order by upp.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PrevPictureFileNames
from dbo.Movie
full join v on v.UnitId=dbo.Movie.MovieId
left join dbo.MovieReceiveTypesData MovieRecieveEng on MovieRecieveEng.MovieReceiveTypeCode=dbo.Movie.ReceiveType and MovieRecieveEng.LanguageCode=0
left join dbo.MovieReceiveTypesData MovieRecieveHeb on MovieRecieveHeb.MovieReceiveTypeCode=dbo.Movie.ReceiveType and MovieRecieveHeb.LanguageCode=1
left join dbo.MovieColorTypes colorEng on colorEng.ColorId=dbo.Movie.ColorType and colorEng.LanguageCode=0
left join dbo.MovieColorTypes colorHeb on colorHeb.ColorId=dbo.Movie.ColorType and colorHeb.LanguageCode=1
left join dbo.MovieData movieDataEng on movieDataEng.MovieId=dbo.Movie.MovieId and movieDataEng.LanguageCode=0
left join dbo.MovieData movieDataHeb on movieDataHeb.MovieId=dbo.Movie.MovieId and movieDataHeb.LanguageCode=1
left join dbo.MovieFiles on dbo.MovieFiles.MovieFileId=dbo.Movie.MovieFileId
left join dbo.MovieSections msEng on msEng.MovieId=dbo.Movie.MovieId and msEng.LanguageCode=0
left join dbo.MovieSections msHeb on msHeb.MovieId=dbo.Movie.MovieId and msHeb.LanguageCode=1
left join dbo.MovieSectionsData msd on msd.MovieId=dbo.Movie.MovieId;

---------------------
-----  Musics -------
---------------------
with unitFileAttac as
(SELECT UnitFileAttachments.unitid, FileAttachments.AttachmentFileName, FileAttachments.AttachmentNum, FileAttachments.AttachmentPath
FROM 		FileAttachments,UnitFileAttachments
WHERE  	FileAttachments.AttachmentNum = UnitFileAttachments.AttachmentNum),
unitPics as
(SELECT     dbo.UnitPreviewPics.UnitId AS UnitId, dbo.PicturesUnitPics.PictureUnitId AS PictureUnitId
FROM         dbo.UnitPreviewPics INNER JOIN
                      dbo.PicturesUnitPics ON dbo.UnitPreviewPics.PictureId = dbo.PicturesUnitPics.PictureId AND 
                      dbo.UnitPreviewPics.UnitId <> dbo.PicturesUnitPics.PictureUnitId),
 v as
(SELECT   	u.UnitId,u.EditorRemarks, u.ForPreview, u.IsValueUnit,u.OldUnitId,
					u.RightsCode, dbo.RightsTypes.RightsDesc,--ul.LexiconId,
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
FROM         		dbo.Units u
LEFT JOIN	dbo.UnitData heb ON u.UnitId = heb.UnitId and heb.LanguageCode=1
LEFT JOIN	dbo.UnitData eng ON u.UnitId = eng.UnitId and eng.LanguageCode=0
LEFT JOIN dbo.RightsTypes ON u.RightsCode = dbo.RightsTypes.RightsCode
LEFT JOIN dbo.UnitDisplayStatus ON u.UnitDisplayStatus = dbo.UnitDisplayStatus.DisplayStatus
LEFT JOIN dbo.UnitStatuses ON u.UnitStatus = dbo.UnitStatuses.UnitStatus
LEFT JOIN dbo.UnitTypes ON u.UnitType = dbo.UnitTypes.UnitType
WHERE     u.UnitType = 2)
select  v.*,mp.MusicPieceId,mp.IncludesText,
		mp.PieceTypeCode, EngType.PieceTypeDesc,HebType.PieceTypeDesc,
		ReceiveDate,StanzaNumber,IsAudioFiles,
		RecordingDate, RecordingDuration,
		EngData.Incipit, HebData.Incipit,
		EngData.IncipitTranslation, HebData.IncipitTranslation,
		EngData.OriginalTitle, HebData.OriginalTitle,
		EngData.ReceiveDetails, HebData.ReceiveDetails,
		EngData.SongName, HebData.SongName,
		EngData.SongNameTranslation, HebData.SongNameTranslation,
		EngData.StanzaDesc, HebData.StanzaDesc,
		mpt.TuneCode, EngTun.TuneName, HebTun.TuneName,
		Engrd.RecordingDetails, Hebrd.RecordingDetails,
		Engrd.RecordingPlace, Hebrd.RecordingPlace,
		-- Archives
		STUFF(( SELECT ',' + cast(ma.ArchiveId as nvarchar(max)) FROM MusicArchives ma where v.UnitId=ma.MusicPieceId order by ma.ArchiveId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') ArchiveIds,
		STUFF(( SELECT ',' + cast(ma.Archive as nvarchar(max)) FROM MusicArchives ma where v.UnitId=ma.MusicPieceId order by ma.ArchiveId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') Archive,
		STUFF(( SELECT ',' + cast(ma.FromCatalogNumber as nvarchar(max)) FROM MusicArchives ma where v.UnitId=ma.MusicPieceId order by ma.ArchiveId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') FromCatalogNumber,
		STUFF(( SELECT ',' + cast(ma.FromTrackIndex as nvarchar(max)) FROM MusicArchives ma where v.UnitId=ma.MusicPieceId order by ma.ArchiveId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') FromTrackIndex,
		STUFF(( SELECT ',' + cast(ma.ToTrackIndex as nvarchar(max)) FROM MusicArchives ma where v.UnitId=ma.MusicPieceId order by ma.ArchiveId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') ToTrackIndex,
		STUFF(( SELECT ',' + cast(ma.FromTrackNumber as nvarchar(max)) FROM MusicArchives ma where v.UnitId=ma.MusicPieceId order by ma.ArchiveId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') FromTrackNumber,
		STUFF(( SELECT ',' + cast(ma.ToTrackNumber as nvarchar(max)) FROM MusicArchives ma where v.UnitId=ma.MusicPieceId order by ma.ArchiveId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') ToTrackNumber,
		STUFF(( SELECT ',' + cast(ma.IsForDisplay as nvarchar(max)) FROM MusicArchives ma where v.UnitId=ma.MusicPieceId order by ma.ArchiveId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') IsForDisplay,
		STUFF(( SELECT ',' + cast(ma.MediaTypeCode as nvarchar(max)) FROM MusicArchives ma where v.UnitId=ma.MusicPieceId order by ma.ArchiveId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') MediaTypeCode,
		STUFF(( SELECT ',' + cast(mtd.MediaTypeName as nvarchar(max)) FROM MusicArchives ma, MusicMediaTypesData mtd where v.UnitId=ma.MusicPieceId and mtd.MediaTypeCode=ma.MediaTypeCode and mtd.LanguageCode=0 order by ma.ArchiveId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') MediaTypeEnglishName,
		STUFF(( SELECT ',' + cast(mtd.MediaTypeName as nvarchar(max)) FROM MusicArchives ma, MusicMediaTypesData mtd where v.UnitId=ma.MusicPieceId and mtd.MediaTypeCode=ma.MediaTypeCode and mtd.LanguageCode=1 order by ma.ArchiveId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') MediaTypeHebrewName,
		STUFF(( SELECT ',' + cast(ma.MusicPieceId as nvarchar(max)) FROM MusicArchives ma where v.UnitId=ma.MusicPieceId order by ma.ArchiveId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') MusicPieceId,
		STUFF(( SELECT ',' + cast(ma.NextBackUpDate as nvarchar(max)) FROM MusicArchives ma where v.UnitId=ma.MusicPieceId order by ma.ArchiveId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') NextBackUpDate,
		-- Linked Pieces
		STUFF(( SELECT ',' + cast(mpm.MusicToUnitId as nvarchar(max)) FROM MusicPieceToMusicPiece mpm where v.UnitId=mpm.MusicFromUnitID order by mpm.MusicToUnitId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') LinkedPiecesIds,
		STUFF(( SELECT ',' + cast(mpm.LinkType as nvarchar(max)) FROM MusicPieceToMusicPiece mpm where v.UnitId=mpm.MusicFromUnitID order by mpm.MusicToUnitId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') LinkedPiecesType,
		STUFF(( SELECT ',' + cast(mlt.LinkDesc as nvarchar(max)) FROM MusicPieceToMusicPiece mpm,MusicToMusicLinkType mlt where v.UnitId=mpm.MusicFromUnitID and mlt.LinkType=mpm.LinkType and mlt.LanguageCode=0 order by mpm.MusicToUnitId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') LinkedPiecesEnglishType,
		STUFF(( SELECT ',' + cast(mlt.LinkDesc as nvarchar(max)) FROM MusicPieceToMusicPiece mpm,MusicToMusicLinkType mlt where v.UnitId=mpm.MusicFromUnitID and mlt.LinkType=mpm.LinkType and mlt.LanguageCode=1 order by mpm.MusicToUnitId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') LinkedPiecesHebrewType,
		-- Linked Text
		STUFF(( SELECT ',' + cast(mpt.MusicTextId as nvarchar(max)) FROM [dbo].[MusicPieceTexts] mpt where v.UnitId=mpt.MusicPieceId order by mpt.MusicTextId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') LinkedTextIds,
		STUFF(( SELECT ',' + cast(mpt.IsMainText as nvarchar(max)) FROM [dbo].[MusicPieceTexts] mpt where v.UnitId=mpt.MusicPieceId order by mpt.MusicTextId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') IsLinkedTextMain,
		-- Linked UnitPlaces
		STUFF(( SELECT ',' + cast(up.PlaceId as nvarchar(max)) FROM dbo.UnitPlaces up where v.UnitId=up.UnitId order by up.PlaceId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') LinkedPlacesIds,
		STUFF(( SELECT ',' + cast(up.PlaceDescriptionTypeCode as nvarchar(max)) FROM dbo.UnitPlaces up where v.UnitId=up.UnitId order by up.PlaceId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') LinkedPlacesIds,
		STUFF(( SELECT ',' + cast(upd.PlaceDescriptionTypeDesc as nvarchar(max)) FROM dbo.UnitPlaces up join dbo.PlaceDescriptionTypesData upd on upd.PlaceDescriptionTypeCode=up.PlaceDescriptionTypeCode where up.UnitId=v.UnitId and upd.LanguageCode=1 order by up.PlaceId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') HePlaceTypeCodesDesc,
		STUFF(( SELECT ',' + cast(upd.PlaceDescriptionTypeDesc as nvarchar(max)) FROM dbo.UnitPlaces up join dbo.PlaceDescriptionTypesData upd on upd.PlaceDescriptionTypeCode=up.PlaceDescriptionTypeCode where up.UnitId=v.UnitId and upd.LanguageCode=0 order by up.PlaceId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') EnPlaceTypeCodesDesc,
		-- Linked Personality
		STUFF(( SELECT ',' + cast(pu.PersonalityId as varchar(max)) FROM dbo.UnitPersonalities pu where pu.UnitId=v.UnitId order by pu.PersonalityId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PersonalityIds,
		STUFF(( SELECT ',' + cast(pu.PersonTypeCode as varchar(max)) FROM dbo.UnitPersonalities pu where pu.UnitId=v.UnitId order by pu.PersonalityId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PersonalityTypes,
		STUFF(( SELECT ',' + cast(ptd.PersonTypeDesc as nvarchar(max)) FROM dbo.UnitPersonalities pu join dbo.PersonTypesData ptd on ptd.PersonTypeCode=pu.PersonTypeCode  where pu.UnitId=v.UnitId and ptd.LanguageCode=1 order by pu.PersonalityId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') HePersonalityTypeDesc,
		STUFF(( SELECT ',' + cast(ptd.PersonTypeDesc as nvarchar(max)) FROM dbo.UnitPersonalities pu join dbo.PersonTypesData ptd on ptd.PersonTypeCode=pu.PersonTypeCode  where pu.UnitId=v.UnitId and ptd.LanguageCode=0 order by pu.PersonalityId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') EnPersonalityTypeDesc,
		STUFF(( SELECT ',' + cast(pu.PerformerType as varchar(max)) FROM dbo.UnitPersonalities pu where pu.UnitId=v.UnitId order by pu.PersonalityId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PerformerTyps,
		STUFF(( SELECT ',' + cast(ptd.PerformerTypeDesc as nvarchar(max)) FROM dbo.UnitPersonalities pu join dbo.PerformersTypesData ptd on ptd.PerformerType=pu.PerformerType where pu.UnitId=v.UnitId  and ptd.LanguageCode=1 order by pu.PersonalityId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') HePerformerTypeDec,
		STUFF(( SELECT ',' + cast(ptd.PerformerTypeDesc as nvarchar(max)) FROM dbo.UnitPersonalities pu join dbo.PerformersTypesData ptd on ptd.PerformerType=pu.PerformerType where pu.UnitId=v.UnitId  and ptd.LanguageCode=0 order by pu.PersonalityId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') EnPerformerTypeDec,
		STUFF(( SELECT ',' + cast(pu.OrderBy as varchar(max)) FROM dbo.UnitPersonalities pu where pu.UnitId=v.UnitId order by pu.PersonalityId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') OrderBy,
		-- Linked Pics
		STUFF(( SELECT ',' + cast(pu.PictureUnitId as varchar(max)) FROM unitPics pu where pu.UnitId=v.UnitId order by pu.PictureUnitId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PicIds,
		--UnitPeriod
		STUFF(( SELECT ',' + cast(pu.PeriodNum as varchar(max)) FROM dbo.UnitPeriods pu where pu.UnitId=v.UnitId order by pu.PeriodNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PeriodNum,
		STUFF(( SELECT ',' + cast(pu.PeriodTypeCode as varchar(max)) FROM dbo.UnitPeriods pu where pu.UnitId=v.UnitId order by pu.PeriodNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PeriodTypeCode,
		STUFF(( SELECT ',' + cast(ptd.PeriodTypeDesc as nvarchar(max)) FROM dbo.UnitPeriods pu join dbo.PeriodTypesData ptd on ptd.PeriodTypeCode=pu.PeriodTypeCode where pu.UnitId=v.UnitId and ptd.LanguageCode=1 order by pu.PeriodNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') HePeriodTypeDesc,
		STUFF(( SELECT ',' + cast(ptd.PeriodTypeDesc as nvarchar(max)) FROM dbo.UnitPeriods pu join dbo.PeriodTypesData ptd on ptd.PeriodTypeCode=pu.PeriodTypeCode where pu.UnitId=v.UnitId and ptd.LanguageCode=0 order by pu.PeriodNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') EnPeriodTypeDesc,
		STUFF(( SELECT ',' + cast(pu.PeriodDateTypeCode as varchar(max)) FROM dbo.UnitPeriods pu where pu.UnitId=v.UnitId order by pu.PeriodNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PeriodDateTypeCode,
		STUFF(( SELECT ',' + cast(ptd.PeriodDateTypeDesc as nvarchar(max)) FROM dbo.UnitPeriods pu join dbo.PeriodDateTypesData ptd on ptd.PeriodDateTypeCode=pu.PeriodDateTypeCode where pu.UnitId=v.UnitId and ptd.LanguageCode=1 order by pu.PeriodNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') HePeriodDateTypeDesc,
		STUFF(( SELECT ',' + cast(ptd.PeriodDateTypeDesc as nvarchar(max)) FROM dbo.UnitPeriods pu join dbo.PeriodDateTypesData ptd on ptd.PeriodDateTypeCode=pu.PeriodDateTypeCode where pu.UnitId=v.UnitId and ptd.LanguageCode=0 order by pu.PeriodNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') EnPeriodDateTypeDesc,
		STUFF(( SELECT ',' + cast(pu.PeriodStartDate as varchar(max)) FROM dbo.UnitPeriods pu where pu.UnitId=v.UnitId order by pu.PeriodNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PeriodStartDate,
		STUFF(( SELECT ',' + cast(pu.PeriodEndDate as varchar(max)) FROM dbo.UnitPeriods pu where pu.UnitId=v.UnitId order by pu.PeriodNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PeriodEndDate,
		STUFF(( SELECT ',' + cast(pu.PeriodDesc as nvarchar(max)) FROM dbo.UnitPeriodsData pu where pu.UnitId=v.UnitId and pu.LanguageCode=1 order by pu.PeriodNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') HePeriodDesc,
		STUFF(( SELECT ',' + cast(pu.PeriodDesc as nvarchar(max)) FROM dbo.UnitPeriodsData pu where pu.UnitId=v.UnitId and pu.LanguageCode=0 order by pu.PeriodNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') EnPeriodDesc,
		-- Music Languages
		STUFF(( SELECT ',' + cast(ml.LanguageId as nvarchar(max)) FROM [dbo].[MusicPieceLanguages] ml where ml.MusicPieceId=v.UnitId order by ml.LanguageId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') LanguageIds,
		STUFF(( SELECT ',' + cast(ml.IsOrigLanguage as nvarchar(max)) FROM [dbo].[MusicPieceLanguages] ml where ml.MusicPieceId=v.UnitId order by ml.LanguageId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') IsOrigLanguage,
		STUFF(( SELECT ',' + cast(l.LanguageDesc as nvarchar(max)) FROM [dbo].[MusicPieceLanguages] ml join Languages l on l.LanguageCode=ml.LanguageId where ml.MusicPieceId=v.UnitId order by ml.LanguageId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') LanguageDesc,
		STUFF(( SELECT ',' + cast(l.LanguageHebDesc as nvarchar(max)) FROM [dbo].[MusicPieceLanguages] ml join Languages l on l.LanguageCode=ml.LanguageId where ml.MusicPieceId=v.UnitId order by ml.LanguageId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') LanguageHebDesc,
		--UnitPreviewPics
		STUFF(( SELECT ',' + cast(dbo.PicturesUnitPics.PictureUnitId as varchar(max)) FROM dbo.UnitPreviewPics upp JOIN dbo.PicturesUnitPics ON upp.PictureId = dbo.PicturesUnitPics.PictureId AND upp.UnitId <> dbo.PicturesUnitPics.PictureUnitId and upp.UnitId =v.UnitId order by upp.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PictureUnitsIds,
		STUFF(( SELECT ',' + cast(upp.IsPreview as varchar(1)) FROM dbo.UnitPreviewPics upp where upp.UnitId=v.UnitId order by upp.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') IsPreview,
		STUFF(( SELECT ',' + cast(upp.PictureId as varchar(max)) FROM dbo.UnitPreviewPics upp where upp.UnitId=v.UnitId order by upp.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PrevPictureIds,
		-- + Pictures Files Details
		STUFF(( SELECT ',' + isnull(cast(P.PicturePath as varchar(max)),'') FROM dbo.UnitPreviewPics upp left join Pictures P on P.PictureId=upp.PictureId where upp.UnitId=v.UnitId order by upp.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PrevPicturePaths,
		STUFF(( SELECT ',' + isnull(cast(P.PictureFileName as varchar(max)),'') FROM dbo.UnitPreviewPics upp left join Pictures P on P.PictureId=upp.PictureId where upp.UnitId=v.UnitId order by upp.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PrevPictureFileNames
from   v
left join [dbo].[MusicPieces] mp on mp.MusicPieceId=v.UnitId
left join [MusicPiecesData] EngData on EngData.MusicPieceId=v.UnitId and EngData.LanguageCode=0
left join [MusicPiecesData] HebData on HebData.MusicPieceId=v.UnitId and HebData.LanguageCode=1
left join MusicPieceTypeCodesData EngType on EngType.PieceTypeCode=v.UnitId and EngType.LanguageCode=0
left join MusicPieceTypeCodesData HebType on HebType.PieceTypeCode=v.UnitId and HebType.LanguageCode=1
left join MusicPieceTunes mpt on mpt.MusicPieceId=v.UnitId
left join [dbo].[MusicTunesData] EngTun on EngTun.TuneCode=mpt.TuneCode and EngTun.LanguageCode=0
left join [dbo].[MusicTunesData] HebTun on HebTun.TuneCode=mpt.TuneCode and HebTun.LanguageCode=1
left join [dbo].[MusicRecordingData] Engrd on  Engrd.MusicPieceId=v.UnitId and Engrd.LanguageCode=0 
left join [dbo].[MusicRecordingData] Hebrd on  Hebrd.MusicPieceId=v.UnitId and Hebrd.LanguageCode=1

---------------------------
-----  Music Text --------- Not Doen Yet!!!!
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
		STUFF(( SELECT ',' + cast(ppt.PersonTypeCode as varchar(max)) FROM dbo.PersonalitiesPersonTypes ppt where ppt.PersonalityId=v.UnitId order by PersonTypeId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PersonTypeCodes,
		STUFF(( SELECT ',' + cast(pt.PersonTypeDesc as varchar(max)) FROM dbo.PersonalitiesPersonTypes ppt, PersonTypesData pt where pt.PersonTypeCode=ppt.PersonTypeCode and ppt.PersonalityId=v.UnitId and pt.LanguageCode=0 for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') HePersonTypeCodesDesc,
		STUFF(( SELECT ',' + cast(pt.PersonTypeDesc as nvarchar(max)) FROM dbo.PersonalitiesPersonTypes ppt, PersonTypesData pt where pt.PersonTypeCode=ppt.PersonTypeCode and ppt.PersonalityId=v.UnitId and pt.LanguageCode=1 for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') EnPersonTypeCodesDesc,
		STUFF(( SELECT ',' + cast(ppt.PersonTypeId as varchar(max)) FROM dbo.PersonalitiesPersonTypes ppt where ppt.PersonalityId=v.UnitId order by PersonTypeId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PersonTypeIds,
		STUFF(( SELECT ',' + cast(ppt.IsMainCreatorType as varchar(max)) FROM dbo.PersonalitiesPersonTypes ppt where ppt.PersonalityId=v.UnitId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') IsMainCreatorType,
		--UnitSources
		STUFF(( SELECT ',' + cast(us.SourceId as varchar(max)) FROM dbo.UnitSources us where us.UnitId=v.UnitId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PictureSources,
        --UnitPreviewPics
		STUFF(( SELECT ',' + cast(dbo.PicturesUnitPics.PictureUnitId as varchar(max)) FROM dbo.UnitPreviewPics upp JOIN dbo.PicturesUnitPics ON upp.PictureId = dbo.PicturesUnitPics.PictureId AND upp.UnitId <> dbo.PicturesUnitPics.PictureUnitId and upp.UnitId =v.UnitId order by upp.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PictureUnitsIds,
		STUFF(( SELECT ',' + cast(upp.PictureId as varchar(max)) FROM dbo.UnitPreviewPics upp where upp.UnitId=v.UnitId order by upp.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PictureId,
		STUFF(( SELECT ',' + cast(upp.IsPreview as varchar(1)) FROM dbo.UnitPreviewPics upp where upp.UnitId=v.UnitId order by upp.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') IsPreview,
		-- + Pictures Files Details
		STUFF(( SELECT ',' + isnull(cast(P.PicturePath as varchar(max)),'') FROM dbo.UnitPreviewPics upp left join Pictures P on P.PictureId=upp.PictureId where upp.UnitId=v.UnitId order by upp.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PrevPicturePaths,
		STUFF(( SELECT ',' + isnull(cast(P.PictureFileName as varchar(max)),'') FROM dbo.UnitPreviewPics upp left join Pictures P on P.PictureId=upp.PictureId where upp.UnitId=v.UnitId order by upp.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PrevPictureFileNames,
		-- UnitPlaces
		STUFF(( SELECT ',' + cast(upp.PlaceId as varchar(max)) FROM dbo.UnitPlaces upp where upp.UnitId=v.UnitId order by upp.PlaceId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PlaceIds,
		STUFF(( SELECT ',' + cast(upp.PlaceDescriptionTypeCode as varchar(max)) FROM dbo.UnitPlaces upp where upp.UnitId=v.UnitId order by upp.PlaceId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PlaceTypeCodes,
		STUFF(( SELECT ',' + cast(upd.PlaceDescriptionTypeDesc as nvarchar(max)) FROM dbo.UnitPlaces up join dbo.PlaceDescriptionTypesData upd on upd.PlaceDescriptionTypeCode=up.PlaceDescriptionTypeCode where up.UnitId=v.UnitId and upd.LanguageCode=1 order by up.PlaceId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') HePlaceTypeCodesDesc,
		STUFF(( SELECT ',' + cast(upd.PlaceDescriptionTypeDesc as nvarchar(max)) FROM dbo.UnitPlaces up join dbo.PlaceDescriptionTypesData upd on upd.PlaceDescriptionTypeCode=up.PlaceDescriptionTypeCode where up.UnitId=v.UnitId and upd.LanguageCode=0 order by up.PlaceId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') EnPlaceTypeCodesDesc,
		--Family Name
		STUFF(( SELECT ',' + cast(uf.FamilyNameId as nvarchar(max)) FROM [dbo].[UnitFamilyNames] uf where uf.UnitId=v.UnitId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') FamilyNameIds,
		--Period
		STUFF(( SELECT ',' + cast(pu.PeriodNum as varchar(max)) FROM dbo.UnitPeriods pu where pu.UnitId=v.UnitId order by pu.PeriodNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PeriodNum,
		STUFF(( SELECT ',' + cast(pu.PeriodTypeCode as varchar(max)) FROM dbo.UnitPeriods pu where pu.UnitId=v.UnitId order by pu.PeriodNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PeriodTypeCode,
		STUFF(( SELECT ',' + cast(ptd.PeriodTypeDesc as nvarchar(max)) FROM dbo.UnitPeriods pu join dbo.PeriodTypesData ptd on ptd.PeriodTypeCode=pu.PeriodTypeCode where pu.UnitId=v.UnitId and ptd.LanguageCode=1 order by pu.PeriodNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') HePeriodTypeDesc,
		STUFF(( SELECT ',' + cast(ptd.PeriodTypeDesc as nvarchar(max)) FROM dbo.UnitPeriods pu join dbo.PeriodTypesData ptd on ptd.PeriodTypeCode=pu.PeriodTypeCode where pu.UnitId=v.UnitId and ptd.LanguageCode=0 order by pu.PeriodNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') EnPeriodTypeDesc,
		STUFF(( SELECT ',' + cast(pu.PeriodDateTypeCode as varchar(max)) FROM dbo.UnitPeriods pu where pu.UnitId=v.UnitId order by pu.PeriodNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PeriodDateTypeCode,
		STUFF(( SELECT ',' + cast(ptd.PeriodDateTypeDesc as nvarchar(max)) FROM dbo.UnitPeriods pu join dbo.PeriodDateTypesData ptd on ptd.PeriodDateTypeCode=pu.PeriodDateTypeCode where pu.UnitId=v.UnitId and ptd.LanguageCode=1 order by pu.PeriodNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') HePeriodDateTypeDesc,
		STUFF(( SELECT ',' + cast(ptd.PeriodDateTypeDesc as nvarchar(max)) FROM dbo.UnitPeriods pu join dbo.PeriodDateTypesData ptd on ptd.PeriodDateTypeCode=pu.PeriodDateTypeCode where pu.UnitId=v.UnitId and ptd.LanguageCode=0 order by pu.PeriodNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') EnPeriodDateTypeDesc,
		STUFF(( SELECT ',' + cast(pu.PeriodStartDate as varchar(max)) FROM dbo.UnitPeriods pu where pu.UnitId=v.UnitId order by pu.PeriodNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PeriodStartDate,
		STUFF(( SELECT ',' + cast(pu.PeriodEndDate as varchar(max)) FROM dbo.UnitPeriods pu where pu.UnitId=v.UnitId order by pu.PeriodNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PeriodEndDate,
		STUFF(( SELECT ',' + cast(pu.PeriodDesc as nvarchar(max)) FROM dbo.UnitPeriodsData pu where pu.UnitId=v.UnitId and pu.LanguageCode=1 order by pu.PeriodNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') HePeriodDesc,
		STUFF(( SELECT ',' + cast(pu.PeriodDesc as nvarchar(max)) FROM dbo.UnitPeriodsData pu where pu.UnitId=v.UnitId and pu.LanguageCode=0 order by pu.PeriodNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') EnPeriodDesc
		,per.PersonalityId, 
		HeData.FirstName HeFirstName, HeData.LastName HeLastName, HeData.MiddleName HeMiddleName, HeData.NickName HeNickName, HeData.OtherNames HeOtherNames,HeData.Title HeTitle, 
		EnData.FirstName AS Expr1, EnData.LastName AS Expr2, EnData.MiddleName, EnData.NickName, EnData.OtherNames,EnData.Title
FROM v        
JOIN dbo.Personalities AS per on v.UnitId=per.PersonalityId
LEFT JOIN dbo.PersonalitiesData AS HeData ON v.UnitId = HeData.PersonalityId AND HeData.LanguageCode = 0 
LEFT JOIN dbo.PersonalitiesData AS EnData ON v.UnitId = EnData.PersonalityId AND EnData.LanguageCode = 1