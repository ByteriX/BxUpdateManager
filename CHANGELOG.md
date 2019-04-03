# Copyright

BxUpdateManager is a manager for checking update from network and local
ByteriX, 2017. All right reserved.

# Versions

## 1.0.0 (03.04.2019)
##### Improvements
* renamed active to isActivated
* edited access to private methods: didUpdateData(), toUpdateData(), resetUpdateDataTime(), toUpdateInterface(),  resetUpdateInterfaceTime(), updateInterfaceExecute(), didUpdateInterface()
* changed a description and example

## 0.9.7 (03.11.2018)
##### Improvements
* changed description
* Swift 3.2/4.0/4.2 supporting

## 0.9.6 (08.12.2017)
##### Improvements
* changed description
* Swift 3.2/4.0 supporting

## 0.9.5 (28.09.2017)
##### Bug fixing
* fixed updateData() when timePeriod == .fromStopLoading

## 0.9.4 (25.09.2017)
##### Improvements
* added timePeriod property. That fix cyclic update

## 0.9.3 (15.08.2017)
##### Improvements
* made public getter methods

## 0.9.2 (26.06.2017)
##### Improvements
* added toUpdateData(), resetUpdateDataTime(), toUpdateInterface(), resetUpdateInterfaceTime()

## 0.9.1 (26.06.2017)
##### Bug fixing
* fixed issue with uncallig load data

## 0.9 (26.06.2017)
##### Improvements
* started project



# Installation

pod 'BxUpdateManager'
