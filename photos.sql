SELECT cast(PictureId as varchar(max)) as PictureId, PicturePath, PictureFileName 
FROM Pictures with (nolock)
WHERE PictureId=PictureId AND (%s=0 OR PictureId IN (%s))
