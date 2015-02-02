--------------------------
-----  Places ------------
--------------------------
with unitFileAttac as
(SELECT UnitFileAttachments.unitid, FileAttachments.AttachmentFileName, FileAttachments.AttachmentNum, FileAttachments.AttachmentPath
FROM 		FileAttachments,UnitFileAttachments
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
						--unitFileAttac.AttachmentFileName, unitFileAttac.AttachmentNum, unitFileAttac.AttachmentPath,
					STUFF(( SELECT cast(ul.LexiconId as varchar(max)) + ',' FROM dbo.UnitsLexicon ul where ul.UnitId=u.UnitId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') UserLexicon,
					STUFF(( SELECT cast(ufl.AttachmentFileName as nvarchar(max)) + ',' FROM unitFileAttac ufl where ufl.UnitId=u.UnitId order by ufl.AttachmentNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') AttachmentFileName,
					STUFF(( SELECT cast(ufl.AttachmentPath as nvarchar(max)) + ',' FROM unitFileAttac ufl where ufl.UnitId=u.UnitId order by ufl.AttachmentNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') AttachmentPath,
					STUFF(( SELECT cast(ufl.AttachmentNum as nvarchar(max)) + ',' FROM unitFileAttac ufl where ufl.UnitId=u.UnitId order by ufl.AttachmentNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') AttachmentNum
--dbo.PlaceTypesData.PlaceTypeDesc,dbo.Places.PlaceTypeCode,
FROM         		dbo.Units u
LEFT JOIN	dbo.UnitData heb ON u.UnitId = heb.UnitId and heb.LanguageCode=1
LEFT JOIN	dbo.UnitData eng ON u.UnitId = eng.UnitId and eng.LanguageCode=0
--LEFT JOIN dbo.UnitsLexicon ul ON ul.UnitId=u.UnitId
LEFT JOIN dbo.RightsTypes ON u.RightsCode = dbo.RightsTypes.RightsCode
LEFT JOIN dbo.UnitDisplayStatus ON u.UnitDisplayStatus = dbo.UnitDisplayStatus.DisplayStatus
LEFT JOIN dbo.UnitStatuses ON u.UnitStatus = dbo.UnitStatuses.UnitStatus
LEFT JOIN dbo.UnitTypes ON u.UnitType = dbo.UnitTypes.UnitType
WHERE     u.UnitType = 5)
--ORDER BY u.UnitId)
SELECT	plcdheb.PlaceTypeDesc HePlaceTypeDesc,
		plcdeng.PlaceTypeDesc EnPlaceTypeDesc,
			plc.PlaceTypeCode,plc.PlaceParentId,
			plcd_parentheb.PlaceTypeDesc PlaceParentTypeCodeDesc,
			plcd_parentheb.PlaceTypeDesc HePlaceParentTypeCodeDesc,
			plcd_parenteng.PlaceTypeDesc EnPlaceParentTypeCodeDesc,
		STUFF(( SELECT cast(upp.IsPreview as varchar(1)) + ',' FROM dbo.UnitPreviewPics upp where upp.UnitId=v.UnitId order by upp.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') IsPreview,
		STUFF(( SELECT cast(upp.PictureId as varchar(max)) + ',' FROM dbo.UnitPreviewPics upp where upp.UnitId=v.UnitId order by upp.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PictureId
,v.*
--(select','+ Emt_EmployeeID from T_EmployeeMaster a where a.Emt_EmployeeID = b.Emt_EmployeeID For XML PATH('')),1,1,'')
FROM  dbo.Places plc
JOIN  v on plc.PlaceId = v.UnitId
LEFT JOIN dbo.PlaceTypesData plcdheb ON plc.PlaceTypeCode = plcdheb.PlaceTypeCode
																	AND 1=plcdheb.LanguageCode
LEFT JOIN dbo.PlaceTypesData plcdeng ON plc.PlaceTypeCode = plcdeng.PlaceTypeCode
																	AND 0=plcdeng.LanguageCode
LEFT JOIN dbo.Places plc_parent ON  plc_parent.PlaceId=plc.PlaceParentId
LEFT JOIN dbo.PlaceTypesData plcd_parentheb ON plc_parent.PlaceTypeCode = plcd_parentheb.PlaceTypeCode
																	AND 1=plcd_parentheb.LanguageCode
LEFT JOIN dbo.PlaceTypesData plcd_parenteng ON plc_parent.PlaceTypeCode = plcd_parenteng.PlaceTypeCode
																	AND 0=plcd_parenteng.LanguageCode
ORDER BY v.UnitId;