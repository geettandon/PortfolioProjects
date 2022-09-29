/*
	Cleaning Data in SQL Queries
*/

SELECT *
FROM PortfolioProject..NashvilleHousing

-- Standardise Date Format

SELECT SaleDateConverted
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
ADD SaleDateConverted DATE

UPDATE PortfolioProject..NashvilleHousing
SET SaleDateConverted = CAST(SaleDate AS DATE)

-- Populate Property Address Data

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM PortfolioProject..NashvilleHousing AS a
JOIN PortfolioProject..NashvilleHousing AS b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(b.PropertyAddress, a.PropertyAddress)
FROM PortfolioProject..NashvilleHousing AS a
JOIN PortfolioProject..NashvilleHousing AS b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- Breaking out Address into individual columns - Address, City, State

SELECT PropertyAddress, LEFT(PropertyAddress, CHARINDEX(',', PropertyAddress) - 1) AS Address, 
	RIGHT(PropertyAddress, LEN(PropertyAddress) - CHARINDEX(',', PropertyAddress)) AS City
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertyStreetAddress NVARCHAR(255)

UPDATE PortfolioProject..NashvilleHousing
SET PropertyStreetAddress = LEFT(PropertyAddress, CHARINDEX(',', PropertyAddress) - 1)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD PropertyCity NVARCHAR(255)

UPDATE PortfolioProject..NashvilleHousing
SET PropertyCity = RIGHT(PropertyAddress, LEN(PropertyAddress) - CHARINDEX(',', PropertyAddress))

SELECT OwnerAddress,
		PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
		PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
		PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerStreetAddress NVARCHAR(255)

UPDATE PortfolioProject..NashvilleHousing
SET OwnerStreetAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerCity NVARCHAR(255)

UPDATE PortfolioProject..NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE PortfolioProject..NashvilleHousing
ADD OwnerState NVARCHAR(255)

UPDATE PortfolioProject..NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-- Change Y and N as Yes and No in "SoldAsVacant" field

UPDATE PortfolioProject..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
					END

-- Remove Duplcates

WITH Rank_CTE AS (
		SELECT *,	
				ROW_NUMBER() OVER(PARTITION BY ParcelID,
								PropertyAddress,
								SaleDate,
								SalePrice,
								LegalReference
							ORDER BY UniqueID
							) AS Rank
		FROM PortfolioProject..NashvilleHousing
					)

DELETE
FROM Rank_CTE
WHERE Rank > 1

-- Delete Unused Columns

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN SaleDate, PropertyAddress, OwnerAddress, TaxDistrict