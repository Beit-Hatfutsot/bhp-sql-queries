create table operationsLog (OperationDate datetime,
							UnitId bigint,
							OperationDescription varchar(100),
							IsSynonym bit,
							IsSynced bit);
							  

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

insert into operationsLog (OperationDate, UnitId, OperationDescription, IsSynonym, IsSynced)
values (@UpdateDate,@OutParam,'INSERT',0,0);

end try
begin catch
	exec iBHPErrorLogInsert
	exec iBHPErrorRethrow	
end catch
GO


ALTER PROCEDURE [dbo].[pBHPUpdateUnit]
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

insert into operationsLog (OperationDate, UnitId, OperationDescription, IsSynonym, IsSynced)
values (@UpdateDate,@UnitId,'UPDATE',0,0);


end try
begin catch
	exec iBHPErrorLogInsert
	exec iBHPErrorRethrow	
end catch
GO


ALTER PROCEDURE [dbo].[pBHPDeleteUnit]
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

insert into operationsLog (OperationDate, UnitId, OperationDescription, IsSynonym, IsSynced) 
values (@TimeStamp,@UnitId,'DELETE',0,0)

end try
begin catch
	exec iBHPErrorLogInsert
	exec iBHPErrorRethrow	
end catch
GO

ALTER PROCEDURE [dbo].[pBHPChangeUnitStatus]
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

insert into operationsLog (OperationDate, UnitId, OperationDescription, IsSynonym, IsSynced) 
values (@UpdateDate,@UnitId,'CHANGE_STATUS',0,0)

end try
begin catch
	exec iBHPErrorLogInsert
	exec iBHPErrorRethrow	
end catch
GO

SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO




