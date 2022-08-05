--Cleaning Data in SQL Queries

Select *
From CiscenjePodataka.dbo.NashvilleHousing

------------------------------------------------------------------------------------------------------

--Standardize Data Format
Select saleDateConverted, CONVERT(Date,SaleDate)
From CiscenjePodataka.dbo.NashvilleHousing


Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

-- If it doesn't Update properly

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

-------------------------------------------------------------------------------------------------------
--Populate Property Address date

Select *
From CiscenjePodataka.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From CiscenjePodataka.dbo.NashvilleHousing a
JOIN CiscenjePodataka.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]        -- jer ovi nisu u istom redu 
Where a.PropertyAddress is null
--Sada ovim desno adresama mora popuniti lijeve adrese


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From CiscenjePodataka.dbo.NashvilleHousing a
JOIN CiscenjePodataka.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null

---------------------------------------------------------------------------------------------------------
--Breking out Address into Individual Columns(Address, City, State)
Select PropertyAddress
From CiscenjePodataka.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address  --bez -1 zahvati i zarez
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1 ,LEN(PropertyAddress))as Address
From CiscenjePodataka.dbo.NashvilleHousing 


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1 ,LEN(PropertyAddress))

Select *
From CiscenjePodataka.dbo.NashvilleHousing


Select OwnerAddress
From CiscenjePodataka.dbo.NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress,',','.'), 3) 
, PARSENAME(REPLACE(OwnerAddress,',','.'), 2)
, PARSENAME(REPLACE(OwnerAddress,',','.'),1)
From CiscenjePodataka.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


Select *
From CiscenjePodataka.dbo.NashvilleHousing
------------------------------------------------------------------------------------------------------
--Change Y and N  to Yes and No in "SoldAsVacant"

Select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
From CiscenjePodataka.dbo.NashvilleHousing   --prikazuje sve razlicite vrijednosti u datoj koloni, i broj vrijednosti
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y'THEN 'Yes'
       When SoldAsVacant = 'N'THEN 'No'
	   ELSE SoldAsVacant
	   END
From CiscenjePodataka.dbo.NashvilleHousing 

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y'THEN 'Yes'
       When SoldAsVacant = 'N'THEN 'No'
	   ELSE SoldAsVacant
	   END

-------------------------------------------------------------------------------------------------------------
--Remove Duplicates

WITH RowNumCTE AS (
Select *,
    ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
	             PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 ORDER BY 
				   UniqueID
				 ) row_num
From CiscenjePodataka.dbo.NashvilleHousing   
)
DELETE
From RowNumCTE
Where row_num > 1
--order by PropertyAddress   
--Sve su to duplikati koje brisemo
--Ako bismo opet usmjesto DELETE stavili SELECT * vidjeli bismo da vise nema duplikata

Select*
From CiscenjePodataka.dbo.NashvilleHousing 
-----------------------------------------------------------------------------------------------
--Delete Unused Columns

Select*
From CiscenjePodataka.dbo.NashvilleHousing

ALTER TABLE CiscenjePodataka.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict

ALTER TABLE CiscenjePodataka.dbo.NashvilleHousing
DROP COLUMN SaleDate