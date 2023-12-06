@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Packages'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.representativeKey: 'ABAPPackage'
@VDM.viewType: #BASIC
define view entity ZI_ABAPPackages
  as select from tdevc
  association [0..1] to ZI_ABAPPackages          as _ParentABAPPackage    on _ParentABAPPackage.ABAPPackage = $projection.ParentABAPPackage
  association [1..*] to ZI_TransportLayers       as _TransportLayer       on _TransportLayer.Translayer = $projection.TransportLayer
  association [0..1] to ZI_SoftwareComponents    as _SoftwareComponent    on _SoftwareComponent.SoftwareComponent = $projection.DeliveryUnit
  association [0..1] to ZI_ApplicationComponents as _ApplicationComponent on _ApplicationComponent.ApplicationComponent = $projection.ApplicationComponent
  association [0..*] to ZI_PackageInterfaces     as _PackageInterfaces    on _PackageInterfaces.ABAPPackage = $projection.ABAPPackage
  association [0..*] to ZI_UseAccesses           as _UseAccesses          on _UseAccesses.ClientPackage = $projection.ABAPPackage
  association [1..*] to ZI_ObjectCatalogEntries  as _Objects              on _Objects.ABAPPackage = $projection.ABAPPackage
  association [1..1] to ZI_ABAPPackageTexts      as _Text                 on _Text.ABAPPackage = $projection.ABAPPackage
  with default filter _Text.Language = $session.system_language
{
      @ObjectModel.text.association: '_Text'
  key devclass         as ABAPPackage,
      korrflag         as WriteTransportRequests,
      @Semantics.user.responsible: true
      as4user          as Author,
      pdevclass        as TransportLayer,
      dlvunit          as DeliveryUnit,
      component        as ApplicationComponent,
      namespace        as Namespace,
      tpclass          as CustomerDelivery,
      shipment         as Shipment,
      parentcl         as ParentABAPPackage,
      applicat         as ApplicationArea,
      packtype         as PackageType,
      restricted       as Restricted,
      mainpack         as MainPackage,
      @Semantics.user.createdBy: true
      created_by       as CreatedBy,
      @Semantics.systemDate.createdAt: true
      created_on       as CreatedOn,
      @Semantics.user.lastChangedBy: true
      changed_by       as ChangedBy,
      @Semantics.systemDate.lastChangedAt: true
      changed_on       as ChangedOn,
      srv_check        as SrvCheck,
      cli_check        as CliCheck,
      ext_alias        as ExtAlias,
      project_guid     as ProjectGuid,
      project_passdown as ProjectPassdown,
      is_enhanceable   as IsEnhanceable,
      package_kind     as PackageKind,
      enhanced_package as EnhancedPackage,
      access_object    as AccessObject,
      default_intf     as DefaultIntf,
      inherit_cli_intf as InheritCliIntf,
      tech_chg_tstmp   as TechChgTstmp,
      overall_tstmp    as OverallTstmp,
      encapsulation    as Encapsulation,
      dcl_enabled      as DclEnabled,
      sub_key          as SubKey,
      allow_static     as AllowStatic,
      switch_id        as SwitchId,
      check_rule       as CheckRule,
      _ParentABAPPackage,
      _TransportLayer,
      _SoftwareComponent,
      _ApplicationComponent,
      _PackageInterfaces,
      _UseAccesses,
      _Objects,
      _Text
}
