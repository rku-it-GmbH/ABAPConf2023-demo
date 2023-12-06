@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Application components'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.representativeKey: 'ApplicationComponent'
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #META
}
@VDM.viewType: #BASIC
define view entity ZI_ApplicationComponents
  as select from df14l
  association to ZI_ApplicationComponentTexts as _Text on _Text.ApplicationComponent = $projection.ApplicationComponent
  with default filter _Text.Language = $session.system_language
{
      @ObjectModel.text.association: '_Text'
  key fctr_id    as ApplicationComponent,
      @Semantics.user.createdBy: true
      fstuser    as CreatedByUser,
      @Semantics.systemDate.createdAt: true
      fstdate    as CreatedAtDate,
      @Semantics.systemTime.createdAt: true
      fsttime    as CreatedAtTime,
      @Semantics.user.lastChangedBy: true
      lstuser    as LastChangedByUser,
      @Semantics.systemDate.lastChangedAt: true
      lstdate    as LastChangedAtDate,
      @Semantics.systemTime.lastChangedAt: true
      lsttime    as LastChangedAtTime,
      rele       as CreatedAtSapRelease,
      lstrele    as LastChangedAtSapRelease,
      ariid      as AriId,
      ps_posid   as ExternalId,
      xref       as CrossReference,
      custass    as CustomizingAssigned,
      ale_aggr   as AleAggregate,
      desktop    as DesktopFlag,
      www        as WebFlag,
      released   as Released,
      incomplete as Incomplete,
      synch      as Synchronized,
      visible    as Visible,
      @Semantics.systemDateTime.lastChangedAt: true
      tstamp     as Timestamp,
      uname1     as UserResponsibleForCustomizing,
      uname2     as UserResponsibleForReleaseNotes,
      selectable as Selectable,
      _Text
}
where
  as4local = 'A'
