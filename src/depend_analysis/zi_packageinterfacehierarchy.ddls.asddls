@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Package interface hierarchy'
define hierarchy ZI_PackageInterfaceHierarchy
  with parameters
    p_root : scomifnam
  as parent child hierarchy(
    source ZI_PackageInterfacePropagation
    child to parent association _Parent
    start where
      ParentInterfaceName = $parameters.p_root
    siblings order by
      ChildInterfaceName
  )
{
  key ParentInterfaceName,
  key ChildInterfaceName,
      ParentPackageName,
      ChildPackageName,
      _ParentInterface,
      _ChildInterface,
      _ParentPackage,
      _ChildPackage

}
