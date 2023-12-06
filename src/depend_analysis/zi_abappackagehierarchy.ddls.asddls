@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Package hierarchy'
define hierarchy ZI_ABAPPackageHierarchy
  with parameters
    p_root : devclass
  as parent child hierarchy(
    source ZI_ABAPPackages
    child to parent association _ParentABAPPackage
    start where
      ABAPPackage = $parameters.p_root
    siblings order by
      ABAPPackage
  )

{
  key ABAPPackage,
      WriteTransportRequests,
      Author,
      TransportLayer,
      DeliveryUnit,
      ApplicationComponent,
      Namespace,
      CustomerDelivery,
      Shipment,
      ParentABAPPackage,
      ApplicationArea,
      PackageType,
      Restricted,
      MainPackage,
      CreatedBy,
      CreatedOn,
      ChangedBy,
      ChangedOn,
      SrvCheck,
      CliCheck,
      ExtAlias,
      ProjectGuid,
      ProjectPassdown,
      IsEnhanceable,
      PackageKind,
      EnhancedPackage,
      AccessObject,
      DefaultIntf,
      InheritCliIntf,
      TechChgTstmp,
      OverallTstmp,
      Encapsulation,
      DclEnabled,
      SubKey,
      AllowStatic,
      SwitchId,
      CheckRule,
      $node.hierarchy_rank        as Rank,
      $node.hierarchy_parent_rank as ParentRank,
      /* Associations */
      _ApplicationComponent,
      _PackageInterfaces,
      _ParentABAPPackage,
      _SoftwareComponent,
      _Text,
      _TransportLayer,
      _UseAccesses
}
