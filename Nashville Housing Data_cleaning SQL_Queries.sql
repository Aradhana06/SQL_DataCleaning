/*
Cleaning Data in SQL Queries
*/

-- Standardize date format
select SaleDateConverted, CONVERT(DATE,SaleDate)
from Project..[Nashville Housing]

ALTER TABLE [Nashville Housing]
ADD SaleDateConverted date


Update [Nashville Housing]
set SaleDateConverted = CONVERT(DATE,SaleDate)

-- Populated Property ADDRESS
-- some data have same parcel_id and same address a lot of time
SELECT PropertyAddress 
from Project..[Nashville Housing]
where PropertyAddress is null

SELECT * 
from Project..[Nashville Housing]
where PropertyAddress is null
order by ParcelID

--populate the id with address

SELECT A.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress , ISNULL(a.PropertyAddress,b.PropertyAddress)
from Project..[Nashville Housing] as a
join Project..[Nashville Housing] as b
  on a.ParcelID=b.ParcelID 
  and a.[UniqueID ]<>B.[UniqueID ]
  where a.PropertyAddress is null


update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from Project..[Nashville Housing] as a
join Project..[Nashville Housing] as b
  on a.ParcelID=b.ParcelID 
  and a.[UniqueID ]<>B.[UniqueID ]
  where a.PropertyAddress is null


  -- Breaking Out Address into Individual Column(Address, City, State)

SELECT PropertyAddress
from Project..[Nashville Housing]
--where PropertyAddress is null
--order by ParcelID

--using SUBSTRING AND CHARINDEX ( -1 to eliminate comma)
SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress)) as Address
from Project..[Nashville Housing]



ALTER TABLE [Nashville Housing]
ADD PropertySplitAddress nvarchar(255)

Update [Nashville Housing]
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)



ALTER TABLE [Nashville Housing]
ADD PropertySplitCity nvarchar(255)

Update [Nashville Housing]
set  PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress)+1, len(PropertyAddress)) 


select *  
from Project..[Nashville Housing]

--owner address

select OwnerAddress
from Project..[Nashville Housing]

select 
PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
from Project..[Nashville Housing]

ALTER TABLE [Nashville Housing]
ADD OwnerSplitAddress nvarchar(255)

Update [Nashville Housing]
set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE [Nashville Housing]
ADD OwnerSplitCity nvarchar(255)

Update [Nashville Housing]
set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE [Nashville Housing]
ADD OwnerSplitState nvarchar(255)

Update [Nashville Housing]
set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

select *  
from Project..[Nashville Housing]

--Change Y and N to Yes and No in 'Sold as Vacant' field

select DISTINCT (SoldAsVacant), count(SoldAsVacant)
from Project..[Nashville Housing]
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' THEN 'YES'
     when SoldAsVacant ='N' Then 'NO'
	 else SoldAsVacant
	 end
from Project..[Nashville Housing]

UPDATE [Nashville Housing]
set SoldAsVacant = case when SoldAsVacant = 'Y' THEN 'YES'
     when SoldAsVacant ='N' Then 'NO'
	 else SoldAsVacant
	 end
	 from Project..[Nashville Housing]


	 --Remove Duplicates
with remove_dup AS (
select * ,
     ROW_NUMBER() OVER (
     PARTITION BY ParcelID, PropertyAddress, SalePrice,SaleDate,LegalReference order by UniqueID ) as row_num
	 from Project..[Nashville Housing])

	 select * from remove_dup 
	 where row_num >1
	 order by ParcelID

	 delete from remove_dup
	 where row_num>1

	--delete unused columns

	select * from  Project..[Nashville Housing]

	alter table Project..[Nashville Housing]
	drop column OwnerAddress, TaxDistrict, PropertyAddress