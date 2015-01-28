select
	distinct	gt.GenTreeNumber AS GTN,
		gti.GenTreeId AS GTID
from GenTree gt,GenTreeIndividuals gti
where gt.GenTreeId = gti.GenTreeId;