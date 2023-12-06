@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Propagation of package interfaces'
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #BASIC
define view entity ZI_PackageInterfacePropagation
  as select from   intf       as ParentInterface
    left outer join(
                   ifobjshort as Object
        inner join intf       as ChildInterface on  Object.elem_key  = ChildInterface.intf_name
                                                and Object.elem_type = 'PINF'
    )
    on Object.intf_name = ParentInterface.intf_name
  association [0..*] to ZI_PackageInterfacePropagation as _Parent          on _Parent.ChildInterfaceName = $projection.ParentInterfaceName
  association [1..1] to ZI_PackageInterfaces           as _ParentInterface on _ParentInterface.InterfaceName = $projection.ParentInterfaceName
  association [0..1] to ZI_PackageInterfaces           as _ChildInterface  on _ChildInterface.InterfaceName = $projection.ChildInterfaceName
  association [1..1] to ZI_ABAPPackages                as _ParentPackage   on _ParentPackage.ABAPPackage = $projection.ParentPackageName
  association [0..1] to ZI_ABAPPackages                as _ChildPackage    on _ChildPackage.ABAPPackage = $projection.ChildPackageName
{
  key ParentInterface.intf_name as ParentInterfaceName,
  key ChildInterface.intf_name  as ChildInterfaceName,
      ParentInterface.pack_name as ParentPackageName,
      ChildInterface.pack_name  as ChildPackageName,
      _Parent,
      _ParentInterface,
      _ChildInterface,
      _ParentPackage,
      _ChildPackage
}
