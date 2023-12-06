@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Object catalogue entries'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #META
}
@VDM.viewType: #BASIC
define view entity ZI_ObjectCatalogEntries
  as select from tadir
  association [0..1] to I_RequestsHeader      as _TransportRequest  on _TransportRequest.TransportRequestID = $projection.TransportRequest
  association [1..1] to ZI_ABAPPackages       as _ABAPPackage       on _ABAPPackage.ABAPPackage = $projection.ABAPPackage
  association [0..1] to ZI_SoftwareComponents as _SoftwareComponent on _SoftwareComponent.SoftwareComponent = $projection.SoftwareComponent
  association [0..1] to I_Language            as _MasterLanguage    on _MasterLanguage.Language = $projection.MasterLanguage
{
  key pgmid      as ProgramId,
  key object     as ObjectType,
  key obj_name   as ObjectName,
      @ObjectModel.foreignKey.association: '_TransportRequest'
      korrnum    as TransportRequest,
      srcsystem  as SourceSystem,
      @Semantics.user.responsible: true
      author     as Author,
      srcdep     as Repair,
      @ObjectModel.foreignKey.association: '_ABAPPackage'
      devclass   as ABAPPackage,
      genflag    as IsGenerated,
      edtflag    as IsEditable,
      cproject   as CustomerProject,
      @ObjectModel.foreignKey.association: '_MasterLanguage'
      @Semantics.language: true
      masterlang as MasterLanguage,
      versid     as VersionId,
      paknocheck as NoPackageCheck,
      objstablty as DeploymentTarget,
      @ObjectModel.foreignKey.association: '_SoftwareComponent'
      component  as SoftwareComponent,
      crelease   as SapRelease,
      delflag    as DeletionFlag,
      translttxt as TranslateText,
      created_on as CreatedOn,
      check_date as CheckDate,
      check_cfg  as CheckConfiguration,
      _ABAPPackage,
      _SoftwareComponent,
      _TransportRequest,
      _MasterLanguage
}
