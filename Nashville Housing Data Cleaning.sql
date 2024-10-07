-- Data Cleaning

Select *
From portfolio_project.dbo.nashville_housing
Order by 2


-- Standardize Date Format

Select SaleDate, Convert(Date, SaleDate)
From portfolio_project.dbo.nashville_housing

Update nashville_housing
Set SaleDate = Convert(Date, SaleDate)


-- If it doesn't update properly

Alter Table nashville_housing
Add SaleDateConverted Date;

Update nashville_housing
Set SaleDateConverted = Convert(Date, SaleDate)


-- Populate Property Address Data

Select *
From portfolio_project.dbo.nashville_housing
--Where PropertyAddress is null
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, Isnull(a.PropertyAddress, b.PropertyAddress)
From portfolio_project.dbo.nashville_housing a
Join portfolio_project.dbo.nashville_housing b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

Update a
Set PropertyAddress = Isnull(a.PropertyAddress, b.PropertyAddress)
From portfolio_project.dbo.nashville_housing a
Join portfolio_project.dbo.nashville_housing b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From portfolio_project.dbo.nashville_housing
--Where PropertyAddress is null
--Order by ParcelID

Select 
Substring(PropertyAddress, 1, Charindex(',', PropertyAddress) -1) as Address,
Substring(PropertyAddress, Charindex(',', PropertyAddress) +1, Len(PropertyAddress)) as Address
From portfolio_project.dbo.nashville_housing
Order by ParcelID

Alter Table nashville_housing 
Add PropertySplitAddress nvarchar(255);

Update nashville_housing
Set PropertySplitAddress = Substring(PropertyAddress, 1, Charindex(',', PropertyAddress) -1)

Alter Table nashville_housing
Add PropertySplitCity nvarchar(255);

Update nashville_housing
Set PropertySplitCity = Substring(PropertyAddress, Charindex(',', PropertyAddress) +1, Len(PropertyAddress))

Select *
From portfolio_project.dbo.nashville_housing


Select OwnerAddress
From portfolio_project.dbo.nashville_housing
Order by ParcelID

Select 
ParseName(Replace(OwnerAddress, ',', '.'), 3),
ParseName(Replace(OwnerAddress, ',', '.'), 2),
ParseName(Replace(OwnerAddress, ',', '.'), 1)
From portfolio_project.dbo.nashville_housing
Order by ParcelID 

Alter Table nashville_housing
Add OwnerSplitAddress nvarchar(255);

Update nashville_housing
Set OwnerSplitAddress = ParseName(Replace(OwnerAddress, ',', '.'), 3)

Alter Table nashville_housing
Add OwnerSplitCity nvarchar(255);

Update nashville_housing
Set OwnerSplitCity = ParseName(Replace(OwnerAddress, ',', '.'), 2)

Alter Table nashville_housing
Add OwnerSplitState nvarchar(255);

Update nashville_housing
Set OwnerSplitState = ParseName(Replace(OwnerAddress, ',', '.'), 1)


-- Change Y and N to Yes and No in "Sold as Vacant" Field

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From portfolio_project.dbo.nashville_housing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
Case
	When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
End
From portfolio_project.dbo.nashville_housing

Update nashville_housing
Set SoldAsVacant = Case
	When SoldAsVacant = 'Y' Then 'Yes'
	When SoldAsVacant = 'N' Then 'No'
	Else SoldAsVacant
End


-- Remove Duplicates

With RowNumCTE 
as 
(
Select *, Row_Number() Over(Partition By ParcelID ,PropertyAddress, SalePrice, SaleDate, LegalReference 
Order By UniqueID) row_num
From portfolio_project.dbo.nashville_housing
--Order by ParcelID
)

--Delete
--From RowNumCTE
--Where row_num > 1

Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


-- Delete Unused Columns

Select *
From portfolio_project.dbo.nashville_housing
Order by ParcelID

Alter Table portfolio_project.dbo.nashville_housing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


