@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Declarations of use'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
@VDM.viewType: #BASIC
define view entity ZI_UseAccesses
  as select from permission
  association [1..1] to ZI_PackageInterfaces as _Interface on _Interface.InterfaceName = $projection.InterfaceName
{
  key client_pak as ClientPackage,
  key intf_name  as InterfaceName,
      err_sever  as ErrorSeverity,
      _Interface
}
