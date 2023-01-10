  /*
	Project Purpose : Cleaning Data using SQL
  */
  SELECT *
  FROM portfolio_projects.nashvillehousingdata; 
  
  
  -- Populate Property Address Data
  SELECT * 
  FROM portfolio_projects.nashvillehousingdata
  ORDER BY ParcelID;
  
  SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,IFNULL(b.PropertyAddress, a.PropertyAddress)
  FROM portfolio_projects.nashvillehousingdata a
  JOIN portfolio_projects.nashvillehousingdata b
  ON a.ParcelID = b.ParcelID
  AND a.UniqueID <> b.UniqueID
  WHERE a.PropertyAddress = '';
  
  UPDATE portfolio_projects.nashvillehousingdata a
  JOIN portfolio_projects.nashvillehousingdata b
  ON a.ParcelID = b.ParcelID
  AND a.UniqueID <> b.UniqueID
  SET a.PropertyAddress = IFNULL(b.PropertyAddress,a.PropertyAddress)
  WHERE a.PropertyAddress = '';
  
  SELECT PropertyAddress
  FROM portfolio_projects.nashvillehousingdata;
  
  
  -- Splitting Address into Individual Columns(i.e City, State, Address)
  SELECT 
  SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1) AS Address,
  SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1, CHAR_LENGTH(PropertyAddress)) AS City
  FROM portfolio_projects.nashvillehousingdata; 
  
  ALTER TABLE nashvillehousingdata
  ADD PropertySplitAddress NVARCHAR(255);
  
  UPDATE nashvillehousingdata
  SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',',PropertyAddress) -1);
  
  ALTER TABLE nashvillehousingdata
  ADD PropertySplitCity NVARCHAR(255);
  
  UPDATE nashvillehousingdata
  SET PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1, CHAR_LENGTH(PropertyAddress));
  
  SELECT *
  FROM portfolio_projects.nashvillehousingdata;
  
  SELECT OwnerAddress
  FROM portfolio_projects.nashvillehousingdata;
  
  
-- Splitting Owner Address into Individual Columns(i.e City, State, Address)
 SELECT 
  SUBSTRING_INDEX(OwnerAddress,',', 1) AS OwnerAddress,
  SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress,',', 2),',',-1) AS OwnerCity,
   SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress,',', -2),',',-1) AS OwnerState
  FROM portfolio_projects.nashvillehousingdata; 
  
  
ALTER TABLE nashvillehousingdata
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE nashvillehousingdata
SET OwnerSplitAddress =  SUBSTRING_INDEX(OwnerAddress,',', 1);

ALTER TABLE nashvillehousingdata
ADD OwnerSplitCity NVARCHAR(255);

UPDATE nashvillehousingdata
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress,',', 2),',',-1);

ALTER TABLE nashvillehousingdata
ADD OwnerSplitState NVARCHAR(255);

UPDATE nashvillehousingdata
SET OwnerSplitState =  SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress,',', -2),',',-1);

SELECT *
FROM portfolio_projects.nashvillehousingdata;


-- Change Y and N to Yes and No in "Sold as Vacant" field
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM portfolio_projects.nashvillehousingdata
GROUP BY SoldAsVacant
ORDER BY 2;


SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM  portfolio_projects.nashvillehousingdata;


UPDATE nashvillehousingdata
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END;
       
       
-- Remove Duplicates
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM portfolio_projects.nashvillehousingdata
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

FROM portfolio_projects.nashvillehousingdata
)
DELETE 
FROM RowNumCTE
WHERE row_num > 1;

SELECT *
FROM portfolio_projects.nashvillehousingdata;



-- Delete Unused Columns
SELECT *
FROM portfolio_projects.nashvillehousingdata;


ALTER TABLE portfolio_projects.nashvillehousingdata
DROP COLUMN OwnerAddress, 
DROP TaxDistrict, 
DROP PropertyAddress, 
DROP SaleDate;

SELECT *
FROM portfolio_projects.nashvillehousingdata;







    
