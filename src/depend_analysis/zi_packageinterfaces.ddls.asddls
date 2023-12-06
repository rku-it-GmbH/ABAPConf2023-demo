@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Package interfaces'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.representativeKey: 'InterfaceName'
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #META
}
@VDM.viewType: #BASIC
define view entity ZI_PackageInterfaces
  as select from intf
  association [1..1] to ZI_ABAPPackages          as _ABAPPackage on _ABAPPackage.ABAPPackage = $projection.ABAPPackage
  association [0..*] to ZI_UseAccesses           as _UseAccesses on _UseAccesses.InterfaceName = $projection.InterfaceName
  association [1..1] to ZI_PackageInterfaceTexts as _Text        on _Text.InterfaceName = $projection.InterfaceName
  with default filter _Text.Language = $session.system_language
{
      @ObjectModel.text.association: '_Text'
  key intf_name       as InterfaceName,
      pack_name       as ABAPPackage,
      @Semantics.user.responsible: true
      author          as Author,
      @Semantics.user.createdBy: true
      created_by      as CreatedBy,
      @Semantics.systemDate.createdAt: true
      created_on      as CreatedOn,
      @Semantics.user.lastChangedBy: true
      changed_by      as ChangedBy,
      @Semantics.systemDate.lastChangedAt: true
      changed_on      as ChangedOn,
      pinftype        as PackageInterfaceType,
      restricted      as Restricted,
      default_if      as DefaultIf,
      def_sever       as DefaultSeverity,
      acl_flag        as AclFlag,
      pifstablty      as PackageInterfaceStability,
      suppress_transl as SuppressTranslation,
      release_status  as ReleaseStatus,
      _ABAPPackage,
      _UseAccesses,
      _Text
}
