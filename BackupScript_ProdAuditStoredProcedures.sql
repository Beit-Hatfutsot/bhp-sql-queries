USE [BHP_FINAL]
GO

/****** Object:  StoredProcedure [dbo].[pBHPInsertUnit]    Script Date: 4/29/2015 4:52:45 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[pBHPInsertUnit]
	@OldUnitId [varchar](50),
	@UnitType [tinyint],
	@RightsCode [int],
	@UnitStatus [Int],
	@UnitDisplayStatus[tinyint],
	@IsValueUnit [bit] = 1,
	@EditorRemarks nvarchar(300),
	@UpdateUser nvarchar(30),
	@UpdateDate datetime,
	@ForPreview [bit],
	@OutParam bigint = 0  output	
WITH EXECUTE AS CALLER
AS
begin try

exec iBHPCheckUpdateConstraint
		@UnitType = @UnitType,		
		@ForPreview = @ForPreview,
		@Constraint = 'INSERT'

--picture Receive unit
if @UnitType = 14
	set @OldUnitId  = dbo.fBHPGenerateArNumber()


insert Units(OldUnitId, UnitType, RightsCode, UnitStatus, UnitDisplayStatus, IsValueUnit, EditorRemarks, UpdateUser, UpdateDate, ForPreview)
values(@OldUnitId,@UnitType,@RightsCode,@UnitStatus, @UnitDisplayStatus, dbo.fBHPIsValueUnit(@UnitType,@IsValueUnit), @EditorRemarks, @UpdateUser, @UpdateDate, @ForPreview)
set @OutParam = @@identity

end try
begin catch
	exec iBHPErrorLogInsert
	exec iBHPErrorRethrow	
end catch

GO

USE [BHP_FINAL]
GO

/****** Object:  StoredProcedure [dbo].[pBHPUpdateUnit]    Script Date: 4/29/2015 4:53:35 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[pBHPUpdateUnit]
	@UnitId bigint,
	@OldUnitId [varchar](50),
	@UnitType [tinyint],
	@RightsCode [int],
	@UnitStatus [Int],
	@UnitDisplayStatus[tinyint],
	@IsValueUnit [bit],
	@EditorRemarks nvarchar(300),
	@UpdateUser nvarchar(30),
	@UpdateDate datetime,
	@ForPreview [bit],	
	@TimeStamp timestamp	
WITH EXECUTE AS CALLER
AS
begin try

exec iBHPCheckUpdateConstraint
		@UnitID = @UnitId ,
		@TS = @TimeStamp,
		@UnitType = @UnitType, /*Added as a fix by zafrir*/
		@UnitStatus = @UnitStatus,
		@ForPreview = @ForPreview,
		@Constraint = 'UPDATE'

update Units
set OldUnitId = @OldUnitId
	,UnitType = @UnitType
	,RightsCode = @RightsCode
	,UnitStatus = @UnitStatus
	,UnitDisplayStatus = @UnitDisplayStatus
	,IsValueUnit =  dbo.fBHPIsValueUnit(@UnitType,@IsValueUnit)
	,EditorRemarks = @EditorRemarks
	,UpdateUser = @UpdateUser
	,UpdateDate = @UpdateDate
	,ForPreview = @ForPreview
where (UnitId = @UnitId)


end try
begin catch
	exec iBHPErrorLogInsert
	exec iBHPErrorRethrow	
end catch

GO


USE [BHP_FINAL]
GO

/****** Object:  StoredProcedure [dbo].[pBHPDeleteUnit]    Script Date: 4/29/2015 4:54:14 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[pBHPDeleteUnit]
	@UnitId int,
	@TimeStamp timestamp
WITH EXECUTE AS CALLER
AS
begin try

declare @DeleteStatus int
set @DeleteStatus = 4

if not exists(select * from units
where UnitId = @UnitId
and unitStatus = @DeleteStatus
and TS = @TimeStamp)
	exec iBHPRaisError @ErrorNumber=10, @UnitId=@UnitId

-- Source
delete SourceEmailPhoneList where SourceId = @UnitId
delete SourcesData where SourceId = @UnitId
delete Sources where SourceId = @UnitId
--Places 
delete Places where PlaceId=@UnitId
-- Personality
delete PersonalitiesPersonTypes where PersonalityId = @UnitId
delete PersonalitiesData where PersonalityId = @UnitId
delete Personalities where PersonalityId = @UnitId
--Picture Receive
delete PictureReceiveUnitItems where PictureReceiveUnitId = @UnitId
delete PictureReceiveUnit where PictureReceiveUnitId = @UnitId
--Pictures
delete PicturesUnitPics where PictureUnitId = @UnitId
delete PictureUnits where PictureUnitId = @UnitId
--Music Text
delete MusicTextsData where MusicTextId = @UnitId
delete MusicTextLanguages where MusicTextId = @UnitId
delete MusicText where MusicTextId = @UnitId
--Music
delete MusicPiecesData where MusicPieceId = @UnitId
delete MusicRecordings where MusicRecordingId = @UnitId
delete MusicPieceLanguages where MusicPieceId = @UnitId
delete MusicPieces where MusicPieceId = @UnitId
--Movies
delete MovieSections where MovieId = @UnitId
delete MovieVersions where MovieId = @UnitId
delete MovieData where MovieId = @UnitId
delete Movie where MovieId = @UnitId
--Lexicon

--Period
delete UnitPeriodsData where UnitId = @UnitId
delete UnitPeriods where UnitId = @UnitId

--Global
delete UnitData where UnitId=@UnitId
delete Units where UnitId=@UnitId
and  UnitStatus = 4 and TS = @TimeStamp

end try
begin catch
	exec iBHPErrorLogInsert
	exec iBHPErrorRethrow	
end catch

GO


USE [BHP_FINAL]
GO

/****** Object:  StoredProcedure [dbo].[pBHPChangeUnitStatus]    Script Date: 4/29/2015 4:54:56 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[pBHPChangeUnitStatus]
	@UnitId bigint,
	@UnitStatus [Int],
	@UpdateUser nvarchar(30),
	@UpdateDate datetime,
	@TimeStamp timestamp 
WITH EXECUTE AS CALLER
AS
begin try  

exec iBHPCheckUpdateConstraint
		@UnitID = @UnitId ,
		@TS = @TimeStamp,
		@UnitStatus = @UnitStatus ,
		@Constraint = 'CHANGE_STATUS'

update Units
set  UnitStatus = @UnitStatus	
	 ,UpdateUser = @UpdateUser
	 ,UpdateDate = @UpdateDate	
where (UnitId = @UnitId and TS = @TimeStamp) 

select  @@DBTS;

end try
begin catch
	exec iBHPErrorLogInsert
	exec iBHPErrorRethrow	
end catch

GO

-- Synonyms
USE [BHP_FINAL]
GO

/****** Object:  StoredProcedure [dbo].[pBHPInsertSynonym]    Script Date: 4/29/2015 4:58:47 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[pBHPInsertSynonym]
(
	@Synonym nvarchar(100),
	@LanguageCode int,
	@Num int -- = Null output
)
AS
	SET NOCOUNT OFF;
begin try
if(charindex('$',@Synonym) <> 0)
	exec iBHPRaisError @ErrorNumber=16	

--if(@Num is null or @Num = -1)
--	set @Num = (select max(Num) from [Synonyms]) + 1

Insert Synonyms(Num,LanguageCode,[Synonym])
Values(@Num,@LanguageCode,@Synonym)
	
	
end try
begin catch
	exec iBHPErrorLogInsert;
	exec iBHPErrorRethrow;	
end catch

GO


USE [BHP_FINAL]
GO

/****** Object:  StoredProcedure [dbo].[pBHPUpdateSynonym]    Script Date: 4/29/2015 4:59:16 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[pBHPUpdateSynonym]
(
	@SynonymKey int,
	@Num int,
	@LanguageCode int,
	@Synonym nvarchar(100)
)
AS
	SET NOCOUNT OFF;
begin try
Update Synonyms Set [Synonym] = @Synonym, LanguageCode = @LanguageCode
where Num = @Num AND SynonymKey = @SynonymKey
end try
begin catch
	exec iBHPErrorLogInsert;
	exec iBHPErrorRethrow;	
end catch


--select US1.[Synonym] as SynonymKey,dbo.fbhpGeneralConcatenates(US2.[Synonym]) as SynonymValues 
--FROM Synonyms US1,Synonyms US2 
--WHERE 
--US1.[Synonym] IN (select Data from dbo.fbhpSplit('Cohen','$'))
--and
--US1.Num=US2.Num
--GROUP BY US1.[Synonym]

GO


USE [BHP_FINAL]
GO

/****** Object:  StoredProcedure [dbo].[pBHPDeleteSynonym]    Script Date: 4/29/2015 4:59:41 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[pBHPDeleteSynonym]
(
	@Num int,
	@Synonym nvarchar(100)
)
AS
	SET NOCOUNT OFF;
begin try
delete Synonyms
where Num = @Num and [Synonym] = @Synonym
end try
begin catch
	exec iBHPErrorLogInsert;
	exec iBHPErrorRethrow;	
end catch

GO


USE [BHP_FINAL]
GO

/****** Object:  StoredProcedure [dbo].[pBHPDeleteSynonymUnit]    Script Date: 4/29/2015 4:59:55 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[pBHPDeleteSynonymUnit]
(
	@Num int
)
AS
	SET NOCOUNT OFF;
begin try
delete Synonyms
where Num = @Num
end try
begin catch
	exec iBHPErrorLogInsert;
	exec iBHPErrorRethrow;	
end catch

GO


