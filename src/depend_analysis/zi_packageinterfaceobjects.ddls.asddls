@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Objects of a package interface'
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #BASIC
define view entity ZI_PackageInterfaceObjects
  as select from ifobjshort
{
  key intf_name           as InterfaceName,
  key elem_type           as ElementType,
  key elem_key            as ElementKey,
      paknocheck          as NoPackageCheck,
      useastype           as UseAsType,
      asforgnkey          as UseAsForeignKey,
      deprecation_type    as DeprecationType,
      repl_object_type    as ReplacementObjectType,
      repl_object_name    as RepacementlObjectName,
      repl_subobject_type as ReplacementSubobjectType,
      repl_subobject_name as ReplacementSubobjectName
}
