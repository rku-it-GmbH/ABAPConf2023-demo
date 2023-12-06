@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Package dependencies'
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #COMPOSITE
define view entity ZI_PackageDependencies
  as select from ZI_PackageInterfaces as Consumer
    inner join   ZI_UseAccesses       as Dependency on Dependency.ClientPackage = Consumer.ABAPPackage
    inner join   ZI_PackageInterfaces as Provider   on Dependency.InterfaceName = Provider.InterfaceName
  association [0..*] to ZI_PackageDependencies as _Parent on _Parent.ProviderPackage = $projection.ConsumerPackage
{
  key Provider.ABAPPackage   as ProviderPackage,
  key Provider.InterfaceName as ProviderInterface,
  key Consumer.ABAPPackage   as ConsumerPackage,
  key Consumer.InterfaceName as ConsumerInterface,
      /* Associations */
      _Parent
}
union select from ZI_PackageInterfaces as Provider
association [0..*] to ZI_PackageDependencies as _Parent on _Parent.ProviderPackage = $projection.ConsumerPackage
{
  key Provider.ABAPPackage   as ProviderPackage,
  key Provider.InterfaceName as ProviderInterface,
  key ''                     as ConsumerPackage,
  key ''                     as ConsumerInterface,
      /* Associations */
      _Parent
}
