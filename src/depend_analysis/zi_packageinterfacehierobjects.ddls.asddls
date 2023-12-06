@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Objects of a package interface hierarchy'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_PackageInterfaceHierObjects
with parameters
    p_root : scomifnam
 as select from ZI_PackageInterfaceHierarchy( p_root: $parameters.p_root ) as Hierarchy 
 inner join ZI_PackageInterfaceObjects as Object on Object.InterfaceName = Hierarchy.ChildInterfaceName
                                                and Object.ElementType  <> 'PINF'
{
    key $parameters.p_root as RootInterfaceName,
    key Hierarchy.ParentInterfaceName,
    key Hierarchy.ChildInterfaceName,
    key Object.InterfaceName,
    key Object.ElementType,
    key Object.ElementKey,
    Hierarchy.ParentPackageName,
    Hierarchy.ChildPackageName,
    Object.NoPackageCheck,
    Object.UseAsType,
    Object.UseAsForeignKey,
    Object.DeprecationType,
    Object.ReplacementObjectType,
    Object.RepacementlObjectName,
    Object.ReplacementSubobjectType,
    Object.ReplacementSubobjectName,
    /* Associations */
    Hierarchy._ChildInterface,
    Hierarchy._ChildPackage,
    Hierarchy._ParentInterface,
    Hierarchy._ParentPackage
}
