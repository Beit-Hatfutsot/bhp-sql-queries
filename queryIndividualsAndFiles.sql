select gti.BirthDate, gti.BirthPlace, gti.BirthPlaceDMSoundex, gti.DeathDate, gti.DeathPlace
		,gti.DeathPlaceDMSoundex, gti.Gender, gti.GenTreeId, gti.Id, 
		gti.IndividualBirthLastName,
		gti.IndividualBirthLastNameDMSoundex, gti.IndividualFirstName,
		gti.IndividualId, gti.IndividualLastName, gti.IndividualLastNameDMSoundex,
		gti.MarrigeDates, gti.MarrigePlace, gti.MarrigePlaceDMsoundex,
		gt.GenTreeFileId, gt.GenTreePath as GenTreePath, gt.GenTreeXmlPath, gt.GenTreeFileName
from GenTreeIndividuals gti
full join [dbo].[GenTree] gt
on gt.GenTreeId=gti.GenTreeId