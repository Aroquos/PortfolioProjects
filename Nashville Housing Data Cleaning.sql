--Cleaning Data in SQL Queries

Select* 
From Covid.dbo.Nashville


--Standardize Date Format

Select SaleDateConverted, CONVERT(Date, SaleDate)
From Covid.dbo.Nashville

Update Nashville
SET Saledate = CONVERT(Date, SaleDate)

ALTER TABLE Nashville
Add SaleDateConverted Date;

Update Nashville 
Set SaleDateConverted = CONVERT(Date, SaleDate)

--Populate Property Address

Select *
From Covid.dbo.Nashville
Where PropertyAddress is NULL 
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From Covid.dbo.Nashville a
Join Covid.dbo.Nashville b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From Covid.dbo.Nashville a
Join Covid.dbo.Nashville b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From Covid.dbo.Nashville
--Where PropertyAddress is null
--order by ParcelID

Select
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

From Covid.dbo.Nashville

ALTER TABLE Nashville
Add PropertySplitAddress Nvarchar(255);

Update Nashville
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE Nashville
Add PropertySplitCity Nvarchar(255);

Update Nashville
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


Select*
From Covid.dbo.Nashville

Select 
Parsename(REPLACE(OwnerAddress,',','.'),3)
,Parsename(REPLACE(OwnerAddress,',','.'),2)
,Parsename(REPLACE(OwnerAddress,',','.'),1)
From Covid.dbo.Nashville


ALTER TABLE Nashville
Add OwnerSplitAddress Nvarchar(255);

Update Nashville
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE Nashville
Add OwnerSplitCity Nvarchar(255);

Update Nashville
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)

ALTER TABLE Nashville
Add OwnerSplitState Nvarchar(255);

Update Nashville
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)

--Change Y to Yes and N to No in SOldAsVacant field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From Covid.dbo.Nashville
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From Covid.dbo.Nashville

Update Nashville
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END

--Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From Covid.dbo.Nashville
--order by ParcelID
)
DELETE
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress

--Delete Unused Columns

Select *
From Covid.dbo.Nashville

ALTER TABLE Covid.dbo.Nashville
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate