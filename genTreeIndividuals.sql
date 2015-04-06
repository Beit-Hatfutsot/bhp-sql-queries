	select	gt.GenTreeNumber AS GTN,
			gti.GenTreeId AS GTID,
			gti.IndividualId AS II, 
			gti.BirthDate As BD, 
			gti.BirthPlace AS BP, 
			gti.BirthPlaceDMSoundex AS BPS, 
			gti.DeathDate AS DD,
			gti.DeathPlace AS DP,
			gti.DeathPlaceDMSoundex AS DPS, 
			gti.Gender AS G, 
			gti.Id AS ID, 
			gti.IndividualBirthLastName AS IBLN,
			gti.IndividualBirthLastNameDMSoundex AS IBLNS, 
			gti.IndividualFirstName AS FN,
			gti.IndividualLastName AS LN, 
			gti.IndividualLastNameDMSoundex AS LNS,
			gti.MarrigeDates AS MD, 
			gti.MarrigePlace AS MP, 
			gti.MarrigePlaceDMsoundex AS MPS,
			gt.GenTreeFileId AS GTF, 
			gt.GenTreePath as GenTreePath, 
			gt.GenTreeXmlPath as GTXML, 
			gt.GenTreeFileName AS GTFN,
			/*Birth Date*/
			Birth.PeriodStartDate AS BSD,
			Birth.PeriodEndDate AS BED,
			/*Death Date*/
			Death.PeriodStartDate AS DSD,
			Death.PeriodEndDate AS DED,
			/*Marriage Date*/
			STUFF(( SELECT  cast(Marriage.PeriodStartDate as varchar(100)) + ',' FROM dbo.GenTreePeriod Marriage where gti.GenTreeId=Marriage.GenTreeId and gti.IndividualId=Marriage.IndividualId and Marriage.PeriodTypeCode= 7 order by Marriage.PeriodStartDate for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') AS MSD,
			STUFF(( SELECT  cast(Marriage.PeriodEndDate as varchar(100)) + ',' FROM dbo.GenTreePeriod Marriage where gti.GenTreeId=Marriage.GenTreeId and gti.IndividualId=Marriage.IndividualId and Marriage.PeriodTypeCode= 7 order by Marriage.PeriodStartDate for XML PATH(''),Type).value('.','NVARCHAR(MAX)'),1,0,'') AS MED
from 		[dbo].[GenTreeIndividuals] gti with (nolock)
full join 	[dbo].[GenTree] gt with (nolock) on gt.GenTreeId=gti.GenTreeId
left join   (select 	GenTreeId,
						IndividualId,
						PeriodTypeCode,
						PeriodStartDate, 
						PeriodEndDate, 
						row_number() over (partition by GenTreeId,IndividualId order by PeriodStartDate desc) as indrank 	 
			from 		[dbo].[GenTreePeriod] with (nolock)) Birth
on 	gti.GenTreeId=Birth.GenTreeId and gti.IndividualId=Birth.IndividualId and Birth.PeriodTypeCode= 1 and Birth.indrank=1
left join  (select GenTreeId,IndividualId,PeriodTypeCode,PeriodStartDate, PeriodEndDate, row_number() over (partition by GenTreeId,IndividualId order by PeriodStartDate desc) as indrank from [dbo].[GenTreePeriod] with (nolock)) Death
on gti.GenTreeId=Death.GenTreeId and gti.IndividualId=Death.IndividualId and Death.PeriodTypeCode= 2 and Death.indrank=1