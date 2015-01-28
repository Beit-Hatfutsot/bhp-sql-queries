-----------------------
-----  Movies ---------
-----------------------
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
		msd.SectionId,msd.SectionStartMinute, msd.SectionEndMinute
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
left join dbo.MovieSectionsData msd on msd.MovieId=dbo.Movie.MovieId