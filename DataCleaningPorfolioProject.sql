/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [CleaningDataProject].[dbo].[NashvilleHousing]




  -- Cleaning Data in SQL Queries



  select *
  from CleaningDataProject..NashvilleHousing

  --------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

  select saledateconverted, CONVERT(date,saledate)
  from CleaningDataProject..NashvilleHousing

  update NashvilleHousing
  set SaleDate = CONVERT(date,saledate)

  alter table nashvillehousing
  add saledateconverted date;

    update NashvilleHousing
  set saledateconverted = CONVERT(date,saledate)


 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

  select *
  from CleaningDataProject..NashvilleHousing
  --where PropertyAddress is null
  order by ParcelID

  select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
  from CleaningDataProject..NashvilleHousing a
  join CleaningDataProject..NashvilleHousing b
  on a.parcelid = b.parcelid
  and a.[UniqueID ] <> b.[UniqueID ]
  where a.PropertyAddress is null

  update a
  set PropertyAddress = isnull(a.PropertyAddress, b.PropertyAddress)
    from CleaningDataProject..NashvilleHousing a
  join CleaningDataProject..NashvilleHousing b
  on a.parcelid = b.parcelid
  and a.[UniqueID ] <> b.[UniqueID ]



--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

  select PropertyAddress
  from CleaningDataProject..NashvilleHousing
  --where PropertyAddress is null
  --order by ParcelID

select
substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, substring(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress)) as Address
from CleaningDataProject..NashvilleHousing


alter table nashvillehousing
add PropertySplitAddress nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

alter table nashvillehousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
set PropertySplitCity = substring(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress))

select *
from CleaningDataProject..NashvilleHousing


-- Separating Owner Address

select OwnerAddress
from CleaningDataProject..NashvilleHousing

select
PARSENAME(replace(owneraddress, ',','.'),3) as Address
,PARSENAME(replace(owneraddress, ',','.'),2) as City
,PARSENAME(replace(owneraddress, ',','.'),1) as State
from CleaningDataProject..NashvilleHousing


alter table nashvillehousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(owneraddress, ',','.'),3)

alter table nashvillehousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(owneraddress, ',','.'),2)

alter table nashvillehousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState = PARSENAME(replace(owneraddress, ',','.'),1)

select *
from CleaningDataProject..NashvilleHousing




--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct (SoldAsVacant), count(SoldAsVacant)
from CleaningDataProject..NashvilleHousing
group by SoldAsVacant
order by 2



select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end
from CleaningDataProject..NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
       when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end





-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

with rownumcte as (
select *,
ROW_NUMBER() over(
partition by parcelid,
			 propertyaddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 order by
			 UniqueID) row_num
from CleaningDataProject..NashvilleHousing
)
--order by ParcelID

select *
from rownumcte
where row_num > 1
order by PropertyAddress

-- Can also use delete function to remove duplicates
--delete
--from rownumcte
--where row_num > 1
--order by PropertyAddress





---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



select *
from CleaningDataProject..NashvilleHousing


ALTER TABLE CleaningDataProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


--Only used if permenantly deleting the raw data












-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------


