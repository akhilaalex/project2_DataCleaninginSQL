
--DATA CLEANING

select * from project1..nashville_housing


--CREATING A NEW COLUMN SALESDATECONVERTED FOR SALE DATE(REMOVING THE TIMEFRAME)

-- adding a new column for sales date
alter table nashville_housing add SaleDateConverted Date;

--updating the table by adding date in new column
update nashville_housing set SaleDateConverted=convert(Date,SaleDate)

select SaleDateConverted from project1..nashville_housing


--POPULATING PROPERTY ADDRESS

select * from project1..nashville_housing
order by ParcelID

/*
there are some rows with null PropertyAddress ,
 we can see that ParcelID is unique for a PropertyAddress ,
  so we are going to replace null values with the 
  PropertyAddress corresponding to the ParcelID
*/

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,
ISNULL(a.PropertyAddress,b.PropertyAddress)
from project1..nashville_housing a
join project1..nashville_housing b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

-- now we are going to update the table

UPDATE a
set PropertyAddress=ISNULL(a.PropertyAddress,b.PropertyAddress)
from project1..nashville_housing a
join project1..c b
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null

--BREAKING PROPERTY ADDRESS INTO INDIVIDUAL COLUMNS(address , state)

select PropertyAddress from project1..nashville_housing

   --creating a new column to store address
Alter table nashville_housing
 add PropertySplitAddress nvarchar(255)

 UPDATE nashville_housing
 set PropertySplitAddress=SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)


 --creating a new column to store city
 
 Alter table nashville_housing
 add PropertySplitCity nvarchar(255)

 update nashville_housing
 set PropertySplitCity=SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1,
      len(PropertyAddress))

select PropertySplitAddress,PropertySplitCity from project1..nashville_housing


--BREAKING OWNER ADDRESS INTO INDIVIDUAL COLUMNS(address,city,state)

select OwnerAddress from nashville_housing

select PARSENAME(replace (OwnerAddress, ',', '.'),3),
PARSENAME(replace (OwnerAddress, ',', '.'),2),
PARSENAME(replace (OwnerAddress, ',', '.'),1)
from nashville_housing

-- creating new column to store owner address

Alter table nashville_housing add OwnerSplitAddress nvarchar(255);

Update nashville_housing 
set OwnerSplitAddress=PARSENAME(replace(OwnerAddress,',' ,'.'),3)

-- creating new column to store owner city

Alter table nashville_housing add OwnerSplitCity nvarchar(255);

Update nashville_housing 
set OwnerSplitCity=PARSENAME(replace(OwnerAddress,',' ,'.'),2)


-- creating new column to store owner state

Alter table nashville_housing add OwnerSplitState nvarchar(255);

Update nashville_housing 
set OwnerSplitState=PARSENAME(replace(OwnerAddress,',' ,'.'),1)


--CHANGING Y AND N TO YES AND NO IN SOLDASVACANT

-- grouping the data by SoldAsVacant
select distinct(SoldAsVacant) , count(SoldAsVacant) 
from project1.dbo.nashville_housing
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant='Y' then 'Yes'
     when SoldAsVacant='N' then 'No'
	 else SoldAsVacant
	 end
 from project1..nashville_housing


 --updating the table by setting Y=Yes and N=No
update nashville_housing 
set SoldAsVacant=case when SoldAsVacant='Y' then 'Yes'
     when SoldAsVacant='N' then 'No'
	 else SoldAsVacant
	 end
 from project1..nashville_housing



 --REMOVING DUPLICATES ROW


 -- creating CTE for duplicates row
 WITH Rownumcte AS( Select *,
	ROW_NUMBER() OVER ( PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
  from  project1.dbo.nashville_housing
                    )

-- displaying the duplicates

Select *
From Rownumcte
Where row_num > 1
Order by PropertyAddress

-- deleting the duplicates
Delete From Rownumcte Where row_num > 1

-- DELETING UNUSED COLUMNS



ALTER TABLE project1.dbo.nashville_housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

-- Displaying the final table
Select *
From project1.dbo.nashville_housing

