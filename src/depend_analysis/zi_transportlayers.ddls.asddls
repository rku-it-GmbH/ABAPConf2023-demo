@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Transport layers'
@Metadata.ignorePropagatedAnnotations: true
@VDM.viewType: #BASIC
define view entity ZI_TransportLayers 
  as select from(
                        tcevers  as Version
      left outer join   tceverst as VersionText        on  Version.version   = VersionText.version
                                                       and VersionText.spras = $session.system_language
  )
    inner join(
                        tcetral  as TransportLayer
        left outer join tcetralt as TransportLayerText on  TransportLayer.version    = TransportLayerText.version
                                                       and TransportLayer.translayer = TransportLayerText.translayer
                                                       and TransportLayerText.spras  = $session.system_language
    )
    on TransportLayer.version = Version.version
    inner join          tcerele  as Route              on  Route.version    = TransportLayer.version
                                                       and Route.translayer = TransportLayer.translayer
{
  key Route.version            as Version,
  key Route.translayer         as Translayer,
  key Route.intsys             as SourceSystem,
      Route.consys             as TargetSystem,
      Route.oricon             as OriginalSourceSystem,
      TransportLayerText.ctext as TransportLayerText,
      Version.delcascade       as DeliveryCascade,
      Version.author           as Author,
      Version.changed          as Changed,
      Version.activation       as Activation,
      Version.deactivat        as Deactivation,
      Version.controler        as Controller,
      Version.convers          as ConfigVersion,
      VersionText.vstext       as VersionText
}
where
  Version.active = 'A' 
