-----------------------
-----  Movies ---------
-----------------------
with unitFileAttac as
(SELECT 	UnitFileAttachments.unitid, FileAttachments.AttachmentFileName, FileAttachments.AttachmentNum, FileAttachments.AttachmentPath
 FROM 		FileAttachments,UnitFileAttachments
 WHERE  	FileAttachments.AttachmentNum = UnitFileAttachments.AttachmentNum),
 v as
(SELECT   	u.UnitId,u.EditorRemarks, 
			u.ForPreview, 
			u.IsValueUnit,
			u.OldUnitId,
			u.RightsCode,
			dbo.RightsTypes.RightsDesc,
			u.TS,u.UnitDisplayStatus, 
			dbo.UnitDisplayStatus.DisplayStatusDesc,
			u.UnitStatus, 
			dbo.UnitStatuses.StatusDesc,
			u.UnitType, 
			dbo.UnitTypes.UnitTypeDesc,
			u.UpdateDate, u.UpdateUser,
			heb.Bibiliography HeBibiliography, 
			eng.Bibiliography EnBibiliography,
			heb.id,heb.LocationInMuseum,
			eng.UnitHeader EnHeader,
			heb.UnitHeader HeHeader ,
			heb.UnitHeaderDMSoundex HeUnitHeaderDMSoundex, 
			eng.UnitHeaderDMSoundex EnUnitHeaderDMSoundex,
			heb.UnitText1 HeUnitText1,
			heb.UnitText2 HeUnitText2,
			eng.UnitText1 EnUnitText1,
			eng.UnitText2 EnUnitText2,
			STUFF(( SELECT cast(ul.LexiconId as varchar(max)) + ',' FROM dbo.UnitsLexicon ul where ul.UnitId=u.UnitId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') UserLexicon,
			STUFF(( SELECT cast(ufl.AttachmentFileName as nvarchar(max)) + ',' FROM unitFileAttac ufl where ufl.UnitId=u.UnitId order by ufl.AttachmentNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') AttachmentFileName,
			STUFF(( SELECT cast(ufl.AttachmentPath as nvarchar(max)) + ',' FROM unitFileAttac ufl where ufl.UnitId=u.UnitId order by ufl.AttachmentNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') AttachmentPath,
			STUFF(( SELECT cast(ufl.AttachmentNum as nvarchar(max)) + ',' FROM unitFileAttac ufl where ufl.UnitId=u.UnitId order by ufl.AttachmentNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') AttachmentNum
FROM        dbo.Units u
LEFT JOIN	dbo.UnitData heb ON u.UnitId = heb.UnitId and heb.LanguageCode=1
LEFT JOIN	dbo.UnitData eng ON u.UnitId = eng.UnitId and eng.LanguageCode=0
LEFT JOIN 	dbo.RightsTypes  ON u.RightsCode = dbo.RightsTypes.RightsCode
LEFT JOIN 	dbo.UnitDisplayStatus ON u.UnitDisplayStatus = dbo.UnitDisplayStatus.DisplayStatus
LEFT JOIN 	dbo.UnitStatuses ON u.UnitStatus = dbo.UnitStatuses.UnitStatus
LEFT JOIN 	dbo.UnitTypes ON u.UnitType = dbo.UnitTypes.UnitType
WHERE     	u.UnitType = 9)
select  /*dbo.Movie.MovieId,*/ 
		m.Minutes							 as Minutes, 
		m.ProductionYear					 as ProductionYear,
		m.MovieFileId						 as MovieFileId, 
		m.ReceiveDate						 as ReceiveDate,
		m.ReceiveType						 as ReceiveType,
		MovieRecieveEng.MovieReceiveTypeDesc as MovieReceiveTypeDescEnglish,
		MovieRecieveHeb.MovieReceiveTypeDesc as MovieReceiveTypeDescHebrew,
		m.ColorType							 as ColorType,
		colorEng.ColorDesc					 as EnColorDesc,
		colorHeb.ColorDesc					 as HeColorDesc,	
		movieDataEng.DistributionCompany     as EnDistributionCompany,
		movieDataHeb.DistributionCompany     as HeDistributionCompany,
		movieDataEng.ProductionCompany       as EnProductionCompany,
		movieDataHeb.ProductionCompany		 as HeProductionCompany,
		dbo.MovieFiles.MovieFileName		 as MovieFileName, 
		dbo.MovieFiles.MoviePath			 as MoviePath,
		v.*,
		STUFF(( SELECT 		cast(up.PlaceId as nvarchar(max)) + ','
				FROM 		dbo.UnitPlaces up 
				where 		up.UnitId=m.MovieId
				order by 	up.PlaceId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') RelatedPlaces,
		STUFF(( SELECT 		cast(eu.ExhibitionId as nvarchar(max)) + ','
				FROM 		dbo.ExhibitionLinkedUnits eu 
				where 		eu.LinkedUnitId=m.MovieId
				order by 	eu.ExhibitionId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') RelatedExhibitions,
		STUFF(( SELECT 		cast(us.SourceId as nvarchar(max)) + ','
				FROM 		dbo.UnitSources us 
				where 		us.UnitId=m.MovieId
				order by 	us.SourceId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') RelatedSources,
		STUFF(( SELECT 		cast(up.PersonalityId as nvarchar(max)) + ','
				FROM 		dbo.UnitPersonalities up 
				where 		up.UnitId=m.MovieId 
				order by 	up.PersonalityId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') RelatedPersonalitys,
		STUFF(( SELECT 		cast(pup.PictureUnitId as nvarchar(max)) + ','
				FROM 		dbo.UnitPreviewPics up 
				INNER JOIN 	dbo.PicturesUnitPics pup ON up.PictureId = pup.PictureId AND up.UnitId <> pup.PictureUnitId 
				where up.UnitId=m.MovieId 
				order by pup.PictureUnitId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') RelatedPics,
		STUFF(( SELECT cast(mf.CatalogCode as nvarchar(max)) + ',' FROM dbo.MovieFormat mf where mf.MovieId=m.MovieId order by mf.FormatId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') CatalogCodes,
		STUFF(( SELECT cast(mf.FormatCode as nvarchar(max)) + ',' FROM dbo.MovieFormat mf where mf.MovieId=m.MovieId order by mf.FormatId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') FormatCode,
		STUFF(( SELECT cast(mf.FormatId as nvarchar(max)) + ',' FROM dbo.MovieFormat mf where mf.MovieId=m.MovieId order by mf.FormatId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') FormatId,
		STUFF(( SELECT cast(mf.IsPrimaryVersion as nvarchar(max)) + ',' FROM dbo.MovieFormat mf where mf.MovieId=m.MovieId order by mf.FormatId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') IsPrimaryVersion,
		STUFF(( SELECT cast(mfs.FormatDesc as nvarchar(max)) + ',' FROM dbo.MovieFormats mfs, dbo.MovieFormat mf where mf.MovieId=m.MovieId and mfs.FormatCode=mf.FormatId order by mf.FormatId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') FormatDesc,
		STUFF(( SELECT cast(mv.LanguageId as nvarchar(max)) + ',' FROM dbo.MovieVersions mv where mv.MovieId=m.MovieId order by mv.VersionId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') LanguageId,
		STUFF(( SELECT cast(l.LanguageDesc as nvarchar(max)) + ',' FROM dbo.MovieVersions mv, dbo.Languages l where mv.MovieId=m.MovieId and l.LanguageCode=mv.LanguageId order by mv.VersionId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') VersionLanguageDesc,
		STUFF(( SELECT cast(l.LanguageHebDesc as nvarchar(max)) + ',' FROM dbo.MovieVersions mv, dbo.Languages l where mv.MovieId=m.MovieId and l.LanguageCode=mv.LanguageId order by mv.VersionId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') VersionLanguageHebDesc,
		STUFF(( SELECT cast(mv.VersionId as nvarchar(max)) + ',' FROM dbo.MovieVersions mv where mv.MovieId=m.MovieId order by mv.VersionId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') VersionId,
		STUFF(( SELECT cast(mv.VersionTypeCode as nvarchar(max)) + ',' FROM dbo.MovieVersions mv where mv.MovieId=m.MovieId order by mv.VersionId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') VersionTypeCode,
		STUFF(( SELECT cast(mvt.MovieVersionTypeDesc as nvarchar(max)) + ',' FROM dbo.MovieVersions mv, dbo.MovieVersionTypes mvt where mv.MovieId=m.MovieId and mvt.MovieVersionTypeCode=mv.VersionTypeCode and mvt.LanguageCode=0 order  by mv.VersionId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') MovieVersionTypeDescEnglish,
		STUFF(( SELECT cast(mvt.MovieVersionTypeDesc as nvarchar(max)) + ',' FROM dbo.MovieVersions mv, dbo.MovieVersionTypes mvt where mv.MovieId=m.MovieId and mvt.MovieVersionTypeCode=mv.VersionTypeCode and mvt.LanguageCode=1 order  by mv.VersionId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') MovieVersionTypeDescHebrew,
		msEng.SectionHeader,msEng.SectionId, msHeb.SectionHeader,msHeb.SectionId,
		msd.SectionId,msd.SectionStartMinute, msd.SectionEndMinute,
		--UnitPreviewPics
		STUFF(( SELECT cast(dbo.PicturesUnitPics.PictureUnitId as varchar(max)) + ',' FROM dbo.UnitPreviewPics upp JOIN dbo.PicturesUnitPics ON upp.PictureId = dbo.PicturesUnitPics.PictureId AND upp.UnitId <> dbo.PicturesUnitPics.PictureUnitId and upp.UnitId =m.MovieId order by upp.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PictureUnitsIds,
		STUFF(( SELECT cast(upp.IsPreview as varchar(1)) + ',' FROM dbo.UnitPreviewPics upp where upp.UnitId=m.MovieId order by upp.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') IsPreview,
		STUFF(( SELECT cast(upp.PictureId as varchar(max)) + ',' FROM dbo.UnitPreviewPics upp where upp.UnitId=m.MovieId order by upp.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PrevPictureIds,
		-- + Pictures Files Details
		STUFF(( SELECT isnull(cast(P.PicturePath as varchar(max)),'') + ',' FROM dbo.UnitPreviewPics upp left join Pictures P on P.PictureId=upp.PictureId where upp.UnitId=m.MovieId order by upp.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PrevPicturePaths,
		STUFF(( SELECT isnull(cast(P.PictureFileName as varchar(max)),'') + ',' FROM dbo.UnitPreviewPics upp left join Pictures P on P.PictureId=upp.PictureId where upp.UnitId=m.MovieId order by upp.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PrevPictureFileNames
from dbo.Movie m
full join v on v.UnitId=m.MovieId
left join dbo.MovieReceiveTypesData MovieRecieveEng on MovieRecieveEng.MovieReceiveTypeCode=m.ReceiveType and MovieRecieveEng.LanguageCode=0
left join dbo.MovieReceiveTypesData MovieRecieveHeb on MovieRecieveHeb.MovieReceiveTypeCode=m.ReceiveType and MovieRecieveHeb.LanguageCode=1
left join dbo.MovieColorTypes colorEng on colorEng.ColorId=m.ColorType and colorEng.LanguageCode=0
left join dbo.MovieColorTypes colorHeb on colorHeb.ColorId=m.ColorType and colorHeb.LanguageCode=1
left join dbo.MovieData movieDataEng on movieDataEng.MovieId=m.MovieId and movieDataEng.LanguageCode=0
left join dbo.MovieData movieDataHeb on movieDataHeb.MovieId=m.MovieId and movieDataHeb.LanguageCode=1
left join dbo.MovieFiles on dbo.MovieFiles.MovieFileId=m.MovieFileId
left join dbo.MovieSections msEng on msEng.MovieId=m.MovieId and msEng.LanguageCode=0
left join dbo.MovieSections msHeb on msHeb.MovieId=m.MovieId and msHeb.LanguageCode=1
left join dbo.MovieSectionsData msd on msd.MovieId=m.MovieId;