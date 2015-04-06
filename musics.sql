---------------------
-----  Musics -------
---------------------
with unitFileAttac as
(SELECT UnitFileAttachments.unitid, FileAttachments.AttachmentFileName, FileAttachments.AttachmentNum, FileAttachments.AttachmentPath
FROM 		FileAttachments with (nolock),
			UnitFileAttachments with (nolock)
WHERE  	FileAttachments.AttachmentNum = UnitFileAttachments.AttachmentNum),
unitPics as
(SELECT     dbo.UnitPreviewPics.UnitId AS UnitId, dbo.PicturesUnitPics.PictureUnitId AS PictureUnitId
FROM         dbo.UnitPreviewPics with (nolock) INNER JOIN
                      dbo.PicturesUnitPics with (nolock) ON dbo.UnitPreviewPics.PictureId = dbo.PicturesUnitPics.PictureId AND 
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
					STUFF(( SELECT cast(ul.LexiconId as varchar(max)) FROM dbo.UnitsLexicon ul with (nolock) where ul.UnitId=u.UnitId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') UserLexicon,
					STUFF(( SELECT cast(ufl.AttachmentFileName as nvarchar(max)) FROM unitFileAttac ufl with (nolock) where ufl.UnitId=u.UnitId order by ufl.AttachmentNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') AttachmentFileName,
					STUFF(( SELECT cast(ufl.AttachmentPath as nvarchar(max)) FROM unitFileAttac ufl with (nolock) where ufl.UnitId=u.UnitId order by ufl.AttachmentNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') AttachmentPath,
					STUFF(( SELECT cast(ufl.AttachmentNum as nvarchar(max)) FROM unitFileAttac ufl with (nolock) where ufl.UnitId=u.UnitId order by ufl.AttachmentNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') AttachmentNum
FROM         		dbo.Units u with (nolock)
LEFT JOIN	dbo.UnitData heb with (nolock) ON u.UnitId = heb.UnitId and heb.LanguageCode=1
LEFT JOIN	dbo.UnitData eng with (nolock) ON u.UnitId = eng.UnitId and eng.LanguageCode=0
LEFT JOIN dbo.RightsTypes with (nolock) ON u.RightsCode = dbo.RightsTypes.RightsCode
LEFT JOIN dbo.UnitDisplayStatus with (nolock) ON u.UnitDisplayStatus = dbo.UnitDisplayStatus.DisplayStatus
LEFT JOIN dbo.UnitStatuses with (nolock) ON u.UnitStatus = dbo.UnitStatuses.UnitStatus
LEFT JOIN dbo.UnitTypes with (nolock) ON u.UnitType = dbo.UnitTypes.UnitType
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
		STUFF(( SELECT cast(ma.ArchiveId as nvarchar(max)) + ',' FROM MusicArchives ma with (nolock) where v.UnitId=ma.MusicPieceId order by ma.ArchiveId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') ArchiveIds,
		STUFF(( SELECT cast(ma.Archive as nvarchar(max)) + ',' FROM MusicArchives ma with (nolock) where v.UnitId=ma.MusicPieceId order by ma.ArchiveId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') Archive,
		STUFF(( SELECT cast(ma.FromCatalogNumber as nvarchar(max)) + ',' FROM MusicArchives ma with (nolock) where v.UnitId=ma.MusicPieceId order by ma.ArchiveId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') FromCatalogNumber,
		STUFF(( SELECT cast(ma.FromTrackIndex as nvarchar(max)) + ',' FROM MusicArchives ma with (nolock) where v.UnitId=ma.MusicPieceId order by ma.ArchiveId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') FromTrackIndex,
		STUFF(( SELECT cast(ma.ToTrackIndex as nvarchar(max)) + ',' FROM MusicArchives ma with (nolock) where v.UnitId=ma.MusicPieceId order by ma.ArchiveId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') ToTrackIndex,
		STUFF(( SELECT cast(ma.FromTrackNumber as nvarchar(max)) + ',' FROM MusicArchives ma with (nolock) where v.UnitId=ma.MusicPieceId order by ma.ArchiveId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') FromTrackNumber,
		STUFF(( SELECT cast(ma.ToTrackNumber as nvarchar(max)) + ',' FROM MusicArchives ma with (nolock) where v.UnitId=ma.MusicPieceId order by ma.ArchiveId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') ToTrackNumber,
		STUFF(( SELECT cast(ma.IsForDisplay as nvarchar(max)) + ',' FROM MusicArchives ma with (nolock) where v.UnitId=ma.MusicPieceId order by ma.ArchiveId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') IsForDisplay,
		STUFF(( SELECT cast(ma.MediaTypeCode as nvarchar(max)) + ',' FROM MusicArchives ma with (nolock) where v.UnitId=ma.MusicPieceId order by ma.ArchiveId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') MediaTypeCode,
		STUFF(( SELECT cast(mtd.MediaTypeName as nvarchar(max)) + ',' FROM MusicArchives ma with (nolock), MusicMediaTypesData mtd with (nolock) where v.UnitId=ma.MusicPieceId and mtd.MediaTypeCode=ma.MediaTypeCode and mtd.LanguageCode=0 order by ma.ArchiveId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') MediaTypeEnglishName,
		STUFF(( SELECT cast(mtd.MediaTypeName as nvarchar(max)) + ',' FROM MusicArchives ma with (nolock), MusicMediaTypesData mtd with (nolock) where v.UnitId=ma.MusicPieceId and mtd.MediaTypeCode=ma.MediaTypeCode and mtd.LanguageCode=1 order by ma.ArchiveId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') MediaTypeHebrewName,
		STUFF(( SELECT cast(ma.MusicPieceId as nvarchar(max)) + ',' FROM MusicArchives ma with (nolock) where v.UnitId=ma.MusicPieceId order by ma.ArchiveId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') MusicPieceId,
		STUFF(( SELECT cast(ma.NextBackUpDate as nvarchar(max)) + ',' FROM MusicArchives ma with (nolock) where v.UnitId=ma.MusicPieceId order by ma.ArchiveId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') NextBackUpDate,
		-- Linked Pieces
		STUFF(( SELECT cast(mpm.MusicToUnitId as nvarchar(max)) + ',' FROM MusicPieceToMusicPiece mpm with (nolock) where v.UnitId=mpm.MusicFromUnitID order by mpm.MusicToUnitId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') LinkedPiecesIds,
		STUFF(( SELECT cast(mpm.LinkType as nvarchar(max)) + ',' FROM MusicPieceToMusicPiece mpm with (nolock) where v.UnitId=mpm.MusicFromUnitID order by mpm.MusicToUnitId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') LinkedPiecesType,
		STUFF(( SELECT cast(mlt.LinkDesc as nvarchar(max)) + ',' FROM MusicPieceToMusicPiece mpm with (nolock),MusicToMusicLinkType mlt with (nolock) where v.UnitId=mpm.MusicFromUnitID and mlt.LinkType=mpm.LinkType and mlt.LanguageCode=0 order by mpm.MusicToUnitId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') LinkedPiecesEnglishType,
		STUFF(( SELECT cast(mlt.LinkDesc as nvarchar(max)) + ',' FROM MusicPieceToMusicPiece mpm with (nolock),MusicToMusicLinkType mlt with (nolock) where v.UnitId=mpm.MusicFromUnitID and mlt.LinkType=mpm.LinkType and mlt.LanguageCode=1 order by mpm.MusicToUnitId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') LinkedPiecesHebrewType,
		-- Linked Text
		STUFF(( SELECT cast(mpt.MusicTextId as nvarchar(max)) + ',' FROM [dbo].[MusicPieceTexts] mpt with (nolock) where v.UnitId=mpt.MusicPieceId order by mpt.MusicTextId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') LinkedTextIds,
		STUFF(( SELECT cast(mpt.IsMainText as nvarchar(max)) + ',' FROM [dbo].[MusicPieceTexts] mpt with (nolock) where v.UnitId=mpt.MusicPieceId order by mpt.MusicTextId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') IsLinkedTextMain,
		-- Linked UnitPlaces
		STUFF(( SELECT cast(up.PlaceId as nvarchar(max)) + ',' FROM dbo.UnitPlaces up with (nolock) where v.UnitId=up.UnitId order by up.PlaceId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') LinkedPlacesIds,
		STUFF(( SELECT cast(up.PlaceDescriptionTypeCode as nvarchar(max)) + ',' FROM dbo.UnitPlaces up with (nolock) where v.UnitId=up.UnitId order by up.PlaceId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') LinkedPlacesIds,
		STUFF(( SELECT cast(upd.PlaceDescriptionTypeDesc as nvarchar(max)) + ',' FROM dbo.UnitPlaces up with (nolock) join dbo.PlaceDescriptionTypesData upd with (nolock) on upd.PlaceDescriptionTypeCode=up.PlaceDescriptionTypeCode where up.UnitId=v.UnitId and upd.LanguageCode=1 order by up.PlaceId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') HePlaceTypeCodesDesc,
		STUFF(( SELECT cast(upd.PlaceDescriptionTypeDesc as nvarchar(max)) + ',' FROM dbo.UnitPlaces up with (nolock) join dbo.PlaceDescriptionTypesData upd with (nolock) on upd.PlaceDescriptionTypeCode=up.PlaceDescriptionTypeCode where up.UnitId=v.UnitId and upd.LanguageCode=0 order by up.PlaceId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') EnPlaceTypeCodesDesc,
		-- Linked Personality
		STUFF(( SELECT cast(pu.PersonalityId as varchar(max)) + ',' FROM dbo.UnitPersonalities pu with (nolock) where pu.UnitId=v.UnitId order by pu.PersonalityId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PersonalityIds,
		STUFF(( SELECT cast(pu.PersonTypeCode as varchar(max)) + ',' FROM dbo.UnitPersonalities pu with (nolock) where pu.UnitId=v.UnitId order by pu.PersonalityId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PersonalityTypes,
		STUFF(( SELECT cast(ptd.PersonTypeDesc as nvarchar(max)) + ',' FROM dbo.UnitPersonalities pu with (nolock) join dbo.PersonTypesData ptd with (nolock) on ptd.PersonTypeCode=pu.PersonTypeCode  where pu.UnitId=v.UnitId and ptd.LanguageCode=1 order by pu.PersonalityId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') HePersonalityTypeDesc,
		STUFF(( SELECT cast(ptd.PersonTypeDesc as nvarchar(max)) + ',' FROM dbo.UnitPersonalities pu with (nolock) join dbo.PersonTypesData ptd with (nolock) on ptd.PersonTypeCode=pu.PersonTypeCode  where pu.UnitId=v.UnitId and ptd.LanguageCode=0 order by pu.PersonalityId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') EnPersonalityTypeDesc,
		STUFF(( SELECT cast(pu.PerformerType as varchar(max)) + ',' FROM dbo.UnitPersonalities pu with (nolock) where pu.UnitId=v.UnitId order by pu.PersonalityId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PerformerTyps,
		STUFF(( SELECT cast(ptd.PerformerTypeDesc as nvarchar(max)) + ',' FROM dbo.UnitPersonalities pu with (nolock) join dbo.PerformersTypesData ptd with (nolock) on ptd.PerformerType=pu.PerformerType where pu.UnitId=v.UnitId  and ptd.LanguageCode=1 order by pu.PersonalityId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') HePerformerTypeDec,
		STUFF(( SELECT cast(ptd.PerformerTypeDesc as nvarchar(max)) + ',' FROM dbo.UnitPersonalities pu with (nolock) join dbo.PerformersTypesData ptd with (nolock) on ptd.PerformerType=pu.PerformerType where pu.UnitId=v.UnitId  and ptd.LanguageCode=0 order by pu.PersonalityId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') EnPerformerTypeDec,
		STUFF(( SELECT cast(pu.OrderBy as varchar(max)) + ',' FROM dbo.UnitPersonalities pu with (nolock) where pu.UnitId=v.UnitId order by pu.PersonalityId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') OrderBy,
		-- Linked Pics
		STUFF(( SELECT cast(pu.PictureUnitId as varchar(max)) + ',' FROM unitPics pu with (nolock) where pu.UnitId=v.UnitId order by pu.PictureUnitId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PicIds,
		--UnitPeriod
		STUFF(( SELECT cast(pu.PeriodNum as varchar(max)) + ',' FROM dbo.UnitPeriods pu with (nolock) where pu.UnitId=v.UnitId order by pu.PeriodNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PeriodNum,
		STUFF(( SELECT cast(pu.PeriodTypeCode as varchar(max)) + ',' FROM dbo.UnitPeriods pu with (nolock) where pu.UnitId=v.UnitId order by pu.PeriodNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PeriodTypeCode,
		STUFF(( SELECT cast(ptd.PeriodTypeDesc as nvarchar(max)) + ',' FROM dbo.UnitPeriods pu with (nolock) join dbo.PeriodTypesData ptd with (nolock) on ptd.PeriodTypeCode=pu.PeriodTypeCode where pu.UnitId=v.UnitId and ptd.LanguageCode=1 order by pu.PeriodNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') HePeriodTypeDesc,
		STUFF(( SELECT cast(ptd.PeriodTypeDesc as nvarchar(max)) + ',' FROM dbo.UnitPeriods pu with (nolock) join dbo.PeriodTypesData ptd with (nolock) on ptd.PeriodTypeCode=pu.PeriodTypeCode where pu.UnitId=v.UnitId and ptd.LanguageCode=0 order by pu.PeriodNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') EnPeriodTypeDesc,
		STUFF(( SELECT cast(pu.PeriodDateTypeCode as varchar(max)) + ',' FROM dbo.UnitPeriods pu with (nolock) where pu.UnitId=v.UnitId order by pu.PeriodNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PeriodDateTypeCode,
		STUFF(( SELECT cast(ptd.PeriodDateTypeDesc as nvarchar(max)) + ',' FROM dbo.UnitPeriods pu with (nolock) join dbo.PeriodDateTypesData ptd with (nolock) on ptd.PeriodDateTypeCode=pu.PeriodDateTypeCode where pu.UnitId=v.UnitId and ptd.LanguageCode=1 order by pu.PeriodNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') HePeriodDateTypeDesc,
		STUFF(( SELECT cast(ptd.PeriodDateTypeDesc as nvarchar(max)) + ',' FROM dbo.UnitPeriods pu with (nolock) join dbo.PeriodDateTypesData ptd with (nolock) on ptd.PeriodDateTypeCode=pu.PeriodDateTypeCode where pu.UnitId=v.UnitId and ptd.LanguageCode=0 order by pu.PeriodNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') EnPeriodDateTypeDesc,
		STUFF(( SELECT cast(pu.PeriodStartDate as varchar(max)) + ',' FROM dbo.UnitPeriods pu with (nolock) where pu.UnitId=v.UnitId order by pu.PeriodNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PeriodStartDate,
		STUFF(( SELECT cast(pu.PeriodEndDate as varchar(max)) + ',' FROM dbo.UnitPeriods pu with (nolock) where pu.UnitId=v.UnitId order by pu.PeriodNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PeriodEndDate,
		STUFF(( SELECT cast(pu.PeriodDesc as nvarchar(max)) + ',' FROM dbo.UnitPeriodsData pu with (nolock) where pu.UnitId=v.UnitId and pu.LanguageCode=1 order by pu.PeriodNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') HePeriodDesc,
		STUFF(( SELECT cast(pu.PeriodDesc as nvarchar(max)) + ',' FROM dbo.UnitPeriodsData pu with (nolock) where pu.UnitId=v.UnitId and pu.LanguageCode=0 order by pu.PeriodNum for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') EnPeriodDesc,
		-- Music Languages
		STUFF(( SELECT cast(ml.LanguageId as nvarchar(max)) + ',' FROM [dbo].[MusicPieceLanguages] ml with (nolock) where ml.MusicPieceId=v.UnitId order by ml.LanguageId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') LanguageIds,
		STUFF(( SELECT cast(ml.IsOrigLanguage as nvarchar(max)) + ',' FROM [dbo].[MusicPieceLanguages] ml with (nolock) where ml.MusicPieceId=v.UnitId order by ml.LanguageId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') IsOrigLanguage,
		STUFF(( SELECT cast(l.LanguageDesc as nvarchar(max)) + ',' FROM [dbo].[MusicPieceLanguages] ml with (nolock) join Languages l with (nolock) on l.LanguageCode=ml.LanguageId where ml.MusicPieceId=v.UnitId order by ml.LanguageId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') LanguageDesc,
		STUFF(( SELECT cast(l.LanguageHebDesc as nvarchar(max)) + ',' FROM [dbo].[MusicPieceLanguages] ml with (nolock) join Languages l with (nolock) on l.LanguageCode=ml.LanguageId where ml.MusicPieceId=v.UnitId order by ml.LanguageId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') LanguageHebDesc,
		--UnitPreviewPics
		STUFF(( SELECT cast(dbo.PicturesUnitPics.PictureUnitId as varchar(max)) + ',' FROM dbo.UnitPreviewPics upp with (nolock) JOIN dbo.PicturesUnitPics with (nolock) ON upp.PictureId = dbo.PicturesUnitPics.PictureId AND upp.UnitId <> dbo.PicturesUnitPics.PictureUnitId and upp.UnitId =v.UnitId order by upp.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PictureUnitsIds,
		STUFF(( SELECT cast(upp.IsPreview as varchar(1)) + ',' FROM dbo.UnitPreviewPics upp with (nolock) where upp.UnitId=v.UnitId order by upp.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') IsPreview,
		STUFF(( SELECT cast(upp.PictureId as varchar(max)) + ',' FROM dbo.UnitPreviewPics upp with (nolock) where upp.UnitId=v.UnitId order by upp.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PrevPictureIds,
		-- + Pictures Files Details
		STUFF(( SELECT ',' + isnull(cast(P.PicturePath as varchar(max)),'') + ',' FROM dbo.UnitPreviewPics upp with (nolock) left join Pictures P with (nolock) on P.PictureId=upp.PictureId where upp.UnitId=v.UnitId order by upp.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PrevPicturePaths,
		STUFF(( SELECT ',' + isnull(cast(P.PictureFileName as varchar(max)),'') + ',' FROM dbo.UnitPreviewPics upp with (nolock) left join Pictures P with (nolock) on P.PictureId=upp.PictureId where upp.UnitId=v.UnitId order by upp.PictureId for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') PrevPictureFileNames
from   v
left join [dbo].[MusicPieces] mp with (nolock) on mp.MusicPieceId=v.UnitId
left join [MusicPiecesData] EngData with (nolock) on EngData.MusicPieceId=v.UnitId and EngData.LanguageCode=0
left join [MusicPiecesData] HebData with (nolock) on HebData.MusicPieceId=v.UnitId and HebData.LanguageCode=1
left join MusicPieceTypeCodesData EngType with (nolock) on EngType.PieceTypeCode=v.UnitId and EngType.LanguageCode=0
left join MusicPieceTypeCodesData HebType with (nolock) on HebType.PieceTypeCode=v.UnitId and HebType.LanguageCode=1
left join MusicPieceTunes mpt with (nolock) on mpt.MusicPieceId=v.UnitId
left join [dbo].[MusicTunesData] EngTun with (nolock) on EngTun.TuneCode=mpt.TuneCode and EngTun.LanguageCode=0
left join [dbo].[MusicTunesData] HebTun with (nolock) on HebTun.TuneCode=mpt.TuneCode and HebTun.LanguageCode=1
left join [dbo].[MusicRecordingData] Engrd with (nolock) on  Engrd.MusicPieceId=v.UnitId and Engrd.LanguageCode=0 
left join [dbo].[MusicRecordingData] Hebrd with (nolock) on  Hebrd.MusicPieceId=v.UnitId and Hebrd.LanguageCode=1