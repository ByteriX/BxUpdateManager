# Copyright

BxUpdateManager is a manager for checking update from network and local
ByteriX, 2017. All right reserved.

# Versions

## 1.0.3 (27.04.2020)
##### Bug fixing
* edited PodSpec with supporting Swift versions section

## 1.0.2 (11.06.2019)
##### Improvements
* new build script with pushing podspec

## 1.0.1 (11.06.2019)
##### Improvements
* swift_versions changed

## 1.0.0 (03.04.2019)
##### Improvements
* renamed active to isActivated
* edited access to private methods: didUpdateData(), toUpdateData(), resetUpdateDataTime(), toUpdateInterface(),  resetUpdateInterfaceTime(), updateInterfaceExecute(), didUpdateInterface()
* moved BxUpdateManagerTimePeriod to BxUpdateManager.WaitingStrategy and rename timePeriod to waitingStrategy
* changed a description and example
* added lastActivationDate property
* renamed lastLocalUpdateData to lastUpdateDataDate, lastLocalUpdateInterface to lastUpdateInterfaceDate


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
